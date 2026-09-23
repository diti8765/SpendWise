import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_format.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/empty_state.dart';
import '../state/transaction_providers.dart';
import '../domain/transaction.dart';
import '../../filters/domain/filter_state.dart';
import '../../filters/presentation/filter_sheet.dart';
import '../../overview/state/overview_providers.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/day_header.dart';
import 'widgets/add_expense_sheet.dart';

/// Categorised transaction feed with search, filters, and pagination.
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Transaction> _allTransactions = [];
  String? _nextCursor;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _nextCursor != null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_nextCursor == null || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    final month = ref.read(monthProvider);
    final monthKey = AppDateFormat.monthKey(month);
    final filter = ref.read(filterStateProvider);

    final feedKey = FeedKey(
      month: monthKey,
      filter: filter,
      cursor: _nextCursor,
    );

    final page = await ref.read(feedProvider(feedKey).future);
    setState(() {
      _allTransactions.addAll(page.items);
      _nextCursor = page.nextCursor;
      _isLoadingMore = false;
    });
  }

  Future<void> _refresh() async {
    final month = ref.read(monthProvider);
    final monthKey = AppDateFormat.monthKey(month);
    final filter = ref.read(filterStateProvider);

    final feedKey = FeedKey(month: monthKey, filter: filter);
    ref.invalidate(feedProvider(feedKey));

    final page = await ref.read(feedProvider(feedKey).future);
    setState(() {
      _allTransactions
        ..clear()
        ..addAll(page.items);
      _nextCursor = page.nextCursor;
    });
  }

  Future<void> _openAddExpense() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExpenseSheet(
        onExpenseAdded: () {
          _refresh();
        },
      ),
    );
    if (added == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(monthProvider);
    final monthKey = AppDateFormat.monthKey(month);
    final filter = ref.watch(filterStateProvider);
    final feedKey = FeedKey(month: monthKey, filter: filter);
    final feedAsync = ref.watch(feedProvider(feedKey));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            tooltip: 'Add Expense',
            icon: const Icon(Icons.add),
            onPressed: _openAddExpense,
          ),
          IconButton(
            tooltip: 'Filters',
            icon: Badge(
              isLabelVisible: filter.activeCount > 0,
              label: Text('${filter.activeCount}'),
              child: const Icon(Icons.tune),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const FilterSheet(),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search merchants...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(filterStateProvider.notifier)
                              .setSearchQuery(null);
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (value) {
                ref.read(filterStateProvider.notifier).setSearchQuery(value);
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category filter chips
          _CategoryFilterChips(ref: ref, currentFilter: filter),

          // Transaction list
          Expanded(
            child: feedAsync.when(
              loading: () => ListView.builder(
                itemCount: 8,
                itemBuilder: (_, __) => const TransactionSkeleton(),
              ),
              error: (e, _) => AsyncErrorView(error: e, onRetry: _refresh),
              data: (page) {
                final displayItems = _allTransactions.isNotEmpty
                    ? _allTransactions
                    : page.items;

                if (displayItems.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions found',
                    subtitle: filter.isActive
                        ? 'Try adjusting your filters'
                        : null,
                    onAction: filter.isActive
                        ? () =>
                              ref.read(filterStateProvider.notifier).clearAll()
                        : null,
                    actionLabel: filter.isActive ? 'Clear Filters' : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: _buildList(displayItems, _nextCursor != null),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'feed_add_expense_fab',
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        onPressed: _openAddExpense,
      ),
    );
  }

  Widget _buildList(List<Transaction> transactions, bool hasMore) {
    // Group by day
    final grouped = <String, List<Transaction>>{};
    for (final t in transactions) {
      final key = AppDateFormat.relative(t.at);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    final dayKeys = grouped.keys.toList();
    // Count total items: day headers + transactions
    int itemCount = 0;
    for (final key in dayKeys) {
      itemCount += 1 + grouped[key]!.length; // header + transactions
    }
    if (hasMore) itemCount++; // loading indicator

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        int currentIndex = 0;
        for (final dayKey in dayKeys) {
          final dayTxns = grouped[dayKey]!;

          // Day header
          if (index == currentIndex) {
            return DayHeader(title: dayKey);
          }
          currentIndex++;

          // Transactions in this day
          for (final txn in dayTxns) {
            if (index == currentIndex) {
              return TransactionTile(
                transaction: txn,
                onTap: () => context.push('/transactions/${txn.id}'),
              );
            }
            currentIndex++;
          }
        }

        // Loading more indicator
        if (hasMore && index == itemCount - 1) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _CategoryFilterChips extends StatelessWidget {
  final WidgetRef ref;
  final FilterState currentFilter;

  const _CategoryFilterChips({required this.ref, required this.currentFilter});

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: currentFilter.categoryId == null,
              onSelected: (_) {
                ref.read(filterStateProvider.notifier).setCategory(null);
              },
            ),
          ),
          ...categories.map((cat) {
            final isSelected = currentFilter.categoryId == cat.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat.name),
                selected: isSelected,
                onSelected: (_) {
                  ref
                      .read(filterStateProvider.notifier)
                      .setCategory(isSelected ? null : cat.id);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
