// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kanban_historico.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KanbanHistoricoAdapter extends TypeAdapter<KanbanHistorico> {
  @override
  final int typeId = 30;

  @override
  KanbanHistorico read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KanbanHistorico(
      data: fields[0] as DateTime,
      tarefas: (fields[1] as List).cast<KanbanHistoricoTask>(),
      notaDia: fields[2] as int,
      observacoes: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, KanbanHistorico obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.data)
      ..writeByte(1)
      ..write(obj.tarefas)
      ..writeByte(2)
      ..write(obj.notaDia)
      ..writeByte(3)
      ..write(obj.observacoes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KanbanHistoricoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
