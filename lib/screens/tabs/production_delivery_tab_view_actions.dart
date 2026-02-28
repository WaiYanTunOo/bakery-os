part of 'production_delivery_tab.dart';

extension _ProductionDeliveryTabActionView on _ProductionDeliveryTabState {
  Widget _buildReadinessActions() {
    final orders = _ordersForDate();
    if (orders.isEmpty) return const Text('No orders for this date.');
    return Column(children: orders.map(_buildReadinessOrderRow).toList());
  }

  Widget _buildReadinessOrderRow(Map<String, dynamic> order) {
    final status = (order['status'] ?? 'pending').toString();
    final customer = (order['customer'] ?? '-').toString();
    final itemCount = (order['items'] as List).length;
    final total = (order['total'] as num?)?.toDouble() ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$customer • ${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)), Text('$itemCount items • ${total.toStringAsFixed(2)} THB')])),
        _buildReadinessStatus(status, order),
      ]),
    );
  }

  Widget _buildReadinessStatus(String status, Map<String, dynamic> order) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
      Chip(label: Text(status), backgroundColor: _statusColor(status).withValues(alpha: 0.15), labelStyle: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold)),
      if (status == 'verified') TextButton(onPressed: _canCompleteShowcase ? () => _updateOrderStatus(order, 'in_progress') : null, child: const Text('Start Prep')),
      if (status == 'in_progress') TextButton(onPressed: _canCompleteShowcase ? () => _updateOrderStatus(order, 'ready') : null, child: const Text('Mark Ready')),
    ]);
  }

  Widget _buildPendingShowcaseActions(Map<String, dynamic> req) {
    if (!_canCompleteShowcase) return const Chip(label: Text('Baking...'), backgroundColor: Colors.amber);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: 70, child: TextField(decoration: const InputDecoration(hintText: 'Qty', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (val) => _bhInputs[(req['id'] ?? '').toString()] = val)),
      const SizedBox(width: 8),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white), onPressed: () => _completeShowcaseRequest(req), child: const Text('Deliver')),
    ]);
  }

  Widget _buildDeliveredChip(int deliveredQty) {
    return Chip(label: Text(deliveredQty == 0 ? 'Out of Stock' : 'Delivered $deliveredQty'), backgroundColor: deliveredQty == 0 ? Colors.red.shade100 : Colors.green.shade100);
  }
}