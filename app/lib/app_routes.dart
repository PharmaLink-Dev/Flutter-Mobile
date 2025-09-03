//material app routes using go_router with stateful shell route
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Screens
import 'features/home/presentation/home_screen.dart';
import 'features/scan/presentation/scan_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/profile/presentation/profile_screen.dart';

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
              path: '/',builder: (_, __) => const HomeScreen(),
              //routes: [GoRoute(path: '/seeAll', builder: (_, __) => const HomeScreen())],
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house), label: "Home"),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.qrcode), label: "Scan"),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.clockRotateLeft), label: "History"),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user), label: "Profile"),
        ],
      ),
    );
  }
}
