import 'package:app/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    final actionCards = [
      ActionCard(
        gradient: AppGradients.scanLabel,
        icon: FontAwesomeIcons.camera,
        title: "สแกนฉลาก",
        subtitle: "วิเคราะห์ส่วนผสม",
        onTap: () => context.go('/scan'),
        shadowColor: const Color(0xFF42A5F5).withValues(alpha: 0.4),
      ),
      ActionCard(
        gradient: AppGradients.searchFda,
        icon: FontAwesomeIcons.barcode,
        title: "ค้นหา FDA",
        subtitle: "ตรวจสอบใบอนุญาต",
        onTap: () => context.go('/scan-fda'),
        shadowColor: const Color(0xFFFDD835).withValues(alpha: 0.4),
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
              color: appColors.text,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            const double spacing = 12.0;
            final double cardWidth = ((constraints.maxWidth - spacing) / 2)
                .clamp(140.0, 165.0);

            return Center(
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children: actionCards.map((card) {
                  return SizedBox(width: cardWidth, child: card);
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
  final Color? shadowColor;

  const ActionCard({
    super.key,
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.shadowColor,
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
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      widget.shadowColor ??
                      Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: -2,
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: onGradientColor,
                        size: showText ? 24 : 28,
                      ),
                    ),
                    if (showText) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: onGradientColor,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
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
