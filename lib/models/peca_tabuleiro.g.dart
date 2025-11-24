// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peca_tabuleiro.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PecaTabuleiroAdapter extends TypeAdapter<PecaTabuleiro> {
  @override
  final int typeId = 200;

  @override
  PecaTabuleiro read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PecaTabuleiro(
      id: fields[0] as String,
      tipo: fields[1] as String,
      nivel: fields[2] as int,
      row: fields[3] as int,
      col: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PecaTabuleiro obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tipo)
      ..writeByte(2)
      ..write(obj.nivel)
      ..writeByte(3)
      ..write(obj.row)
      ..writeByte(4)
      ..write(obj.col);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PecaTabuleiroAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
