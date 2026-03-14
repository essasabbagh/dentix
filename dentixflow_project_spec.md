# DentixFlow -- Offline Dental Management System

## 1. Project Overview

DentixFlow is a **local-first dental clinic management system** built
using **Flutter Desktop (Windows)**.\
The application is designed to run **100% offline**, allowing dental
clinics to manage patients, treatments, finances, and medical records
without requiring internet connectivity.

### Key Goals

-   Fully **offline operation**
-   **Fast and responsive** local database
-   **Portable backup & restore**
-   Easy **WhatsApp sharing**
-   **Professional dental odontogram (tooth chart)**
-   **Simple deployment for clinics**

Target platform: - Primary: **Windows** - Development: **macOS** -
Technology: **Flutter Desktop**

------------------------------------------------------------------------

# 2. Technical Stack

## Core Technologies

-   **Flutter Desktop**
-   **Dart**
-   **SQLite database**
-   **Clean Architecture**

## Main Packages

### Database

-   drift
-   sqlite3_flutter_libs

### State Management

-   flutter_riverpod

### Charts & Statistics

-   fl_chart

### File Management

-   path_provider
-   file_picker

### Communication

-   url_launcher
-   share_plus

### PDF & Printing

-   pdf
-   printing

### Utilities

-   uuid
-   intl

------------------------------------------------------------------------

# 3. Project Architecture

The system follows **Clean Architecture** to ensure scalability and
maintainability.

    lib/
     ├ core/
     │   ├ database/
     │   ├ services/
     │   ├ utils/
     │   └ constants/
     │
     ├ features/
     │   ├ patients/
     │   ├ odontogram/
     │   ├ payments/
     │   ├ appointments/
     │   ├ reports/
     │   └ media/
     │
     ├ data/
     │   ├ datasources/
     │   ├ models/
     │   └ repositories/
     │
     ├ domain/
     │   ├ entities/
     │   ├ repositories/
     │   └ usecases/
     │
     └ presentation/
         ├ pages/
         ├ widgets/
         └ providers/

### Layer Responsibilities

**Core** - shared utilities - database configuration - backup services

**Data** - database tables - models - repository implementations

**Domain** - business logic - entities - use cases

**Presentation** - UI - Riverpod providers - widgets

------------------------------------------------------------------------

# 4. Database Design (Drift)

## Patients

Stores patient information.

Fields:

-   id
-   name
-   phone
-   birthdate
-   medical_history
-   allergies
-   notes
-   created_at

------------------------------------------------------------------------

## Appointments

-   id
-   patient_id
-   date
-   status
-   notes

------------------------------------------------------------------------

## Treatments (Reference Table)

Defines available dental treatments.

Fields:

-   id
-   name
-   default_price
-   color

Example:

-   Filling
-   Cleaning
-   Crown
-   Extraction

------------------------------------------------------------------------

## ToothTreatments

Stores procedures applied to teeth.

Fields:

-   id
-   patient_id
-   tooth_number (1-32)
-   treatment_type
-   status
-   notes
-   cost
-   date

Allows **multiple treatments per tooth**.

------------------------------------------------------------------------

## Payments

Tracks financial transactions.

Fields:

-   id
-   patient_id
-   treatment_id
-   amount
-   payment_date
-   notes
-   created_at

------------------------------------------------------------------------

## MediaFiles

Stores references to X-rays and reports.

Fields:

-   id
-   patient_id
-   file_path
-   file_type
-   date

------------------------------------------------------------------------

## Settings

Clinic configuration.

Fields:

-   clinic_name
-   clinic_phone
-   clinic_address
-   currency
-   logo_path

------------------------------------------------------------------------

# 5. File Storage Structure

DentixFlow uses a local directory structure.

Example:

    DentixFlow/
       dentix.db
       media/
          patient_1/
             xray_a23f.png
       backups/

Media files are stored locally.

The database stores **relative paths** only.

------------------------------------------------------------------------

# 6. Interactive Tooth Chart

The odontogram is implemented using **CustomPainter**.

### Tooth Layout

32 permanent teeth arranged in dental arch.

Each tooth is represented as a **Path object**.

Example mapping:

    Map<int, Path> toothPaths

### Interaction

User tap detection:

1.  User taps screen
2.  Convert tap to canvas coordinate
3.  Check:

```{=html}
<!-- -->
```
    if (path.contains(tapPosition))

4.  Identify clicked tooth

### Tooth Status Colors

-   Healthy → White
-   Planned Treatment → Blue
-   Completed Treatment → Green
-   Extracted → Red

------------------------------------------------------------------------

# 7. Media Management (X-rays)

When a user adds an X-ray:

1.  Pick file using **file_picker**
2.  Copy file into:

```{=html}
<!-- -->
```
    /DentixFlow/media/patient_ID/

3.  Save path in database

Example:

    media/patient_12/xray_23.png

------------------------------------------------------------------------

# 8. Backup & Restore System

## Backup

The system creates a ZIP file containing:

    dentix.db
    /media
    /settings.json

Example backup file:

    dentix_backup_2026_03_12.zip

Backup can be saved to:

-   Desktop
-   USB drive

------------------------------------------------------------------------

## Restore

Steps:

1.  User selects backup ZIP
2.  Extract files
3.  Replace local database and media folder

------------------------------------------------------------------------

# 9. WhatsApp Integration

## Send Text

Using url_launcher:

    whatsapp://send?phone=PHONE&text=MESSAGE

## Send Files

Steps:

1.  Generate PDF invoice
2.  Save temporary file
3.  Use share_plus

User chooses **WhatsApp Desktop**.

------------------------------------------------------------------------

# 10. PDF Reports

Generated using **pdf** and **printing** packages.

Available reports:

-   Invoice
-   Patient treatment history
-   Daily revenue
-   Monthly revenue
-   Treatment statistics

------------------------------------------------------------------------

# 11. Dashboard

The dashboard displays clinic statistics using **fl_chart**.

Examples:

-   Patients today
-   Monthly revenue
-   Treatment distribution
-   Appointment statistics

------------------------------------------------------------------------

# 12. Security

To protect patient data:

-   Optional **SQLite encryption**
-   Local-only storage
-   No cloud dependency

------------------------------------------------------------------------

# 13. Build & Deployment

## Development

Develop on macOS using Flutter.

Test with macOS target.

## Windows Build

    flutter build windows --release

Output:

    build/windows/runner/Release/

------------------------------------------------------------------------

## Installer Creation

Recommended tool:

**Inno Setup**

Installer features:

-   Install application
-   Create desktop shortcut
-   Create DentixFlow folder

------------------------------------------------------------------------

# 14. Future Enhancements

Potential advanced features:

-   Appointment calendar
-   Dark mode
-   Treatment templates
-   Advanced reports
-   Multi-user login
-   Cloud sync option
-   AI X-ray analysis

------------------------------------------------------------------------

# 15. Summary

DentixFlow provides:

-   Offline-first dental management
-   Fast local database
-   Interactive odontogram
-   Patient record management
-   Financial tracking
-   Portable backup system

The architecture ensures the project remains **scalable, maintainable,
and production-ready for dental clinics**.
