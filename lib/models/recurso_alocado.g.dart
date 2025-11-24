// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurso_alocado.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecursoAlocadoAdapter extends TypeAdapter<RecursoAlocado> {
  @override
  final int typeId = 11;

  @override
  RecursoAlocado read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecursoAlocado(
      recursoId: fields[0] as String,
      quantidade: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, RecursoAlocado obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.recursoId)
      ..writeByte(1)
      ..write(obj.quantidade);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecursoAlocadoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
