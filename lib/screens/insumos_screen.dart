import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/insumo.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cidade_da_vida/models/receita.dart';
import 'package:cidade_da_vida/utils/receita_utils.dart';

class NovoInsumoScreen extends StatefulWidget {
  const NovoInsumoScreen({super.key});

  @override
  State<NovoInsumoScreen> createState() => _NovoInsumoScreenState();
}

class _NovoInsumoScreenState extends State<NovoInsumoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers / variáveis
  final _nomeController = TextEditingController();
  final _quantidadeTotalController = TextEditingController();
  final _quantidadeDisponivelController = TextEditingController();
  final _quantidadeSolicitadaController = TextEditingController();
  final _valorUnitarioController = TextEditingController();
  final _quantidadeMinimaController = TextEditingController();

  DateTime? validade;
  DateTime? dataUltimaCompra;
  String? imagemPath;

  String? categoriaSelecionada;
  String? predioSelecionado;
  String? unidadeSelecionada;
  String? statusSelecionado;

  // Para drop-downs
  final List<String> categorias = [
    'Legumes e verduras',
    'Limpeza',
    'Higiene',
    'Bebidas',
    'Descartáveis',
    'Pet',
    'Frutas',
    'Grãos e cereais',
    'Laticinios',
    'Carnes',
    'Temperos',
    'Mercearia'

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
    'Finanças',
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
    'vidro'
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

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagemPath = pickedFile.path;
      });
    }
  }

  Future<void> _pickDate(Function(DateTime) onDatePicked) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDatePicked(picked);
    }
  }

  void _salvarInsumo() async {
    if (_formKey.currentState!.validate()) {
      final uuid = Uuid();

      final novoInsumo = Insumo(
        id: uuid.v4(),
        nome: _nomeController.text,
        categoria: categoriaSelecionada ?? '',
        quantidadeTotal: double.tryParse(_quantidadeTotalController.text) ?? 0,
        quantidadeDisponivel: double.tryParse(_quantidadeDisponivelController.text) ?? 0,
        quantidadeSolicitada: double.tryParse(_quantidadeSolicitadaController.text) ?? 0,
        unidadeMedida: unidadeSelecionada ?? '',
        valorUnitario: double.tryParse(_valorUnitarioController.text) ?? 0,
        validade: validade,
        imagemPath: imagemPath,
        dataUltimaCompra: dataUltimaCompra,
        status: statusSelecionado ?? '',
        prediosVinculados: predioSelecionado != null ? [predioSelecionado!] : [],
        quantidadeMinima: double.tryParse(_quantidadeMinimaController.text) ?? 0,
        estaNaListaCompras: false,
        marcadoParaCompra: false,
      );

      final box = Hive.box<Insumo>('insumos');
      await box.put(novoInsumo.id, novoInsumo);
      final receitaBox = Hive.box<Receita>('receitas');
      await recalcularCustosDeTodasAsReceitas(receitaBox, box);

      print("✅ Insumo salvo com ID: ${novoInsumo.id}");

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Insumo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
              ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoria'),
                value: categoriaSelecionada,
                items: categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    categoriaSelecionada = value;
                  });
                },
                validator: (value) =>
                value == null || value.isEmpty ? 'Selecione uma categoria' : null,
              ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Prédio vinculado'),
                value: predioSelecionado,
                items: predios
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    predioSelecionado = value;
                  });
                },
                validator: (value) =>
                value == null || value.isEmpty ? 'Selecione o prédio' : null,
              ),

              TextFormField(
                controller: _quantidadeTotalController,
                decoration: const InputDecoration(labelText: 'Quantidade Total'),
                keyboardType: TextInputType.number,
              ),

              TextFormField(
                controller: _quantidadeDisponivelController,
                decoration: const InputDecoration(labelText: 'Quantidade Disponível'),
                keyboardType: TextInputType.number,
              ),

              TextFormField(
                controller: _quantidadeSolicitadaController,
                decoration: const InputDecoration(labelText: 'Quantidade Solicitada'),
                keyboardType: TextInputType.number,
              ),

              TextFormField(
                controller: _quantidadeMinimaController,
                decoration: const InputDecoration(labelText: 'Quantidade Mínima'),
                keyboardType: TextInputType.number,
              ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Unidade de Medida'),
                value: unidadeSelecionada,
                items: unidades
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    unidadeSelecionada = value;
                  });
                },
                validator: (value) =>
                value == null || value.isEmpty ? 'Selecione a unidade' : null,
              ),

              TextFormField(
                controller: _valorUnitarioController,
                decoration: const InputDecoration(labelText: 'Valor Unitário'),
                keyboardType: TextInputType.number,
              ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: statusSelecionado,
                items: statusInsumoList
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    statusSelecionado = value;
                  });
                },
                validator: (value) =>
                value == null || value.isEmpty ? 'Selecione o status' : null,
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickDate((picked) {
                        setState(() {
                          validade = picked;
                        });
                      }),
                      child: Text(validade == null
                          ? 'Selecionar Validade'
                          : 'Validade: ${validade!.day}/${validade!.month}/${validade!.year}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickDate((picked) {
                        setState(() {
                          dataUltimaCompra = picked;
                        });
                      }),
                      child: Text(dataUltimaCompra == null
                          ? 'Última Compra'
                          : 'Compra: ${dataUltimaCompra!.day}/${dataUltimaCompra!.month}/${dataUltimaCompra!.year}'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Selecionar Imagem'),
              ),

              if (imagemPath != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    File(imagemPath!),
                    height: 150,
                  ),
                ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _salvarInsumo,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}