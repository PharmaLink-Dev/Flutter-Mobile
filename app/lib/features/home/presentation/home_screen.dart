import 'package:app/features/home/widgets/recent_scan_list.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/app_colors.dart';
import 'package:go_router/go_router.dart';

// Import custom widgets
import '../widgets/top_summary_card.dart';
import '../widgets/quick_actions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Temporary button to access the test screen
            ElevatedButton(
              onPressed: () => context.go('/test'),
              child: const Text('Go to Test Screen'),
            ),
            const SizedBox(height: 20),
            const TopSummaryCard(),
            const SizedBox(height: 20),
            const QuickActions(), // grid of shortcuts
            const SizedBox(height: 20),
            const RecentScanList(scanType: ScanType.ingredient),
            const SizedBox(height: 20),
            const RecentScanList(scanType: ScanType.fda),
          ],
        ),
      ),
    );
  }
}
