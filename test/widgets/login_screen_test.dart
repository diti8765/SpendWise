import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/security/secure_session_store.dart';
import 'package:spendwise/features/auth/presentation/login_screen.dart';

import '../helpers/fake_repositories.dart';

void main() {
  testWidgets('LoginScreen renders fields and sign in button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureSessionStoreProvider.overrideWithValue(
            FakeSecureSessionStore(),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    // Initial pump and settle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('SpendWise'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Customer ID / Username'), findsOneWidget);
    expect(find.text('PIN'), findsOneWidget);
  });
}
