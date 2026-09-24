// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../state/transaction_providers.dart';

/// Result from the category picker.
class CategoryPickerResult {
  final String categoryId;
  final bool applyToMerchant;

  const CategoryPickerResult({
    required this.categoryId,
    required this.applyToMerchant,
  });
}

/// Bottom sheet for selecting a new category.
class CategoryPicker extends ConsumerStatefulWidget {
  final String currentCategoryId;
  final String merchantName;

  const CategoryPicker({
    super.key,
    required this.currentCategoryId,
    required this.merchantName,
  });

  @override
  ConsumerState<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends ConsumerState<CategoryPicker> {
  late String _selectedCategoryId;
  bool _applyToMerchant = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.currentCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Change Category', style: theme.textTheme.titleLarge),
          ),

          // Category list
          ...categories.map((cat) {
            final color =
                AppTheme.categoryColors[cat.id] ??
                AppTheme.categoryColors['other']!;

            return RadioListTile<String>(
              title: Text(cat.name),
              secondary: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                radius: 16,
                child: Icon(Icons.category, color: color, size: 16),
              ),
              value: cat.id,
              groupValue: _selectedCategoryId,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategoryId = value);
                }
              },
            );
          }),

          const Divider(),

          // Apply to merchant checkbox
          CheckboxListTile(
            title: Text('Apply to all from ${widget.merchantName}'),
            subtitle: const Text(
              'Future transactions will also use this category',
            ),
            value: _applyToMerchant,
            onChanged: (value) {
              setState(() => _applyToMerchant = value ?? false);
            },
          ),

          // Confirm button
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _selectedCategoryId == widget.currentCategoryId
                  ? null // Disable if same category
                  : () {
                      Navigator.of(context).pop(
                        CategoryPickerResult(
                          categoryId: _selectedCategoryId,
                          applyToMerchant: _applyToMerchant,
                        ),
                      );
                    },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
