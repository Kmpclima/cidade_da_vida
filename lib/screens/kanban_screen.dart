import 'package:cidade_da_vida/screens/novaTarefaRecorrenteScreen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/tarefa.dart';
import '../widgets/task_card_kanban.dart';
import '../nova_tarefa_screen.dart';
import '../screens/criar_projeto_screen.dart';
import '../models/projeto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../tarefa_manager.dart';
import 'package:cidade_da_vida/animations/animations_manager.dart';
import 'package:cidade_da_vida/controllers/audio_controller.dart';
import 'package:cidade_da_vida/models/kanban_historico.dart';
import 'package:cidade_da_vida/models/kanban_historico_task.dart';
import 'package:cidade_da_vida/models/tarefaRecorrente.dart';
import 'package:cidade_da_vida/models/insumo.dart';
import 'package:cidade_da_vida/utils/tarefas_recorrentes.dart';
import 'package:uuid/uuid.dart';
import 'package:cidade_da_vida/services/board_queue_service.dart';

// ✅ ✅ ✅  AQUI ESTÁ A FUNÇÃO QUE FALTAVA ✅ ✅ ✅
bool ehNovoDia(Box configBox) {
  final dataUltimoAcessoStr = configBox.get('data_ultimo_acesso');
  final dataUltimoAcesso = dataUltimoAcessoStr != null
      ? DateTime.parse(dataUltimoAcessoStr)
      : null;

  final hoje = DateTime.now();

  if (dataUltimoAcesso == null ||
      dataUltimoAcesso.year != hoje.year ||
      dataUltimoAcesso.month != hoje.month ||
      dataUltimoAcesso.day != hoje.day) {
    configBox.put('data_ultimo_acesso', hoje.toIso8601String());
    configBox.put('virada_realizada_hoje', false);
    return true;
  }
  return false;
}

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();


  /// Método estático para rodar a virada do dia
  static Future<void> realizarViradaDoDia(BuildContext context) async {
    await verificarTarefasRecorrentesEAdicionar();
    final box = Hive.box<Tarefa>('tarefas');

    final tarefasToday = box.values
        .where((t) =>
    t.kanbanColumn == KanbanColumn.TODAY &&
        t.concluida == false)
        .toList();

    if (tarefasToday.isEmpty) {
      print("✅ Nenhuma tarefa no TODAY para virar.");
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("✨ Virada do Dia"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Estas tarefas não foram concluídas ontem:"),
            const SizedBox(height: 12),
            ...tarefasToday.map((t) => Text("• ${t.nome}")).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              for (final tarefa in tarefasToday) {
                tarefa.kanbanColumn = KanbanColumn.DONE;
                tarefa.concluida = true;
                tarefa.dataConclusao = DateTime.now();
                await tarefa.save();
              }
              Navigator.pop(context);
            },
            child: const Text("Marcar como concluídas"),
          ),
          TextButton(
            onPressed: () async {
              for (final tarefa in tarefasToday) {
                tarefa.kanbanColumn = KanbanColumn.TO_DO;
                tarefa.concluida = false;
                tarefa.dataConclusao = null;
                await tarefa.save();
              }
              Navigator.pop(context);
            },
            child: const Text("Voltar para TO DO"),
          ),
        ],
      ),
    );
    // Limpa tarefas concluídas (DONE) da visualização do Kanban
    final tarefasDone = box.values
        .where((t) =>
    t.kanbanColumn == KanbanColumn.DONE &&
        t.concluida == true)
        .toList();

    for (final tarefa in tarefasDone) {
      tarefa.kanbanColumn = null;
      await tarefa.save();
    }

    print("✅ Coluna DONE limpa para o novo dia!");

    // Agora mostra o modal para nota e observações do dia
    await showDialog(
      context: context,
      builder: (context) {
        int notaSelecionada = 3;
        TextEditingController obsController = TextEditingController();

        return AlertDialog(
          title: Text("⭐ Como foi seu dia?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Dê uma nota de 1 a 5 estrelas:"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < notaSelecionada
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      notaSelecionada = index + 1;
                      (context as Element).markNeedsBuild();
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: obsController,
                decoration: const InputDecoration(
                  labelText: "Observações do dia",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              )
            ],
          ),
          actions: [
            TextButton(
              child: Text("Salvar"),
              onPressed: () async {
                final historicoBox =
                Hive.box<KanbanHistorico>('kanban_historico');

                final historico = KanbanHistorico(
                  data: DateTime.now(),
                  tarefas: [], // Podemos salvar a lista de tarefas do dia se quiser
                  notaDia: notaSelecionada,
                  observacoes: obsController.text,
                );

                await historicoBox.add(historico);

                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}

class _KanbanScreenState extends State<KanbanScreen> {

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _concluindo = false;

  Future<void> _concluirTarefa(Tarefa tarefa) async {
    if (_concluindo) return; // evita clique duplo
    _concluindo = true;
    try {
      final tarefaManager = Provider.of<TarefaManager>(context, listen: false); // ← pega a instância
      final agora = DateTime.now();                                             // ← mantém
      final box = Hive.box<KanbanHistoricoTask>('kanban_historico_tasks');

      KanbanHistoricoTask? h = (tarefa.idHistoricoTask != null)
          ? box.get(tarefa.idHistoricoTask)
          : null;
      h ??= box.values
          .cast<KanbanHistoricoTask>()
          .where((e) => e.idTarefa == tarefa.id)
          .fold<KanbanHistoricoTask?>(null, (acc, e) =>
      (acc == null || (e.tempoGastoMinutos ?? 0) > (acc.tempoGastoMinutos ?? 0)) ? e : acc);

      final base  = (h?.tempoGastoMinutos ?? tarefa.tempoGastoMinutos ?? 0);
      final extra = (h?.inicioExecucao != null)
          ? agora.difference(h!.inicioExecucao!).inMinutes
          : 0;
      final total = base + extra;

      if (h != null) {
        h
          ..tempoGastoMinutos = total
          ..dataConclusao     = agora
          ..inicioExecucao    = null;
        await h.save();
      }

      tarefa
        ..tempoGastoMinutos = total
        ..dataConclusao     = agora
        ..kanbanColumn      = KanbanColumn.DONE
        ..concluida         = true
        ..status            = "normal";
      await tarefa.save();

      // >>> AQUI: manda para o Tabuleiro
      final String categoria = tarefa.categoria ?? 'Geral';
      final int estaminaGasta = (() {
        try {
          final v = (tarefa.estamina ?? tarefa.estamina ?? total);
          return (v is int) ? v : (v as num).round();
        } catch (_) {
          return total;
        }
      })();
      final int valorAbsoluto = estaminaGasta.abs(); // converte p/ positivo
      if (valorAbsoluto > 0) {
        await BoardQueueService.addPending(categoria, valorAbsoluto);
      }
// <<< fim do envio

      await tarefaManager.concluirTarefa(tarefa, context); // ← usa a instância
      AudioController.tocarEfeito("tarefa_feita.mp3");
      await AnimationsManager.mostrarTarefaConcluida(context);
      if (mounted) setState(() {});
    } finally {
      _concluindo = false;
    }
  }

  int _calcularTrabalhadoHoje() {
    final historicoBox = Hive.box<KanbanHistoricoTask>('kanban_historico_tasks');
    final tarefasBox = Hive.box<Tarefa>('tarefas');
    final agora = DateTime.now();
    final inicioHoje = DateTime(agora.year, agora.month, agora.day);

    // só conta "tempo correndo" se a tarefa está em DOING agora
    final doingIds = tarefasBox.values
        .where((t) => t.kanbanColumn == KanbanColumn.DOING && t.concluida == false)
        .map((t) => t.id)
        .whereType<String>()
        .toSet();

    // dedupe por tarefa (pega o histórico com maior tempo)
    final Map<String, KanbanHistoricoTask> porTarefa = {};
    for (final h in historicoBox.values.cast<KanbanHistoricoTask>()) {
      final concluiuHoje = h.dataConclusao != null && _isSameDay(h.dataConclusao!, agora);
      final tarefaExiste = tarefasBox.values.any((t) => t.id == h.idTarefa);

      // só considera se: concluiu hoje OU a tarefa existe (para possível tempo correndo)
      if (!concluiuHoje && !tarefaExiste) continue;

      final atual = porTarefa[h.idTarefa];
      if (atual == null || (h.tempoGastoMinutos ?? 0) > (atual.tempoGastoMinutos ?? 0)) {
        porTarefa[h.idTarefa] = h;
      }
    }

    int total = 0;

    porTarefa.forEach((id, h) {
      int minutos = 0;

      // tempo persistido de tarefas concluídas HOJE
      if (h.dataConclusao != null && _isSameDay(h.dataConclusao!, agora)) {
        minutos += (h.tempoGastoMinutos ?? 0);
      }

      // tempo correndo: só se a tarefa está em DOING agora
      if (h.inicioExecucao != null && doingIds.contains(id)) {
        final inicioConsiderado =
        h.inicioExecucao!.isBefore(inicioHoje) ? inicioHoje : h.inicioExecucao!;
        minutos += agora.difference(inicioConsiderado).inMinutes;
      }

      // caps defensivos
      final estimado = h.tempoEstimadoMinutos ?? 0;
      if (estimado > 0 && minutos > estimado * 3) minutos = estimado * 3;
      if (minutos > 24 * 60) minutos = 24 * 60;

      total += minutos;
    });

    return total;
  }
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      final configBox = Hive.box('configuracoes');

      // Verifica se é novo dia
      final novoDia = ehNovoDia(configBox);

      if (novoDia) {
        print('✨ Novo dia detectado!');
        await KanbanScreen.realizarViradaDoDia(context);
        configBox.put('virada_realizada_hoje', true);
      } else {
        // Se não é novo dia, verifica se já rodou hoje
        final jaRodou = configBox.get('virada_realizada_hoje', defaultValue: false);

        if (!jaRodou) {
          print('🚀 Rodando virada do dia pois ainda não foi executada hoje.');
          await KanbanScreen.realizarViradaDoDia(context);
          configBox.put('virada_realizada_hoje', true);
        } else {
          print('✅ Virada já realizada hoje. Não precisa rodar de novo.');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tarefaManager = Provider.of<TarefaManager>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kanban das Tarefas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nova tarefa ou projeto',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.check),
                      title: const Text('Nova Tarefa'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NovaTarefaScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.check),
                      title: const Text('Nova Tarefa Recorrente'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NovaTarefaRecorrenteScreen(),
                          ),
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.folder_open),
                      title: const Text('Novo Projeto'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NovoProjetoScreen(
                              onSalvar: (novoProjeto) async {
                                final box = Hive.box<Projeto>('projetos');
                                await box.add(novoProjeto);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const KanbanScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Tarefa>('tarefas').listenable(),
        builder: (context, box, _) {
          final tarefasToDo = box.values
              .where((t) =>
          t.kanbanColumn == KanbanColumn.TO_DO &&
              t.status != "em espera" &&
              t.concluida == false)
              .toList()
            ..sort((a, b) {
              return (b.isPrioridadeSemana == true ? 1 : 0) -
                  (a.isPrioridadeSemana == true ? 1 : 0);
            });

          final tarefasDoing = box.values
              .where((t) =>
          t.kanbanColumn == KanbanColumn.DOING &&
              t.status != "em espera" &&
              t.concluida == false)
              .toList()
            ..sort((a, b) {
              return (b.isPrioridadeSemana == true ? 1 : 0) -
                  (a.isPrioridadeSemana == true ? 1 : 0);
            });

          final tarefasDone = box.values
              .where((t) =>
          t.kanbanColumn == KanbanColumn.DONE &&
              t.concluida == true)
              .toList();

          final tarefasEmEspera = box.values
              .where((t) =>
          t.status == "em espera" &&
              t.concluida == false)
              .toList();

          final tarefasToday = box.values
              .where((t) =>
          t.kanbanColumn == KanbanColumn.TODAY &&
              t.concluida == false)
              .toList()
            ..sort((a, b) {
              return (b.isPrioridadeSemana == true ? 1 : 0) -
                  (a.isPrioridadeSemana == true ? 1 : 0);
            });

          // Calcula estamina e tempo
          final estaminaTotal = 100;
          final estaminaPlanejada = tarefasToday.fold(
              0, (sum, tarefa) => sum + (tarefa.estamina ?? 0));
          final estaminaRestante = estaminaTotal + estaminaPlanejada;

          final tempoTotalMinutos = tarefasToday.fold(
            0,
                (sum, tarefa) => sum + (tarefa.tempoEstimadoMinutos ?? 0),
          );
          final tempoTotalHoras = tempoTotalMinutos / 60;

          if (tempoTotalHoras > 8) {
            Future.delayed(Duration.zero, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                  Text("Majestade, não cabe mais nada no seu dia!"),
                ),
              );
            });
          }

          final tempoTrabalhadoHojeMin = _calcularTrabalhadoHoje();
          final horas = tempoTrabalhadoHojeMin ~/ 60;
          final minutos = tempoTrabalhadoHojeMin % 60;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                kanbanColumn(
                  context,
                  "TODAY\n"
                      "Estamina restante: $estaminaRestante\n"
                      "Tempo planejado: ${tempoTotalHoras.toStringAsFixed(1)}h",
                  Colors.purple[100]!,
                  KanbanColumn.TODAY,
                  tarefasToday,
                  tarefaManager,
                  largura: 450,
                ),
                kanbanColumn(
                  context,
                  "TO DO",
                  Colors.blue[100]!,
                  KanbanColumn.TO_DO,
                  tarefasToDo,
                  tarefaManager,
                  largura: 450,
                ),
                kanbanColumn(
                  context,
                  "DOING",
                  Colors.yellow[100]!,
                  KanbanColumn.DOING,
                  tarefasDoing,
                  tarefaManager,
                ),
                kanbanColumn(
                  context,
                  "EM ESPERA",
                  Colors.grey[300]!,
                  null,
                  tarefasEmEspera,
                  tarefaManager,
                  largura: 350,
                ),
                kanbanColumn(
                  context,
                  "✅ DONE\n🕒 Trabalhado hoje: ${horas}h ${minutos}min",
                  Colors.green[100]!,
                  KanbanColumn.DONE,
                  tarefasDone,
                  tarefaManager,
                  onConcluir: _concluirTarefa,   // << AQUI
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget kanbanColumn(
      BuildContext context,
      String title,
      Color color,
      KanbanColumn? columnType,
      List<Tarefa> tarefasFiltradas,
      TarefaManager tarefaManager, {
        double largura = 300,
        Future<void> Function(Tarefa)? onConcluir, // 👈 adicionado aqui
      }) {
    return DragTarget<Tarefa>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) async {
        final tarefa = details.data;

        final historicoTask = KanbanHistoricoTask(
          idTarefa: tarefa.id ?? UniqueKey().toString(),
          nome: tarefa.nome,
          categoria: tarefa.categoria,
          projetoId: tarefa.projetoId,
          kanbanColumn: tarefa.kanbanColumn ?? KanbanColumn.TO_DO,
          tempoEstimadoMinutos: tarefa.tempoEstimadoMinutos,
          tempoGastoMinutos: tarefa.tempoGastoMinutos,
          dataConclusao: tarefa.dataConclusao,
          isPrioridadeSemana: tarefa.isPrioridadeSemana ?? false,
          status: tarefa.status ?? 'normal',
          xp: tarefa.xp,
          conhecimento: tarefa.conhecimento,
          criatividade: tarefa.criatividade,
          estamina: tarefa.estamina,
          conexao: tarefa.conexao,
          espiritualidade: tarefa.espiritualidade,
          energiaVital: tarefa.energiaVital,
        );

        if (columnType == null) {
          // EM ESPERA
          tarefa.status = "em espera";
          tarefa.kanbanColumn = null;
          tarefa.concluida = false;
          tarefa.dataConclusao = null;
          await tarefa.save();
        } else if (columnType == KanbanColumn.DOING) {
    tarefa.status = "normal";
    tarefa.kanbanColumn = KanbanColumn.DOING;

    // antes de mexer no histórico, garanta id da tarefa
    if (tarefa.id == null || tarefa.id!.isEmpty) {
      tarefa.id = const Uuid().v4();
      await tarefa.save();
    }

    final boxHistorico = Hive.box<KanbanHistoricoTask>('kanban_historico_tasks');

    KanbanHistoricoTask? h;
// 1) tenta pela key salva
          if (tarefa.idHistoricoTask != null) {
            h = boxHistorico.get(tarefa.idHistoricoTask);
          }
// 2) tenta por idTarefa
          h ??= boxHistorico.values
              .cast<KanbanHistoricoTask>()
              .where((e) => e.idTarefa == tarefa.id)
              .fold<KanbanHistoricoTask?>(null, (acc, e) =>
          (acc == null || (e.tempoGastoMinutos ?? 0) > (acc.tempoGastoMinutos ?? 0)) ? e : acc);

// 3) cria se não existir
          if (h == null) {
            h = KanbanHistoricoTask(
              idTarefa: tarefa.id!,
              nome: tarefa.nome,
              categoria: tarefa.categoria,
              projetoId: tarefa.projetoId,
              kanbanColumn: KanbanColumn.DOING,
              tempoEstimadoMinutos: tarefa.tempoEstimadoMinutos,
              tempoGastoMinutos: tarefa.tempoGastoMinutos ?? 0,
              isPrioridadeSemana: tarefa.isPrioridadeSemana ?? false,
              status: tarefa.status ?? 'normal',
              xp: tarefa.xp,
              conhecimento: tarefa.conhecimento,
              criatividade: tarefa.criatividade,
              estamina: tarefa.estamina,
              conexao: tarefa.conexao,
              espiritualidade: tarefa.espiritualidade,
              energiaVital: tarefa.energiaVital,
            );
            final key = await boxHistorico.add(h);
            tarefa.idHistoricoTask = key;
            await tarefa.save();
          }

// 4) inicia se ainda não estava rodando
          if (h.inicioExecucao == null) {
            h.inicioExecucao = DateTime.now();
            await h.save();
          }

          print(
              "✅ Histórico pronto p/ DOING | tarefa='${tarefa.nome}' (id=${tarefa.id}) "
                  "| histKey=${tarefa.idHistoricoTask} | inicio=${h.inicioExecucao}"
          );

    }else if (columnType == KanbanColumn.DONE) {
          // Encaminha para a lógica do botão
          await onConcluir?.call(tarefa); // se você estiver passando o callback para o KanbanColunas
          return;
        } else {
          // TO_DO, TODAY, etc.
          tarefa.status = "normal";
          tarefa.kanbanColumn = columnType;
          tarefa.concluida = false;
          tarefa.dataConclusao = null;
          await tarefa.save();
          print("📝 Tarefa salva com tempo: ${tarefa.tempoGastoMinutos} min");
        }

        setState(() {});
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: largura,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: candidateData.isNotEmpty
                ? Border.all(color: Colors.deepPurple, width: 3)
                : null,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: tarefasFiltradas.isEmpty
                    ? const Center(
                  child: Text("Ainda vazio..."),
                )
                    : ListView.builder(
                  itemCount: tarefasFiltradas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefasFiltradas[index];
                    final status = tarefaManager.obterStatusTarefa(tarefa);
                    return Draggable<Tarefa>(
                      data: tarefa,
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: largura - 20,
                          child: Opacity(
                            opacity: 0.8,
                            child: TaskCardKanban(
                              tarefa: tarefa,
                              status: status,
                                onConcluir: _concluirTarefa,   // << usa o mesmo método
                              onRemover: () {
                                tarefa.kanbanColumn =
                                    KanbanColumn.TO_DO;
                                tarefa.save();
                              },
                              onTogglePrioridade: () {
                                tarefa.isPrioridadeSemana =
                                !(tarefa.isPrioridadeSemana ??
                                    false);
                                tarefa.save();
                              },
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: TaskCardKanban(
                          tarefa: tarefa,
                          status: status,
                          onConcluir: _concluirTarefa,   // << usa o mesmo método
                          onRemover: () {
                            tarefa.kanbanColumn =
                                KanbanColumn.TO_DO;
                            tarefa.save();
                          },
                          onTogglePrioridade: () {
                            tarefa.isPrioridadeSemana =
                            !(tarefa.isPrioridadeSemana ??
                                false);
                            tarefa.save();
                          },
                        ),
                      ),
                      child: TaskCardKanban(
                        status: status,
                        tarefa: tarefa,
                          onConcluir: _concluirTarefa,   // << usa o mesmo método
                        onRemover: () {
                          tarefa.kanbanColumn =
                              KanbanColumn.TO_DO;
                          tarefa.save();
                        },
                        onTogglePrioridade: () {
                          tarefa.isPrioridadeSemana =
                          !(tarefa.isPrioridadeSemana ??
                              false);
                          tarefa.save();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
