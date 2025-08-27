import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chrono_gallery/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';

void main() {
  group('HomeScreen Tests', () {
    late SharedPreferences prefs;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    tearDown(() async {
      await prefs.clear();
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
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('HomeScreen muestra selector de fecha', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      // Toca el botón de editar fecha
      await tester.tap(find.byIcon(Icons.edit_calendar_rounded));
      await tester.pumpAndSettle();
      
      // Verifica que se muestra el selector de fecha
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('HomeScreen maneja fecha guardada', (WidgetTester tester) async {
      // Simula una fecha guardada
      final testDate = DateTime(2024, 1, 1);
      await prefs.setInt('start_date_ms', testDate.millisecondsSinceEpoch);
      
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();
      
      // Verifica que se muestra la fecha guardada
      expect(find.text('Desde: 01/01/2024'), findsOneWidget);
      expect(find.byType(CircularPercentIndicator), findsNWidgets(5));
    });

    testWidgets('HomeScreen muestra menú de edición', (WidgetTester tester) async {
      // Simula una fecha guardada
      final testDate = DateTime(2024, 1, 1);
      await prefs.setInt('start_date_ms', testDate.millisecondsSinceEpoch);
      
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();
      
      // Toca el botón de editar fecha
      await tester.tap(find.byIcon(Icons.edit_calendar_rounded));
      await tester.pumpAndSettle();
      
      // Verifica que se muestra el menú de edición
      expect(find.text('Editar fecha'), findsOneWidget);
      expect(find.text('Cambiar fecha'), findsOneWidget);
      expect(find.text('Borrar fecha'), findsOneWidget);
    });

    testWidgets('HomeScreen calcula tiempo transcurrido correctamente', (WidgetTester tester) async {
      // Simula una fecha guardada hace 1 día
      final testDate = DateTime.now().subtract(const Duration(days: 1));
      await prefs.setInt('start_date_ms', testDate.millisecondsSinceEpoch);
      
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();
      
      // Verifica que se muestran los indicadores de tiempo
      expect(find.byType(CircularPercentIndicator), findsNWidgets(5));
      
      // Verifica que se muestra al menos 1 día
      expect(find.textContaining('1'), findsAtLeastNWidgets(1));
    });
  });
}
