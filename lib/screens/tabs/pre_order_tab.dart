import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/app_data.dart';
import '../../services/supabase_service.dart';
import '../../utils/audit_logger.dart';
import '../../utils/data_utils.dart';

part 'pre_order_tab_logic.dart';
part 'pre_order_tab_add_item.dart';
part 'pre_order_tab_submit.dart';
part 'pre_order_tab_view.dart';
part 'pre_order_tab_view_form.dart';
part 'pre_order_tab_view_cart.dart';
part 'pre_order_tab_view_ready.dart';
part 'pre_order_tab_state.dart';

class PreOrderTab extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final AppData appData;
  final VoidCallback onStateChanged;

  const PreOrderTab({
    super.key,
    required this.currentUser,
    required this.appData,
    required this.onStateChanged,
  });

  @override
  State<PreOrderTab> createState() => _PreOrderTabState();
}

class _PreOrderTabState extends State<PreOrderTab> {
  String _poCustomer = '';
  String? _poItem;
  int _poQty = 1;
  double _poPrice = 0.0;
  String _poDate = '';
  final List<Map<String, dynamic>> _currentCart = [];
  bool _poAutoVerify = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _poDate = AppDateUtils.todayStr();
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  void _setPreOrderState(VoidCallback updater) {
    if (!mounted) return;
    setState(updater);
  }
}