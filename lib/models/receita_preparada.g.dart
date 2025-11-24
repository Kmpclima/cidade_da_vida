// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receita_preparada.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceitaPreparadaAdapter extends TypeAdapter<ReceitaPreparada> {
  @override
  final int typeId = 99;

  @override
  ReceitaPreparada read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReceitaPreparada(
      id: fields[0] as String,
      nome: fields[1] as String,
      receitaIdOriginal: fields[2] as String,
      dataPreparo: fields[3] as DateTime,
      validade: fields[4] as DateTime,
      porcoesDisponiveis: fields[5] as int,
      pesoTotal: fields[6] as double?,
      pesoPorPorcao: fields[7] as double?,
      localArmazenamento: fields[8] as String,
      tags: (fields[9] as List).cast<String>(),
      custoPorcao: fields[10] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ReceitaPreparada obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.receitaIdOriginal)
      ..writeByte(3)
      ..write(obj.dataPreparo)
      ..writeByte(4)
      ..write(obj.validade)
      ..writeByte(5)
      ..write(obj.porcoesDisponiveis)
      ..writeByte(6)
      ..write(obj.pesoTotal)
      ..writeByte(7)
      ..write(obj.pesoPorPorcao)
      ..writeByte(8)
      ..write(obj.localArmazenamento)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.custoPorcao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceitaPreparadaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
