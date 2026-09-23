import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../state/overview_providers.dart';

/// Shows the most recent transactions on the overview screen.
class RecentTransactionsList extends ConsumerWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final theme = Theme.of(context);

    return transactionsAsync.when(
      loading: () => Column(
        children: List.generate(3, (_) => const TransactionSkeleton()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (transactions) {
        if (transactions.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
          );
        }

        return Column(
          children: transactions.map((t) {
            return ListTile(
              onTap: () => context.push('/transactions/${t.id}'),
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  t.merchantName[0].toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                t.merchantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${t.category.name} • ${AppDateFormat.relative(t.at)}',
                style: theme.textTheme.bodySmall,
              ),
              trailing: Text(
                Money.formatPaise(t.amountPaise),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
