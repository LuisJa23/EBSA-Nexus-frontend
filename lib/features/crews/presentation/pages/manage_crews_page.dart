import 'package:flutter/material.dart';

/// Página para gestionar cuadrillas
class ManageCrewsPage extends StatelessWidget {
  const ManageCrewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Gestión de Cuadrillas',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
