import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

const Color _accent = Color(0xFFFF7FBF);

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

/// Editor expandible que usa controlador externo (para guardar bien)
class _ExpandingMarkdownEditor extends StatelessWidget {
  final TextEditingController controller;
  const _ExpandingMarkdownEditor({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.multiline,
      expands: true,
      maxLines: null,
      minLines: null,
      decoration: const InputDecoration(
        hintText: 'Contenido (Markdown)…',
        hintStyle: TextStyle(color: Colors.white54),
        contentPadding: EdgeInsets.all(12),
        border: InputBorder.none,
      ),
    );
  }
}

class _CardsScreenState extends State<CardsScreen>
    with SingleTickerProviderStateMixin {
  // Data
  final List<_CardItem> _cards = [];
  final List<_MsgItem> _msgs = [];

  // Loading
  bool _loading = true;

  // Tabs
  late final TabController _tabs;

  // Estilo romántico
  static const Color _bg1 = Color(0xFF0D0B12);
  static const Color _bg2 = Color(0xFF141320);
  static const Color _bg3 = Color(0xFF171628);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
    _loadAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // ========= Files =========
  Future<File> _cardsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/cards.json');
  }

  Future<File> _msgsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/messages.json');
  }

  // ========= Load/Save =========
  Future<void> _loadAll() async {
    await Future.wait([_loadCardsOnly(), _loadMsgsOnly()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadCardsOnly() async {
    try {
      final file = await _cardsFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        final list = (jsonDecode(raw) as List)
            .map((e) => _CardItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _cards
          ..clear()
          ..addAll(list);
      }
    } catch (_) {}
  }

  Future<void> _loadMsgsOnly() async {
    try {
      final file = await _msgsFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        final list = (jsonDecode(raw) as List)
            .map((e) => _MsgItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _msgs
          ..clear()
          ..addAll(list);
      }
    } catch (_) {}
  }

  Future<void> _saveCards() async {
    final file = await _cardsFile();
    final raw = jsonEncode(_cards.map((e) => e.toJson()).toList());
    await file.writeAsString(raw);
  }

  Future<void> _saveMsgs() async {
    final file = await _msgsFile();
    final raw = jsonEncode(_msgs.map((e) => e.toJson()).toList());
    await file.writeAsString(raw);
  }

  // ========= Crear CARTA =========
  Future<void> _addCardDialog() async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: Column(
                children: [
                  const SizedBox(height: 8),
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
                    'Nueva carta',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: titleCtrl,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Título',
                        labelStyle: const TextStyle(color: Colors.white70),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: _accent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: _ExpandingMarkdownEditor(
                          controller: contentCtrl,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (titleCtrl.text.trim().isEmpty ||
                                  contentCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Completa título y contenido',
                                    ),
                                  ),
                                );
                                return;
                              }
                              Navigator.pop(context, true);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Guardar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (ok == true) {
      final item = _CardItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleCtrl.text.trim(),
        content: contentCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      setState(() => _cards.insert(0, item));
      await _saveCards();
    }
  }

  // ========= Crear MENSAJE =========
  Future<void> _addMessageDialog() async {
    final authorCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    DateTime? customDate;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.92,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottom),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
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
                        'Nuevo mensaje',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Autor
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: authorCtrl,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Autor',
                            hintText: 'Nombre o @usuario',
                            hintStyle: const TextStyle(color: Colors.white54),
                            labelStyle: const TextStyle(color: Colors.white70),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: _accent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Selector de FECHA (opcional)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.event_rounded,
                                color: _accent.withOpacity(0.9),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  customDate == null
                                      ? 'Fecha: ahora (opcional)'
                                      : 'Fecha: ${_formatDate(customDate!)}',
                                  style: GoogleFonts.lora(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final now = DateTime.now();
                                  final picked = await showDatePicker(
                                    context: context,
                                    locale: const Locale('es'),
                                    initialDate: customDate ?? now,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(now.year + 50),
                                    builder: (context, child) {
                                      final scheme = const ColorScheme.dark(
                                        primary: _accent,
                                        surface: Color(0xFF12121A),
                                        onSurface: Colors.white,
                                      );
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: scheme,
                                          dialogBackgroundColor: const Color(
                                            0xFF12121A,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setModalState(() {
                                      customDate = DateTime(
                                        picked.year,
                                        picked.month,
                                        picked.day,
                                      );
                                    });
                                  }
                                },
                                child: Text(
                                  customDate == null
                                      ? 'Elegir fecha'
                                      : 'Cambiar',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              if (customDate != null)
                                IconButton(
                                  tooltip: 'Quitar fecha',
                                  onPressed: () =>
                                      setModalState(() => customDate = null),
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Contenido ocupa el resto
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: TextField(
                              controller: contentCtrl,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.multiline,
                              expands: true,
                              maxLines: null,
                              minLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Escribe tu mensaje…',
                                hintStyle: TextStyle(color: Colors.white54),
                                contentPadding: EdgeInsets.all(12),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Botones
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  if (authorCtrl.text.trim().isEmpty ||
                                      contentCtrl.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Completa autor y contenido',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.pop(context, true);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Guardar'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (ok == true) {
      final item = _MsgItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        author: authorCtrl.text.trim(),
        content: contentCtrl.text.trim(),
        createdAt:
            customDate ?? DateTime.now(), // <- usa la fecha elegida o "ahora"
      );
      setState(() => _msgs.insert(0, item));
      await _saveMsgs();
    }
  }

  // ========= Lector CARTA =========
  Future<void> _openCard(_CardItem item) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF12121A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 560, minWidth: 320),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.06),
                          Colors.white.withOpacity(0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, color: _accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          onPressed: () async {
                            final confirm = await _confirmDelete(
                              context,
                              'Eliminar carta',
                            );
                            if (confirm == true) {
                              Navigator.pop(context);
                              setState(
                                () =>
                                    _cards.removeWhere((c) => c.id == item.id),
                              );
                              await _saveCards();
                            }
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatDate(item.createdAt),
                    style: GoogleFonts.lora(
                      color: Colors.white54,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: Markdown(
                        selectable: true,
                        shrinkWrap: true,
                        data: item.content,
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.lora(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 16,
                            height: 1.45,
                          ),
                          h1: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                          h2: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          em: const TextStyle(color: Colors.white70),
                          strong: const TextStyle(color: _accent),
                          blockquoteDecoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            border: Border(
                              left: BorderSide(
                                color: _accent.withOpacity(0.7),
                                width: 3,
                              ),
                            ),
                          ),
                          blockquotePadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          code: GoogleFonts.robotoMono(color: Colors.white),
                          codeblockPadding: const EdgeInsets.all(12),
                          codeblockDecoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          listBullet: GoogleFonts.lora(color: Colors.white),
                          horizontalRuleDecoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ========= Lector MENSAJE (burbuja / tweet) =========
  Future<void> _openMessage(_MsgItem item) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF12121A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 480, minWidth: 320),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabecera estilo tweet
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _accent.withOpacity(0.2),
                        child: Text(
                          item.author.isNotEmpty
                              ? item.author[0].toUpperCase()
                              : '🙂',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.author,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        onPressed: () async {
                          final confirm = await _confirmDelete(
                            context,
                            'Eliminar mensaje',
                          );
                          if (confirm == true) {
                            Navigator.pop(context);
                            setState(
                              () => _msgs.removeWhere((m) => m.id == item.id),
                            );
                            await _saveMsgs();
                          }
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Burbuja tipo WhatsApp/Tweet
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.10)),
                    ),
                    child: Text(
                      item.content,
                      style: GoogleFonts.lora(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatDate(item.createdAt),
                      style: GoogleFonts.lora(
                        color: Colors.white54,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext ctx, String title) {
    return showDialog<bool>(
      context: ctx,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: const Text(
          '¿Seguro que quieres eliminarlo?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    final bg = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_bg1, _bg2, _bg3],
    );

    return Container(
      decoration: BoxDecoration(gradient: bg),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.2),
          elevation: 0,
          centerTitle: true,
          title: Text(
            _tabs.index == 0 ? 'Cartas' : 'Mensajes',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: _accent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Cartas', icon: Icon(Icons.menu_book_rounded)),
              Tab(text: 'Mensajes', icon: Icon(Icons.sms_rounded)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: _tabs.index == 0 ? 'Nueva carta' : 'Nuevo mensaje',
              onPressed: _tabs.index == 0 ? _addCardDialog : _addMessageDialog,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabs,
                children: [
                  // === Cartas ===
                  _cards.isEmpty
                      ? _EmptyCards(onAdd: _addCardDialog)
                      : Scrollbar(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            itemCount: _cards.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) => _CardTile(
                              item: _cards[i],
                              onTap: () => _openCard(_cards[i]),
                              onDelete: () async {
                                setState(() => _cards.removeAt(i));
                                await _saveCards();
                              },
                            ),
                          ),
                        ),

                  // === Mensajes ===
                  _msgs.isEmpty
                      ? _EmptyMessages(onAdd: _addMessageDialog)
                      : Scrollbar(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            itemCount: _msgs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) => _MsgTile(
                              item: _msgs[i],
                              onTap: () => _openMessage(_msgs[i]),
                              onDelete: () async {
                                setState(() => _msgs.removeAt(i));
                                await _saveMsgs();
                              },
                            ),
                          ),
                        ),
                ],
              ),
      ),
    );
  }
}

// ====== UI Tiles ======

class _CardTile extends StatelessWidget {
  final _CardItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CardTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.02),
            ],
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.favorite_border_rounded, color: _accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lora(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDateStatic(item.createdAt),
                    style: GoogleFonts.lora(
                      color: Colors.white54,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Eliminar',
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDateStatic(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }
}

class _MsgTile extends StatelessWidget {
  final _MsgItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MsgTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _accent.withOpacity(0.2),
              child: Text(
                item.author.isNotEmpty ? item.author[0].toUpperCase() : '🙂',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: item.author,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: '  ·  ${_formatDateStatic(item.createdAt)}',
                          style: GoogleFonts.lora(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.preview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lora(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Eliminar',
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDateStatic(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }
}

class _EmptyCards extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyCards({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded, size: 72, color: _accent),
            const SizedBox(height: 12),
            Text(
              'Aún no hay cartas',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escribe tu primera carta ✨',
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nueva carta'),
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyMessages({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sms_rounded, size: 72, color: _accent),
            const SizedBox(height: 12),
            Text(
              'Aún no hay mensajes',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Añade tus mensajes favoritos 💬',
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo mensaje'),
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====== Models ======

class _CardItem {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  _CardItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  String get preview {
    final text = content
        .replaceAll(RegExp(r'[>#*_`]+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return text.length <= 120 ? text : '${text.substring(0, 120)}…';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory _CardItem.fromJson(Map<String, dynamic> json) => _CardItem(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class _MsgItem {
  final String id;
  final String author;
  final String content;
  final DateTime createdAt;

  _MsgItem({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  String get preview {
    final text = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.length <= 160 ? text : '${text.substring(0, 160)}…';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory _MsgItem.fromJson(Map<String, dynamic> json) => _MsgItem(
    id: json['id'] as String,
    author: json['author'] as String,
    content: json['content'] as String,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
