import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 1) // New unique typeId for Ingredient
class Ingredient extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String description; // e.g., "Moisturizer", "Preservative"

  @HiveField(2)
  late String safetyLevel; // e.g., "Safe", "Warning", "Danger"

  Ingredient({
    required this.name,
    required this.description,
    required this.safetyLevel,
  });
}
