import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  Future<Map<String, dynamic>?> _profileFuture = AuthService.instance.resolveCurrentUserProfile();

  void _refreshProfile() {
    setState(() {
      _profileFuture = AuthService.instance.resolveCurrentUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService.instance.authChanges,
      builder: (context, authState) {
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser == null) {
          return LoginScreen(onSignedIn: _refreshProfile);
        }

        return FutureBuilder<Map<String, dynamic>?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final profile = snapshot.data;
            if (profile == null) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.no_accounts, size: 56, color: Colors.red),
                        const SizedBox(height: 12),
                        const Text('Access denied', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 8),
                        const Text('Your account is authenticated but not mapped to a staff role.'),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () async {
                            await AuthService.instance.signOut();
                            _refreshProfile();
                          },
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return DashboardScreen(currentUser: profile);
          },
        );
      },
    );
  }
}
