import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../models/insumo.dart';
import '../models/receita_preparada.dart';
import 'package:hive/hive.dart';
import 'package:cidade_da_vida/utils/receita_utils.dart';

class AjusteProducaoScreen extends StatefulWidget {
  final Receita receita;

  const AjusteProducaoScreen({super.key, required this.receita});

  @override
  State<AjusteProducaoScreen> createState() => _AjusteProducaoScreenState();
}

class _AjusteProducaoScreenState extends State<AjusteProducaoScreen> {
  final Map<String, TextEditingController> _quantidadeControllers = {};
  final TextEditingController _quantidadeProduzidaController = TextEditingController();
  final TextEditingController _pesoTotalController = TextEditingController();

  late Box<Insumo> insumoBox;
  late Box<Receita> receitaBox;

  List<IngredientesReceita> _ingredientesExtras = [];
  String? _categoriaSelecionada;

  final List<String> categorias = [
    'Legumes e verduras',
    'Limpeza',
    'Higiene',
    'Bebidas',
    'Descartáveis',
    'Pet',
    'Frutas',
    'Grãos e cereais',
    'Laticínios',
    'Carnes',
    'Temperos',
    'Mercearia'
  ];

  @override
  void initState() {
    super.initState();
    insumoBox = Hive.box<Insumo>('insumos');
    receitaBox = Hive.box<Receita>('receitas');

    for (var ingrediente in widget.receita.ingredientes) {
      _quantidadeControllers[ingrediente.idInsumo] =
          TextEditingController(text: ingrediente.quantidade.toString());
    }

    if (widget.receita.quantidadeProduzida != null) {
      _quantidadeProduzidaController.text =
          widget.receita.quantidadeProduzida!.toString();
    }
  }

