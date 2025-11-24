// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jogadora_status_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JogadoraStatusHiveAdapter extends TypeAdapter<JogadoraStatusHive> {
  @override
  final int typeId = 1;

  @override
  JogadoraStatusHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JogadoraStatusHive(
      xp: fields[0] as int,
      nivel: fields[1] as int,
      conhecimento: fields[2] as int,
      criatividade: fields[3] as int,
      estamina: fields[4] as int,
      conexao: fields[5] as int,
      espiritualidade: fields[6] as int,
      energiaVital: fields[7] as int,
      xpDiarioPorPredio: (fields[8] as Map).cast<String, int>(),
      xpTotalPorPredio: (fields[9] as Map).cast<String, int>(),
      avatarAtual: fields[10] as String,
      dataUltimoAcesso: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, JogadoraStatusHive obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.xp)
      ..writeByte(1)
      ..write(obj.nivel)
      ..writeByte(2)
      ..write(obj.conhecimento)
      ..writeByte(3)
      ..write(obj.criatividade)
      ..writeByte(4)
      ..write(obj.estamina)
      ..writeByte(5)
      ..write(obj.conexao)
      ..writeByte(6)
      ..write(obj.espiritualidade)
      ..writeByte(7)
      ..write(obj.energiaVital)
      ..writeByte(8)
      ..write(obj.xpDiarioPorPredio)
      ..writeByte(9)
      ..write(obj.xpTotalPorPredio)
      ..writeByte(10)
      ..write(obj.avatarAtual)
      ..writeByte(11)
      ..write(obj.dataUltimoAcesso);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JogadoraStatusHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
