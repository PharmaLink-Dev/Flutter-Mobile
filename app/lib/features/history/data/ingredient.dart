import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 0)
class Ingredient extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String status; // เช่น "Good", "Bad", "เพิ่มเอง", "ไม่พบข้อมูล"

  // เพิ่ม field อื่นๆ ที่ต้องการเก็บ เช่น detail, caution etc.

  Ingredient({required this.name, required this.status});
}
