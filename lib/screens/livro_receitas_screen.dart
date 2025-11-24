import 'dart:io';

import 'package:cidade_da_vida/controllers/cardapio_manager.dart';
import 'package:cidade_da_vida/models/insumo.dart';
import 'package:cidade_da_vida/models/receita.dart';
import 'package:cidade_da_vida/models/receita_preparada.dart';
import 'package:cidade_da_vida/screens/ajuste_producao_screen.dart';
import 'package:cidade_da_vida/screens/detalhe_receita_screen.dart';
import 'package:cidade_da_vida/utils/receita_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:cidade_da_vida/screens/nova_receita_screen.dart';

class LivroReceitasScreen extends StatefulWidget {
  const LivroReceitasScreen({super.key});

  @override
  State<LivroReceitasScreen> createState() => _LivroReceitasScreenState();
}

class _LivroReceitasScreenState extends State<LivroReceitasScreen> {
  late Box<Receita> receitaBox;
  late Box<Insumo> insumoBox;
  late Box<ReceitaPreparada> preparadasBox;
  late Box<List<String>> tagsBox;

  List<Receita> receitasFiltradas = [];
  List<String> selectedTags = [];
  String ingredienteFiltro = '';

  List<String> todasAsTags = [];

  @override
  void initState() {
    super.initState();
    receitaBox = Hive.box<Receita>('receitas');
    insumoBox = Hive.box<Insumo>('insumos');
    preparadasBox = Hive.box<ReceitaPreparada>('receitasPreparadas');
    tagsBox = Hive.box<List<String>>('tags');

    final tags = tagsBox.get('tags') ?? []; // AJUSTADO aqui
    tags.sort();
    todasAsTags = tags;

    atualizarListaFiltrada();
  }


  void atualizarListaFiltrada() {
    final receitasOriginais = receitaBox.values.toList();

    List<Receita> filtradas = receitasOriginais;

    if (selectedTags.isNotEmpty) {
      filtradas = filtradas.where((receita) {
        return receita.tags.any((tag) => selectedTags.contains(tag));
      }).toList();
    }

    if (ingredienteFiltro.isNotEmpty) {
      filtradas = filtradas.where((receita) {
        return receita.ingredientes.any((ing) {
          final insumo = insumoBox.get(ing.idInsumo);
          return insumo?.nome
              .toLowerCase()
              .contains(ingredienteFiltro.toLowerCase()) ??
              false;
        });
      }).toList();
    }

    // Ordena por nome
    filtradas.sort((a, b) => a.nome.compareTo(b.nome));

    setState(() {
      receitasFiltradas = filtradas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Livro de Receitas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final termo = await showDialog<String>(
                context: context,
                builder: (context) {
                  String texto = "";
                  return AlertDialog(
                    title: const Text("Buscar ingrediente"),
                    content: TextField(
                      autofocus: true,
                      onChanged: (value) => texto = value,
                      decoration: const InputDecoration(
                        labelText: "Digite o ingrediente...",
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, null),
                        child: const Text("Cancelar"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, texto),
                        child: const Text("Buscar"),
                      )
                    ],
                  );
                },
              );

              if (termo != null) {
                ingredienteFiltro = termo;
                atualizarListaFiltrada();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: "Limpar filtros",
            onPressed: () {
              ingredienteFiltro = '';
              selectedTags.clear();
              atualizarListaFiltrada();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          MultiSelectDialogField<String>(
            items: todasAsTags
                .map((tag) => MultiSelectItem(tag, tag))
                .toList(),
            initialValue: selectedTags,
            title: const Text("Filtrar por tags"),
            buttonText: const Text("Filtrar por tags"),
            onConfirm: (values) {
              selectedTags = values;
              atualizarListaFiltrada();
            },
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: receitasFiltradas.length,
              itemBuilder: (context, index) {
                final receita = receitasFiltradas[index];
                final status = verificarStatusReceita(receita, insumoBox);
                final cor = corDeFundoParaStatus(status);
                final icone = iconeParaStatus(status);
                final ingredientesFaltantes =
                obterIngredientesFaltantes(receita, insumoBox);

                return Card(
                  color: cor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetalheReceitaScreen(receita: receita),
                              ),
                            );
                          },
                          child: receita.imagemPath != null &&
                              File(receita.imagemPath!).existsSync()
                              ? ClipRRect(
                            borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(8)),
                            child: Image.file(
                              File(receita.imagemPath!),
                              fit: BoxFit.cover,
                            ),
                          )
                              : Container(
                            color: Colors.brown[100],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Column(
                          children: [
                            Text(
                              receita.nome,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (ingredientesFaltantes.isNotEmpty)
                              Text(
                                "Faltam: ${ingredientesFaltantes.join(', ')}",
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            if (receita.tempoPreparo != null)
                              Text(
                                  "${receita.tempoPreparo} min • ${receita.ingredientes.length} itens"),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.restaurant_menu),
                                  tooltip: "Fazer",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AjusteProducaoScreen(receita: receita),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.playlist_add),
                                  tooltip: "Adicionar ao cardápio",
                                  onPressed: () {
                                    CardapioManager().adicionarReceita(receita);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "${receita.nome} adicionada ao cardápio."),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NovaReceitaScreen()),
          );
        },
        tooltip: "Nova Receita",
        child: const Icon(Icons.add),
      ),
    );
  }

  List<String> obterIngredientesFaltantes(
      Receita receita, Box<Insumo> insumoBox) {
    final faltantes = <String>[];

    for (final ingrediente in receita.ingredientes) {
      final insumo = insumoBox.get(ingrediente.idInsumo);
      if (insumo == null ||
          insumo.quantidadeDisponivel < ingrediente.quantidade) {
        faltantes.add(insumo?.nome ?? "Desconhecido");
      }
    }
    return faltantes;
  }
}