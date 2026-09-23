import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/validators.dart';
import '../../overview/state/overview_providers.dart';
import '../../transactions/state/transaction_providers.dart';
import '../data/budget_repository.dart';
import '../domain/budget.dart';
import '../state/budget_providers.dart';

/// Create or edit a budget for a category.
class BudgetEditScreen extends ConsumerStatefulWidget {
  final String category;

  const BudgetEditScreen({super.key, required this.category});

  @override
  ConsumerState<BudgetEditScreen> createState() => _BudgetEditScreenState();
}

class _BudgetEditScreenState extends ConsumerState<BudgetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;

  bool get _isNew => widget.category == 'new' || widget.category.isEmpty;

  @override
  void initState() {
    super.initState();
    if (!_isNew) {
      _selectedCategory = widget.category;
    }
    // Pre-fill if editing an existing budget.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isNew) {
        final budgets = ref.read(budgetsProvider).valueOrNull ?? [];
        final existing = budgets
            .where((b) => b.category == widget.category)
            .firstOrNull;
        if (existing != null) {
          _amountController.text = Money.formatPaiseRaw(existing.limitPaise);
        }
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _navigateBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.budgets);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final targetCategory = _isNew ? _selectedCategory : widget.category;
    if (targetCategory == null || targetCategory.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final paise = Money.parseToPaise(_amountController.text);
    if (paise == null || paise <= 0) return;

    setState(() => _isLoading = true);

    try {
      final month = ref.read(monthProvider);
      final monthKey = AppDateFormat.monthKey(month);

      final budget = Budget(
        category: targetCategory,
        month: monthKey,
        limitPaise: paise,
        spentPaise: 0, // Will be calculated by repository/backend
      );

      await ref.read(budgetRepositoryProvider).setBudget(budget);
      ref.invalidate(budgetsProvider);

      if (mounted) _navigateBack();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save budget: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final month = ref.read(monthProvider);
      final monthKey = AppDateFormat.monthKey(month);
      await ref
          .read(budgetRepositoryProvider)
          .deleteBudget(category: widget.category, month: monthKey);
      ref.invalidate(budgetsProvider);
      if (mounted) _navigateBack();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete budget: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    final displayCategory = _isNew
        ? (_selectedCategory ?? 'Select Category')
        : (widget.category.isNotEmpty
              ? widget.category[0].toUpperCase() + widget.category.substring(1)
              : 'Budget');

    final categoryColor =
        AppTheme.categoryColors[_selectedCategory] ??
        AppTheme.categoryColors['other']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New Budget' : 'Edit Budget'),
        actions: [
          if (!_isNew)
            IconButton(
              tooltip: 'Delete budget',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isNew) ...[
                Text('Select Category', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categories.map((cat) {
                    final color =
                        AppTheme.categoryColors[cat.id] ??
                        AppTheme.categoryColors['other']!;
                    return DropdownMenuItem<String>(
                      value: cat.id,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.15),
                            radius: 12,
                            child: Icon(Icons.circle, color: color, size: 12),
                          ),
                          const SizedBox(width: 8),
                          Text(cat.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedCategory = val);
                  },
                  validator: (val) =>
                      val == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 24),
              ] else ...[
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: categoryColor.withValues(alpha: 0.15),
                      radius: 20,
                      child: Icon(Icons.category, color: categoryColor),
                    ),
                    const SizedBox(width: 12),
                    Text(displayCategory, style: theme.textTheme.headlineSmall),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Budget (\u20b9)',
                  prefixText: '\u20b9 ',
                ),
                keyboardType: TextInputType.number,
                validator: Validators.amount,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
