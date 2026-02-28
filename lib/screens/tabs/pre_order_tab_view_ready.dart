part of 'pre_order_tab.dart';

extension _PreOrderTabReadyView on _PreOrderTabState {
  Widget _buildReadyOrdersSection() {
    final ready = _readyOrders();
    if (ready.isEmpty) return const Text('No ready pre-orders yet.');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Ready Pre-Orders (FH View)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...ready.map(_buildReadyOrderCard),
    ]);
  }

  Widget _buildReadyOrderCard(Map<String, dynamic> order) {
    final customer = (order['customer'] ?? '-').toString();
    final orderId = (order['id'] ?? '').toString();
    final total = (order['total'] as num?)?.toDouble() ?? 0;
    final itemsLabel = _itemNames(order);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.green.shade200), borderRadius: BorderRadius.circular(8), color: Colors.green.shade50),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$customer • $orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Products: $itemsLabel'),
        const SizedBox(height: 4),
        Text('Total: ${total.toStringAsFixed(2)} THB'),
      ]),
    );
  }
}