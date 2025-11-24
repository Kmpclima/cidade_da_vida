import 'package:hive/hive.dart';

part 'receita_preparada.g.dart';

@HiveType(typeId: 99)
class ReceitaPreparada extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String receitaIdOriginal; // id da Receita original, se precisar rastrear

  @HiveField(3)
  DateTime dataPreparo;

  @HiveField(4)
  DateTime validade;

  @HiveField(5)
  int porcoesDisponiveis;

  @HiveField(6)
  double? pesoTotal;

  @HiveField(7)
  double? pesoPorPorcao;

  @HiveField(8)
  String localArmazenamento; // 'geladeira' ou 'freezer'

  @HiveField(9)
  List<String> tags;

  @HiveField(10)
  double? custoPorcao;

  ReceitaPreparada({
    required this.id,
    required this.nome,
    required this.receitaIdOriginal,
    required this.dataPreparo,
    required this.validade,
    required this.porcoesDisponiveis,
    this.pesoTotal,
    this.pesoPorPorcao,
    required this.localArmazenamento,
    required this.tags,
    this.custoPorcao,
  });
}