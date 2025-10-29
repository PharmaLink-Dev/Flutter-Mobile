import '../models/ingredient.dart';

final List<Ingredient> sampleIngredients = [
  Ingredient(name: 'Vitamin B-Complex', status: 'ปลอดภัย', riskLevel: 'ต่ำ'),
  Ingredient(
    name: 'Potassium Chloride',
    status: 'เสี่ยงสูง',
    riskLevel: 'รุนแรง',
  ),
  Ingredient(name: 'Phosphorus', status: 'เสี่ยงสูง', riskLevel: 'รุนแรง'),
  Ingredient(name: 'Vitamin A', status: 'เสี่ยง', riskLevel: 'ปานกลาง'),
];
