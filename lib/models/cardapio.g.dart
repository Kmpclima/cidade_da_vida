// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cardapio.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAvulsoAdapter extends TypeAdapter<ItemAvulso> {
  @override
  final int typeId = 105;

  @override
  ItemAvulso read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemAvulso(
      nome: fields[0] as String,
      quantidade: fields[1] as double,
      unidade: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemAvulso obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.nome)
      ..writeByte(1)
      ..write(obj.quantidade)
      ..writeByte(2)
      ..write(obj.unidade);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAvulsoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RefeicaoAdapter extends TypeAdapter<Refeicao> {
  @override
  final int typeId = 102;

  @override
  Refeicao read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Refeicao(
      id: fields[0] as String,
      nome: fields[1] as String,
      receitas: (fields[2] as List).cast<Receita>(),
      itensAvulsos: (fields[3] as List).cast<ItemAvulso>(),
      data: fields[4] as DateTime,
      concluida: fields[5] as bool,
      quantidadePorcoes: fields[6] as int,
      congelada: fields[7] as bool,
      preparadasNaRefeicao: (fields[8] as List).cast<ReceitaPreparada>(),
    );
  }

  @override
  void write(BinaryWriter writer, Refeicao obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.receitas)
      ..writeByte(3)
      ..write(obj.itensAvulsos)
      ..writeByte(4)
      ..write(obj.data)
      ..writeByte(5)
      ..write(obj.concluida)
      ..writeByte(6)
      ..write(obj.quantidadePorcoes)
      ..writeByte(7)
      ..write(obj.congelada)
      ..writeByte(8)
      ..write(obj.preparadasNaRefeicao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefeicaoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CardapioAdapter extends TypeAdapter<Cardapio> {
  @override
  final int typeId = 104;

  @override
  Cardapio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cardapio(
      id: fields[0] as String,
      nome: fields[1] as String,
      refeicoes: (fields[2] as List).cast<Refeicao>(),
      dataInicio: fields[3] as DateTime,
      dataFim: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Cardapio obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.refeicoes)
      ..writeByte(3)
      ..write(obj.dataInicio)
      ..writeByte(4)
      ..write(obj.dataFim);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardapioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
