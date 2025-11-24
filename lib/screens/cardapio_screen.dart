import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/cardapio.dart';
import '../models/receita.dart';
import '../models/receita_preparada.dart';
import '../models/insumo.dart';
import '../controllers/cardapio_manager.dart';
import '../utils/data_utils.dart';
import 'ajuste_producao_screen.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:collection/collection.dart';
import 'package:cidade_da_vida/models/receita_preparada.dart';

class CardapioScreen extends StatefulWidget {
  final Cardapio cardapio;

  const CardapioScreen({super.key, required this.cardapio});

  @override
  State<CardapioScreen> createState() => _CardapioScreenState();
}


class _CardapioScreenState extends State<CardapioScreen> {
  late Box<Cardapio> cardapioBox;
  late Box<Insumo> insumoBox;
  late Box<ReceitaPreparada> preparadasBox;

  Cardapio? semanaSelecionada;
  List<Cardapio> semanasDisponiveis = [];

  @override
  void initState() {
    super.initState();
    cardapioBox = Hive.box<Cardapio>('cardapios');
    insumoBox = Hive.box<Insumo>('insumos');
    preparadasBox = Hive.box<ReceitaPreparada>('receitasPreparadas');
    carregarCardapios();
  }

  double calcularCustoTotalDaRefeicao(Refeicao refeicao) {
    double total = 0.0;

    // Custos das receitas (chips vermelhos)
    for (final r in refeicao.receitas) {
      total += r.custoPorcao ?? 0.0;
    }

    // Custos das porções preparadas (chips verdes)
    for (final p in refeicao.preparadasNaRefeicao) {
      if (p.custoPorcao != null) {
        total += p.custoPorcao!;
      } else {
        // Tenta buscar custo na receita original, caso não tenha na preparada
        final receitaOriginal = Hive.box<Receita>('receitas').values.firstWhereOrNull(
              (r) => r.id == p.receitaIdOriginal,
        );

        if (receitaOriginal != null) {
          total += receitaOriginal.custoPorcao ?? 0.0;
        }
      }
    }

    // Custos dos itens avulsos
    for (final i in refeicao.itensAvulsos) {
      final insumo = Hive.box<Insumo>('insumos').values.firstWhereOrNull(
            (insumo) => insumo.nome == i.nome,
      );
      if (insumo != null) {
        total += (insumo.valorUnitario ?? 0.0) * (i.quantidade ?? 0);
      }
    }

    return total;
  }

  DateTime calcularDataDoDia(String nomeDia, Cardapio cardapio) {
    final dias = [
      "Domingo",
      "Segunda",
      "Terça",
      "Quarta",
      "Quinta",
      "Sexta",
      "Sábado"
    ];

    int index = dias.indexOf(nomeDia);
    if (index == -1) return cardapio.dataInicio;

    return cardapio.dataInicio.add(Duration(days: index));
  }

  Refeicao? buscarRefeicaoNoDia(
      String nomeRefeicao, DateTime data, Cardapio cardapio) {
    try {
      return cardapio.refeicoes.firstWhere(
            (r) =>
        r.data.year == data.year &&
            r.data.month == data.month &&
            r.data.day == data.day &&
            r.nome == nomeRefeicao,
      );
    } catch (e) {
      return null;
    }
  }

