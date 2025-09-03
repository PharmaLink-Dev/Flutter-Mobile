import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/**
 * RecentScanList
 * ---------------
 * A mock list of recently scanned items.
 * Later, this can be connected to dynamic data (API, Database, etc.)
 */
class RecentScanList extends StatelessWidget {
  const RecentScanList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _scanItem(
          title: "Multivitamin for Seniors",
          subtitle: "Brand A • 1 day ago",
          status: "Danger",
          statusColor: Colors.red,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Multi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _scanItem(
          title: "Ginkgo Biloba Extract",
          subtitle: "Brand B • 3 days ago",
          status: "Safe",
          statusColor: Colors.green,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const FaIcon(FontAwesomeIcons.leaf, color: Colors.green),
          ),
        ),
      ],
    );
  }

  // Private helper widget: one scan item row
  Widget _scanItem({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required Widget leading,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          leading, // left icon/box
          const SizedBox(width: 12),
          Expanded( // expands to fill available space
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
