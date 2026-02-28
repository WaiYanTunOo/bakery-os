import 'package:flutter/material.dart';

import 'home_tab_stat_card.dart';

class HomeTabStatsRow extends StatelessWidget {
  final int pendingCount;
  final double verifiedRevenue;
  final int pendingShiftReviews;

  const HomeTabStatsRow({
    super.key,
    required this.pendingCount,
    required this.verifiedRevenue,
    required this.pendingShiftReviews,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: HomeTabStatCard(
              title: 'Pending Transfers',
              value: pendingCount.toString(),
              icon: Icons.pending_actions,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 200,
            child: HomeTabStatCard(
              title: 'Verified Revenue',
              value: '$verifiedRevenue THB',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 200,
            child: HomeTabStatCard(
              title: 'Pending Shift Reviews',
              value: pendingShiftReviews.toString(),
              icon: Icons.assignment,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }
}
