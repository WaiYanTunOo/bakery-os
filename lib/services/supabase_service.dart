import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

/// Validation rules and error handling for input data.
class ValidationError implements Exception {
  final String message;
  ValidationError(this.message);

  @override
  String toString() => 'ValidationError: $message';
}

/// Input validation utility for Supabase operations.
class InputValidator {
  // EOD Report field limits
  static const double maxEodAmount = 999999.99;
  static const double minEodAmount = 0.0;
  static const int maxNoteLength = 500;
  static const int maxShiftLength = 20;

  // Showcase Request field limits
  static const int maxNameLength = 100;
  static const int maxIdLength = 50;
  static const int maxUserNameLength = 100;
  static const int maxDeliveredQty = 1000;
  static const int minDeliveredQty = 0;

  /// Validates EOD report data. Throws ValidationError if invalid.
  static void validateEodReport({
    required String shift,
    required double grossSales,
    required double promptpay,
    required double card,
    required double expectedCash,
    required double actualCash,
    required double discrepancy,
    required String note,
  }) {
    // Validate shift
    if (shift.trim().isEmpty) {
      throw ValidationError('Shift cannot be empty');
    }
    if (shift.length > maxShiftLength) {
      throw ValidationError('Shift exceeds max length of $maxShiftLength');
    }

    // Validate numeric fields
    _validateAmounts({
      'Gross Sales': grossSales,
      'PromptPay': promptpay,
      'Card': card,
      'Expected Cash': expectedCash,
      'Actual Cash': actualCash,
      'Discrepancy': discrepancy,
    });

    // Validate note
    if (note.trim().length > maxNoteLength) {
      throw ValidationError(
        'Note exceeds max length of $maxNoteLength (current: ${note.trim().length})',
      );
    }
  }

  /// Validates showcase request data. Throws ValidationError if invalid.
  static void validateShowcaseRequest({
    required String id,
    required String name,
    required String requestedBy,
    int? deliveredQty,
  }) {
    // Validate ID
    if (id.trim().isEmpty) {
      throw ValidationError('Request ID cannot be empty');
    }
    if (id.length > maxIdLength) {
      throw ValidationError('Request ID exceeds max length of $maxIdLength');
    }

    // Validate name
    if (name.trim().isEmpty) {
      throw ValidationError('Item name cannot be empty');
    }
    if (name.length > maxNameLength) {
      throw ValidationError(
        'Item name exceeds max length of $maxNameLength (current: ${name.length})',
      );
    }

    // Validate requested_by
    if (requestedBy.trim().isEmpty) {
      throw ValidationError('Requested by user cannot be empty');
    }
    if (requestedBy.length > maxUserNameLength) {
      throw ValidationError(
        'User name exceeds max length of $maxUserNameLength',
      );
    }

    // Validate delivered_qty if provided
    if (deliveredQty != null) {
      if (deliveredQty < minDeliveredQty || deliveredQty > maxDeliveredQty) {
        throw ValidationError(
          'Delivered quantity must be between $minDeliveredQty and $maxDeliveredQty',
        );
      }
    }
  }

  /// Helper to validate all amount fields are within acceptable range.
  static void _validateAmounts(Map<String, double> amounts) {
    for (final entry in amounts.entries) {
      final value = entry.value;
      if (value < minEodAmount || value > maxEodAmount) {
        throw ValidationError(
          '${entry.key} must be between $minEodAmount and $maxEodAmount (got $value)',
        );
      }
    }
  }
}

class SupabaseService {
  SupabaseService._privateConstructor();
  static final SupabaseService instance = SupabaseService._privateConstructor();

  /// Underlying Supabase client; can be replaced in tests.
  SupabaseClient client = Supabase.instance.client;

  /// Replace the client (for testing or custom configuration).
  void overrideClient(SupabaseClient newClient) => client = newClient;

  /// Insert an EOD report. Returns true on success.
  /// Generic fetcher for a table. Throws on error, returns empty list on failure.
  ///
  /// `orderBy` and `ascending` allow simple sorting. Use more specific
  /// query methods if you need filters/pagination.
  Future<List<Map<String, dynamic>>> fetchTable(
    String table, {
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      final supabase = client;
      dynamic query = supabase.from(table).select();
      if (orderBy != null) {
        // order() may return a different builder type so use dynamic
        query = query.order(orderBy, ascending: ascending);
      }
      final res = await query;
      if (res is! List) return [];
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      developer.log('SupabaseService.fetchTable($table) error: $e', name: 'SupabaseService');
      return [];
    }
  }

