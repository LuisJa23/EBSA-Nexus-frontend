// password_field.dart
//
// Campo de contraseña personalizado
//
// PROPÓSITO:
// - Widget especializado para input de passwords
// - Toggle de visibilidad de contraseña
// - Validación específica de password strength
// - Consistencia visual en toda la app
//
// CAPA: PRESENTATION LAYER
// DEPENDENCIAS: Puede importar Flutter, Material icons
//
// CONTENIDO ESPERADO:
// - class PasswordField extends StatefulWidget
// - TextEditingController como parámetro
// - bool _isObscured para manejar visibilidad
// - TextFormField con:
//   - obscureText basado en _isObscured
//   - suffixIcon con IconButton de eye/eye-off
//   - Validator de password strength
//   - Decoration consistent con app theme
// - onTap del icon para toggle visibilidad
// - Parámetros: controller, validator, label, hint
// - Animación suave en cambio de visibilidad
// - Accesibilidad para lectores de pantalla
// - Soporte para autovalidate mode
