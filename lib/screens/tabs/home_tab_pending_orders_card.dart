import 'package:flutter/material.dart';

import 'home_tab_pending_order_row.dart';

class HomeTabPendingOrdersCard extends StatelessWidget {
  final List<Map<String, dynamic>> pendingOrders;
  final void Function(String orderId) onVerify;
  final VoidCallback onStateChanged;

  const HomeTabPendingOrdersCard({
    super.key,
    required this.pendingOrders,
    required this.onVerify,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clearing Account (Needs Verification)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (pendingOrders.isEmpty)
              const Text('No pending orders.')
            else
              Column(
                children: pendingOrders
                    .map(
                      (order) => HomeTabPendingOrderRow(
                        order: order,
                        onVerified: () => onVerify((order['id'] ?? '').toString()),
                        onStateChanged: onStateChanged,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
