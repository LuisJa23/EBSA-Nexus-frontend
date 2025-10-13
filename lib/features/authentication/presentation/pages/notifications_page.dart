import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ebsa_nexus_frontend/core/widgets/custom_button.dart';
import 'package:ebsa_nexus_frontend/core/widgets/status_alert_card.dart';
import 'package:ebsa_nexus_frontend/core/widgets/chip_state.dart';
import 'package:ebsa_nexus_frontend/core/widgets/label_text_field.dart';
import 'package:ebsa_nexus_frontend/config/routes/route_names.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              type: ButtonType.primary,
              onPressed: () {
                context.go(RouteNames.profile);
              },
            ),
            ChipState(state: 'Por asignar'),
            SizedBox(height: 12, width: 10),
            ChipState(state: 'En curso'),
            SizedBox(height: 12),
            CustomButton(
              text: 'Ir al Perfil',
              type: ButtonType.secondary,
              width: 120,
              onPressed: () {
                context.go(RouteNames.profile);
              },
            ),
            LabeledTextField(
              label: "Label Text",
              hint: "Text",
              controller: _controller, // Pass the controller
            ),
            StatusCard(
              type: StatusType.alerta,
              title: "Alerta",
              subtitle: "Label Text",
            ),
          ],
        ),
      ),
    );
  }
}
