import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chrono_gallery/main.dart';
import 'package:chrono_gallery/widgets/root_shell.dart';

void main() {
  group('Integration Tests', () {
    testWidgets('Flujo completo de navegación entre pantallas', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Verifica que se inicia en la pantalla de inicio
      expect(find.text('Tiempo juntos'), findsOneWidget);
      
      // Navega a la pantalla de cartas
      await tester.tap(find.byIcon(Icons.collections_bookmark_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Cartas'), findsOneWidget);
      
      // Navega a la pantalla de galería
      await tester.tap(find.byIcon(Icons.photo_library_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Galería'), findsOneWidget);
      
      // Regresa a la pantalla de inicio
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Tiempo juntos'), findsOneWidget);
    });

    testWidgets('Flujo de creación de carta', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RootShell()));
      await tester.pumpAndSettle();
      
      // Navega a la pantalla de cartas
      await tester.tap(find.byIcon(Icons.collections_bookmark_rounded));
      await tester.pumpAndSettle();
      
      // Toca el botón de nueva carta
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      
      // Verifica que se abre el modal de nueva carta
      expect(find.text('Nueva carta'), findsOneWidget);
      expect(find.text('Título'), findsOneWidget);
      expect(find.text('Contenido (Markdown)…'), findsOneWidget);
    });

    testWidgets('Flujo de creación de mensaje', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RootShell()));
      await tester.pumpAndSettle();
      
      // Navega a la pantalla de cartas
      await tester.tap(find.byIcon(Icons.collections_bookmark_rounded));
      await tester.pumpAndSettle();
      
      // Cambia al tab de mensajes
      await tester.tap(find.text('Mensajes'));
      await tester.pumpAndSettle();
      
      // Toca el botón de nuevo mensaje
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      
      // Verifica que se abre el modal de nuevo mensaje
      expect(find.text('Nuevo mensaje'), findsOneWidget);
      expect(find.text('Autor'), findsOneWidget);
      expect(find.text('Escribe tu mensaje…'), findsOneWidget);
    });

    testWidgets('Flujo de selección de fecha', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RootShell()));
      await tester.pumpAndSettle();
      
      // Verifica que se muestra el estado vacío
      expect(find.text('Elige una fecha para empezar a contar.'), findsOneWidget);
      
      // Toca el botón de editar fecha
      await tester.tap(find.byIcon(Icons.edit_calendar_rounded));
      await tester.pumpAndSettle();
      
      // Verifica que se abre el selector de fecha
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('Flujo de galería vacía', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RootShell()));
      await tester.pumpAndSettle();
      
      // Navega a la pantalla de galería
      await tester.tap(find.byIcon(Icons.photo_library_rounded));
      await tester.pumpAndSettle();
      
      // Verifica que se muestra el estado vacío
      expect(find.text('Aún no hay fotos'), findsOneWidget);
      expect(find.text('Añade tus recuerdos para verlos aquí ✨'), findsOneWidget);
      
      // Verifica que existe el botón de añadir fotos
      expect(find.text('Añadir fotos'), findsOneWidget);
    });

    testWidgets('Persistencia de navegación', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RootShell()));
      await tester.pumpAndSettle();
      
      // Navega a cartas
      await tester.tap(find.byIcon(Icons.collections_bookmark_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Cartas'), findsOneWidget);
      
      // Reconstruye el widget (simula reinicio de app)
      await tester.pumpWidget(const MaterialApp(home: RootShell()));
      await tester.pumpAndSettle();
      
      // Verifica que se mantiene en la pantalla de inicio (comportamiento por defecto)
      expect(find.text('Tiempo juntos'), findsOneWidget);
    });
  });
}
