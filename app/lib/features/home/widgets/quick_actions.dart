import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:app/shared/app_colors.dart';

/// QuickActions: à¸à¸¥à¹ˆà¸­à¸‡à¸£à¸§à¸¡à¸›à¸¸à¹ˆà¸¡à¸¥à¸±à¸” (à¹à¸ªà¸”à¸‡à¸›à¸¸à¹ˆà¸¡à¸¥à¸±à¸” 2 à¸›à¸¸à¹ˆà¸¡à¹ƒà¸™ GridView)
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    // List of action cards
    final actionCards = [
      ActionCard(
        gradient: AppGradients.scanLabel, // à¸ªà¸µà¸žà¸·à¹‰à¸™à¸«à¸¥à¸±à¸‡à¹à¸šà¸š gradient
        icon: FontAwesomeIcons.camera, // à¹„à¸­à¸„à¸­à¸™à¸à¸¥à¹‰à¸­à¸‡
        title: "สแกนฉลาก", // à¸Šà¸·à¹ˆà¸­à¸›à¸¸à¹ˆà¸¡
        subtitle: "วิเคราะห์ส่วนผสม", // à¸„à¸³à¸­à¸˜à¸´à¸šà¸²à¸¢
        onTap: () => context.go('/scan'), // à¸™à¸³à¸—à¸²à¸‡à¹„à¸›à¸«à¸™à¹‰à¸² /scan
      ),
      ActionCard(
        gradient: AppGradients.fdaNumber, // à¸ªà¸µà¸žà¸·à¹‰à¸™à¸«à¸¥à¸±à¸‡à¹à¸šà¸š gradient
        icon: FontAwesomeIcons.barcode, // à¹„à¸­à¸„à¸­à¸™ QR
        title: "ค้นหา FDA", // à¸Šà¸·à¹ˆà¸­à¸›à¸¸à¹ˆà¸¡
        subtitle: "ตรวจสอบใบอนุญาต", // à¸„à¸³à¸­à¸˜à¸´à¸šà¸²à¸¢
        onTap: () {
          // à¹à¸ªà¸”à¸‡ SnackBar à¹à¸ˆà¹‰à¸‡à¸§à¹ˆà¸²à¸Ÿà¸µà¹€à¸ˆà¸­à¸£à¹Œà¸¢à¸±à¸‡à¹„à¸¡à¹ˆà¹€à¸›à¸´à¸”à¹ƒà¸Šà¹‰à¸‡à¸²à¸™
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Coming soon: FDA Number page")),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title à¸ªà¹ˆà¸§à¸™à¸«à¸±à¸§ "Quick Action"
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            "Quick Action",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text, // à¹ƒà¸Šà¹‰à¸ªà¸µ text à¸ˆà¸²à¸à¸˜à¸µà¸¡à¸à¸¥à¸²à¸‡
            ),
          ),
        ),
        // Use LayoutBuilder to build a responsive layout
        LayoutBuilder(
          builder: (context, constraints) {
            // Define a fixed width for each card
            const cardWidth = 160.0;
            // Calculate the number of columns that can fit
            final crossAxisCount = (constraints.maxWidth / cardWidth).floor();

            // If it can fit more than one column, use a Row/Wrap like layout.
            // Otherwise, use a Column.
            if (crossAxisCount > 1) {
              return Wrap(
                spacing: 12, // Horizontal spacing
                runSpacing: 12, // Vertical spacing
                alignment: WrapAlignment.spaceEvenly,
                children: actionCards
                    .map((card) => SizedBox(
                          width: cardWidth,
                          child: card,
                        ))
                    .toList(),
              );
            } else {
              return Column(
                children: actionCards
                    .map((card) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: card,
                        ))
                    .toList(),
              );
            }
          },
        ),
      ],
    );
  }
}

/// ActionCard: à¸›à¸¸à¹ˆà¸¡à¸¥à¸±à¸” 1 à¹ƒà¸š (à¸¡à¸µ animation à¸•à¸­à¸™ hover à¹à¸¥à¸° tap)
class ActionCard extends StatefulWidget {
  final LinearGradient gradient; // à¸ªà¸µà¸žà¸·à¹‰à¸™à¸«à¸¥à¸±à¸‡à¹à¸šà¸š gradient
  final IconData icon; // à¹„à¸­à¸„à¸­à¸™
  final String title; // à¸Šà¸·à¹ˆà¸­à¸›à¸¸à¹ˆà¸¡
  final String subtitle; // à¸„à¸³à¸­à¸˜à¸´à¸šà¸²à¸¢
  final VoidCallback onTap; // à¸Ÿà¸±à¸‡à¸à¹Œà¸Šà¸±à¸™à¹€à¸¡à¸·à¹ˆà¸­à¸à¸”à¸›à¸¸à¹ˆà¸¡

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
  bool _hover = false; // state à¸ªà¸³à¸«à¸£à¸±à¸š hover (mouse over)
  bool _tap = false; // state à¸ªà¸³à¸«à¸£à¸±à¸š tap (à¸„à¸¥à¸´à¸)

