import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';
import '../features/auth/state/auth_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/overview/presentation/overview_screen.dart';
import '../features/transactions/presentation/feed_screen.dart';
import '../features/transactions/presentation/transaction_detail_screen.dart';
import '../features/budgets/presentation/budgets_screen.dart';
import '../features/budgets/presentation/budget_edit_screen.dart';
import '../features/merchants/presentation/merchants_screen.dart';
import '../features/merchants/presentation/merchant_detail_screen.dart';

/// Listens to auth state changes and notifies GoRouter to re-evaluate redirects.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// Provides the GoRouter instance with session-driven route guard.
/// When no authenticated session exists, all routes redirect to login (B3).
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final isOnLogin = state.matchedLocation == AppRoutes.login;

      // Not authenticated and not on login → redirect to login (B3).
      if (!isAuthenticated && !isOnLogin) {
        return AppRoutes.login;
      }

      // Authenticated and on login → redirect to overview.
      if (isAuthenticated && isOnLogin) {
        return AppRoutes.overview;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Main app shell with bottom navigation.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AppShell(navigationShell: shell),
        branches: [
          // Overview tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.overview,
                builder: (context, state) => const OverviewScreen(),
              ),
            ],
          ),
          // Transactions tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.transactions,
                builder: (context, state) => const FeedScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return TransactionDetailScreen(transactionId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Budgets tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.budgets,
                builder: (context, state) => const BudgetsScreen(),
                routes: [
                  GoRoute(
                    path: ':category',
                    builder: (context, state) {
                      final cat = state.pathParameters['category'] ?? '';
                      return BudgetEditScreen(category: cat);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Merchants tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.merchants,
                builder: (context, state) => const MerchantsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return MerchantDetailScreen(merchantId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// App shell with bottom navigation bar.
/// StatefulShellRoute preserves state across tab switches.
class _AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _AppShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Merchants',
          ),
        ],
      ),
    );
  }
}
