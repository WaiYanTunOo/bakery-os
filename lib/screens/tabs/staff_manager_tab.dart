import 'package:flutter/material.dart';
import 'dart:math';
import '../../data/app_data.dart';

class StaffManagerTab extends StatefulWidget {
  final AppData appData;
  final VoidCallback onStateChanged;

  const StaffManagerTab({super.key, required this.appData, required this.onStateChanged});

  @override
  State<StaffManagerTab> createState() => _StaffManagerTabState();
}

class _StaffManagerTabState extends State<StaffManagerTab> {
  final TextEditingController _stfNameCtrl = TextEditingController();
  String _stfRole = 'FH';
  bool _stfPerm = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Staff & Permissions Directory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 300,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add Staff', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(controller: _stfNameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                        const SizedBox(height: 16),
                        DropdownButtonFormField(
                          initialValue: _stfRole,
                          decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                          items: const [DropdownMenuItem(value:'FH',child:Text('FH')), DropdownMenuItem(value:'BH',child:Text('BH'))],
                          onChanged: (val) => setState(() => _stfRole = val.toString()),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(value: _stfPerm, onChanged: (val) => setState(() => _stfPerm = val!)),
                            const Text('Can Manage Menu?'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_stfNameCtrl.text.isEmpty) return;
                            widget.appData.staffDirectory.add({
                              'id': 's${Random().nextInt(1000)}', 
                              'name': _stfNameCtrl.text, 
                              'role': _stfRole, 
                              'can_manage_products': _stfPerm
                            });
                            _stfNameCtrl.clear();
                            widget.onStateChanged();
                          },
                          child: const Text('Add Staff'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 500,
                child: Card(
                  child: DataTable(
                    columns: const [DataColumn(label: Text('Name')), DataColumn(label: Text('Role')), DataColumn(label: Text('Menu Perm'))],
                    rows: widget.appData.staffDirectory.where((s) => s['id'] != 'owner').map((s) => DataRow(cells: [
                      DataCell(Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Chip(label: Text(s['role']))),
                      DataCell(Checkbox(value: s['can_manage_products'], onChanged: (val) {
                        s['can_manage_products'] = val!;
                        widget.onStateChanged();
                      })),
                    ])).toList(),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}