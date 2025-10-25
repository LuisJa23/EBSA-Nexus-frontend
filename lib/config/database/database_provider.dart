// database_provider.dart
//
// Provider para acceso a base de datos
//
// PROPÓSITO:
// - Proveer instancia singleton de la base de datos
// - Facilitar acceso desde toda la aplicación
//
// CAPA: DATA LAYER

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Provider singleton de la base de datos
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  // Asegurarse de cerrar la BD cuando el provider se elimine
  ref.onDispose(() {
    database.close();
  });

  return database;
});
