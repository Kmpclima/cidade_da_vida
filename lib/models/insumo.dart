import 'package:hive/hive.dart';

part 'insumo.g.dart'; // para gerar o adapter

@HiveType(typeId: 123) // use outro typeId se já estiver ocupado!
class Insumo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String categoria;

  @HiveField(3)
  double quantidadeTotal;

  @HiveField(4)
  double quantidadeDisponivel;

  @HiveField(5)
  double? quantidadeSolicitada;

  @HiveField(6)
  String unidadeMedida;

  @HiveField(7)
  double valorUnitario;

  @HiveField(8)
  DateTime? validade;

  @HiveField(9)
  String? imagemPath;

  @HiveField(10)
  DateTime? dataUltimaCompra;

  @HiveField(11)
  String status;

  @HiveField(12)
  List<String> prediosVinculados;

  @HiveField(13)
  double quantidadeMinima;

  @HiveField(14)
  bool estaNaListaCompras;

  @HiveField(15)
  bool marcadoParaCompra;

  Insumo({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.quantidadeTotal,
    required this.quantidadeDisponivel,
    this.quantidadeSolicitada,
    required this.unidadeMedida,
    required this.valorUnitario,
    this.validade,
    this.imagemPath,
    this.dataUltimaCompra,
    required this.status,
    required this.prediosVinculados,
    required this.quantidadeMinima,
    required this.estaNaListaCompras,
    required this.marcadoParaCompra,
  });
}