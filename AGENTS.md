# AGENTS.md - Dentix Flutter Project Guidelines

This file provides guidelines for agentic coding agents working in this repository.

## Project Overview

- **Type**: Flutter Desktop/Mobile Dental Clinic Management System (DentixFlow)
- **State Management**: Riverpod + flutter_hooks
- **Database**: Drift (SQLite ORM)
- **Routing**: go_router
- **Primary Language**: Arabic (RTL support required)

## Build Commands

### Flutter SDK Management (FVM)
```bash
# Use the correct Flutter version
fvm use

# Run Flutter commands with FVM
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run lib/main.dart
```

### Install Dependencies
```bash
fvm flutter pub get
```

### Generate Code
```bash
# Drift database code generation (after modifying tables/DAOs)
fvm dart run build_runner build --delete-conflicting-outputs

# Localization (ARB files -> generated code)
fvm dart run intl_utils:generate

# App icons
fvm dart run flutter_launcher_icons:generate

# Rename app
fvm dart run rename_app:main all="Dentix"

# Native splash screen
fvm dart run flutter_native_splash:create
```

### Run Application
```bash
fvm flutter run lib/main.dart
```

### Build Releases
```bash
# Android APK (uses scripts/apk.sh)
sh apk.sh

# Android AAB Bundle (uses scripts/android.sh)
sh android.sh

# iOS (uses scripts/ios.sh)
sh ios.sh
```

## Lint & Analyze Commands

### Full Analysis
```bash
fvm flutter analyze
```

### Single File Analysis
```bash
fvm dart analyze lib/features/patients/models/patient_model.dart
```

### Run a Single Test
```bash
fvm flutter test test/path/to/test_file_test.dart
```

### Run Tests with Coverage
```bash
fvm flutter test --coverage
```

### Dependency Validation
```bash
fvm dart run dependency_validator
```

## Code Style Guidelines

### File Structure
- Use relative imports within the project: `import '../models/patient_model.dart';`
- Use package imports for core packages: `import 'package:dentix/core/...';`
- File names: `snake_case.dart`
- Widget files in `pages/` folder
- Widget components in `widgets/` folder

### Linting Rules (from analysis_options.yaml)
- Single quotes for strings: `prefer_single_quotes: true`
- Trailing commas: `require_trailing_commas: true`
- Const constructors: `prefer_const_constructors: true`
- Const declarations: `prefer_const_declarations: true`
- Sort constructors first: `sort_constructors_first: true`
- Use key in widget constructors: `use_key_in_widget_constructors: true`
- Page width: 80 characters

### Dart Style Conventions

#### Naming
- Classes: `PascalCase` (e.g., `PatientModel`)
- Variables/functions: `camelCase` (e.g., `firstName`, `getPatientById`)
- Private members: `_underscorePrefix` (e.g., `_repository`)
- Constants: `camelCase` (e.g., `maxRetries`)
- Enums: `PascalCase` values (e.g., `AlertDialogType.error`)

#### Imports Order
1. Dart SDK imports
2. Flutter/Third-party package imports
3. Project package imports (`package:dentix/...`)
4. Relative imports
5. Use `// ignore_for_file` sparingly

#### Model Classes
```dart
class PatientModel {
  const PatientModel({
    required this.id,
    required this.firstName,
    // ...
  });

  final int id;
  final String firstName;
  // ...

  /// Computed property with doc comment
  String get fullName => '$firstName $lastName';

  PatientModel copyWith({
    int? id,
    String? firstName,
    // ...
  }) {
    return PatientModel(
      id: id ?? this.id,
      // ...
    );
  }
}
```

#### Providers (Riverpod)
```dart
// Repository provider
final patientsRepositoryProvider = Provider<PatientsRepository>((ref) {
  return PatientsRepository(ref.watch(appDatabaseProvider));
});

// Service provider
final patientsServiceProvider = Provider<PatientsService>((ref) {
  return PatientsService(ref.watch(patientsRepositoryProvider));
});

// Stream provider for reactive data
final patientsListProvider = StreamProvider<List<PatientModel>>((ref) {
  return ref.watch(patientsServiceProvider).watchAllPatients();
});

// Family provider for parameterized access
final patientByIdProvider = StreamProvider.family<PatientModel?, int>(
  (ref, id) => ref.watch(patientsServiceProvider).watchPatientById(id),
);

// StateNotifier for forms/mutations
class PatientFormNotifier extends StateNotifier<AsyncValue<void>> {
  PatientFormNotifier(this._service) : super(const AsyncValue.data(null));

  final PatientsService _service;

  Future<bool> createPatient({...}) async {
    state = const AsyncValue.loading();
    try {
      await _service.createPatient(...);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
```

