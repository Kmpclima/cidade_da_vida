import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/insumo.dart';
import '../models/compra.dart';
import 'package:uuid/uuid.dart';
import 'package:cidade_da_vida/screens/carrossel_compras_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ListaComprasScreen extends StatefulWidget {
  const ListaComprasScreen({super.key});

  @override
  State<ListaComprasScreen> createState() => _ListaComprasScreenState();
}

class _ListaComprasScreenState extends State<ListaComprasScreen> {
  late Box<Insumo> insumoBox;
  Set<String> insumosJaComprados = {};
  Map<String, TextEditingController> valorControllers = {};
  Map<String, TextEditingController> qtdControllers = {};

  @override
  void initState() {
    super.initState();
    insumoBox = Hive.box<Insumo>('insumos');

    // Inicializa controllers para insumos existentes
    for (var insumo in insumoBox.values) {
      valorControllers[insumo.id] = TextEditingController(
        text: insumo.valorUnitario.toString(),
      );
      qtdControllers[insumo.id] = TextEditingController(
        text: (insumo.quantidadeSolicitada ?? 0).toString(),
      );
    }
  }

  @override
  void dispose() {
    for (var c in valorControllers.values) {
      c.dispose();
    }
    for (var c in qtdControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _gerarCompra() async {
    final insumosSelecionados = insumoBox.values
        .where((i) => i.marcadoParaCompra)
        .toList();

    if (insumosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum item marcado para compra!'),
        ),
      );
      return;
    }

    final compra = Compra(
      id: const Uuid().v4(),
      dataCompra: DateTime.now(),
      listaInsumos: insumosSelecionados.map((i) => {
        'id': i.id,
        'nome': i.nome,
      }).toList(),
      valorEstimado: insumosSelecionados.fold(0.0, (total, i) {
        return total +
            ((i.valorUnitario) * (i.quantidadeSolicitada ?? 0));
      }),
    );

    final compraBox = Hive.box<Compra>('compras');
    compraBox.put(compra.id, compra);

    for (var insumo in insumosSelecionados) {
      insumo.status = 'aguardando compra';
      insumo.marcadoParaCompra = false;
      await insumo.save();
    }

    // Esse trecho é só debug seu; pode manter ou não:
    for (var insumo in insumosSelecionados) {
      insumosJaComprados.add(insumo.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Compra gerada com sucesso! Valor estimado: R\$ ${compra.valorEstimado.toStringAsFixed(2)}',
        ),
      ),
    );

    setState(() {});
  }
  void _confirmarGeracaoCompra() {
    final insumosSelecionados = insumoBox.values
        .where((i) => i.marcadoParaCompra)
        .toList();

    double subtotal = insumosSelecionados.fold(0.0, (total, i) {
      return total +
          ((i.valorUnitario) * (i.quantidadeSolicitada ?? 0));
    });

    if (insumosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum item marcado para compra!'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Geração de Compra'),
          content: Text(
              'Deseja realmente gerar esta compra?\n\nSubtotal estimado: R\$ ${subtotal.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
              ),
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                _gerarCompra();
              },
            ),
          ],
        );
      },
    );
  }

  void _abrirModalAdicionarItem(BuildContext context) {
    final insumos = insumoBox.values.toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));

    String? insumoSelecionadoId;
    final qtdController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Escolha o Insumo',
                  border: OutlineInputBorder(),
                ),
                items: insumos.map((i) {
                  return DropdownMenuItem<String>(
                    value: i.id,
                    child: Text(i.nome),
                  );
                }).toList(),
                onChanged: (value) {
                  insumoSelecionadoId = value;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtdController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Qtd. desejada',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700),
                onPressed: () async {
                  if (insumoSelecionadoId != null) {
                    final insumo =
                    insumoBox.get(insumoSelecionadoId!);

                    if (insumo != null) {
                      insumo.estaNaListaCompras = true;
                      insumo.quantidadeSolicitada =
                          double.tryParse(qtdController.text) ?? 0;
                      insumo.marcadoParaCompra = false;
                      await insumo.save();

                      // inicializa controllers para o novo insumo
                      valorControllers[insumo.id] = TextEditingController(
                        text: insumo.valorUnitario.toString(),
                      );
                      qtdControllers[insumo.id] = TextEditingController(
                        text: (insumo.quantidadeSolicitada ?? 0).toString(),
                      );
                    }

                    Navigator.pop(context);
                    setState(() {});
                  }
                },
                child: const Text('Salvar'),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final insumosParaCompra = insumoBox.values.where((insumo) {
      return insumo.estaNaListaCompras == true ||
          insumo.quantidadeDisponivel <= insumo.quantidadeMinima;
    }).toList();

    insumosParaCompra.sort((a, b) {
      if (a.marcadoParaCompra == b.marcadoParaCompra) {
        return a.nome.compareTo(b.nome);
      } else if (a.marcadoParaCompra) {
        return -1;
      } else {
        return 1;
      }
    });

    double subtotal = insumosParaCompra
        .where((i) => i.marcadoParaCompra)
        .fold(0.0, (total, i) {
      return total +
          ((i.valorUnitario) * (i.quantidadeSolicitada ?? 0));
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras Genérica'),
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Minhas Compras',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConferenciaInsumosScreen(),
                ),
              );
              // Caso queira evitar empilhar múltiplas vezes:
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const CarrosselComprasScreen(),
              //   ),
              // );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: ListView.builder(
              itemCount: insumosParaCompra.length,
              itemBuilder: (context, index) {
                final insumo = insumosParaCompra[index];
                final valorController = valorControllers[insumo.id]!;
                final qtdController = qtdControllers[insumo.id]!;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: insumosJaComprados.contains(insumo.id)
                      ? Colors.amber.shade100
                      : (insumo.marcadoParaCompra
                      ? Colors.green.shade100
                      : Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insumo.nome,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                                'Estoque: ${insumo.quantidadeTotal} ${insumo.unidadeMedida}'),
                            const SizedBox(width: 16),
                            Text('Categoria: ${insumo.categoria}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Flexible(
                              child: TextField(
                                controller: valorController,
                                keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}$'),
                                  ),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Valor Unitário',
                                  border: OutlineInputBorder(),
                                ),
                                onEditingComplete: () async {
                                  setState(() {
                                    insumo.valorUnitario =
                                        double.tryParse(
                                            valorController.text.replaceAll(',', '.')
                                        ) ??
                                            insumo.valorUnitario;

                                  });
                                  await insumo.save();
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: TextField(
                                controller: qtdController,
                                keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Qtd. a Comprar',
                                  border: OutlineInputBorder(),
                                ),
                                onEditingComplete: () async {
                                  setState(() {
                                    insumo.quantidadeSolicitada =
                                        double.tryParse(qtdController.text) ?? 0;

                                  });
                                  await insumo.save();
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Checkbox(
                              value: insumo.marcadoParaCompra,
                              onChanged: (value) async {
                                setState(() {
                                  insumo.marcadoParaCompra = value ?? false;
                                });
                                await insumo.save();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Text(
                'Subtotal: R\$ ${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: Colors.teal.shade700,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 10,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Adicionar Item',
            backgroundColor: Colors.orange,
            onTap: () {
              _abrirModalAdicionarItem(context);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.shopping_cart),
            label: 'Gerar Compra',
            backgroundColor: Colors.teal.shade700,
            onTap: () {
              _confirmarGeracaoCompra();
            },
          ),
        ],
      ),
    );
  }
}