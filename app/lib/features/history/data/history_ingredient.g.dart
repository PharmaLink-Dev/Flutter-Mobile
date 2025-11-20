// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_ingredient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryIngredientAdapter extends TypeAdapter<HistoryIngredient> {
  @override
  final int typeId = 0;

  @override
  HistoryIngredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryIngredient(
      name: fields[0] as String,
      status: fields[1] as String,
      riskLevel: fields[2] as String,
      description: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryIngredient obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.riskLevel)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryIngredientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
