// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:bakery_os/screens/login_screen.dart';

void main() {
  testWidgets('Login screen loads and shows secure title', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen(onSignedIn: () {})));

    expect(find.text('BakeryOS Secure Login'), findsOneWidget);
    expect(find.text('Sign in securely'), findsOneWidget);
  });
}
