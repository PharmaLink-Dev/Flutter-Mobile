import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ingredient.dart';

// demo ไว้การดึงข้อมูลจาก API จริง
class IngredientService {
  final String baseUrl = "https://example.com/api"; // สมมติ API จริง

  Future<List<Ingredient>> fetchIngredients() async {
    final response = await http.get(Uri.parse('$baseUrl/ingredients'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map(
            (item) => Ingredient(
              name: item['name'],
              status: item['status'],
              riskLevel: item['riskLevel'],
            ),
          )
          .toList();
    } else {
      throw Exception('Failed to load ingredients');
    }
  }
}
