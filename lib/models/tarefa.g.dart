// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarefa.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TarefaAdapter extends TypeAdapter<Tarefa> {
  @override
  final int typeId = 0;

  @override
  Tarefa read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tarefa(
      id: fields[19] as String?,
      nome: fields[0] as String,
      categoria: fields[1] as String,
      status: fields[2] as String,
      xp: fields[3] as int,
      concluida: fields[4] as bool,
      conhecimento: fields[5] as int,
      criatividade: fields[6] as int,
      estamina: fields[7] as int,
      conexao: fields[8] as int,
      espiritualidade: fields[9] as int,
      energiaVital: fields[10] as int,
      dataFinal: fields[11] as DateTime?,
      projetoId: fields[12] as String?,
      dataCriacao: fields[13] as DateTime?,
      kanbanColumn: fields[14] as KanbanColumn?,
      isPrioridadeSemana: fields[15] as bool?,
      dataConclusao: fields[16] as DateTime?,
      tempoEstimadoMinutos: fields[17] as int?,
      tempoGastoMinutos: fields[18] as int?,
      idHistoricoTask: fields[20] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Tarefa obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.nome)
      ..writeByte(1)
      ..write(obj.categoria)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.xp)
      ..writeByte(4)
      ..write(obj.concluida)
      ..writeByte(5)
      ..write(obj.conhecimento)
      ..writeByte(6)
      ..write(obj.criatividade)
      ..writeByte(7)
      ..write(obj.estamina)
      ..writeByte(8)
      ..write(obj.conexao)
      ..writeByte(9)
      ..write(obj.espiritualidade)
      ..writeByte(10)
      ..write(obj.energiaVital)
      ..writeByte(11)
      ..write(obj.dataFinal)
      ..writeByte(12)
      ..write(obj.projetoId)
      ..writeByte(13)
      ..write(obj.dataCriacao)
      ..writeByte(14)
      ..write(obj.kanbanColumn)
      ..writeByte(15)
      ..write(obj.isPrioridadeSemana)
      ..writeByte(16)
      ..write(obj.dataConclusao)
      ..writeByte(17)
      ..write(obj.tempoEstimadoMinutos)
      ..writeByte(18)
      ..write(obj.tempoGastoMinutos)
      ..writeByte(19)
      ..write(obj.id)
      ..writeByte(20)
      ..write(obj.idHistoricoTask);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TarefaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class KanbanColumnAdapter extends TypeAdapter<KanbanColumn> {
  @override
  final int typeId = 90;

  @override
  KanbanColumn read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return KanbanColumn.TO_DO;
      case 1:
        return KanbanColumn.DOING;
      case 2:
        return KanbanColumn.DONE;
      case 3:
        return KanbanColumn.TODAY;
      default:
        return KanbanColumn.TO_DO;
    }
  }

  @override
  void write(BinaryWriter writer, KanbanColumn obj) {
    switch (obj) {
      case KanbanColumn.TO_DO:
        writer.writeByte(0);
        break;
      case KanbanColumn.DOING:
        writer.writeByte(1);
        break;
      case KanbanColumn.DONE:
        writer.writeByte(2);
        break;
      case KanbanColumn.TODAY:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KanbanColumnAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
