import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/recurso.dart';
import '../models/predio.dart';
import 'package:collection/collection.dart';

class InventarioCentralScreen extends StatefulWidget {
  const InventarioCentralScreen({super.key});

  @override
  State<InventarioCentralScreen> createState() => _InventarioCentralScreenState();
}

class _InventarioCentralScreenState extends State<InventarioCentralScreen> {
  RecursoStatus? filtroStatus;
  String? filtroPredio;

  final List<String> categoriasOrdenadas = [
    'Ateliê',
    'Cozinha',
    'Escola',
    'Espiritual',
    'Família e amigos',
    'Financas',
    'Hospital',
    'Horta',
    'Lazer',
    'Moradia',
    'Prefeitura',
    'Workshop'
  ];

  @override
  Widget build(BuildContext context) {
    final recursoBox = Hive.box<Recurso>('recursos');
    final predioBox = Hive.box<Predio>('predios');

    final recursosFiltrados = recursoBox.values
        .where((recurso) {
      bool okStatus = true;
      bool okPredio = true;

      if (filtroStatus != null) {
        okStatus = recurso.status == filtroStatus;
      }

      if (filtroPredio != null) {
        okPredio = recurso.prediosVinculados.contains(filtroPredio);
      }

      return okStatus && okPredio;
    })
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventário Central'),
        actions: [
          // Dropdown filtro Status
          DropdownButtonHideUnderline(
            child: DropdownButton<RecursoStatus>(
              value: filtroStatus,
              hint: const Text(
                "Filtrar Status",
                style: TextStyle(color: Colors.white),
              ),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              items: [
                const DropdownMenuItem<RecursoStatus>(
                  value: null,
                  child: Text("Todos"),
                ),
                ...RecursoStatus.values.map(
                      (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  ),
                )
              ],
              onChanged: (novoStatus) {
                setState(() {
                  filtroStatus = novoStatus;
                });
              },
            ),
          ),

          // Dropdown filtro Prédio
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: filtroPredio,
              hint: const Text(
                "Filtrar Prédio",
                style: TextStyle(color: Colors.white),
              ),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.location_city, color: Colors.white),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text("Todos"),
                ),
                ...categoriasOrdenadas.map(
                      (categoria) => DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  ),
                )
              ],
              onChanged: (novoPredio) {
                setState(() {
                  filtroPredio = novoPredio;
                });
              },
            ),
          ),
        ],
      ),
      body: recursosFiltrados.isEmpty
          ? const Center(
        child: Text("Nenhum recurso encontrado com o filtro atual."),
      )
          : ListView.builder(
        itemCount: recursosFiltrados.length,
        itemBuilder: (context, index) {
          final recurso = recursosFiltrados[index];

          final nomesPredios = recurso.prediosVinculados
              .map((categoriaPredio) {
            final predio = predioBox.values
                .firstWhereOrNull((p) => p.categoria == categoriaPredio);
            return predio?.nome ?? categoriaPredio;
          }).toList()
            ..sort();

          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome + botão lápis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recurso.nome,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          abrirModalEdicao(
                            context,
                            recurso,
                            categoriasOrdenadas,
                                () => setState(() {}),
                          );
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text('ID: ${recurso.id}'),
                  Text('Descrição: ${recurso.descricao ?? ""}'),
                  Text(
                      'Valor unitário: R\$ ${recurso.valorUnitario.toStringAsFixed(2)}'),
                  Text(
                      'Prédios vinculados: ${nomesPredios.isNotEmpty ? nomesPredios.join(", ") : "nenhum"}'),

                  const SizedBox(height: 8),

                  // Dropdown inline - Status
                  Row(
                    children: [
                      const Text(
                        "Status:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<RecursoStatus>(
                        value: recurso.status,
                        items: RecursoStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status.toString().split('.').last,
                            ),
                          );
                        }).toList(),
                        onChanged: (novoStatus) async {
                          recurso.status = novoStatus!;
                          await recurso.save();
                          setState(() {});
                        },
                      )
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Dropdown inline - Prédio (single-select)
                  Row(
                    children: [
                      const Text(
                        "Prédio:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: recurso.prediosVinculados.isNotEmpty
                            ? recurso.prediosVinculados.first
                            : null,
                        hint: const Text("Selecionar prédio"),
                        items: categoriasOrdenadas.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (novaCategoria) async {
                          recurso.prediosVinculados = [novaCategoria!];
                          recurso.estaNaPrefeitura =
                              novaCategoria == "Prefeitura";
                          await recurso.save();
                          setState(() {});
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void abrirModalEdicao(
      BuildContext context,
      Recurso recurso,
      List<String> categorias,
      VoidCallback onClose,
      ) {
    final TextEditingController nomeController =
    TextEditingController(text: recurso.nome);
    final TextEditingController unidadeController =
    TextEditingController(text: recurso.unidade);
    final TextEditingController descricaoController =
    TextEditingController(text: recurso.descricao ?? '');
    final TextEditingController origemController =
    TextEditingController(text: recurso.origem ?? '');
    final TextEditingController valorUnitarioController =
    TextEditingController(text: recurso.valorUnitario.toString());
    final TextEditingController valorVendaController =
    TextEditingController(text: recurso.valorVenda?.toString() ?? '');
    final TextEditingController qtdTotalController =
    TextEditingController(text: recurso.quantidadeTotal.toString());
    final TextEditingController qtdDisponivelController =
    TextEditingController(text: recurso.quantidadeDisponivel.toString());

    RecursoStatus statusSelecionado = recurso.status;
    bool compartilhavel = recurso.compartilhavel;
    List<String> prediosSelecionados =
    List<String>.from(recurso.prediosVinculados);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Editar Recurso",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),

                TextField(
                  controller: unidadeController,
                  decoration: const InputDecoration(labelText: "Unidade"),
                ),

                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(labelText: "Descrição"),
                ),

                TextField(
                  controller: origemController,
                  decoration: const InputDecoration(labelText: "Origem"),
                ),

                TextField(
                  controller: valorUnitarioController,
                  keyboardType: TextInputType.number,
                  decoration:
                  const InputDecoration(labelText: "Valor Unitário (R\$)"),
                ),

                TextField(
                  controller: valorVendaController,
                  keyboardType: TextInputType.number,
                  decoration:
                  const InputDecoration(labelText: "Valor Venda (R\$)"),
                ),

                TextField(
                  controller: qtdTotalController,
                  keyboardType: TextInputType.number,
                  decoration:
                  const InputDecoration(labelText: "Quantidade Total"),
                ),

                TextField(
                  controller: qtdDisponivelController,
                  keyboardType: TextInputType.number,
                  decoration:
                  const InputDecoration(labelText: "Quantidade Disponível"),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Text("Compartilhável"),
                    Switch(
                      value: compartilhavel,
                      onChanged: (val) {
                        compartilhavel = val;
                      },
                    )
                  ],
                ),

                DropdownButtonFormField<RecursoStatus>(
                  value: statusSelecionado,
                  decoration: const InputDecoration(labelText: "Status"),
                  items: RecursoStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (novoStatus) {
                    if (novoStatus != null) {
                      statusSelecionado = novoStatus;
                    }
                  },
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categorias.map((cat) {
                    final selecionado =
                    prediosSelecionados.contains(cat);
                    return FilterChip(
                      label: Text(cat),
                      selected: selecionado,
                      onSelected: (val) {
                        if (val) {
                          prediosSelecionados.add(cat);
                        } else {
                          prediosSelecionados.remove(cat);
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text("Excluir"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Confirmar exclusão"),
                            content: const Text(
                                "Tem certeza que deseja excluir este recurso?"),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancelar")),
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text("Excluir")),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await recurso.delete();
                          onClose();
                          Navigator.pop(context);
                        }
                      },
                    ),

                    ElevatedButton(
                      child: const Text("Salvar"),
                      onPressed: () async {
                        recurso.nome = nomeController.text;
                        recurso.unidade = unidadeController.text;
                        recurso.descricao =
                        descricaoController.text.isNotEmpty
                            ? descricaoController.text
                            : null;
                        recurso.origem = origemController.text.isNotEmpty
                            ? origemController.text
                            : null;
                        recurso.valorUnitario =
                            double.tryParse(valorUnitarioController.text) ?? 0;
                        recurso.valorVenda =
                            double.tryParse(valorVendaController.text);
                        recurso.quantidadeTotal =
                            double.tryParse(qtdTotalController.text) ?? 0;
                        recurso.quantidadeDisponivel =
                            double.tryParse(qtdDisponivelController.text) ?? 0;
                        recurso.compartilhavel = compartilhavel;
                        recurso.status = statusSelecionado;
                        recurso.prediosVinculados = prediosSelecionados;
                        recurso.estaNaPrefeitura =
                            prediosSelecionados.contains("Prefeitura");

                        await recurso.save();
                        onClose();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}