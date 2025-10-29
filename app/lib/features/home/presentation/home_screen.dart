import 'package:app/features/home/widgets/recent_scan_list.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/app_colors.dart'; // เพิ่ม import สี

// Import custom widgets
import '../widgets/search_bar.dart';
import '../widgets/quick_actions.dart';

/**
 * HomeScreen
 * ----------------
 * Main demo content for the Home tab.
 * Displays:
 * - Search bar
 * - Quick actions
 * - Recent scans
 *
 * NOTE: No BottomNavigationBar here.
 * Navigation is handled by ShellScaffold in app_route.dart.
 */
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            SearchBarWidget(), // search bar
            SizedBox(height: 20),
            QuickActions(), // grid of shortcuts
            SizedBox(height: 20),
            RecentScanList(scanType: ScanType.ingredient),
            SizedBox(height: 20),
            RecentScanList(scanType: ScanType.fda),
          ],
        ),
      ),
    );
  }
}
