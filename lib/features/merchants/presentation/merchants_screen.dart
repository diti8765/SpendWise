import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../app/theme.dart';
import '../state/merchant_providers.dart';
import '../domain/merchant_insight.dart';

/// Merchant analytics screen — list sorted by total spent.
class MerchantsScreen extends ConsumerWidget {
  const MerchantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantsAsync = ref.watch(merchantInsightsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Merchants')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(merchantInsightsProvider),
        child: merchantsAsync.when(
          loading: () => ListView.builder(
            itemCount: 6,
            itemBuilder: (_, __) => const TransactionSkeleton(),
          ),
          error: (e, _) => AsyncErrorView(
            error: e,
            onRetry: () => ref.invalidate(merchantInsightsProvider),
          ),
          data: (merchants) {
            if (merchants.isEmpty) {
              return const EmptyState(
                icon: Icons.store_outlined,
                title: 'No merchant data',
                subtitle: 'Your spending insights will appear here',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: merchants.length,
              itemBuilder: (context, index) {
                final merchant = merchants[index];
                return _MerchantTile(
                  merchant: merchant,
                  onTap: () =>
                      context.push('/merchants/${merchant.merchantKey}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MerchantTile extends StatelessWidget {
  final MerchantInsight merchant;
  final VoidCallback? onTap;

  const _MerchantTile({required this.merchant, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor =
        AppTheme.categoryColors[merchant.categoryId] ??
        AppTheme.categoryColors['other']!;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: categoryColor.withValues(alpha: 0.15),
        child: Text(
          merchant.merchantName[0].toUpperCase(),
          style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(merchant.merchantName),
      subtitle: Text(
        '${merchant.transactionCount} transactions • Avg ${Money.formatPaise(merchant.averagePaise)}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        Money.formatPaise(merchant.totalPaise),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
