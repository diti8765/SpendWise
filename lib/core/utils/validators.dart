/// Input validators for SpendWise forms.
class Validators {
  Validators._(); // Non-instantiable utility class

  /// Validates that a string is not null or empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates a budget amount in rupee string form.
  /// Must be a positive number.
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final cleaned = value.replaceAll(',', '').replaceAll('₹', '').trim();
    final parsed = double.tryParse(cleaned);
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid amount greater than zero';
    }
    return null;
  }

  /// Validates a customer ID for login.
  static String? customerId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Customer ID is required';
    }
    if (value.trim().length < 4) {
      return 'Customer ID must be at least 4 characters';
    }
    return null;
  }

  /// Validates a PIN for login.
  static String? pin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN is required';
    }
    if (value.trim().length < 4 || value.trim().length > 6) {
      return 'PIN must be 4-6 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'PIN must contain only digits';
    }
    return null;
  }

  /// Sanitizes a search query (trims whitespace, limits length).
  static String sanitizeSearch(String query) {
    return query.trim().substring(0, query.length.clamp(0, 100));
  }
}
