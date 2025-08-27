import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chrono_gallery/screens/cards_screen.dart';

void main() {
  group('CardsScreen Tests', () {

    testWidgets('CardsScreen se renderiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardsScreen()));
      
      expect(find.text('Cartas'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Mensajes'), findsOneWidget);
    });

    testWidgets('CardsScreen muestra tabs de Cartas y Mensajes', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardsScreen()));
      
      // Verifica que existen ambos tabs
      expect(find.text('Cartas'), findsOneWidget);
      expect(find.text('Mensajes'), findsOneWidget);
      
      // Verifica que el tab de Cartas está activo por defecto
      expect(find.text('Aún no hay cartas'), findsOneWidget);
    });

    testWidgets('CardsScreen cambia entre tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardsScreen()));
      
      // Cambia al tab de Mensajes
      await tester.tap(find.text('Mensajes'));
      await tester.pumpAndSettle();
      
      // Verifica que se muestra el tab de Mensajes
      expect(find.text('Aún no hay mensajes'), findsOneWidget);
    });

    testWidgets('CardsScreen muestra botón de nueva carta', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardsScreen()));
      
      // Verifica que existe el botón de nueva carta
      expect(find.text('Nueva carta'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('CardsScreen muestra botón de nuevo mensaje', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardsScreen()));
      
      // Cambia al tab de Mensajes
      await tester.tap(find.text('Mensajes'));
      await tester.pumpAndSettle();
      
      // Verifica que existe el botón de nuevo mensaje
      expect(find.text('Nuevo mensaje'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('CardsScreen muestra estado vacío para cartas', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardsScreen()));
      
      expect(find.text('Aún no hay cartas'), findsOneWidget);
      expect(find.text('Escribe tu primera carta ✨'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    });

    testWidgets('CardsScreen muestra estado vacío para mensajes', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardsScreen()));
      
      // Cambia al tab de Mensajes
      await tester.tap(find.text('Mensajes'));
      await tester.pumpAndSettle();
      
      expect(find.text('Aún no hay mensajes'), findsOneWidget);
      expect(find.text('Añade tus mensajes favoritos 💬'), findsOneWidget);
      expect(find.byIcon(Icons.sms_rounded), findsOneWidget);
    });
  });
}
