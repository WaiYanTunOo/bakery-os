import 'package:flutter/material.dart';
import '../../data/app_data.dart';

class ExpenseLedgerTab extends StatelessWidget {
  final AppData appData;

  const ExpenseLedgerTab({super.key, required this.appData});

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = appData.expenses.fold(0.0, (sum, e) => sum + e['total']);
    double staffOwed = appData.expenses.where((e) => e['paidFrom'] == 'Staff Pocket').fold(0.0, (sum, e) => sum + e['total']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Expense Book Ledger', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard('Total Expenses', '$total THB', Icons.receipt_long, Colors.pink),
            const SizedBox(width: 16),
            _buildStatCard('Owed to Staff', '$staffOwed THB', Icons.warning, Colors.red),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date & Time')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Source')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Logged By')),
              ],
              rows: appData.expenses.map((e) => DataRow(cells: [
                DataCell(Text('${e['date']} ${e['time']}')),
                DataCell(Text(e['description'])),
                DataCell(Text(e['paidFrom'])),
                DataCell(Text('${e['total']} THB', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink))),
                DataCell(Text(e['loggedBy'])),
              ])).toList(),
            ),
          ),
        )
      ],
    );
  }
}