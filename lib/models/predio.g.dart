// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'predio.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PredioAdapter extends TypeAdapter<Predio> {
  @override
  final int typeId = 33;

  @override
  Predio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Predio(
      id: fields[0] as String,
      nome: fields[1] as String,
      categoria: fields[2] as String,
      nivel: fields[3] as int,
      xpTotal: fields[4] as int,
      xpDiario: fields[5] as int,
      status: fields[6] as PredioStatus,
      x1: fields[7] as double,
      y1: fields[8] as double,
      x2: fields[9] as double,
      y2: fields[10] as double,
      imagens: (fields[11] as List?)?.cast<String>(),
      habilidadesDesbloqueadas: (fields[12] as List?)?.cast<PredioHabilidade>(),
      orcamentoMensal: fields[14] as double,
      orcamentoTotal: fields[13] as double,
      cor: fields[15] as String,
      statusManual: fields[16] as PredioStatus?,
      statusManualExpira: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Predio obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.categoria)
      ..writeByte(3)
      ..write(obj.nivel)
      ..writeByte(4)
      ..write(obj.xpTotal)
      ..writeByte(5)
      ..write(obj.xpDiario)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.x1)
      ..writeByte(8)
      ..write(obj.y1)
      ..writeByte(9)
      ..write(obj.x2)
      ..writeByte(10)
      ..write(obj.y2)
      ..writeByte(11)
      ..write(obj.imagens)
      ..writeByte(12)
      ..write(obj.habilidadesDesbloqueadas)
      ..writeByte(13)
      ..write(obj.orcamentoTotal)
      ..writeByte(14)
      ..write(obj.orcamentoMensal)
      ..writeByte(15)
      ..write(obj.cor)
      ..writeByte(16)
      ..write(obj.statusManual)
      ..writeByte(17)
      ..write(obj.statusManualExpira);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PredioStatusAdapter extends TypeAdapter<PredioStatus> {
  @override
  final int typeId = 34;

  @override
  PredioStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PredioStatus.ativo;
      case 1:
        return PredioStatus.pegandoFogo;
      case 2:
        return PredioStatus.abandonado;
      case 3:
        return PredioStatus.boost;
      case 4:
        return PredioStatus.pausado;
      case 5:
        return PredioStatus.fumaceando;
      default:
        return PredioStatus.ativo;
    }
  }

  @override
  void write(BinaryWriter writer, PredioStatus obj) {
    switch (obj) {
      case PredioStatus.ativo:
        writer.writeByte(0);
        break;
      case PredioStatus.pegandoFogo:
        writer.writeByte(1);
        break;
      case PredioStatus.abandonado:
        writer.writeByte(2);
        break;
      case PredioStatus.boost:
        writer.writeByte(3);
        break;
      case PredioStatus.pausado:
        writer.writeByte(4);
        break;
      case PredioStatus.fumaceando:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredioStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
