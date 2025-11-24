import 'package:hive/hive.dart';

part 'tarefa.g.dart';

@HiveType(typeId: 90)
enum KanbanColumn {
  @HiveField(0)
  TO_DO,

  @HiveField(1)
  DOING,

  @HiveField(2)
  DONE,

  @HiveField(3)
  TODAY,
}

@HiveType(typeId: 0)
class Tarefa extends HiveObject {
  @HiveField(0)
  String nome;

  @HiveField(1)
  String categoria;

  @HiveField(2)
  String status;

  @HiveField(3)
  int xp;

  @HiveField(4)
  bool concluida;

  @HiveField(5)
  int conhecimento;

  @HiveField(6)
  int criatividade;

  @HiveField(7)
  int estamina;

  @HiveField(8)
  int conexao;

  @HiveField(9)
  int espiritualidade;

  @HiveField(10)
  int energiaVital;

  @HiveField(11)
  DateTime? dataFinal;

  @HiveField(12)
  String? projetoId;

  @HiveField(13)
  DateTime? dataCriacao;

  @HiveField(14)
  KanbanColumn? kanbanColumn;

  @HiveField(15)
  bool? isPrioridadeSemana;

  @HiveField(16)
  DateTime? dataConclusao;

  @HiveField(17)
  int? tempoEstimadoMinutos;

  @HiveField(18)
  int? tempoGastoMinutos;

  @HiveField(19)
  String? id;

  @HiveField(20)
  int? idHistoricoTask;

  Tarefa({
    this.id,
    required this.nome,
    required this.categoria,
    required this.status,
    this.xp = 0,
    this.concluida = false,
    this.conhecimento = 0,
    this.criatividade = 0,
    this.estamina = 0,
    this.conexao = 0,
    this.espiritualidade = 0,
    this.energiaVital = 0,
    this.dataFinal,
    this.projetoId,
    this.dataCriacao,
    this.kanbanColumn,
    this.isPrioridadeSemana,
    this.dataConclusao,
    this.tempoEstimadoMinutos,
    this.tempoGastoMinutos,
    this.idHistoricoTask,
  });
}