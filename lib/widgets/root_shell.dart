import 'package:chrono_gallery/screens/cards_screen.dart';
import 'package:chrono_gallery/screens/gallery_screen.dart';
import 'package:chrono_gallery/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 1; // 0: Cartas | 1: Home | 2: Galería
  final _pages = const [CardsScreen(), HomeScreen(), GalleryScreen()];

  @override
  Widget build(BuildContext context) {
    const barBg = Color(0xFF12121A);
    const accent = Color(0xFFFF7FBF);

    // Ajustes de tamaño del nav
    const double navHeight = 96;
    const double circleW = 76;
    const double iconSize = 26;

    // Levantar un poco los iconos INACTIVOS
    const double lift = 14.0; // sube/ baja este valor a tu gusto

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),

      bottomNavigationBar: CircleNavBar(
        padding: EdgeInsets.zero,
        height: navHeight,
        circleWidth: circleW,
        color: barBg,
        circleColor: accent,
        shadowColor: Colors.black54,
        circleShadowColor: Colors.black54,
        cornerRadius: BorderRadius.zero,

        activeIndex: _index,
        onTap: (i) => setState(() => _index = i),

        // Activos (icono dentro del círculo): sin desplazamiento
        activeIcons: const [
          Icon(
            Icons.collections_bookmark_rounded,
            color: Colors.white,
            size: iconSize,
          ),
          Icon(Icons.home_rounded, color: Colors.black, size: iconSize),
          Icon(
            Icons.photo_library_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        ],

        // Inactivos: desplazados hacia ARRIBA
        inactiveIcons: [
          Transform.translate(
            offset: const Offset(0, -lift),
            child: const Icon(
              Icons.collections_bookmark_rounded,
              color: Colors.white70,
              size: iconSize,
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -lift),
            child: const Icon(
              Icons.home_outlined,
              color: Colors.white70,
              size: iconSize,
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -lift),
            child: const Icon(
              Icons.photo_library_outlined,
              color: Colors.white70,
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }
}
