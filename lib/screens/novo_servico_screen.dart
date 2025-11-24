import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/servico.dart';

class NovoServicoScreen extends StatefulWidget {
  final String predioId;

  const NovoServicoScreen({
    super.key,
    required this.predioId,
  });

  @override
  State<NovoServicoScreen> createState() => _NovoServicoScreenState();
}

class _NovoServicoScreenState extends State<NovoServicoScreen> {
  final _formKey = GlobalKey<FormState>();

  String? nome;
  String? descricao;
  double valor = 0.0;
  bool recorrente = false;
  String? frequencia;
  DateTime? dataVencimento;
  String? linkDocumento;

  final _dataController = TextEditingController();

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  void _salvarServico() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final servicoBox = Hive.box<Servico>('servicos');

    final novoServico = Servico(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome ?? '',
      descricao: descricao,
      valor: valor,
      recorrente: recorrente,
      frequencia: recorrente ? frequencia : null,
      dataVencimento: dataVencimento,
      status: "pendente",
      predioId: widget.predioId,
      linkDocumento: linkDocumento,
    );

    await servicoBox.put(novoServico.id, novoServico);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Serviço cadastrado com sucesso!')),
    );

    Navigator.pop(context, novoServico);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Serviço')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome do serviço'),
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Informe o nome' : null,
                onSaved: (value) => nome = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                onSaved: (value) => descricao = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor';
                  }
                  final v = double.tryParse(value.replaceAll(',', '.'));
                  if (v == null || v < 0) {
                    return 'Valor inválido';
                  }
                  return null;
                },
                onSaved: (value) {
                  valor = double.tryParse(value!.replaceAll(',', '.')) ?? 0.0;
                },
              ),
              SwitchListTile(
                title: const Text('É recorrente?'),
                value: recorrente,
                onChanged: (val) => setState(() => recorrente = val),
              ),
              if (recorrente)
                TextFormField(
                  decoration:
                  const InputDecoration(labelText: 'Frequência (ex.: Mensal)'),
                  onSaved: (value) => frequencia = value,
                ),
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Data de vencimento'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      dataVencimento = picked;
                      _dataController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                    });
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Link documento (opcional)'),
                onSaved: (value) => linkDocumento = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarServico,
                child: const Text('Salvar Serviço'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}