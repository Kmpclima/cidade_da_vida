import 'package:hive/hive.dart';
import '../models/insumo.dart';
import '../models/receita.dart';
import '../models/predio.dart';
import '../predios_iniciais.dart';
import 'package:collection/collection.dart';
import 'package:cidade_da_vida/models/tarefa.dart';
import 'package:uuid/uuid.dart';

Future<void> migrarChavesInsumosParaUuid(Box<Insumo> box) async {
  try {
    print('⚙️ Iniciando migração...');
    final keys = box.keys.toList();

    for (var key in keys) {
      if (key is int) {
        final insumo = box.get(key);
        if (insumo != null) {
          if (!box.containsKey(insumo.id)) {
            await box.put(insumo.id, insumo);
            print('[MIGRAÇÃO] Migrado: ${insumo.nome}');
          } else {
            print('[MIGRAÇÃO] Já existia UUID: ${insumo.nome}');
          }
          await box.delete(key);
        }
      }
    }
    print('✅ Migração concluída.');
  } catch (e, s) {
    print('❌ Erro durante migração: $e');
    print(s);
  }
}

Future<void> migrarTarefasAntigas() async {
  var box = Hive.box<Tarefa>('tarefas');
  final uuid = Uuid();

  for (var tarefa in box.values) {
    // ✅ Gera id somente se ainda não existir
    if (tarefa.id == null || tarefa.id!.isEmpty) {
      tarefa.id = uuid.v4();
    }

    // ✅ Inicializa campos novos se estiverem nulos
    tarefa.isPrioridadeSemana = tarefa.isPrioridadeSemana ?? false;
    tarefa.dataConclusao = tarefa.dataConclusao ?? null;
    tarefa.tempoEstimadoMinutos = tarefa.tempoEstimadoMinutos ?? null;
    tarefa.tempoGastoMinutos = tarefa.tempoGastoMinutos ?? null;
    tarefa.idHistoricoTask = tarefa.idHistoricoTask ?? null;

    await tarefa.save();
  }

  print("🚀 Migração concluída com sucesso!");
}
Future<void> salvarPrediosIniciais(Box<Predio> predioBox) async {
  for (final predio in prediosIniciais) {
    final existe = predioBox.values.any((p) => p.id == predio.id);
    if (!existe) {
      await predioBox.add(predio);
      print('✅ Prédio "${predio.nome}" salvo.');
    } else {
      print('ℹ️ Prédio "${predio.nome}" já existe.');
    }
  }
}
Future<void> corrigirTarefasKanban() async {
  final boxTarefas = Hive.box<Tarefa>('tarefas');
  int corrigidas = 0;

  for (var tarefa in boxTarefas.values) {
    final colAtual = tarefa.kanbanColumn;
    final colCorreta = _definirKanbanColumnCorreta(tarefa);

    if (colAtual != colCorreta) {
      print('Corrigindo "${tarefa.nome}" de $colAtual para $colCorreta');
      tarefa.kanbanColumn = colCorreta;
      await tarefa.save();
      corrigidas++;
    }
  }

  print('✅ Correção de Kanban concluída. $corrigidas tarefa(s) atualizada(s).');
}

// Função auxiliar para decidir a coluna correta com base no estado atual
KanbanColumn _definirKanbanColumnCorreta(Tarefa tarefa) {
  if (tarefa.concluida == true) {
    return KanbanColumn.DONE;
  } else if (tarefa.kanbanColumn == KanbanColumn.DOING) {
    return KanbanColumn.DOING; // mantém se estiver fazendo
  } else if (tarefa.kanbanColumn == KanbanColumn.TODAY) {
    return KanbanColumn.TODAY; // mantém se estiver no dia
  } else {
    return KanbanColumn.TO_DO;
  }
}

Future<void> popularValorUnitarioNosIngredientes() async {
  final receitaBox = Hive.box<Receita>('receitas');
  final insumoBox = Hive.box<Insumo>('insumos');

  for (var receita in receitaBox.values) {
    bool precisaSalvar = false;

    for (var ing in receita.ingredientes) {
      if (ing.valorUnitario == null) {
        final insumo = insumoBox.values
            .firstWhereOrNull((i) => i.id == ing.idInsumo);

        ing.valorUnitario = insumo?.valorUnitario ?? 0.0;
        precisaSalvar = true;
      }
    }

    if (precisaSalvar) {
      await receita.save();
      print("✅ Atualizou valores unitários da receita: ${receita.nome}");
    }
  }
}