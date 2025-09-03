import 'package:flutter/material.dart';

/**
 * RecentScansTitle
 * -----------------
 * Section header for the "Recent Scans" list.
 * Includes a "See All" link.
 */
class RecentScansTitle extends StatelessWidget {
  const RecentScansTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // left-right
      children: const [
        Text(
          "Recent Scans",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          "See All",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
