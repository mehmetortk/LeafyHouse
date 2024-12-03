// test/presentation/views/auth/login_view_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:leafy_house/presentation/views/auth/login_view.dart';

void main() {
  testWidgets('LoginView has email and password fields', (WidgetTester tester) async {
    // Build the LoginView widget
    await tester.pumpWidget(MaterialApp(home: LoginView()));

    // Verify email TextField exists
    expect(find.byType(TextField), findsNWidgets(2));

    // Verify "Giriş Yap" button exists
    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}
