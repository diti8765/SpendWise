import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/transactions/domain/month_summary.dart';

/// Provides the [CacheManager] singleton.
final cacheManagerProvider = Provider<CacheManager>((ref) {
  return const CacheManager();
});

/// Manages offline caching of monthly summaries and data.
/// Uses [SharedPreferences] to store JSON-serialized data.
/// Supports viewing the last three months offline (spec NFR).
class CacheManager {
  static const _summaryPrefix = 'summary_';
  static const _cachedMonthsKey = 'cached_months';

  const CacheManager();

  /// Saves a month summary to cache.
  Future<void> cacheMonthSummary(MonthSummary summary) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(summary.toJson());
    await prefs.setString('$_summaryPrefix${summary.month}', jsonStr);

    // Track cached months (keep only last 3).
    final cached = prefs.getStringList(_cachedMonthsKey) ?? [];
    if (!cached.contains(summary.month)) {
      cached.add(summary.month);
      // Keep only the 3 most recent months.
      cached.sort((a, b) => b.compareTo(a));
      if (cached.length > 3) {
        final toRemove = cached.sublist(3);
        for (final m in toRemove) {
          await prefs.remove('$_summaryPrefix$m');
        }
        cached.removeRange(3, cached.length);
      }
      await prefs.setStringList(_cachedMonthsKey, cached);
    }
  }

  /// Retrieves a cached month summary, or null if not available.
  Future<MonthSummary?> getCachedMonthSummary(String month) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_summaryPrefix$month');
    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return MonthSummary.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Returns the list of month keys currently cached.
  Future<List<String>> getCachedMonths() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_cachedMonthsKey) ?? [];
  }

  /// Clears all cached data.
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList(_cachedMonthsKey) ?? [];
    for (final m in cached) {
      await prefs.remove('$_summaryPrefix$m');
    }
    await prefs.remove(_cachedMonthsKey);
  }
}
