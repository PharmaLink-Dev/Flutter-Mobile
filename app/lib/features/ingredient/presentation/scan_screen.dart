import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:app/features/scan/presentation/crop_image_screen.dart';
import 'package:app/features/scan/presentation/widgets/scan_overlay.dart';
import 'package:app/features/scan/presentation/widgets/scan_page_template.dart';
import 'package:app/service/supabase_init.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'confirmation_page.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  void _goToCrop(BuildContext context, Uint8List bytes, String fileName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CropImageScreen(
          imageBytes: bytes,
          fileName: fileName,
          onCropped: (croppedBytes, originalFilename) async {
            final String path = 'public/${const Uuid().v4()}.png';

            try {
              final String storagePath = await supabase.storage.from('image').uploadBinary(
                    path,
                    croppedBytes,
                    fileOptions: const FileOptions(
                      cacheControl: '3600',
                      upsert: false,
                    ),
                  );
              
              final String publicUrl = supabase.storage.from('image').getPublicUrl(storagePath);
              print('✅ Upload successful! Image URL: $publicUrl');

              if (!context.mounted) return;
             
              // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ConfirmationPage()));
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload failed: $e')),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScanPageTemplate(
      headerTitle: 'สแกนสาร',
      overlay: const ScanOverlay(width: 320, height: 320),
      guideText: 'วางฉลากให้อยู่ในกรอบ',
      showGalleryUpload: true,
      onCaptured: (bytes, fileName) async => _goToCrop(context, bytes, fileName),
    );
  }
}
