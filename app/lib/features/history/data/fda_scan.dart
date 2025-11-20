import 'package:hive/hive.dart';

part 'fda_scan.g.dart';

@HiveType(typeId: 2) // New unique typeId
class FdaScan extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String fdaNumber;

  @HiveField(2)
  late String scanName;

  @HiveField(3)
  late DateTime scanDate;

  @HiveField(4)
  late Map<String, String?> fdaData; // To store the fetched data

  @HiveField(5)
  bool isFavorite = false;

  FdaScan({
    required this.id,
    required this.fdaNumber,
    String? scanName,
    required this.scanDate,
    required this.fdaData,
  }) : scanName = scanName ?? fdaNumber;
}
