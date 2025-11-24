// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lista_geral.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemListaAdapter extends TypeAdapter<ItemLista> {
  @override
  final int typeId = 161;

  @override
  ItemLista read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemLista(
      id: fields[0] as String,
      descricao: fields[1] as String,
      quantidade: fields[2] as double?,
      unidade: fields[3] as String?,
      observacao: fields[4] as String?,
      concluido: fields[5] as bool,
      tarefaIdVinculada: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ItemLista obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.descricao)
      ..writeByte(2)
      ..write(obj.quantidade)
      ..writeByte(3)
      ..write(obj.unidade)
      ..writeByte(4)
      ..write(obj.observacao)
      ..writeByte(5)
      ..write(obj.concluido)
      ..writeByte(6)
      ..write(obj.tarefaIdVinculada);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemListaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ListaGeralAdapter extends TypeAdapter<ListaGeral> {
  @override
  final int typeId = 162;

  @override
  ListaGeral read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListaGeral(
      id: fields[0] as String,
      predioId: fields[1] as String,
      titulo: fields[2] as String,
      itens: (fields[3] as List?)?.cast<ItemLista>(),
      criadoEm: fields[4] as DateTime?,
      arquivada: fields[5] as bool,
      executavel: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ListaGeral obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.predioId)
      ..writeByte(2)
      ..write(obj.titulo)
      ..writeByte(3)
      ..write(obj.itens)
      ..writeByte(4)
      ..write(obj.criadoEm)
      ..writeByte(5)
      ..write(obj.arquivada)
      ..writeByte(6)
      ..write(obj.executavel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListaGeralAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
