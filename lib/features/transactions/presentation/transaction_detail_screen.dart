import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/money.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../app/theme.dart';
import '../state/transaction_providers.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';
import 'widgets/category_picker.dart';

/// Shows full transaction details and allows recategorisation.
class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnAsync = ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: txnAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AsyncErrorView(
          error: e,
          onRetry: () =>
              ref.invalidate(transactionDetailProvider(transactionId)),
        ),
        data: (txn) => _TransactionDetailBody(
          transaction: txn,
          transactionId: transactionId,
        ),
      ),
    );
  }
}

class _TransactionDetailBody extends ConsumerWidget {
  final Transaction transaction;
  final String transactionId;

  const _TransactionDetailBody({
    required this.transaction,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryColor =
        AppTheme.categoryColors[transaction.category.id] ??
        AppTheme.categoryColors['other']!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount
          Center(
            child: Text(
              Money.formatPaise(transaction.amountPaise),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Merchant',
                    value: transaction.merchantName,
                  ),
                  const Divider(),
                  _DetailRow(
                    label: 'Raw Merchant',
                    value: transaction.merchantRaw,
                  ),
                  const Divider(),
                  _DetailRow(
                    label: 'Date',
                    value: AppDateFormat.fullDateTime(transaction.at),
                  ),
                  const Divider(),
                  _DetailRow(label: 'Mode', value: transaction.mode),
                  const Divider(),
                  _DetailRow(label: 'Transaction ID', value: transaction.id),
                  if (transaction.description != null) ...[
                    const Divider(),
                    _DetailRow(
                      label: 'Description',
                      value: transaction.description!,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category (tappable for recategorisation)
          Text('Category', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showCategoryPicker(context, ref),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: categoryColor.withValues(alpha: 0.15),
                    radius: 20,
                    child: Icon(Icons.category, color: categoryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      transaction.category.name,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Change',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCategoryPicker(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<CategoryPickerResult>(
      context: context,
      builder: (_) => CategoryPicker(
        currentCategoryId: transaction.category.id,
        merchantName: transaction.merchantName,
      ),
    );

    if (result == null || !context.mounted) return;

    // Optimistic UI: immediately update the local state.
    // The repository call happens in the background.
    try {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.recategorise(
        transactionId: transactionId,
        newCategoryId: result.categoryId,
        applyToMerchant: result.applyToMerchant,
      );

      // Invalidate to refresh data.
      ref.invalidate(transactionDetailProvider(transactionId));
      // Also invalidate feed and summaries since data changed.
      ref.invalidate(feedProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.applyToMerchant
                  ? 'Category updated for all ${transaction.merchantName} transactions'
                  : 'Category updated',
            ),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                // Undo: revert to original category.
                await repo.recategorise(
                  transactionId: transactionId,
                  newCategoryId: transaction.category.id,
                  applyToMerchant: result.applyToMerchant,
                );
                ref.invalidate(transactionDetailProvider(transactionId));
                ref.invalidate(feedProvider);
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update category: $e')),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
