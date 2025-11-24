// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receita.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceitaAdapter extends TypeAdapter<Receita> {
  @override
  final int typeId = 21;

  @override
  Receita read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Receita(
      id: fields[0] as String,
      nome: fields[1] as String,
      descricao: fields[2] as String?,
      tempoPreparo: fields[3] as double?,
      ingredientes: (fields[4] as List).cast<IngredientesReceita>(),
      status: fields[5] as String?,
      usarComoInsumo: fields[6] as bool,
      tags: (fields[7] as List).cast<String>(),
      imagemPath: fields[8] as String?,
      validadeDias: fields[9] as int,
      quantidadeProduzida: fields[10] as double?,
      unidade: fields[11] as String?,
      datasPreparo: (fields[12] as List).cast<DateTime>(),
      custoTotal: fields[13] as double?,
      custoPorcao: fields[14] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Receita obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.descricao)
      ..writeByte(3)
      ..write(obj.tempoPreparo)
      ..writeByte(4)
      ..write(obj.ingredientes)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.usarComoInsumo)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.imagemPath)
      ..writeByte(9)
      ..write(obj.validadeDias)
      ..writeByte(10)
      ..write(obj.quantidadeProduzida)
      ..writeByte(11)
      ..write(obj.unidade)
      ..writeByte(12)
      ..write(obj.datasPreparo)
      ..writeByte(13)
      ..write(obj.custoTotal)
      ..writeByte(14)
      ..write(obj.custoPorcao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceitaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IngredientesReceitaAdapter extends TypeAdapter<IngredientesReceita> {
  @override
  final int typeId = 20;

  @override
  IngredientesReceita read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IngredientesReceita(
      idInsumo: fields[0] as String,
      quantidade: fields[1] as double,
      unidade: fields[2] as String,
      opcional: fields[3] as bool,
      nomeInsumo: fields[4] as String,
      valorUnitario: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, IngredientesReceita obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.idInsumo)
      ..writeByte(1)
      ..write(obj.quantidade)
      ..writeByte(2)
      ..write(obj.unidade)
      ..writeByte(3)
      ..write(obj.opcional)
      ..writeByte(4)
      ..write(obj.nomeInsumo)
      ..writeByte(5)
      ..write(obj.valorUnitario);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientesReceitaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
