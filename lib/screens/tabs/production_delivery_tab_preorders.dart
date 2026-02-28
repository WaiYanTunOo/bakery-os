part of 'production_delivery_tab.dart';

extension _ProductionDeliveryTabPreOrders on _ProductionDeliveryTabState {
  void _computePreOrders() {
    final verified = <String, int>{};
    var pending = 0;
    var inProgress = 0;
    var ready = 0;
    for (final order in widget.appData.onlineOrders) {
      final status = (order['status'] ?? '').toString();
      final items = order['items'];
      if (items is! List) continue;
      for (final rawItem in items) {
        if (rawItem is! Map) continue;
        final item = Map<String, dynamic>.from(rawItem);
        if ((item['deliveryDate'] ?? '').toString() != _targetDate) continue;
        final qty = (item['qty'] as num?)?.toInt() ?? 0;
        final name = (item['name'] ?? '').toString();
        if (qty <= 0 || name.isEmpty) continue;
        if (status == 'verified') {
          verified[name] = (verified[name] ?? 0) + qty;
        } else if (status == 'pending') {
          pending += qty;
        } else if (status == 'in_progress') {
          verified[name] = (verified[name] ?? 0) + qty;
          inProgress += qty;
        } else if (status == 'ready') {
          ready += qty;
        }
      }
    }
    _setPreOrderSummary(
      verified: verified,
      pending: pending,
      inProgress: inProgress,
      ready: ready,
    );
  }
}