import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/insumo.dart';
import 'package:cidade_da_vida/models/receita.dart';
import 'package:cidade_da_vida/utils/receita_utils.dart';

class EditarInsumosScreen extends StatefulWidget {
  const EditarInsumosScreen({super.key});

  @override
  State<EditarInsumosScreen> createState() => _EditarInsumosScreenState();
}

class _EditarInsumosScreenState extends State<EditarInsumosScreen> {
  late Box<Insumo> insumoBox;
  late Box<Receita> receitasBox;

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
    'Mercearia',
  ];

  final List<String> predios = [
    'Cozinha',
    'Moradia',
    'Horta',
    'Ateliê',
    'Prefeitura',
    'Escola',
    'Espiritual',
    'Workshop',
    'Lazer',
    'Financas',
    'Família e amigos',
    'Hospital',
  ];

  final List<String> unidades = [
    'kg',
    'g',
    'un',
    'litros',
    'ml',
    'pacote',
    'vidro',
    'lata'
  ];

  final List<String> statusInsumoList = [
    'Bom',
    'Para vencer',
    'Vencido',
    'Estragado',
    'Baixo estoque',
    'Acabou',
  ];

  @override
  void initState() {
    super.initState();
    insumoBox = Hive.box<Insumo>('insumos');
    receitasBox = Hive.box<Receita>('receitas');
  }

  void _igualarEstoques() async {
    int count = 0;

    for (final insumo in insumoBox.values) {
      if (insumo.quantidadeTotal > 0 &&
          insumo.quantidadeTotal != insumo.quantidadeDisponivel) {
        insumo.quantidadeDisponivel = insumo.quantidadeTotal;
        await insumo.save();
        count++;
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
        count > 0
            ? '✅ Estoques igualados em $count insumo(s).'
            : 'Nenhum insumo precisava ser ajustado.',
      )),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final insumos = insumoBox.values.toList()
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Insumos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Igualar estoques',
            onPressed: _igualarEstoques,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: insumos.length,
        itemBuilder: (context, index) {
          final insumo = insumos[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(insumo.nome),
              subtitle: Text(
                  "${insumo.quantidadeTotal} ${insumo.unidadeMedida} • ${insumo.categoria}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _abrirEdicaoInsumo(insumo);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmarExclusao(insumo);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _abrirEdicaoInsumo(Insumo insumo) {
    final nomeController = TextEditingController(text: insumo.nome);
    final quantidadeController = TextEditingController(
        text: insumo.quantidadeTotal.toString());
    final disponivelController = TextEditingController(
        text: insumo.quantidadeDisponivel.toString());
    final minimoController = TextEditingController(
        text: insumo.quantidadeMinima.toString());
    final valorController = TextEditingController(
        text: insumo.valorUnitario.toString());

    String? categoria =
    categorias.contains(insumo.categoria) ? insumo.categoria : null;
    String? unidade =
    unidades.contains(insumo.unidadeMedida) ? insumo.unidadeMedida : null;
    String? status =
    statusInsumoList.contains(insumo.status) ? insumo.status : null;
    List<String> prediosSelecionados = List.from(insumo.prediosVinculados);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Insumo'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),
                TextField(
                  controller: quantidadeController,
                  decoration:
                  const InputDecoration(labelText: "Quantidade Total"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: disponivelController,
                  decoration:
                  const InputDecoration(labelText: "Disponível"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: minimoController,
                  decoration:
                  const InputDecoration(labelText: "Qtd. Mínima"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: valorController,
                  decoration:
                  const InputDecoration(labelText: "Valor Unitário"),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: categoria,
                  items: categorias
                      .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  ))
                      .toList(),
                  onChanged: (val) => categoria = val,
                  decoration:
                  const InputDecoration(labelText: "Categoria"),
                ),
                DropdownButtonFormField<String>(
                  value: unidade,
                  items: unidades
                      .map((u) => DropdownMenuItem(
                    value: u,
                    child: Text(u),
                  ))
                      .toList(),
                  onChanged: (val) => unidade = val,
                  decoration:
                  const InputDecoration(labelText: "Unidade"),
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  items: statusInsumoList
                      .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  ))
                      .toList(),
                  onChanged: (val) => status = val,
                  decoration:
                  const InputDecoration(labelText: "Status"),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Prédios vinculados",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: predios.map((p) {
                    return FilterChip(
                      label: Text(p),
                      selected: prediosSelecionados.contains(p),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            prediosSelecionados.add(p);
                          } else {
                            prediosSelecionados.remove(p);
                          }
                        });
                      },
                    );
                  }).toList(),
                )
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
                insumo.nome = nomeController.text;
                insumo.quantidadeTotal =
                    double.tryParse(quantidadeController.text) ?? 0;
                insumo.quantidadeDisponivel =
                    double.tryParse(disponivelController.text) ?? 0;
                insumo.quantidadeMinima =
                    double.tryParse(minimoController.text) ?? 0;
                insumo.valorUnitario =
                    double.tryParse(valorController.text) ?? 0;
                insumo.categoria = categoria ?? '';
                insumo.unidadeMedida = unidade ?? '';
                insumo.status = status ?? '';
                insumo.prediosVinculados = prediosSelecionados;

                await insumo.save();
                await recalcularCustosDeTodasAsReceitas(receitasBox, insumoBox);

                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Insumo salvo com sucesso!")),
                );
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }
  void _confirmarExclusao(Insumo insumo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Insumo"),
        content: Text("Deseja excluir o insumo '${insumo.nome}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await insumo.delete();
              if (!mounted) return;
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Insumo excluído.")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Excluir"),
          )
        ],
      ),
    );
  }
}