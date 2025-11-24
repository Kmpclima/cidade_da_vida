// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarefaRecorrente.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TarefaRecorrenteAdapter extends TypeAdapter<TarefaRecorrente> {
  @override
  final int typeId = 91;

  @override
  TarefaRecorrente read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TarefaRecorrente(
      nome: fields[0] as String,
      categoria: fields[1] as String,
      status: fields[2] as String,
      xp: fields[3] as int,
      ativa: fields[4] as bool,
      dataInicio: fields[5] as DateTime,
      intervaloDias: fields[6] as int,
      gerarNoDiaAtual: fields[7] as bool,
      conhecimento: fields[8] as int,
      criatividade: fields[9] as int,
      estamina: fields[10] as int,
      conexao: fields[11] as int,
      espiritualidade: fields[12] as int,
      energiaVital: fields[13] as int,
      insumos: (fields[14] as List).cast<Insumo>(),
      encerrar: fields[15] as bool,
      ultimaExecucao: fields[16] as DateTime?,
      dataCriacao: fields[17] as DateTime?,
      tempoEstimadoMinutos: fields[18] as int?,
      projeto: fields[19] as Projeto,
    );
  }

  @override
  void write(BinaryWriter writer, TarefaRecorrente obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.nome)
      ..writeByte(1)
      ..write(obj.categoria)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.xp)
      ..writeByte(4)
      ..write(obj.ativa)
      ..writeByte(5)
      ..write(obj.dataInicio)
      ..writeByte(6)
      ..write(obj.intervaloDias)
      ..writeByte(7)
      ..write(obj.gerarNoDiaAtual)
      ..writeByte(8)
      ..write(obj.conhecimento)
      ..writeByte(9)
      ..write(obj.criatividade)
      ..writeByte(10)
      ..write(obj.estamina)
      ..writeByte(11)
      ..write(obj.conexao)
      ..writeByte(12)
      ..write(obj.espiritualidade)
      ..writeByte(13)
      ..write(obj.energiaVital)
      ..writeByte(14)
      ..write(obj.insumos)
      ..writeByte(15)
      ..write(obj.encerrar)
      ..writeByte(16)
      ..write(obj.ultimaExecucao)
      ..writeByte(17)
      ..write(obj.dataCriacao)
      ..writeByte(18)
      ..write(obj.tempoEstimadoMinutos)
      ..writeByte(19)
      ..write(obj.projeto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TarefaRecorrenteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
