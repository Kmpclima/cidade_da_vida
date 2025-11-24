import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/receita.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/insumo.dart';
import 'package:cidade_da_vida/utils/receita_utils.dart';




class DetalheReceitaScreen extends StatefulWidget {
  final Receita receita;

  const DetalheReceitaScreen({super.key, required this.receita});

  @override
  State<DetalheReceitaScreen> createState() => _DetalheReceitaScreenState();
}

class _DetalheReceitaScreenState extends State<DetalheReceitaScreen> {
  late Box<Insumo> insumoBox;
  late Box tagsBox;

  List<String> todasTags = [];
  List<String> tagsSelecionadas = [];

  @override
  void initState() {
    super.initState();
    insumoBox = Hive.box<Insumo>('insumos');
    tagsBox = Hive.box<List<String>>('tags');

    todasTags = List<String>.from(
        tagsBox.get('tags', defaultValue: <String>[])
    );
    tagsSelecionadas = List<String>.from(widget.receita.tags);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receita.nome),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                todasTags = List<String>.from(tagsBox.get('tags', defaultValue: <String>[]));
              });
              _abrirDialogoEditarReceita();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (widget.receita.imagemPath != null &&
                widget.receita.imagemPath!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.receita.imagemPath!),
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (widget.receita.descricao != null &&
                widget.receita.descricao!.isNotEmpty)
              Text(
                widget.receita.descricao!,
                style: const TextStyle(fontSize: 16),
              ),
            if (widget.receita.tempoPreparo != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Tempo de preparo: ${widget.receita.tempoPreparo} min",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 16),

            if (widget.receita.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: widget.receita.tags
                      .map((tag) => Chip(label: Text(tag)))
                      .toList(),
                ),
              ),
            const Text(
              "Ingredientes:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.receita.ingredientes.map(
                  (ingrediente) {
                final insumo = insumoBox.get(ingrediente.idInsumo);
                final nomeInsumo = insumo?.nome ??
                    ingrediente.nomeInsumo ??
                    "⚠ Insumo não encontrado";

                final unidade = ingrediente.unidade.isNotEmpty
                    ? ingrediente.unidade
                    : (insumo?.unidadeMedida ?? 'unidade');

                return ListTile(
                  title: Text(
                    "${ingrediente.quantidade} $unidade — $nomeInsumo",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editarIngrediente(ingrediente),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removerIngrediente(ingrediente),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
            ElevatedButton.icon(
              onPressed: _abrirDialogoNovoIngrediente,
              icon: const Icon(Icons.add),
              label: const Text("Adicionar Ingrediente"),
            ),
            const SizedBox(height: 16),

// NOVOS CAMPOS
            if (widget.receita.custoTotal != null)
              Text(
                "💰 Custo total: R\$ ${widget.receita.custoTotal!.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            if (widget.receita.custoPorcao != null)
              Text(
                "🍽️ Custo por porção: R\$ ${widget.receita.custoPorcao!.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Marcar como feita"),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/ajuste_producao',
                  arguments: widget.receita,
                );
              },
            )
          ],
        ),
      ),
    );
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
                  tagsSelecionadas.add(novaTag);
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
  void _editarIngrediente(IngredientesReceita ingrediente) {
    final quantidadeController =
    TextEditingController(text: ingrediente.quantidade.toString());
    final unidadeController =
    TextEditingController(text: ingrediente.unidade);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Ingrediente"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantidadeController,
              decoration: const InputDecoration(labelText: "Quantidade"),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
            ),
            TextFormField(
              controller: unidadeController,
              decoration: const InputDecoration(labelText: "Unidade"),
              readOnly: true,
              enabled: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final novaQtd =
                  double.tryParse(quantidadeController.text) ?? 0;

              setState(() {
                ingrediente.quantidade = novaQtd;
              });
              widget.receita.calcularCustos(insumoBox);
              await widget.receita.save();

              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          )
        ],
      ),
    );
  }

  void _removerIngrediente(IngredientesReceita ingrediente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remover Ingrediente"),
        content: const Text("Deseja realmente remover este ingrediente?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                widget.receita.ingredientes.remove(ingrediente);
              });
              widget.receita.calcularCustos(insumoBox);
              await widget.receita.save();
              Navigator.pop(context);
            },
            child: const Text("Remover"),
          )
        ],
      ),
    );
  }
  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return pickedFile.path;
    }
    return null;
  }

  void _abrirDialogoNovoIngrediente() {
    String? insumoSelecionadoId;
    final quantidadeController = TextEditingController();
    final unidadeController = TextEditingController();

    final insumos = insumoBox.values.toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));

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
                    decoration:
                    const InputDecoration(labelText: "Insumo"),
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
                        unidadeController.text =
                            insumo?.unidadeMedida ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: quantidadeController,
                    decoration:
                    const InputDecoration(labelText: "Quantidade"),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
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
                onPressed: () async {
                  if (insumoSelecionadoId != null) {
                    final insumo =
                    insumoBox.get(insumoSelecionadoId);
                    if (insumo == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Erro: insumo não existe mais.")),
                      );
                      return;
                    }

                    final novo = IngredientesReceita(
                      idInsumo: insumoSelecionadoId!,
                      nomeInsumo: insumo.nome,
                      quantidade:
                      double.tryParse(quantidadeController.text) ??
                          0,
                      unidade: unidadeController.text,
                      opcional: false,
                    );

                    setState(() {
                      widget.receita.ingredientes.removeWhere(
                              (i) => i.idInsumo == novo.idInsumo);
                      widget.receita.ingredientes.add(novo);
                    });
                    widget.receita.calcularCustos(insumoBox);
                    await widget.receita.save();
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

  void _abrirDialogoEditarReceita() {
    final nomeController = TextEditingController(text: widget.receita.nome);
    final descricaoController =
    TextEditingController(text: widget.receita.descricao);
    final tempoController = TextEditingController(
        text: widget.receita.tempoPreparo?.toString() ?? '');
    final imagemController =
    TextEditingController(text: widget.receita.imagemPath ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Receita"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(
                    labelText: "Descrição / Modo de Preparo",
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: tempoController,
                  decoration: const InputDecoration(labelText: "Tempo de Preparo (min)"),
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: imagemController,
                  decoration: const InputDecoration(labelText: "Caminho da Imagem"),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final novoPath = await _pickImage();
                    if (novoPath != null) {
                      setState(() {
                        imagemController.text = novoPath;
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text("Selecionar Imagem"),
                ),
                const SizedBox(height: 16),
                // ---- AQUI COMEÇA O BLOCO DAS TAGS ----
                const Text(
                  "Tags:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: todasTags.map((tag) {
                    final selected = tagsSelecionadas.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: selected,
                      onSelected: (bool value) {
                        setState(() {
                          if (value) {
                            if (!tagsSelecionadas.contains(tag)) {
                              tagsSelecionadas.add(tag);
                            }
                          } else {
                            tagsSelecionadas.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _abrirDialogNovaTag,
                  icon: const Icon(Icons.add),
                  label: const Text("Nova Tag"),
                ),
                // ---- AQUI TERMINA O BLOCO DAS TAGS ----
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
                setState(() {
                  widget.receita.nome = nomeController.text.trim();
                  widget.receita.descricao = descricaoController.text.trim().isEmpty
                      ? null
                      : descricaoController.text.trim();
                  widget.receita.tempoPreparo =
                      double.tryParse(tempoController.text.trim());
                  widget.receita.imagemPath = imagemController.text.trim().isEmpty
                      ? null
                      : imagemController.text.trim();
                  widget.receita.tags = List.from(tagsSelecionadas);
                });

                widget.receita.calcularCustos(insumoBox);
                await widget.receita.save();

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Receita atualizada!")),
                );
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _simularSelecaoImagem() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "/caminho/da/nova/imagem.png";
  }

}