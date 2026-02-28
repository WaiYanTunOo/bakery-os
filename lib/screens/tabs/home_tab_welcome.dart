import 'package:flutter/material.dart';

class HomeTabWelcome extends StatelessWidget {
  final String name;

  const HomeTabWelcome({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(Icons.coffee, size: 80, color: Colors.indigo.shade200),
          const SizedBox(height: 16),
          Text(
            'Welcome, $name',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Use the menu on the left to begin your shift.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
