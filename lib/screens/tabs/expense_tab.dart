import 'package:flutter/material.dart';
import 'dart:math';

import '../../data/app_data.dart';
import '../../utils/data_utils.dart';

part 'expense_tab_view.dart';
part 'expense_tab_actions.dart';

class ExpenseTab extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final AppData appData;
  final VoidCallback onStateChanged;

  const ExpenseTab({
    super.key,
    required this.currentUser,
    required this.appData,
    required this.onStateChanged,
  });

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
    return _buildExpenseCard(context);
  }

  void _setExpenseSource(String value) {
    setState(() => _expSource = value);
  }
}