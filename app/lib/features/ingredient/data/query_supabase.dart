import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:app/service/supabase_init.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service สำหรับเรียก Supabase RPC เพื่อตรวจสอบสถานะสารประกอบ
class SupabaseQueryService {
  final SupabaseClient _supabase = supabase;

  /// เรียกฟังก์ชัน `check_ingredients_status` ใน Supabase
  /// แล้วแปลงผลลัพธ์ให้อยู่ในรูป List<Ingredient> สำหรับใช้บนหน้า Result
  ///
  /// ตัวอย่างโครงสร้างข้อมูลจาก RPC:
  /// [
  ///   {
  ///     "data": {
  ///       "Keyword": "Potassium Citrate",
  ///       "Risk_Level": "red",
  ///       "Explanation": "...",
  ///       "Refference": "..."
  ///     },
  ///     "status": "found",
  ///     "search_term": "Potassium Citrate"
  ///   }
  /// ]
  ///
  /// - แถวที่ `status != "found"` จะถูกกรองทิ้ง (ไม่แสดงใน Result)
  /// - `Risk_Level` (green / yellow / red) จะถูกแปลงเป็นข้อความไทยใน field `status`
  /// - `Explanation` + `Refference` จะถูกนำมารวมเป็น description
  Future<List<Ingredient>> searchInDatabase(List<String> terms) async {
    try {
      final response = await _supabase.rpc(
        'check_ingredients_status',
        params: {'search_terms': terms},
      );

      if (response is! List) {
        print('RPC returned non-list response: $response');
        return const [];
      }

      final ingredients = <Ingredient>[];

      for (final row in response) {
        if (row is! Map) continue;

        // wrapper อาจเป็น Map<dynamic, dynamic> จาก Supabase
        final wrapper = Map<String, dynamic>.from(row as Map);

        final wrapperStatus =
            (wrapper['status'] ?? '').toString().trim().toLowerCase();
        // ถ้าไม่พบข้อมูล ไม่ต้องเอาไปแสดงบน ResultPage
        if (wrapperStatus != 'found') continue;

        final rawData = wrapper['data'];
        final data = rawData is Map
            ? Map<String, dynamic>.from(rawData as Map)
            : <String, dynamic>{};

        final searchTerm =
            (wrapper['search_term'] ?? '').toString().trim();

        final name = (data['Keyword'] ?? searchTerm).toString().trim();

        final rawRiskLevel =
            (data['Risk_Level'] ?? '').toString().trim().toLowerCase();

        final explanation =
            (data['Explanation'] ?? '').toString().trim();
        final reference =
            (data['Refference'] ?? '').toString().trim();

        final statusThai = _mapRiskLevelToThai(rawRiskLevel);

        final buffer = StringBuffer();
        if (explanation.isNotEmpty) {
          buffer.writeln(explanation);
        }
        if (reference.isNotEmpty) {
          if (buffer.isNotEmpty) buffer.writeln();
          buffer.write('อ้างอิง: $reference');
        }

        ingredients.add(
          Ingredient(
            name: name,
            status: statusThai,
            riskLevel: rawRiskLevel,
            description: buffer.toString(),
          ),
        );
      }

      print('RPC call results: ${ingredients.length} items');
      return ingredients;
    } catch (e) {
      print('Error calling RPC: $e');
      rethrow;
    }
  }
}

String _mapRiskLevelToThai(String riskLevel) {
  switch (riskLevel) {
    case 'green':
      return 'ปลอดภัย';
    case 'yellow':
      return 'ควรระวัง';
    case 'red':
      return 'อันตราย';
    default:
      return 'ไม่พบข้อมูล';
  }
}
