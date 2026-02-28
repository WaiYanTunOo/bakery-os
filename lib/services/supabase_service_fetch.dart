part of 'supabase_service.dart';

extension SupabaseServiceFetch on SupabaseService {
  Future<List<Map<String, dynamic>>> fetchTable(String table, {String? orderBy, bool ascending = true}) async {
    try {
      dynamic query = client.from(table).select();
      if (orderBy != null) query = query.order(orderBy, ascending: ascending);
      final res = await query;
      if (res is! List) return [];
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      developer.log('SupabaseService.fetchTable($table) error: $e', name: 'SupabaseService');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    final res = await client.from('menu_items').select('id, name, price');
    return List<Map<String, dynamic>>.from(res as List<dynamic>);
  }

  Future<List<Map<String, dynamic>>> fetchStaffDirectory() async {
    final res = await client.from('staff_directory').select('id, name, role, can_manage_products');
    return List<Map<String, dynamic>>.from(res as List<dynamic>);
  }

  Future<List<Map<String, dynamic>>> fetchEodReports() async => fetchTable('eod_reports', orderBy: 'created_at', ascending: false);
  Future<List<Map<String, dynamic>>> fetchOnlineOrders() async => fetchTable('online_orders', orderBy: 'created_at', ascending: false);
  Future<List<Map<String, dynamic>>> fetchExpenses() async => fetchTable('expenses', orderBy: 'created_at', ascending: false);
  Future<List<Map<String, dynamic>>> fetchShowcaseRequests() async => fetchTable('showcase_requests', orderBy: 'created_at', ascending: false);
}