// lib/models/projeto.dart
import 'package:cidade_da_vida/models/recurso_alocado.dart';
import 'package:hive/hive.dart';

part 'projeto.g.dart';


@HiveType(typeId: 2)

class Projeto {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String categoria; // Ex: "Cozinha", "Horta", etc.

  @HiveField(3)
  String descricao;

  @HiveField(4)
  String corHex; // Para identificar visualmente

  @HiveField(5)
  double? orcamento;

  @HiveField(6)
  DateTime? prazoFinal;

  @HiveField(7)
  List<RecursoAlocado> recursosAlocados;

  @HiveField(8)
  List<String>? contatosUteis;

  @HiveField(9)
  double? horasGastas;

  @HiveField(10)
  String? licoesAprendidas;

  @HiveField(11)
  List<String>? conquistas;

  @HiveField(12)
  bool? arquivado;


  Projeto({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.descricao,
    required this.corHex,
    this.orcamento = 0,
    this.prazoFinal,
    this. contatosUteis,
    this.horasGastas = 0,
    this.licoesAprendidas,
    this. conquistas,
    this.arquivado = false,
    this.recursosAlocados = const [],
  });
}
