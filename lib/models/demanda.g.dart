// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demanda.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DemandaAdapter extends TypeAdapter<Demanda> {
  @override
  final int typeId = 7;

  @override
  Demanda read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Demanda(
      recursoId: fields[0] as String,
      quantidadeSolicitada: fields[1] as double,
      status: fields[2] as String,
      dataSolicitacao: fields[3] as DateTime,
      prazo: fields[4] as DateTime?,
      urgente: fields[5] as bool,
      projetoSolicitante: fields[6] as String,
      valorUnitario: fields[7] as double?,
      descricao: fields[8] as String?,
      link: fields[9] as String?,
      tipoPagamento: fields[10] as String?,
      valorEntrada: fields[11] as double?,
      numeroParcelas: fields[12] as int?,
      parcelasServicoIds: (fields[13] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Demanda obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.recursoId)
      ..writeByte(1)
      ..write(obj.quantidadeSolicitada)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.dataSolicitacao)
      ..writeByte(4)
      ..write(obj.prazo)
      ..writeByte(5)
      ..write(obj.urgente)
      ..writeByte(6)
      ..write(obj.projetoSolicitante)
      ..writeByte(7)
      ..write(obj.valorUnitario)
      ..writeByte(8)
      ..write(obj.descricao)
      ..writeByte(9)
      ..write(obj.link)
      ..writeByte(10)
      ..write(obj.tipoPagamento)
      ..writeByte(11)
      ..write(obj.valorEntrada)
      ..writeByte(12)
      ..write(obj.numeroParcelas)
      ..writeByte(13)
      ..write(obj.parcelasServicoIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DemandaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
