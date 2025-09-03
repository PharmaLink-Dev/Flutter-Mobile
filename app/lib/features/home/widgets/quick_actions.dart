import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/**
 * QuickActions
 * -------------
 * A grid of 2 shortcut buttons:
 * - Scan Label
 * - FDA Number
 */
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, // 2 items per row
      shrinkWrap: true, // shrink to fit children
      physics: const NeverScrollableScrollPhysics(), // disable scroll (ListView already scrolls)
      crossAxisSpacing: 12, // horizontal space between items
      mainAxisSpacing: 12, // vertical space between items
      children: [
        _actionCard(
          color: Colors.blue[50]!,
          icon: FontAwesomeIcons.camera,
          text: "Scan Label",
          textColor: Colors.blue[700]!,
        ),
        _actionCard(
          color: Colors.grey[200]!,
          iconWidget: Image.network(
            "https://firebasestorage.googleapis.com/v0/b/gemini-ui-playground.appspot.com/o/images%2Fgemini-logo.png?alt=media&token=e637a42a-4638-4c8d-9057-9d91a22ad23c",
            height: 30,
          ),
          text: "FDA Number",
          textColor: Colors.grey[800]!,
        ),
      ],
    );
  }

  // Private helper widget (_ prefix = private in Dart file scope)
  Widget _actionCard({
    required Color color,
    IconData? icon,
    Widget? iconWidget,
    required String text,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20), // rounded card
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: iconWidget ?? Icon(icon, size: 28, color: textColor),
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
