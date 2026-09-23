import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_format.dart';
import '../data/merchant_repository.dart';
import '../domain/merchant_insight.dart';
import '../domain/merchant_rule.dart';
import '../../overview/state/overview_providers.dart';

/// Merchant insights for the current month.
final merchantInsightsProvider = FutureProvider<List<MerchantInsight>>((
  ref,
) async {
  final month = ref.watch(monthProvider);
  final monthKey = AppDateFormat.monthKey(month);
  final repo = ref.watch(merchantRepositoryProvider);
  return repo.getMerchants(monthKey);
});

/// All merchant categorisation rules.
final merchantRulesProvider = FutureProvider<List<MerchantRule>>((ref) async {
  final repo = ref.watch(merchantRepositoryProvider);
  return repo.getMerchantRules();
});
