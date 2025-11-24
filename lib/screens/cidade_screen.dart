import 'package:flutter/material.dart';
import '../nova_tarefa_screen.dart';
import '../tarefa_manager.dart';
import '../widgets/predio_card.dart';
import '../screens/perfil_jogadora_screen.dart';
import '../screens/criar_projeto_screen.dart';
import '../controllers/audio_controller.dart';
import '../models/projeto.dart';
import 'package:hive/hive.dart';
import '../screens/tela_prefeitura_screen.dart';
import '../screens/detalhe_predio_screen.dart';
import '../widgets/timer_widget.dart';
import '../models/predio.dart';
import '../widgets/predio_status_animation.dart';
import 'package:cidade_da_vida/animations/animations_manager.dart';
import 'package:cidade_da_vida/widgets/volume_sheet.dart';
import 'package:cidade_da_vida/screens/kanban_screen.dart';
import '../screens/board_screen.dart';

class CidadeScreen extends StatefulWidget {
  final TarefaManager tarefaManager;

  const CidadeScreen({
    super.key,
    required this.tarefaManager,
  });

  @override
  CidadeScreenState createState() => CidadeScreenState();
}

class CidadeScreenState extends State<CidadeScreen> {
  bool somAtivo = true;

  @override
  void initState() {
    super.initState();

    final predioBox = Hive.box<Predio>('predios');
    final musica = AnimationsManager.musicaPorStatusCidade(predioBox.values.toList());
    AudioController.tocarMusicaFundo(musica);

    _recalcularTodosStatusPredios().then((_) {
      _debugPrintStatusPredios();
    });
  }

  Future<void> _recalcularTodosStatusPredios() async {
    final predioBox = Hive.box<Predio>('predios');

    for (var predio in predioBox.values) {
      await widget.tarefaManager.atualizarStatusDoPredio(predio.categoria);
    }

    // Agora decide efeitos sonoros:
    final predios = predioBox.values.toList();

    // Atualiza música de fundo
    final musica = AnimationsManager.musicaPorStatusCidade(predios);
    if (somAtivo) {
      await AudioController.tocarMusicaFundo(musica);
    }

    // Verifica incêndio
    final temIncendio = predios.any(
          (p) => p.status == PredioStatus.pegandoFogo,
    );

    if (somAtivo) {
      if (temIncendio) {
        await AudioController.tocarEfeito("incendio.mp3", loop: true);
      } else {
        if (AudioController.efeitoAtual == "incendio.mp3") {
          await AudioController.tocarEfeito("fogo_apagando.mp3");
        }
        await AudioController.pararEfeito();
      }
    } else {
      await AudioController.pararEfeito();
    }

    setState(() {});
  }
  void _debugPrintStatusPredios() {
    final predioBox = Hive.box<Predio>('predios');
    for (final predio in predioBox.values) {
      print("🔥 Predio: ${predio.nome} | Status salvo: ${predio.status}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Box<Projeto> projetoBox = Hive.box<Projeto>('projetos');
    final predioBox = Hive.box<Predio>('predios');

    return ValueListenableBuilder(
      valueListenable: widget.tarefaManager.tarefasNotifier,
      builder: (context, tarefas, _) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/cenario_cidade.png',
                  fit: BoxFit.cover,
                ),
              ),
              for (final predio in predioBox.values) ...[
                // Imagem do prédio
                Positioned(
                  left: predio.x1.toDouble(),
                  top: predio.y1.toDouble(),
                   child: SizedBox(
                   width: (predio.x2 - predio.x1).toDouble(),
                   height: (predio.y2 - predio.y1).toDouble(),
                   child: PredioCard(
                   categoria: predio.categoria,
                   tarefaManager: widget.tarefaManager,
                   tarefasCount: tarefas
                   .where((t) => t.categoria == predio.categoria && !t.concluida)
                   .length,
                  projetosCount: projetoBox.values
                  .where((p) => p.categoria == predio.categoria && p.arquivado != true)
                  .length,

                    onTap: () {
                      if (predio.categoria == 'Prefeitura') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const TelaPrefeituraScreen()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalhePredioScreen(
                              nome: predio.nome,
                              tarefaManager: widget.tarefaManager,
                              todosProjetos: projetoBox.values
                                  .where((p) =>
                              p.categoria == predio.categoria &&
                                  p.arquivado != true)
                                  .toList(),
                            ),
                          ),
                        );
                      }
                    },
                   ),
                 ),
                ),
                // Animação do prédio (se existir)
               /* Positioned(
                  left: predio.x1.toDouble(),
                  top: predio.y1.toDouble(),
                  child: PredioStatusAnimation(
                    status: predio.status,
                    width: (predio.x2 - predio.x1).toDouble(),
                    height: (predio.y2 - predio.y1).toDouble(),
                  ),
                ),*/
              ],
              Positioned(
                top: 30,
                right: 30,
                child: IconButton(
                  icon: const Icon(Icons.person,
                      size: 40, color: Colors.white),
                  tooltip: 'Minha Jogadora',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const PerfilJogadoraScreen(),
                      ),
                    );
                  },
                ),
              ),

              // TIMER
              Positioned(
                bottom: 450,
                right: 100,
                child: SizedBox(
                  width: 160,
                 // child: TimerWidget(),
                ),
              ),

              // BOTÃO DO SOM
              Positioned(
                top: 30,
                left: 30,
               child:  IconButton(
                  icon: Icon(
                    somAtivo ? Icons.volume_up : Icons.volume_off,
                    size: 36,
                    color: Colors.white,
                  ),
                  tooltip: somAtivo ? 'Configurar som' : 'Ligar som',
                  onPressed: () {
                    if (!somAtivo) {
                      setState(() {
                        somAtivo = true;
                        final musica = AnimationsManager.musicaPorStatusCidade(predioBox.values.toList());
                        AudioController.tocarMusicaFundo(musica);
                        _recalcularTodosStatusPredios();
                      });
                      return;
                    }

                    showModalBottomSheet(
                      context: context,
                      builder: (context) => VolumeSheet(
                        onClose: () => setState(() {}),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // FAB do Tabuleiro
              FloatingActionButton(
                heroTag: 'fab_board',
                tooltip: 'Tabuleiro de Recompensas',
                child: const Icon(Icons.grid_view),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BoardScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              // FAB do Kanban (o que você já tinha)
              FloatingActionButton(
                heroTag: 'fab_kanban',
                tooltip: 'Abrir Kanban',
                child: const Icon(Icons.view_kanban),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KanbanScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}