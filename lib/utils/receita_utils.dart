import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/receita.dart';
import '../models/insumo.dart';

enum ReceitaStatus {
  ok,
  faltando,
  paraVencer,
  vencido,
}

ReceitaStatus verificarStatusReceita(Receita receita, Box<Insumo> insumoBox) {
  bool faltando = false;
  bool vencido = false;
  bool paraVencer = false;

  for (final ingrediente in receita.ingredientes) {
    final insumo = insumoBox.get(ingrediente.idInsumo);
    if (insumo == null) {
      faltando = true;
      continue;
    }

    if (insumo.quantidadeDisponivel < ingrediente.quantidade) {
      faltando = true;
    }

    if (insumo.validade != null) {
      final diasParaVencer =
          insumo.validade!.difference(DateTime.now()).inDays;

      if (diasParaVencer < 0) {
        vencido = true;
      } else if (diasParaVencer <= 3) {
        paraVencer = true;
      }
    }
  }

  if (vencido) return ReceitaStatus.vencido;
  if (faltando) return ReceitaStatus.faltando;
  if (paraVencer) return ReceitaStatus.paraVencer;
  return ReceitaStatus.ok;
}

Color corDeFundoParaStatus(ReceitaStatus status) {
  switch (status) {
    case ReceitaStatus.ok:
      return Colors.green.shade100;
    case ReceitaStatus.faltando:
      return Colors.yellow.shade100;
    case ReceitaStatus.paraVencer:
      return Colors.orange.shade100;
    case ReceitaStatus.vencido:
      return Colors.red.shade100;
  }
}

IconData iconeParaStatus(ReceitaStatus status) {
  switch (status) {
    case ReceitaStatus.ok:
      return Icons.check_circle;
    case ReceitaStatus.faltando:
      return Icons.warning;
    case ReceitaStatus.paraVencer:
      return Icons.schedule;
    case ReceitaStatus.vencido:
      return Icons.cancel;
  }
}




extension ReceitaCustos on Receita {
  void calcularCustos(Box<Insumo> insumoBox) {
    double total = 0.0;

    for (final ing in ingredientes) {
      // Busca insumo atualizado no Hive
      final insumo = insumoBox.get(ing.idInsumo);

      double valorUnitario = ing.valorUnitario ?? 0.0;

      if (insumo != null) {
        valorUnitario = insumo.valorUnitario ?? valorUnitario;
      }

      ing.valorUnitario = valorUnitario;

      total += ing.quantidade * valorUnitario;
    }

    custoTotal = total;

    if (quantidadeProduzida != null && quantidadeProduzida! > 0) {
      custoPorcao = total / quantidadeProduzida!;
    } else {
      custoPorcao = null;
    }
  }
}
//PARA RECALCULAR O CUSTO DAS RECEITAS AO ABRIR O APP
Future<void> recalcularCustosDeTodasAsReceitas(
    Box<Receita> receitaBox,
    Box<Insumo> insumoBox,
    ) async {
  for (final receita in receitaBox.values) {
    receita.calcularCustos(insumoBox);
    await receita.save();
  }
}