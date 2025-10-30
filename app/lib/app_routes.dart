//material app routes using go_router with stateful shell route
import 'package:app/features/scan/presentation/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/shared/app_colors.dart';
import 'package:app/features/fda_scan/presentation/fda_scan_screen.dart';

// Screens
import 'features/home/presentation/home_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/news/presentation/news_screen.dart';

/// App Router using GoRouter with StatefulShellRoute
/// -------------------------------------------------
/// Manages bottom navigation and page switching.
final GoRouter appRouter = GoRouter(
  routes: [
    // Bottom tabs (Home, History) are kept alive in a shell.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/', builder: (_, __) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/news', builder: (_, __) => const NewsScreen())
          ]
        )
      ],
    ),
    // Scan is OUTSIDE the shell so it will be disposed when leaving.
    GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),
    // FDA Scan: duplicate flow like Scan
    GoRoute(path: '/scan-fda', builder: (_, __) => const FdaScanScreen()),
  ],
);

/// ShellScaffold
/// -------------------------------------------------
/// Wraps navigation shell with a Scaffold and a BottomNavigationBar.
class ShellScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const ShellScaffold({super.key, required this.navigationShell});

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  int get _currentIndex => widget.navigationShell.currentIndex;

  void _onTap(int index) {
    if (index == 1) {
      // Open Scan as a standalone route (no bottom bar); it will dispose on exit.
      context.go('/scan');
      return;
    }
    final mappedIndex = index == 0 ? 0 : 1; // map Home=0, History=1 to branches
    widget.navigationShell.goBranch(
      mappedIndex,
      initialLocation: mappedIndex == _currentIndex,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,      // ✅ ใช้สีเขียวแบรนด์
        unselectedItemColor: AppColors.textSecondary, // ✅ สีเทาอ่อน
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // ✅ filled เมื่อ active
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined),
            activeIcon: Icon(Icons.newspaper),
            label: "News"
          )
        ],
      ),
    );
  }
}
