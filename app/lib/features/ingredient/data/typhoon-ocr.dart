import 'dart:typed_data';
import 'dart:io';
import 'package:app/service/supabase_init.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class TyphoonService {
  final SupabaseClient _supabase = supabase;
  final Uuid _uuid = const Uuid();

  Future<Map<String, dynamic>> uploadAndScanImage(
    Uint8List croppedBytes,
  ) async {
    final String path = 'public/${_uuid.v4()}.png';

    try {
      await _supabase.storage
          .from('image')
          .uploadBinary(
            path,
            croppedBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
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
        final errorMessage =
            (res.data as Map)['error'] ?? 'Unknown function error';
        throw Exception(errorMessage.toString());
      }

      final data = res.data as Map<String, dynamic>;

      final List<dynamic> rawList = (data['ingredients'] as List?) ?? [];
      final List<Map<String, dynamic>> ingredientList = rawList
          .map((e) => e as Map<String, dynamic>)
          .toList();

      return {'ingredients': ingredientList, 'imagePath': path};
    } on SocketException catch (e) {
      print('Network error - No internet connection: $e');
      throw Exception(
        'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้\nกรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณและลองอีกครั้ง',
      );
    } on HttpException catch (e) {
      print('HTTP error: $e');
      throw Exception(
        'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์\nกรุณาลองอีกครั้งในภายหลัง',
      );
    } on FormatException catch (e) {
      print('Format error: $e');
      throw Exception(
        'ข้อมูลที่ได้รับจากเซิร์ฟเวอร์ไม่ถูกต้อง\nกรุณาลองอีกครั้ง',
      );
    } catch (e) {
      print('Error in TyphoonService: $e');

      // Check if error message contains network-related keywords
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('failed host lookup') ||
          errorStr.contains('network') ||
          errorStr.contains('socket')) {
        throw Exception(
          'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้\nกรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณและลองอีกครั้ง',
        );
      }

      throw Exception('เกิดข้อผิดพลาดในการสแกน: ${e.toString()}');
    }
  }
}
