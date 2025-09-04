import 'package:flutter/material.dart';
import 'package:app/models/ingredient.dart';
import 'package:app/constants/app_colors.dart';

class IngredientDetailPage extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientDetailPage({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('รายละเอียดส่วนผสม'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ความเสี่ยง'),
              Tab(text: 'ภาพรวม'),
              Tab(text: 'ปฏิกิริยา'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRiskTab(),
            _buildOverviewTab(),
            _buildInteractionTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ความเสี่ยงสำหรับผู้ป่วยโรคไต',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          _buildRiskItem(
            'ภาวะโพแทสเซียมในเลือดสูง (Hyperkalemia)',
            'รุนแรง',
            AppColors.red,
          ),
          _buildRiskItem(
            'หัวใจเต้นผิดจังหวะ / หัวใจหยุดเต้น',
            'รุนแรง',
            AppColors.red,
          ),
          _buildRiskItem('กล้ามเนื้ออ่อนแรง', 'ปานกลาง', AppColors.yellow),
          const SizedBox(height: 20),
          const Text(
            'ข้อแนะนำ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          const Text(
            'ควรหลีกเลี่ยงผลิตภัณฑ์ที่มีส่วนผสมนี้และจำกัดอาหารที่มีโพแทสเซียมสูงตามคำแนะนำของแพทย์อย่างเคร่งครัด',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${ingredient.name} คืออะไร?',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            ingredient.description.isNotEmpty
                ? ingredient.description
                : 'ข้อมูลภาพรวมของส่วนผสมยังไม่พร้อม',
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ปฏิกิริยากับยาที่ใช้บ่อยในผู้ป่วยโรคไต',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          _buildRiskItem(
            'ยาขับปัสสาวะบางชนิด (Spironolactone)',
            'รุนแรง',
            AppColors.red,
          ),
          _buildRiskItem(
            'ยาลดความดันกลุ่ม ACEI/ARBs',
            'ปานกลาง',
            AppColors.yellow,
          ),
        ],
      ),
    );
  }

  Widget _buildRiskItem(String title, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
