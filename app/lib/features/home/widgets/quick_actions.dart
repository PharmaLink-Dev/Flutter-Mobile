
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:app/shared/app_colors.dart';

/// QuickActions: A responsive grid of two action buttons.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actionCards = [
      ActionCard(
        gradient: AppGradients.scanLabel,
        icon: FontAwesomeIcons.camera,
        title: "Scan Label",
        subtitle: "Camera scan",
        onTap: () => context.go('/scan'),
      ),
      ActionCard(
        gradient: AppGradients.fdaNumber,
        icon: FontAwesomeIcons.qrcode,
        title: "FDA Number",
        subtitle: "Quick lookup",
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Coming soon: FDA Number page")),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
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
        // Use a GridView for a simple, responsive 2-column layout
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2, // Adjust for a pleasant card shape (width / height)
          children: actionCards,
        ),
      ],
    );
  }
}

/// ActionCard: An individual, responsive action button.
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
  bool _hover = false;
  bool _tap = false;

  void _animateTap(VoidCallback action) async {
    setState(() => _tap = true);
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => _tap = false);
    action();
  }

  @override
  Widget build(BuildContext context) {
    final scale = _tap ? 0.95 : (_hover ? 1.05 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => _animateTap(widget.onTap),
            borderRadius: BorderRadius.circular(18),
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.overlay.withOpacity(0.5),
                    blurRadius: _hover ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: LayoutBuilder(builder: (context, constraints) {
                // Show text only if the card is wide enough
                final bool showText = constraints.maxWidth > 100;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 28),
                    if (showText) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85)),
                      ),
                    ]
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
