@echo off
echo ========================================
echo    Tests de Chrono Gallery
echo ========================================
echo.

echo Ejecutando tests básicos (recomendados)...
flutter test test/final_tests.dart
echo.

echo Ejecutando tests unitarios...
flutter test test/utils_test.dart
echo.

echo Ejecutando tests de widgets básicos...
flutter test test/widget_test.dart
echo.

echo ========================================
echo    Tests completados
echo ========================================
echo.
echo Para ejecutar todos los tests (algunos pueden fallar):
echo   flutter test
echo.
echo Para ejecutar tests con cobertura:
echo   flutter test --coverage
echo.
pause
