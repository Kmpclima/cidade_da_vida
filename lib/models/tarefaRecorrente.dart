import 'package:cidade_da_vida/models/projeto.dart';
import 'package:hive/hive.dart';
import 'package:cidade_da_vida/models/insumo.dart';
import 'package:cidade_da_vida/models/projeto.dart';

part 'tarefaRecorrente.g.dart';

@HiveType(typeId: 91)
class TarefaRecorrente extends HiveObject {
  @HiveField(0)
  String nome;

  @HiveField(1)
  String categoria;

  @HiveField(2)
  String status;

  @HiveField(3)
  int xp;

  @HiveField(4)
  bool ativa;

  @HiveField(5)
  DateTime dataInicio;

  @HiveField(6)
  int intervaloDias; // <- substitui o enum FrequenciaRecorrencia

  @HiveField(7)
  bool gerarNoDiaAtual;

  @HiveField(8)
  int conhecimento;

  @HiveField(9)
  int criatividade;

  @HiveField(10)
  int estamina;

  @HiveField(11)
  int conexao;

  @HiveField(12)
  int espiritualidade;

  @HiveField(13)
  int energiaVital;

  @HiveField(14)
  List<Insumo> insumos; // modelo auxiliar, você pode ajustar

  @HiveField(15)
  bool encerrar;

  @HiveField(16)
  DateTime? ultimaExecucao;

  @HiveField(17)
  DateTime? dataCriacao;

  @HiveField(18)
  int? tempoEstimadoMinutos;

  @HiveField(19)
  Projeto projeto;


  TarefaRecorrente({
    required this.nome,
    required this.categoria,
    required this.status,
    this.xp = 0,
    this.ativa = true,
    required this.dataInicio,
    this.intervaloDias = 7,
    this.gerarNoDiaAtual = true,
    this.conhecimento = 0,
    this.criatividade = 0,
    this.estamina = 0,
    this.conexao = 0,
    this.espiritualidade = 0,
    this.energiaVital = 0,
    this.insumos = const [],
    this.encerrar = false,
    this.ultimaExecucao,
    this.dataCriacao,
    this.tempoEstimadoMinutos,
    required this.projeto,
  });
}