import 'dart:io';
import 'dart:typed_data';

import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:app/features/ingredient/presentation/widgets/ingredient_result_card.dart';
import 'package:app/features/ingredient/presentation/widgets/warning_dialog.dart';
import 'package:app/shared/app_colors.dart';
import 'package:flutter/material.dart';

/// หน้าแสดงผลการวิเคราะห์ส่วนผสม
/// แสดงเฉพาะส่วนผสมที่มีข้อมูลจากฐาน Supabase แล้วเท่านั้น
class ResultPage extends StatefulWidget {
  final List<Ingredient> ingredients;
  final Uint8List? imageBytes;
  final String? imagePath;
  final String? heroTag;

  const ResultPage({
    super.key,
    required this.ingredients,
    this.imageBytes,
    this.imagePath,
    this.heroTag,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool get _hasImage {
    final bytes = widget.imageBytes;
    final path = widget.imagePath;
    final hasBytes = bytes != null && bytes.isNotEmpty;
    final hasPath = path != null && path.isNotEmpty;
    return hasBytes || hasPath;
  }

  @override
  void initState() {
    super.initState();

    // แสดงคำเตือนสำหรับผู้ป่วยโรคไตเมื่อพบส่วนผสมกลุ่มสีแดง
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final redIngredients = widget.ingredients
          .where(
            (ingredient) => ingredient.riskLevel.toLowerCase() == 'red',
          )
          .map((ingredient) => ingredient.name)
          .toSet()
          .toList();

      if (redIngredients.isNotEmpty) {
        showWarningDialog(
          context,
          riskyIngredients: redIngredients,
        );
      }
    });
  }

  Widget _buildImageHeader() {
    if (!_hasImage) return const SizedBox.shrink();

    Widget imageWidget;
    if (widget.imageBytes != null && widget.imageBytes!.isNotEmpty) {
      imageWidget = Image.memory(
        widget.imageBytes!,
        fit: BoxFit.cover,
      );
    } else if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      imageWidget = Image.file(
        File(widget.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            color: Colors.grey[400],
            size: 48,
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: imageWidget,
      ),
    );

    final heroTag = widget.heroTag;
    if (heroTag != null && heroTag.isNotEmpty) {
      content = Hero(
        tag: heroTag,
        child: content,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    // จัดเรียงส่วนผสมตามระดับความเสี่ยง: อันตราย (red) > ระมัดระวัง (yellow) > ปลอดภัย (green / อื่น ๆ)
    final ingredients = [...widget.ingredients]..sort((a, b) {
        int score(String level) {
          switch (level.toLowerCase()) {
            case 'red':
              return 0; // อันตรายสูงสุด ให้อยู่บนสุด
            case 'yellow':
              return 1; // ระมัดระวัง
            case 'green':
              return 2; // ปลอดภัย
            default:
              return 3; // อื่น ๆ / ไม่ทราบ
          }
        }

        final aScore = score(a.riskLevel);
        final bScore = score(b.riskLevel);
        if (aScore != bScore) return aScore.compareTo(bScore);
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    // หา index สุดท้ายของแต่ละโซนความเสี่ยง
    int lastRedIndex = -1;
    int lastYellowIndex = -1;
    for (var i = 0; i < ingredients.length; i++) {
      final level = ingredients[i].riskLevel.toLowerCase();
      if (level == 'red') {
        lastRedIndex = i;
      } else if (level == 'yellow') {
        lastYellowIndex = i;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text(
            'ผลการวิเคราะห์ส่วนผสม',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ingredients.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'ไม่พบข้อมูลส่วนผสมที่ตรงกับฐานข้อมูล',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ingredients.length + (_hasImage ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_hasImage) {
                    if (index == 0) {
                      return _buildImageHeader();
                    }
                    final ingredientIndex = index - 1;
                    final ingredient = ingredients[ingredientIndex];

                    final isZoneBoundary = ingredientIndex == lastRedIndex ||
                        ingredientIndex == lastYellowIndex;

                    return Column(
                      children: [
                        IngredientResultCard(
                          ingredient: ingredient,
                        ),
                        if (isZoneBoundary &&
                            ingredientIndex != ingredients.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1,
                              height: 2,
                            ),
                          ),
                      ],
                    );
                  } else {
                    final ingredient = ingredients[index];

                    final isZoneBoundary =
                        index == lastRedIndex || index == lastYellowIndex;

                    return Column(
                      children: [
                        IngredientResultCard(
                          ingredient: ingredient,
                        ),
                        if (isZoneBoundary && index != ingredients.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(
                              color: Colors.white70,
                              thickness: 1,
                              height: 1,
                            ),
                          ),
                      ],
                    );
                  }
                },
              ),
      ),
    );
  }
}
