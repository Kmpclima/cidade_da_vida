import '../models/receita.dart';

class CardapioManager {
  static final CardapioManager _instance = CardapioManager._internal();

  factory CardapioManager() {
    return _instance;
  }

  CardapioManager._internal();

  final List<Receita> receitasSelecionadas = [];

  void adicionarReceita(Receita receita) {
    if (!receitasSelecionadas.any((r) => r.id == receita.id)) {
      receitasSelecionadas.add(receita);
    }
  }

  void removerReceita(Receita receita) {
    receitasSelecionadas.removeWhere((r) => r.id == receita.id);
  }

  void limpar() {
    receitasSelecionadas.clear();
  }
}