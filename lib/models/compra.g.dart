// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compra.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompraAdapter extends TypeAdapter<Compra> {
  @override
  final int typeId = 10;

  @override
  Compra read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Compra(
      id: fields[0] as String,
      dataCompra: fields[1] as DateTime,
      listaInsumos: (fields[2] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      valorEstimado: fields[3] as double,
      valorReal: fields[4] as double?,
      concluida: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Compra obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dataCompra)
      ..writeByte(2)
      ..write(obj.listaInsumos)
      ..writeByte(3)
      ..write(obj.valorEstimado)
      ..writeByte(4)
      ..write(obj.valorReal)
      ..writeByte(5)
      ..write(obj.concluida);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompraAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
