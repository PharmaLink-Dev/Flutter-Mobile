import 'package:hive/hive.dart';
import 'ingredient.dart'; // Import the new Ingredient model

part 'scan_history.g.dart';

@HiveType(typeId: 0)
class ScanHistory extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String imagePath; // This remains the same

  @HiveField(2)
  late List<Ingredient> ingredients; // Changed to a list of Ingredient objects

  @HiveField(3)
  late DateTime scanDate;

  @HiveField(4)
  late bool isFavorite;

  ScanHistory({
    required this.id,
    required this.imagePath,
    required this.ingredients, // Updated constructor
    required this.scanDate,
    this.isFavorite = false,
  });
}
