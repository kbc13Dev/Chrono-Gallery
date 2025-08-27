import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chrono_gallery/main.dart';
import 'package:chrono_gallery/screens/home_screen.dart';
import 'package:chrono_gallery/screens/cards_screen.dart';
import 'package:chrono_gallery/screens/gallery_screen.dart';

void main() {
  group('Tests Finales de Chrono Gallery', () {
    testWidgets('App principal se renderiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Tiempo juntos'), findsOneWidget);
    });

    testWidgets('App tiene tema oscuro configurado', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, equals(Brightness.dark));
      expect(materialApp.theme?.useMaterial3, isTrue);
    });

    testWidgets('App tiene localización en español', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.locale, equals(const Locale('es')));
      expect(materialApp.supportedLocales, contains(const Locale('es')));
    });

    testWidgets('HomeScreen se renderiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      expect(find.text('Tiempo juntos'), findsOneWidget);
      expect(find.byIcon(Icons.edit_calendar_rounded), findsOneWidget);
    });

    testWidgets('HomeScreen muestra estado vacío inicialmente', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      expect(find.text('Elige una fecha para empezar a contar.'), findsOneWidget);
      expect(find.text('Elegir fecha'), findsOneWidget);
    });

    testWidgets('CardsScreen se renderiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardsScreen()));
      
      // Verifica que existe la AppBar con el título
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('CardsScreen muestra tabs de navegación', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardsScreen()));
      
      // Verifica que existen los tabs
      expect(find.byType(Tab), findsNWidgets(2));
    });

    testWidgets('GalleryScreen se renderiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
      
      expect(find.text('Galería'), findsOneWidget);
      expect(find.byIcon(Icons.add_photo_alternate_rounded), findsOneWidget);
    });

    testWidgets('GalleryScreen tiene estructura de navegación', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
      
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.add_photo_alternate_rounded), findsOneWidget);
    });

    testWidgets('Todas las pantallas principales existen', (WidgetTester tester) async {
      // Verifica que se pueden renderizar todas las pantallas principales
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      expect(find.byType(HomeScreen), findsOneWidget);
      
      await tester.pumpWidget(const MaterialApp(home: CardsScreen()));
      expect(find.byType(CardsScreen), findsOneWidget);
      
      await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
      expect(find.byType(GalleryScreen), findsOneWidget);
    });

    testWidgets('App mantiene configuración consistente', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verifica configuración del tema
      expect(materialApp.theme?.brightness, equals(Brightness.dark));
      expect(materialApp.theme?.useMaterial3, isTrue);
      
      // Verifica configuración de localización
      expect(materialApp.locale, equals(const Locale('es')));
      expect(materialApp.supportedLocales.length, equals(2));
      expect(materialApp.supportedLocales, contains(const Locale('es')));
      expect(materialApp.supportedLocales, contains(const Locale('en')));
      
      // Verifica que no se muestra el banner de debug
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });
  });
}
