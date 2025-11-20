import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:app/features/ingredient/presentation/widgets/ingredient_result_card.dart';
import 'package:app/features/ingredient/presentation/widgets/warning_dialog.dart';
import 'package:app/shared/app_colors.dart';
import 'package:flutter/material.dart';

/// หน้าแสดงผลการวิเคราะห์ส่วนผสม
/// แสดงเฉพาะส่วนผสมที่มีข้อมูลจากฐาน Supabase แล้วเท่านั้น
class ResultPage extends StatefulWidget {
  final List<Ingredient> ingredients;

  const ResultPage({super.key, required this.ingredients});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
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

  @override
  Widget build(BuildContext context) {
    final ingredients = widget.ingredients;

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
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: ingredients.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return IngredientResultCard(ingredient: ingredients[index]);
                },
              ),
      ),
    );
  }
}

