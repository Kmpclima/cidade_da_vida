import 'package:hive/hive.dart';
import 'entrada_financeira.dart';
import 'distribuicao_orcamentaria.dart';

part 'tesouraria.g.dart';

@HiveType(typeId: 83)
class Tesouraria extends HiveObject {
  @HiveField(0)
  double saldoAtual;

  @HiveField(1)
  List<EntradaFinanceira> entradas;

  @HiveField(2)
  List<DistribuicaoOrcamentaria> distribuicoes;

  Tesouraria({
    required this.saldoAtual,
    required this.entradas,
    required this.distribuicoes,
  });

  void adicionarEntrada(EntradaFinanceira entrada) {
    entradas.add(entrada);
    saldoAtual += entrada.valor;
    save();
  }

  bool distribuirVerificandoSaldo(DistribuicaoOrcamentaria dist) {
    if (dist.valor > saldoAtual) return false;
    distribuicoes.add(dist);
    saldoAtual -= dist.valor;
    save();
    return true;
  }
}