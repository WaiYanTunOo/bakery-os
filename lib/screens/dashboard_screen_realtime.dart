part of 'dashboard_screen.dart';

extension _DashboardScreenRealtime on _DashboardScreenState {
  void _setupRealtimeListeners() {
    _showcaseChannel = SupabaseService.instance.subscribeToTable('showcase_requests', _handleShowcaseChange);
    _ordersChannel = SupabaseService.instance.subscribeToTable('online_orders', _handleOrderChange);
    _expensesChannel = SupabaseService.instance.subscribeToTable('expenses', _handleExpenseChange);
  }

  void _handleShowcaseChange(PostgresChangePayload payload) {
    if (!mounted) return;
    final newRecord = payload.newRecord;
    final oldRecord = payload.oldRecord;
    _setDashboardState(() {
      if (payload.eventType == PostgresChangeEvent.insert && newRecord.isNotEmpty) {
        _appData.showcaseRequests.insert(0, newRecord);
      } else if (payload.eventType == PostgresChangeEvent.update && newRecord.isNotEmpty) {
        final index = _appData.showcaseRequests.indexWhere((r) => r['id'] == newRecord['id']);
        if (index >= 0) _appData.showcaseRequests[index] = newRecord;
      } else if (payload.eventType == PostgresChangeEvent.delete && oldRecord.isNotEmpty) {
        _appData.showcaseRequests.removeWhere((r) => r['id'] == oldRecord['id']);
      }
    });
  }

  void _handleOrderChange(PostgresChangePayload payload) {
    if (!mounted) return;
    final newRecord = payload.newRecord;
    final oldRecord = payload.oldRecord;
    _setDashboardState(() {
      if (payload.eventType == PostgresChangeEvent.insert && newRecord.isNotEmpty) {
        _appData.onlineOrders.insert(0, newRecord);
      } else if (payload.eventType == PostgresChangeEvent.update && newRecord.isNotEmpty) {
        final index = _appData.onlineOrders.indexWhere((o) => o['id'] == newRecord['id']);
        if (index >= 0) _appData.onlineOrders[index] = newRecord;
      } else if (payload.eventType == PostgresChangeEvent.delete && oldRecord.isNotEmpty) {
        _appData.onlineOrders.removeWhere((o) => o['id'] == oldRecord['id']);
      }
    });
  }

  void _handleExpenseChange(PostgresChangePayload payload) {
    if (!mounted) return;
    final newRecord = payload.newRecord;
    final oldRecord = payload.oldRecord;
    _setDashboardState(() {
      if (payload.eventType == PostgresChangeEvent.insert && newRecord.isNotEmpty) {
        _appData.expenses.insert(0, newRecord);
      } else if (payload.eventType == PostgresChangeEvent.update && newRecord.isNotEmpty) {
        final index = _appData.expenses.indexWhere((e) => e['id'] == newRecord['id']);
        if (index >= 0) _appData.expenses[index] = newRecord;
      } else if (payload.eventType == PostgresChangeEvent.delete && oldRecord.isNotEmpty) {
        _appData.expenses.removeWhere((e) => e['id'] == oldRecord['id']);
      }
    });
  }
}