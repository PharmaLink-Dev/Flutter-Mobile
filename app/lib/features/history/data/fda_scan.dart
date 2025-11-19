import 'package:hive/hive.dart';

part 'fda_scan.g.dart';

@HiveType(typeId: 2) // New unique typeId
class FdaScan extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String fdaNumber;

  @HiveField(2)
  late String? imagePath; // Nullable if no image was scanned

  @HiveField(3)
  late String scanName;

  @HiveField(4)
  late DateTime scanDate;

  @HiveField(5)
  late Map<String, String?> fdaData; // To store the fetched data

  FdaScan({
    required this.id,
    required this.fdaNumber,
    this.imagePath,
    String? scanName,
    required this.scanDate,
    required this.fdaData,
  }) : scanName = scanName ?? fdaNumber;
}
