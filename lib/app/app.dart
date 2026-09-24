import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/security/app_lock.dart';
import '../core/security/app_lock_overlay.dart';
import '../features/auth/state/auth_provider.dart';
import 'router.dart';
import 'theme.dart';

/// Root widget for the SpendWise application.
/// Manages app lifecycle to enforce background app lock (B2).
class SpendWiseApp extends ConsumerStatefulWidget {
  const SpendWiseApp({super.key});

  @override
  ConsumerState<SpendWiseApp> createState() => _SpendWiseAppState();
}

class _SpendWiseAppState extends ConsumerState<SpendWiseApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      ref.read(appLockProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final isLocked = ref.watch(appLockProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return MaterialApp.router(
      title: 'SpendWise',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (isLocked && isAuthenticated) const AppLockOverlay(),
          ],
        );
      },
    );
  }
}
