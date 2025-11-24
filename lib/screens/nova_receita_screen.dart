import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../models/receita.dart';
import '../models/insumo.dart';
import 'package:cidade_da_vida/utils/receita_utils.dart';

class NovaReceitaScreen extends StatefulWidget {
  const NovaReceitaScreen({super.key});

  @override
  State<NovaReceitaScreen> createState() => _NovaReceitaScreenState();
}

class _NovaReceitaScreenState extends State<NovaReceitaScreen> {
  final _formKey = GlobalKey<FormState>();
  late Box<Insumo> insumoBox;
  late Box<List<String>> tagsBox;

  String nome = '';
  String? descricao;
  double? tempoPreparo;
  bool usarComoInsumo = false;
  List<String> tags = [];
  String? imagemPath;
  int validadeDias = 3;
  double? quantidadeProduzida;
  String? unidade;
  List<String> todasTags = [];

  List<IngredientesReceita> ingredientes = [];

  @override
  void initState() {
    super.initState();
    insumoBox = Hive.box<Insumo>('insumos');
    tagsBox = Hive.box<List<String>>('tags');
    todasTags = tagsBox.get('tags', defaultValue: []) ?? [];

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova Receita")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration:
                const InputDecoration(labelText: "Nome da receita"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Informe o nome";
                  }
                  return null;
                },
                onSaved: (value) => nome = value!,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: "Descrição"),
                onSaved: (value) => descricao = value,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: "Tempo de preparo (min)"),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                tempoPreparo = double.tryParse(value ?? ""),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text("Usar como insumo"),
                value: usarComoInsumo,
                onChanged: (val) {
                  setState(() {
                    usarComoInsumo = val;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration:
                const InputDecoration(labelText: "Validade (dias)"),
                keyboardType: TextInputType.number,
                initialValue: "3",
                onSaved: (value) =>
                validadeDias = int.tryParse(value ?? "3") ?? 3,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration:
                const InputDecoration(labelText: "Quantidade produzida"),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                quantidadeProduzida = double.tryParse(value ?? ""),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration:
                const InputDecoration(labelText: "Unidade produzida"),
                onSaved: (value) => unidade = value,
              ),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tags:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: todasTags.map((tag) {
                        final selected = tags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: selected,
                          onSelected: (bool value) {
                            setState(() {
                              if (value) {
                                tags.add(tag);
                              } else {
                                tags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    TextButton.icon(
                      onPressed: _abrirDialogNovaTag,
                      icon: const Icon(Icons.add),
                      label: const Text("Nova Tag"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _escolherImagem,
                child: const Text("Escolher Imagem"),
              ),
              if (imagemPath != null) ...[
                const SizedBox(height: 8),
                Image.file(
                  File(imagemPath!),
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _abrirDialogoNovoIngrediente,
                child: const Text("Adicionar Ingrediente"),
              ),
              if (ingredientes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  "Ingredientes adicionados:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...ingredientes.map(
                      (ing) {
                    final insumo = insumoBox.get(ing.idInsumo);
                    final nomeInsumo = insumo?.nome ??
                        ing.nomeInsumo ??
                        '⚠ Insumo não encontrado';
                    final unidadeInsumo =
                        insumo?.unidadeMedida ?? ing.unidade ?? '';

                    return ListTile(
                      title: Text(nomeInsumo),
                      subtitle: Text(
                          '${ing.opcional ? "Opcional - " : ""}${ing.quantidade} $unidadeInsumo'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            ingredientes.remove(ing);
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _salvarReceita,
                child: const Text("Salvar Receita"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _escolherImagem() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imagemPath = picked.path;
      });
    }
  }

  void _abrirDialogNovaTag() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nova Tag"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nome da Tag"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final novaTag = controller.text.trim();
              if (novaTag.isNotEmpty && !todasTags.contains(novaTag)) {
                setState(() {
                  todasTags.add(novaTag);
                  tags.add(novaTag);
                  tagsBox.put('tags', todasTags);
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Adicionar"),
          )
        ],
      ),
    );
  }
  void _abrirDialogoNovoIngrediente() {
    String? insumoSelecionadoId;
    final quantidadeController = TextEditingController();
    final unidadeController = TextEditingController();

    final insumos = insumoBox.values.toList();

    print("[DEBUG] Itens carregados do Hive para dropdown:");
    for (var insumo in insumos) {
      print("ID: ${insumo.id}, Nome: ${insumo.nome}");
    }
    String? dropdownValue;
    final insumosOrdenados = [...insumos]
      ..sort((a, b) => a.nome.compareTo(b.nome));

    for (var entry in insumoBox.toMap().entries) {
      print("KEY NO HIVE: ${entry.key} → NOME: ${entry.value.nome}");
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Adicionar Ingrediente"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  DropdownButtonFormField<String>(
                    value: dropdownValue,
                    decoration: const InputDecoration(labelText: "Insumo"),
                    items: insumosOrdenados
                        .map(
                          (i) => DropdownMenuItem(
                        value: i.id,
                        child: Text(i.nome),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        dropdownValue = value;
                        insumoSelecionadoId = value;

                        print('>> Selecionou insumo ID: $value');

                        final insumo = insumoBox.get(value);

                        if (insumo == null) {
                          print('⚠ insumoBox.get($value) retornou NULL!');
                        } else {
                          print('✅ Encontrado insumo no Hive: ${insumo.nome}');
                        }

                        unidadeController.text = insumo?.unidadeMedida ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: quantidadeController,
                    decoration:
                    const InputDecoration(labelText: "Quantidade"),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                  ),
                  if (unidadeController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: unidadeController,
                      decoration:
                      const InputDecoration(labelText: "Unidade"),
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
                    final insumo =
                    insumoBox.get(insumoSelecionadoId);
                    if (insumo == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text("Erro: insumo não existe mais."),
                        ),
                      );
                      return;
                    }

                    final novo = IngredientesReceita(
                      idInsumo: insumoSelecionadoId!,
                      nomeInsumo: insumo.nome,
                      quantidade:
                      double.tryParse(quantidadeController.text) ?? 0,
                      unidade: unidadeController.text,
                      opcional: false,
                    );

                    setState(() {
                      ingredientes.removeWhere(
                              (i) => i.idInsumo == novo.idInsumo);
                      ingredientes.add(novo);
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


  void _salvarReceita() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    print('>>> Salvando receita: $nome');
    for (var ing in ingredientes) {
      print('   idInsumo: ${ing.idInsumo}');
      print('   nomeInsumo: ${ing.nomeInsumo}');
      print('   quantidade: ${ing.quantidade}');
      print('   unidade: ${ing.unidade}');
    }

    final receitaBox = Hive.box<Receita>('receitas');

    final receita = Receita(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      descricao: descricao,
      tempoPreparo: tempoPreparo,
      ingredientes: ingredientes.map((ing) {
        final insumo = insumoBox.get(ing.idInsumo);

        return IngredientesReceita(
          idInsumo: ing.idInsumo,
          nomeInsumo: insumo?.nome ?? ing.nomeInsumo,
          quantidade: ing.quantidade,
          unidade: insumo?.unidadeMedida ?? ing.unidade ?? '',
          opcional: ing.opcional,
          valorUnitario: insumo?.valorUnitario ?? 0.0,
        );
      }).toList(),

      usarComoInsumo: usarComoInsumo,
      tags: tags,
      validadeDias: validadeDias,
      imagemPath: imagemPath,
      quantidadeProduzida: quantidadeProduzida,
      unidade: unidade,
    );
    receita.calcularCustos(insumoBox);

    await receitaBox.put(receita.id, receita);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Receita salva!")),
    );

    Navigator.pop(context);
  }
}