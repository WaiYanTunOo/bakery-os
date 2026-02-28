part of 'dashboard_screen.dart';

extension _DashboardScreenData on _DashboardScreenState {
  Future<void> _loadDataFromSupabase() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        SupabaseService.instance.fetchMenuItems(),
        SupabaseService.instance.fetchStaffDirectory(),
        SupabaseService.instance.fetchEodReports(),
        SupabaseService.instance.fetchOnlineOrders(),
        SupabaseService.instance.fetchExpenses(),
        SupabaseService.instance.fetchShowcaseRequests(),
      ]);
      _setDashboardState(() {
        _appData.menuItems = results[0];
        _appData.staffDirectory = results[1];
        _appData.eodReports = results[2];
        _appData.onlineOrders = results[3];
        _appData.expenses = results[4];
        _appData.showcaseRequests = results[5];
      });
      _setLoading(false);
    } catch (e) {
      debugPrint('Error loading Supabase data: $e');
      if (!mounted) return;
      _setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to sync with cloud: $e'), backgroundColor: Colors.red));
    }
  }

  void _refresh() => _setDashboardState(() {});

  List<Map<String, dynamic>> _getNavItems() {
    final role = widget.currentUser['role'];
    final canManage = widget.currentUser['can_manage_products'] == true;
    final items = <Map<String, dynamic>>[
      {'id': 'home', 'icon': Icons.home, 'label': 'Home'},
      {'id': 'production', 'icon': Icons.inventory, 'label': 'Prod & Delivery'},
    ];
    if (role == 'FH' || role == 'Owner') {
      items.add({'id': 'preorder', 'icon': Icons.shopping_cart, 'label': 'Pre-Orders'});
      items.add({'id': 'eod', 'icon': Icons.attach_money, 'label': 'Shift Reconcile'});
    }
    if (role != 'Owner') items.add({'id': 'expense', 'icon': Icons.receipt, 'label': 'Log Expense'});
    if (canManage) items.add({'id': 'catalog', 'icon': Icons.local_offer, 'label': 'Manage Catalog'});
    if (role == 'Owner') {
      items.add({'id': 'expense_book', 'icon': Icons.account_balance_wallet, 'label': 'Expense Book'});
      items.add({'id': 'ledger', 'icon': Icons.book, 'label': 'Verified Ledger'});
      items.add({'id': 'staff', 'icon': Icons.people, 'label': 'Staff Manager'});
    }
    return items;
  }
}