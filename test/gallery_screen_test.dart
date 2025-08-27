import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chrono_gallery/screens/gallery_screen.dart';

void main() {
  group('GalleryScreen Tests', () {
    testWidgets('GalleryScreen se renderiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
      
      expect(find.text('Galería'), findsOneWidget);
      expect(find.byIcon(Icons.add_photo_alternate_rounded), findsOneWidget);
    });

    testWidgets('GalleryScreen muestra estado vacío inicialmente', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
      
      expect(find.text('Aún no hay fotos'), findsOneWidget);
      expect(find.text('Añade tus recuerdos para verlos aquí ✨'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
    });

    testWidgets('GalleryScreen muestra botón de añadir fotos', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
      
      // Verifica que existe el botón de añadir fotos
      expect(find.text('Añadir fotos'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('GalleryScreen muestra filtros de carpetas', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
      
      // Verifica que se muestra el filtro "Todas"
      expect(find.text('Todas'), findsOneWidget);
    });

    testWidgets('GalleryScreen tiene estructura de navegación correcta', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
      
      // Verifica que existe la AppBar
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verifica que existe el botón de acción
      expect(find.byIcon(Icons.add_photo_alternate_rounded), findsOneWidget);
    });
  });
}
