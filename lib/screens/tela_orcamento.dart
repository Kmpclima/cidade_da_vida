import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/predio.dart';
import '../models/demanda.dart';
import '../models/projeto.dart';
import '../models/tarefa.dart';
import '../utils/color_utils.dart';
import 'package:cidade_da_vida/models/recurso.dart';
import '../models/servico.dart';

class TelaOrcamentoScreen extends StatefulWidget {
  const TelaOrcamentoScreen({super.key});

  @override
  State<TelaOrcamentoScreen> createState() => _TelaOrcamentoScreenState();
}

class _TelaOrcamentoScreenState extends State<TelaOrcamentoScreen> {
  late Box<Predio> predioBox;
  final Map<String, TextEditingController> _controllers = {};

  double calcularSaldoTotal() {
    return predioBox.values.fold(
        0.0, (prev, p) => prev + (p.orcamentoTotal ?? 0));
  }
  @override
  void initState() {
    super.initState();
    predioBox = Hive.box<Predio>('predios');

    // Inicializa controllers para cada prédio
    for (var predio in predioBox.values) {
      _controllers[predio.id] = TextEditingController(
        text: predio.orcamentoMensal.toString(),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A3A1C),
      appBar: AppBar(
        title: const Text('Orçamento dos Prédios'),
        backgroundColor: Colors.brown[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemCount: predioBox.values.length,
              itemBuilder: (context, index) {
                final predio = predioBox.getAt(index)!;
                return _buildPredioRow(predio);
              },
            ),
          ),
          _buildSaldoTotal(),
          const SizedBox(height: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: _salvarAlteracoes,
        child: const Icon(Icons.save),
      ),
    );
  }
  Widget _buildSaldoTotal() {
    final saldoTotal = calcularSaldoTotal();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.amber.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.brown),
          const SizedBox(width: 8),
          Text(
            "Saldo total da Cidade da Vida: R\$ ${saldoTotal.toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPredioRow(Predio predio) {
    final tarefaBox = Hive.box<Tarefa>('tarefas');
    final projetoBox = Hive.box<Projeto>('projetos');
    final demandaBox = Hive.box<Demanda>('demandas');
    final recursoBox = Hive.box<Recurso>('recursos');
    final servicoBox = Hive.box<Servico>('servicos');

    final tarefasCount = tarefaBox.values
        .where((t) => t.categoria == predio.categoria && !t.concluida)
        .length;

    final projetosCount = projetoBox.values
        .where((p) => p.categoria == predio.categoria && p.arquivado != true)
        .length;

    // Total das demandas (todas, sem filtrar aprovadas)
    final totalDemandas = demandaBox.values.fold<double>(
      0.0,
          (prev, d) {
        final recurso = recursoBox.get(d.recursoId);
        if (recurso != null &&
            recurso.prediosVinculados.contains(predio.categoria)) {
          return prev +
              ((d.quantidadeSolicitada ?? 0) *
                  (d.valorUnitario ?? 0.0));
        }
        return prev;
      },
    );

    // Total serviços pendentes
    final totalServicosPendentes = servicoBox.values
        .where((s) =>
    s.predioId == predio.id &&
        s.status == 'pendente')
        .fold<double>(0.0, (prev, s) => prev + s.valor);

    final saldoReservado = totalServicosPendentes;

    // Calcular sugestão de aporte
    final saldoDisponivel = predio.orcamentoTotal;
    final aporteNecessario = (saldoDisponivel < 0 ? saldoDisponivel.abs() : 0)
        + saldoReservado;

    // Obtemos a cor do prédio
    final corPredio = stringToColor(predio.cor) ?? Colors.brown.shade200;
    final corFundo = corPredio.withOpacity(0.5);
    final corTexto =
    corPredio.computeLuminance() > 0.5 ? Colors.brown[800] : Colors.white;

    return Tooltip(
      message: '$tarefasCount tarefas\n'
          '$projetosCount projetos\n'
          'Total Demandas: R\$ ${totalDemandas.toStringAsFixed(2)}',
      child: Container(
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/bau_financas.png',
                  height: 48,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Text(
                    predio.nome,
                    style: TextStyle(
                      fontSize: 18,
                      color: corTexto,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total: R\$ ${predio.orcamentoTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: corTexto,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _controllers[predio.id],
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: corTexto),
                    decoration: InputDecoration(
                      labelText: 'Orçamento Mensal',
                      labelStyle:
                      TextStyle(color: corTexto?.withOpacity(0.7)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber.shade200),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber.shade400),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Saldo reservado: R\$ ${saldoReservado.toStringAsFixed(2)}',
              style: TextStyle(color: corTexto, fontSize: 14),
            ),
            Text(
              'Sugestão de aporte: R\$ ${aporteNecessario.toStringAsFixed(2)}',
              style: TextStyle(color: corTexto, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.brown[800],
              ),
              onPressed: () async {
                predio.orcamentoTotal += predio.orcamentoMensal;
                await predio.save();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Aporte de R\$ ${predio.orcamentoMensal.toStringAsFixed(2)} realizado.',
                    ),
                  ),
                );
                setState(() {});
              },
              child: const Text('Aportar orçamento mensal'),
            ),
          ],
        ),
      ),
    );
  }

  void _salvarAlteracoes() async {
    for (var predio in predioBox.values) {
      final texto = _controllers[predio.id]?.text ?? '0';
      final valor = double.tryParse(texto.replaceAll(',', '.')) ?? 0;
      predio.orcamentoMensal = valor;

      await predio.save();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Orçamentos atualizados com sucesso!')),
    );
  }
}