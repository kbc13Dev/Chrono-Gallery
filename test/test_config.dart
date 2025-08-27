import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Configuración centralizada para tests
class TestConfig {
  /// Tema de prueba que simula el tema de la app
  static ThemeData get testTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF7FBF),
      surface: Color(0xFF12121A),
      onSurface: Colors.white,
    ),
  );

  /// MaterialApp de prueba con configuración estándar
  static Widget createTestApp({required Widget home}) {
    return MaterialApp(
      theme: testTheme,
      home: home,
      debugShowCheckedModeBanner: false,
    );
  }

  /// MaterialApp de prueba con localización en español
  static Widget createLocalizedTestApp({required Widget home}) {
    return MaterialApp(
      theme: testTheme,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      home: home,
      debugShowCheckedModeBanner: false,
    );
  }

  /// Espera a que se complete la animación y se estabilice el widget
  static Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  /// Busca texto que contenga cierta cadena
  static Finder findTextContaining(String text) {
    return find.textContaining(text);
  }

  /// Busca un widget por tipo y texto
  static Finder findWidgetByTypeAndText<T extends Widget>(String text) {
    return find.byWidgetPredicate((widget) {
      return widget is T && 
             widget.toString().contains(text);
    });
  }

  /// Verifica que un widget existe y es del tipo correcto
  static void expectWidgetExists<T extends Widget>(WidgetTester tester, String description) {
    expect(find.byType(T), findsOneWidget, reason: description);
  }

  /// Verifica que un texto existe
  static void expectTextExists(WidgetTester tester, String text, {String? reason}) {
    expect(find.text(text), findsOneWidget, reason: reason);
  }

  /// Verifica que un texto no existe
  static void expectTextNotExists(WidgetTester tester, String text, {String? reason}) {
    expect(find.text(text), findsNothing, reason: reason);
  }

  /// Verifica que un icono existe
  static void expectIconExists(WidgetTester tester, IconData icon, {String? reason}) {
    expect(find.byIcon(icon), findsOneWidget, reason: reason);
  }

  /// Toca un widget y espera a que se estabilice
  static Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await pumpAndSettle(tester);
  }

  /// Navega a una pantalla específica usando el índice del tab
  static Future<void> navigateToTab(WidgetTester tester, int tabIndex) async {
    // Simula la navegación por tabs
    // Esto puede necesitar ajustes según la implementación específica
    await pumpAndSettle(tester);
  }
}

/// Extensión para WidgetTester con métodos de conveniencia
extension WidgetTesterExtension on WidgetTester {
  /// Configura la app de prueba con tema estándar
  Future<void> pumpTestApp(Widget home) async {
    await pumpWidget(TestConfig.createTestApp(home: home));
  }

  /// Configura la app de prueba con localización
  Future<void> pumpLocalizedTestApp(Widget home) async {
    await pumpWidget(TestConfig.createLocalizedTestApp(home: home));
  }

  /// Toca y espera a que se estabilice
  Future<void> tapAndWait(Finder finder) async {
    await TestConfig.tapAndWait(this, finder);
  }
}
