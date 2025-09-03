import 'package:flutter/material.dart';

// Import custom widgets
import '../widgets/header_section.dart';
import '../widgets/search_bar.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_scans_title.dart';
import '../widgets/recent_scan_list.dart';

/**
 * HomeScreen
 * ----------------
 * Main demo content for the Home tab.
 * Displays:
 * - Greeting + avatar
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
    return Center(
      // Phone mockup container (fixed width & height)
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
        ),

        // Clip for rounded screen edges
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: const [
                HeaderSection(),       // greeting + avatar
                SizedBox(height: 20),
                SearchBarWidget(),     // search bar
                SizedBox(height: 20),
                QuickActions(),        // grid of shortcuts
                SizedBox(height: 20),
                RecentScansTitle(),    // "Recent Scans" title
                RecentScanList(),      // mock list
              ],
            ),
          ),
        ),
      ),
    );
  }
}
