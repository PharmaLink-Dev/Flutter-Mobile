import 'dart:typed_data';
import 'package:app/service/supabase_init.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class TyphoonService {
  final SupabaseClient _supabase = supabase;
  final Uuid _uuid = const Uuid();

  Future<Map<String, dynamic>> uploadAndScanImage(Uint8List croppedBytes) async {
    final String path = 'public/${_uuid.v4()}.png';

    try {
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

      if (res.data is Map && (res.data as Map)['error'] != null) {
        final errorMessage = (res.data as Map)['error'] ?? 'Unknown function error';
        throw Exception(errorMessage.toString());
      }

      final data = res.data as Map<String, dynamic>;

      final List<dynamic> rawList = (data['ingredients'] as List?) ?? [];
      final List<Map<String, dynamic>> ingredientList =
          rawList.map((e) => e as Map<String, dynamic>).toList();

      return {
        'ingredients': ingredientList,
        'imagePath': path,
      };
    } catch (e) {

      print('Error in TyphoonService: $e');
      throw Exception('Upload/Scan failed: ${e.toString()}');
    }
  }
}
