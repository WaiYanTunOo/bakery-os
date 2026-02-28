import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // for RealtimeChannel & types
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../data/app_data.dart';
import 'auth_gate_screen.dart';

import 'tabs/home_tab.dart';
import 'tabs/expense_tab.dart';
import 'tabs/expense_ledger_tab.dart';
import 'tabs/pre_order_tab.dart';
import 'tabs/production_delivery_tab.dart';
import 'tabs/catalog_tab.dart';
import 'tabs/staff_manager_tab.dart';
import 'tabs/verified_ledger_tab.dart';
import 'tabs/eod_tab.dart';

part 'dashboard_screen_realtime.dart';
part 'dashboard_screen_data.dart';
part 'dashboard_screen_view.dart';
part 'dashboard_screen_content.dart';
part 'dashboard_screen_auth.dart';

// --- SCREEN 2: MAIN DASHBOARD ---
class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const DashboardScreen({super.key, required this.currentUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _activeTab = 'home';
  bool _isLoading = true;
  
  // App State passed to all children
  final AppData _appData = AppData();
  
  // The service provides access to Supabase functionality
  // (client should not be referenced directly in widgets).
  // final supabase = Supabase.instance.client; // removed

  RealtimeChannel? _showcaseChannel;
  RealtimeChannel? _ordersChannel;
  RealtimeChannel? _expensesChannel;

  @override
  void initState() {
    super.initState();
    _loadDataFromSupabase();
    _setupRealtimeListeners();
  }

  // cleanup
  @override
  void dispose() {
    _showcaseChannel?.unsubscribe();
    _ordersChannel?.unsubscribe();
    _expensesChannel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDashboard();
  }

  void _setDashboardState(VoidCallback updater) {
    if (!mounted) return;
    setState(updater);
  }

  void _setActiveTab(String tabId) {
    if (!_isTabAllowed(tabId)) return;
    _setDashboardState(() => _activeTab = tabId);
  }

  void _setLoading(bool loading) {
    _setDashboardState(() => _isLoading = loading);
  }
}