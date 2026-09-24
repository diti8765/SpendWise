import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../domain/merchant_insight.dart';
import '../domain/merchant_rule.dart';

/// Provides the [MerchantRepository].
final merchantRepositoryProvider = Provider<MerchantRepository>((ref) {
  return MerchantRepository(dio: ref.watch(apiClientProvider));
});

/// Repository for merchant insights and categorisation rules.
class MerchantRepository {
  final Dio _dio;
  final ErrorMapper _errorMapper = const ErrorMapper();
  static const bool _useMock = true;

  MerchantRepository({required Dio dio})
    : _dio = dio; // ignore: prefer_initializing_formals

  /// Fetches merchant insights for the given month.
  Future<List<MerchantInsight>> getMerchants(String month) async {
    if (_useMock) return _mockGetMerchants(month);

    try {
      final response = await _dio.get(
        '/merchants',
        queryParameters: {'month': month},
      );
      final items = response.data as List;
      return items
          .map((e) => MerchantInsight.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _errorMapper.mapDioException(e);
    }
  }

  /// Fetches all merchant → category rules.
  Future<List<MerchantRule>> getMerchantRules() async {
    if (_useMock) return _mockGetRules();

    try {
      final response = await _dio.get('/merchant-rules');
      final items = response.data as List;
      return items
          .map((e) => MerchantRule.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _errorMapper.mapDioException(e);
    }
  }

  /// Creates or updates a merchant → category rule.
  Future<MerchantRule> setMerchantRule(MerchantRule rule) async {
    if (_useMock) return _mockSetRule(rule);

    try {
      final response = await _dio.put(
        '/merchant-rules/${rule.merchantKey}',
        data: rule.toJson(),
      );
      return MerchantRule.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _errorMapper.mapDioException(e);
    }
  }

  // ─── Mock implementation ──────────────────────────────────────

  Future<List<MerchantInsight>> _mockGetMerchants(String month) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Generate mock merchant insights
    return [
      const MerchantInsight(
        merchantName: 'Swiggy',
        merchantKey: 'swiggy',
        categoryId: 'food',
        totalPaise: 450000,
        transactionCount: 12,
      ),
      const MerchantInsight(
        merchantName: 'Amazon',
        merchantKey: 'amazon',
        categoryId: 'shopping',
        totalPaise: 890000,
        transactionCount: 8,
      ),
      const MerchantInsight(
        merchantName: 'Uber',
        merchantKey: 'uber',
        categoryId: 'travel',
        totalPaise: 230000,
        transactionCount: 15,
      ),
      const MerchantInsight(
        merchantName: 'Netflix',
        merchantKey: 'netflix',
        categoryId: 'entertainment',
        totalPaise: 64900,
        transactionCount: 1,
      ),
      const MerchantInsight(
        merchantName: 'Zomato',
        merchantKey: 'zomato',
        categoryId: 'food',
        totalPaise: 380000,
        transactionCount: 10,
      ),
      const MerchantInsight(
        merchantName: 'Flipkart',
        merchantKey: 'flipkart',
        categoryId: 'shopping',
        totalPaise: 560000,
        transactionCount: 5,
      ),
      const MerchantInsight(
        merchantName: 'Jio',
        merchantKey: 'jio',
        categoryId: 'bills',
        totalPaise: 59900,
        transactionCount: 1,
      ),
      const MerchantInsight(
        merchantName: 'Apollo Pharmacy',
        merchantKey: 'apollo pharmacy',
        categoryId: 'health',
        totalPaise: 125000,
        transactionCount: 3,
      ),
    ];
  }

  static final List<MerchantRule> _mockRules = [
    const MerchantRule(merchantKey: 'swiggy', category: 'food'),
    const MerchantRule(merchantKey: 'amazon', category: 'shopping'),
    const MerchantRule(merchantKey: 'uber', category: 'travel'),
  ];

  Future<List<MerchantRule>> _mockGetRules() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_mockRules);
  }

  Future<MerchantRule> _mockSetRule(MerchantRule rule) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _mockRules.indexWhere(
      (r) => r.merchantKey == rule.merchantKey,
    );
    if (index >= 0) {
      _mockRules[index] = rule;
    } else {
      _mockRules.add(rule);
    }
    return rule;
  }
}
