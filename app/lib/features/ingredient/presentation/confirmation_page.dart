import 'package:flutter/material.dart';
import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:app/shared/app_colors.dart';
import 'package:app/features/ingredient/presentation/confirmation_controller.dart';
import 'package:app/features/ingredient/presentation/result_Page.dart';

class ConfirmationPage extends StatefulWidget {
  final List<Ingredient> ingredients;
  final String imagePath;

  const ConfirmationPage({
    super.key,
    required this.ingredients,
    required this.imagePath,
  });

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  final ConfirmationController _vm = ConfirmationController();
  final _addCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm.loadFromIngredients(widget.ingredients);
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('ยืนยันส่วนผสม')),
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.background),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _AddBar(
                  controller: _addCtrl,
                  onAdd: () {
                    _vm.addManual(_addCtrl.text);
                    _addCtrl.clear();
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: _vm.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final it = _vm.items[i];
                      final status = it.isManual ? 'เพิ่มเอง' : (it.ingredient.status.isEmpty ? 'ไม่ระบุ' : it.ingredient.status);
                      final color = it.isManual
                          ? AppColors.primary
                          : (status == 'เสี่ยงสูง'
                              ? AppColors.red
                              : status == 'เสี่ยง'
                                  ? AppColors.orange
                                  : status == 'ปลอดภัย'
                                      ? AppColors.green
                                      : AppColors.textSecondary);
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: CheckboxListTile(
                          value: it.checked,
                          onChanged: (v) => _vm.toggleAt(i, v ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(it.ingredient.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                            child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                          secondary: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _vm.removeAt(i),
                            tooltip: 'ลบ',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Checkbox(value: _vm.isConfirmed, onChanged: (v) => _vm.setConfirmed(v ?? false)),
                    const Expanded(child: Text('ข้อมูลทั้งหมดถูกต้องและครบถ้วน')),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _vm.canAnalyze
                        ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultPage()))
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: _vm.canAnalyze ? AppColors.primary : AppColors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('วิเคราะห์ผล', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  const _AddBar({required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onAdd(),
            decoration: InputDecoration(
              hintText: 'เพิ่มส่วนผสมเอง…',
              prefixIcon: const Icon(Icons.add_circle_outline),
              filled: true,
              fillColor: AppColors.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('เพิ่ม'),
        ),
      ],
    );
  }
}
