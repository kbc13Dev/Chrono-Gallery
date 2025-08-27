import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Utils Tests', () {
    group('Cálculos de fecha', () {
      test('formateo de fecha DD/MM/YYYY', () {
        final date = DateTime(2024, 12, 25);
        final formatted = _formatDate(date);
        expect(formatted, equals('25/12/2024'));
      });

      test('formateo de fecha con día y mes de un dígito', () {
        final date = DateTime(2024, 3, 5);
        final formatted = _formatDate(date);
        expect(formatted, equals('05/03/2024'));
      });

      test('cálculo de años bisiestos', () {
        expect(_isLeap(2020), isTrue);   // 2020 es bisiesto
        expect(_isLeap(2024), isTrue);   // 2024 es bisiesto
        expect(_isLeap(2023), isFalse);  // 2023 no es bisiesto
        expect(_isLeap(2100), isFalse);  // 2100 no es bisiesto (regla del siglo)
        expect(_isLeap(2000), isTrue);   // 2000 es bisiesto (excepción)
      });

      test('días en mes', () {
        expect(_daysInMonth(2024, 1), equals(31));  // Enero
        expect(_daysInMonth(2024, 2), equals(29));  // Febrero bisiesto
        expect(_daysInMonth(2023, 2), equals(28));  // Febrero no bisiesto
        expect(_daysInMonth(2024, 4), equals(30));  // Abril
        expect(_daysInMonth(2024, 12), equals(31)); // Diciembre
      });

      test('fecha segura', () {
        final safe = _safeDate(2024, 2, 30); // 30 de febrero no existe
        expect(safe.day, equals(29)); // Se ajusta al máximo del mes
        
        final safe2 = _safeDate(2024, 2, 0); // 0 de febrero no existe
        expect(safe2.day, equals(1)); // Se ajusta al mínimo del mes
      });

      test('años completos entre fechas', () {
        final start = DateTime(2020, 6, 15);
        final end = DateTime(2024, 6, 14); // Un día antes del aniversario
        expect(_fullYearsBetween(start, end), equals(3));
        
        final end2 = DateTime(2024, 6, 15); // En el aniversario
        expect(_fullYearsBetween(start, end2), equals(4));
        
        final end3 = DateTime(2024, 6, 16); // Un día después del aniversario
        expect(_fullYearsBetween(start, end3), equals(4));
      });
    });

    group('Cálculos de progreso', () {
      test('progreso de horas en un día', () {
        final now = DateTime(2024, 1, 1, 12, 30, 0); // 12:30
        final hourPct = (12 + 30 / 60.0 + 0 / 3600.0) / 24.0;
        expect(hourPct, greaterThan(0.5)); // Más de la mitad del día
        expect(hourPct, lessThan(0.6));    // Menos de 60% del día
      });

      test('progreso de minutos en una hora', () {
        final minutePct = (30 + 15 / 60.0) / 60.0; // 30:15
        expect(minutePct, equals(0.5 + 0.25)); // 50% + 25% de minuto
      });

      test('progreso de segundos en un minuto', () {
        final secondPct = (45 + 500 / 1000.0) / 60.0; // 45.5 segundos
        expect(secondPct, equals(45.5 / 60.0));
      });
    });
  });
}

// Funciones auxiliares para testing (copiadas del código real)
String _formatDate(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final y = dt.year.toString().padLeft(4, '0');
  return '$d/$m/$y';
}

bool _isLeap(int y) => (y % 4 == 0) && ((y % 100 != 0) || (y % 400 == 0));

int _daysInMonth(int y, int m) {
  const dm = [31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (m == 2) return _isLeap(y) ? 29 : 28;
  return dm[m - 1];
}

DateTime _safeDate(int y, int m, int d) {
  final dim = _daysInMonth(y, m);
  final dd = d.clamp(1, dim);
  return DateTime(y, m, dd);
}

int _fullYearsBetween(DateTime start, DateTime end) {
  var years = end.year - start.year;
  final annivThisYear = _safeDate(end.year, start.month, start.day);
  if (end.isBefore(annivThisYear)) years -= 1;
  return years.clamp(0, 1000000);
}
