# DentixFlow -- Project Architecture & Database Plan

## Overview

DentixFlow is a desktop dental clinic management system built with: -
Flutter - Drift (SQLite ORM) - GoRouter - Riverpod

The application is designed to be modular, scalable, and maintainable.\
Each feature module owns its UI, service layer, repository layer, and
database access.

------------------------------------------------------------------------

# Application Modules

Main modules:

-   Dashboard
-   Patients
-   Appointments
-   Treatments
-   Odontogram
-   Payments
-   Reports
-   Settings

Each module includes:

-   Presentation (UI)
-   Services
-   Repositories
-   Database DAO
-   Models

------------------------------------------------------------------------

# Global Project Structure

    lib

    core
        database
        router
        services
        constants
        utils

    features
        dashboard
        patients
        appointments
        treatments
        odontogram
        payments
        reports
        settings

    components
        main
        form

------------------------------------------------------------------------

# Database Architecture

Database engine: SQLite using Drift

Database file:

    dentixflow.db

Tables are organized by domain:

    patients_tables
    appointments_tables
    treatments_tables
    payments_tables
    odontogram_tables
    settings_tables

------------------------------------------------------------------------

# Database Schema

## Patients Table

Purpose: store clinic patient records.

Fields:

-   id
-   first_name
-   last_name
-   phone
-   email
-   gender
-   birth_date
-   address
-   notes
-   created_at
-   updated_at

Relationships:

-   patient → appointments
-   patient → treatments
-   patient → payments
-   patient → odontogram records

Indexes:

-   phone
-   last_name

------------------------------------------------------------------------

## Appointments Table

Purpose: manage clinic scheduling.

Fields:

-   id
-   patient_id
-   appointment_date
-   status
-   doctor_name
-   notes
-   created_at
-   updated_at

Status enum:

-   scheduled
-   completed
-   cancelled
-   no_show

Indexes:

-   appointment_date
-   patient_id

------------------------------------------------------------------------

## Treatments Table

Purpose: store treatment records.

Fields:

-   id
-   patient_id
-   appointment_id
-   treatment_type
-   tooth_number
-   price
-   status
-   notes
-   created_at
-   updated_at

Status:

-   planned
-   in_progress
-   completed
-   cancelled

Relationships:

-   treatment → patient
-   treatment → appointment
-   treatment → tooth

------------------------------------------------------------------------

## Odontogram Table

Purpose: track tooth status for each patient.

Fields:

-   id
-   patient_id
-   tooth_number
-   condition
-   treatment_type
-   notes
-   updated_at

Tooth numbers:

1 -- 32

Condition enum:

-   healthy
-   decay
-   missing
-   filled
-   crown
-   implant
-   root_canal

Used for the interactive odontogram UI.

------------------------------------------------------------------------

## Payments Table

Purpose: manage billing and payment history.

Fields:

-   id
-   patient_id
-   treatment_id
-   amount
-   payment_status
-   payment_date
-   notes
-   created_at

Status:

-   paid
-   pending
-   partial

------------------------------------------------------------------------

## Settings Table

Purpose: store clinic configuration.

Fields:

-   key
-   value
-   updated_at

Primary key:

key

Example settings:

-   clinic_name
-   clinic_phone
-   clinic_address
-   currency
-   theme_mode
-   language

------------------------------------------------------------------------

# Service Layer Architecture

Every module has one main service responsible for business logic.

Services interact with:

-   repositories
-   database layer
-   domain rules

------------------------------------------------------------------------

## Patients Service

Responsibilities:

-   create patient
-   update patient
-   delete patient
-   search patients
-   load patient history

Operations:

-   register patient
-   edit patient information
-   view patient treatments
-   view patient payments

------------------------------------------------------------------------

## Appointments Service

Responsibilities:

-   create appointment
-   update appointment
-   cancel appointment
-   view schedule

Operations:

-   schedule visit
-   reschedule visit
-   cancel visit
-   get daily appointments

------------------------------------------------------------------------

## Treatments Service

Responsibilities:

-   create treatment
-   update treatment
-   complete treatment
-   calculate cost

Operations:

-   add treatment
-   edit treatment
-   complete treatment
-   treatment history

------------------------------------------------------------------------

## Odontogram Service

Responsibilities:

-   load patient teeth
-   update tooth condition
-   add dental procedure

Operations:

-   click tooth
-   show treatments
-   add dental procedure
-   update tooth status

------------------------------------------------------------------------

## Payments Service

Responsibilities:

-   create payment
-   update payment
-   calculate balance
-   generate invoice

Operations:

-   pay treatment
-   partial payment
-   refund
-   payment history

------------------------------------------------------------------------

## Reports Service

Responsibilities:

-   income reports
-   treatment statistics
-   patient statistics
-   appointment reports

Operations:

-   daily revenue
-   monthly revenue
-   top treatments
-   clinic performance

------------------------------------------------------------------------

## Settings Service

Responsibilities:

-   save settings
-   read settings
-   update settings

Operations:

-   change theme
-   update clinic information
-   configure preferences

------------------------------------------------------------------------

# Repository Layer

Repositories act as data mediators between services and database.

Flow:

Service → Repository → Drift DAO → Database

Example:

PatientsService → PatientsRepository → PatientsDao → Database

------------------------------------------------------------------------

# Feature Module Structure

Example: patients module

    features/patients

    data
        patients_repository

    services
        patients_service

    database
        patients_dao
        patients_tables

    models
        patient_model

    presentation
        pages
        widgets
        providers

------------------------------------------------------------------------

# State Management

Riverpod providers are used for state handling.

Examples:

-   patientsServiceProvider
-   patientsListProvider
-   patientDetailsProvider

------------------------------------------------------------------------

# Dashboard Module

Displays aggregated data such as:

-   today appointments
-   monthly revenue
-   total patients
-   treatment statistics

Data sources:

-   appointments
-   payments
-   treatments
-   patients

------------------------------------------------------------------------

# Performance Strategy

Use Drift reactive queries:

-   watchPatients()
-   watchAppointments()
-   watchPayments()

This allows UI to update automatically when data changes.

------------------------------------------------------------------------

# Future Scalability

Architecture supports:

-   multi-doctor clinics
-   AI diagnosis support
-   cloud backup
-   multi-device synchronization

------------------------------------------------------------------------

# Development Phases

Phase 1

-   database schema
-   patients module
-   appointments module

Phase 2

-   treatments
-   odontogram
-   payments

Phase 3

-   reports
-   dashboard
-   settings

Phase 4

-   analytics
-   backups
-   advanced reporting

------------------------------------------------------------------------

End of document.
