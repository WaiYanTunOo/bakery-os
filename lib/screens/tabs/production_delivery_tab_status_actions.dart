part of 'production_delivery_tab.dart';

extension _ProductionDeliveryTabStatusActions on _ProductionDeliveryTabState {
  Future<void> _updateOrderStatus(Map<String, dynamic> order, String newStatus) async {
    if (!_canCompleteShowcase) {
      _showMessage('Only BH or Owner can update pre-order readiness.', error: true);
      return;
    }
    final orderId = (order['id'] ?? '').toString();
    if (orderId.isEmpty) {
      _showMessage('Invalid order ID.', error: true);
      return;
    }
    final actor = widget.currentUser['name']?.toString() ?? 'Unknown';
    final role = widget.currentUser['role']?.toString() ?? 'Unknown';
    try {
      final ok = await (widget.onUpdateOrderStatus?.call(orderId, newStatus) ??
          SupabaseService.instance.updateOnlineOrderStatus(orderId, newStatus));
      if (!mounted) return;
      if (!ok) return _showMessage('Failed to update order status.', error: true);
      final orderIndex = widget.appData.onlineOrders.indexWhere((entry) => (entry['id'] ?? '').toString() == orderId);
      if (orderIndex != -1) widget.appData.onlineOrders[orderIndex]['status'] = newStatus;
      _computePreOrders();
      widget.onStateChanged();
      AuditLogger.action(
        actor: actor,
        role: role,
        action: 'update',
        entity: 'online_order',
        entityId: orderId,
        metadata: {'status': newStatus},
      );
      _showMessage('Order updated to $newStatus.', error: false);
    } on ValidationError catch (e) {
      if (mounted) _showMessage(e.message, error: true);
    } catch (_) {
      if (mounted) _showMessage('Unexpected error while updating order.', error: true);
    }
  }
}