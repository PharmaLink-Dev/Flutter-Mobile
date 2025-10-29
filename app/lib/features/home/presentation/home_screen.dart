import 'package:flutter/material.dart';
import 'package:app/shared/app_colors.dart';

// Home sections
import '../widgets/top_summary_card.dart';
import '../widgets/quick_actions.dart';

/// HomeScreen
/// หน้าแรกสรุป + ปุ่มลัด ตามดีไซน์ที่ให้มา
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TopSummaryCard(),
            SizedBox(height: 20),
            QuickActions(),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
