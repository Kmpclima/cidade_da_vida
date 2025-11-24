import 'package:hive/hive.dart';
import 'receita.dart';
import 'receita_preparada.dart';

part 'cardapio.g.dart';


@HiveType(typeId: 105)
class ItemAvulso extends HiveObject {
  @HiveField(0)
  String nome;

  @HiveField(1)
  double quantidade;

  @HiveField(2)
  String unidade;

  ItemAvulso({
    required this.nome,
    required this.quantidade,
    required this.unidade,
  });
}

@HiveType(typeId: 102)
class Refeicao extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  List<Receita> receitas;

  @HiveField(3)
  List<ItemAvulso> itensAvulsos;

  @HiveField(4)
  DateTime data;

  @HiveField(5)
  bool concluida;

  @HiveField(6)
  int quantidadePorcoes;

  @HiveField(7)
  bool congelada;

  @HiveField(8)
  List<ReceitaPreparada> preparadasNaRefeicao;

  Refeicao({
    required this.id,
    required this.nome,
    required this.receitas,
    required this.itensAvulsos,
    required this.data,
    required this.concluida,
    required this.quantidadePorcoes,
    required this.congelada,
    required this.preparadasNaRefeicao,
  });
}

@HiveType(typeId: 104)
class Cardapio extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  List<Refeicao> refeicoes;

  @HiveField(3)
  DateTime dataInicio;

  @HiveField(4)
  DateTime dataFim;

  Cardapio({
    required this.id,
    required this.nome,
    required this.refeicoes,
    required this.dataInicio,
    required this.dataFim,
  });
}