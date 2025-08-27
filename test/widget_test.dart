// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chrono_gallery/main.dart';

void main() {
  group('App Tests', () {
    testWidgets('App se renderiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Verifica que la app se renderiza
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
  });
}
