import 'package:spendwise/features/transactions/data/transaction_repository.dart';
import 'package:spendwise/features/transactions/domain/transaction.dart';
import 'package:spendwise/features/transactions/domain/month_summary.dart';
import 'package:spendwise/core/security/secure_session_store.dart';

/// Fake repository for widget tests that returns data synchronously without delays.
class FakeTransactionRepository implements TransactionRepository {
  @override
  Future<TransactionPage> getTransactions({
    required String month,
    String? cursor,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    int? minAmountPaise,
    int? maxAmountPaise,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return const TransactionPage(items: [], nextCursor: null);
  }

  @override
  Future<Transaction> getTransaction(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Transaction> recategorise({
    required String transactionId,
    required String newCategoryId,
    bool applyToMerchant = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<MonthSummary> getSummary(String month) async {
    return MonthSummary.empty(month);
  }
}

/// In-memory session store for tests (avoids Keychain/Keystore platform channels).
class FakeSecureSessionStore implements SecureSessionStore {
  String? _token;
  String? _userId;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> saveUserId(String userId) async => _userId = userId;

  @override
  Future<String?> getUserId() async => _userId;

  @override
  Future<void> clearSession() async {
    _token = null;
    _userId = null;
  }

  @override
  Future<bool> hasSession() async => _token != null && _token!.isNotEmpty;
}
