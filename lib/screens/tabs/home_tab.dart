import 'package:flutter/material.dart';
import '../../data/app_data.dart';

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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Icon(Icons.coffee, size: 80, color: Colors.indigo.shade200),
            const SizedBox(height: 16),
            Text('Welcome, ${currentUser['name']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Use the menu on the left to begin your shift.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    int pendingCount = appData.onlineOrders.where((o) => o['status'] == 'pending').length;
    double verifiedRev = appData.onlineOrders.where((o) => o['status'] == 'verified').fold(0.0, (sum, o) => sum + o['total']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Owner Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(width: 200, child: _buildStatCard('Pending Transfers', pendingCount.toString(), Icons.pending_actions, Colors.orange)),
              const SizedBox(width: 16),
              SizedBox(width: 200, child: _buildStatCard('Verified Revenue', '$verifiedRev THB', Icons.check_circle, Colors.green)),
              const SizedBox(width: 16),
              SizedBox(width: 200, child: _buildStatCard('Pending Shift Reviews', appData.eodReports.length.toString(), Icons.assignment, Colors.indigo)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Clearing Account (Needs Verification)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                appData.onlineOrders.where((o) => o['status'] == 'pending').isEmpty 
                  ? const Text('No pending orders.')
                  : ListView(
                      shrinkWrap: true,
                      children: appData.onlineOrders.where((o) => o['status'] == 'pending').map((order) {
                        return ListTile(
                          title: Text(order['customer'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${order['items'].length} items | Logged by ${order['loggedBy']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${order['total']} THB', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                onPressed: () {
                                  order['status'] = 'verified';
                                  onStateChanged();
                                },
                                child: const Text('Verify'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}