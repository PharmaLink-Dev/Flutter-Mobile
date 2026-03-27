
import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:app/features/ingredient/domain/confirmation_controller.dart';
import 'package:app/features/ingredient/presentation/result_Page.dart';
import 'package:app/shared/app_colors.dart';
import 'package:app/features/ingredient/data/query_supabase.dart';
import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app/features/history/data/scan_history.dart';
import 'package:app/features/history/data/history_ingredient.dart';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';

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
  final TextEditingController _scanNameCtrl = TextEditingController(); // Controller for scan name
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
    _scanNameCtrl.dispose(); // Dispose the new controller
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: appColors.background,
          appBar: const _ConfirmationAppBar(),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Scan Name Input Field ---
                _ScanNameField(controller: _scanNameCtrl),
                const SizedBox(height: 24),
                Expanded(
                  child: _IngredientList(
                    items: _vm.items,
                    onToggle: _vm.toggleAt,
                    onRemove: _vm.removeAt,
                    onEdit: _vm.editAt,
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

                    final searchTerms = selected.map((e) => e.name).toList();

                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            appColors.primary,
                          ),
                        ),
                      ),
                    );

                    try {
                      final results = await _supabaseQueryService
                          .searchInDatabase(searchTerms);

                      if (!context.mounted) return;

                      Navigator.of(context).pop();

                      final List<Ingredient> mergedIngredients = [];

                      if (results.isNotEmpty) {
                        for (final ocrItem in selected) {
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

                      // --- Use custom name or default ---
                      final scanName = _scanNameCtrl.text.isNotEmpty
                          ? _scanNameCtrl.text
                          : 'Ingredient Scan ${_historyBox.length + 1}';

                      // Only save to history if ingredients are found
                      if (ingredientsForHistory.isNotEmpty) {
                        final newScanHistory = ScanHistory(
                          id: _uuid.v4(),
                          scanName: scanName,
                          scanDate: DateTime.now(),
                          imagePath: widget.imagePath,
                          ingredients: ingredientsForHistory,
                          imageBytes: widget.scannedImageBytes,
                        );
                        await _historyBox.add(newScanHistory);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultPage(
                            ingredients: mergedIngredients,
                            imageBytes: widget.scannedImageBytes,
                            imagePath: widget.imagePath,
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      Navigator.of(context).pop();
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
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.primaryHeader,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'ตรวจสอบผลการสแกน',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }
}
// --- New Widget for Scan Name Input ---
class _ScanNameField extends StatelessWidget {
  final TextEditingController controller;

  const _ScanNameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'ตั้งชื่อการสแกนนี้ (ไม่บังคับ)',
        labelStyle: TextStyle(color: appColors.textSecondary),
        filled: true,
        fillColor: appColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.primary, width: 2),
        ),
      ),
    );
  }
}


class _IngredientList extends StatelessWidget {
  final List<ConfirmItem> items;
  final void Function(int index, bool value) onToggle;
  final void Function(int index) onRemove;
  final void Function(int index, String newName)? onEdit;

  const _IngredientList({
    required this.items,
    required this.onToggle,
    required this.onRemove,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    if (items.isEmpty) {
      return Center(
        child: Text(
          'ไม่พบรายการส่วนผสมจากการสแกน',
          style: TextStyle(color: appColors.textSecondary),
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
            color: appColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Checkbox(
                  value: item.checked,
                  onChanged: (v) => onToggle(index, v ?? false),
                  activeColor: appColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.ingredient.name,
                    style: TextStyle(fontWeight: FontWeight.w600, color: appColors.text),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: appColors.primary,
                  tooltip: 'แก้ไข',
                  onPressed: () {
                    _showEditDialog(context, index, item.ingredient.name, appColors);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: appColors.textSecondary, // Muted color for the close icon
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

  void _showEditDialog(BuildContext context, int index, String currentName, AppColorExtension appColors) {
    final TextEditingController editController = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: appColors.surface,
          title: Text(
            'แก้ไขส่วนผสม',
            style: TextStyle(color: appColors.text),
          ),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'ชื่อส่วนผสม',
              labelStyle: TextStyle(color: appColors.textSecondary),
              filled: true,
              fillColor: appColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: appColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: appColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: appColors.primary, width: 2),
              ),
            ),
            style: TextStyle(color: appColors.text),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Dispose after dialog is closed
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  editController.dispose();
                });
              },
              child: Text(
                'ยกเลิก',
                style: TextStyle(color: appColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = editController.text.trim();
                if (newName.isNotEmpty && onEdit != null) {
                  onEdit!(index, newName);
                }
                Navigator.of(dialogContext).pop();
                // Dispose after dialog is closed
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  editController.dispose();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.primary,
                foregroundColor: appColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('บันทึก'),
            ),
          ],
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
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เพิ่มหรือแก้ไขส่วนผสม',
          style: TextStyle(fontWeight: FontWeight.w600, color: appColors.text),
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
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final onSurfaceTextColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: isConfirmed,
              onChanged: (v) => onConfirmChanged(v ?? false),
              activeColor: appColors.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text('ฉันขอยืนยันว่าข้อมูลทั้งหมดนั้นถูกต้อง', style: TextStyle(color: onSurfaceTextColor)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: canAnalyze ? AppGradients.button : null,
            color: canAnalyze ? null : appColors.textSecondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: canAnalyze
                ? [
                    BoxShadow(
                      color: appColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canAnalyze ? onAnalyze : null,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Text(
                  'วิเคราะห์ผล',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appColors.surface,
                  ),
                ),
              ),
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
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

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
              fillColor: appColors.surface,
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
            backgroundColor: appColors.primary,
            foregroundColor: appColors.surface,
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
