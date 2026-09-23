import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/utils/money.dart';

void main() {
  group('Money utility', () {
    test('formats paise to rupee string with Indian grouping', () {
      expect(Money.formatPaise(45000), '₹450.00');
      expect(Money.formatPaise(145050), '₹1,450.50');
      expect(Money.formatPaise(10000000), '₹1,00,000.00');
      expect(Money.formatPaise(0), '₹0.00');
    });

    test('formats paise compact', () {
      expect(Money.formatPaiseCompact(1250000), isNotEmpty);
      expect(Money.formatPaiseCompact(50000), isNotEmpty);
    });

    test('formats paise raw for input fields', () {
      expect(Money.formatPaiseRaw(145050), '1,450.50');
      expect(Money.formatPaiseRaw(0), '0.00');
    });

    test('parses rupee string to paise', () {
      expect(Money.parseToPaise('₹450.00'), 45000);
      expect(Money.parseToPaise('1,450.50'), 145050);
      expect(Money.parseToPaise('450'), 45000);
      expect(Money.parseToPaise('invalid'), isNull);
      expect(Money.parseToPaise(''), isNull);
    });

    test('safe arithmetic', () {
      expect(Money.add(10000, 20000), 30000);
      expect(Money.subtract(30000, 10000), 20000);
    });

    test('percentage calculation', () {
      expect(Money.percentage(50, 100), 50.0);
      expect(Money.percentage(0, 100), 0.0);
      expect(Money.percentage(50, 0), 0.0); // No division by zero
    });

    test('negative amount detection', () {
      expect(Money.isNegative(-500), isTrue);
      expect(Money.isNegative(500), isFalse);
      expect(Money.isNegative(0), isFalse);
    });
  });
}
