import 'package:flutter/material.dart';
import 'package:app/models/ingredient.dart';
import 'result_page.dart';

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({super.key});

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  final List<Ingredient> ingredients = [
    Ingredient(name: 'Vitamin B-Complex', status: 'ปลอดภัย'),
    Ingredient(name: 'Potassium Chloride', status: 'เสี่ยงสูง'),
    Ingredient(name: 'Phosphorus', status: 'เสี่ยงสูง'),
    Ingredient(name: 'Vitamin A', status: 'เสี่ยง'),
  ];

  bool isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ยืนยันส่วนผสม')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'โปรดตรวจสอบว่ารายการด้านล่างตรงกับฉลากผลิตภัณฑ์หรือไม่',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  return Card(
                    child: CheckboxListTile(
                      title: Text(ingredient.name),
                      value: true, // demo: แสดงถูกติ๊กทุกตัว
                      onChanged: (bool? newValue) {},
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: isConfirmed,
                  onChanged: (bool? newValue) {
                    setState(() {
                      isConfirmed = newValue ?? false;
                    });
                  },
                ),
                const Text('ข้อมูลทั้งหมดถูกต้องและครบถ้วน'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConfirmed
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResultPage()),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('วิเคราะห์ผล'),
            ),
          ],
        ),
      ),
    );
  }
}
