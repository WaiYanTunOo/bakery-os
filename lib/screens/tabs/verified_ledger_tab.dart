import 'package:flutter/material.dart';
import '../../data/app_data.dart';

class VerifiedLedgerTab extends StatelessWidget {
  final AppData appData;

  const VerifiedLedgerTab({super.key, required this.appData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Verified Sales Ledger', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Card(
          child: DataTable(
            columns: const [DataColumn(label: Text('ID')), DataColumn(label: Text('Customer')), DataColumn(label: Text('Items')), DataColumn(label: Text('Total'))],
            rows: appData.onlineOrders.where((o) => o['status'] == 'verified').map((o) => DataRow(cells: [
              DataCell(Text(o['id'])),
              DataCell(Text(o['customer'])),
              DataCell(Text('${o['items'].length} item(s)')),
              DataCell(Text('${o['total']} THB', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
            ])).toList(),
          ),
        )
      ],
    );
  }
}