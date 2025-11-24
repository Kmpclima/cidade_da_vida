import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/insumo.dart';
import '../models/predio.dart';

class ConferenciaInsumosScreen extends StatefulWidget {
  const ConferenciaInsumosScreen({super.key});

  @override
  State<ConferenciaInsumosScreen> createState() => _ConferenciaInsumosScreenState();
}

class _ConferenciaInsumosScreenState extends State<ConferenciaInsumosScreen> {
  late Box<Insumo> insumoBox;
  late Box<Predio> predioBox;

  @override
  void initState() {
    super.initState();
    insumoBox = Hive.box<Insumo>('insumos');
    predioBox = Hive.box<Predio>('predios');
  }

  @override
  Widget build(BuildContext context) {
    final pendentes = insumoBox.values
        .where((i) => i.status == 'aguardando compra')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conferir Insumos Pendentes'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: pendentes.isEmpty
          ? const Center(child: Text('Nenhum insumo aguardando conferência.'))
          : ListView.builder(
        itemCount: pendentes.length,
        itemBuilder: (context, index) {
          final insumo = pendentes[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: _buildInsumoForm(insumo),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsumoForm(Insumo insumo) {
    final valorController = TextEditingController(
      text: insumo.valorUnitario.toStringAsFixed(2),
    );

    final qtdController = TextEditingController(
      text: "0",
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          insumo.nome,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Estoque atual: ${insumo.quantidadeTotal} ${insumo.unidadeMedida}',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: TextField(
                controller: valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Valor unitário',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: TextField(
                controller: qtdController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Qtd recebida',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
              child: const Text('Salvar'),
              onPressed: () async {
                await _salvarInsumo(insumo, valorController, qtdController);
              },
            )
          ],
        )
      ],
    );
  }

  Future<void> _salvarInsumo(
      Insumo insumo,
      TextEditingController valorController,
      TextEditingController qtdController) async {
    final novoValor = double.tryParse(
        valorController.text.replaceAll(',', '.')) ??
        insumo.valorUnitario;

    final novaQtd = double.tryParse(
        qtdController.text.replaceAll(',', '.')) ??
        0;

    // Atualizar insumo
    insumo.valorUnitario = novoValor;
    insumo.quantidadeTotal += novaQtd;
    insumo.quantidadeDisponivel += novaQtd;
    insumo.status = 'bom';
    await insumo.save();

    // Rateio orçamento
    double custo = novaQtd * novoValor;

    for (var predioNome in insumo.prediosVinculados ?? []) {
      final prediosEncontrados = predioBox.values
          .where((p) => p.nome == predioNome);

      if (prediosEncontrados.isNotEmpty) {
        final predio = prediosEncontrados.first;
        predio.orcamentoTotal -= custo;
        await predio.save();
        print('[DEBUG] Debitado R\$ ${custo.toStringAsFixed(2)} do prédio ${predio.nome}');
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Salvo: ${insumo.nome}\n'
                'Novo valor unitário: ${insumo.valorUnitario}\n'
                'Novo estoque: ${insumo.quantidadeTotal}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() {});
  }
}