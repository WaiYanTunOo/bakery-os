part of 'staff_manager_tab.dart';

extension _StaffManagerTabView on _StaffManagerTabState {
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );

    if (remove != true) return;
    _setStaffState(() => widget.appData.staffDirectory.removeWhere((s) => s['id'] == staff['id']));
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

  Widget _buildStaffManagerContent() {
    final rows = widget.appData.staffDirectory.where((staff) => staff['id'] != 'owner').toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Staff & Permissions Directory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 320, child: _buildAddStaffCard()),
          const SizedBox(width: 16),
          SizedBox(width: 620, child: _buildStaffTable(rows)),
        ]),
      ),
    ]);
  }

  Widget _buildAddStaffCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add Staff', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _stfNameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _stfRole,
            decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
            items: const [DropdownMenuItem(value: 'FH', child: Text('FH')), DropdownMenuItem(value: 'BH', child: Text('BH'))],
            onChanged: (val) => _setStaffState(() => _stfRole = val ?? 'FH'),
          ),
          const SizedBox(height: 16),
          Row(children: [Checkbox(value: _stfPerm, onChanged: (val) => _setStaffState(() => _stfPerm = val ?? false)), const Text('Can Manage Menu?')]),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _addStaff, child: const Text('Add Staff'))),
        ]),
      ),
    );
  }

  Widget _buildStaffTable(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No staff members added yet.')));
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [DataColumn(label: Text('Name')), DataColumn(label: Text('Role')), DataColumn(label: Text('Menu Perm')), DataColumn(label: Text('Action'))],
          rows: rows.map((staff) => DataRow(cells: [
            DataCell(Text((staff['name'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Chip(label: Text((staff['role'] ?? '').toString()))),
            DataCell(Checkbox(value: (staff['can_manage_products'] ?? false) as bool, onChanged: (val) => _toggleMenuPermission(staff, val ?? false))),
            DataCell(IconButton(onPressed: () => _removeStaff(staff), icon: const Icon(Icons.delete_outline, color: Colors.red))),
          ])).toList(),
        ),
      ),
    );
  }
}
