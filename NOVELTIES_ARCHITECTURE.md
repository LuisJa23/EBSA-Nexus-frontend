# 🏗️ Arquitectura: Lista de Novedades

## 📐 Clean Architecture - Flujo de Datos

```
┌─────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                          │
│  (UI, Widgets, State Management)                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐         ┌──────────────────────┐        │
│  │ IncidentListPage │◄────────┤ NoveltyListNotifier │        │
│  │  (ConsumerWidget)│         │   (StateNotifier)    │        │
│  └────────┬─────────┘         └──────────┬───────────┘        │
│           │                              │                     │
│           │ displays                     │ manages            │
│           ▼                              ▼                     │
│  ┌──────────────────┐         ┌──────────────────────┐        │
│  │ NoveltyListItem  │         │ NoveltyListState     │        │
│  │ FilterBottomSheet│         │  (Immutable State)   │        │
│  └──────────────────┘         └──────────────────────┘        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                               │
                               │ calls
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                               │
│  (Business Logic, Use Cases, Entities)                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐         ┌──────────────────────┐        │
│  │  GetNovelties    │─────────┤ NoveltyRepository    │        │
│  │   (Use Case)     │  uses   │    (Interface)       │        │
│  └──────────────────┘         └──────────────────────┘        │
│           │                                                     │
│           │ returns                                             │
│           ▼                                                     │
│  ┌──────────────────┐                                          │
│  │    Novelty       │                                          │
│  │   (Entity)       │                                          │
│  └──────────────────┘                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                               │
                               │ implements
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DATA LAYER                                │
│  (API, Models, Repository Implementation)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────┐                                     │
│  │NoveltyRepositoryImpl  │                                     │
│  │  (Implementation)     │                                     │
│  └──────────┬────────────┘                                     │
│             │ uses                                              │
│             ▼                                                   │
│  ┌───────────────────────┐         ┌──────────────────┐       │
│  │  NoveltyService       │─────────┤   ApiClient      │       │
│  │  (HTTP Calls)         │  uses   │  (Dio + JWT)     │       │
│  └──────────┬────────────┘         └──────────────────┘       │
│             │                                                   │
│             │ returns                                           │
│             ▼                                                   │
│  ┌───────────────────────┐                                     │
│  │  NoveltyResponse      │                                     │
│  │  NoveltyPageResponse  │                                     │
│  │  (DTOs/Models)        │                                     │
│  └───────────────────────┘                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                               │
                               │ HTTP Request
                               ▼
                    ┌──────────────────────┐
                    │   BACKEND API        │
                    │ /api/v1/novelties    │
                    │   (Spring Boot)      │
                    └──────────────────────┘
```

## 🔄 Flujo de Datos Detallado

### 1️⃣ **Usuario Abre la Página**

```
User Action: Abre IncidentListPage
     │
     ▼
[IncidentListPage.initState()]
     │
     ▼
ref.read(noveltyListProvider.notifier).loadNovelties()
     │
     ▼
[NoveltyListNotifier.loadNovelties()]
     │
     ├─ setState(status: loading)
     ├─ notifyListeners()
     │
     ▼
_getNovelties(filters) → Use Case
     │
     ▼
NoveltyRepository.getNovelties(filters)
     │
     ▼
NoveltyRepositoryImpl.getNovelties()
     │
     ▼
NoveltyService.getNovelties(params)
     │
     ▼
ApiClient.get('/api/v1/novelties?page=0&size=10...')
     │
     ├─ Add JWT Token (via Interceptor)
     ├─ Send HTTP GET Request
     │
     ▼
Backend Response (JSON)
     │
     ▼
NoveltyPageResponse.fromJson(json)
     │
     ├─ Parse JSON to Models
     ├─ Convert to Entities
     │
     ▼
Either<Failure, NoveltyPage>
     │
     ▼
[NoveltyListNotifier] Updates State
     │
     ├─ status: success
     ├─ novelties: [List<Novelty>]
     ├─ totalElements, totalPages, etc.
     │
     ▼
ref.watch(noveltyListProvider) detects change
     │
     ▼
[IncidentListPage] Rebuilds UI
     │
     ├─ ListView.builder()
     ├─ Display NoveltyListItems
     │
     ▼
User sees the list! 🎉
```

### 2️⃣ **Usuario Aplica Filtros**

