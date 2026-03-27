// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanHistoryAdapter extends TypeAdapter<ScanHistory> {
  @override
  final int typeId = 1;

  @override
  ScanHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanHistory(
      id: fields[0] as String,
      scanName: fields[1] as String,
      scanDate: fields[2] as DateTime,
      imagePath: fields[3] as String,
      ingredients: (fields[4] as List).cast<HistoryIngredient>(),
      isFavorite: fields[5] as bool,
      imageBytes: fields[6] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, ScanHistory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.scanName)
      ..writeByte(2)
      ..write(obj.scanDate)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.ingredients)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.imageBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
