// lib/models/jogadora_status.dart
import 'package:flutter/material.dart';
import 'tarefa.dart';
import 'package:hive/hive.dart';
import 'jogadora_status_adapter.dart';

class JogadoraStatus extends ChangeNotifier {

  late JogadoraStatusHive _dados;
  final Box<JogadoraStatusHive> _box;

  JogadoraStatus(this._box) {
    _dados = _box.get('status')!;
  }

  // Getters públicos
  int get xp => _dados.xp;
  int get nivel => _dados.nivel;
  int get conhecimento => _dados.conhecimento;
  int get criatividade => _dados.criatividade;
  int get estamina => _dados.estamina;
  int get conexao => _dados.conexao;
  int get espiritualidade => _dados.espiritualidade;
  int get energiaVital => _dados.energiaVital;
  String get avatarAtual => _dados.avatarAtual;
  DateTime? get dataUltimoAcesso => _dados.dataUltimoAcesso;
  Map<String, int> get xpDiarioPorPredio => _dados.xpDiarioPorPredio;
  Map<String, int> get xpTotalPorPredio => _dados.xpTotalPorPredio;

  void aplicarTarefa(Tarefa tarefa,List<Tarefa> todasTarefas) {
    _dados.xp += tarefa.xp;
    _dados.conhecimento += tarefa.conhecimento;
    _dados.criatividade += tarefa.criatividade;
    _dados.estamina += tarefa.estamina;
    _dados.conexao += tarefa.conexao;
    _dados.espiritualidade += tarefa.espiritualidade;
    _dados.energiaVital += tarefa.energiaVital;

    _dados.xpDiarioPorPredio[tarefa.categoria] =
        (_dados.xpDiarioPorPredio[tarefa.categoria] ?? 0) + tarefa.xp;

    _dados.xpTotalPorPredio[tarefa.categoria] =
        (_dados.xpTotalPorPredio[tarefa.categoria] ?? 0) + tarefa.xp;

    int limite = 100 + (_dados.nivel * 50);
    while (_dados.xp >= limite) {
      _dados.xp -= limite;
      _dados.nivel++;
      limite = 100 + (_dados.nivel * 50);
    }

    _atualizarAvatar(todasTarefas);
    _salvar();
  }

  void _atualizarAvatar(List<Tarefa> todasTarefas) {
    // Verifica estresse por tarefas pendentes
    final categoriasComPendencias = <String>{};
    for (var t in todasTarefas) {
      if (!t.concluida) {
        categoriasComPendencias.add(t.categoria);
      }
    }

    if (categoriasComPendencias.length >= 4) {
      _dados.avatarAtual = 'avatar_estressada';
    } else if (_dados.estamina <= 20 || _dados.energiaVital <= 20) {
      _dados.avatarAtual = 'avatar_cansada';
    } else {
      // Avatar por prédio mais ativo
      final maior = _dados.xpDiarioPorPredio.entries.fold<MapEntry<String, int>?>(
        null,
            (anterior, atual) => anterior == null || atual.value > anterior.value ? atual : anterior,
      );

      if (maior != null) {
        final nome = maior.key;
        if (nome.contains('Cozinha')) {
          _dados.avatarAtual = 'avatar_cozinheira';
        } else if (nome.contains('Escola')) {
          _dados.avatarAtual = 'avatar_professora';
        } else if (nome.contains('Horta')) {
          _dados.avatarAtual = 'avatar_naturalista';
        } else if (nome.contains ('Espiritual')){
          _dados.avatarAtual = 'avatar_transcendente';
        } else if (nome.contains ('Finanças')) {
          _dados.avatarAtual = 'avatar_riqueza';
        } else if (nome.contains ('Workshop')){
          _dados.avatarAtual= 'avatar_designer';
        } else if (nome.contains ('Hospital')){
          _dados.avatarAtual = 'avatar_saudavel';          
        } else if (nome.contains('Família e amigos')){
          _dados.avatarAtual = 'avatar_conectada';
        } else if (nome.contains('Moradia')){
          _dados.avatarAtual = 'avatar_casa_arrumada';
        } else if (nome.contains ('Ateliê')){
          _dados.avatarAtual = 'avatar_artesa';
        } else if (nome.contains ('Lazer')){
          _dados.avatarAtual = 'avatar_descansada';
        }
        else {
          _dados.avatarAtual = 'avatar_padrao';
        }
      }
    }
  }

  void resetarEstaminaEDiario() {
    _dados.estamina = 100;
    _dados.xpDiarioPorPredio.clear();
    _dados.dataUltimoAcesso = DateTime.now();
    _salvar();
  }


  bool ehNovoDia() {
    final hoje = DateTime.now();
    if (_dados.dataUltimoAcesso == null ||
        _dados.dataUltimoAcesso!.day != hoje.day ||
        _dados.dataUltimoAcesso!.month != hoje.month ||
        _dados.dataUltimoAcesso!.year != hoje.year) {
      resetarEstaminaEDiario();
      return true;
    }
    return false;
  }

  void resetarTudo() {
    _dados = JogadoraStatusHive(
      xp: 0,
      nivel: 0,
      conhecimento: 0,
      criatividade: 0,
      estamina: 100,
      conexao: 0,
      espiritualidade: 0,
      energiaVital: 100,
      xpDiarioPorPredio: {},
      xpTotalPorPredio: {},
      avatarAtual: 'avatar_padrao',
      dataUltimoAcesso: DateTime.now(),
    );
    _salvar();
  }

  void _salvar() {
    _box.put('status', _dados);
    notifyListeners();
  }
}

