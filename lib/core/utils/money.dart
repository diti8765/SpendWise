import 'package:intl/intl.dart';

/// Utility for safe money operations using integer paise.
///
/// RULE: Money is always stored as integer paise internally.
/// ₹450 = 45000 paise. Formatting to ₹ happens only at the
/// presentation boundary using this class.
///
/// Example:
///   Money.formatPaise(45000)  → '₹450.00'
///   Money.formatPaise(145050) → '₹1,450.50'
class Money {
  Money._(); // Non-instantiable utility class

  /// Indian number format: 1,23,456.78
  static final NumberFormat _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Compact format without decimals for large amounts: ₹1.2L
  static final NumberFormat _compactFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Formats paise as a rupee string with Indian grouping.
  ///
  /// Example: 145050 → '₹1,450.50'
  static String formatPaise(int paise) {
    final rupees = paise / 100;
    return _indianFormat.format(rupees);
  }

  /// Formats paise in compact form for charts and summaries.
  ///
  /// Example: 1250000 → '₹12.5K' or '₹12,500'
  static String formatPaiseCompact(int paise) {
    final rupees = paise / 100;
    return _compactFormat.format(rupees);
  }

  /// Formats paise without the currency symbol (for input fields).
  ///
  /// Example: 145050 → '1,450.50'
  static String formatPaiseRaw(int paise) {
    final rupees = paise / 100;
    final format = NumberFormat('#,##,##0.00', 'en_IN');
    return format.format(rupees);
  }

  /// Parses a rupee string back to paise.
  /// Strips ₹, commas, spaces. Returns null if unparseable.
  ///
  /// Example: '₹1,450.50' → 145050
  static int? parseToPaise(String input) {
    try {
      final cleaned = input
          .replaceAll('₹', '')
          .replaceAll(',', '')
          .replaceAll(' ', '')
          .trim();
      if (cleaned.isEmpty) return null;
      final rupees = double.parse(cleaned);
      return (rupees * 100).round();
    } catch (_) {
      return null;
    }
  }

  /// Adds two paise amounts safely.
  static int add(int a, int b) => a + b;

  /// Subtracts paise amounts safely.
  static int subtract(int a, int b) => a - b;

  /// Returns the percentage of [part] relative to [total].
  /// Returns 0 if total is 0 to avoid division by zero.
  static double percentage(int part, int total) {
    if (total == 0) return 0;
    return (part * 100) / total;
  }

  /// Returns true if the paise amount represents a negative value (e.g. refund).
  static bool isNegative(int paise) => paise < 0;
}
