import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const _accent = Color(0xFFFF7FBF);
  static const _bg1 = Color(0xFF0D0B12);
  static const _bg2 = Color(0xFF141320);
  static const _bg3 = Color(0xFF171628);

  final List<_GalleryItem> _items = [];
  bool _loading = true;
  String? _folderFilter; // null = Todas

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // ------------------ Persistencia ------------------

  Future<Directory> _photosDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final photos = Directory('${dir.path}/gallery_photos');
    if (!await photos.exists()) {
      await photos.create(recursive: true);
    }
    return photos;
  }

  Future<File> _jsonFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/gallery.json');
  }

  Future<void> _loadItems() async {
    try {
      final file = await _jsonFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        final list = (jsonDecode(raw) as List)
            .map((e) => _GalleryItem.fromJson(e as Map<String, dynamic>))
            .toList();

        // Limpieza: descarta entradas cuyo archivo ya no exista
        final photos = await _photosDir();
        final kept = <_GalleryItem>[];
        for (final it in list) {
          final f = File('${photos.path}/${it.relativePath}');
          if (await f.exists()) kept.add(it);
        }

        _items
          ..clear()
          ..addAll(kept);
      }
    } catch (_) {
      // en caso de error, continuamos con lista vacía
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveItems() async {
    final file = await _jsonFile();
    final raw = jsonEncode(_items.map((e) => e.toJson()).toList());
    await file.writeAsString(raw);
  }

  // ------------------ Acciones ------------------

  Future<void> _pickPhotos() async {
    try {
      final picker = ImagePicker();
      List<XFile> files = [];

      // pickMultiImage (mejor UX)
      final many = await picker.pickMultiImage();
      if (many != null && many.isNotEmpty) {
        files = many;
      } else {
        // fallback a una sola
        final one = await picker.pickImage(source: ImageSource.gallery);
        if (one != null) files = [one];
      }

      if (files.isEmpty) return;

      final photosDir = await _photosDir();

      for (final xf in files) {
        final ext = xf.name.contains('.') ? xf.name.split('.').last : 'jpg';
        final id = DateTime.now().microsecondsSinceEpoch.toString();
        final filename = '$id.$ext';
        final dest = File('${photosDir.path}/$filename');

        await File(xf.path).copy(dest.path);

        final item = _GalleryItem(
          id: id,
          relativePath: filename, // guardamos solo el relativo
          createdAt: DateTime.now(),
          folder:
              _folderFilter, // si estás filtrando una carpeta, añade ahí directo
        );

        _items.insert(0, item); // al principio
      }

      await _saveItems();
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron añadir fotos: $e')),
      );
    }
  }

  Future<void> _onLongPressItem(_GalleryItem item) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final folders = _allFolders();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
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
                  'Opciones',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),

                ListTile(
                  leading: const Icon(
                    Icons.create_new_folder_rounded,
                    color: _accent,
                  ),
                  title: const Text(
                    'Crear carpeta',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final name = await _askFolderName();
                    if (name != null && name.trim().isNotEmpty) {
                      setState(() => item.folder = name.trim());
                      await _saveItems();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.drive_file_move_rounded,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'Mover a carpeta',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final target = await _pickFolder(folders);
                    if (target != null) {
                      setState(
                        () =>
                            item.folder = target == '__none__' ? null : target,
                      );
                      await _saveItems();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _askFolderName() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        title: const Text(
          'Nueva carpeta',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nombre (ej. Verano 2024)',
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: _accent),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<String?> _pickFolder(List<String> folders) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final all = ['__none__', ...folders];
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemBuilder: (_, i) {
              final f = all[i];
              return ListTile(
                leading: Icon(
                  f == '__none__' ? Icons.clear_rounded : Icons.folder_rounded,
                  color: f == '__none__' ? Colors.white70 : _accent,
                ),
                title: Text(
                  f == '__none__' ? 'Quitar de carpeta' : f,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(ctx, f),
              );
            },
            separatorBuilder: (_, __) =>
                const Divider(color: Colors.white12, height: 1),
            itemCount: all.length,
          ),
        );
      },
    );
  }

  // ------------------ Helpers UI / datos ------------------

  List<String> _allFolders() {
    final s = <String>{};
    for (final it in _items) {
      if (it.folder != null && it.folder!.trim().isNotEmpty)
        s.add(it.folder!.trim());
    }
    final list = s.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  // agrupa por fecha (formato dd/MM/yyyy) y devuelve pares (DateTime, List<_GalleryItem>)
  List<_DateGroup> _groupsFilteredSorted() {
    // filtro por carpeta
    final filtered = _folderFilter == null
        ? _items
        : _items.where((e) => e.folder == _folderFilter).toList();

    // ordenar por fecha desc
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // agrupar por día
    final map = <String, List<_GalleryItem>>{};
    final order = <String, DateTime>{};

    for (final it in filtered) {
      final d = DateTime(
        it.createdAt.year,
        it.createdAt.month,
        it.createdAt.day,
      );
      final key =
          '${_two(d.day)}/${_two(d.month)}/${d.year.toString().padLeft(4, '0')}';
      map.putIfAbsent(key, () => []).add(it);
      order[key] = d;
    }

    final groups =
        map.entries
            .map(
              (e) =>
                  _DateGroup(label: e.key, day: order[e.key]!, items: e.value),
            )
            .toList()
          ..sort((a, b) => b.day.compareTo(a.day));

    return groups;
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  int _calcCrossAxisCount(double width) {
    if (width >= 1200) return 6;
    if (width >= 900) return 5;
    if (width >= 700) return 4;
    if (width >= 500) return 3;
    return 2;
  }

  // ------------------ UI ------------------

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
            'Galería',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Añadir fotos',
              onPressed: _pickPhotos,
              icon: const Icon(
                Icons.add_photo_alternate_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
            ? _EmptyGallery(onAdd: _pickPhotos)
            : Column(
                children: [
                  _FolderChips(
                    folders: _allFolders(),
                    current: _folderFilter,
                    onChanged: (f) => setState(() => _folderFilter = f),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Scrollbar(
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final groups = _groupsFilteredSorted();
                          final crossAxisCount = _calcCrossAxisCount(
                            c.maxWidth,
                          );
                          final cellSpacing = 10.0;

                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                            itemCount: groups.length,
                            itemBuilder: (context, i) {
                              final g = groups[i];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _DateHeader(label: g.label),
                                  const SizedBox(height: 8),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          mainAxisSpacing: cellSpacing,
                                          crossAxisSpacing: cellSpacing,
                                        ),
                                    itemCount: g.items.length,
                                    itemBuilder: (context, j) {
                                      return _PhotoTile(
                                        item: g.items[j],
                                        onTap: () => _openViewer(g.items, j),
                                        onLongPress: () =>
                                            _onLongPressItem(g.items[j]),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _openViewer(List<_GalleryItem> list, int index) async {
    final photosDir = await _photosDir();
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) {
        final item = list[index];
        final file = File('${photosDir.path}/${item.relativePath}');
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: const Color(0xFF0F0F17),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(file, fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ------------------ Widgets auxiliares ------------------

class _FolderChips extends StatelessWidget {
  final List<String> folders;
  final String? current;
  final ValueChanged<String?> onChanged;
  const _FolderChips({
    required this.folders,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    void addChip(String? value, String label) {
      final selected = current == value;
      chips.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ChoiceChip(
            selected: selected,
            onSelected: (_) => onChanged(value),
            label: Text(label),
            labelStyle: TextStyle(
              color: selected ? Colors.black : Colors.white70,
            ),
            selectedColor: _GalleryScreenState._accent,
            backgroundColor: Colors.white12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    addChip(null, 'Todas');
    for (final f in folders) {
      addChip(f, f);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
      child: Row(children: chips),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
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
          const Icon(Icons.today_rounded, color: _GalleryScreenState._accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.lora(
              color: Colors.white,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final _GalleryItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _PhotoTile({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Directory>(
      future: getApplicationDocumentsDirectory(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        final file = File(
          '${snap.data!.path}/gallery_photos/${item.relativePath}',
        );
        return GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(color: const Color(0xFF101018)),
                ),
                Positioned.fill(child: Image.file(file, fit: BoxFit.cover)),
                // Etiqueta de carpeta (si tiene)
                if (item.folder != null && item.folder!.isNotEmpty)
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.folder_rounded,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.folder!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyGallery({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_library_rounded,
              size: 72,
              color: _GalleryScreenState._accent,
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no hay fotos',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Añade tus recuerdos para verlos aquí ✨',
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: const Text('Añadir fotos'),
              style: FilledButton.styleFrom(
                backgroundColor: _GalleryScreenState._accent,
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

// ------------------ Modelos ------------------

class _GalleryItem {
  final String id;
  final String relativePath; // dentro de gallery_photos
  final DateTime createdAt;
  String? folder;

  _GalleryItem({
    required this.id,
    required this.relativePath,
    required this.createdAt,
    this.folder,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'relativePath': relativePath,
    'createdAt': createdAt.toIso8601String(),
    'folder': folder,
  };

  factory _GalleryItem.fromJson(Map<String, dynamic> json) => _GalleryItem(
    id: json['id'] as String,
    relativePath: json['relativePath'] as String,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    folder: json['folder'] as String?,
  );
}

class _DateGroup {
  final String label;
  final DateTime day;
  final List<_GalleryItem> items;

  _DateGroup({required this.label, required this.day, required this.items});
}
