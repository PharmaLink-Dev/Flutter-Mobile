//material app routes using go_router with stateful shell route
import 'package:app/features/history/presentation/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/shared/app_colors.dart';

// Screens
import 'features/home/presentation/home_screen.dart';
import 'features/scan/presentation/scan_screen.dart';
import 'features/history/presentation/history_screen.dart';

/// App Router using GoRouter with StatefulShellRoute
/// -------------------------------------------------
/// Manages bottom navigation and page switching.
final GoRouter appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
                path: '/',
                builder: (_, __) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'test', // Added route for the test screen
                    builder: (_, __) => const TestScreen(),
                  ),
                ]),
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
      ],
    ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary, // ✅ ใช้สีเขียวแบรนด์
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
        ],
      ),
    );
  }
}
