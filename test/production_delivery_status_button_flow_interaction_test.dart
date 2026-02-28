import 'package:bakery_os/data/app_data.dart';
import 'package:bakery_os/screens/tabs/production_delivery_tab.dart';
import 'package:bakery_os/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('UI button flow verified -> in_progress -> ready with mocked updates', (tester) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appData = AppData();
    final today = AppDateUtils.todayStr();
    appData.onlineOrders = [
      {
        'id': 'ORD-UI-FLOW',
        'customer': 'Interaction Customer',
        'items': [
          {'name': 'Sourdough', 'qty': 1, 'price': 120, 'deliveryDate': today},
        ],
        'total': 120,
        'status': 'verified',
        'logged_by': 'FH-1',
      },
    ];

    final calls = <String>[];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ProductionDeliveryTab(
          currentUser: {'role': 'BH', 'name': 'BH Tester'},
          appData: appData,
          onStateChanged: () {},
          onUpdateOrderStatus: (id, status) async {
            calls.add('$id:$status');
            return true;
          },
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Start Prep'), findsOneWidget);
    expect(find.text('Mark Ready'), findsNothing);

    await tester.tap(find.text('Start Prep'));
    await tester.pumpAndSettle();

    expect(calls, equals(['ORD-UI-FLOW:in_progress']));
    expect(appData.onlineOrders.first['status'], 'in_progress');
    expect(find.text('Start Prep'), findsNothing);
    expect(find.text('Mark Ready'), findsOneWidget);

    await tester.tap(find.text('Mark Ready'));
    await tester.pumpAndSettle();

    expect(calls, equals(['ORD-UI-FLOW:in_progress', 'ORD-UI-FLOW:ready']));
    expect(appData.onlineOrders.first['status'], 'ready');
    expect(find.text('Start Prep'), findsNothing);
    expect(find.text('Mark Ready'), findsNothing);
  });
}
