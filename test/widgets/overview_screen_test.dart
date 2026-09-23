import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/features/overview/presentation/overview_screen.dart';

void main() {
  testWidgets('OverviewScreen renders title and header elements', (
    tester,
  ) async {
    // Set a large screen size so all widgets fit without scrolling.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OverviewScreen())),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('SpendWise'), findsOneWidget);
    expect(find.text('By Category'), findsOneWidget);
    expect(find.text('Daily Spending'), findsOneWidget);
  });
}
