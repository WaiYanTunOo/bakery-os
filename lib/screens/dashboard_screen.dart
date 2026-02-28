import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/app_data.dart';
import 'role_selection_screen.dart';

import 'tabs/home_tab.dart';
import 'tabs/expense_tab.dart';
import 'tabs/expense_ledger_tab.dart';
import 'tabs/pre_order_tab.dart';
import 'tabs/production_delivery_tab.dart';
import 'tabs/catalog_tab.dart';
import 'tabs/staff_manager_tab.dart';
import 'tabs/verified_ledger_tab.dart';
import 'tabs/eod_tab.dart';

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
  
  // Supabase client instance
  final supabase = Supabase.instance.client;

  RealtimeChannel? _showcaseChannel;
  RealtimeChannel? _ordersChannel;
  RealtimeChannel? _expensesChannel;

  @override
  void initState() {
    super.initState();
    _loadDataFromSupabase();
    _setupRealtimeListeners();
  }

  /// Set up Supabase real-time subscriptions for tables that change frequently.
  void _setupRealtimeListeners() {
    // Listen to showcase_requests changes
    _showcaseChannel = supabase
        .channel('public:showcase_requests')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'showcase_requests',
          callback: (payload) => _handleShowcaseChange(payload),
        )
        .subscribe();

    // Listen to online_orders changes
    _ordersChannel = supabase
        .channel('public:online_orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'online_orders',
          callback: (payload) => _handleOrderChange(payload),
        )
        .subscribe();

    // Listen to expenses changes
    _expensesChannel = supabase
        .channel('public:expenses')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'expenses',
          callback: (payload) => _handleExpenseChange(payload),
        )
        .subscribe();
  }

  /// Handle real-time changes to showcase_requests
  void _handleShowcaseChange(PostgresChangePayload payload) {
    if (!mounted) return;
    final newRecord = payload.newRecord;
    final oldRecord = payload.oldRecord;

    setState(() {
      if (payload.eventType == PostgresChangeEvent.insert && newRecord.isNotEmpty) {
        // Add new request to the front
        _appData.showcaseRequests.insert(0, newRecord);
      } else if (payload.eventType == PostgresChangeEvent.update && newRecord.isNotEmpty) {
        // Find and update the record
        final index = _appData.showcaseRequests.indexWhere((r) => r['id'] == newRecord['id']);
        if (index >= 0) {
          _appData.showcaseRequests[index] = newRecord;
        }
      } else if (payload.eventType == PostgresChangeEvent.delete && oldRecord.isNotEmpty) {
        // Remove deleted record
        _appData.showcaseRequests.removeWhere((r) => r['id'] == oldRecord['id']);
      }
    });
  }

  /// Handle real-time changes to online_orders
  void _handleOrderChange(PostgresChangePayload payload) {
    if (!mounted) return;
    final newRecord = payload.newRecord;
    final oldRecord = payload.oldRecord;

    setState(() {
      if (payload.eventType == PostgresChangeEvent.insert && newRecord.isNotEmpty) {
        _appData.onlineOrders.insert(0, newRecord);
      } else if (payload.eventType == PostgresChangeEvent.update && newRecord.isNotEmpty) {
        final index = _appData.onlineOrders.indexWhere((o) => o['id'] == newRecord['id']);
        if (index >= 0) {
          _appData.onlineOrders[index] = newRecord;
        }
      } else if (payload.eventType == PostgresChangeEvent.delete && oldRecord.isNotEmpty) {
        _appData.onlineOrders.removeWhere((o) => o['id'] == oldRecord['id']);
      }
    });
  }

  /// Handle real-time changes to expenses
  void _handleExpenseChange(PostgresChangePayload payload) {
    if (!mounted) return;
    final newRecord = payload.newRecord;
    final oldRecord = payload.oldRecord;

    setState(() {
      if (payload.eventType == PostgresChangeEvent.insert && newRecord.isNotEmpty) {
        _appData.expenses.insert(0, newRecord);
      } else if (payload.eventType == PostgresChangeEvent.update && newRecord.isNotEmpty) {
        final index = _appData.expenses.indexWhere((e) => e['id'] == newRecord['id']);
        if (index >= 0) {
          _appData.expenses[index] = newRecord;
        }
      } else if (payload.eventType == PostgresChangeEvent.delete && oldRecord.isNotEmpty) {
        _appData.expenses.removeWhere((e) => e['id'] == oldRecord['id']);
      }
    });
  }

  // --- INITIAL DATA FETCH ---
  Future<void> _loadDataFromSupabase() async {
    setState(() => _isLoading = true);
    
    try {
      // Fetch all tables concurrently for better performance
      final responses = await Future.wait([
        supabase.from('menu_items').select(),
        supabase.from('staff_directory').select(),
        supabase.from('eod_reports').select().order('created_at', ascending: false),
        supabase.from('online_orders').select().order('created_at', ascending: false),
        supabase.from('expenses').select().order('created_at', ascending: false),
        supabase.from('showcase_requests').select().order('created_at', ascending: false),
      ]);

      setState(() {
        _appData.menuItems = List<Map<String, dynamic>>.from(responses[0]);
        _appData.staffDirectory = List<Map<String, dynamic>>.from(responses[1]);
        _appData.eodReports = List<Map<String, dynamic>>.from(responses[2]);
        _appData.onlineOrders = List<Map<String, dynamic>>.from(responses[3]);
        _appData.expenses = List<Map<String, dynamic>>.from(responses[4]);
        _appData.showcaseRequests = List<Map<String, dynamic>>.from(responses[5]);
        
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading Supabase data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sync with cloud: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Simple state refresh callback for child widgets
  void _refresh() => setState(() {});

  // --- NAVIGATION LOGIC ---
  List<Map<String, dynamic>> _getNavItems() {
    String role = widget.currentUser['role'];
    bool canManage = widget.currentUser['can_manage_products'] == true; // Double check boolean parse
    
    List<Map<String, dynamic>> items = [
      {'id': 'home', 'icon': Icons.home, 'label': 'Home'},
      {'id': 'production', 'icon': Icons.inventory, 'label': 'Prod & Delivery'},
    ];

    if (role == 'FH' || role == 'Owner') {
      items.add({'id': 'preorder', 'icon': Icons.shopping_cart, 'label': 'Pre-Orders'});
      items.add({'id': 'eod', 'icon': Icons.attach_money, 'label': 'Shift Reconcile'});
    }

    if (role != 'Owner') {
      items.add({'id': 'expense', 'icon': Icons.receipt, 'label': 'Log Expense'});
    }

    if (canManage) {
      items.add({'id': 'catalog', 'icon': Icons.local_offer, 'label': 'Manage Catalog'});
    }

    if (role == 'Owner') {
      items.add({'id': 'expense_book', 'icon': Icons.account_balance_wallet, 'label': 'Expense Book'});
      items.add({'id': 'ledger', 'icon': Icons.book, 'label': 'Verified Ledger'});
      items.add({'id': 'staff', 'icon': Icons.people, 'label': 'Staff Manager'});
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _getNavItems();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.storefront, color: Colors.indigo),
            const SizedBox(width: 8),
            const Text('BakeryOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.currentUser['name']} (${widget.currentUser['role']})',
                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Switch User',
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleSelectionScreen())),
            )
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.indigo),
                SizedBox(height: 16),
                Text('Syncing with Supabase...', style: TextStyle(color: Colors.grey))
              ],
            ),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar Navigation
              Container(
                width: 250,
                color: Colors.white,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: navItems.map((item) {
                    bool isSelected = _activeTab == item['id'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        selected: isSelected,
                        selectedTileColor: Colors.indigo.shade50,
                        leading: Icon(item['icon'], color: isSelected ? Colors.indigo : Colors.grey.shade600),
                        title: Text(item['label'], style: TextStyle(
                          color: isSelected ? Colors.indigo : Colors.grey.shade800,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                        )),
                        onTap: () => setState(() => _activeTab = item['id']),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              // Main Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: _buildActiveTabContent(),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 'home': 
        return HomeTab(currentUser: widget.currentUser, appData: _appData, onStateChanged: _refresh);
      case 'production': 
        return ProductionDeliveryTab(currentUser: widget.currentUser, appData: _appData, onStateChanged: _refresh);
      case 'preorder': 
        return PreOrderTab(currentUser: widget.currentUser, appData: _appData, onStateChanged: _refresh);
      case 'eod': 
        return EodTab(appData: _appData, onStateChanged: _refresh, onTabChanged: (tab) => setState(() => _activeTab = tab));
      case 'expense': 
        return ExpenseTab(currentUser: widget.currentUser, appData: _appData, onStateChanged: _refresh);
      case 'expense_book': 
        return ExpenseLedgerTab(appData: _appData);
      case 'ledger': 
        return VerifiedLedgerTab(appData: _appData);
      case 'catalog': 
        return CatalogTab(appData: _appData, onStateChanged: _refresh);
      case 'staff': 
        return StaffManagerTab(appData: _appData, onStateChanged: _refresh);
      default: 
        return const Center(child: Text('Work in progress'));
    }
  }

  @override
  void dispose() {
    _showcaseChannel?.unsubscribe();
    _ordersChannel?.unsubscribe();
    _expensesChannel?.unsubscribe();
    super.dispose();
  }
}