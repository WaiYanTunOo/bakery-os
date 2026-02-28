part of 'supabase_service.dart';

extension SupabaseServiceOrders on SupabaseService {
  Future<Map<String, dynamic>?> insertOnlineOrder(Map<String, dynamic> order) async {
    try {
      final normalizedItems = List<Map<String, dynamic>>.from(order['items'] as List<dynamic>);
      InputValidator.validateOnlineOrder(
        id: (order['id'] ?? '').toString(),
        customer: (order['customer'] ?? '').toString(),
        items: normalizedItems,
        total: (order['total'] as num?)?.toDouble() ?? -1,
        status: (order['status'] ?? '').toString(),
        loggedBy: (order['logged_by'] ?? order['loggedBy'] ?? '').toString(),
      );
      final payload = {
        'id': (order['id'] ?? '').toString().trim(),
        'customer': (order['customer'] ?? '').toString().trim(),
        'items': normalizedItems,
        'total': (order['total'] as num).toDouble(),
        'status': (order['status'] ?? 'pending').toString(),
        'date': (order['date'] ?? '').toString(),
        'logged_by': (order['logged_by'] ?? order['loggedBy'] ?? '').toString().trim(),
      };
      final resp = await client.from('online_orders').insert(payload).select() as List<dynamic>?;
      if (resp != null && resp.isNotEmpty) return Map<String, dynamic>.from(resp.first);
      return null;
    } on ValidationError {
      rethrow;
    } catch (e) {
      developer.log('SupabaseService.insertOnlineOrder error: $e', name: 'SupabaseService');
      return null;
    }
  }

  Future<bool> updateOnlineOrderStatus(String id, String status) async {
    try {
      if (id.trim().isEmpty) throw ValidationError('Order ID cannot be empty');
      if (!InputValidator.allowedOnlineOrderStatuses.contains(status)) throw ValidationError('Order status is invalid');
      final currentRows = await client.from('online_orders').select('status').eq('id', id).limit(1) as List<dynamic>;
      if (currentRows.isEmpty) return false;
      final currentStatus = (currentRows.first['status'] ?? '').toString();
      InputValidator.validateOnlineOrderStatusTransition(fromStatus: currentStatus, toStatus: status);
      if (currentStatus == status) return true;
      await client.from('online_orders').update({'status': status}).eq('id', id);
      return true;
    } on ValidationError {
      rethrow;
    } catch (e) {
      developer.log('SupabaseService.updateOnlineOrderStatus error: $e', name: 'SupabaseService');
      return false;
    }
  }
}