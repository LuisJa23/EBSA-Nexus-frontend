import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ebsa_nexus_frontend/core/widgets/custom_button.dart';
import 'package:ebsa_nexus_frontend/core/widgets/label_text_field.dart';
import 'package:ebsa_nexus_frontend/config/routes/route_names.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Notificaciones'),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Ir al Perfil',
              onPressed: () {
                context.go(RouteNames.profile); // Use go_router navigation
              },
            ),
            LabeledTextField(label: "Label Text", hint: "Text"),
          ],
        ),
      ),
    );
  }
}
