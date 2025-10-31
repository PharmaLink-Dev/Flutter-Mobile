import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FdaResultBottomSheet extends StatelessWidget {
  final Map<String, String?> data;
  final VoidCallback? onCopyAll;
  final ScrollController? scrollController;

  const FdaResultBottomSheet({
    super.key,
    required this.data,
    this.onCopyAll,
    this.scrollController,
  });

  void _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('คัดลอกแล้ว')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = <String>[
      'ชื่อผลิตภัณฑ์(TH)',
      'ชื่อผลิตภัณฑ์(EN)',
      'สถานะผลิตภัณฑ์',
      'เลขสารบบ',
      'ชื่อผู้รับอนุญาต',
    ];
    final entries = [
      ...order.where((k) => data.containsKey(k)).map((k) => MapEntry(k, data[k])),
      ...data.entries.where((e) => !order.contains(e.key)),
    ];

    final allText = entries.map((e) => '${e.key}: ${e.value ?? '-'}').join('\n');

    return Material(
      elevation: 12,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -6)),
          ],
        ),
        child: ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          itemCount: entries.length + 1,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ผลการตรวจสอบ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onCopyAll ?? () => _copyToClipboard(context, allText),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('คัดลอก'),
                  ),
                ],
              );
            }

            final e = entries[index - 1];
            final value = (e.value == null || e.value!.trim().isEmpty) ? '-' : e.value!.trim();
            final isStatus = e.key == 'สถานะผลิตภัณฑ์';
            final isNameTh = e.key == 'ชื่อผลิตภัณฑ์(TH)';

            TextStyle titleStyle = const TextStyle(fontWeight: FontWeight.w600);
            TextStyle subtitleStyle = const TextStyle();
            Widget subtitleWidget;

            if (isStatus) {
              final isGood = value.contains('คงอยู่');
              final statusColor = isGood ? Colors.green : Colors.black87;
              subtitleWidget = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isGood) const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  if (isGood) const SizedBox(width: 6),
                  Text(value, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
                ],
              );
            } else if (isNameTh) {
              // Render like other rows (no extra emphasis)
              subtitleWidget = Text(value, style: subtitleStyle);
            } else {
              subtitleWidget = Text(value, style: subtitleStyle);
            }

            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(e.key, style: titleStyle),
              subtitle: subtitleWidget,
              trailing: null,
            );
          },
        ),
      ),
    );
  }
}
