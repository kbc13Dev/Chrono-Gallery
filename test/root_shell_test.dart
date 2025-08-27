import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chrono_gallery/widgets/root_shell.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

void main() {
  group('RootShell Tests', () {
    testWidgets('RootShell se renderiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RootShell()));
      
      // Verifica que se renderiza el Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
      
      // Verifica que se renderiza la navegación inferior
      expect(find.byType(CircleNavBar), findsOneWidget);
    });

    testWidgets('RootShell muestra las tres pantallas principales', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RootShell()));
      
      // Verifica que se muestran los iconos de navegación
      expect(find.byIcon(Icons.collections_bookmark_rounded), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.home_rounded), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.photo_library_rounded), findsAtLeastNWidgets(1));
    });

    testWidgets('RootShell inicia en la pantalla de inicio', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RootShell()));
      
      // Verifica que se muestra la pantalla de inicio por defecto
      expect(find.text('Tiempo juntos'), findsOneWidget);
    });

    testWidgets('RootShell tiene navegación circular', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RootShell()));
      
      // Verifica que existe la navegación circular
      expect(find.byType(CircleNavBar), findsOneWidget);
      
      // Verifica que tiene el estilo correcto
      final navBar = tester.widget<CircleNavBar>(find.byType(CircleNavBar));
      expect(navBar.height, equals(96.0));
      expect(navBar.circleWidth, equals(76.0));
    });

    testWidgets('RootShell mantiene estado entre navegaciones', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RootShell()));
      
      // Verifica que se muestra la pantalla de inicio
      expect(find.text('Tiempo juntos'), findsOneWidget);
      
      // Navega a la pantalla de cartas
      await tester.tap(find.byIcon(Icons.collections_bookmark_rounded));
      await tester.pumpAndSettle();
      
      // Verifica que se muestra la pantalla de cartas
      expect(find.text('Cartas'), findsOneWidget);
      
      // Navega de vuelta a la pantalla de inicio
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();
      
      // Verifica que se muestra la pantalla de inicio
      expect(find.text('Tiempo juntos'), findsOneWidget);
    });
  });
}
