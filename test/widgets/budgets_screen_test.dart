import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/features/budgets/presentation/budgets_screen.dart';

void main() {
  testWidgets('BudgetsScreen renders title and add button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: BudgetsScreen())),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Budgets'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
