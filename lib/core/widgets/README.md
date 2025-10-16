# Core Widgets - Componentes UI Reutilizables

Este directorio contiene componentes de interfaz de usuario reutilizables globalmente en toda la aplicación.

## 📁 Estructura

```
/lib/core/widgets/
├── widgets.dart                # Barrel export principal
├── custom_text_field.dart      # Input personalizado
├── custom_button.dart          # Sistema de botones
├── custom_dropdown.dart        # Dropdowns + estados
├── work_role_dropdown.dart     # Dropdown especializado
├── form_section.dart           # Agrupador de campos
└── README.md                   # Esta documentación
```

## 🎯 Propósito

Estos widgets están diseñados para:

- ✅ **Reutilización global** en toda la aplicación
- ✅ **Consistencia visual** y de comportamiento
- ✅ **Mantenibilidad** centralizada
- ✅ **Productividad** en desarrollo

## 📦 Uso Recomendado

### Importación Simplificada (Barrel Export)

```dart
import '../../../../core/widgets/widgets.dart';
```

### Importación Individual

```dart
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
// etc...
```

## 🧩 Componentes Disponibles

### 1. `CustomTextField`

Componente para campos de texto con validación y manejo de errores:

```dart
CustomTextField(
  controller: controller,
  label: 'Nombre',
  hint: 'Ingrese su nombre',
  icon: Icons.person,
  fieldName: 'name',
  errorText: state.getFieldError('name'),
  validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
)
```

### 2. `CustomButton`

Sistema completo de botones con múltiples variantes:

```dart
// Botón primario
CustomButton(
  text: 'Crear Usuario',
  type: ButtonType.primary,
  isLoading: isLoading,
  onPressed: handleSubmit,
)

// Botón de selección
WorkTypeButton(
  label: 'Interno',
  isSelected: selectedType == WorkType.intern,
  onPressed: () => selectType(WorkType.intern),
)
```

### 3. `CustomDropdown`

Dropdown con estados de loading y error:

```dart
CustomDropdown<String>(
  value: selectedValue,
  label: 'Seleccionar Opción',
  icon: Icons.list,
  items: items,
  onChanged: onChanged,
  validator: validator,
)
```

### 4. `WorkRoleDropdown`

Dropdown especializado que se conecta automáticamente a la API:

```dart
WorkRoleDropdown(
  workType: WorkType.intern,
  selectedValue: selectedRole,
  onChanged: (value) => setState(() => selectedRole = value),
  validator: (value) => value == null ? 'Requerido' : null,
)
```

### 5. `FormSection`

Agrupador de campos con título y espaciado consistente:

```dart
FormSection(
  title: 'Información Personal',
  children: [
    CustomTextField(...),
    CustomTextField(...),
  ],
)
```

## 🚀 Ventajas de la Ubicación en `/core/widgets`

### ✅ **Reutilización Global**

- Disponibles para cualquier feature de la app
- No limitados al módulo de usuarios
- Fácil acceso desde cualquier parte del código

### ✅ **Arquitectura Limpia**

- Separación clara entre widgets core y específicos
- Seguimiento de principios de Clean Architecture
- Componentes como parte de la infraestructura

### ✅ **Mantenimiento Centralizado**

- Un solo lugar para cambios de estilo global
- Debugging y testing simplificado
- Versionado y evolución controlada

### ✅ **Productividad**

- Import simplificado con barrel export
- Componentes listos para usar
- Documentación centralizada

## 📋 Casos de Uso

Estos widgets son ideales para:

- 📝 **Formularios** de cualquier feature
- 🔍 **Páginas de búsqueda** con filtros
- ⚙️ **Configuraciones** de usuario
- 📊 **Dashboards** con controles
- 🎨 **Cualquier UI** que necesite consistencia

## 🔄 Evolución

Para agregar nuevos widgets core:

1. **Crear el componente** en `/lib/core/widgets/`
2. **Exportarlo** en `widgets.dart`
3. **Documentarlo** en este README
4. **Testear** en múltiples contextos

## 🎯 Próximos Componentes Sugeridos

- `CustomCard` - Tarjetas consistentes
- `CustomDialog` - Diálogos estandarizados
- `CustomAppBar` - AppBar personalizada
- `LoadingState` - Estados de carga globales
- `ErrorState` - Manejo de errores consistente
