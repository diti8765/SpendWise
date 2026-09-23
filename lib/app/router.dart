import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Placeholder widgets until you build the UI in Phase 2
class OverviewScreen extends StatelessWidget { const OverviewScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Overview'))); }
class FeedScreen extends StatelessWidget { const FeedScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Feed'))); }
class BudgetsScreen extends StatelessWidget { const BudgetsScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Budgets'))); }
class MerchantsScreen extends StatelessWidget { const MerchantsScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Merchants'))); }

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/overview',
    routes: [
      GoRoute(
        path: '/overview',
        builder: (context, state) => const OverviewScreen(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const FeedScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return Scaffold(body: Center(child: Text('Transaction $id')));
            },
          ),
        ],
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        path: '/merchants',
        builder: (context, state) => const MerchantsScreen(),
      ),
    ],
  );
});