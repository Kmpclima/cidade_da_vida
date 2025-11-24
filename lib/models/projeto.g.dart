// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projeto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjetoAdapter extends TypeAdapter<Projeto> {
  @override
  final int typeId = 2;

  @override
  Projeto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Projeto(
      id: fields[0] as String,
      nome: fields[1] as String,
      categoria: fields[2] as String,
      descricao: fields[3] as String,
      corHex: fields[4] as String,
      orcamento: fields[5] as double?,
      prazoFinal: fields[6] as DateTime?,
      contatosUteis: (fields[8] as List?)?.cast<String>(),
      horasGastas: fields[9] as double?,
      licoesAprendidas: fields[10] as String?,
      conquistas: (fields[11] as List?)?.cast<String>(),
      arquivado: fields[12] as bool?,
      recursosAlocados: (fields[7] as List).cast<RecursoAlocado>(),
    );
  }

  @override
  void write(BinaryWriter writer, Projeto obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.categoria)
      ..writeByte(3)
      ..write(obj.descricao)
      ..writeByte(4)
      ..write(obj.corHex)
      ..writeByte(5)
      ..write(obj.orcamento)
      ..writeByte(6)
      ..write(obj.prazoFinal)
      ..writeByte(7)
      ..write(obj.recursosAlocados)
      ..writeByte(8)
      ..write(obj.contatosUteis)
      ..writeByte(9)
      ..write(obj.horasGastas)
      ..writeByte(10)
      ..write(obj.licoesAprendidas)
      ..writeByte(11)
      ..write(obj.conquistas)
      ..writeByte(12)
      ..write(obj.arquivado);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjetoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
