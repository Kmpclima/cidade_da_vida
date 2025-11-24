import 'package:hive/hive.dart';

part 'receita.g.dart';

@HiveType(typeId: 21)
class Receita extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String? descricao;

  @HiveField(3)
  double? tempoPreparo;

  @HiveField(4)
  List<IngredientesReceita> ingredientes;

  @HiveField(5)
  String? status;

  @HiveField(6)
  bool usarComoInsumo;

  @HiveField(7)
  List<String> tags;

  @HiveField(8)
  String? imagemPath;

  @HiveField(9)
  int validadeDias;

  @HiveField(10)
  double? quantidadeProduzida;

  @HiveField(11)
  String? unidade;

  @HiveField(12)
  List<DateTime> datasPreparo;

  @HiveField(13)
  double? custoTotal;

  @HiveField(14)
  double? custoPorcao;

  Receita({
    required this.id,
    required this.nome,
    this.descricao,
    this.tempoPreparo,
    required this.ingredientes,
    this.status,
    this.usarComoInsumo = false,
    this.tags = const [],
    this.imagemPath,
    this.validadeDias = 3,
    this.quantidadeProduzida,
    this.unidade,
    this.datasPreparo = const [],
    this.custoTotal,
    this.custoPorcao,
  });
}

@HiveType(typeId: 20)
class IngredientesReceita {
  @HiveField(0)
  String idInsumo;

  @HiveField(1)
  double quantidade;

  @HiveField(2)
  String unidade;

  @HiveField(3)
  bool opcional;

  @HiveField(4)
  String nomeInsumo;

  @HiveField(5)
  double? valorUnitario;

  IngredientesReceita({
    required this.idInsumo,
    required this.quantidade,
    required this.unidade,
    this.opcional = false,
    required this.nomeInsumo,
    this.valorUnitario,
  });
}
