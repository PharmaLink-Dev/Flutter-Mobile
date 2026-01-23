
import 'package:app/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final actionCards = [
      ActionCard(
        gradient: isDarkMode ? AppGradients.buttonDark : AppGradients.button,
        icon: FontAwesomeIcons.camera,
        title: "สแกนฉลาก",
        subtitle: "วิเคราะห์ส่วนผสม",
        onTap: () => context.go('/scan'),
      ),
      ActionCard(
        gradient: isDarkMode ? AppGradients.actionCardSecondaryDark : AppGradients.actionCardSecondary,
        icon: FontAwesomeIcons.barcode,
        title: "ค้นหา FDA",
        subtitle: "ตรวจสอบใบอนุญาต",
        onTap: () => context.go('/scan-fda'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            "Quick Action",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              // CHANGED: Use text color from theme
              color: appColors.text,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            const double spacing = 12.0;
            final double cardWidth = ((constraints.maxWidth - spacing) / 2).clamp(140.0, 165.0);

            return Center(
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children: actionCards.map((card) {
                  return SizedBox(
                    width: cardWidth,
                    child: card,
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ActionCard extends StatefulWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  bool _isTapped = false;

  void _handleTap() async {
    setState(() => _isTapped = true);
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() => _isTapped = false);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final scale = _isTapped ? 0.95 : 1.0;
    // NEW: Get theme-aware colors
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    // For content on a colorful gradient, a static white or a highly contrasting
    // color from the theme is usually best. `appColors.surface` is often white
    // in light mode and a dark color in dark mode. For gradients, we might
    // want to stick with a light color for readability in both themes.
    final Color onGradientColor = Colors.white;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: onGradientColor.withValues(alpha: 0.2),
          highlightColor: onGradientColor.withValues(alpha: 0.1),
          child: Container(
            constraints: const BoxConstraints(minHeight: 140),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  // CHANGED: Use a theme-aware shadow color or a semi-transparent black
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool showText = constraints.maxWidth > 100;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: onGradientColor, size: showText ? 28 : 32),
                    if (showText) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: onGradientColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: onGradientColor.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