#### Repository Pattern
```dart
class PatientsRepository {
  PatientsRepository(this._db);
  final AppDatabase _db;

  // ─── Mappers ───────────────────────────────────────────────

  PatientModel _fromData(PatientsTableData d) => PatientModel(
    id: d.id,
    // ...
  );

  // ─── Read ──────────────────────────────────────────────────

  Future<List<PatientModel>> getAllPatients() async {
    final rows = await _db.patientsDao.getAllPatients();
    return rows.map(_fromData).toList();
  }

  Stream<List<PatientModel>> watchAllPatients() =>
      _db.patientsDao.watchAllPatients().map((rows) => rows.map(_fromData).toList());

  // ─── Write ─────────────────────────────────────────────────

  Future<int> createPatient({...}) => _db.patientsDao.insertPatient(...);
}
```

#### Service Layer
```dart
class PatientsService {
  PatientsService(this._repository);
  final PatientsRepository _repository;

  // Validation should throw descriptive exceptions in Arabic
  void _validatePatient({required String firstName, ...}) {
    if (firstName.trim().isEmpty) {
      throw Exception('الاسم الأول مطلوب');
    }
    // ...
  }
}
```

#### Widgets
```dart
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      // ...
    );
  }
}
```

#### Drift Tables
```dart
class PatientsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstName => text().named('first_name')();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  String get tableName => 'patients';

  @override
  List<Index> get indexes => [
    Index('patients_phone_idx', 'CREATE INDEX patients_phone_idx ON patients(phone)'),
  ];
}
```

#### Drift DAOs
```dart
@DriftAccessor(tables: [PatientsTable])
class PatientsDao extends DatabaseAccessor<AppDatabase> with _$PatientsDaoMixin {
  PatientsDao(super.db);

  Future<List<PatientsTableData>> getAllPatients() => (select(patientsTable)
    ..orderBy([(t) => OrderingTerm(expression: t.lastName)]))
    .get();

  Stream<List<PatientsTableData>> watchAllPatients() => (select(patientsTable)
    ..orderBy([(t) => OrderingTerm(expression: t.lastName)]))
    .watch();

  Future<int> insertPatient(PatientsTableCompanion patient) =>
      into(patientsTable).insert(patient);
}
```

#### Enums
```dart
/// Describes the type of alert dialog, affecting icon and colors.
enum AlertDialogType {
  /// Error dialog with red theme.
  error,

  /// Warning dialog with orange theme.
  warning,

  /// Info dialog with primary theme color.
  info,

  /// Success dialog with green theme.
  success,
}
```

### Error Handling
- Use `try-catch` blocks with `AsyncValue` for async operations
- Throw descriptive exceptions (preferably in Arabic for user-facing messages)
- Use `AsyncValue.error(e, st)` for error states in StateNotifiers

### Documentation
- Add doc comments for public classes and methods
- Use `///` for documentation, not `//`
- Exclude generated files from public_member_api_docs

### Excluded from Analysis
- `build/**`
- `lib/core/locale/generated`
- `test/_data/**`

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # MaterialApp configuration
├── initialize_app.dart          # App initialization
├── configs/                     # App-wide configurations
│   └── app_configs.dart
├── core/                        # Shared utilities
│   ├── constants/
│   ├── database/                # Drift database, tables, DAOs
│   ├── enums/                   # Enum definitions
│   ├── errors/
│   ├── extensions/
│   ├── locale/                  # i18n (ARB files + generated)
│   ├── pagination/
│   ├── router/                  # go_router configuration
│   ├── themes/                 # App themes, colors, styles
│   └── utils/
├── components/                  # Reusable UI components
│   ├── buttons/
│   ├── form/
│   ├── images/
│   ├── loading/
│   ├── main/                    # Main app components (drawer, appbar)
│   └── ui/
└── features/                    # Feature modules
    ├── appointments/
    ├── assets/
    ├── dashboard/
    ├── odontogram/
    ├── patients/
    ├── payments/
    ├── reports/
    ├── root/
    ├── settings/
    ├── splash/
    ├── statics/
    └── treatments/

    Each feature follows:
    ├── data/                    # Repository
    ├── models/                  # Domain models
    ├── pages/                   # Screen widgets
    ├── providers/               # Riverpod providers
    ├── services/                # Business logic
    └── widgets/                 # Feature-specific widgets
```

## Architecture

- **Presentation**: Widgets, Pages, Riverpod Providers
- **Services**: Business logic, validation, orchestration
- **Repositories**: Data access abstraction, mappers
- **Database**: Drift tables and DAOs
- **Models**: Domain models (separate from database entities)

Flow: `Widget → Provider → Service → Repository → DAO → Database`
