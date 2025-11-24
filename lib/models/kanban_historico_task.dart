import 'package:hive/hive.dart';
import 'tarefa.dart';

part 'kanban_historico_task.g.dart';

@HiveType(typeId: 25)
class KanbanHistoricoTask extends HiveObject {
  @HiveField(0)
  String idTarefa;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String categoria;

  @HiveField(3)
  String? projetoId;

  @HiveField(4)
  KanbanColumn kanbanColumn;

  @HiveField(5)
  int? tempoEstimadoMinutos;

  @HiveField(6)
  int? tempoGastoMinutos;

  @HiveField(7)
  DateTime? dataConclusao;

  @HiveField(8)
  bool isPrioridadeSemana;

  @HiveField(9)
  String status;

  @HiveField(10)
  int xp;

  @HiveField(11)
  int conhecimento;

  @HiveField(12)
  int criatividade;

  @HiveField(13)
  int estamina;

  @HiveField(14)
  int conexao;

  @HiveField(15)
  int espiritualidade;

  @HiveField(16)
  int energiaVital;

  @HiveField(17)
  DateTime? inicioExecucao;

  KanbanHistoricoTask({
    required this.idTarefa,
    required this.nome,
    required this.categoria,
    this.projetoId,
    required this.kanbanColumn,
    this.tempoEstimadoMinutos,
    this.tempoGastoMinutos,
    this.dataConclusao,
    this.isPrioridadeSemana = false,
    required this.status,
    this.xp = 0,
    this.conhecimento = 0,
    this.criatividade = 0,
    this.estamina = 0,
    this.conexao = 0,
    this.espiritualidade = 0,
    this.energiaVital = 0,
    this.inicioExecucao,
  });
}