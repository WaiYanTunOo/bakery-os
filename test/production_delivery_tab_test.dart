import 'package:bakery_os/data/app_data.dart';
import 'package:bakery_os/screens/tabs/production_delivery_tab.dart';
import 'package:bakery_os/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Production delivery tab renders readiness counters and actions',
      (WidgetTester tester) async {
    final appData = AppData();
    final today = AppDateUtils.todayStr();
    appData.onlineOrders = [
      {
        'id': 'ORD-001',
        'customer': 'Aye',
        'items': [
          {'name': 'Croissant', 'qty': 1, 'price': 80, 'deliveryDate': today},
        ],
        'total': 80,
        'status': 'pending',
        'logged_by': 'FH-1',
      },
      {
        'id': 'ORD-002',
        'customer': 'Mya',
        'items': [
          {'name': 'Croissant', 'qty': 2, 'price': 80, 'deliveryDate': today},
        ],
        'total': 160,
        'status': 'verified',
        'logged_by': 'FH-1',
      },
      {
        'id': 'ORD-003',
        'customer': 'Nay',
        'items': [
          {'name': 'Baguette', 'qty': 3, 'price': 90, 'deliveryDate': today},
        ],
        'total': 270,
        'status': 'in_progress',
        'logged_by': 'FH-1',
      },
      {
        'id': 'ORD-004',
        'customer': 'Hla',
        'items': [
          {'name': 'Sourdough', 'qty': 4, 'price': 120, 'deliveryDate': today},
        ],
        'total': 480,
        'status': 'ready',
        'logged_by': 'FH-1',
      },
    ];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ProductionDeliveryTab(
            currentUser: {'role': 'BH', 'name': 'Test BH'},
            appData: appData,
            onStateChanged: () {},
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(ProductionDeliveryTab), findsOneWidget);
    expect(find.text('Pending pre-order units for this date: 1'), findsOneWidget);
    expect(find.text('In progress: 3 | Ready: 4'), findsOneWidget);
    expect(find.text('BH Readiness Actions'), findsOneWidget);
    expect(find.text('Start Prep'), findsOneWidget);
    expect(find.text('Mark Ready'), findsOneWidget);
  });
}
