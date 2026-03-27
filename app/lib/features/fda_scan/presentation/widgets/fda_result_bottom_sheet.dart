import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/features/fda_scan/data/fda_search_service.dart';

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
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('คัดลอกแล้ว')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final order = <String>[
      'ชื่อผลิตภัณฑ์(TH)',
      'ชื่อผลิตภัณฑ์(EN)',
      'สถานะผลิตภัณฑ์',
      'เลขสารบบ',
      'ชื่อผู้รับอนุญาต',
    ];
    final entries = [
      ...order
          .where((k) => data.containsKey(k))
          .map((k) => MapEntry(k, data[k])),
      ...data.entries.where((e) => !order.contains(e.key)),
    ];

    final allText = entries
        .map((e) => '${e.key}: ${e.value ?? '-'}')
        .join('\n');

    return Material(
      elevation: 12,
      color: Colors
          .transparent, // Use transparent as background is handled by Container
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface, // Use theme surface color
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Builder(
          builder: (context) {
            // helpers for styled cards
            Widget infoCard({
              required IconData icon,
              required Color tint,
              required String label,
              required String value,
            }) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: tint.withOpacity(0.1), // Adjusted opacity
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: tint.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: tint),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            value,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            Widget safetyCard({required bool good}) {
              final goodColor = Colors.green.shade600;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: goodColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: goodColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.shield_outlined, color: goodColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ปลอดภัย',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ได้รับการรับรองจาก อย. กระทรวงสาธารณสุข',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final fdpdtno = (data['เลขสารบบ'] ?? '').trim();
            final Uri? fdaUri = fdpdtno.isNotEmpty
                ? FdaSearchService.buildUriForFdpdtno(fdpdtno)
                : null;

            final nameTh = (data['ชื่อผลิตภัณฑ์(TH)'] ?? '').trim();
            final nameEn = (data['ชื่อผลิตภัณฑ์(EN)'] ?? '').trim();
            final licenseHolder = (data['ชื่อผู้รับอนุญาต'] ?? '').trim();
            final status = (data['สถานะผลิตภัณฑ์'] ?? '').trim();

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ผลการตรวจสอบ',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed:
                          onCopyAll ?? () => _copyToClipboard(context, allText),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('คัดลอกทั้งหมด'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Product names on top
                if (nameTh.isNotEmpty) ...[
                  infoCard(
                    icon: Icons.medication_rounded,
                    tint: Colors
                        .teal
                        .shade400, // A color that works in both modes
                    label: 'ชื่อผลิตภัณฑ์ (TH)',
                    value: nameTh,
                  ),
                  const SizedBox(height: 12),
                ],
                if (nameEn.isNotEmpty) ...[
                  infoCard(
                    icon: Icons.inventory_2_rounded,
                    tint: Colors
                        .purple
                        .shade300, // A color that works in both modes
                    label: 'ชื่อผลิตภัณฑ์ (EN)',
                    value: nameEn,
                  ),
                  const SizedBox(height: 12),
                ],

                if (fdpdtno.isNotEmpty) ...[
                  infoCard(
                    icon: Icons.verified_rounded,
                    tint: Colors
                        .green
                        .shade500, // A color that works in both modes
                    label: 'เลขทะเบียน FDA',
                    value: fdpdtno,
                  ),
                  const SizedBox(height: 12),
                ],

                if (licenseHolder.isNotEmpty) ...[
                  infoCard(
                    icon: Icons.factory_rounded,
                    tint: Colors
                        .blue
                        .shade400, // A color that works in both modes
                    label: 'ผู้รับอนุญาต',
                    value: licenseHolder,
                  ),
                  const SizedBox(height: 12),
                ],

                if (status.contains('คงอยู่')) ...[
                  safetyCard(good: true),
                  const SizedBox(height: 16),
                ],

                Center(
                  child: TextButton.icon(
                    onPressed: (fdaUri == null)
                        ? null
                        : () async {
                            final ok = await launchUrl(
                              fdaUri,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('เปิดลิงก์ไม่สำเร็จ'),
                                ),
                              );
                            }
                          },
                    icon: Icon(
                      Icons.open_in_new_rounded,
                      color: Colors.green.shade600,
                    ),
                    label: Text(
                      'ดูข้อมูลเพิ่มเติมที่ FDA',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
