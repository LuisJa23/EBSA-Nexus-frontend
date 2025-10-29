import 'package:flutter/material.dart';

/// AppBar personalizado con el logo de EBSA Nexus en el lado izquierdo
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showLogo;
  final double logoSize;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.centerTitle = true,
    this.showLogo = true,
    this.logoSize = 40.0,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Logo en el lado izquierdo (leading)
      leading: showLogo
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/ebsa2.png',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('ERROR CARGANDO LOGO: $error');
                  return Container(
                    width: logoSize,
                    height: logoSize,
                    color: Colors.red,
                    child: const Icon(Icons.error, color: Colors.white),
                  );
                },
              ),
            )
          : null,
      // Título sin el logo
      title: title != null ? Text(title!) : null,
      centerTitle: centerTitle,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