  @override
  void dispose() {
    for (var controller in _quantidadeControllers.values) {
      controller.dispose();
    }
    _quantidadeProduzidaController.dispose();
    _pesoTotalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todosIngredientes = [
      ...widget.receita.ingredientes,
      ..._ingredientesExtras,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Produzir: ${widget.receita.nome}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Ingredientes usados:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ...todosIngredientes.map((ingrediente) {
              final insumo = insumoBox.get(ingrediente.idInsumo);
              final nomeInsumo = insumo?.nome ?? ingrediente.nomeInsumo ?? ingrediente.idInsumo;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        nomeInsumo,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "${ingrediente.quantidade} ${ingrediente.unidade}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _quantidadeControllers[ingrediente.idInsumo],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: "Usado",
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _abrirDialogoNovoIngrediente,
              icon: const Icon(Icons.add),
              label: const Text("Adicionar Ingrediente Extra"),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _quantidadeProduzidaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Quantidade produzida (${widget.receita.unidade ?? 'unidade'})",
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pesoTotalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Peso total produzido (em gramas)",
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoriaSelecionada,
              decoration: const InputDecoration(
                labelText: "Categoria do insumo",
              ),
              items: categorias
                  .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _categoriaSelecionada = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _confirmarProducao,
              child: const Text("Confirmar Produção"),
            ),
          ],
        ),
      ),
    );
  }


  void _abrirDialogoNovoIngrediente() {
    String? insumoSelecionadoId;
    final quantidadeController = TextEditingController();
    final unidadeController = TextEditingController();

    final insumos = insumoBox.values.toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Novo Ingrediente"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Ingrediente"),
                    items: insumos
                        .map(
                          (i) => DropdownMenuItem(
                        value: i.id,
                        child: Text(i.nome),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      insumoSelecionadoId = value;
                      final insumo = insumoBox.get(value);
                      setStateDialog(() {
                        unidadeController.text = insumo?.unidadeMedida ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: quantidadeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: "Quantidade"),
                  ),
                  if (unidadeController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: unidadeController,
                      decoration: const InputDecoration(labelText: "Unidade"),
                      readOnly: true,
                      enabled: false,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (insumoSelecionadoId != null) {
                    final insumo = insumoBox.get(insumoSelecionadoId);
                    if (insumo == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Erro: insumo não existe mais."),
                        ),
                      );
                      return;
                    }

                    final novo = IngredientesReceita(
                      idInsumo: insumoSelecionadoId!,
                      nomeInsumo: insumo.nome,
                      quantidade: double.tryParse(
                        quantidadeController.text,
                      ) ??
                          0,
                      unidade: unidadeController.text,
                      opcional: false,
                    );

                    setState(() {
                      _ingredientesExtras
                          .removeWhere((i) => i.idInsumo == novo.idInsumo);
                      _ingredientesExtras.add(novo);
                      _quantidadeControllers[novo.idInsumo] = TextEditingController(
                        text: novo.quantidade.toString(),
                      );
                    });

                    Navigator.pop(context);
                  }
                },
                child: const Text("Adicionar"),
              )
            ],
          );
        },
      ),
    );
  }

  void _confirmarProducao() async {
    widget.receita.calcularCustos(insumoBox);
    await widget.receita.save();

    try {
      double? quantidadeProduzida =
      double.tryParse(_quantidadeProduzidaController.text);

      double? pesoTotal = double.tryParse(_pesoTotalController.text);

      double pesoPorPorcao = 0;
      if (pesoTotal != null &&
          quantidadeProduzida != null &&
          quantidadeProduzida > 0) {
        pesoPorPorcao = pesoTotal / quantidadeProduzida;
      }

      final todosIngredientes = [
        ...widget.receita.ingredientes,
        ..._ingredientesExtras,
      ];

      for (var ingrediente in todosIngredientes) {
        final usadoStr = _quantidadeControllers[ingrediente.idInsumo]?.text ?? "0";
        final usado = double.tryParse(usadoStr) ?? 0.0;

        final insumo = insumoBox.get(ingrediente.idInsumo);
        if (insumo != null) {
          insumo.quantidadeTotal -= usado;
          insumo.quantidadeDisponivel -= usado;
          await insumo.save();
        }
      }

      if (widget.receita.usarComoInsumo &&
          quantidadeProduzida != null &&
          _categoriaSelecionada != null) {
        final insumoExistente = insumoBox.values.firstWhere(
              (i) => i.nome == widget.receita.nome,
          orElse: () => Insumo(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            categoria: _categoriaSelecionada!,
            estaNaListaCompras: false,
            marcadoParaCompra: false,
            quantidadeMinima: 1,
            quantidadeTotal: 0,
            status: 'bom',
            valorUnitario: widget.receita.custoPorcao ?? 0,
            nome: widget.receita.nome,
            unidadeMedida: widget.receita.unidade ?? 'unidade',
            quantidadeDisponivel: 0,
            validade: DateTime.now()
                .add(Duration(days: widget.receita.validadeDias)),
            prediosVinculados: ['Cozinha'],
          ),
        );

        insumoExistente.quantidadeTotal += quantidadeProduzida;
        insumoExistente.quantidadeDisponivel += quantidadeProduzida;
        insumoExistente.categoria = _categoriaSelecionada!;
        insumoExistente.valorUnitario = widget.receita.custoPorcao ?? 0;

        if (!insumoBox.containsKey(insumoExistente.id)) {
          await insumoBox.put(insumoExistente.id, insumoExistente);
        } else {
          await insumoExistente.save();
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produção registrada como insumo!")),
        );
        Navigator.pop(context, null);
      } else {
        // >>> AQUI ENTRA O NOVO BLOCO QUE CALCULA O CUSTO <<<

        double custoTotalProducao = 0;

        for (var ingrediente in todosIngredientes) {
          final usadoStr =
              _quantidadeControllers[ingrediente.idInsumo]?.text ?? "0";
          final usado = double.tryParse(usadoStr) ?? 0.0;

          final insumo = insumoBox.get(ingrediente.idInsumo);
          if (insumo != null) {
            custoTotalProducao += usado * (insumo.valorUnitario ?? 0);
          }
        }

        double custoPorPorcao = 0;
        if (quantidadeProduzida != null && quantidadeProduzida > 0) {
          custoPorPorcao = custoTotalProducao / quantidadeProduzida;
        }

        final novaPreparada = ReceitaPreparada(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nome: widget.receita.nome,
          receitaIdOriginal: widget.receita.id,
          dataPreparo: DateTime.now(),
          validade: DateTime.now()
              .add(Duration(days: widget.receita.validadeDias)),
          porcoesDisponiveis: quantidadeProduzida?.toInt() ?? 0,
          pesoTotal: pesoTotal ?? 0,
          pesoPorPorcao: pesoPorPorcao,
          localArmazenamento: "geladeira",
          tags: [],
          custoPorcao: custoPorPorcao,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produção registrada com sucesso!")),
        );

        Navigator.pop(context, novaPreparada);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar produção: $e")),
      );
    }
  }
}