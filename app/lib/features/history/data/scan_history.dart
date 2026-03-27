import 'package:hive/hive.dart';
import 'history_ingredient.dart'; // Import the new Ingredient model
import 'dart:typed_data';

part 'scan_history.g.dart';

@HiveType(typeId: 1)
class ScanHistory extends HiveObject {
  @HiveField(0)
  late String id; // Unique ID (e.g., UUID)

  @HiveField(1)
  late String scanName; // ชื่อสแกน, อาจเป็นชื่อรูปภาพ หรือวันที่/เวลา

  @HiveField(2)
  late DateTime scanDate;

  @HiveField(3)
  late String imagePath; // Path/URL ของรูปภาพที่สแกน

  @HiveField(4)
  late List<HistoryIngredient> ingredients; // รายการส่วนผสมที่ได้

  @HiveField(5)
  bool isFavorite = false;

  @HiveField(6) // กำหนด HiveField ใหม่
  late Uint8List? imageBytes; // ใช้ Uint8List สำหรับเก็บข้อมูลรูปภาพ

  ScanHistory({
    required this.id,
    required this.scanName,
    required this.scanDate,
    required this.imagePath,
    required this.ingredients,
    this.isFavorite = false,
    this.imageBytes,
  });
}
