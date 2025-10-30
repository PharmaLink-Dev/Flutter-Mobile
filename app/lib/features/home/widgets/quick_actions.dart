import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:app/shared/app_colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actionCards = [
      ActionCard(
        gradient: AppGradients.scanLabel,
        icon: FontAwesomeIcons.camera,
        title: "สแกนฉลาก",
        subtitle: "วิเคราะห์ส่วนผสม",
        onTap: () => context.go('/scan'),
      ),
      ActionCard(
        gradient: AppGradients.fdaNumber,
        icon: FontAwesomeIcons.barcode,
        title: "ค้นหา FDA",
        subtitle: "ตรวจสอบใบอนุญาต",
        onTap: () => context.go('/scan-fda'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            "Quick Action",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
        // Use LayoutBuilder to create a fully responsive card size
        LayoutBuilder(
          builder: (context, constraints) {
            const double spacing = 12.0;
            // Calculate the ideal card width based on available space,
            // then clamp it to our desired min/max size.
            final double cardWidth = ((constraints.maxWidth - spacing) / 2).clamp(140.0, 165.0);

            return Center(
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children: actionCards.map((card) {
                  // Apply the calculated width to each card.
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

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      // The ConstrainedBox is removed from here to allow dynamic sizing.
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Container(
            constraints: const BoxConstraints(minHeight: 140), // Ensure a nice aspect ratio
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.overlay,
                  blurRadius: 10,
                  offset: Offset(0, 5),
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
                    Icon(widget.icon, color: Colors.white, size: showText ? 28 : 32),
                    if (showText) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
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
