import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/app/app.dart';

void main() {
  testWidgets('SpendWise app boots without errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SpendWiseApp()));

    // Initial pump to mount the widget tree
    await tester.pump();
    expect(find.byType(SpendWiseApp), findsOneWidget);
  });
}
