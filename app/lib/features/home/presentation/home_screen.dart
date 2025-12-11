
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
    // NEW: Get theme-aware colors from the context
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      // CHANGED: Use background color from the theme
      backgroundColor: appColors.background,
      appBar: buildAppBar(context, appColors),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWithSearchBox(
              size: size,
              // CHANGED: Pass primary color from the theme
              primaryColor: appColors.primary,
              // NEW: Pass text color that contrasts with the primary color
              onPrimaryTextColor: appColors.surface, // Typically white in light theme
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

  AppBar buildAppBar(BuildContext context, AppColorExtension appColors) {
    return AppBar(
      elevation: 0,
      // CHANGED: Use primary color from the theme
      backgroundColor: appColors.primary,
      // The icon color will be automatically managed by the AppBar theme
      // based on the brightness of the background color.
      actions: [
        IconButton(
          icon: const Icon(Icons.settings), // Color is now handled by theme
          onPressed: () {
            context.go('/settings');
          },
        ),
      ],
    );
  }
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

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: size.height * 0.18,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 36 + 20,
            ),
            height: size.height * 0.18 - 27,
            decoration: BoxDecoration(
              // CHANGED: Uses the color passed from the theme
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  'Welcome to kidness',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        // CHANGED: Use a theme-aware text color
                        color: onPrimaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            // CHANGED: Pass primary color from the theme
            child: HomeSearchBar(primaryColor: appColors.primary),
          ),
        ],
      ),
    );
  }
}
