import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/features/budgets/domain/budget.dart';
import 'package:spendwise/core/notifications/budget_alert_service.dart';

void main() {
  group('Budget entity', () {
    test('calculates remaining paise correctly', () {
      const budget = Budget(
        category: 'food',
        month: '2026-09',
        limitPaise: 1000000, // ₹10,000
        spentPaise: 600000, // ₹6,000
      );
      expect(budget.remainingPaise, 400000);
      expect(budget.usageRatio, 0.6);
      expect(budget.isWarning, isFalse);
      expect(budget.isExceeded, isFalse);
    });

    test('detects warning state at 80%', () {
      const budget = Budget(
        category: 'food',
        month: '2026-09',
        limitPaise: 1000000,
        spentPaise: 800000, // Exactly 80%
      );
      expect(budget.isWarning, isTrue);
      expect(budget.isExceeded, isFalse);
    });

    test('detects warning state at 95%', () {
      const budget = Budget(
        category: 'food',
        month: '2026-09',
        limitPaise: 1000000,
        spentPaise: 950000,
      );
      expect(budget.isWarning, isTrue);
      expect(budget.isExceeded, isFalse);
    });

    test('detects exceeded state at 100%', () {
      const budget = Budget(
        category: 'food',
        month: '2026-09',
        limitPaise: 1000000,
        spentPaise: 1000000,
      );
      expect(budget.isWarning, isFalse);
      expect(budget.isExceeded, isTrue);
      expect(budget.remainingPaise, 0);
    });

    test('detects exceeded state over 100%', () {
      const budget = Budget(
        category: 'food',
        month: '2026-09',
        limitPaise: 1000000,
        spentPaise: 1200000,
      );
      expect(budget.isExceeded, isTrue);
      expect(budget.remainingPaise, -200000); // Negative remaining
    });
  });

  group('BudgetAlertService', () {
    test('sends alert once per threshold per month', () {
      final service = BudgetAlertService();

      const warningBudget = Budget(
        category: 'food',
        month: '2026-09',
        limitPaise: 1000000,
        spentPaise: 850000,
      );

      // First check at 85% → should alert
      final alert1 = service.checkBudgetAlert(warningBudget);
      expect(alert1, isNotNull);
      expect(alert1, contains('Warning'));

      // Second check at 85% → should NOT alert (already sent)
      final alert2 = service.checkBudgetAlert(warningBudget);
      expect(alert2, isNull);

      // Now pushes to exceeded (105%)
      const exceededBudget = Budget(
        category: 'food',
        month: '2026-09',
        limitPaise: 1000000,
        spentPaise: 1050000,
      );

      // First check at 100% threshold → should alert
      final alert3 = service.checkBudgetAlert(exceededBudget);
      expect(alert3, isNotNull);
      expect(alert3, contains('Exceeded'));

      // Second check at 105% → should NOT alert (already sent)
      final alert4 = service.checkBudgetAlert(exceededBudget);
      expect(alert4, isNull);
    });
  });
}
