import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/map/map_screen.dart';
import '../features/scanner/scanner_screen.dart';
import '../features/navigation/navigation_screen.dart';
import '../shared/widgets/app_shell.dart';

/// GoRouter provider — consumed via `ref.watch(routerProvider)`.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/map',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/map',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MapScreen(),
            ),
          ),
          GoRoute(
            path: '/scanner',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ScannerScreen(),
            ),
          ),
          GoRoute(
            path: '/navigate',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NavigationScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
