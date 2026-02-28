import 'package:flutter/material.dart';

import '../../services/supabase_service.dart';

class HomeTabPendingOrderRow extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onVerified;
  final VoidCallback onStateChanged;

  const HomeTabPendingOrderRow({
    super.key,
    required this.order,
    required this.onVerified,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (order['customer'] ?? '-').toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(order['items'] as List?)?.length ?? 0} items | Logged by ${order['loggedBy'] ?? order['logged_by'] ?? '-'}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${total.toStringAsFixed(2)} THB',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final orderId = (order['id'] ?? '').toString();
                  if (orderId.isNotEmpty) {
                    await SupabaseService.instance.updateOnlineOrderStatus(
                      orderId,
                      'verified',
                    );
                  }
                  order['status'] = 'verified';
                  onVerified();
                  onStateChanged();
                },
                child: const Text('Verify'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
