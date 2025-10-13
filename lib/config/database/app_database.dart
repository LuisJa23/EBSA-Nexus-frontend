// app_database.dart
//
// Configuración principal de la base de datos con Drift
//
// PROPÓSITO:
// - Configurar Drift (SQLite) database
// - Definir conexión y configuraciones
// - Manejo de migraciones
// - Queries complejas y triggers
//
// CONTENIDO ESPERADO:
// - @DriftDatabase annotation
// - class AppDatabase extends _$AppDatabase
// - Lista de tablas: [Reports, Users, Incidents, Evidence, SyncQueue, ...]
// - int get schemaVersion => 1;
// - MigrationStrategy get migration => MigrationStrategy(...);
// - Queries personalizados para reportes complejos
// - Triggers para audit log
// - Índices para performance
// - Foreign keys y constraints
// - Backup y restore methods
