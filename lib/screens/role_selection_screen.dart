import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'dashboard_screen.dart';

// --- SCREEN 1: LOGIN ---
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront, size: 64, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text('BakeryOS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text('Select a user to simulate login', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              ...initialStaff.map((staff) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: staff['role'] == 'Owner' ? Colors.indigo.shade100 : 
                                     staff['role'] == 'FH' ? Colors.blue.shade100 : Colors.orange.shade100,
                    child: Icon(
                      staff['role'] == 'Owner' ? Icons.trending_up : 
                      staff['role'] == 'FH' ? Icons.point_of_sale : Icons.kitchen,
                      color: staff['role'] == 'Owner' ? Colors.indigo : 
                             staff['role'] == 'FH' ? Colors.blue : Colors.orange,
                    ),
                  ),
                  title: Text(staff['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Role: ${staff['role']}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardScreen(currentUser: staff)),
                    );
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}