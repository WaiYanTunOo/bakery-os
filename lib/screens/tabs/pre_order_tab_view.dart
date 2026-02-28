part of 'pre_order_tab.dart';

extension _PreOrderTabView on _PreOrderTabState {
  Widget _buildContent(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = viewportWidth < 560 ? 560.0 : (viewportWidth < 900 ? viewportWidth : 900.0);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: contentWidth,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.shopping_cart, color: Colors.indigo), SizedBox(width: 8), Text('Log Pre-Order Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 8),
              if (!_canCreateOrder) Text('Read-only for your role. Only FH or Owner can create pre-orders.', style: TextStyle(color: Colors.orange.shade800)),
              const SizedBox(height: 16),
              TextField(decoration: const InputDecoration(labelText: 'Customer Name / Social Handle', border: OutlineInputBorder()), onChanged: (val) => _poCustomer = val),
              const SizedBox(height: 24),
              _buildFormSection(),
              const SizedBox(height: 24),
              _buildCartSection(),
              if (_canViewReadyOrders) ...[const SizedBox(height: 24), const Divider(), const SizedBox(height: 8), _buildReadyOrdersSection()],
            ]),
          ),
        ),
      ),
    );
  }
}