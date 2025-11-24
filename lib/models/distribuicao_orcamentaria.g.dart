// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distribuicao_orcamentaria.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DistribuicaoOrcamentariaAdapter
    extends TypeAdapter<DistribuicaoOrcamentaria> {
  @override
  final int typeId = 82;

  @override
  DistribuicaoOrcamentaria read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DistribuicaoOrcamentaria(
      predioDestino: fields[0] as String,
      data: fields[1] as DateTime,
      valor: fields[2] as double,
      descricao: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DistribuicaoOrcamentaria obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.predioDestino)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.valor)
      ..writeByte(3)
      ..write(obj.descricao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistribuicaoOrcamentariaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
