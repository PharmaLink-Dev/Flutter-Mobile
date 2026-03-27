import 'package:hive/hive.dart';

part 'history_ingredient.g.dart';

@HiveType(typeId: 0) // ตรวจสอบ typeId ให้ถูกต้อง
class HistoryIngredient extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String status;

  @HiveField(2)
  final String riskLevel;

  @HiveField(3)
  final String description;

  HistoryIngredient({
    required this.name,
    required this.status,
    this.riskLevel = '',
    this.description = '',
  });
}
