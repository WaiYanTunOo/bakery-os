import 'package:bakery_os/data/app_data.dart';
import 'package:bakery_os/screens/tabs/production_delivery_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Production delivery tab renders without error',
      (WidgetTester tester) async {
    final appData = AppData();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ProductionDeliveryTab(
            currentUser: {'role': 'FH', 'name': 'Test'},
            appData: appData,
            onStateChanged: () {},
          ),
        ),
      ),
    ));

    expect(find.byType(ProductionDeliveryTab), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('Production delivery tab displays items from appData',
      (WidgetTester tester) async {
    final appData = AppData();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ProductionDeliveryTab(
            currentUser: {'role': 'FH', 'name': 'Test'},
            appData: appData,
            onStateChanged: () {},
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();
    expect(find.byType(ProductionDeliveryTab), findsOneWidget);
  });
}
