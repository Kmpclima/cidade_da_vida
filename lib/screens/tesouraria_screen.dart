import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tesouraria.dart';
import '../models/entrada_financeira.dart';
import '../models/distribuicao_orcamentaria.dart';
import 'package:cidade_da_vida/models/predio.dart';

class TesourariaScreen extends StatefulWidget {
  const TesourariaScreen({super.key});

  @override
  State<TesourariaScreen> createState() => _TesourariaScreenState();
}

class _TesourariaScreenState extends State<TesourariaScreen> {
  late Box<Tesouraria> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<Tesouraria>('tesouraria');
  }

  Tesouraria get _tesouraria => _box.getAt(0)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tesouraria"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "💰 Saldo disponível: R\$ ${_tesouraria.saldoAtual.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _abrirFormularioEntrada,
                  child: const Text("Adicionar Entrada"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _abrirFormularioDistribuicao,
                  child: const Text("Distribuir Fundos"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("📥 Entradas recentes:", style: TextStyle(fontSize: 16)),
            Expanded(
              child: ListView.builder(
                itemCount: _tesouraria.entradas.length,
                itemBuilder: (context, index) {
                  final entrada = _tesouraria.entradas.reversed.toList()[index];
                  return ListTile(
                    title: Text("${entrada.origem} (+R\$${entrada.valor.toStringAsFixed(2)})"),
                    subtitle: Text("${entrada.data.toLocal().toString().split(' ')[0]}"
                        "${entrada.predioRelacionado != null ? ' - ${entrada.predioRelacionado}' : ''}"),
                  );
                },
              ),
            ),
            const Divider(),
            const Text("📤 Distribuições:", style: TextStyle(fontSize: 16)),
            Expanded(
              child: ListView.builder(
                itemCount: _tesouraria.distribuicoes.length,
                itemBuilder: (context, index) {
                  final dist = _tesouraria.distribuicoes.reversed.toList()[index];
                  return ListTile(
                    title: Text("→ ${dist.predioDestino} (R\$${dist.valor.toStringAsFixed(2)})"),
                    subtitle: Text("${dist.data.toLocal().toString().split(' ')[0]}"
                        "${dist.descricao != null ? ' - ${dist.descricao}' : ''}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirFormularioEntrada() {
    showDialog(
      context: context,
      builder: (_) => _FormNovaEntrada(onSalvar: (entrada) {
        setState(() {
          _tesouraria.adicionarEntrada(entrada);
        });
      }),
    );
  }

  void _abrirFormularioDistribuicao() {
    showDialog(
      context: context,
      builder: (_) => _FormNovaDistribuicao(
        saldoAtual: _tesouraria.saldoAtual,
        onSalvar: (dist) {
          final sucesso = _tesouraria.distribuirVerificandoSaldo(dist);
          if (!sucesso) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Saldo insuficiente para essa distribuição.")),
            );
          } else {
            setState(() {});
          }
          return sucesso; // ✅ ESSA LINHA É ESSENCIAL!
        },
      ),
    );
  }
}

class _FormNovaEntrada extends StatefulWidget {
  final Function(EntradaFinanceira) onSalvar;

  const _FormNovaEntrada({required this.onSalvar});

  @override
  State<_FormNovaEntrada> createState() => _FormNovaEntradaState();
}

class _FormNovaEntradaState extends State<_FormNovaEntrada> {
  final _formKey = GlobalKey<FormState>();
  String _origem = '';
  double _valor = 0;
  String? _predioRelacionado;
  List<String> _prediosDisponiveis = [];

  @override
  void initState() {
    super.initState();
    final boxPredios = Hive.box<Predio>('predios');
    _prediosDisponiveis = boxPredios.values.map((p) => p.nome).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nova Entrada"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Origem"),
              validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
              onSaved: (val) => _origem = val!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Valor (R\$)"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (val) {
                final v = double.tryParse(val ?? '');
                if (v == null || v <= 0) return 'Informe um valor válido';
                return null;
              },
              onSaved: (val) => _valor = double.parse(val!),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Prédio relacionado (opcional)",
              ),
              value: _prediosDisponiveis.isNotEmpty ? null : null,
              items: _prediosDisponiveis
                  .map((nome) => DropdownMenuItem(value: nome, child: Text(nome)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _predioRelacionado = val;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar")),
        ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                final entrada = EntradaFinanceira(
                  origem: _origem,
                  data: DateTime.now(),
                  valor: _valor,
                  predioRelacionado: _predioRelacionado,
                );
                widget.onSalvar(entrada);
                Navigator.of(context).pop();
              }
            },
            child: const Text("Salvar")),
      ],
    );
  }
}

class _FormNovaDistribuicao extends StatefulWidget {
  final double saldoAtual;
  final Function(DistribuicaoOrcamentaria) onSalvar;

  const _FormNovaDistribuicao({
    required this.saldoAtual,
    required this.onSalvar,
  });

  @override
  State<_FormNovaDistribuicao> createState() => _FormNovaDistribuicaoState();
}

class _FormNovaDistribuicaoState extends State<_FormNovaDistribuicao> {
  final _formKey = GlobalKey<FormState>();
  String _predioDestino = '';
  double _valor = 0;
  String? _descricao;

  List<String> _prediosDisponiveis = [];

  @override
  void initState() {
    super.initState();
    final boxPredios = Hive.box<Predio>('predios');
    _prediosDisponiveis = boxPredios.values.map((p) => p.nome).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Distribuir Fundos"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Saldo disponível: R\$ ${widget.saldoAtual.toStringAsFixed(2)}"),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Prédio destino"),
              value: _prediosDisponiveis.isNotEmpty ? _prediosDisponiveis.first : null,
              items: _prediosDisponiveis
                  .map((nome) => DropdownMenuItem(value: nome, child: Text(nome)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _predioDestino = val!;
                });
              },
              validator: (val) =>
              val == null || val.isEmpty ? 'Selecione um prédio' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Valor (R\$)"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (val) {
                final v = double.tryParse(val ?? '');
                if (v == null || v <= 0) return 'Valor inválido';
                if (v > widget.saldoAtual) return 'Saldo insuficiente';
                return null;
              },
              onSaved: (val) => _valor = double.parse(val!),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Descrição (opcional)"),
              onSaved: (val) => _descricao = val,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              final dist = DistribuicaoOrcamentaria(
                predioDestino: _predioDestino,
                data: DateTime.now(),
                valor: _valor,
                descricao: _descricao,
              );

              final sucesso = widget.onSalvar(dist);

              if (sucesso) {
                try {
                  final boxPredios = Hive.box<Predio>('predios');
                  final predio = boxPredios.values.firstWhere(
                        (p) => p.nome == dist.predioDestino,
                  );

                  predio.orcamentoTotal += dist.valor;
                  predio.orcamentoMensal += dist.valor;
                  await predio.save();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("💰 R\$${dist.valor.toStringAsFixed(2)} enviados para ${dist.predioDestino}")),
                    );
                  }

                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("⚠️ Prédio '${dist.predioDestino}' não encontrado.")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("❌ Saldo insuficiente para distribuir.")),
                );
              }
            }
          },
          child: const Text("Salvar"),
        ),
      ],
    );
  }
}