import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:app/features/ingredient/domain/confirmation_controller.dart';
import 'package:app/features/ingredient/presentation/result_page.dart';
import 'package:app/shared/app_colors.dart';
import 'package:app/features/ingredient/data/query_supabase.dart';
import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app/features/history/data/scan_history.dart';
import 'package:app/features/history/data/history_ingredient.dart';
import 'dart:typed_data';

class ConfirmationPage extends StatefulWidget {
  final List<Ingredient> ingredients;
  final String imagePath;
  final Uint8List? scannedImageBytes;

  const ConfirmationPage({
    super.key,
    required this.ingredients,
    required this.imagePath,
    this.scannedImageBytes,
  });

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  final ConfirmationController _vm = ConfirmationController();
  final TextEditingController _addCtrl = TextEditingController();
  final SupabaseQueryService _supabaseQueryService = SupabaseQueryService();

  static const _uuid = Uuid();
  final _historyBox = Hive.box<ScanHistory>('history');

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
      builder: (context, _) {
        return Scaffold(
          appBar: const _ConfirmationAppBar(),
          body: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: _IngredientList(
                      items: _vm.items,
                      onToggle: _vm.toggleAt,
                      onRemove: _vm.removeAt,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AddSection(
                    controller: _addCtrl,
                    onAdd: () {
                      _vm.addManual(_addCtrl.text);
                      _addCtrl.clear();
                    },
                  ),
                  const SizedBox(height: 16),
                  _ConfirmationFooter(
                    isConfirmed: _vm.isConfirmed,
                    canAnalyze: _vm.canAnalyze,
                    onConfirmChanged: _vm.setConfirmed,
                    onAnalyze: () async {
                      final selected = _vm.items
                          .where((it) => it.checked)
                          .map((it) => it.ingredient)
                          .toList();

                      // ดึงเฉพาะชื่อไป query Supabase
                      final searchTerms = selected.map((e) => e.name).toList();

                      // แสดง loading ระหว่างเรียก Supabase
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      );

                      try {
                        // ได้ผลลัพธ์จาก Supabase (มีเฉพาะตัวที่เจอ)
                        final results = await _supabaseQueryService
                            .searchInDatabase(searchTerms);

                        if (!context.mounted) return;

                        // ปิด loading
                        Navigator.of(context).pop();

                        // ---------------------------------------------------------
                        // ผสานข้อมูล: แสดงเฉพาะรายการที่ "พบ" ในฐาน (status = found)
                        // โดยยึดชื่อ/mg จาก OCR แล้ว enrich ด้วยข้อมูลจาก DB
                        // ถ้าไม่พบเลย -> mergedIngredients จะเป็นลิสต์ว่าง
                        // ---------------------------------------------------------
                        final List<Ingredient> mergedIngredients = [];

                        if (results.isNotEmpty) {
                          for (final ocrItem in selected) {
                            // จับคู่แบบ case-insensitive โดยใช้ searchTerm จาก DB เป็นหลัก
                            Ingredient? dbMatch;
                            for (final dbItem in results) {
                              final dbKey = (dbItem.searchTerm ?? dbItem.name)
                                  .trim()
                                  .toLowerCase();
                              final ocrKey =
                                  ocrItem.name.trim().toLowerCase();
                              if (dbKey == ocrKey) {
                                dbMatch = dbItem;
                                break;
                              }
                            }

                            if (dbMatch != null) {
                              // ใช้ชื่อ / mg เดิมจาก OCR แต่เติม status / description / riskLevel จาก DB
                              mergedIngredients.add(
                                ocrItem.copyWith(
                                  status: dbMatch.status,
                                  description: dbMatch.description,
                                  riskLevel: dbMatch.riskLevel,
                                ),
                              );
                            }
                          }
                        }

                        final List<HistoryIngredient> ingredientsForHistory =
                            mergedIngredients.map((ing) {
                          return HistoryIngredient(
                            name: ing.name,
                            status: ing.status,
                            riskLevel: ing.riskLevel,
                            description: ing.description,
                          );
                        }).toList();

                        final newScanHistory = ScanHistory(
                          id: _uuid.v4(),
                          scanName: 'Ingredient Scan ${_historyBox.length + 1}',
                          scanDate: DateTime.now(),
                          imagePath: widget.imagePath,
                          ingredients: ingredientsForHistory,
                          imageBytes: widget.scannedImageBytes,
                        );
                        print(
                          'Bytes length to save: ${widget.scannedImageBytes?.lengthInBytes ?? 0}',
                        );
                        await _historyBox.add(newScanHistory);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ResultPage(ingredients: mergedIngredients),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        Navigator.of(context).pop(); // ปิด loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'เกิดข้อผิดพลาดในการดึงข้อมูลจากฐานข้อมูล',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ConfirmationAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          'ตรวจสอบผลการสแกน',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _IngredientList extends StatelessWidget {
  final List<ConfirmItem> items;
  final void Function(int index, bool value) onToggle;
  final void Function(int index) onRemove;

  const _IngredientList({
    required this.items,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'ไม่พบรายการส่วนผสมจากการสแกน',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Checkbox(
                  value: item.checked,
                  onChanged: (v) => onToggle(index, v ?? false),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.ingredient.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.primary,
                  tooltip: 'ลบ',
                  onPressed: () => onRemove(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const _AddSection({required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เพิ่มหรือแก้ไขส่วนผสม',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _AddBar(controller: controller, onAdd: onAdd),
      ],
    );
  }
}

class _ConfirmationFooter extends StatelessWidget {
  final bool isConfirmed;
  final bool canAnalyze;
  final ValueChanged<bool> onConfirmChanged;
  final VoidCallback onAnalyze;

  const _ConfirmationFooter({
    required this.isConfirmed,
    required this.canAnalyze,
    required this.onConfirmChanged,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: isConfirmed,
              onChanged: (v) => onConfirmChanged(v ?? false),
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text('ฉันขอยืนยันว่าข้อมูลทั้งหมดนั้นถูกต้อง'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canAnalyze ? onAnalyze : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: canAnalyze ? AppColors.primary : AppColors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'วิเคราะห์ผล',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
              hintText: 'เพิ่มส่วนผสมเอง...',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('เพิ่ม'),
        ),
      ],
    );
  }
}
