import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/app_data.dart';
import '../../services/supabase_service.dart';
import '../../utils/audit_logger.dart';
import '../../utils/data_utils.dart';

part 'production_delivery_tab_logic.dart';
part 'production_delivery_tab_preorders.dart';
part 'production_delivery_tab_status_actions.dart';
part 'production_delivery_tab_showcase_submit.dart';
part 'production_delivery_tab_showcase_complete.dart';
part 'production_delivery_tab_view.dart';
part 'production_delivery_tab_view_showcase_request.dart';
part 'production_delivery_tab_view_showcase_queue.dart';
part 'production_delivery_tab_view_preorder_queue.dart';
part 'production_delivery_tab_view_actions.dart';
part 'production_delivery_tab_state.dart';

class ProductionDeliveryTab extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final AppData appData;
  final VoidCallback onStateChanged;
  final Future<bool> Function(String id, String status)? onUpdateOrderStatus;

  const ProductionDeliveryTab({
    super.key,
    required this.currentUser,
    required this.appData,
    required this.onStateChanged,
    this.onUpdateOrderStatus,
  });

  @override
  State<ProductionDeliveryTab> createState() => _ProductionDeliveryTabState();
}

class _ProductionDeliveryTabState extends State<ProductionDeliveryTab> {
  String _targetDate = '';
  late final TextEditingController _targetDateController;
  String? _fhReqItem;
  final Map<String, String> _bhInputs = {};

  Map<String, int> _verifiedPreOrders = {};
  int _pendingForDate = 0;
  int _inProgressForDate = 0;
  int _readyForDate = 0;

  @override
  void initState() {
    super.initState();
    _targetDate = AppDateUtils.todayStr();
    _targetDateController = TextEditingController(text: _targetDate);
    _computePreOrders();
  }

  @override
  void dispose() {
    _targetDateController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProductionDeliveryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appData.onlineOrders != widget.appData.onlineOrders) {
      _computePreOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  void _setProductionState(VoidCallback updater) {
    if (!mounted) return;
    setState(updater);
  }
}
