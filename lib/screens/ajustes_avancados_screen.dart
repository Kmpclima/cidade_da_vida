import 'package:flutter/material.dart';
import '../models/projeto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/recursos_utils.dart';
import '../models/predio.dart';
import '../models/servico.dart';
import '../models/demanda.dart';
import 'package:cidade_da_vida/models/insumo.dart';

class AjustesAvancadosScreen extends StatefulWidget {

  final Predio predio;
  const AjustesAvancadosScreen({super.key, required this.predio});

  @override
  State<AjustesAvancadosScreen> createState() => _AjustesAvancadosScreenState();
}

class _AjustesAvancadosScreenState extends State<AjustesAvancadosScreen> {
  double valorManual = 0.0;

  @override
  Widget build(BuildContext context) {

    final predio = widget.predio;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajustes Avançados"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  predio.orcamentoTotal = 0;
                  predio.save();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Orçamento zerado!")),
                  );
                },
                child: const Text("Zerar orçamento do prédio"),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  double valor = await calcularTotalGastosJaPagos();
                  predio.orcamentoTotal -= valor;
                  await predio.save();

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Foram debitados R\$ ${valor.toStringAsFixed(2)} ao orçamento.")),
                  );
                },
                child: const Text("Debitar gastos já pagos"),
              ),
              const SizedBox(height: 32),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Valor manual (+ ou -)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  valorManual = double.tryParse(value) ?? 0.0;
                },
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  predio.orcamentoTotal += valorManual;
                  predio.save();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Orçamento ajustado em R\$ ${valorManual.toStringAsFixed(2)}")),
                  );
                },
                child: const Text("Aplicar ajuste"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<double> calcularTotalGastosJaPagos() async {
    final predio = widget.predio;

    double total = 0.0;

    // Serviços pagos
    final boxServicos = Hive.box<Servico>('servicos');
    final servicosDoPredio = boxServicos.values
        .where((s) => s.predioId == predio.id && s.status == 'pago');
    total += servicosDoPredio.fold(0.0, (prev, s) => prev + s.valor);

    // Demandas aprovadas
    final boxProjetos = Hive.box<Projeto>('projetos');
    final boxDemandas = Hive.box<Demanda>('demandas');

    final demandasDoPredio = boxDemandas.values.where((d) {
      if (d.projetoSolicitante == null || d.projetoSolicitante!.isEmpty) {
        return false;
      }

      Projeto? projeto;

      try {
        projeto = boxProjetos.values.firstWhere(
              (p) => p.id == d.projetoSolicitante,
        );
      } catch (e) {
        projeto = null;
      }

      if (projeto == null) return false;

      return projeto.categoria == predio.nome && d.status == 'aprovada';
    }).toList();

    total += demandasDoPredio.fold(
      0.0,
          (prev, d) =>
      prev + ((d.quantidadeSolicitada ?? 0) * (d.valorUnitario ?? 0.0)),
    );

    // Insumos recebidos
    final boxInsumos = Hive.box<Insumo>('insumos');
    final insumosDoPredio = boxInsumos.values.where((i) {
      if (i.prediosVinculados.isEmpty) return false;
      return i.prediosVinculados.first == predio.id && i.status == 'recebido';
    }).toList();


    total += insumosDoPredio.fold(
      0.0,
          (prev, i) =>
      prev + ((i.quantidadeDisponivel ?? 0) * (i.valorUnitario)),
    );

    return total;
  }
}