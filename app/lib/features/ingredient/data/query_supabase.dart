import 'package:app/service/supabase_init.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseQueryService {
  final SupabaseClient _supabase = supabase;

  Future<void> searchInDatabase(List<String> terms) async {
    try {

      final response = await _supabase.rpc(
        'search_ingredients',
        params: {'search_terms': terms},
      );

      final List<dynamic> results = response as List<dynamic>;

      for (var item in results) {
        final String searchTerm = item['search_term'];
        final String status = item['status']; 
        final Map<String, dynamic>? data = item['data'];

        if (status == 'found') {
          print('เจอสาร: $searchTerm -> ข้อมูล: ${data?['Keyword']}');
        } else {
          print('ไม่เจอสาร: $searchTerm');
        }
      }
    } catch (e) {
      print('Error calling RPC: $e');
    }
  }
}