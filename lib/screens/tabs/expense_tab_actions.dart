part of 'expense_tab.dart';

extension _ExpenseTabActions on _ExpenseTabState {
  List<DropdownMenuItem<String>> _paymentSourceItems() {
    final role = widget.currentUser['role'];
    final items = <String, DropdownMenuItem<String>>{};
    if (role != 'BH') {
      items['Petty Cash (Register)'] = const DropdownMenuItem(
        value: 'Petty Cash (Register)',
        child: Text('Cash Register (Petty Cash)'),
      );
    }
    items['Staff Pocket'] = const DropdownMenuItem(
      value: 'Staff Pocket',
      child: Text('Staff Paid Out of Pocket'),
    );
    if (role == 'Owner') {
      items['Owner Transfer'] = const DropdownMenuItem(
        value: 'Owner Transfer',
        child: Text('Owner Transferred directly'),
      );
    }
    return items.values.toList();
  }

  void _submitExpense(BuildContext context) {
    if (_expDescCtrl.text.isEmpty || _expPriceCtrl.text.isEmpty) return;

    final price = double.tryParse(_expPriceCtrl.text) ?? 0;
    final qty = int.tryParse(_expQtyCtrl.text) ?? 1;

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
      'loggedBy': widget.currentUser['name'],
    });

    _expDescCtrl.clear();
    _expPriceCtrl.clear();
    _expRemarkCtrl.clear();
    _expQtyCtrl.text = '1';

    widget.onStateChanged();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense Logged!')));
  }
}
