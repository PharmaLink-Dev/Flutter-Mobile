import 'package:flutter/material.dart';
import 'package:app/models/ingredient.dart';
import 'package:app/utils/warning_dialog.dart';
import 'ingredient_detail_page.dart';
import 'package:app/constants/app_colors.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final List<Ingredient> riskyIngredients = [
    Ingredient(name: 'Potassium Chloride', status: 'เสี่ยงสูง'),
    Ingredient(name: 'Phosphorus', status: 'เสี่ยงสูง'),
    Ingredient(name: 'Vitamin A', status: 'เสี่ยง'),
  ];

  final List<Ingredient> safeIngredients = [
    Ingredient(name: 'Vitamin B-Complex', status: 'ปลอดภัย'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showWarningDialog(
        context,
        diseaseName: 'โรคไต',
        riskyIngredients: riskyIngredients.map((e) => e.name).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ผลการวิเคราะห์')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            const Text(
              'ส่วนผสมที่ควรระวัง',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ...riskyIngredients.map((i) => _buildIngredientCard(i)),
            const SizedBox(height: 20),
            const Text(
              'ส่วนผสมอื่นที่พบ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ...safeIngredients.map((i) => _buildIngredientCard(i)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Column(
        children: const [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.red,
            child: Icon(
              Icons.warning_amber_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'เสี่ยงสูง',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.red,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'ตรวจพบ 2 ส่วนผสมที่ไม่แนะนำ\nสำหรับผู้ป่วยโรคไต',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    Color statusColor;
    switch (ingredient.status) {
      case 'เสี่ยงสูง':
        statusColor = AppColors.red;
        break;
      case 'เสี่ยง':
        statusColor = AppColors.yellow;
        break;
      default:
        statusColor = AppColors.green;
    }

    return Card(
      child: ListTile(
        title: Text(ingredient.name),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            ingredient.status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  IngredientDetailPage(ingredient: ingredient),
            ),
          );
        },
      ),
    );
  }
}
