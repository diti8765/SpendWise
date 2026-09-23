import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/features/transactions/data/transaction_repository.dart';
import 'package:spendwise/features/transactions/presentation/feed_screen.dart';

import '../helpers/fake_repositories.dart';

void main() {
  testWidgets('FeedScreen renders search and title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(
            FakeTransactionRepository(),
          ),
        ],
        child: const MaterialApp(home: FeedScreen()),
      ),
    );

    // Let the Future resolve immediately with no timers
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Transactions'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
