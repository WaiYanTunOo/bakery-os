part of 'supabase_service.dart';

extension SupabaseServiceShowcase on SupabaseService {
  Future<Map<String, dynamic>?> insertShowcaseRequest(Map<String, dynamic> newReq) async {
    try {
      InputValidator.validateShowcaseRequest(
        id: newReq['id'] ?? '',
        name: newReq['name'] ?? '',
        requestedBy: newReq['requested_by'] ?? '',
        deliveredQty: newReq['delivered_qty'],
      );
      final resp = await client.from('showcase_requests').insert(newReq).select() as List<dynamic>?;
      if (resp != null && resp.isNotEmpty) return Map<String, dynamic>.from(resp.first);
      return null;
    } on ValidationError {
      rethrow;
    } catch (e) {
      developer.log('SupabaseService.insertShowcaseRequest error: $e', name: 'SupabaseService');
      return null;
    }
  }

  Future<bool> updateShowcaseRequest(String id, Map<String, dynamic> updates) async {
    try {
      if (updates.containsKey('delivered_qty')) {
        final qty = updates['delivered_qty'];
        if (qty != null && (qty < InputValidator.minDeliveredQty || qty > InputValidator.maxDeliveredQty)) {
          throw ValidationError('Delivered quantity must be between ${InputValidator.minDeliveredQty} and ${InputValidator.maxDeliveredQty}');
        }
      }
      await client.from('showcase_requests').update(updates).eq('id', id);
      return true;
    } on ValidationError {
      rethrow;
    } catch (e) {
      developer.log('SupabaseService.updateShowcaseRequest error: $e', name: 'SupabaseService');
      return false;
    }
  }
}