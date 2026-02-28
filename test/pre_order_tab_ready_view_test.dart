import 'package:bakery_os/data/app_data.dart';
import 'package:bakery_os/screens/tabs/pre_order_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Pre-order tab shows ready orders with full product names', (
    WidgetTester tester,
  ) async {
    final appData = AppData();
    appData.onlineOrders = [
      {
        'id': 'ORD-9001',
        'customer': 'Ready Customer',
        'items': [
          {
            'name': 'Very Long Product Name For Display Verification',
            'qty': 1,
            'price': 200,
            'deliveryDate': '2099-01-01',
          },
          {
            'name': 'Another Long Product Name For Ready List',
            'qty': 2,
            'price': 100,
            'deliveryDate': '2099-01-01',
          },
        ],
        'total': 400,
        'status': 'ready',
        'logged_by': 'FH-1',
      },
      {
        'id': 'ORD-9002',
        'customer': 'Not Ready Customer',
        'items': [
          {
            'name': 'Hidden Item',
            'qty': 1,
            'price': 20,
            'deliveryDate': '2099-01-01',
          },
        ],
        'total': 20,
        'status': 'verified',
        'logged_by': 'FH-1',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: PreOrderTab(
                currentUser: const {'name': 'Khun Jane', 'role': 'FH'},
                appData: appData,
                onStateChanged: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ready Pre-Orders (FH View)'), findsOneWidget);
    expect(find.textContaining('Ready Customer • ORD-9001'), findsOneWidget);
    expect(
      find.textContaining('Very Long Product Name For Display Verification'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Another Long Product Name For Ready List'),
      findsOneWidget,
    );
    expect(find.textContaining('Not Ready Customer • ORD-9002'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
