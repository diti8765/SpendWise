# SpendWise — Expense Analytics & Monthly Budgets

SpendWise is a personal finance Flutter application built as a Capstone project. It provides automated expense categorisation, monthly and category spending charts, monthly budgets with threshold alerts, merchant insights, and an instant recategorisation flow that learns from user corrections.

---

## 🏛 Architecture

SpendWise strictly follows the 4-layer architecture defined in the reference specification:

```
Flutter App
│
├── Presentation
│   ├── Screens (Overview, Feed, Transaction Detail, Budgets, Budget Edit, Merchants, Merchant Detail)
│   ├── Widgets (Charts, Cards, Skeletons, Bottom Sheets)
│   └── go_router with session-driven guard
│
├── State
│   ├── Riverpod Providers & AsyncNotifiers
│   └── Family providers for month, feed, summaries
│
├── Data
│   ├── Repositories (Transaction, Budget, Merchant, Auth)
│   ├── Models (fromJson / toJson at the data boundary)
│   └── Aggregator (Pure Dart, isolate-ready for large datasets)
│
└── Core
    ├── Errors (Sealed BankError hierarchy & ErrorMapper)
    ├── Network (Dio, interceptors, ApiConfig)
    ├── Security (SecureSessionStore, BiometricService, AppLock)
    ├── Utils (Money in paise, AppDateFormat, Validators)
    ├── Cache (CacheManager for 3-month offline support)
    ├── Motion (Reduce-motion aware animations)
    └── Shared Widgets (Skeleton, AsyncErrorView, EmptyState)
```

### Architectural Rules
- **No Dio in Widgets**: Screens and widgets communicate exclusively via Riverpod providers and repositories.
- **Integer Paise for Money**: Floats are never used for currency. All values are stored as integer paise (`amountPaise`).
- **ISO-8601 UTC Dates**: Dates are parsed into local time once, at the model boundary.
- **Sealed BankError**: Raw HTTP errors or stack traces are never exposed to the UI.
- **Three States Everywhere**: Every network-backed screen handles Loading (skeleton), Error (with retry), and Empty states.

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.47.4 or later
- **Dart SDK**: 3.13.3 or later

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd flutter_application_1

# Install dependencies
flutter pub get
```

### Running the App

The app includes built-in mock repositories with realistic transaction data across multiple months, so it runs completely standalone without needing an external backend:

```bash
# Run with default mock backend
flutter run

# Run with a custom API URL via --dart-define
flutter run --dart-define=API_BASE_URL=https://api.spendwise.example.com
```

### Demo Login Credentials
- **Customer ID**: Any string with 4+ characters (e.g. `ANANYA`)
- **PIN**: `1234`

---

## 🧪 Testing

The project includes unit tests for business logic and widget tests for key screens:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run analyzer
flutter analyze

# Verify code formatting
dart format --set-exit-if-changed .
```

### Test Coverage Highlights
- **Money Utility**: Safe arithmetic, paise formatting, parsing, Indian numbering system.
- **Aggregator**: Pure Dart calculations for category totals, daily trends, merchant aggregation, month-over-month percentage change.
- **Budget Logic**: Threshold warnings (80% amber, 100% red), remaining balance, single-alert-per-month logic.
- **Filter State**: Multi-filter combination, badge counts, clearing logic.
- **Models**: JSON serialization round-trips for all entities.
- **Error Mapping**: Mapping `DioException` types and HTTP status codes into `BankError`.
- **Widget Tests**: Smoke test, Login screen, Feed screen, Budgets screen, Merchants screen, Overview screen.

---

## 📁 Folder Structure

```
lib/
├── main.dart
│
├── app/
│   ├── app.dart              # Root MaterialApp with theme & router
│   ├── router.dart           # go_router with auth redirect guard & shell
│   ├── routes.dart           # Route constants
│   └── theme.dart            # Material 3 green theme & category colours
│
├── core/
│   ├── cache/                # CacheManager (offline storage)
│   ├── errors/               # BankError sealed classes & ErrorMapper
│   ├── motion/               # Reduce-motion aware animations
│   ├── network/              # Dio, ApiConfig, auth & error interceptors
│   ├── notifications/        # Budget alert threshold service
│   ├── security/             # Secure storage, biometrics, app lock
│   ├── utils/                # Money (paise), DateFormat, Validators
│   └── widgets/              # AsyncErrorView, Skeleton, EmptyState
│
└── features/
    ├── auth/                 # Login, session restore, token storage
    ├── overview/             # Monthly overview, donut chart, daily trend
    ├── transactions/         # Feed, detail, recategorisation, aggregator
    ├── budgets/              # Budget list, progress bars, edit/create
    ├── merchants/            # Insights, rules, detail view
    └── filters/              # Filter sheet, state notifier
```

---

## 🔒 Security & Privacy
- Tokens are stored using Keychain / Keystore via `flutter_secure_storage`.
- PINs are never stored or logged in plaintext.
- App lock triggers when the app moves to the background, requiring biometric / device PIN unlock.
- Network logging automatically strips Authorization headers.

---

## 📄 License
This project is part of a Flutter Capstone assessment.
