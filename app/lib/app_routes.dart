//material app routes using go_router with stateful shell route
import 'package:app/features/history/presentation/test_screen.dart';
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

  // This method handles the navigation when a tab is tapped.
  void _onTap(int index) {
    // index is the TAPPED index of the BottomNavigationBarItem
    // 0=Home, 1=Scan, 2=History, 3=News

    // "Scan" is a special case that navigates to a different route
    // outside of the StatefulShellRoute.
    if (index == 1) {
      context.go('/scan');
      return;
    }

    // Map the tapped tab index to the correct branch index for the shell.
    // Tab 0 (Home) -> Branch 0
    // Tab 2 (History) -> Branch 1
    // Tab 3 (News) -> Branch 2
    final int branchIndex;
    if (index == 0) {
      branchIndex = 0;
    } else if (index == 2) {
      branchIndex = 1;
    } else { // index is 3
      branchIndex = 2;
    }

    widget.navigationShell.goBranch(
      branchIndex,
      // This is an optimization. It will only pop to the initial location of
      // the branch if the user taps the tab for the branch they are already on.
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This part is crucial for correctly highlighting the BottomNavigationBarItem.
    // We need to map the CURRENT branch index back to the correct TAB index.
    final int currentIndex;
    switch (widget.navigationShell.currentIndex) {
      case 0: // Branch 0 (Home) should highlight Tab 0 (Home).
        currentIndex = 0;
        break;
      case 1: // Branch 1 (History) should highlight Tab 2 (History).
        currentIndex = 2;
        break;
      case 2: // Branch 2 (News) should highlight Tab 3 (News).
        currentIndex = 3;
        break;
      default:
        currentIndex = 0;
    }

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        // Use the correctly calculated index here.
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
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
