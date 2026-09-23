import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the app lock state.
/// When the app goes to background, [isLocked] becomes true.
/// The lock overlay should appear before any sensitive data is shown.
final appLockProvider = StateNotifierProvider<AppLockNotifier, bool>((ref) {
  return AppLockNotifier();
});

class AppLockNotifier extends StateNotifier<bool> {
  /// true = locked, false = unlocked
  AppLockNotifier() : super(false);

  /// Lock the app (called when app goes to background).
  void lock() => state = true;

  /// Unlock the app (called after successful biometric auth).
  void unlock() => state = false;
}

/// Listens to app lifecycle changes and locks the app when it goes to background.
/// Attach this as a mixin or use it in the root widget.
class AppLifecycleHandler with WidgetsBindingObserver {
  final AppLockNotifier notifier;
  final bool hasSession;

  AppLifecycleHandler({required this.notifier, required this.hasSession});

  void register() {
    WidgetsBinding.instance.addObserver(this);
  }

  void unregister() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!hasSession) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        notifier.lock();
      case AppLifecycleState.resumed:
        // Lock remains until biometric unlock succeeds.
        break;
      default:
        break;
    }
  }
}
