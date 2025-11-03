import 'dart:typed_data';
import 'package:app/service/supabase_init.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class TyphoonService {
  final _supabase = supabase;
  final _uuid = const Uuid();

  Future<Map<String, String>> uploadAndScanImage(Uint8List croppedBytes) async {
    final String path = 'public/${_uuid.v4()}.png'; 

    try {
      // 2. อัปโหลด
      await _supabase.storage.from('image').uploadBinary(
            path,
            croppedBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );
      
      print('✅ Upload successful! Path: $path');

      final res = await _supabase.functions.invoke(
        'path-ocr',
        body: {'imagePath': path},
      );

      if (res.data == null) {
        throw Exception('Function returned no data');
      }

      final rawOcrResult = res.data['text'] as String;

      return {
        'ocrText': rawOcrResult,
        'imagePath': path,
      };

    } catch (e) {
      print('Error in TyphoonService: $e');
      throw Exception('Upload/Scan failed: $e');
    }
  }
}

