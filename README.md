# MinKids - Aplicación Móvil Flutter

Aplicación móvil de control parental que permite a los padres monitorear y gestionar el uso de aplicaciones de sus hijos.

## 🚀 Características Implementadas

### Para Padres (Rol: `padre`)
- ✅ Registro e inicio de sesión automático
- ✅ Dashboard con resumen del día del hijo
- ✅ Listado de hijos vinculados
- ✅ Control de aplicaciones con límites de tiempo
- ✅ Ajuste de límites diarios por aplicación
- ✅ Vincular hijos mediante código
- ✅ Perfil con preferencias de notificación

### Para Hijos (Rol: `hijo`)
- ✅ Registro con generación de código de vinculación
- ✅ Visualización del código de vinculación en Home y Perfil
- ✅ Vista de aplicaciones con tiempo restante (solo lectura)
- ✅ Dashboard simplificado con resumen personal
- ✅ Sin capacidad de modificar límites

## 📱 Configuración

### Requisitos Previos
- Flutter SDK 3.7.2 o superior
- Backend MinKids ejecutándose (ver `/backend`)
- Emulador Android/iOS o dispositivo físico

### Instalación

1. **Navegar al directorio del proyecto**:
```bash
cd minkids
```

2. **Instalar dependencias**:
```bash
flutter pub get
```

3. **Configurar URL del backend**:
   - Edita `lib/utils/constants.dart`
   - Cambia `kBaseUrl` según tu entorno:
     - Android Emulator: `http://10.0.2.2:3000`
     - iOS Simulator: `http://localhost:3000`
     - Dispositivo físico: `http://<TU_IP_LOCAL>:3000`

4. **Ejecutar la aplicación**:
```bash
flutter run
```

## 🔐 Flujo de Autenticación

### Registro

**Padre**:
1. Selecciona rol "Padre"
2. Completa formulario de registro
3. Auto-login y redirección a Home
4. Puede agregar hijos mediante código

**Hijo**:
1. Selecciona rol "Hijo"
2. Completa formulario de registro
3. **Se muestra el código de vinculación** en un diálogo
4. Auto-login y redirección a Home
5. El código también está visible en la pantalla de inicio

### Login
1. Ingresa email y contraseña
2. Redirección automática a Home según rol

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                    # Entry point, routing
├── models/
│   ├── user.dart               # Modelo de usuario
│   ├── child.dart              # Modelo de hijo vinculado
│   ├── application.dart        # Modelo de aplicación
│   └── app_limit.dart          # Modelo de límite de app
├── services/
│   ├── api_service.dart        # HTTP client (GET, POST, PATCH, DELETE)
│   ├── auth_service.dart       # Autenticación y almacenamiento local
│   ├── applications_service.dart
│   ├── limits_service.dart
│   └── parent_children_service.dart
├── screens/
│   ├── login_screen.dart       # Pantalla de login
│   ├── register_screen.dart    # Registro (muestra código si hijo)
│   ├── home_screen.dart        # Container con BottomNavigationBar
│   ├── home_tab.dart           # Tab Inicio (dinámico por rol)
│   ├── apps_screen.dart        # Tab Apps (dinámico por rol)
│   ├── profile_screen.dart     # Tab Perfil
│   └── add_child_screen.dart   # Agregar hijo por código (padre)
└── utils/
    └── constants.dart          # Configuración (API URL, keys)
```

## 🎯 Endpoints Consumidos

| Endpoint | Método | Auth | Descripción |
|----------|--------|------|-------------|
| `/auth/register` | POST | No | Registro de usuario |
| `/auth/login` | POST | No | Inicio de sesión |
| `/parent-children/add` | POST | Sí | Vincular hijo por código |
| `/parent-children/my-children` | GET | Sí | Lista de hijos del padre |
| `/applications` | GET | Sí | Lista de aplicaciones |
| `/child-app-limits/child/:id` | GET | Sí | Límites de un hijo |
| `/child-app-limits` | POST | Sí | Crear límite |
| `/child-app-limits/:id` | PATCH | Sí | Actualizar límite |

## 🎨 Pantallas por Rol

### Padre
1. **Inicio**: Resumen del día, tarjetas de uso y ubicación, lista de hijos
2. **Apps**: Control de aplicaciones con ajuste de límites
3. **Ubicación**: (Placeholder)
4. **Consejos**: (Placeholder)
5. **Perfil**: Datos de usuario, preferencias, botón "Agregar Hijo"

### Hijo
1. **Inicio**: Saludo personalizado, **código de vinculación destacado**, resumen de uso
2. **Apps**: Lista de apps con tiempo restante (solo lectura, switches deshabilitados)
3. **Ubicación**: (Placeholder)
4. **Consejos**: (Placeholder)
5. **Perfil**: Datos de usuario, preferencias, código de vinculación

## 🔧 Próximas Mejoras

- [ ] Integración de mapa en pantalla de Ubicación
- [ ] Consumir endpoints reales de uso de aplicaciones (`/child-app-usage`)
- [ ] Selector de hijo para padre (actualmente muestra placeholder)
- [ ] Pantalla de Consejos con contenido dinámico
- [ ] Notificaciones push
- [ ] Refresh token automático
- [ ] Almacenamiento seguro con `flutter_secure_storage`
- [ ] Tests unitarios y de integración

## 🐛 Troubleshooting

**Error de conexión al backend**:
- Verifica que el backend esté corriendo en el puerto 3000
- Asegúrate de usar la IP correcta según tu dispositivo/emulador
- En Android Emulator, usa `10.0.2.2` en lugar de `localhost`

**No se muestra el código de vinculación**:
- Verifica que el backend retorne el campo `code` en la respuesta de `/auth/register` para usuarios con rol "hijo"
- El código debe estar en `response.body.code` o `response.body.user.code`

**Auto-login no funciona**:
- Verifica que el backend retorne un token JWT en `/auth/login`
- El token debe estar en `response.body.token` o `response.body.access_token`

## 📝 Notas de Desarrollo

- La app usa `SharedPreferences` para almacenar token y datos de usuario
- Los switches de notificaciones en Perfil son UI-only (no persisten)
- La pantalla Apps muestra datos mock para demostración (padre)
- El cálculo de tiempo usado en Apps (hijo) es simulado (80% del límite)
