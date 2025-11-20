import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:app/service/supabase_init.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseQueryService {
  final SupabaseClient _supabase = supabase;
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

        final wrapper = Map<String, dynamic>.from(row as Map);

        final wrapperStatus =
            (wrapper['status'] ?? '').toString().trim().toLowerCase();
        if (wrapperStatus != 'found') continue;

        final rawData = wrapper['data'];
        final data = rawData is Map
            ? Map<String, dynamic>.from(rawData as Map)
            : <String, dynamic>{};

        final searchTerm =
            (wrapper['search_term'] ?? '').toString().trim();

        // ชื่อจากฐานข้อมูล (Keyword) ใช้เพื่ออ้างอิงเชิงวิชาการ
        // แต่เรายังคงเก็บ searchTerm แยกไว้สำหรับจับคู่กับ OCR
        final dbKeyword = (data['Keyword'] ?? '').toString().trim();
        final name = dbKeyword.isNotEmpty ? dbKeyword : searchTerm;

        final rawRiskLevel =
            (data['Risk_Level'] ?? '').toString().trim().toLowerCase();

        final explanation =
            (data['Explanation'] ?? '').toString().trim();
        final reference =
            (data['Reference'] ?? '').toString().trim();

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
            searchTerm: searchTerm.isNotEmpty ? searchTerm : null,
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
