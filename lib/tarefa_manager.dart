import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'models/tarefa.dart';
import '../animations/animations_manager.dart';
import 'models/predio.dart';
import 'screens/kanban_screen.dart';

class TarefaManager {
  final Box<Tarefa> _box;

  final ValueNotifier<List<Tarefa>> _tarefasNotifier = ValueNotifier([]);

  ValueNotifier<List<Tarefa>> get tarefasNotifier => _tarefasNotifier;

  TarefaManager(this._box) {
    _tarefasNotifier.value = _box.values.toList();
  }

  Future<void> adicionar(Tarefa tarefa) async {
    await _box.add(tarefa);
    _tarefasNotifier.value = _box.values.toList();

    await atualizarStatusDoPredio(tarefa.categoria);
    print('TAREFA ADICIONADA: ${tarefa.nome} (${tarefa.categoria})');
  }

  List<Tarefa> obterPorCategoria(String categoria) {
    return _box.values
        .where((tarefa) => tarefa.categoria == categoria)
        .toList();
  }
//CALCULA TODAS AS TAREFAS POR PREDIO, INCLUSIVE AS CONCLUIDAS
  List<Tarefa> tarefasPorPredio(String predioCategoria) {
    final predioBox = Hive.box<Predio>('predios');
    final predio = predioBox.values.firstWhere(
          (p) => p.categoria == predioCategoria,
      orElse: () => Predio(id: '', nome: '', categoria: ''),
    );

    if (predio.categoria.isEmpty) {
      print('⚠️ Predio não encontrado para categoria $predioCategoria');
      return [];
    }

    return _box.values
        .where((t) => t.categoria == predio.categoria)
        .toList();
  }
//CONTA APENAS AS TAREFAS NAO CONCLUIDAS POR PREDIO
  List<Tarefa> tarefasAtivasPorPredio(String predioCategoria) {
    return _box.values
        .where((t) => t.categoria == predioCategoria && !t.concluida)
        .toList();
  }

  int contarTarefasUrgentes(String predioCategoria) {
    return tarefasAtivasPorPredio(predioCategoria)
        .where((t) => obterStatusTarefa(t) == "Urgente")
        .length;
  }

  int contarTarefasAtrasadas(String predioCategoria) {
    return tarefasAtivasPorPredio(predioCategoria)
        .where((t) => obterStatusTarefa(t) == "Atrasada")
        .length;
  }

  int contarTarefasAbandonadas(String predioCategoria) {
    return tarefasAtivasPorPredio(predioCategoria)
        .where((t) => obterStatusTarefa(t) == "Abandonada")
        .length;
  }

  int contarTarefasTotal(String predioCategoria) {
    return tarefasAtivasPorPredio(predioCategoria).length;
  }

  String obterStatusTarefa(Tarefa tarefa) {
    final agora = DateTime.now();

    tarefa.dataCriacao ??= DateTime.now();

    if (tarefa.concluida) {
      return "Concluída";
    }

    if (tarefa.dataFinal != null) {
      final fimDia = DateTime(agora.year, agora.month, agora.day, 23, 59, 59);
      final fimDiaAmanha = fimDia.add(const Duration(days: 2));

      if (tarefa.dataFinal!.isBefore(agora)) {
        return "Atrasada";
      } else if (tarefa.dataFinal!.isBefore(fimDiaAmanha)) {
        return "Urgente";
      }
    }

    final diasDesdeCriacao =
        agora.difference(tarefa.dataCriacao!).inDays;

    if (tarefa.dataFinal == null && diasDesdeCriacao >= 5) {
      return "Abandonada";
    }

    if (tarefa.status.toLowerCase() == 'urgente') {
      return "Urgente";
    }

    return "Normal";
  }

  PredioStatus calcularStatusDoPredio(
      String predioCategoria, {
        PredioStatus? statusManual,
        DateTime? statusManualExpira,
      }) {
    if (statusManual != null) {
      if (statusManualExpira == null) {
        return statusManual;
      } else if (DateTime.now().isBefore(statusManualExpira)) {
        return statusManual;
      }
    }

    final urgentes = contarTarefasUrgentes(predioCategoria);
    final atrasadas = contarTarefasAtrasadas(predioCategoria);
    final abandonadas = contarTarefasAbandonadas(predioCategoria);
    final total = contarTarefasTotal(predioCategoria);

    print("🔎 CALCULANDO STATUS DO PRÉDIO → $predioCategoria");
    print("   - urgentes    = $urgentes");
    print("   - atrasadas   = $atrasadas");
    print("   - abandonadas = $abandonadas");
    print("   - total       = $total");

    if (total == 0) {
      return PredioStatus.abandonado;
    } else if (atrasadas > 0) {
      return PredioStatus.pegandoFogo;
    } else if (urgentes > 0) {
      return PredioStatus.pegandoFogo;
    } else if (total > 10) {
      return PredioStatus.fumaceando;
    } else if (abandonadas > 0) {
      return PredioStatus.abandonado;
    } else {
      return PredioStatus.ativo;
    }
  }

  Future<void> atualizarStatusDoPredio(String predioCategoria) async {
    final predioBox = Hive.box<Predio>('predios');
    final predio = predioBox.values.firstWhere(
          (p) => p.categoria == predioCategoria,
      orElse: () => Predio(id: '', nome: '', categoria: ''),
    );

    if (predio.categoria.isEmpty) {
      print("⚠️ Predio não encontrado para categoria $predioCategoria");
      return;
    }

    final statusCalculado = calcularStatusDoPredio(predio.categoria);

    if (predio.status != statusCalculado) {
      predio.status = statusCalculado;
      await predio.save();
      print("✅ Status atualizado do prédio ${predio.nome} → $statusCalculado");
    } else {
      print("ℹ️ Status do prédio ${predio.nome} permanece em $statusCalculado");
    }
  }

  Future<void> concluirTarefa(Tarefa tarefa, BuildContext context) async {
    final index = _box.values.toList().indexOf(tarefa);
    if (index != -1) {
      final chave = _box.keyAt(index);

      final novaTarefa = Tarefa(
        id: tarefa.id,
        nome: tarefa.nome,
        categoria: tarefa.categoria,
        status: tarefa.status,
        xp: tarefa.xp,
        conhecimento: tarefa.conhecimento,
        criatividade: tarefa.criatividade,
        estamina: tarefa.estamina,
        conexao: tarefa.conexao,
        espiritualidade: tarefa.espiritualidade,
        energiaVital: tarefa.energiaVital,
        dataFinal: tarefa.dataFinal,
        concluida: true,
        dataCriacao: tarefa.dataCriacao,
        projetoId: tarefa.projetoId,
        kanbanColumn: KanbanColumn.DONE,
        tempoEstimadoMinutos: tarefa.tempoEstimadoMinutos,
        tempoGastoMinutos: tarefa.tempoGastoMinutos,
      );

      await _box.put(chave, novaTarefa);
      _tarefasNotifier.value = _box.values.toList();
      await atualizarStatusDoPredio(tarefa.categoria);
    }
  }
}