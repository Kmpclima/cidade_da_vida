import 'package:flutter/material.dart';
import '../tarefa_manager.dart';
import '../models/tarefa.dart';
import '../models/projeto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoricoScreen extends StatelessWidget {
  final String nome;
  final TarefaManager tarefaManager;

  const HistoricoScreen({
    super.key,
    required this.nome,
    required this.tarefaManager,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de $nome'),
      ),
      body: ValueListenableBuilder(
        valueListenable: tarefaManager.tarefasNotifier,
        builder: (context, List<Tarefa> tarefas, _) {
          final tarefasAvulsas = tarefas
              .where((t) =>
          t.categoria == nome &&
              t.projetoId == null &&
              t.concluida)
              .toList();

          final tarefasEmProjetosAtivos = tarefas
              .where((t) =>
          t.categoria == nome &&
              t.projetoId != null &&
              t.concluida)
              .toList();

          return FutureBuilder(
            future: Hive.openBox<Projeto>('projetos'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final box = snapshot.data!;
              final projetosArquivados = box.values
                  .where((p) => p.categoria == nome && p.arquivado == true)
                  .toList();

              return ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  const Text('Tarefas Avulsas Concluídas:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...tarefasAvulsas.map((t) => ListTile(
                    title: Text(
                      t.nome,
                      style: const TextStyle(decoration: TextDecoration.lineThrough),
                    ),
                    subtitle: Text('XP: ${t.xp}'),
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                  )),
                  const Divider(),

                  const Text('Tarefas de Projetos Concluídas:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...tarefasEmProjetosAtivos.map((t) => ListTile(
                    title: Text(
                      t.nome,
                      style: const TextStyle(decoration: TextDecoration.lineThrough),
                    ),
                    subtitle: Text('XP: ${t.xp}'),
                    leading: const Icon(Icons.assignment_turned_in, color: Colors.blue),
                  )),
                  const Divider(),

                  const Text('Projetos Arquivados:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...projetosArquivados.map((p) => Card(
                    color: Color(int.parse(p.corHex.replaceAll('#', '0xff'))),
                    child: ListTile(
                      title: Text(p.nome, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        p.descricao,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      leading: const Icon(Icons.folder_off, color: Colors.white),
                    ),
                  )),
                ],
              );
            },
          );
        },
      ),
    );
  }
}