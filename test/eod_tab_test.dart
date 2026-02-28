import 'package:bakery_os/data/app_data.dart';
import 'package:bakery_os/screens/tabs/eod_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EOD tab renders without crashing',
      (WidgetTester tester) async {
    final appData = AppData();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EodTab(
              appData: appData,
              onStateChanged: () {},
              onTabChanged: (t) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(EodTab), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('EOD tab has submit button with key',
      (WidgetTester tester) async {
    final appData = AppData();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EodTab(
              appData: appData,
              onStateChanged: () {},
              onTabChanged: (t) {},
            ),
          ),
        ),
      ),
    );

    var submitButton = find.byKey(const Key('eod_submit'));
    expect(submitButton, findsOneWidget);
  });
}
