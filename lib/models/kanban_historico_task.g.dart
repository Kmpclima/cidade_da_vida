// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kanban_historico_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KanbanHistoricoTaskAdapter extends TypeAdapter<KanbanHistoricoTask> {
  @override
  final int typeId = 25;

  @override
  KanbanHistoricoTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KanbanHistoricoTask(
      idTarefa: fields[0] as String,
      nome: fields[1] as String,
      categoria: fields[2] as String,
      projetoId: fields[3] as String?,
      kanbanColumn: fields[4] as KanbanColumn,
      tempoEstimadoMinutos: fields[5] as int?,
      tempoGastoMinutos: fields[6] as int?,
      dataConclusao: fields[7] as DateTime?,
      isPrioridadeSemana: fields[8] as bool,
      status: fields[9] as String,
      xp: fields[10] as int,
      conhecimento: fields[11] as int,
      criatividade: fields[12] as int,
      estamina: fields[13] as int,
      conexao: fields[14] as int,
      espiritualidade: fields[15] as int,
      energiaVital: fields[16] as int,
      inicioExecucao: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, KanbanHistoricoTask obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.idTarefa)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.categoria)
      ..writeByte(3)
      ..write(obj.projetoId)
      ..writeByte(4)
      ..write(obj.kanbanColumn)
      ..writeByte(5)
      ..write(obj.tempoEstimadoMinutos)
      ..writeByte(6)
      ..write(obj.tempoGastoMinutos)
      ..writeByte(7)
      ..write(obj.dataConclusao)
      ..writeByte(8)
      ..write(obj.isPrioridadeSemana)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.xp)
      ..writeByte(11)
      ..write(obj.conhecimento)
      ..writeByte(12)
      ..write(obj.criatividade)
      ..writeByte(13)
      ..write(obj.estamina)
      ..writeByte(14)
      ..write(obj.conexao)
      ..writeByte(15)
      ..write(obj.espiritualidade)
      ..writeByte(16)
      ..write(obj.energiaVital)
      ..writeByte(17)
      ..write(obj.inicioExecucao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KanbanHistoricoTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
