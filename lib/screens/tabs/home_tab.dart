import 'package:flutter/material.dart';
import '../../data/app_data.dart';
import 'home_tab_pending_orders_card.dart';
import 'home_tab_stats_row.dart';
import 'home_tab_welcome.dart';

class HomeTab extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final AppData appData;
  final VoidCallback onStateChanged;

  const HomeTab({
    super.key,
    required this.currentUser,
    required this.appData,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (currentUser['role'] != 'Owner') {
      return HomeTabWelcome(name: currentUser['name']?.toString() ?? 'Staff');
    }

    final pendingOrders = appData.onlineOrders.where((o) => o['status'] == 'pending').toList();
    final pendingCount = pendingOrders.length;
    final verifiedRev = appData.onlineOrders
        .where((o) => o['status'] == 'verified')
        .fold(0.0, (sum, o) => sum + ((o['total'] as num?)?.toDouble() ?? 0.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Owner Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        HomeTabStatsRow(
          pendingCount: pendingCount,
          verifiedRevenue: verifiedRev,
          pendingShiftReviews: appData.eodReports.length,
        ),
        const SizedBox(height: 24),
        HomeTabPendingOrdersCard(
          pendingOrders: pendingOrders,
          onVerify: (orderId) {
            onStateChanged();
          },
          onStateChanged: onStateChanged,
        ),
      ],
    );
  }
}