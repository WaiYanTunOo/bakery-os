import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth_gate_screen.dart';
import 'utils/secret_manager.dart';

const _envSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _envSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('.env not loaded, proceeding with secure storage / dart-define');
  }

  try {
    final credentials = await SecretManager.ensureSupabaseCredentials(
      envUrl: _envSupabaseUrl,
      envAnonKey: _envSupabaseAnonKey,
    );

    await Supabase.initialize(
      url: credentials['url']!,
      anonKey: credentials['anonKey']!,
    );
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
    runApp(const StartupErrorApp());
    return;
  }

  runApp(const BakeryOSApp());
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Startup configuration error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Supabase credentials are missing or invalid. Provide values via --dart-define or .env for development.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BakeryOSApp extends StatelessWidget {
  const BakeryOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BakeryOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const AuthGateScreen(),
    );
  }
}