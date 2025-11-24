// lib/utils/recursos_utils.dart

import 'package:hive/hive.dart';
import '../models/recurso.dart';

/// Aloca recurso a um projeto específico e atualiza a quantidade disponível
Future<void> alocarRecursoParaProjeto(Recurso recurso, String projetoId, double quantidade) async {
  if (!recurso.projetosVinculados.contains(projetoId)) {
    recurso.projetosVinculados.add(projetoId);
  }

  if (!recurso.compartilhavel) {
    recurso.quantidadeDisponivel = (recurso.quantidadeDisponivel ?? 0) - quantidade;
    if (recurso.quantidadeDisponivel < 0) recurso.quantidadeDisponivel = 0;
  }

  final box = await Hive.openBox<Recurso>('recursos');
  await box.put(recurso.id, recurso);
}

/// Aloca recurso diretamente a uma área (prédio)
Future<void> alocarRecursoParaArea(Recurso recurso, String nomeArea) async {
  if (!recurso.projetosVinculados.contains(nomeArea)) {
    recurso.projetosVinculados.add(nomeArea);
    final box = await Hive.openBox<Recurso>('recursos');
    await box.put(recurso.id, recurso);
  }
}

/// Retorna recursos visíveis na área, incluindo os compartilháveis e filtrando danificados se necessário
List<Recurso> getRecursosVisiveisParaArea({
  required String nomeArea,
  required List<Recurso> todosRecursos,
  bool incluirDanificados = false,
}) {
  return todosRecursos.where((r) {
    //if (nomeArea == 'Prefeitura') return true;

    final pertence = r.projetosVinculados.contains(nomeArea);
    final naoDanificado = incluirDanificados || r.status != RecursoStatus.danificado;

    return pertence && naoDanificado;
  }).toList();
}

/// Retorna recursos compartilháveis que não pertencem à área atual
List<Recurso> getRecursosCompartilhaveisDisponiveisEmOutrasAreas({
  required String nomeArea,
  required List<Recurso> todosRecursos,
}) {
  return todosRecursos.where((r) {
    return r.compartilhavel &&
        !r.projetosVinculados.contains(nomeArea) &&
        r.status != RecursoStatus.danificado;
  }).toList();
}