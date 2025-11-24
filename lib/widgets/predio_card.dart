import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../tarefa_manager.dart';
import '../controllers/audio_controller.dart';
import '../models/predio.dart';
import '../animations/animations_manager.dart';

class PredioCard extends StatelessWidget {
  final String categoria;
  final TarefaManager tarefaManager;
  final int tarefasCount;
  final int projetosCount;
  final VoidCallback? onTap;

  const PredioCard({
    super.key,
    required this.categoria,
    required this.tarefaManager,
    required this.tarefasCount,
    required this.projetosCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Predio>('predios');

    final predio = box.values.firstWhere(
          (p) => p.categoria == categoria,
      orElse: () => Predio(
        id: '',
        nome: 'Desconhecido',
        categoria: categoria,
      ),
    );

    if (predio.categoria == '') {
      return Text('Prédio não encontrado: $categoria');
    }

    final animacaoWidget = AnimationsManager.animacaoPorStatus(
      predio.status,
      width: 150,        // agora a animação fica maior!
      height: 150,
    );

    return GestureDetector(
      onTap: () async {
        AudioController.tocarEfeito('porta_abrindo.mp3');
        await Future.delayed(const Duration(milliseconds: 600));

        final somPersonalizado = _somPorPredio(predio.nome);
        if (somPersonalizado != null) {
          AudioController.tocarEfeito(somPersonalizado);
        }

        if (onTap != null) {
          onTap!();
        }
      },
      child: Stack(
        clipBehavior: Clip.none, // permite transbordar para fora do Stack
        children: [
          if (animacaoWidget != null)
            Positioned(
              top: -100,    // sobe a animação
              right: -100,  // desloca pra direita
              child: animacaoWidget,
            ),
          Card(
            elevation: 5,
            color: Colors.teal[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    predio.nome,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    'Nível: ${predio.nivel}',
                    style: const TextStyle(fontSize: 8),
                  ),
                  const SizedBox(height: 2),
                  if (tarefasCount > 0 || projetosCount > 0)
                    Wrap(
                      spacing: 2,
                      runSpacing: -4,
                      children: [
                        if (tarefasCount > 0)
                          Chip(
                            label: Text(
                              '$tarefasCount tarefas',
                              style: const TextStyle(fontSize: 8),
                            ),
                            backgroundColor: Colors.orange[100],
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        if (projetosCount > 0)
                          Chip(
                            label: Text(
                              '$projetosCount projetos',
                              style: const TextStyle(fontSize: 8),
                            ),
                            backgroundColor: Colors.blue[100],
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _somPorPredio(String nome) {
    switch (nome.toLowerCase()) {
      case 'escola':
        return 'escola.mp3';
      case 'horta':
        return 'pasarinho_chamando.mp3';
      case 'cozinha':
        return 'cozinha.mp3';
      case 'espiritual':
        return 'spiritual.mp3';
      case 'moradia':
        return 'cuidados_casa.mp3';
      default:
        return null;
    }
  }
}