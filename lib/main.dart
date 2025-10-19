// main.dart
//
// Punto de entrada principal de la aplicación Nexus EBSA
//
// PROPÓSITO:
// - Inicializar la aplicación Flutter
// - Configurar inyección de dependencias
// - Setup de servicios esenciales
// - Manejo global de errores
// - Inicialización de providers
//
// CONTENIDO ESPERADO:
// - Future<void> main() async
// - WidgetsFlutterBinding.ensureInitialized()
// - await setupDependencies() // injection_container.dart
// - await setupLocalDatabase()
// - FlutterError.onError setup para crashlytics
// - runApp(ProviderScope(child: NexusEBSAApp())) // si usa Riverpod
// - o runApp(MultiProvider(providers: [...], child: NexusEBSAApp())) // si usa Provider

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config/dependency_injection/injection_container.dart' as di;

void main() async {
  // Asegurar que Flutter esté inicializado antes de configuraciones
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar inyección de dependencias
  await di.init();

  // TODO: Inicializar base de datos local
  // await setupLocalDatabase();

  // Configurar manejo global de errores
  FlutterError.onError = (FlutterErrorDetails details) {
    // TODO: Enviar a servicio de crash reporting en producción
    debugPrint('Flutter Error: ${details.exception}');
  };

  // Ejecutar aplicación con Riverpod
  runApp(const ProviderScope(child: NexusEBSAApp()));
}
