# GitHub Copilot Instructions - EBSA Nexus Mobile Application

## Project Context
You are working on **EBSA Nexus**, a mobile incident reporting system for EBSA S.A.E.S.P. workers. The application allows field workers, contractors, and area managers to create, manage, and track incident reports with multimedia evidence (photos, videos, audio) and GPS data.

## Technology Stack
- **Flutter Version**: 3.35.5
- **Language**: Dart
- **Architecture**: Clean Architecture
- **State Management**: Riverpod (preferred) or Provider
- **Local Storage**: Drift (SQLite) for offline support
- **HTTP Client**: Dio
- **Key Features**: Offline-first, multimedia capture, GPS tracking, real-time sync

---

## Folder Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   └── storage_constants.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   │
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   │
│   ├── network/
│   │   ├── network_info.dart
│   │   └── api_client.dart
│   │
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── extensions.dart
│   │
│   └── widgets/
│       ├── loading_indicator.dart
│       ├── error_widget.dart
│       ├── empty_state_widget.dart
│       └── custom_button.dart
│
├── features/
│   │
│   ├── authentication/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── credentials_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user.dart
│   │   │   │   └── credentials.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   │
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── splash_page.dart
│   │       ├── widgets/
│   │       │   ├── login_form.dart
│   │       │   └── password_field.dart
│   │       └── providers/
│   │           └── auth_provider.dart
│   │
│   ├── reports/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── report_remote_datasource.dart
│   │   │   │   └── report_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── report_model.dart
│   │   │   │   ├── evidence_model.dart
│   │   │   │   └── gps_location_model.dart
│   │   │   └── repositories/
│   │   │       └── report_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── report.dart
│   │   │   │   ├── evidence.dart
│   │   │   │   └── gps_location.dart
│   │   │   ├── repositories/
│   │   │   │   └── report_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_report_usecase.dart
│   │   │       ├── get_reports_usecase.dart
│   │   │       ├── update_report_usecase.dart
│   │   │       ├── sync_reports_usecase.dart
│   │   │       └── attach_evidence_usecase.dart
│   │   │
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── report_list_page.dart
│   │       │   ├── create_report_page.dart
│   │       │   └── report_detail_page.dart
│   │       ├── widgets/
│   │       │   ├── report_card.dart
│   │       │   ├── evidence_picker.dart
│   │       │   ├── gps_indicator.dart
│   │       │   ├── report_form.dart
│   │       │   └── sync_status_indicator.dart
│   │       └── providers/
│   │           ├── report_list_provider.dart
│   │           ├── create_report_provider.dart
│   │           └── sync_provider.dart
│   │
│   ├── incidents/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── incident_remote_datasource.dart
│   │   │   │   └── incident_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── incident_model.dart
│   │   │   └── repositories/
│   │   │       └── incident_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── incident.dart
│   │   │   ├── repositories/
│   │   │   │   └── incident_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_incident_types_usecase.dart
│   │   │       └── classify_incident_usecase.dart
│   │   │
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── incident_selector_page.dart
│   │       ├── widgets/
│   │       │   └── incident_type_card.dart
│   │       └── providers/
│   │           └── incident_provider.dart
│   │
│   ├── work_crews/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── crew_remote_datasource.dart
│   │   │   │   └── crew_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── work_crew_model.dart
│   │   │   └── repositories/
│   │   │       └── crew_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── work_crew.dart
│   │   │   ├── repositories/
│   │   │   │   └── crew_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_available_crews_usecase.dart
│   │   │       └── assign_crew_usecase.dart
│   │   │
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── crew_assignment_page.dart
│   │       ├── widgets/
│   │       │   └── crew_selector.dart
│   │       └── providers/
│   │           └── crew_provider.dart
│   │
│   └── notifications/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── notification_local_datasource.dart
│       │   ├── models/
│       │   │   └── notification_model.dart
│       │   └── repositories/
│       │       └── notification_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   └── notification.dart
│       │   ├── repositories/
│       │   │   └── notification_repository.dart
│       │   └── usecases/
│       │       ├── get_notifications_usecase.dart
│       │       └── mark_notification_read_usecase.dart
│       │
│       └── presentation/
│           ├── pages/
│           │   └── notifications_page.dart
│           ├── widgets/
│           │   └── notification_card.dart
│           └── providers/
│               └── notification_provider.dart
│
└── config/
    ├── routes/
    │   ├── app_router.dart
    │   └── route_names.dart
    │
    ├── dependency_injection/
    │   └── injection_container.dart
    │
    └── database/
        ├── app_database.dart
        └── database_tables.dart
