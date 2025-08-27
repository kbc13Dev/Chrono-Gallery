import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _prefsKey = 'start_date_ms';
  DateTime? _startDate;
  Duration _elapsed = Duration.zero;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadSavedDate();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_prefsKey);
    if (ms != null) {
      _startDate = DateTime.fromMillisecondsSinceEpoch(ms);
      _startTicker();
    } else {
      setState(() {}); // estado vacío
    }
  }

  Future<void> _saveDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, date.millisecondsSinceEpoch);
  }

  Future<void> _clearDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _ticker?.cancel();
    setState(() {
      _startDate = null;
      _elapsed = Duration.zero;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('es'),
      initialDate: _startDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 50),
      builder: (context, child) {
        final scheme = const ColorScheme.dark(
          primary: Color(0xFFFF7FBF),
          surface: Color(0xFF12121A),
          onSurface: Colors.white,
        );
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: scheme,
            dialogBackgroundColor: const Color(0xFF12121A),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final normalized = DateTime(picked.year, picked.month, picked.day);
      _startDate = normalized;
      await _saveDate(normalized);
      _startTicker();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _recalculate();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _recalculate());
  }

  void _recalculate() {
    if (_startDate == null) return;
    final diff = DateTime.now().difference(_startDate!);
    setState(() => _elapsed = diff.isNegative ? Duration.zero : diff);
  }

  // ---------- helpers de fecha / aniversario ----------
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
  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bg = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0D0B12), Color(0xFF141320), Color(0xFF171628)],
    );

    final titleStyle = GoogleFonts.playfairDisplay(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: Colors.white,
    );
    final subStyle = GoogleFonts.lora(
      fontSize: 14,
      fontStyle: FontStyle.italic,
      color: Colors.white70,
    );
    final accent = const Color(0xFFFF7FBF);

    // unidades base
    final hours = _elapsed.inHours % 24;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;

    // ---- cálculo de años y ciclo anual relativo a la fecha elegida ----
    final now = DateTime.now();
    int years = 0;
    int daysSinceAnniv = 0;
    double yearPct = 0.0; // 0..1 hasta 100 años
    double dayPct = 0.0; // 0..1 dentro del año actual

    if (_startDate != null) {
      years = _fullYearsBetween(_startDate!, now);

      final lastAnniv = _safeDate(
        _startDate!.year + years,
        _startDate!.month,
        _startDate!.day,
      );
      final nextAnniv = _safeDate(
        lastAnniv.year + 1,
        _startDate!.month,
        _startDate!.day,
      );

      final sinceLast = now.difference(lastAnniv);
      final cycleLength = nextAnniv.difference(lastAnniv);

      // DÍAS desde el último aniversario (valor mostrado)
      daysSinceAnniv = sinceLast.inDays.clamp(0, 400);

      // Progreso suave de DÍAS dentro del año (con seg/miliseg)
      final secondsSinceLast = sinceLast.inMilliseconds / 1000.0;
      final secondsCycle = cycleLength.inMilliseconds / 1000.0;
      dayPct = secondsCycle <= 0
          ? 0.0
          : (secondsSinceLast / secondsCycle).clamp(0.0, 1.0);

      // Progreso de AÑOS hacia 100 (años + fracción del año actual)
      final yearsExact =
          years + (secondsCycle <= 0 ? 0.0 : (secondsSinceLast / secondsCycle));
      yearPct = (yearsExact / 100.0).clamp(0.0, 1.0);
    }

    // HORAS/MIN/SEG con progreso fraccional
    final hourPct = (hours + minutes / 60.0 + seconds / 3600.0) / 24.0;
    final minutePct = (minutes + seconds / 60.0) / 60.0;
    final secondPct = (seconds + now.millisecond / 1000.0) / 60.0;

    // Config para distribución: en vertical 2 cols (3 filas), en horizontal 3 cols (2 filas)
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final cols = isPortrait ? 2 : 3;
    final rows = isPortrait ? 3 : 2;

    return Container(
      decoration: BoxDecoration(gradient: bg),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.2),
          elevation: 0,
          centerTitle: true,
          title: Text('Tiempo juntos', style: titleStyle),
          actions: [
            IconButton(
              tooltip: 'Editar fecha',
              onPressed: _startDate == null ? _pickDate : _showEditMenu,
              icon: const Icon(
                Icons.edit_calendar_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: _startDate == null
              ? _EmptyState(
                  onPick: _pickDate,
                  accent: accent,
                  subStyle: subStyle,
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeaderDate(
                        date: _startDate!,
                        labelStyle: subStyle,
                        accent: accent,
                      ),
                      const SizedBox(height: 16),

                      // ====== Área central con 5 aros (SEG centrado en la última fila) ======
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, c) {
                            const spacing = 16.0;

                            // Tamaño de celda objetivo según rejilla teórica (cols x rows)
                            final cellW =
                                (c.maxWidth - (cols - 1) * spacing) / cols;
                            final cellH =
                                (c.maxHeight - (rows - 1) * spacing) / rows;
                            double dim = cellW < cellH ? cellW : cellH;
                            dim = dim.clamp(80.0, 9999.0);

                            // Construimos en orden y centramos automáticamente con Wrap
                            final items = <Widget>[
                              _buildRingBox(dim, 'AÑOS', '$years', yearPct),
                              _buildRingBox(
                                dim,
                                'DÍAS',
                                '$daysSinceAnniv',
                                dayPct,
                              ),
                              _buildRingBox(
                                dim,
                                'HORAS',
                                hours.toString().padLeft(2, '0'),
                                hourPct,
                              ),
                              _buildRingBox(
                                dim,
                                'MIN',
                                minutes.toString().padLeft(2, '0'),
                                minutePct,
                              ),
                              _buildRingBox(
                                dim,
                                'SEG',
                                seconds.toString().padLeft(2, '0'),
                                secondPct,
                              ),
                            ];

                            return Center(
                              child: Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                alignment:
                                    WrapAlignment.center, // centra cada fila
                                runAlignment: WrapAlignment
                                    .center, // centra verticalmente
                                children: items,
                              ),
                            );
                          },
                        ),
                      ),
                      // =========================================================================
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // Caja cuadrada de tamaño fijo 'dim' con el anillo dentro
  Widget _buildRingBox(double dim, String label, String center, double pct) {
    final lineW = (dim * 0.10).clamp(8.0, 14.0);
    final radius = (dim / 2 - lineW / 2).clamp(24.0, dim);

    return SizedBox(
      width: dim,
      height: dim,
      child: CircularPercentIndicator(
        radius: radius,
        lineWidth: lineW,
        animation: true,
        animateFromLastPercent: true,
        animationDuration: 900,
        percent: pct.clamp(0.0, 1.0),
        circularStrokeCap: CircularStrokeCap.round,
        center: Text(
          center,
          style: GoogleFonts.poppins(
            fontSize: (radius * 0.8 / 2 + 14),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        footer: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: GoogleFonts.lora(color: Colors.white70, fontSize: 12),
          ),
        ),
        backgroundColor: Colors.white12,
        progressColor: const Color(0xFFFF7FBF),
      ),
    );
  }

  void _showEditMenu() {
    final accent = const Color(0xFFFF7FBF);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Editar fecha',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.calendar_month_rounded, color: accent),
                  title: const Text(
                    'Cambiar fecha',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickDate();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Borrar fecha',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _clearDate();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onPick;
  final Color accent;
  final TextStyle subStyle;
  const _EmptyState({
    required this.onPick,
    required this.accent,
    required this.subStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 72,
              color: accent.withOpacity(0.9),
            ),
            const SizedBox(height: 12),
            Text(
              'Elige una fecha para empezar a contar.',
              style: subStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('Elegir fecha'),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderDate extends StatelessWidget {
  final DateTime date;
  final TextStyle labelStyle;
  final Color accent;
  const _HeaderDate({
    required this.date,
    required this.labelStyle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final formatted =
        '${two(date.day)}/${two(date.month)}/${date.year.toString().padLeft(4, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_rounded, color: accent),
          const SizedBox(width: 10),
          Text('Desde: $formatted', style: labelStyle),
        ],
      ),
    );
  }
}
