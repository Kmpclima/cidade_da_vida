import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../models/projeto.dart';
import '../models/tarefa.dart';
import '../models/jogadora_status.dart';
import '../tarefa_manager.dart';
import '../controllers/audio_controller.dart';
import 'editar_projeto_screen.dart';
import '../models/recurso.dart';
import '../animations/animations_manager.dart';

class DetalheProjetoScreen extends StatefulWidget {
  final Projeto projeto;
  final List<Tarefa> tarefas;
  final TarefaManager tarefaManager;
  final String nomeDoPredio;

  const DetalheProjetoScreen({
    super.key,
    required this.projeto,
    required this.tarefas,
    required this.tarefaManager,
    required this.nomeDoPredio,
  });

  @override
  State<DetalheProjetoScreen> createState() => _DetalheProjetoScreenState();
}

class _DetalheProjetoScreenState extends State<DetalheProjetoScreen> {
  late Projeto projetoAtual;

  @override
  void initState() {
    super.initState();
    projetoAtual = widget.projeto;
    AudioController.tocarEfeito('flipping_book.mp3');
    Hive.openBox<Recurso>('recursos');
  }

  Future<void> _showTarefaConcluidaOverlay() async {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: AnimationsManager.tarefaConcluida(
            width: 200,
            height: 200,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    await Future.delayed(const Duration(seconds: 2));
    overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    final tarefasDoProjeto = widget.tarefas
        .where((t) => t.projetoId == projetoAtual.id && !t.concluida)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(projetoAtual.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Projeto',
            onPressed: () async {
              final boxRecursos = await Hive.openBox<Recurso>('recursos');
              final recursosFiltradosPorCategoria = boxRecursos.values.where((r) {
                final pertenceAoPredio = r.projetosVinculados.contains(projetoAtual.categoria);
                final estaDisponivel = r.status == RecursoStatus.disponivel;
                final estaNoPredio = r.estaNaPrefeitura == false || (r.compartilhavel == true && estaDisponivel);
                return pertenceAoPredio && estaNoPredio;
              }).toList();

              final projetoEditado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditarProjetoScreen(
                    projeto: projetoAtual,
                    nomeDoPredio: widget.nomeDoPredio,
                    onAtualizar: (novo) {
                      setState(() {
                        projetoAtual = novo;
                      });
                    },
                    recursosDoPredio: recursosFiltradosPorCategoria,
                  ),
                ),
              );

              if (projetoEditado != null && projetoEditado is Projeto) {
                final box = await Hive.openBox<Projeto>('projetos');
                await box.put(projetoEditado.id, projetoEditado);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Projeto atualizado!')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.archive),
            tooltip: 'Arquivar Projeto',
            onPressed: () async {
              final confirmar = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Arquivar projeto?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Arquivar'),
                    ),
                  ],
                ),
              );
              if (confirmar == true) {
                final box = await Hive.openBox<Projeto>('projetos');
                final projetoAtualizado = Projeto(
                  id: projetoAtual.id,
                  nome: projetoAtual.nome,
                  categoria: projetoAtual.categoria,
                  descricao: projetoAtual.descricao,
                  corHex: projetoAtual.corHex,
                  orcamento: projetoAtual.orcamento ?? 0,
                  prazoFinal: projetoAtual.prazoFinal,
                  recursosAlocados: projetoAtual.recursosAlocados ?? [],
                  contatosUteis: projetoAtual.contatosUteis,
                  horasGastas: projetoAtual.horasGastas,
                  licoesAprendidas: projetoAtual.licoesAprendidas,
                  conquistas: projetoAtual.conquistas,
                  arquivado: true,
                );

                await box.put(projetoAtual.id, projetoAtualizado);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Projeto arquivado!')),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (projetoAtual.recursosAlocados.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recursos Alocados',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...projetoAtual.recursosAlocados.map((r) {
                    final recursoOriginal =
                    Hive.box<Recurso>('recursos').get(r.recursoId);
                    final nome = recursoOriginal?.nome ?? 'Recurso desconhecido';
                    return Text('$nome - ${r.quantidade} unidade(s)');
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            if (tarefasDoProjeto.isEmpty)
              const Center(
                child: Text('Nenhuma tarefa pendente neste projeto.'),
              )
            else
              ...tarefasDoProjeto.map(
                    (tarefa) => ListTile(
                  title: Text(tarefa.nome),
                  subtitle: Text('XP: ${tarefa.xp}'),
                  trailing: const Icon(Icons.check_circle_outline),
                  onTap: () async {
                    final jogadora = Provider.of<JogadoraStatus>(context, listen: false);
                    final foiConcluidaAgora = !tarefa.concluida;
                    final todasTarefas = widget.tarefaManager.tarefasNotifier.value;

                    await widget.tarefaManager.concluirTarefa(tarefa, context);

                    if (foiConcluidaAgora) {
                      jogadora.aplicarTarefa(tarefa, todasTarefas);

                      // 🔊 Toca som
                      AudioController.tocarEfeito('tarefa_feita.mp3');

                      // 🎇 Mostra animação full-screen
                      await _showTarefaConcluidaOverlay();
                    }

                    setState(() {});
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}