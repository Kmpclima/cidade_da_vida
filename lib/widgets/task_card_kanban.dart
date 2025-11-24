import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tarefa.dart';
import '../animations/animations_manager.dart';
import 'package:cidade_da_vida/models/kanban_historico_task.dart';
import '../widgets/timer_widget.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class TaskCardKanban extends StatelessWidget {
  final Tarefa tarefa;
  final String status;
  final Future<void> Function(Tarefa)? onConcluir;
  final VoidCallback onRemover;
  final VoidCallback onTogglePrioridade;

  const TaskCardKanban({
    super.key,
    required this.tarefa,
    required this.status,
    required this.onConcluir,
    required this.onRemover,
    required this.onTogglePrioridade,
  });

  @override
  Widget build(BuildContext context) {
    Widget? animacao;

    // ✅ Carrega histórico salvo se existir
    // ✅ Carrega/garante 1 único histórico por tarefa
    final boxHistorico = Hive.box<KanbanHistoricoTask>('kanban_historico_tasks');

// garante ID estável
    String tarefaId = tarefa.id ?? '';
    if (tarefaId.isEmpty) {
      tarefaId = const Uuid().v4();

      // salva fora do build
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        tarefa.id = tarefaId;
        await tarefa.save();
      });
    }

    KanbanHistoricoTask? historicoTask;

// 1) tenta pelo id salvo na própria tarefa
    if (tarefa.idHistoricoTask != null) {
      historicoTask = boxHistorico.get(tarefa.idHistoricoTask);
    }

// 2) se não achou, tenta por idTarefa (evita duplicar em rebuild)
    final historicoExistente = boxHistorico.values
        .cast<KanbanHistoricoTask>()
        .where((h) => h.idTarefa == tarefaId)
        .toList();

    if (historicoExistente.isNotEmpty) {
      historicoTask ??= historicoExistente.first;
    }

// 3) se ainda não existir, cria UMA vez e persiste após o frame
    if (historicoTask == null) {
      final novo = KanbanHistoricoTask(
        idTarefa: tarefaId,
        nome: tarefa.nome,
        categoria: tarefa.categoria,
        projetoId: tarefa.projetoId,
        kanbanColumn: tarefa.kanbanColumn ?? KanbanColumn.TO_DO,
        tempoEstimadoMinutos: tarefa.tempoEstimadoMinutos,
        tempoGastoMinutos: tarefa.tempoGastoMinutos,
        dataConclusao: tarefa.dataConclusao,
        isPrioridadeSemana: tarefa.isPrioridadeSemana ?? false,
        status: tarefa.status,
        xp: tarefa.xp,
        conhecimento: tarefa.conhecimento,
        criatividade: tarefa.criatividade,
        estamina: tarefa.estamina,
        conexao: tarefa.conexao,
        espiritualidade: tarefa.espiritualidade,
        energiaVital: tarefa.energiaVital,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final key = await boxHistorico.add(novo);
        tarefa.idHistoricoTask = key;
        await tarefa.save();
      });

      historicoTask = novo;
    }
    switch (status) {
      case "Urgente":
        animacao = AnimationsManager.fogo(width: 50, height: 50, versao: 1);
        break;
      case "Atrasada":
        animacao = AnimationsManager.fogo(width: 50, height: 50, versao: 2);
        break;
      case "Abandonada":
        animacao = AnimationsManager.teia(width: 50, height: 50);
        break;
      default:
        animacao = null;
    }

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("assets/images/papiro.jpg"),
          fit: BoxFit.cover,
        ),
        border: Border.all(
          color: const Color(0xFF5D4037),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (animacao != null)
            Positioned(
              top: 50,
              right: 40,
              child: animacao,
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + estrela
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tarefa.nome,
                        style: GoogleFonts.medievalSharp(
                          fontSize: 16,
                          color: Colors.brown[900],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        tarefa.isPrioridadeSemana == true
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                      ),
                      tooltip: "Prioridade da Semana",
                      onPressed: onTogglePrioridade,
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (tarefa.xp > 0)
                      medievalChip("XP: ${tarefa.xp}", Icons.shield),
                    if (tarefa.estamina != 0)
                      medievalChip(
                        tarefa.estamina > 0
                            ? "Recupera Estamina: ${tarefa.estamina}"
                            : "Gasta Estamina: ${tarefa.estamina.abs()}",
                        tarefa.estamina > 0
                            ? Icons.add_circle
                            : Icons.remove_circle,
                        tarefa.estamina > 0
                            ? Colors.green[200]!
                            : Colors.red[200]!,
                      ),
                    if (tarefa.conhecimento > 0)
                      medievalChip("Conhecimento: ${tarefa.conhecimento}", Icons.menu_book),
                    if (tarefa.criatividade > 0)
                      medievalChip("Criatividade: ${tarefa.criatividade}", Icons.brush),
                    if (tarefa.conexao > 0)
                      medievalChip("Conexão: ${tarefa.conexao}", Icons.people),
                    if (tarefa.espiritualidade > 0)
                      medievalChip("Espiritualidade: ${tarefa.espiritualidade}", Icons.self_improvement),
                    if (tarefa.energiaVital > 0)
                      medievalChip("Energia Vital: ${tarefa.energiaVital}", Icons.favorite),

                    // ✅ Novos campos para debug:
                    medievalChip(
                      tarefa.concluida ? "✅ Concluída" : "⏳ Em andamento",
                      tarefa.concluida ? Icons.check_circle : Icons.hourglass_bottom,
                      tarefa.concluida ? Colors.green[100]! : Colors.grey[300]!,
                    ),
                    medievalChip(
                      "Coluna: ${tarefa.kanbanColumn?.name ?? 'indefinida'}",
                      Icons.view_column,
                      Colors.blueGrey[100]!,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ✅ TIMER WIDGET CORRETO
                if (tarefa.kanbanColumn == KanbanColumn.DOING && historicoTask != null)
                  TimerWidget(task: historicoTask),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: Colors.green[700],
                      tooltip: "Concluir Tarefa",
                        onPressed: () async {
                          if (onConcluir != null) {
                            await onConcluir!(tarefa);
                          }
                        }
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red[700],
                      tooltip: "Remover do Dia",
                      onPressed: onRemover,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget medievalChip(String text, IconData icon, [Color? color]) {
    return Chip(
      label: Text(
        text,
        style: GoogleFonts.medievalSharp(
          color: Colors.brown[900],
          fontSize: 13,
        ),
      ),
      backgroundColor: color ?? const Color(0xFFD7CCC8),
      avatar: Icon(
        icon,
        color: Colors.brown[800],
        size: 18,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF5D4037), width: 1),
      ),
    );
  }
}