import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/features/transactions/data/aggregator.dart';
import 'package:spendwise/features/transactions/domain/transaction.dart';

void main() {
  group('Aggregator (pure Dart)', () {
    const aggregator = Aggregator();

    const catFood = Category(
      id: 'food',
      name: 'Food',
      icon: 'restaurant',
      color: '#FF7043',
    );
    const catShopping = Category(
      id: 'shopping',
      name: 'Shopping',
      icon: 'bag',
      color: '#42A5F5',
    );

    final transactions = [
      Transaction(
        id: 't1',
        merchantRaw: 'SWIGGY*1',
        merchantName: 'Swiggy',
        category: catFood,
        amountPaise: 45000, // ₹450
        at: DateTime.utc(2026, 9, 5, 12),
        mode: 'UPI',
      ),
      Transaction(
        id: 't2',
        merchantRaw: 'SWIGGY*2',
        merchantName: 'Swiggy',
        category: catFood,
        amountPaise: 35000, // ₹350
        at: DateTime.utc(2026, 9, 10, 19),
        mode: 'UPI',
      ),
      Transaction(
        id: 't3',
        merchantRaw: 'AMAZON*1',
        merchantName: 'Amazon',
        category: catShopping,
        amountPaise: 120000, // ₹1,200
        at: DateTime.utc(2026, 9, 15, 14),
        mode: 'Card',
      ),
    ];

    test('computes month summary totals accurately to the paise', () {
      final summary = aggregator.computeSummary(
        month: '2026-09',
        transactions: transactions,
      );

      expect(summary.month, '2026-09');
      expect(summary.totalPaise, 200000); // 45000 + 35000 + 120000
      expect(summary.byCategory['food'], 80000);
      expect(summary.byCategory['shopping'], 120000);
      expect(summary.byDay.length, 30); // September has 30 days
      expect(summary.byDay[4], 45000); // Day 5 is index 4
      expect(summary.byDay[9], 35000); // Day 10 is index 9
      expect(summary.byDay[14], 120000); // Day 15 is index 14
    });

    test('computes empty summary when no transactions exist', () {
      final summary = aggregator.computeSummary(
        month: '2026-09',
        transactions: [],
      );

      expect(summary.totalPaise, 0);
      expect(summary.byCategory, isEmpty);
      expect(summary.byDay.length, 30);
      expect(summary.byDay.every((d) => d == 0), isTrue);
    });

    test('computes merchant insights sorted by total descending', () {
      final insights = aggregator.computeMerchantInsights(transactions);

      expect(insights.length, 2); // Swiggy and Amazon
      // Amazon spent ₹1,200, Swiggy spent ₹800 → Amazon first
      expect(insights[0].merchantName, 'Amazon');
      expect(insights[0].totalPaise, 120000);
      expect(insights[0].transactionCount, 1);
      expect(insights[0].averagePaise, 120000);

      expect(insights[1].merchantName, 'Swiggy');
      expect(insights[1].totalPaise, 80000);
      expect(insights[1].transactionCount, 2);
      expect(insights[1].averagePaise, 40000); // 80000 / 2
    });

    test('computes month-over-month change', () {
      final change = aggregator.computeMonthOverMonthChange(
        currentTotalPaise: 150000,
        previousTotalPaise: 100000,
      );
      expect(change, closeTo(50.0, 0.01));

      final decrease = aggregator.computeMonthOverMonthChange(
        currentTotalPaise: 80000,
        previousTotalPaise: 100000,
      );
      expect(decrease, closeTo(-20.0, 0.01));

      final zeroPrev = aggregator.computeMonthOverMonthChange(
        currentTotalPaise: 100000,
        previousTotalPaise: 0,
      );
      expect(zeroPrev, isNull);
    });
  });
}
