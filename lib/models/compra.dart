import 'package:hive/hive.dart';

part 'compra.g.dart';

@HiveType(typeId: 10)
class Compra extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime dataCompra;

  @HiveField(2)
  List<Map<String, dynamic>> listaInsumos;

  @HiveField(3)
  double valorEstimado;

  @HiveField(4)
  double? valorReal;

  @HiveField(5)
  bool concluida;

  Compra({
    required this.id,
    required this.dataCompra,
    required this.listaInsumos,
    required this.valorEstimado,
    this.valorReal,
    this.concluida = false,
  });
}