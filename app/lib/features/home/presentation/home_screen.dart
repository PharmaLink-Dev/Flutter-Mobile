import 'package:app/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/home/widgets/quick_actions.dart';
import 'package:app/features/home/widgets/recent_scan_list.dart';
import 'package:app/features/home/widgets/searchBar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      backgroundColor: appColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWithSearchBox(
              size: size,
              primaryColor: appColors.primary,
              onPrimaryTextColor:
                  Colors.white, // Always white for contrast on gradient
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: QuickActions(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: RecentScanList(scanType: ScanType.ingredient),
            ),
          ],
        ),
      ),
    );
  }

  // AppBar removed
}

class HeaderWithSearchBox extends StatelessWidget {
  const HeaderWithSearchBox({
    super.key,
    required this.size,
    required this.primaryColor,
    required this.onPrimaryTextColor,
  });

  final Size size;
  final Color primaryColor;
  final Color onPrimaryTextColor;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      // Increased height to account for status bar
      height: size.height * 0.2 + topPadding,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 36 + 20,
              top: topPadding + 80, // Added extra padding to move text down
            ),
            height: size.height * 0.2 - 27 + topPadding,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryHeader,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative Circles
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: -10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Welcome to kidness',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: onPrimaryTextColor,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: AppColorExtension.textGlow,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: HomeSearchBar(primaryColor: appColors.primary),
          ),
        ],
      ),
    );
  }
}
