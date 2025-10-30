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
      imagePath: fields[2] as String?,
      scanName: fields[3] as String?,
      scanDate: fields[4] as DateTime,
      fdaData: (fields[5] as Map).cast<String, String?>(),
    );
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
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.scanName)
      ..writeByte(4)
      ..write(obj.scanDate)
      ..writeByte(5)
      ..write(obj.fdaData);
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
