import 'package:flutter/material.dart';

import '../errors/bank_error.dart';

/// Displays a user-friendly error message with an optional retry button.
/// Used in every network-backed screen's error state.
class AsyncErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const AsyncErrorView({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = _errorMessage(error);
    final icon = _errorIcon(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _errorMessage(Object error) {
    if (error is BankError) return error.message;
    return 'An unexpected error occurred.';
  }

  IconData _errorIcon(Object error) {
    if (error is NetworkError) return Icons.wifi_off_rounded;
    if (error is UnauthorizedError) return Icons.lock_outline_rounded;
    if (error is ServerError) return Icons.cloud_off_rounded;
    return Icons.error_outline_rounded;
  }
}
