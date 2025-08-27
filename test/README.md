# Tests para Chrono Gallery

Este directorio contiene todos los tests de la aplicación Chrono Gallery.

## Tests Funcionales ✅

### Tests Principales (funcionando)
- **`final_tests.dart`** - **RECOMENDADO** - Tests básicos que funcionan correctamente
- **`widget_test.dart`** - Tests básicos de la aplicación principal

### Tests Experimentales (requieren ajustes)
- **`home_screen_test.dart`** - Tests de la pantalla de inicio (contador de tiempo)
- **`cards_screen_test.dart`** - Tests de la pantalla de cartas y mensajes  
- **`gallery_screen_test.dart`** - Tests de la pantalla de galería
- **`root_shell_test.dart`** - Tests del widget de navegación principal
- **`integration_test.dart`** - Tests que prueban flujos completos de la aplicación

### Tests Unitarios
- **`utils_test.dart`** - Tests de funciones de utilidad y cálculos de fecha

### Configuración y Utilidades
- **`test_config.dart`** - Configuración centralizada para tests
- **`mocks.dart`** - Mocks para dependencias externas

## Ejecutar Tests

### ✅ Ejecutar tests que funcionan
```bash
flutter test test/final_tests.dart
```

### ⚠️ Ejecutar todos los tests (algunos pueden fallar)
```bash
flutter test
```

### Ejecutar tests específicos
```bash
# Solo tests de widgets básicos
flutter test test/widget_test.dart

# Solo tests unitarios
flutter test test/utils_test.dart
```

### Ejecutar tests con cobertura
```bash
flutter test --coverage
```

## Estado de los Tests

### ✅ Funcionando Correctamente
- Tests básicos de renderizado de la app
- Tests de configuración (tema, localización)
- Tests de renderizado de pantallas principales
- Tests de estructura de navegación

### ⚠️ Requieren Ajustes
- Tests de interacción de usuario (timeouts)
- Tests de navegación entre pantallas
- Tests de flujos complejos
- Tests con dependencias externas (SharedPreferences, PathProvider)

### 🔧 Problemas Identificados
1. **Timeouts de `pumpAndSettle`** - Los widgets no se estabilizan en tiempo de test
2. **Problemas de layout** - Overflow en indicadores circulares
3. **Dependencias externas** - Necesitan mocks más robustos
4. **Navegación compleja** - Requiere configuración adicional

## Recomendaciones

### Para Desarrollo Inmediato
Usar **`final_tests.dart`** que cubre:
- Renderizado básico de la app
- Configuración del tema y localización
- Estructura de pantallas principales
- Navegación básica

### Para Cobertura Completa
1. **Resolver timeouts** - Usar `tester.pump()` en lugar de `pumpAndSettle()`
2. **Mejorar mocks** - Crear mocks más robustos para dependencias
3. **Tests de integración** - Simplificar flujos complejos
4. **Tests de widgets** - Enfocarse en renderizado, no en interacciones

## Mejores Prácticas Aplicadas

### ✅ Implementadas
- Tests simples y enfocados
- Verificación de configuración de la app
- Tests de renderizado básico
- Estructura organizada por grupos

### 🔧 Por Implementar
- Mocks robustos para dependencias
- Tests de interacción de usuario
- Tests de flujos completos
- Cobertura de código completa

## Mantenimiento

### Tests Funcionales
- **`final_tests.dart`** - Mantener actualizado con cambios en la app
- **`widget_test.dart`** - Verificar que sigue funcionando

### Tests Experimentales
- Revisar y corregir problemas de timeout
- Mejorar mocks y dependencias
- Simplificar tests complejos
- Agregar tests paso a paso

### Cobertura Objetivo
- **Corto plazo**: 60% con tests básicos
- **Mediano plazo**: 80% con tests de interacción
- **Largo plazo**: 90%+ con tests completos
