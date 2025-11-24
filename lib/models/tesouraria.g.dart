// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tesouraria.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TesourariaAdapter extends TypeAdapter<Tesouraria> {
  @override
  final int typeId = 83;

  @override
  Tesouraria read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tesouraria(
      saldoAtual: fields[0] as double,
      entradas: (fields[1] as List).cast<EntradaFinanceira>(),
      distribuicoes: (fields[2] as List).cast<DistribuicaoOrcamentaria>(),
    );
  }

  @override
  void write(BinaryWriter writer, Tesouraria obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.saldoAtual)
      ..writeByte(1)
      ..write(obj.entradas)
      ..writeByte(2)
      ..write(obj.distribuicoes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TesourariaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
