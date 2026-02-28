import 'package:bakery_os/data/app_data.dart';
import 'package:bakery_os/screens/tabs/production_delivery_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Production delivery tab shows empty readiness state', (
    WidgetTester tester,
  ) async {
    final appData = AppData();
    appData.onlineOrders = [
      {
        'id': 'ORD-005',
        'customer': 'Thin',
        'items': [
          {'name': 'Muffin', 'qty': 2, 'price': 60, 'deliveryDate': '2099-01-01'},
        ],
        'total': 120,
        'status': 'verified',
        'logged_by': 'FH-1',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductionDeliveryTab(
              currentUser: {'role': 'BH', 'name': 'Test BH'},
              appData: appData,
              onStateChanged: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ProductionDeliveryTab), findsOneWidget);
    expect(find.text('No active pre-orders for this date.'), findsOneWidget);
    expect(find.text('No orders for this date.'), findsOneWidget);
    expect(find.text('Pending pre-order units for this date: 0'), findsOneWidget);
    expect(find.text('In progress: 0 | Ready: 0'), findsOneWidget);
  });
}
