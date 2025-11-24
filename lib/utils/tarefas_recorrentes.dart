import 'package:hive/hive.dart';
import '../models/tarefa.dart';
import '../models/tarefaRecorrente.dart';
import '../models/insumo.dart';
import 'data_utils.dart';


Future<void> verificarTarefasRecorrentesEAdicionar() async {
  final boxRecorrentes = Hive.box<TarefaRecorrente>('tarefasRecorrentes');
  final boxTarefas = Hive.box<Tarefa>('tarefas');
  final hoje = DateTime.now();

  for (final recorrente in boxRecorrentes.values) {
    if (recorrente.encerrar == true) continue;

    final ultimaExec = recorrente.ultimaExecucao?? recorrente.dataCriacao ?? hoje.subtract(const Duration(days: 1));
    final diasDesdeUltima = hoje.difference(ultimaExec).inDays;

    if (diasDesdeUltima >= recorrente.intervaloDias) {
      // Criar nova tarefa
      final novaTarefa = Tarefa(
        nome: recorrente.nome,
        categoria: recorrente.categoria,
        status: 'normal',
        xp: recorrente.xp,
        concluida: false,
        conhecimento: recorrente.conhecimento,
        criatividade: recorrente.criatividade,
        estamina: recorrente.estamina,
        conexao: recorrente.conexao,
        espiritualidade: recorrente.espiritualidade,
        energiaVital: recorrente.energiaVital,
        dataFinal: recorrente.tempoEstimadoMinutos != null ? hoje.add(Duration(minutes: recorrente.tempoEstimadoMinutos!)) : null,
        dataCriacao: hoje,
        kanbanColumn: KanbanColumn.TO_DO,
        tempoEstimadoMinutos: recorrente.tempoEstimadoMinutos,
        isPrioridadeSemana: false,
        projetoId: recorrente.projeto.id,
      );

      await boxTarefas.add(novaTarefa);

      // Atualiza a data de última execução
      recorrente.ultimaExecucao = hoje;
      await recorrente.save();
    }
  }
}