```
User Action: Toca icono de filtro
     │
     ▼
showModalBottomSheet(NoveltyFiltersBottomSheet)
     │
     ▼
User: Selecciona "PENDING" y "HIGH"
     │
     ▼
Tap "Aplicar"
     │
     ▼
ref.read(noveltyListProvider.notifier).setStatusFilter(PENDING)
ref.read(noveltyListProvider.notifier).setPriorityFilter(HIGH)
     │
     ▼
[NoveltyListNotifier.setStatusFilter()]
     │
     ├─ Update state with new filter
     ├─ Call loadNovelties(refresh: true)
     │
     ▼
API Call: /api/v1/novelties?status=PENDING&priority=HIGH&page=0&size=10
     │
     ▼
Filtered results returned
     │
     ▼
UI updates with filtered list 🎯
```

### 3️⃣ **Usuario Hace Scroll Infinito**

```
User Action: Scrolls to 90% of list
     │
     ▼
_scrollController.addListener() detects
     │
     ▼
ref.read(noveltyListProvider.notifier).loadMore()
     │
     ▼
[NoveltyListNotifier.loadMore()]
     │
     ├─ Check: hasMore? && !isLoadingMore?
     ├─ setState(status: loadingMore)
     │
     ▼
API Call: /api/v1/novelties?page=1&size=10&[...filters]
     │
     ▼
Next page results
     │
     ├─ Append to existing novelties
     ├─ Update pagination metadata
     │
     ▼
UI shows more items at bottom ♾️
```

### 4️⃣ **Usuario Hace Pull-to-Refresh**

```
User Action: Pulls down the list
     │
     ▼
RefreshIndicator.onRefresh
     │
     ▼
ref.read(noveltyListProvider.notifier).refresh()
     │
     ▼
[NoveltyListNotifier.refresh()]
     │
     ├─ Calls loadNovelties(refresh: true)
     ├─ Resets to page 0
     ├─ Clears current list
     ├─ Maintains active filters
     │
     ▼
API Call: /api/v1/novelties?page=0&size=10&[...filters]
     │
     ▼
Fresh data loaded
     │
     ▼
UI shows updated list 🔄
```

## 🔐 Autenticación JWT

```
Every API Call
     │
     ▼
[ApiClient] Dio Interceptor
     │
     ├─ Read JWT from FlutterSecureStorage
     ├─ Add to Headers: "Authorization: Bearer {token}"
     │
     ▼
HTTP Request with Token
     │
     ▼
Backend validates token
     │
     ├─ ✅ Valid → 200 OK
     ├─ ❌ Expired → 401 Unauthorized
     ├─ ❌ Invalid → 403 Forbidden
     │
     ▼
[ApiClient] Error Interceptor
     │
     ├─ 401 → AuthFailure → Navigate to Login
     ├─ 403 → AuthFailure → Show "Access Denied"
     ├─ 500 → ServerFailure → Show Error
     │
     ▼
UI handles error state
```

## 📊 Estado de la Aplicación (Riverpod)

```
┌─────────────────────────────────────────┐
│      incidents_providers.dart           │
│  (Dependency Injection Container)       │
├─────────────────────────────────────────┤
│                                         │
│  apiClientProvider                      │
│       │                                 │
│       ▼                                 │
│  noveltyServiceProvider                 │
│       │                                 │
│       ▼                                 │
│  noveltyRepositoryProvider              │
│       │                                 │
│       ▼                                 │
│  getNoveltiesUseCaseProvider            │
│       │                                 │
│       ▼                                 │
│  noveltyListProvider ◄──────────────┐   │
│  (StateNotifierProvider)            │   │
│       │                             │   │
│       │ provides                    │   │
│       ▼                             │   │
│  NoveltyListState                   │   │
│  ├─ status                         reads│
│  ├─ novelties: []                   │   │
│  ├─ filters                         │   │
│  └─ pagination                      │   │
│       │                             │   │
│       └─────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

## 🎯 Beneficios de esta Arquitectura

### ✅ **Separación de Responsabilidades**
- UI solo renderiza
- Business logic en domain
- Data fetching en data layer

### ✅ **Testeable**
- Cada capa puede testearse independientemente
- Mock repositories, services, etc.

### ✅ **Escalable**
- Fácil agregar nuevas features
- Modificar implementaciones sin afectar otras capas

### ✅ **Mantenible**
- Código organizado y documentado
- Fácil de entender y modificar

### ✅ **Reutilizable**
- Entities y use cases reutilizables
- Widgets componentizados

## 🔗 Dependencias Clave

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.4.9
  
  # Functional Programming
  dartz: ^0.10.1
  equatable: ^2.0.5
  
  # Networking
  dio: ^5.3.3
  
  # Storage
  flutter_secure_storage: ^9.0.0
  
  # Utilities
  intl: ^0.20.2
  logger: ^2.0.2+1
```

---

**Arquitectura implementada siguiendo principios SOLID y Clean Architecture** 🏆
