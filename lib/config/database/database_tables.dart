// database_tables.dart
//
// Definición de tablas de la base de datos Drift
//
// PROPÓSITO:
// - Definir estructura de todas las tablas
// - Relationships y foreign keys
// - Índices para optimización
// - Constraints de negocio
//
// CONTENIDO ESPERADO:
// - class Reports extends Table (con @DataClassName('ReportData'))
//   - IntColumn get id => integer().autoIncrement()();
//   - TextColumn get title => text().withLength(min: 1, max: 255)();
//   - TextColumn get description => text()();
//   - IntColumn get status => intEnum<ReportStatus>()();
//   - DateTimeColumn get createdAt => dateTime()();
//   - RealColumn get latitude => real()();
//   - RealColumn get longitude => real()();
//   - BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
//
// - class Evidence extends Table
// - class Users extends Table  
// - class Incidents extends Table
// - class WorkCrews extends Table
// - class SyncQueue extends Table
// - Índices y constraints apropiados