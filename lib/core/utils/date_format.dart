import 'package:intl/intl.dart';

/// Date formatting utilities for SpendWise.
/// API/model boundary uses ISO-8601 UTC. Presentation uses local time.
class AppDateFormat {
  AppDateFormat._(); // Non-instantiable utility class

  /// Full date with time: 23 Sep 2026, 2:30 PM
  static final DateFormat _fullDateTime = DateFormat('d MMM yyyy, h:mm a');

  /// Date only: 23 Sep 2026
  static final DateFormat _dateOnly = DateFormat('d MMM yyyy');

  /// Month and year: Sep 2026
  static final DateFormat _monthYear = DateFormat('MMM yyyy');

  /// Day header: Monday, 23 Sep
  static final DateFormat _dayHeader = DateFormat('EEEE, d MMM');

  /// Time only: 2:30 PM
  static final DateFormat _timeOnly = DateFormat('h:mm a');

  /// Month key for API: 2026-09
  static final DateFormat _monthKey = DateFormat('yyyy-MM');

  /// Formats a DateTime to full date with time.
  static String fullDateTime(DateTime dt) => _fullDateTime.format(dt.toLocal());

  /// Formats a DateTime to date only.
  static String dateOnly(DateTime dt) => _dateOnly.format(dt.toLocal());

  /// Formats a DateTime to month and year.
  static String monthYear(DateTime dt) => _monthYear.format(dt.toLocal());

  /// Formats a DateTime for day group headers.
  static String dayHeader(DateTime dt) => _dayHeader.format(dt.toLocal());

  /// Formats a DateTime to time only.
  static String timeOnly(DateTime dt) => _timeOnly.format(dt.toLocal());

  /// Returns the month key (e.g. '2026-09') for API queries.
  static String monthKey(DateTime dt) => _monthKey.format(dt);

  /// Returns a relative description: 'Today', 'Yesterday', or the day header.
  static String relative(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);

    final diff = today.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) {
      return DateFormat('EEEE').format(dt.toLocal()); // e.g. 'Monday'
    }
    return dayHeader(dt);
  }

  /// Parses an ISO-8601 UTC string to a local DateTime.
  static DateTime parseIso(String iso) => DateTime.parse(iso).toLocal();

  /// Returns the first day of the month for the given date.
  static DateTime startOfMonth(DateTime dt) => DateTime(dt.year, dt.month);

  /// Returns the last day of the month for the given date.
  static DateTime endOfMonth(DateTime dt) =>
      DateTime(dt.year, dt.month + 1, 0, 23, 59, 59);

  /// Returns the previous month.
  static DateTime previousMonth(DateTime dt) {
    return DateTime(dt.year, dt.month - 1);
  }

  /// Returns the next month.
  static DateTime nextMonth(DateTime dt) {
    return DateTime(dt.year, dt.month + 1);
  }
}
