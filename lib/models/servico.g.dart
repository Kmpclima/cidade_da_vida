// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servico.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServicoAdapter extends TypeAdapter<Servico> {
  @override
  final int typeId = 101;

  @override
  Servico read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Servico(
      id: fields[0] as String,
      nome: fields[1] as String,
      descricao: fields[2] as String?,
      valor: fields[3] as double,
      recorrente: fields[4] as bool,
      frequencia: fields[5] as String?,
      dataVencimento: fields[6] as DateTime?,
      status: fields[7] as String,
      predioId: fields[8] as String,
      linkDocumento: fields[9] as String?,
      dataPagamento: fields[10] as DateTime?,
      demandaId: fields[11] as String?,
      numParcela: fields[12] as int?,
      totalParcelas: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Servico obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.descricao)
      ..writeByte(3)
      ..write(obj.valor)
      ..writeByte(4)
      ..write(obj.recorrente)
      ..writeByte(5)
      ..write(obj.frequencia)
      ..writeByte(6)
      ..write(obj.dataVencimento)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.predioId)
      ..writeByte(9)
      ..write(obj.linkDocumento)
      ..writeByte(10)
      ..write(obj.dataPagamento)
      ..writeByte(11)
      ..write(obj.demandaId)
      ..writeByte(12)
      ..write(obj.numParcela)
      ..writeByte(13)
      ..write(obj.totalParcelas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServicoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
