import 'package:hive/hive.dart';

part 'entrada_financeira.g.dart';

@HiveType(typeId: 81)
class EntradaFinanceira extends HiveObject {
  @HiveField(0)
  String origem; // ex: Salário, Workshop de Design

  @HiveField(1)
  DateTime data;

  @HiveField(2)
  double valor;

  @HiveField(3)
  String? predioRelacionado;

  EntradaFinanceira({
    required this.origem,
    required this.data,
    required this.valor,
    this.predioRelacionado,
  });
}