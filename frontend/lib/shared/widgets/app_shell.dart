import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Persistent shell with bottom navigation bar.
///
/// The [child] is swapped by GoRouter's ShellRoute while the
/// bottom bar stays mounted — no rebuild flicker between tabs.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    ('/map', Icons.map_rounded, 'Map'),
    ('/scanner', Icons.qr_code_scanner_rounded, 'Scanner'),
    ('/navigate', Icons.navigation_rounded, 'Navigate'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final idx = _tabs.indexWhere((t) => location.startsWith(t.$1));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => context.go(_tabs[i].$1),
        items: [
          for (final tab in _tabs)
            BottomNavigationBarItem(
              icon: Icon(tab.$2),
              label: tab.$3,
            ),
        ],
      ),
    );
  }
}
