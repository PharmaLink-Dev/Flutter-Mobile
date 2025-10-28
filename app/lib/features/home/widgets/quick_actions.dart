import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:app/shared/app_colors.dart';

/// QuickActions: กล่องรวมปุ่มลัด (แสดงปุ่มลัด 2 ปุ่มใน GridView)
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    // List of action cards
    final actionCards = [
      ActionCard(
        gradient: AppGradients.scanLabel, // สีพื้นหลังแบบ gradient
        icon: FontAwesomeIcons.camera, // ไอคอนกล้อง
        title: "Scan Label", // ชื่อปุ่ม
        subtitle: "Camera scan", // คำอธิบาย
        onTap: () => context.go('/scan'), // นำทางไปหน้า /scan
      ),
      ActionCard(
        gradient: AppGradients.fdaNumber, // สีพื้นหลังแบบ gradient
        icon: FontAwesomeIcons.qrcode, // ไอคอน QR
        title: "FDA Number", // ชื่อปุ่ม
        subtitle: "Quick lookup", // คำอธิบาย
        onTap: () {
          // แสดง SnackBar แจ้งว่าฟีเจอร์ยังไม่เปิดใช้งาน
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Coming soon: FDA Number page")),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title ส่วนหัว "Quick Action"
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            "Quick Action",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text, // ใช้สี text จากธีมกลาง
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

/// ActionCard: ปุ่มลัด 1 ใบ (มี animation ตอน hover และ tap)
class ActionCard extends StatefulWidget {
  final LinearGradient gradient; // สีพื้นหลังแบบ gradient
  final IconData icon; // ไอคอน
  final String title; // ชื่อปุ่ม
  final String subtitle; // คำอธิบาย
  final VoidCallback onTap; // ฟังก์ชันเมื่อกดปุ่ม

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
  bool _hover = false; // state สำหรับ hover (mouse over)
  bool _tap = false; // state สำหรับ tap (คลิก)

  /// ฟังก์ชันสำหรับ animate ตอน tap (ย่อ scale แล้วกลับมา)
  void _animateTap(VoidCallback action) async {
    setState(() => _tap = true); // ย่อ scale
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => _tap = false); // scale กลับมาเหมือนเดิม
    action(); // เรียกฟังก์ชันที่ส่งมา
  }

  @override
  Widget build(BuildContext context) {
    // คำนวณ scale: ถ้า tap = 0.95, hover = 1.05, ปกติ = 1.0
    final scale = _tap ? 0.95 : (_hover ? 1.05 : 1.0);

    return MouseRegion(
      // เมื่อ mouse เข้า widget ให้ set _hover = true
      onEnter: (_) => setState(() => _hover = true),
      // เมื่อ mouse ออกจาก widget ให้ set _hover = false
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: scale, // ขยาย/ย่อ widget ตาม state
        duration: const Duration(milliseconds: 120), // ระยะเวลา animation
        curve: Curves.easeOut, // รูปแบบการเคลื่อนไหว
        child: Material(
          color: AppColors.surface, // สีพื้นหลังอ่อนนอกสุด
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => _animateTap(widget.onTap), // เรียก animation + ฟังก์ชันเมื่อ tap
            borderRadius: BorderRadius.circular(18),
            splashColor: Colors.white24, // สีคลื่นน้ำตอน tap
            highlightColor: Colors.white10, // สี highlight ตอน tap
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.gradient, // สีพื้นหลังแบบ gradient
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.overlay, // เงาโปร่งใส
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ไอคอนสีขาวบนพื้น gradient
                  Icon(widget.icon, color: Colors.white, size: 28),
                  const SizedBox(height: 12),
                  // ชื่อปุ่ม
                  Text(widget.title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  // คำอธิบายปุ่ม
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
