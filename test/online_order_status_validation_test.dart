import 'package:bakery_os/services/supabase_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Online order status validation', () {
    Map<String, dynamic> orderPayload(String status) {
      return {
        'id': 'ORD-100',
        'customer': 'Status Test Customer',
        'items': [
          {
            'name': 'Croissant',
            'qty': 1,
            'price': 90,
            'deliveryDate': '2099-01-01',
          },
        ],
        'total': 90.0,
        'status': status,
        'loggedBy': 'FH Tester',
      };
    }

    test('accepts in_progress status', () {
      final order = orderPayload('in_progress');
      expect(
        () => InputValidator.validateOnlineOrder(
          id: order['id'] as String,
          customer: order['customer'] as String,
          items: List<Map<String, dynamic>>.from(order['items'] as List),
          total: order['total'] as double,
          status: order['status'] as String,
          loggedBy: order['loggedBy'] as String,
        ),
        returnsNormally,
      );
    });

    test('accepts ready status', () {
      final order = orderPayload('ready');
      expect(
        () => InputValidator.validateOnlineOrder(
          id: order['id'] as String,
          customer: order['customer'] as String,
          items: List<Map<String, dynamic>>.from(order['items'] as List),
          total: order['total'] as double,
          status: order['status'] as String,
          loggedBy: order['loggedBy'] as String,
        ),
        returnsNormally,
      );
    });

    test('rejects unknown status', () {
      final order = orderPayload('unknown');
      expect(
        () => InputValidator.validateOnlineOrder(
          id: order['id'] as String,
          customer: order['customer'] as String,
          items: List<Map<String, dynamic>>.from(order['items'] as List),
          total: order['total'] as double,
          status: order['status'] as String,
          loggedBy: order['loggedBy'] as String,
        ),
        throwsA(isA<ValidationError>()),
      );
    });

    test('allows verified to in_progress transition', () {
      expect(
        () => InputValidator.validateOnlineOrderStatusTransition(
          fromStatus: 'verified',
          toStatus: 'in_progress',
        ),
        returnsNormally,
      );
    });

    test('rejects pending to ready transition', () {
      expect(
        () => InputValidator.validateOnlineOrderStatusTransition(
          fromStatus: 'pending',
          toStatus: 'ready',
        ),
        throwsA(isA<ValidationError>()),
      );
    });

    test('allows idempotent ready to ready transition', () {
      expect(
        () => InputValidator.validateOnlineOrderStatusTransition(
          fromStatus: 'ready',
          toStatus: 'ready',
        ),
        returnsNormally,
      );
    });
  });
}
