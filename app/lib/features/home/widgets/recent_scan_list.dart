import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // ใช้ Font Awesome Icons

// สมมติว่าไฟล์เหล่านี้อยู่ใน Path ที่ถูกต้อง
import 'package:app/features/history/data/scan_history.dart';
import 'package:app/features/history/data/fda_scan.dart';
import 'package:app/features/ingredient/data/ingredient.dart'; // สำหรับแปลง HistoryIngredient กลับมา

import 'package:app/features/ingredient/presentation/result_Page.dart';
import 'package:app/features/fda_scan/presentation/fda_success_screen.dart';

// *********** ข้อมูลจาก history_utils.dart ที่จำเป็น ***********
// เนื่องจากคุณไม่ได้ให้ HistoryConstants และ DateFormatter มา ผมจะสมมติค่าสีพื้นฐาน
class HistoryConstants {
  static const Color primaryGreen = Color.fromRGBO(151, 255, 224, 1);
  static const Color darkGreen = Color.fromRGBO(100, 200, 170, 1);
}

class DateFormatter {
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
// ***************************************************************

enum ScanType { ingredient, fda }

class RecentScanList extends StatelessWidget {
  final ScanType scanType;

  // Constructor เป็น const ได้ เพราะเราไม่ได้เก็บ Hive Box ในนี้
  const RecentScanList({super.key, required this.scanType});

  // --- Navigation Helpers (จำลองการทำงานของ _navigateToIngredientResult) ---

  // ฟังก์ชันสำหรับนำทาง Ingredient Scan
  void _navigateToIngredientResult(BuildContext context, ScanHistory item) {
    // แปลง List<HistoryIngredient> กลับเป็น List<Ingredient>
    final List<Ingredient> ingredientsForDisplay = item.ingredients.map((
      histIng,
    ) {
      return Ingredient(
        name: histIng.name,
        status: histIng.status,
        riskLevel: histIng.riskLevel,
        description: histIng.description,
      );
    }).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        // *หมายเหตุ: คุณต้อง import ResultPage มาด้วย*
          builder: (_) => ResultPage(
            ingredients: ingredientsForDisplay,
            imageBytes: item.imageBytes,
            imagePath: item.imagePath,
          ),
      ),
    );
  }

  // ฟังก์ชันสำหรับนำทาง FDA Scan
  void _navigateToFdaResult(BuildContext context, FdaScan item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        // *หมายเหตุ: คุณต้อง import FdaSuccessScreen มาด้วย*
        builder: (_) => FdaSuccessScreen(data: item.fdaData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = scanType == ScanType.ingredient
        ? "Recent Ingredient Scans"
        : "Recent FDA Scans";

    // ดึง Box โดยตรงใน build
    final Box historyBox = scanType == ScanType.ingredient
        ? Hive.box<ScanHistory>('history')
        : Hive.box<FdaScan>('fda_scans');

    // ใช้ ValueListenableBuilder เพื่อรับฟังการเปลี่ยนแปลง
    return ValueListenableBuilder(
      valueListenable: historyBox.listenable(),
      builder: (context, Box box, Widget? child) {
        // 1. กรองและเรียงลำดับรายการ (เหมือนใน HistoryScreen)
        var allItems = box.values.toList();

        // เรียงลำดับจากใหม่ไปเก่า
        allItems.sort((a, b) => b.scanDate.compareTo(a.scanDate));

        // เลือก 3 รายการล่าสุด
        final recentItems = allItems.take(3).toList();

        if (recentItems.isEmpty) {
          return _buildEmptyState(context, title);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(context, title),
            const SizedBox(height: 4),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = recentItems[index];

                if (scanType == ScanType.ingredient) {
                  return _IngredientCardRecent(
                    item: item as ScanHistory,
                    onTap: () => _navigateToIngredientResult(context, item),
                  );
                } else {
                  return _FdaCardRecent(
                    item: item as FdaScan,
                    onTap: () => _navigateToFdaResult(context, item),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleRow(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        TextButton(
          // *ใช้ GoRouter เพื่อนำทางไปยังหน้า History หลัก*
          onPressed: () => context.go('/history'),
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(context, title),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              'No recent ${title.toLowerCase()}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------
// HELPER WIDGETS: เลียนแบบ IngredientCard ใน HistoryScreen
// ----------------------------------------------------

class _IngredientCardRecent extends StatelessWidget {
  final ScanHistory item;
  final VoidCallback onTap;

  const _IngredientCardRecent({required this.item, required this.onTap});

  // Helper function เพื่อคำนวณ Status และ Color
  Map<String, dynamic> _getDisplayData() {
    final highRiskCount = item.ingredients
        .where((i) => i.riskLevel == 'High')
        .length;
    final mediumRiskCount = item.ingredients
        .where((i) => i.riskLevel == 'Medium')
        .length;

    String statusText;
    Color statusColor;

    if (highRiskCount > 0) {
      statusText = 'High Risk ($highRiskCount)';
      statusColor = Colors.red;
    } else if (mediumRiskCount > 0) {
      statusText = 'Medium Risk ($mediumRiskCount)';
      statusColor = Colors.orange;
    } else {
      statusText = 'Safe';
      statusColor = Colors.green;
    }

    return {'status': statusText, 'statusColor': statusColor};
  }

  @override
  Widget build(BuildContext context) {
    final data = _getDisplayData();
    final statusColor = data['statusColor'] as Color;

    return InkWell(
      onTap: onTap, // 🎯 นำทางไปยัง ResultPage
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image/Icon Area
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: statusColor.withOpacity(0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imageBytes != null
                    ? Image.memory(item.imageBytes!, fit: BoxFit.cover)
                    : Icon(FontAwesomeIcons.leaf, color: statusColor, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.scanName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${DateFormatter.formatTime(item.scanDate)} | ${item.ingredients.length} ingredients',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Status Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                data['status'],
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
}

// ----------------------------------------------------
// HELPER WIDGETS: เลียนแบบ FdaCard ใน HistoryScreen
// ----------------------------------------------------

class _FdaCardRecent extends StatelessWidget {
  final FdaScan item;
  final VoidCallback onTap;

  const _FdaCardRecent({required this.item, required this.onTap});

  Map<String, dynamic> _getDisplayData() {
    final fdaStatus = item.fdaData['สถานะ'] ?? 'Unverified';

    // 🛑 ไม่จำเป็นต้องกำหนด statusColor ตามเงื่อนไขอีกต่อไป
    // แต่ยังคง return product name

    return {
      'status': fdaStatus,
      'productName': item.fdaData['ชื่อผลิตภัณฑ์(TH)'] ?? 'N/A',
    };
  }

  @override
  Widget build(BuildContext context) {
    final data = _getDisplayData();
    // 🛑 ไม่มีการใช้ statusColor แล้ว
    // final statusColor = data['statusColor'] as Color;

    return InkWell(
      onTap: onTap, // 🎯 นำทางไปยัง FdaSuccessScreen
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Area (ใช้สีคงที่ตาม HistoryConstants)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // ใช้ primaryGreen เป็นสีพื้นหลังคงที่
                color: HistoryConstants.primaryGreen.withOpacity(0.2),
              ),
              child: Icon(
                Icons.verified_user, // ใช้ Icon(Icons.verified_user)
                color: HistoryConstants
                    .darkGreen, // ใช้ darkGreen เป็นสีไอคอนคงที่
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['productName'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'FDA Ref: ${item.scanName}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // 🛑 ลบ Status Tag Container ออกทั้งหมดตามคำขอ
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