  void _concluirRefeicao(Refeicao refeicao) async {
    // Consumir itens avulsos (poderia lançar log de consumo no futuro)
    for (final item in refeicao.itensAvulsos) {
      print("Consumindo item avulso: ${item.nome} - ${item.quantidade} ${item.unidade}");
      // Aqui poderia lançar log ou atualizar estoque real
    }

    // Consumir porções preparadas
    for (final preparada in refeicao.preparadasNaRefeicao) {
      final existente = preparadasBox.get(preparada.id);
      if (existente != null) {
        existente.porcoesDisponiveis -= preparada.porcoesDisponiveis;
        if (existente.porcoesDisponiveis <= 0) {
          await preparadasBox.delete(existente.id);
        } else {
          await existente.save();
        }
      }
    }

    refeicao.concluida = true;
    await semanaSelecionada!.save();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Refeição concluída com sucesso!")),
    );
  }

  Widget receitasSelecionadasWidget() {
    final receitas = CardapioManager().receitasSelecionadas;

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: receitas.length,
        itemBuilder: (context, index) {
          final receita = receitas[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Draggable<Receita>(
              data: receita,
              feedback: Material(
                color: Colors.transparent,
                child: _buildReceitaChip(receita, isFeedback: true),
              ),
              childWhenDragging: Opacity(
                opacity: 0.4,
                child: _buildReceitaChip(receita),
              ),
              child: _buildReceitaChip(receita),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReceitaChip(
      Receita receita, {
        bool isFeedback = false,
        Refeicao? refeicao,
      }) {
    return PopupMenuButton<String>(
      tooltip: "Ações",
      onSelected: (value) async {
        if (value == "fazer") {
          await _marcarReceitaComoFeita(receita);
        } else if (value == "excluir") {
          if (refeicao != null) {
            refeicao.receitas.removeWhere((r) => r.id == receita.id);
            await semanaSelecionada?.save();
          } else {
            CardapioManager()
                .receitasSelecionadas
                .removeWhere((r) => r.id == receita.id);
          }
          setState(() {});
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: "fazer",
          child: Text("Marcar como feita"),
        ),
        const PopupMenuItem(
          value: "excluir",
          child: Text("Excluir receita"),
        ),
      ],
      child: Chip(
        label: Text(
          receita.nome,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isFeedback ? 16 : 14,
          ),
        ),
        backgroundColor: Colors.red,
        deleteIcon: const Icon(Icons.delete),
        onDeleted: () async {
          if (refeicao != null) {
            refeicao.receitas.removeWhere((r) => r.id == receita.id);
            await semanaSelecionada?.save();
          } else {
            CardapioManager()
                .receitasSelecionadas
                .removeWhere((r) => r.id == receita.id);
          }
          setState(() {});
        },
      ),
    );
  }

  Future<void> _marcarReceitaComoFeita(Receita receita) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjusteProducaoScreen(receita: receita),
      ),
    );

    if (resultado != null && resultado is ReceitaPreparada) {
      await preparadasBox.put(resultado.id, resultado);
      CardapioManager()
          .receitasSelecionadas
          .removeWhere((r) => r.id == receita.id);
      setState(() {});
    }
  }

  Widget preparadasWidget(String local) {
    final preparadas =
    preparadasBox.values.where((p) => p.localArmazenamento == local).toList();

    if (preparadas.isEmpty) {
      return Text(
        "Nenhuma porção no $local",
        style: const TextStyle(color: Colors.white),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: preparadas.map((p) {
        return Draggable<ReceitaPreparada>(
          data: p,
          feedback: Material(
            color: Colors.transparent,
            child: _buildPreparadaChip(p, isFeedback: true),
          ),
          childWhenDragging: Opacity(
            opacity: 0.4,
            child: _buildPreparadaChip(p),
          ),
          child: _buildPreparadaChip(p),
        );
      }).toList(),
    );
  }

  Widget _buildPreparadaChip(ReceitaPreparada p, {bool isFeedback = false}) {
    return Chip(
      label: Text(
        "${p.nome} (${p.porcoesDisponiveis} porções)",
        style: TextStyle(
          color: Colors.white,
          fontSize: isFeedback ? 16 : 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.green,
      deleteIcon: const Icon(Icons.delete),
      onDeleted: () async {
        // Verifica se está dentro da refeição
        final estaNaRefeicao =
        semanaSelecionada!.refeicoes.any((refeicao) =>
            refeicao.preparadasNaRefeicao.any((r) => r.id == p.id));

        if (estaNaRefeicao) {
          // Remove da refeição
          for (var refeicao in semanaSelecionada!.refeicoes) {
            refeicao.preparadasNaRefeicao
                .removeWhere((x) => x.id == p.id);
          }

          // Verifica se já existe no Hive
          var existente = preparadasBox.get(p.id);
          if (existente != null) {
            existente.porcoesDisponiveis += p.porcoesDisponiveis;
            await existente.save();
          } else {
            await preparadasBox.put(p.id, p);
          }

          await semanaSelecionada!.save();
          setState(() {});
        } else {
          // Está na geladeira/freezer → não faz nada
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("O item já está no estoque.")),
          );
        }
      },
      avatar: IconButton(
        icon: const Icon(Icons.local_dining, color: Colors.white, size: 18),
        onPressed: () {
          // Futuro: consumir porções
        },
      ),
    );
  }

  Widget diasDaSemanaWidget() {
    final dias = [
      "Domingo",
      "Segunda",
      "Terça",
      "Quarta",
      "Quinta",
      "Sexta",
      "Sábado"
    ];

    final refeicoesPadrao = [
      "Almoço",
      "Jantar",
      "Lanche 1",
      "Lanche 2",
      "Lanche 3"
    ];

    return SingleChildScrollView(
      child: Column(
        children: dias.map((dia) {
          final dataDoDia = semanaSelecionada != null
              ? calcularDataDoDia(dia, semanaSelecionada!)
              : null;

          return Card(
            margin: const EdgeInsets.all(8),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dia,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...refeicoesPadrao.map((refeicao) {
                    return DragTarget<Object>(
                      onWillAcceptWithDetails: (details) => true,
                      onAcceptWithDetails: (details) async {
                        var data = details.data;
                        final dataDia = dataDoDia!;
                        var refeicaoObj = buscarRefeicaoNoDia(
                            refeicao, dataDia, semanaSelecionada!);

                        if (refeicaoObj == null) {
                          refeicaoObj = Refeicao(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            nome: refeicao,
                            receitas: [],
                            itensAvulsos: [],
                            data: dataDia,
                            concluida: false,
                            quantidadePorcoes: 0,
                            congelada: false,
                            preparadasNaRefeicao: [],
                          );
                          semanaSelecionada!.refeicoes.add(refeicaoObj);
                        }

                        if (data is Receita) {
                          if (!refeicaoObj.receitas
                              .any((r) => r.id == data.id)) {
                            refeicaoObj.receitas.add(data);
                          }
                          await semanaSelecionada!.save();
                          setState(() {});
                        } else if (data is ReceitaPreparada) {
                          refeicaoObj.preparadasNaRefeicao ??= [];
                          bool jaExiste = refeicaoObj.preparadasNaRefeicao
                              .any((p) => p.id == data.id);
                          if (!jaExiste) {
                            if (data.porcoesDisponiveis > 1) {
                              final novaPorcao = ReceitaPreparada(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                nome: data.nome,
                                receitaIdOriginal: data.receitaIdOriginal,
                                dataPreparo: data.dataPreparo,
                                validade: data.validade,
                                porcoesDisponiveis: 1,
                                pesoTotal: (data.pesoTotal ?? 0) /
                                    (data.porcoesDisponiveis ?? 1),
                                pesoPorPorcao: data.porcoesDisponiveis != null &&
                                    data.porcoesDisponiveis! > 0
                                    ? (data.pesoTotal ?? 0) /
                                    data.porcoesDisponiveis!
                                    : 0,
                                localArmazenamento: data.localArmazenamento,
                                tags: data.tags,
                              );
                              refeicaoObj.preparadasNaRefeicao.add(novaPorcao);
                              data.porcoesDisponiveis -= 1;
                              await preparadasBox.put(data.id, data);
                            } else {
                              refeicaoObj.preparadasNaRefeicao.add(data);
                              await preparadasBox.delete(data.id);
                            }
                            await semanaSelecionada!.save();
                            setState(() {});
                          }
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        final refeicaoEncontrada = dataDoDia != null
                            ? buscarRefeicaoNoDia(
                            refeicao, dataDoDia, semanaSelecionada!)
                            : null;

                        final receitas = refeicaoEncontrada?.receitas ?? [];
                        final preparadas =
                            refeicaoEncontrada?.preparadasNaRefeicao ?? [];
                        final itensAvulsos =
                            refeicaoEncontrada?.itensAvulsos ?? [];

                        return Card(
                          color: candidateData.isNotEmpty
                              ? Colors.teal.shade100
                              : Colors.grey.shade100,
                          margin:
                          const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              refeicao,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (refeicaoEncontrada != null)
                                  Text(
                                    "Custo total: R\$ ${calcularCustoTotalDaRefeicao(refeicaoEncontrada).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                if (receitas.isEmpty &&
                                    preparadas.isEmpty &&
                                    itensAvulsos.isEmpty)
                                  const Text(
                                    "Nenhuma receita ou porção.",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12),
                                  ),
                                if (receitas.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    children: receitas
                                        .map((r) => _buildReceitaChip(r, refeicao: refeicaoEncontrada))
                                        .toList(),
                                  ),
                                if (preparadas.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    children: preparadas
                                        .map((p) =>
                                        _buildPreparadaChip(p))
                                        .toList(),
                                  ),
                                if (itensAvulsos.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    children: itensAvulsos
                                        .map((i) => Chip(
                                      label: Text(
                                        "${i.nome} (${i.quantidade} ${i.unidade})",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      backgroundColor:
                                      Colors.orange,
                                      deleteIcon:
                                      const Icon(Icons.delete),
                                      onDeleted: () async {
                                        refeicaoEncontrada
                                            ?.itensAvulsos
                                            .removeWhere(
                                                (x) =>
                                            x.nome ==
                                                i.nome);
                                        await semanaSelecionada!
                                            .save();
                                        setState(() {});
                                      },
                                    ))
                                        .toList(),
                                  )
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  tooltip: 'Concluir Refeição',
                                  onPressed: refeicaoEncontrada?.concluida == true
                                      ? null
                                      : () {
                                    if (refeicaoEncontrada != null) {
                                      _concluirRefeicao(refeicaoEncontrada);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: refeicaoEncontrada?.concluida == true
                                      ? null
                                      : () {
                                    if (refeicaoEncontrada != null) {
                                      _abrirModalNovoItemAvulso(refeicaoEncontrada);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> carregarCardapios() async {
    final todos = cardapioBox.values.toList();

    final hoje = DateTime.now();

    // Procura o cardápio atual
    Cardapio? semanaAtual;

    for (final c in todos) {
      if (hoje.isAfter(c.dataInicio.subtract(const Duration(days: 1))) &&
          hoje.isBefore(c.dataFim.add(const Duration(days: 1)))) {
        semanaAtual = c;
        break;
      }
    }

    if (semanaAtual == null) {
      // Nenhum cardápio cobre a semana atual → cria um novo

      final inicioSemana = ultimoDomingo(hoje);
      final fimSemana = inicioSemana.add(const Duration(days: 6));

      final novoCardapio = Cardapio(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: "Semana ${inicioSemana.day}/${inicioSemana.month}",
        dataInicio: inicioSemana,
        dataFim: fimSemana,
        refeicoes: [],
      );

      await cardapioBox.put(novoCardapio.id, novoCardapio);

      semanaAtual = novoCardapio;
    }

    // Atualiza dropdown
    semanasDisponiveis = cardapioBox.values.toList()
      ..sort((a, b) => a.dataInicio.compareTo(b.dataInicio));

    semanaSelecionada = semanaAtual;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: const Text(
          'Cardápio da Semana',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          DropdownButton<Cardapio>(
            value: semanaSelecionada,
            dropdownColor: Colors.teal,
            style: const TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
            items: semanasDisponiveis
                .map((c) => DropdownMenuItem(
              value: c,
              child: Text(c.nome),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                semanaSelecionada = value;
              });
            },
          )
        ],
      ),
      body: semanaSelecionada == null
          ? const Center(child: Text("Nenhuma semana selecionada."))
          : Column(
        children: [
          // ---------- ÁREA FIXA ----------
          ExpansionTile(
            title: const Text(
              "Estoque e Área de Descarte",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: true,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: DragTarget<Object>(
                  onWillAcceptWithDetails: (details) => true,
                  onAcceptWithDetails: (details) async {
                    final data = details.data;
                    await _confirmarDescarte(data);
                    if (mounted) setState(() {});
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      height: 60,
                      width: 200,
                      decoration: BoxDecoration(
                        color: candidateData.isNotEmpty
                            ? Colors.red.shade300
                            : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 250,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Receitas Selecionadas:",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      receitasSelecionadasWidget(),
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Geladeira:",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      preparadasWidget("geladeira"),
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Freezer:",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      preparadasWidget("freezer"),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ---------- ÁREA SCROLLÁVEL ----------
          Expanded(
            child: SingleChildScrollView(
              child: diasDaSemanaWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Future <void> _confirmarDescarte(Object data) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Descartar produto"),
        content: const Text(
            "Deseja realmente descartar este produto? Isso removerá do estoque ou do cardápio."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Descartar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (data is ReceitaPreparada) {
        if (data.porcoesDisponiveis > 1) {
          data.porcoesDisponiveis -= 1;
          await data.save();
        } else {
          await preparadasBox.delete(data.id);
        }
      } else if (data is Receita) {
        CardapioManager().removerReceita(data);
      } else if (data is ItemAvulso) {
        for (var r in semanaSelecionada!.refeicoes) {
          r.itensAvulsos.removeWhere((i) => i.nome == data.nome);
        }
        await semanaSelecionada!.save();
      }
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produto descartado com sucesso.")),
      );
    }
  }

  void _abrirModalNovoItemAvulso(Refeicao refeicao) {
    final nomeController = TextEditingController();
    final unidadeController = TextEditingController();
    final quantidadeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Novo Item Avulso"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TypeAheadField<Insumo>(
                suggestionsCallback: (pattern) {
                  return insumoBox.values
                      .where((insumo) => insumo.nome
                      .toLowerCase()
                      .startsWith(pattern.toLowerCase()))
                      .toList()
                  ..sort((a,b) => a.nome.compareTo(b.nome));
                },
                itemBuilder: (context, insumo) {
                  return ListTile(
                    title: Text(insumo.nome),
                    subtitle: Text(insumo.unidadeMedida ?? ''),
                  );
                },
                onSelected: (insumo) {
                  //controller.text = insumo.nome;
                  nomeController.text = insumo.nome;
                  unidadeController.text = insumo.unidadeMedida ?? '';
                  // Opcional: se quiser preencher quantidade padrão

                },
                builder: (context, typeAheadController, focusNode) {
                  return TextField(
                    controller: typeAheadController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Nome do insumo',
                    ),

                    onChanged: (value) {
                      // Atualiza o nomeController também
                      nomeController.text = value;
                    },
                  );
                },
                emptyBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Nenhum item encontrado."),
                ),
              ),
              TextField(
                controller: unidadeController,
                readOnly: true, // ← impede digitar manualmente
                decoration: const InputDecoration(labelText: "Unidade"),
              ),
              TextField(
                controller: quantidadeController,
                decoration: const InputDecoration(labelText: "Quantidade"),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final novo = ItemAvulso(
                nome: nomeController.text,
                quantidade:
                double.tryParse(quantidadeController.text) ?? 0,
                unidade: unidadeController.text,
              );

              refeicao.itensAvulsos.add(novo);
              await semanaSelecionada!.save();
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Adicionar"),
          )
        ],
      ),
    );
  }
}