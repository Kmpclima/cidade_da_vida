// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entrada_financeira.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntradaFinanceiraAdapter extends TypeAdapter<EntradaFinanceira> {
  @override
  final int typeId = 81;

  @override
  EntradaFinanceira read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EntradaFinanceira(
      origem: fields[0] as String,
      data: fields[1] as DateTime,
      valor: fields[2] as double,
      predioRelacionado: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EntradaFinanceira obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.origem)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.valor)
      ..writeByte(3)
      ..write(obj.predioRelacionado);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntradaFinanceiraAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