  // typed convenience wrappers using only needed columns
  Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    // Only select relevant columns to avoid exposing any extras.
    final supabase = client;
    final res = await supabase.from('menu_items').select('id, name, price');
    return List<Map<String, dynamic>>.from(res as List<dynamic>);
  }

  Future<List<Map<String, dynamic>>> fetchStaffDirectory() async {
    final supabase = client;
    final res = await supabase.from('staff_directory').select('id, name, role, can_manage_products');
    return List<Map<String, dynamic>>.from(res as List<dynamic>);
  }

  Future<List<Map<String, dynamic>>> fetchEodReports() async =>
      fetchTable('eod_reports', orderBy: 'created_at', ascending: false);
  Future<List<Map<String, dynamic>>> fetchOnlineOrders() async =>
      fetchTable('online_orders', orderBy: 'created_at', ascending: false);
  Future<List<Map<String, dynamic>>> fetchExpenses() async =>
      fetchTable('expenses', orderBy: 'created_at', ascending: false);
  Future<List<Map<String, dynamic>>> fetchShowcaseRequests() async =>
      fetchTable('showcase_requests', orderBy: 'created_at', ascending: false);

  /// Insert an EOD report. Validates input before insertion.
  /// Throws [ValidationError] if input is invalid.
  /// Returns true on success, false if database operation fails.
  Future<bool> insertEodReport({
    required String shift,
    required double grossSales,
    required double promptpay,
    required double card,
    required double expectedCash,
    required double actualCash,
    required double discrepancy,
    required String note,
  }) async {
    try {
      // Validate input before insertion
      InputValidator.validateEodReport(
        shift: shift,
        grossSales: grossSales,
        promptpay: promptpay,
        card: card,
        expectedCash: expectedCash,
        actualCash: actualCash,
        discrepancy: discrepancy,
        note: note,
      );

      final supabase = client;

      final record = {
        'shift': shift.trim(),
        'gross_sales': grossSales,
        'promptpay': promptpay,
        'card': card,
        'expected_cash': expectedCash,
        'actual_cash': actualCash,
        'discrepancy': discrepancy,
        'note': note.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final res = await supabase.from('eod_reports').insert(record);
      return res != null;
    } on ValidationError {
      rethrow; // Re-throw validation errors for UI to handle
    } catch (e) {
      developer.log('SupabaseService.insertEodReport error: $e', name: 'SupabaseService');
      return false;
    }
  }

  /// Subscribe to postgres changes for [table]. Returns the created channel so
  /// caller can unsubscribe when appropriate.  Only the "public" schema is
  /// supported currently.
  RealtimeChannel subscribeToTable(
      String table, Function(PostgresChangePayload) callback) {
    final supabase = client;
    return supabase
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: callback,
        )
        .subscribe();
  }

  /// Insert a showcase request with validation.
  /// Throws [ValidationError] if input is invalid.
  Future<Map<String, dynamic>?> insertShowcaseRequest(
    Map<String, dynamic> newReq,
  ) async {
    try {
      // Validate input before insertion
      InputValidator.validateShowcaseRequest(
        id: newReq['id'] ?? '',
        name: newReq['name'] ?? '',
        requestedBy: newReq['requested_by'] ?? '',
        deliveredQty: newReq['delivered_qty'],
      );

      final supabase = client;
      final resp = await supabase.from('showcase_requests').insert(newReq).select() as List<dynamic>?;
      if (resp != null && resp.isNotEmpty) return Map<String, dynamic>.from(resp.first);
      return null;
    } on ValidationError {
      rethrow; // Re-throw validation errors for UI to handle
    } catch (e) {
      developer.log('SupabaseService.insertShowcaseRequest error: $e', name: 'SupabaseService');
      return null;
    }
  }

  /// Update a showcase request with validation.
  /// Throws [ValidationError] if input is invalid.
  Future<bool> updateShowcaseRequest(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Validate deliveredQty if being updated
      if (updates.containsKey('delivered_qty')) {
        final qty = updates['delivered_qty'];
        if (qty != null) {
          if (qty < InputValidator.minDeliveredQty ||
              qty > InputValidator.maxDeliveredQty) {
            throw ValidationError(
              'Delivered quantity must be between '
              '${InputValidator.minDeliveredQty} and ${InputValidator.maxDeliveredQty}',
            );
          }
        }
      }

      final supabase = client;
      await supabase.from('showcase_requests').update(updates).eq('id', id);
      return true;
    } on ValidationError {
      rethrow; // Re-throw validation errors for UI to handle
    } catch (e) {
      developer.log('SupabaseService.updateShowcaseRequest error: $e', name: 'SupabaseService');
      return false;
    }
  }
}

