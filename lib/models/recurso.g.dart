// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurso.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecursoAdapter extends TypeAdapter<Recurso> {
  @override
  final int typeId = 4;

  @override
  Recurso read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recurso(
      id: fields[0] as String,
      nome: fields[1] as String,
      unidade: fields[2] as String,
      quantidadeTotal: fields[3] as double,
      quantidadeDisponivel: fields[4] as double,
      valorUnitario: fields[5] as double,
      compartilhavel: fields[6] as bool,
      projetosVinculados: (fields[7] as List).cast<String>(),
      historicoCompras: (fields[8] as List).cast<DateTime>(),
      descricao: fields[9] as String?,
      origem: fields[10] as String?,
      pathImagem: fields[11] as String?,
      valorVenda: fields[12] as double?,
      estaNaPrefeitura: fields[13] as bool,
      status: fields[14] as RecursoStatus,
      prediosVinculados: (fields[15] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Recurso obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.unidade)
      ..writeByte(3)
      ..write(obj.quantidadeTotal)
      ..writeByte(4)
      ..write(obj.quantidadeDisponivel)
      ..writeByte(5)
      ..write(obj.valorUnitario)
      ..writeByte(6)
      ..write(obj.compartilhavel)
      ..writeByte(7)
      ..write(obj.projetosVinculados)
      ..writeByte(8)
      ..write(obj.historicoCompras)
      ..writeByte(9)
      ..write(obj.descricao)
      ..writeByte(10)
      ..write(obj.origem)
      ..writeByte(11)
      ..write(obj.pathImagem)
      ..writeByte(12)
      ..write(obj.valorVenda)
      ..writeByte(13)
      ..write(obj.estaNaPrefeitura)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.prediosVinculados);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecursoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecursoStatusAdapter extends TypeAdapter<RecursoStatus> {
  @override
  final int typeId = 3;

  @override
  RecursoStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecursoStatus.pendente;
      case 1:
        return RecursoStatus.disponivel;
      case 2:
        return RecursoStatus.emUso;
      case 3:
        return RecursoStatus.reservado;
      case 4:
        return RecursoStatus.danificado;
      case 5:
        return RecursoStatus.descartado;
      case 6:
        return RecursoStatus.solicitado;
      case 7:
        return RecursoStatus.aguardandoAprovacao;
      default:
        return RecursoStatus.pendente;
    }
  }

  @override
  void write(BinaryWriter writer, RecursoStatus obj) {
    switch (obj) {
      case RecursoStatus.pendente:
        writer.writeByte(0);
        break;
      case RecursoStatus.disponivel:
        writer.writeByte(1);
        break;
      case RecursoStatus.emUso:
        writer.writeByte(2);
        break;
      case RecursoStatus.reservado:
        writer.writeByte(3);
        break;
      case RecursoStatus.danificado:
        writer.writeByte(4);
        break;
      case RecursoStatus.descartado:
        writer.writeByte(5);
        break;
      case RecursoStatus.solicitado:
        writer.writeByte(6);
        break;
      case RecursoStatus.aguardandoAprovacao:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecursoStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
