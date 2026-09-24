import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/features/merchants/presentation/merchants_screen.dart';

void main() {
  testWidgets('MerchantsScreen renders title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: MerchantsScreen())),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Merchants'), findsOneWidget);
  });
}
