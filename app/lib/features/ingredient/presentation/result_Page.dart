import 'package:flutter/material.dart';
import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:app/features/ingredient/presentation/widgets/warning_dialog.dart';
import 'ingredient_detail_page.dart';
import 'package:app/shared/app_colors.dart';

/// หน้าผลการวิเคราะห์ส่วนผสม
///
/// - รับรายการ [ingredients] ที่ผ่านการยืนยันจากหน้า ConfirmationPage
/// - สรุประดับความเสี่ยงโดยรวมตาม status ของแต่ละส่วนผสม
/// - แยกรายการที่ควรระวังออกจากรายการอื่น
class ResultPage extends StatefulWidget {
  final List<Ingredient> ingredients;
  final String diseaseName;

  const ResultPage({
    super.key,
    this.ingredients = const [],
    this.diseaseName = 'โรคไต',
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final List<Ingredient> _highRisk;
  late final List<Ingredient> _mediumRisk;
  late final List<Ingredient> _others;

  bool get _hasAnyIngredient => widget.ingredients.isNotEmpty;

  bool get _hasRisky => _highRisk.isNotEmpty || _mediumRisk.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _partitionIngredients();

    // แสดงคำเตือนเฉพาะเมื่อมีส่วนผสมที่มีความเสี่ยง
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasRisky) return;
      showWarningDialog(
        context,
        diseaseName: widget.diseaseName,
        riskyIngredients: [
          ..._highRisk,
          ..._mediumRisk,
        ].map((e) => e.name).toList(),
      );
    });
  }

  void _partitionIngredients() {
    _highRisk = [];
    _mediumRisk = [];
    _others = [];

    for (final ing in widget.ingredients) {
      switch (ing.status) {
        case 'เสี่ยงสูง':
          _highRisk.add(ing);
          break;
        case 'เสี่ยง':
          _mediumRisk.add(ing);
          break;
        case 'ปลอดภัย':
          _others.add(ing);
          break;
        default:
          _others.add(ing);
      }
    }
  }

  String get _overallRiskLabel {
    if (!_hasAnyIngredient) return 'ไม่มีข้อมูล';
    if (_highRisk.isNotEmpty) return 'เสี่ยงสูง';
    if (_mediumRisk.isNotEmpty) return 'เสี่ยง';
    return 'ปลอดภัย';
  }

  Color get _overallRiskColor {
    if (!_hasAnyIngredient) return AppColors.textSecondary;
    if (_highRisk.isNotEmpty) return AppColors.red;
    if (_mediumRisk.isNotEmpty) return AppColors.orange;
    return AppColors.green;
  }

  String get _overallDescription {
    if (!_hasAnyIngredient) {
      return 'ยังไม่พบข้อมูลส่วนผสมสำหรับวิเคราะห์';
    }
    if (_highRisk.isNotEmpty) {
      return 'ตรวจพบส่วนผสมที่อาจเป็นอันตรายต่อผู้ป่วย${widget.diseaseName} หลายรายการ\nควรหลีกเลี่ยงผลิตภัณฑ์นี้หรือปรึกษาแพทย์ก่อนใช้';
    }
    if (_mediumRisk.isNotEmpty) {
      return 'พบส่วนผสมที่อาจมีความเสี่ยงสำหรับผู้ป่วย${widget.diseaseName}\nแนะนำให้ใช้ด้วยความระมัดระวังและปรึกษาแพทย์หากไม่แน่ใจ';
    }
    return 'ไม่พบส่วนผสมที่มีรายงานความเสี่ยงชัดเจนต่อผู้ป่วย${widget.diseaseName}\nอย่างไรก็ตาม ควรตรวจสอบฉลากทุกครั้งก่อนใช้ผลิตภัณฑ์';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ผลการวิเคราะห์ส่วนผสม'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultSummaryCard(
                label: _overallRiskLabel,
                color: _overallRiskColor,
                description: _overallDescription,
                hasAnyIngredient: _hasAnyIngredient,
              ),
              const SizedBox(height: 16),
              if (_hasRisky) ...[
                const Text(
                  'ส่วนผสมที่ควรระวัง',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                ...[..._highRisk, ..._mediumRisk]
                    .map(
                      (ing) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ResultIngredientCard(
                          ingredient: ing,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    IngredientDetailPage(ingredient: ing),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
                const SizedBox(height: 20),
              ],
              if (_others.isNotEmpty) ...[
                const Text(
                  'ส่วนผสมอื่นที่พบ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                ..._others
                    .map(
                      (ing) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ResultIngredientCard(
                          ingredient: ing,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    IngredientDetailPage(ingredient: ing),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              ],
              if (!_hasAnyIngredient)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'ไม่พบรายการส่วนผสมจากการสแกน',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}

class _ResultSummaryCard extends StatelessWidget {
  final String label;
  final Color color;
  final String description;
  final bool hasAnyIngredient;

  const _ResultSummaryCard({
    required this.label,
    required this.color,
    required this.description,
    required this.hasAnyIngredient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(
              hasAnyIngredient
                  ? (label == 'ปลอดภัย'
                      ? Icons.check
                      : Icons.warning_amber_rounded)
                  : Icons.info_outline,
              size: 40,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ResultIngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onTap;

  const _ResultIngredientCard({
    required this.ingredient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = ingredient.status.isEmpty ? 'ไม่ระบุ' : ingredient.status;

    final Color statusColor;
    switch (status) {
      case 'เสี่ยงสูง':
        statusColor = AppColors.red;
        break;
      case 'เสี่ยง':
        statusColor = AppColors.orange;
        break;
      case 'ปลอดภัย':
        statusColor = AppColors.green;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.darkGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
