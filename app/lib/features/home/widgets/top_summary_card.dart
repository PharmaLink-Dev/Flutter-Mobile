import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app/shared/app_colors.dart';

/// TopSummaryCard
/// Gradient header card with title, helper icons and quick stats.
class TopSummaryCard extends StatelessWidget {
  const TopSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B7FFF), Color(0xFF38B8F2), Color(0xFF00C9A7)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PharmaLink',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ตรวจสอบส่วนผสม ปลอดภัยแน่นอน',
                      style: TextStyle(color: Colors.white70, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconButton(context, Icons.settings, 'ตั้งค่า'),
                  const SizedBox(width: 6),
                  _iconButton(context, Icons.info_outline, 'ข้อมูล'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StatsRow(),
        ],
      ),
    );
  }

  static Widget _iconButton(BuildContext context, IconData icon, String tooltip) {
    return Material(
      color: Colors.white.withOpacity(0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$tooltip: เร็ว ๆ นี้')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _StatCard(
            title: '1',
            subtitle: 'การสแกนทั้งหมด',
            icon: FontAwesomeIcons.image, // placeholder icon
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: '1',
            subtitle: 'ความเสี่ยงสูง',
            icon: FontAwesomeIcons.triangleExclamation,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _ShieldCard(),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _StatCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _ShieldCard extends StatelessWidget {
  const _ShieldCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Added horizontal padding
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            Icon(Icons.shield_outlined, color: Colors.white, size: 22), // Slightly smaller icon
            SizedBox(width: 6),
            Flexible( // Use Flexible to allow the text to wrap or shrink
              child: Text(
                'ปลอดภัย',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), // Slightly smaller text
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
            ),
          ],
        ),
      ),
    );
  }
}
