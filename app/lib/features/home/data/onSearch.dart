import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:app/features/ingredient/data/query_supabase.dart';

/// ค้นหา ingredient เพียง 1 ชื่อ ด้วย RPC เดิม
Future<List<Ingredient>> onSearch(String term) async {
  final trimmed = term.trim();
  if (trimmed.isEmpty) {
    return const [];
  }

  final service = SupabaseQueryService();
  return service.searchInDatabase([trimmed]);
}