  /// à¸Ÿà¸±à¸‡à¸à¹Œà¸Šà¸±à¸™à¸ªà¸³à¸«à¸£à¸±à¸š animate à¸•à¸­à¸™ tap (à¸¢à¹ˆà¸­ scale à¹à¸¥à¹‰à¸§à¸à¸¥à¸±à¸šà¸¡à¸²)
  void _animateTap(VoidCallback action) async {
    setState(() => _tap = true); // à¸¢à¹ˆà¸­ scale
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => _tap = false); // scale à¸à¸¥à¸±à¸šà¸¡à¸²à¹€à¸«à¸¡à¸·à¸­à¸™à¹€à¸”à¸´à¸¡
    action(); // à¹€à¸£à¸µà¸¢à¸à¸Ÿà¸±à¸‡à¸à¹Œà¸Šà¸±à¸™à¸—à¸µà¹ˆà¸ªà¹ˆà¸‡à¸¡à¸²
  }

  @override
  Widget build(BuildContext context) {
    // à¸„à¸³à¸™à¸§à¸“ scale: à¸–à¹‰à¸² tap = 0.95, hover = 1.05, à¸›à¸à¸•à¸´ = 1.0
    final scale = _tap ? 0.95 : (_hover ? 1.05 : 1.0);

    return MouseRegion(
      // à¹€à¸¡à¸·à¹ˆà¸­ mouse à¹€à¸‚à¹‰à¸² widget à¹ƒà¸«à¹‰ set _hover = true
      onEnter: (_) => setState(() => _hover = true),
      // à¹€à¸¡à¸·à¹ˆà¸­ mouse à¸­à¸­à¸à¸ˆà¸²à¸ widget à¹ƒà¸«à¹‰ set _hover = false
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: scale, // à¸‚à¸¢à¸²à¸¢/à¸¢à¹ˆà¸­ widget à¸•à¸²à¸¡ state
        duration: const Duration(milliseconds: 120), // à¸£à¸°à¸¢à¸°à¹€à¸§à¸¥à¸² animation
        curve: Curves.easeOut, // à¸£à¸¹à¸›à¹à¸šà¸šà¸à¸²à¸£à¹€à¸„à¸¥à¸·à¹ˆà¸­à¸™à¹„à¸«à¸§
        child: Material(
          color: AppColors.surface, // à¸ªà¸µà¸žà¸·à¹‰à¸™à¸«à¸¥à¸±à¸‡à¸­à¹ˆà¸­à¸™à¸™à¸­à¸à¸ªà¸¸à¸”
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => _animateTap(widget.onTap), // à¹€à¸£à¸µà¸¢à¸ animation + à¸Ÿà¸±à¸‡à¸à¹Œà¸Šà¸±à¸™à¹€à¸¡à¸·à¹ˆà¸­ tap
            borderRadius: BorderRadius.circular(18),
            splashColor: Colors.white24, // à¸ªà¸µà¸„à¸¥à¸·à¹ˆà¸™à¸™à¹‰à¸³à¸•à¸­à¸™ tap
            highlightColor: Colors.white10, // à¸ªà¸µ highlight à¸•à¸­à¸™ tap
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.gradient, // à¸ªà¸µà¸žà¸·à¹‰à¸™à¸«à¸¥à¸±à¸‡à¹à¸šà¸š gradient
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.overlay, // à¹€à¸‡à¸²à¹‚à¸›à¸£à¹ˆà¸‡à¹ƒà¸ª
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // à¹„à¸­à¸„à¸­à¸™à¸ªà¸µà¸‚à¸²à¸§à¸šà¸™à¸žà¸·à¹‰à¸™ gradient
                  Icon(widget.icon, color: Colors.white, size: 28),
                  const SizedBox(height: 12),
                  // à¸Šà¸·à¹ˆà¸­à¸›à¸¸à¹ˆà¸¡
                  Text(widget.title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  // à¸„à¸³à¸­à¸˜à¸´à¸šà¸²à¸¢à¸›à¸¸à¹ˆà¸¡
                  Text(widget.subtitle,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

