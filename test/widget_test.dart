// Test básico para la aplicación Nexus EBSA
//
// Pruebas de widgets para verificar el funcionamiento correcto
// de la aplicación y sus componentes principales.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebsa_nexus_frontend/app.dart';

void main() {
  testWidgets('Nexus EBSA app loads correctly', (WidgetTester tester) async {
    // Construir la aplicación dentro de ProviderScope
    await tester.pumpWidget(const ProviderScope(child: NexusEBSAApp()));

    // Verificar que la aplicación carga
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verificar que aparece el título de la app
    expect(find.text('Nexus EBSA'), findsOneWidget);

    // Verificar que aparece el formulario de login
    expect(find.text('Iniciar Sesión'), findsOneWidget);

    // Verificar que existen los campos de email y contraseña
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Verificar que existe el botón de login
    expect(find.text('Iniciar Sesión'), findsNWidgets(2)); // Título + botón
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    // Construir la aplicación
    await tester.pumpWidget(const ProviderScope(child: NexusEBSAApp()));

    // Buscar el botón de iniciar sesión y tocarlo sin llenar campos
    final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
    await tester.tap(loginButton);
    await tester.pump();

    // TODO: Agregar verificaciones de validación cuando estén implementadas
    // expect(find.text('Email es requerido'), findsOneWidget);
    // expect(find.text('Contraseña es requerida'), findsOneWidget);
  });
}
