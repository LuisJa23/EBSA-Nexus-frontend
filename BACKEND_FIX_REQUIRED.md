# ⚠️ PROBLEMA: ID de Usuario en Respuesta de Login

## 🐛 Error Encontrado

Al intentar acceder a la página de notificaciones, se produce el siguiente error:

```
FormatException: Invalid radix-10 number (at character 1)
Pedro.ebsa
```

## 🔍 Causa Raíz

El frontend está intentando convertir `user.id` a un número entero (`int`) para llamar a los endpoints de notificaciones, pero el campo `id` contiene el **username** (`"Pedro.ebsa"`) en lugar de un **ID numérico** (como `5`, `9`, etc.).

### ¿Qué es el userId?

Según el código del backend, las notificaciones se crean con un `userId` numérico que corresponde al **ID del Worker/Usuario** en la base de datos:

```java
// Ejemplo de notificación del backend
{
  "userId": 5,              // ⬅️ Este es el ID numérico del Worker
  "type": "CREW_ASSIGNED",
  "title": "Removido de Cuadrilla",
  "message": "Has sido removido como miembro de la cuadrilla 'Alpha Team'."
}
```

Los endpoints de notificaciones esperan este mismo `userId` numérico:

- `/api/v1/notifications/user/5`
- `/api/v1/notifications/user/9`
- etc.

### Flujo Actual del Problema:

1. Usuario hace login
2. Backend responde con datos del usuario
3. Frontend parsea la respuesta con `UserModel.fromLoginResponse()`
4. El campo `id` se asigna desde `json['username']` → `"Pedro.ebsa"`
5. Al cargar notificaciones, se intenta `int.parse("Pedro.ebsa")` → **ERROR**

## ✅ Solución Implementada en Frontend

### 1. Manejo Seguro de Conversión

Se agregó el método `_parseUserId()` que:

- Intenta convertir el `id` a número
- Si falla, retorna `null` y muestra un mensaje de error claro
- No crashea la aplicación

### 2. Búsqueda de ID Numérico

Se modificó `UserModel.fromLoginResponse()` para buscar el ID en múltiples campos:

```dart
// Prioridad de búsqueda:
1. json['userId']  // Campo preferido
2. json['id']      // Campo alternativo
3. json['username'] // Fallback (no numérico)
```

## 🚨 ACCIÓN REQUERIDA EN EL BACKEND

### Opción A: Agregar Campo `userId` a la Respuesta de Login (RECOMENDADO)

El backend debe incluir el **ID numérico** del usuario en la respuesta de login.

**Endpoint**: `POST /auth/login`

**Respuesta Actual**:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "pedro@ebsa.com",
  "username": "Pedro.ebsa",
  "role": "SUPERVISOR",
  "workRole": "Electricista"
}
```

**Respuesta Esperada** (agregar campo `userId`):

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": 9, // ⬅️ AGREGAR: ID del Worker/Usuario en la BD
  "email": "pedro@ebsa.com",
  "username": "Pedro.ebsa",
  "role": "SUPERVISOR",
  "workRole": "Electricista"
}
```

**¿De dónde sale el `userId`?**

El `userId` debe ser el mismo que se usa en las notificaciones:

- Es el ID de la tabla `workers` o `users` en la base de datos
- Es el mismo que se pasa a `notificationService.createNotification(userId, ...)`
- Es un número entero (Long/Integer en Java)

### Cambio en el Backend (Java/Spring Boot)

**Archivo**: `AuthController.java` o similar

```java
@PostMapping("/login")
public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
    // ... autenticación existente ...

    User user = authService.authenticate(request.getUsername(), request.getPassword());
    // O si usas Worker:
    // Worker worker = authService.authenticate(request.getUsername(), request.getPassword());

    String token = jwtService.generateToken(user);

    LoginResponse response = new LoginResponse();
    response.setToken(token);
    response.setUserId(user.getId());        // ⬅️ AGREGAR: Este es el ID de la BD
    response.setEmail(user.getEmail());
    response.setUsername(user.getUsername());
    response.setRole(user.getRole().name());
    response.setWorkRole(user.getWorkRole());

    return ResponseEntity.ok(response);
}
```

**IMPORTANTE**: El `userId` debe ser el mismo ID que se usa en:

- `CrewMemberService.removeMember(crewId, userId)` - línea 203
- `notificationService.createNotification(userId, ...)` - en todo el código
- La tabla de notificaciones: `notification.user_id`

Por ejemplo, si un usuario tiene `id=9` en la tabla `workers`, ese mismo `9` debe venir en el login.

**Clase `LoginResponse`**:

```java
public class LoginResponse {
    private String token;
    private Long userId;        // ⬅️ AGREGAR ESTE CAMPO
    private String email;
    private String username;
    private String role;
    private String workRole;

    // Getters y setters...

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }
}
```

### Opción B: Agregar Campo `id` (Alternativa)

Si prefieres usar `id` en lugar de `userId`:

```json
{
  "token": "...",
  "id": 9, // ⬅️ Usar este nombre
  "email": "pedro@ebsa.com",
  "username": "Pedro.ebsa",
  "role": "SUPERVISOR",
  "workRole": "Electricista"
}
```

El frontend ya está preparado para buscar en ambos campos (`userId` o `id`).

## 📋 Verificación

### Después de Implementar el Cambio en el Backend:

1. Hacer login en la app
2. Revisar los logs del frontend:

   ```
   🔍 DEBUG fromLoginResponse - JSON completo: {...}
   ✅ ID numérico encontrado en userId: 9
   ```

3. Acceder a la página de notificaciones
4. Debería cargar sin errores

### Si Aparece este Log:

```
⚠️ No se encontró ID numérico, usando username: Pedro.ebsa
```

Significa que el backend **aún no está enviando el campo `userId`** o `id`.

## 🔗 Endpoints que Requieren userId Numérico

Los siguientes endpoints de notificaciones esperan un `userId` numérico:

- `GET /api/v1/notifications/user/{userId}`
- `GET /api/v1/notifications/user/{userId}/unread`
- `GET /api/v1/notifications/user/{userId}/unread/count`
- `PATCH /api/v1/notifications/user/{userId}/read-all`
- `DELETE /api/v1/notifications/user/{userId}`

Por ejemplo:

- ✅ Correcto: `/api/v1/notifications/user/9`
- ❌ Incorrecto: `/api/v1/notifications/user/Pedro.ebsa`

## 📞 Contacto

Si tienes dudas sobre la implementación, revisa:

- `UserModel.fromLoginResponse()` en `user_model.dart`
- `NotificationsPage._parseUserId()` en `notifications_page.dart`

---

**Prioridad**: 🔴 Alta  
**Impacto**: Bloquea la funcionalidad completa de notificaciones  
**Tiempo estimado**: 10-15 minutos
