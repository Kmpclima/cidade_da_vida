// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insumo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InsumoAdapter extends TypeAdapter<Insumo> {
  @override
  final int typeId = 123;

  @override
  Insumo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Insumo(
      id: fields[0] as String,
      nome: fields[1] as String,
      categoria: fields[2] as String,
      quantidadeTotal: fields[3] as double,
      quantidadeDisponivel: fields[4] as double,
      quantidadeSolicitada: fields[5] as double?,
      unidadeMedida: fields[6] as String,
      valorUnitario: fields[7] as double,
      validade: fields[8] as DateTime?,
      imagemPath: fields[9] as String?,
      dataUltimaCompra: fields[10] as DateTime?,
      status: fields[11] as String,
      prediosVinculados: (fields[12] as List).cast<String>(),
      quantidadeMinima: fields[13] as double,
      estaNaListaCompras: fields[14] as bool,
      marcadoParaCompra: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Insumo obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.categoria)
      ..writeByte(3)
      ..write(obj.quantidadeTotal)
      ..writeByte(4)
      ..write(obj.quantidadeDisponivel)
      ..writeByte(5)
      ..write(obj.quantidadeSolicitada)
      ..writeByte(6)
      ..write(obj.unidadeMedida)
      ..writeByte(7)
      ..write(obj.valorUnitario)
      ..writeByte(8)
      ..write(obj.validade)
      ..writeByte(9)
      ..write(obj.imagemPath)
      ..writeByte(10)
      ..write(obj.dataUltimaCompra)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.prediosVinculados)
      ..writeByte(13)
      ..write(obj.quantidadeMinima)
      ..writeByte(14)
      ..write(obj.estaNaListaCompras)
      ..writeByte(15)
      ..write(obj.marcadoParaCompra);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsumoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
