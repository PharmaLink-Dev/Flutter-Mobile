import 'package:app/features/ingredient/presentation/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/shared/app_colors.dart';
import 'package:app/features/fda_scan/presentation/fda_scan_screen.dart';

// Screens
import 'features/home/presentation/home_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/news/presentation/news_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/settings/presentation/appearance_screen.dart';
import 'features/policy/presentation/policy_check_screen.dart';
import 'features/policy/presentation/policy_screen.dart';
import 'features/tutorial/presentation/tutorial_screen.dart';

// --- Main Router Configuration ---
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Initial policy check screen
    GoRoute(path: '/', builder: (_, __) => const PolicyCheckScreen()),
    GoRoute(
      path: '/initial-policy',
      builder: (_, __) => const PolicyScreen(isFirstLaunch: true),
    ),
    GoRoute(path: '/tutorial', builder: (_, __) => const TutorialScreen()),

    // Main app structure with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (_, __) => const HistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/news', builder: (_, __) => const NewsScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    // --- Top-Level Routes (not part of the shell) ---
    // These are pushed on top of the current screen.
    GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),
    GoRoute(path: '/scan-fda', builder: (_, __) => const FdaScanScreen()),
    GoRoute(
      path: '/settings/appearance',
      builder: (_, __) => const AppearanceScreen(),
    ),
    GoRoute(path: '/settings/policy', builder: (_, __) => const PolicyScreen()),
  ],
);

// --- ShellScaffold with Custom Bottom Navigation ---

class ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ShellScaffold({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    // Central scan button logic
    if (index == 2) {
      context.push('/scan');
      return;
    }

    // Map tab index to branch index
    final int branchIndex = (index < 2) ? index : index - 1;

    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  int _getCurrentIndex() {
    final int branchIndex = navigationShell.currentIndex;
    return (branchIndex < 2) ? branchIndex : branchIndex + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _CustomBottomNavBar(
        currentIndex: _getCurrentIndex(),
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}

// --- Custom Bottom Navigation Bar Widget ---

class _CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorExtension>()!;

    return SafeArea(
      child: Container(
        height: 80,
        color: theme.colorScheme.surface, // Background color for the nav bar
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                  colors: colors,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: 'History',
                  index: 1,
                  colors: colors,
                ),
                const SizedBox(width: 56), // Placeholder for the central button
                _buildNavItem(
                  context,
                  icon: Icons.newspaper_outlined,
                  activeIcon: Icons.newspaper,
                  label: 'News',
                  index: 3,
                  colors: colors,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  index: 4,
                  colors: colors,
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.primary.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required AppColorExtension colors,
  }) {
    final bool isSelected = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? colors.primary : colors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colors.primary : colors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
