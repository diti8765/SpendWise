import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../app/theme.dart';
import '../state/merchant_providers.dart';

/// Merchant detail showing total spent, transaction count, average.
class MerchantDetailScreen extends ConsumerWidget {
  final String merchantId;

  const MerchantDetailScreen({super.key, required this.merchantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantsAsync = ref.watch(merchantInsightsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Merchant')),
      body: merchantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (merchants) {
          final merchant = merchants
              .where((m) => m.merchantKey == merchantId)
              .firstOrNull;

          if (merchant == null) {
            return const EmptyState(
              icon: Icons.store_outlined,
              title: 'Merchant not found',
            );
          }

          final categoryColor =
              AppTheme.categoryColors[merchant.categoryId] ??
              AppTheme.categoryColors['other']!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: categoryColor.withValues(alpha: 0.15),
                        radius: 36,
                        child: Text(
                          merchant.merchantName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 28,
                            color: categoryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        merchant.merchantName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        merchant.categoryId[0].toUpperCase() +
                            merchant.categoryId.substring(1),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _StatRow(
                          label: 'Total Spent',
                          value: Money.formatPaise(merchant.totalPaise),
                        ),
                        const Divider(),
                        _StatRow(
                          label: 'Transactions',
                          value: '${merchant.transactionCount}',
                        ),
                        const Divider(),
                        _StatRow(
                          label: 'Average',
                          value: Money.formatPaise(merchant.averagePaise),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
