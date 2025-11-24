import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cidade_da_vida/models/recurso.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:cidade_da_vida/models/predio.dart';

class NovoRecursoScreen extends StatefulWidget {
  final Function(Recurso)? onSalvar;
  final String predioAtual;
  final bool permitirEscolherPredio;

  const NovoRecursoScreen({
    super.key,
    this.onSalvar,
    required this.predioAtual,
    this.permitirEscolherPredio = false,
  });

  @override
  State<NovoRecursoScreen> createState() => _NovoRecursoScreenState();
}

class _NovoRecursoScreenState extends State<NovoRecursoScreen> {
  final _formKey = GlobalKey<FormState>();

  String nome = '';
  double quantidadeTotal = 1;
  double quantidadeDisponivel = 0;
  String unidade = '';
  double valor = 0;
  String origem = 'existente';
  String? descricao = '';
  String? pathImagem;
  DateTime? dataUltimaCompra;
  List<DateTime> historicoCompras = [];
  double? valorVenda;
  List<String> projetosVinculados = ['NenhumProjeto'];
  bool estaNaPrefeitura = true;
  RecursoStatus status = RecursoStatus.pendente;
  bool compartilhavel = false;
  List<String> prediosVinculados = [];
  String? predioSelecionado;

  final _descricaoController = TextEditingController();

  final List<String> opcoesOrigem = ['existente', 'doação', 'compra'];

  @override
  void initState() {
    super.initState();

    if (!widget.permitirEscolherPredio) {
      predioSelecionado = widget.predioAtual;
    }
  }

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        pathImagem = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final predioBox = Hive.box<Predio>('predios');
    final listaPredios = predioBox.values.map((p) => p.nome).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Recurso')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (widget.permitirEscolherPredio) ...[
                DropdownButtonFormField<String>(
                  value: predioSelecionado,
                  decoration: const InputDecoration(labelText: 'Selecione o prédio'),
                  items: listaPredios
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      predioSelecionado = value;
                    });
                  },
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Selecione um prédio' : null,
                ),
              ],
              TextFormField(
                decoration:
                const InputDecoration(labelText: 'Nome do recurso'),
                onChanged: (value) => nome = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              DropdownButtonFormField(
                value: origem,
                decoration: const InputDecoration(labelText: 'Origem'),
                items: opcoesOrigem
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (value) => setState(() => origem = value!),
              ),
              TextFormField(
                decoration:
                const InputDecoration(labelText: 'Quantidade Total'),
                keyboardType: TextInputType.numberWithOptions(),
                onChanged: (v) =>
                quantidadeTotal = double.tryParse(v) ?? 1,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Quantidade disponível'),
                keyboardType: TextInputType.numberWithOptions(),
                onChanged: (v) =>
                quantidadeDisponivel = double.tryParse(v) ?? 1,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Unidade'),
                onChanged: (value) => unidade = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe a unidade' : null,
              ),
              TextFormField(
                decoration:
                const InputDecoration(labelText: 'Valor unitário (R\$)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => valor = double.tryParse(v) ?? 0,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                    labelText: 'Descrição/modelo/manual'),
                maxLines: 2,
                onChanged: (v) => descricao = v,
              ),
              ListTile(
                title: Text(dataUltimaCompra == null
                    ? 'Data da última compra'
                    : 'Data da última compra: ${dataUltimaCompra!.day}/${dataUltimaCompra!.month}/${dataUltimaCompra!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final data = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (data != null) {
                    setState(() => dataUltimaCompra = data);
                  }
                },
              ),
              DropdownButtonFormField<RecursoStatus>(
                value: status,
                decoration:
                const InputDecoration(labelText: 'Status do recurso'),
                items: RecursoStatus.values
                    .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.name),
                ))
                    .toList(),
                onChanged: (value) => setState(() => status = value!),
              ),
              SwitchListTile(
                title: const Text('Está na prefeitura?'),
                value: estaNaPrefeitura,
                onChanged: (v) => setState(() => estaNaPrefeitura = v),
              ),
              SwitchListTile(
                title: const Text('É compartilhável?'),
                value: compartilhavel,
                onChanged: (v) => setState(() => compartilhavel = v),
              ),
              const SizedBox(height: 10),
              if (pathImagem != null)
                Image.file(File(pathImagem!), height: 100),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Selecionar imagem'),
                onPressed: _selecionarImagem,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Salvar Recurso'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final List<DateTime> historico = [...historicoCompras];
                    if (dataUltimaCompra != null) {
                      historico.add(dataUltimaCompra!);
                    }

                    final novo = Recurso(
                      id: const Uuid().v4(),
                      nome: nome,
                      quantidadeTotal: quantidadeTotal,
                      unidade: unidade,
                      valorUnitario: valor,
                      origem: origem,
                      descricao: descricao,
                      pathImagem: pathImagem,
                      historicoCompras: historico,
                      valorVenda: valorVenda,
                      projetosVinculados: {
                        ...projetosVinculados,
                        if (!projetosVinculados
                            .contains(predioSelecionado ?? widget.predioAtual))
                          predioSelecionado ?? widget.predioAtual
                      }.toList(),
                      estaNaPrefeitura: estaNaPrefeitura,
                      status: status,
                      compartilhavel: compartilhavel,
                      quantidadeDisponivel: quantidadeDisponivel,
                      prediosVinculados: {
                        ...(prediosVinculados),
                        if (!prediosVinculados
                            .contains(predioSelecionado ?? widget.predioAtual))
                          predioSelecionado ?? widget.predioAtual
                      }.toList(),
                    );

                    try {
                      if (widget.onSalvar != null) {
                        widget.onSalvar!(novo);
                      } else {
                        final box =
                        await Hive.openBox<Recurso>('recursos');
                        await box.put(novo.id, novo);
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Recurso "${novo.nome}" salvo com sucesso!')),
                        );
                        Navigator.pop(context, novo);
                      }
                    } catch (e) {
                      if (mounted) {
                        print('❌ Erro ao salvar recurso: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                              Text('Erro ao salvar recurso: $e')),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}