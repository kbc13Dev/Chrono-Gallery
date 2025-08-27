import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chrono_gallery/main.dart';
import 'package:chrono_gallery/screens/home_screen.dart';
import 'package:chrono_gallery/screens/cards_screen.dart';
import 'package:chrono_gallery/screens/gallery_screen.dart';

void main() {
  group('Tests Simples de Chrono Gallery', () {
    testWidgets('App principal se renderiza', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Tiempo juntos'), findsOneWidget);
    });

    testWidgets('HomeScreen se renderiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      expect(find.text('Tiempo juntos'), findsOneWidget);
      expect(find.byIcon(Icons.edit_calendar_rounded), findsOneWidget);
    });

    testWidgets('HomeScreen muestra estado vacío', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      expect(find.text('Elige una fecha para empezar a contar.'), findsOneWidget);
      expect(find.text('Elegir fecha'), findsOneWidget);
    });

    testWidgets('CardsScreen se renderiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardsScreen()));
      
      expect(find.text('Cartas'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('CardsScreen muestra tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardsScreen()));
      
      expect(find.text('Cartas'), findsOneWidget);
      expect(find.text('Mensajes'), findsOneWidget);
    });

    testWidgets('GalleryScreen se renderiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
      
      expect(find.text('Galería'), findsOneWidget);
      expect(find.byIcon(Icons.add_photo_alternate_rounded), findsOneWidget);
    });

    testWidgets('GalleryScreen muestra estado vacío', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
      
      expect(find.text('Aún no hay fotos'), findsOneWidget);
      expect(find.text('Añade tus recuerdos para verlos aquí ✨'), findsOneWidget);
    });

    testWidgets('App tiene tema oscuro', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, equals(Brightness.dark));
    });

    testWidgets('App tiene localización en español', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.locale, equals(const Locale('es')));
    });
  });
}
