import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/app_data.dart';
import '../../utils/audit_logger.dart';

class StaffManagerTab extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final AppData appData;
  final VoidCallback onStateChanged;

  const StaffManagerTab({
    super.key,
    required this.currentUser,
    required this.appData,
    required this.onStateChanged,
  });

  @override
  State<StaffManagerTab> createState() => _StaffManagerTabState();
}

class _StaffManagerTabState extends State<StaffManagerTab> {
  final TextEditingController _stfNameCtrl = TextEditingController();
  String _stfRole = 'FH';
  bool _stfPerm = false;

  bool get _isOwnerOnlyContext {
    return widget.currentUser['role'] == 'Owner';
  }

  String get _actorName {
    return (widget.currentUser['name'] ?? 'unknown').toString();
  }

  @override
  void dispose() {
    _stfNameCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String message, {required bool error}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  bool _isNameDuplicate(String name) {
    final normalized = name.trim().toLowerCase();
    return widget.appData.staffDirectory.any(
      (staff) => (staff['name'] ?? '').toString().trim().toLowerCase() == normalized,
    );
  }

  void _addStaff() {
    if (!_isOwnerOnlyContext) {
      _showMessage('Staff management is owner-only.', error: true);
      return;
    }

    final name = _stfNameCtrl.text.trim();
    if (name.length < 2 || name.length > 100) {
      _showMessage('Name must be 2-100 characters.', error: true);
      return;
    }
    if (_isNameDuplicate(name)) {
      _showMessage('A staff member with this name already exists.', error: true);
      return;
    }

    final staffId = 's${Random().nextInt(1000000).toString().padLeft(6, '0')}';
    final record = {
      'id': staffId,
      'name': name,
      'role': _stfRole,
      'can_manage_products': _stfPerm,
    };

    setState(() {
      widget.appData.staffDirectory.add(record);
      _stfNameCtrl.clear();
      _stfRole = 'FH';
      _stfPerm = false;
    });
    widget.onStateChanged();

    AuditLogger.action(
      actor: _actorName,
      role: 'Owner',
      action: 'create',
      entity: 'staff_member',
      entityId: staffId,
      metadata: {'role': _stfRole, 'can_manage_products': _stfPerm},
    );
    _showMessage('Staff member added.', error: false);
  }

  void _toggleMenuPermission(Map<String, dynamic> staff, bool value) {
    if (!_isOwnerOnlyContext) {
      _showMessage('Permission changes are owner-only.', error: true);
      return;
    }

    staff['can_manage_products'] = value;
    widget.onStateChanged();

    AuditLogger.action(
      actor: _actorName,
      role: 'Owner',
      action: 'update',
      entity: 'staff_member',
      entityId: (staff['id'] ?? '').toString(),
      metadata: {'can_manage_products': value},
    );
  }

  Future<void> _removeStaff(Map<String, dynamic> staff) async {
    if (!_isOwnerOnlyContext) {
      _showMessage('Staff removal is owner-only.', error: true);
      return;
    }

    final name = (staff['name'] ?? 'Unknown').toString();
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove staff member'),
        content: Text('Are you sure you want to remove $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (remove != true) return;

    widget.appData.staffDirectory.removeWhere((s) => s['id'] == staff['id']);
    widget.onStateChanged();

    AuditLogger.action(
      actor: _actorName,
      role: 'Owner',
      action: 'delete',
      entity: 'staff_member',
      entityId: (staff['id'] ?? '').toString(),
      metadata: {'name': name},
    );
    _showMessage('Staff member removed.', error: false);
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.appData.staffDirectory.where((staff) => staff['id'] != 'owner').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Staff & Permissions Directory',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 320,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add Staff', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _stfNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _stfRole,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'FH', child: Text('FH')),
                            DropdownMenuItem(value: 'BH', child: Text('BH')),
                          ],
                          onChanged: (val) => setState(() => _stfRole = val ?? 'FH'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _stfPerm,
                              onChanged: (val) => setState(() => _stfPerm = val ?? false),
                            ),
                            const Text('Can Manage Menu?'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addStaff,
                            child: const Text('Add Staff'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 620,
                child: Card(
                  child: rows.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No staff members added yet.'),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Role')),
                              DataColumn(label: Text('Menu Perm')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: rows.map((staff) {
                              return DataRow(
                                cells: [
                                  DataCell(Text((staff['name'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Chip(label: Text((staff['role'] ?? '').toString()))),
                                  DataCell(
                                    Checkbox(
                                      value: (staff['can_manage_products'] ?? false) as bool,
                                      onChanged: (val) => _toggleMenuPermission(staff, val ?? false),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      onPressed: () => _removeStaff(staff),
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
