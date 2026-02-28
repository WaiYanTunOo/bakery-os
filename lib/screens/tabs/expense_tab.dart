import 'package:flutter/material.dart';
import 'dart:math';
import '../../data/app_data.dart';
import '../../utils/data_utils.dart';

class ExpenseTab extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final AppData appData;
  final VoidCallback onStateChanged;

  const ExpenseTab({super.key, required this.currentUser, required this.appData, required this.onStateChanged});

  @override
  State<ExpenseTab> createState() => _ExpenseTabState();
}

class _ExpenseTabState extends State<ExpenseTab> {
  final TextEditingController _expDescCtrl = TextEditingController();
  final TextEditingController _expQtyCtrl = TextEditingController(text: '1');
  final TextEditingController _expPriceCtrl = TextEditingController();
  final TextEditingController _expRemarkCtrl = TextEditingController();
  late String _expSource;

  @override
  void initState() {
    super.initState();
    final role = widget.currentUser['role'];
    if (role == 'BH') {
      _expSource = 'Staff Pocket';
    } else {
      _expSource = 'Petty Cash (Register)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt, color: Colors.pink),
                  SizedBox(width: 8),
                  Text('Log Daily Expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Text('Record ALL expenses here for detailed tracking. Use Qashier POS "Pay Out" for register cash.', style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _expDescCtrl,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: _expQtyCtrl, decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: _expPriceCtrl, decoration: const InputDecoration(labelText: 'Unit Price (THB)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _expSource,
                decoration: const InputDecoration(labelText: 'Payment Source', border: OutlineInputBorder()),
                items: () {
                  final role = widget.currentUser['role'];
                  // use map to dedupe values
                  final map = <String, DropdownMenuItem<String>>{};
                  if (role != 'BH') {
                    map['Petty Cash (Register)'] = const DropdownMenuItem(
                        value: 'Petty Cash (Register)',
                        child: Text('Cash Register (Petty Cash)'));
                  }
                  map['Staff Pocket'] = const DropdownMenuItem(
                      value: 'Staff Pocket',
                      child: Text('Staff Paid Out of Pocket'));
                  if (role == 'Owner') {
                    map['Owner Transfer'] = const DropdownMenuItem(
                        value: 'Owner Transfer',
                        child: Text('Owner Transferred directly'));
                  }
                  return map.values.toList();
                }(),
                onChanged: (val) => setState(() => _expSource = val!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _expRemarkCtrl,
                decoration: const InputDecoration(labelText: 'Remarks (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                  onPressed: () {
                    if (_expDescCtrl.text.isEmpty || _expPriceCtrl.text.isEmpty) return;
                    double price = double.tryParse(_expPriceCtrl.text) ?? 0;
                    int qty = int.tryParse(_expQtyCtrl.text) ?? 1;
                    
                    widget.appData.expenses.insert(0, {
                      'id': 'EXP-${Random().nextInt(1000)}',
                      'date': AppDateUtils.todayStr(),
                      'time': AppDateUtils.timeStr(),
                      'description': _expDescCtrl.text,
                      'qty': qty,
                      'unitPrice': price,
                      'total': price * qty,
                      'paidFrom': _expSource,
                      'remark': _expRemarkCtrl.text,
                      'loggedBy': widget.currentUser['name']
                    });
                    
                    _expDescCtrl.clear();
                    _expPriceCtrl.clear();
                    _expRemarkCtrl.clear();
                    _expQtyCtrl.text = '1';
                    
                    widget.onStateChanged();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense Logged!')));
                  },
                  child: const Text('Submit Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}