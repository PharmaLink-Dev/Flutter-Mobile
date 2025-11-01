// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fda_scan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FdaScanAdapter extends TypeAdapter<FdaScan> {
  @override
  final int typeId = 2;

  @override
  FdaScan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FdaScan(
      id: fields[0] as String,
      fdaNumber: fields[1] as String,
      scanName: fields[2] as String?,
      scanDate: fields[3] as DateTime,
      fdaData: (fields[4] as Map).cast<String, String?>(),
    )..isFavorite = fields[5] as bool;
  }

  @override
  void write(BinaryWriter writer, FdaScan obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fdaNumber)
      ..writeByte(2)
      ..write(obj.scanName)
      ..writeByte(3)
      ..write(obj.scanDate)
      ..writeByte(4)
      ..write(obj.fdaData)
      ..writeByte(5)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FdaScanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
