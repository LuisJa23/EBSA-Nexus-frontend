import 'package:flutter/material.dart';

enum ButtonType { primary, secondary }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final double width;
  final double height;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.width = 90,
    this.height = 35,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = widget.type == ButtonType.primary;

    // Colores según el tipo y estado
    final Color bgColor = isPrimary
        ? (_isPressed ? Colors.white : const Color(0xFFF5C24B))
        : (_isPressed ? Colors.white : Colors.black);

    final Color borderColor = isPrimary
        ? const Color(0xFFF5C24B)
        : Colors.black;

    final Color textColor = isPrimary
        ? (_isPressed ? const Color(0xFFF5C24B).withOpacity(0.6) : Colors.black)
        : (_isPressed ? Colors.black : Colors.white);

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
