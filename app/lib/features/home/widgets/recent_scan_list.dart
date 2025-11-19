import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

enum ScanType { ingredient, fda }

class RecentScanList extends StatelessWidget {
  final ScanType scanType;
  const RecentScanList({super.key, required this.scanType});

  @override
  Widget build(BuildContext context) {
    final data = scanType == ScanType.ingredient ? _ingredientScans : _fdaScans;
    final title =
        scanType == ScanType.ingredient ? "Ingredient Scans" : "FDA Scans";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton(
              onPressed: () => context.go('/history'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 4), // Reduced space after title row
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = data[index];
            return _scanItem(
              title: item['title']!,
              subtitle: item['subtitle']!,
              status: item['status']!,
              statusColor: item['statusColor']! as Color,
              leading: item['leading']! as Widget,
              onTap: () {
                context.go('/history');
              },
            );
          },
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            leading, // left icon/box
            const SizedBox(width: 12),
            Expanded(
              // expands to fill available space
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
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
      ),
    );
  }

  static final List<Map<String, dynamic>> _ingredientScans = [
    {
      'title': "Skincare Ingredient",
      'subtitle': "Brand A • 1 day ago",
      'status': "Safe",
      'statusColor': Colors.green,
      'leading': Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const FaIcon(FontAwesomeIcons.leaf, color: Colors.green),
      ),
    },
  ];

  static final List<Map<String, dynamic>> _fdaScans = [
    {
      'title': "FDA Product 1",
      'subtitle': "Brand C • 5 days ago",
      'status': "Warning",
      'statusColor': Colors.orange,
      'leading': Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const FaIcon(FontAwesomeIcons.pills, color: Colors.orange),
      ),
    },
  ];
}
