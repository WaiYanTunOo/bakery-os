import 'package:bakery_os/data/app_data.dart';
import 'package:bakery_os/screens/tabs/production_delivery_tab.dart';
import 'package:bakery_os/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BH status flow verified -> in_progress -> ready', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appData = AppData();
    final today = AppDateUtils.todayStr();
    appData.onlineOrders = [
      {
        'id': 'ORD-FLOW',
        'customer': 'Flow Customer',
        'items': [
          {'name': 'Sourdough', 'qty': 2, 'price': 120, 'deliveryDate': today},
        ],
        'total': 240,
        'status': 'verified',
        'logged_by': 'FH-1',
      },
    ];

    final calls = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductionDeliveryTab(
              currentUser: {'role': 'BH', 'name': 'Mock BH'},
              appData: appData,
              onStateChanged: () {},
              onUpdateOrderStatus: (id, status) async {
                calls.add('$id:$status');
                return true;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Start Prep'), findsOneWidget);
    await tester.ensureVisible(find.text('Start Prep'));
    await tester.tap(find.text('Start Prep'));
    await tester.pumpAndSettle();

    expect(calls, contains('ORD-FLOW:in_progress'));
    expect(appData.onlineOrders.first['status'], 'in_progress');
    expect(find.text('Mark Ready'), findsOneWidget);

    await tester.ensureVisible(find.text('Mark Ready'));
    await tester.tap(find.text('Mark Ready'));
    await tester.pumpAndSettle();

    expect(calls, contains('ORD-FLOW:ready'));
    expect(appData.onlineOrders.first['status'], 'ready');
    expect(find.text('Mark Ready'), findsNothing);
    expect(find.text('Start Prep'), findsNothing);
    expect(find.text('ready'), findsWidgets);
  });
}
