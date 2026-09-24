import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/money.dart';
import '../../transactions/state/transaction_providers.dart';

/// Bottom sheet for applying filters.
/// Supports category, amount range, and date range.
class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  String? _selectedCategory;
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(filterStateProvider);
    _selectedCategory = currentFilter.categoryId;
    if (currentFilter.minAmountPaise != null) {
      _minAmountController.text = Money.formatPaiseRaw(
        currentFilter.minAmountPaise!,
      );
    }
    if (currentFilter.maxAmountPaise != null) {
      _maxAmountController.text = Money.formatPaiseRaw(
        currentFilter.maxAmountPaise!,
      );
    }
    if (currentFilter.startDate != null && currentFilter.endDate != null) {
      _dateRange = DateTimeRange(
        start: currentFilter.startDate!,
        end: currentFilter.endDate!,
      );
    }
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _apply() {
    final notifier = ref.read(filterStateProvider.notifier);

    notifier.setCategory(_selectedCategory);

    final minPaise = Money.parseToPaise(_minAmountController.text);
    final maxPaise = Money.parseToPaise(_maxAmountController.text);
    notifier.setAmountRange(min: minPaise, max: maxPaise);

    if (_dateRange != null) {
      notifier.setDateRange(start: _dateRange!.start, end: _dateRange!.end);
    } else {
      notifier.setDateRange();
    }

    Navigator.of(context).pop();
  }

  void _clear() {
    ref.read(filterStateProvider.notifier).clearAll();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: theme.textTheme.titleLarge),
              TextButton(onPressed: _clear, child: const Text('Clear All')),
            ],
          ),
          const SizedBox(height: 16),

          // Category
          Text('Category', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _selectedCategory == null,
                onSelected: (_) => setState(() => _selectedCategory = null),
              ),
              ...categories.map(
                (cat) => ChoiceChip(
                  label: Text(cat.name),
                  selected: _selectedCategory == cat.id,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = _selectedCategory == cat.id
                          ? null
                          : cat.id;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amount range
          Text('Amount Range', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Min (\u20b9)',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Max (\u20b9)',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date range
          Text('Date Range', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(
              _dateRange != null
                  ? '${_dateRange!.start.day}/${_dateRange!.start.month} - '
                        '${_dateRange!.end.day}/${_dateRange!.end.month}'
                  : 'Select dates',
            ),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _dateRange,
              );
              if (range != null) {
                setState(() => _dateRange = range);
              }
            },
          ),
          const SizedBox(height: 24),

          FilledButton(onPressed: _apply, child: const Text('Apply Filters')),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
