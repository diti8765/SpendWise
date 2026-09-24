import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/spendwise_logo.dart';
import '../domain/auth_models.dart';
import '../state/auth_provider.dart';

/// Login screen — customer ID + PIN.
/// On success, navigates to the overview.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _pinController = TextEditingController();
  bool _obscurePin = true;

  @override
  void dispose() {
    _customerIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final request = LoginRequest(
      customerId: _customerIdController.text.trim(),
      pin: _pinController.text.trim(),
    );

    await ref.read(authStateProvider.notifier).login(request);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final isLoading = authState.isLoading;

    // Listen for successful login and navigate.
    ref.listen(authStateProvider, (prev, next) {
      if (next.valueOrNull != null) {
        context.go(AppRoutes.overview);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SpendWise Logo
                  const SpendWiseLogo(
                    size: 80,
                    showText: true,
                    subtitle: 'Expense Analytics & Monthly Budgets',
                  ),
                  const SizedBox(height: 48),

                  // Customer ID / Username
                  TextFormField(
                    controller: _customerIdController,
                    decoration: const InputDecoration(
                      labelText: 'Customer ID / Username',
                      hintText: 'e.g. ANANYA or your name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: Validators.customerId,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    autofillHints: const [AutofillHints.username],
                  ),
                  const SizedBox(height: 16),

                  // PIN
                  TextFormField(
                    controller: _pinController,
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscurePin ? 'Show PIN' : 'Hide PIN',
                        icon: Icon(
                          _obscurePin
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePin = !_obscurePin);
                        },
                      ),
                    ),
                    obscureText: _obscurePin,
                    keyboardType: TextInputType.number,
                    validator: Validators.pin,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    onFieldSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: 8),

                  // Error message
                  if (authState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        authState.error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Login button
                  FilledButton(
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Sign In'),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Use any Customer ID with PIN 1234',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
