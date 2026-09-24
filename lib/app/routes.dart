/// Centralised route path constants for SpendWise.
/// Using constants prevents typos and makes refactoring safe.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String overview = '/overview';
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transactions/:id';
  static const String budgets = '/budgets';
  static const String budgetEdit = '/budgets/:category';
  static const String merchants = '/merchants';
  static const String merchantDetail = '/merchants/:id';
}
