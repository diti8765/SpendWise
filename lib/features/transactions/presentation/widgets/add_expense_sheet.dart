import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme.dart';
import '../../../../core/notifications/budget_alert_service.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../../budgets/data/budget_repository.dart';
import '../../../budgets/state/budget_providers.dart';
import '../../../overview/state/overview_providers.dart';
import '../../data/transaction_repository.dart';
import '../../domain/transaction.dart';
import '../../state/transaction_providers.dart';

/// Bottom sheet allowing users to manually record/input a new expense.
class AddExpenseSheet extends ConsumerStatefulWidget {
  final VoidCallback? onExpenseAdded;

  const AddExpenseSheet({super.key, this.onExpenseAdded});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();

  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String _selectedMode = 'UPI';
  bool _isSubmitting = false;

  final List<String> _modes = ['UPI', 'Card', 'NetBanking', 'Cash'];

  // Quick preset merchants with their corresponding category IDs
  final List<({String name, String categoryId})> _quickPresets = const [
    (name: 'Swiggy', categoryId: 'food'),
    (name: 'Zomato', categoryId: 'food'),
    (name: 'Amazon', categoryId: 'shopping'),
    (name: 'Uber', categoryId: 'travel'),
    (name: 'Netflix', categoryId: 'entertainment'),
    (name: 'Electricity', categoryId: 'bills'),
    (name: 'Apollo Pharmacy', categoryId: 'health'),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyPreset(
    String merchant,
    String categoryId,
    List<Category> categories,
  ) {
    _merchantController.text = merchant;
    final match = categories.where((c) => c.id == categoryId).firstOrNull;
    if (match != null) {
      setState(() => _selectedCategory = match);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _submit(List<Category> categories) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final category = _selectedCategory ?? categories.first;
    final amountPaise = Money.parseToPaise(_amountController.text.trim()) ?? 0;
    final merchantName = _merchantController.text.trim();
    final description = _notesController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      final transaction = Transaction(
        id: const Uuid().v4(),
        merchantRaw: merchantName.toUpperCase(),
        merchantName: merchantName,
        category: category,
        amountPaise: amountPaise,
        at: _selectedDate,
        mode: _selectedMode,
        description: description.isNotEmpty ? description : null,
      );

      // 1. Persist transaction
      await ref.read(transactionRepositoryProvider).addTransaction(transaction);

      // 2. Update budget & trigger alert if threshold crossed
      final monthKey = AppDateFormat.monthKey(_selectedDate);
      final updatedBudget = await ref
          .read(budgetRepositoryProvider)
          .recordExpense(
            category: category.id,
            month: monthKey,
            amountPaise: amountPaise,
          );

      String? alertMessage;
      if (updatedBudget != null) {
        alertMessage = ref
            .read(budgetAlertServiceProvider)
            .checkBudgetAlert(updatedBudget);
      }

      // 3. Invalidate caches so UI updates seamlessly
      ref.invalidate(feedProvider);
      ref.invalidate(summaryProvider);
      ref.invalidate(currentSummaryProvider);
      ref.invalidate(recentTransactionsProvider);
      ref.invalidate(budgetsProvider);
      ref.invalidate(currentBudgetsProvider);

      widget.onExpenseAdded?.call();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);

      // 4. User feedback
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Expense of ${Money.formatPaise(amountPaise)} recorded for ${category.name}!',
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (alertMessage != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(alertMessage)),
              ],
            ),
            backgroundColor: updatedBudget!.isExceeded
                ? Colors.red.shade700
                : Colors.amber.shade800,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add expense: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider);
    _selectedCategory ??= categories.first;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Input Expense',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amount field
                TextFormField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                    prefixText: '₹ ',
                    prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final paise = Money.parseToPaise(value.trim());
                    if (paise == null || paise <= 0) {
                      return 'Please enter a valid amount greater than ₹0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quick merchant presets
                Text(
                  'Quick Suggestions',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickPresets.map((preset) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(preset.name),
                          avatar: const Icon(Icons.bolt, size: 16),
                          onPressed: () => _applyPreset(
                            preset.name,
                            preset.categoryId,
                            categories,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Merchant / Payee
                TextFormField(
                  controller: _merchantController,
                  decoration: InputDecoration(
                    labelText: 'Merchant / Payee',
                    hintText: 'e.g. Swiggy, Uber, Grocery Store',
                    prefixIcon: const Icon(Icons.storefront),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a merchant or payee name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category selector
                DropdownButtonFormField<Category>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: categories.map((cat) {
                    final color =
                        AppTheme.categoryColors[cat.id] ??
                        AppTheme.categoryColors['other']!;
                    return DropdownMenuItem<Category>(
                      value: cat,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: color.withValues(alpha: 0.2),
                            child: Icon(Icons.circle, color: color, size: 12),
                          ),
                          const SizedBox(width: 8),
                          Text(cat.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (cat) {
                    if (cat != null) {
                      setState(() => _selectedCategory = cat);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Date and Payment Mode Row
                Row(
                  children: [
                    // Date picker button
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          AppDateFormat.dateOnly(_selectedDate),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Payment Mode Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedMode,
                        decoration: InputDecoration(
                          labelText: 'Mode',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _modes.map((mode) {
                          return DropdownMenuItem<String>(
                            value: mode,
                            child: Text(mode),
                          );
                        }).toList(),
                        onChanged: (mode) {
                          if (mode != null) {
                            setState(() => _selectedMode = mode);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes / Description (optional)
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes / Description (Optional)',
                    hintText: 'e.g. Lunch with team',
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                FilledButton(
                  onPressed: _isSubmitting ? null : () => _submit(categories),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Expense',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
