import 'package:hive/hive.dart';

part 'distribuicao_orcamentaria.g.dart';

@HiveType(typeId: 82)
class DistribuicaoOrcamentaria extends HiveObject {
  @HiveField(0)
  String predioDestino;

  @HiveField(1)
  DateTime data;

  @HiveField(2)
  double valor;

  @HiveField(3)
  String? descricao;

  DistribuicaoOrcamentaria({
    required this.predioDestino,
    required this.data,
    required this.valor,
    this.descricao,
  });
}