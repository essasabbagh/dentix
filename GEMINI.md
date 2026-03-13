# GEMINI.md - DentixFlow Project Context

## Project Overview
**DentixFlow** is a local-first, offline-only dental clinic management system built with **Flutter Desktop (Windows/macOS)**. It is designed to manage patient records, treatments, appointments, and finances without requiring an internet connection.

- **Primary Platform:** Windows
- **Development Platform:** macOS
- **Key Features:** Interactive odontogram (tooth chart), WhatsApp integration, PDF report generation, local-first SQLite database with Drift, and a robust backup/restore system.

## Technical Stack
- **Framework:** Flutter (using FVM for version management)
- **State Management:** Riverpod (`hooks_riverpod`, `flutter_hooks`)
- **Database:** SQLite via `drift` and `sqlite3_flutter_libs`
- **Routing:** `go_router`
- **Dependency Injection:** `get_it` (Service Locator)
- **Local Storage:** `get_storage`
- **Reporting:** `pdf`, `printing`, and `fl_chart` for statistics
- **Localization:** `intl` with `flutter_intl` for multi-language support (Arabic/English)

## Project Structure
The project follows a **Feature-Based Architecture** within the `lib/` directory:

- `lib/core/`: Shared utilities, constants, database configuration, router setup, and base services.
  - `database/`: Drift database definitions and DAOs.
  - `router/`: GoRouter configuration.
  - `themes/`: Application-wide Material 3 themes and design tokens.
  - `utils/`: Logging, snackbars, and helpers.
- `lib/features/`: Contains domain-specific modules. Each feature folder typically contains:
  - `presentation/`: UI pages and widgets.
  - `providers/`: Riverpod providers.
  - `services/`: Business logic.
  - `data/`: Repositories and models (if not shared).
- `lib/components/`: Reusable UI components (buttons, forms, images, loading).
- `assets/`: 
  - `fonts/`: Cairo font family.
  - `images/`: Branding, onboarding, and empty state assets.

## Key Development Commands
- **Initialization:** `fvm flutter pub get`
- **Code Generation:** `fvm dart run build_runner build --delete-conflicting-outputs`
- **Localization:** `fvm dart run intl_utils:generate`
- **Native Splash:** `fvm dart run flutter_native_splash:create`
- **Running:** `fvm flutter run lib/main.dart`
- **Building (Windows):** `flutter build windows --release`
- **Build Scripts:** Several `.sh` scripts are available for specific tasks:
  - `android.sh`, `ios.sh`, `apk.sh`: Mobile build automation.
  - `image_compress.sh`: Asset optimization.

## Coding Conventions
- **Clean Architecture:** Prioritize separation of concerns between UI, services, and database layers.
- **State Management:** Use Riverpod for all asynchronous data and app state. Avoid standard `setState` in complex widgets.
- **Linting:** Follows `package:flutter_lints/flutter.yaml` with custom rules in `analysis_options.yaml`.
  - Prefer single quotes.
  - Require trailing commas.
  - Const constructors where possible.
- **Logging:** Use `AppLog` (in `core/utils/app_log.dart`) instead of `print` for structured, color-coded console output.
- **Routing:** Use `goNamed` for navigation to maintain decoupled path definitions.

## Database (Drift)
The system uses **Drift** for a reactive SQLite experience.
- Tables are defined in `lib/core/database/`.
- Use DAOs (Data Access Objects) within features to interact with specific tables.
- Media files (X-rays, etc.) are stored in the local file system (managed by `path_provider`), with only relative paths stored in the database.

## Design Tokens
- **Typography:** Cairo is the primary font family. Use `Theme.of(context).textTheme` for consistency.
- **Colors:** Harmonious palettes are generated using `ColorScheme.fromSeed` in `lib/core/themes/`.
- **Gradients:** Custom gradients are defined in `AppGradient` (see `README.md`).
