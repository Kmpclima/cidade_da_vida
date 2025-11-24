import 'package:hive/hive.dart';
import 'kanban_historico_task.dart';

part 'kanban_historico.g.dart';

@HiveType(typeId: 30)
class KanbanHistorico extends HiveObject {
  @HiveField(0)
  DateTime data;

  @HiveField(1)
  List<KanbanHistoricoTask> tarefas;

  @HiveField(2)
  int notaDia; // 1 a 5 estrelas

  @HiveField(3)
  String? observacoes;

  KanbanHistorico({
    required this.data,
    required this.tarefas,
    this.notaDia = 0,
    this.observacoes,
  });
}