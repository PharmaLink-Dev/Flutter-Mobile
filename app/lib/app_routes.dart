import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/scan/presentation/scan_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/profile/presentation/profile_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _ShellScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const HomeScreen(),
              // ตัวอย่างหน้าลูกของ Home (เพิ่มได้ตามต้องการ):
              // routes: [GoRoute(path: 'detail', builder: ...)],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),
      ],
    ),
  ],
);

class _ShellScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const _ShellScaffold({required this.navigationShell});

  @override
  State<_ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<_ShellScaffold> {
  int get _currentIndex => widget.navigationShell.currentIndex;

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == _currentIndex,
    );
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  body: widget.navigationShell,
  bottomNavigationBar: NavigationBar(
    selectedIndex: _currentIndex,
    onDestinationSelected: _onTap,
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
      NavigationDestination(icon: Icon(Icons.history), label: 'History'),
      NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
    ],
  ),
);
  }
}
