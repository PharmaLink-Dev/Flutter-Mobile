import 'package:app/service/supabase_init.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseQueryService {
  final SupabaseClient _supabase = supabase;

  Future<void> searchInDatabase(List<String> terms) async {
    try {

      final response = await _supabase.rpc(
        'check_ingredients_status',
        params: {'search_terms': terms},
      );

      final List<dynamic> results = response as List<dynamic>;

      print('RPC call results: $results');

    } catch (e) {
      print('Error calling RPC: $e');
    }
  }
}