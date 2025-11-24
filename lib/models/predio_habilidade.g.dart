// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'predio_habilidade.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PredioHabilidadeAdapter extends TypeAdapter<PredioHabilidade> {
  @override
  final int typeId = 35;

  @override
  PredioHabilidade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PredioHabilidade(
      id: fields[0] as String,
      nome: fields[1] as String,
      descricao: fields[2] as String,
      nivelNecessario: fields[3] as int,
      iconePath: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PredioHabilidade obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.descricao)
      ..writeByte(3)
      ..write(obj.nivelNecessario)
      ..writeByte(4)
      ..write(obj.iconePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredioHabilidadeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