```

---

## Architecture Principles - Clean Architecture

### Layer Independence (Dependency Rule)
- **Domain layer** has NO dependencies on any other layer
- **Data layer** depends ONLY on domain layer
- **Presentation layer** depends ONLY on domain layer (through use cases)
- Dependencies point INWARD: Presentation → Domain ← Data
- External frameworks (Flutter, packages) stay in outer layers

### Domain Layer (Business Logic Core)
- Contains pure Dart business entities with no external dependencies
- Defines abstract repository interfaces (contracts)
- Houses single-responsibility use cases
- Represents the "what" the system does, not "how"
- Must be framework-agnostic and testable in isolation
- No import of Flutter, Dio, Drift, or any external package

### Data Layer (Implementation Details)
- Implements domain repository interfaces
- Manages data sources (remote API, local database)
- Handles data transformation (models ↔ entities)
- Manages offline/online logic and synchronization
- Deals with caching strategies
- Can import external packages (Dio, Drift)

### Presentation Layer (UI & User Interaction)
- Displays information to users
- Captures user input
- Manages UI state through providers/notifiers
- Communicates with domain through use cases only
- Never directly accesses repositories or data sources
- Can import Flutter and UI packages

---

## Design Patterns

### Repository Pattern
- Abstracts data source details from business logic
- Provides single interface for multiple data sources
- Enables easy switching between local/remote storage
- Facilitates offline-first architecture
- Critical for testing (easy mocking)
- Handles synchronization logic transparently

### Factory Method Pattern
- Creates complex domain objects consistently
- Ensures all required metadata is attached (GPS, timestamp, user ID)
- Centralizes object creation logic
- Prevents instantiation errors
- Used for Reports, Evidence, and other complex entities

### Observer Pattern (via State Management)
- Enables reactive UI updates
- Decouples event producers from consumers
- Supports multiple listeners per event
- Facilitates notification system
- Implements through Riverpod/Provider notifications
- Critical for sync status updates

---

## Offline-First Strategy

### Core Principles
- Local database is source of truth
- All write operations go to local storage first
- Background sync attempts when connectivity available
- UI never blocks waiting for network
- Optimistic updates with rollback on failure
- Sync queue for pending operations

### Data Flow
1. User action → Save locally immediately
2. Queue operation for sync
3. Show success to user instantly
4. Background: Attempt sync with server
5. On success: Mark as synced
6. On failure: Retry with exponential backoff
7. Conflict resolution when necessary

### Implementation Requirements
- Every repository must handle offline scenarios
- Sync status tracked per entity
- Network connectivity monitoring
- Periodic background sync jobs
- User-initiated manual sync option
- Clear visual indicators of sync status

---

## Error Handling Philosophy

### Functional Error Handling
- Use Either<Failure, Success> pattern (dartz package)
- Never throw exceptions in domain/data layers
- Return typed failures for better handling
- Centralize failure types (ServerFailure, CacheFailure, ValidationFailure)
- Let presentation layer decide how to display errors

### Failure Types
- **Server Failures**: Network errors, API errors, timeouts
- **Cache Failures**: Local database errors, storage full
- **Validation Failures**: Business rule violations
- **Authentication Failures**: Token expired, unauthorized
- **GPS Failures**: Location disabled, permission denied

---

## State Management Guidelines

### Riverpod/Provider Principles
- One provider per use case or feature state
- Providers should be small and focused
- Use StateNotifier for complex state
- Leverage family modifiers for parameterized providers
- Implement loading, success, and error states
- Auto-dispose providers when not in use

### State Structure
- **Idle**: Initial state, no operation in progress
- **Loading**: Operation in progress, show spinner
- **Success**: Operation completed, show data
- **Error**: Operation failed, show error message
- Always maintain previous data during refresh

---

## Testing Strategy

### Unit Tests (Required)
- All use cases must have unit tests
- Test business logic in isolation
- Mock repositories and data sources
- Test error scenarios and edge cases
- Validate state transformations

### Widget Tests (Required)
- Test complex widgets in isolation
- Mock providers with fake data
- Test user interactions
- Verify correct UI states (loading, error, success)

### Integration Tests (Recommended)
- Test complete user flows
- Verify offline functionality
- Test sync mechanisms
- Validate data persistence

---

## Performance Best Practices

### Memory Management
- Dispose controllers and providers properly
- Avoid memory leaks in listeners
- Use const constructors for immutable widgets
- Implement pagination for large lists
- Lazy load images and media

### Rendering Optimization
- Use ListView.builder, not ListView with children
- Implement RepaintBoundary for expensive widgets
- Cache network images
- Use keys for list items
- Avoid rebuilding entire trees

### Background Operations
- Use Isolates for heavy computations
- Compress images before upload
- Process media in background
- Schedule sync during idle time
- Implement proper cancellation

---

## Security Guidelines

### Data Protection
- Never store credentials in plain text
- Use flutter_secure_storage for sensitive data
- Encrypt local database if required
- Sanitize all user inputs
- Validate data before persistence

### Network Security
- Use HTTPS only
- Implement certificate pinning
- Handle authentication tokens securely
- Implement token refresh mechanism
- Never log sensitive information

### Permission Handling
- Request permissions at appropriate time
- Handle permission denial gracefully
- Explain why permissions are needed
- Provide fallbacks for denied permissions

---

## Code Quality Standards

### Naming Conventions
- Files: snake_case.dart
- Classes: PascalCase
- Functions/Variables: camelCase
- Constants: kPascalCase or SCREAMING_SNAKE_CASE
- Private members: prefix with underscore

### Code Organization
- One class per file (exceptions for small helpers)
- Group related files in same directory
- Use barrel files (index.dart) sparingly
- Keep files under 300 lines when possible
- Extract complex logic into separate functions

### Documentation
- Document public APIs with dartdoc comments
- Explain "why" not "what" in comments
- Document business rules in use cases
- Keep README files updated
- Document architecture decisions

### Immutability
- Prefer const constructors
- Use final for all class fields
- Implement copyWith methods
- Use Equatable for value comparison
- Avoid mutable state in domain

---

## Critical Rules

1. **NEVER import Flutter in domain layer**
2. **ALWAYS use dependency injection** (get_it)
3. **ALWAYS handle offline scenarios** in repositories
4. **NEVER bypass use cases** in presentation layer
5. **ALWAYS use Either for error handling**
6. **ALWAYS add GPS coordinates** to reports
7. **ALWAYS add timestamps** to entities
8. **NEVER hardcode strings** (use constants/l10n)
9. **ALWAYS implement proper loading states**
10. **NEVER mix business logic in widgets**

---

## Workflow: Creating a New Feature

1. **Define domain entities** (pure Dart classes)
2. **Create repository interface** (abstract class)
3. **Write use cases** (business logic)
4. **Create models** (data layer, extends entities)
5. **Implement data sources** (remote + local)
6. **Implement repository** (coordinates sources)
7. **Create providers** (state management)
8. **Build UI** (pages and widgets)
9. **Register in DI container**
10. **Write tests**

---

## Key Packages

### Core
- flutter_riverpod / provider
- get_it
- dartz
- equatable

### Data
- dio
- drift
- shared_preferences
- flutter_secure_storage

### Features
- geolocator
- image_picker
- camera
- permission_handler
- connectivity_plus

### Utils
- uuid
- intl
- logger

---

## Summary

This architecture ensures:
- **Maintainability**: Clear separation of concerns
- **Testability**: Mockable dependencies, isolated logic
- **Scalability**: Easy to add features
- **Flexibility**: Technology-independent core
- **Reliability**: Offline-first with sync
- **Quality**: Consistent patterns and practices

Focus on creating robust, maintainable code that handles the real-world challenges of field workers with intermittent connectivity.