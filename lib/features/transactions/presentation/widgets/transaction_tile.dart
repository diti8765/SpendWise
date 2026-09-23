import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/date_format.dart';
import '../../domain/transaction.dart';

/// A single transaction row in the feed.
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor =
        AppTheme.categoryColors[transaction.category.id] ??
        AppTheme.categoryColors['other']!;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: categoryColor.withValues(alpha: 0.15),
        child: _categoryIcon(transaction.category.icon, categoryColor),
      ),
      title: Text(
        transaction.merchantName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${transaction.category.name} • ${AppDateFormat.timeOnly(transaction.at)}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        Money.formatPaise(transaction.amountPaise),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _categoryIcon(String iconName, Color color) {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'shopping_bag': Icons.shopping_bag,
      'directions_car': Icons.directions_car,
      'movie': Icons.movie,
      'receipt': Icons.receipt,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'more_horiz': Icons.more_horiz,
    };
    return Icon(iconMap[iconName] ?? Icons.category, color: color, size: 20);
  }
}
