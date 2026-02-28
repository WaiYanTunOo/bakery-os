part of 'supabase_service.dart';

class ValidationError implements Exception {
  final String message;
  ValidationError(this.message);
  @override
  String toString() => 'ValidationError: $message';
}

class InputValidator {
  static const allowedOnlineOrderStatuses = {'pending', 'verified', 'in_progress', 'ready'};
  static const Map<String, Set<String>> _onlineOrderTransitions = {
    'pending': {'pending', 'verified'},
    'verified': {'verified', 'in_progress'},
    'in_progress': {'in_progress', 'ready'},
    'ready': {'ready'},
  };
  static const double maxEodAmount = 999999.99;
  static const double minEodAmount = 0.0;
  static const int maxNoteLength = 500;
  static const int maxShiftLength = 20;
  static const int maxNameLength = 100;
  static const int maxIdLength = 50;
  static const int maxUserNameLength = 100;
  static const int maxDeliveredQty = 1000;
  static const int minDeliveredQty = 0;
  static const int maxCustomerLength = 120;
  static const int maxOrderItems = 100;

  static void validateEodReport({required String shift, required double grossSales, required double promptpay, required double card, required double expectedCash, required double actualCash, required double discrepancy, required String note}) {
    if (shift.trim().isEmpty) throw ValidationError('Shift cannot be empty');
    if (shift.length > maxShiftLength) throw ValidationError('Shift exceeds max length of $maxShiftLength');
    _validateAmounts({'Gross Sales': grossSales, 'PromptPay': promptpay, 'Card': card, 'Expected Cash': expectedCash, 'Actual Cash': actualCash, 'Discrepancy': discrepancy});
    if (note.trim().length > maxNoteLength) {
      throw ValidationError('Note exceeds max length of $maxNoteLength (current: ${note.trim().length})');
    }
  }

  static void validateShowcaseRequest({required String id, required String name, required String requestedBy, int? deliveredQty}) {
    if (id.trim().isEmpty) throw ValidationError('Request ID cannot be empty');
    if (id.length > maxIdLength) throw ValidationError('Request ID exceeds max length of $maxIdLength');
    if (name.trim().isEmpty) throw ValidationError('Item name cannot be empty');
    if (name.length > maxNameLength) throw ValidationError('Item name exceeds max length of $maxNameLength (current: ${name.length})');
    if (requestedBy.trim().isEmpty) throw ValidationError('Requested by user cannot be empty');
    if (requestedBy.length > maxUserNameLength) throw ValidationError('User name exceeds max length of $maxUserNameLength');
    if (deliveredQty != null && (deliveredQty < minDeliveredQty || deliveredQty > maxDeliveredQty)) {
      throw ValidationError('Delivered quantity must be between $minDeliveredQty and $maxDeliveredQty');
    }
  }

  static void validateOnlineOrder({required String id, required String customer, required List<Map<String, dynamic>> items, required double total, required String status, required String loggedBy}) {
    if (id.trim().isEmpty || id.length > maxIdLength) throw ValidationError('Order ID is invalid');
    if (customer.trim().isEmpty || customer.trim().length > maxCustomerLength) throw ValidationError('Customer name is invalid');
    if (loggedBy.trim().isEmpty || loggedBy.trim().length > maxUserNameLength) throw ValidationError('Logged by user is invalid');
    if (items.isEmpty || items.length > maxOrderItems) throw ValidationError('Order items are invalid');
    if (total < 0 || total > maxEodAmount) throw ValidationError('Order total is invalid');
    if (!allowedOnlineOrderStatuses.contains(status)) throw ValidationError('Order status is invalid');
  }

  static void validateOnlineOrderStatusTransition({
    required String fromStatus,
    required String toStatus,
  }) {
    if (!allowedOnlineOrderStatuses.contains(fromStatus)) {
      throw ValidationError('Current order status is invalid');
    }
    if (!allowedOnlineOrderStatuses.contains(toStatus)) {
      throw ValidationError('Order status is invalid');
    }
    final allowedTargets = _onlineOrderTransitions[fromStatus] ?? const <String>{};
    if (!allowedTargets.contains(toStatus)) {
      throw ValidationError('Invalid status transition: $fromStatus -> $toStatus');
    }
  }

  static void _validateAmounts(Map<String, double> amounts) {
    for (final entry in amounts.entries) {
      final value = entry.value;
      if (value < minEodAmount || value > maxEodAmount) {
        throw ValidationError('${entry.key} must be between $minEodAmount and $maxEodAmount (got $value)');
      }
    }
  }
}