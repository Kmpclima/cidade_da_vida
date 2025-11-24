import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/demanda.dart';
import '../models/recurso.dart';
import '../models/projeto.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NovaDemandaScreen extends StatefulWidget {
  final String predioAtual;


  const NovaDemandaScreen({
    super.key,
    required this.predioAtual
  });

  @override
  State<NovaDemandaScreen> createState() => _NovaDemandaScreenState();

}

class _NovaDemandaScreenState extends State<NovaDemandaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Campos do formulário
  String? nomeRecurso;
  String? descricao;
  String? link;
  Projeto? projetoSelecionado;
  double quantidadeSolicitada = 1;
  bool urgente = false;
  double? valorUnitario = 0.0;
  File? imagemSelecionada;
  String? unidade;
  List<String>predioVinculado = [];

  DateTime? dataUrgente;
  final _dataUrgenteController = TextEditingController();

  late Box<Projeto> projetoBox;
  late Box<Demanda> demandaBox;
  late Box<Recurso> recursoBox;

  @override
  void initState() {
    super.initState();
    projetoBox = Hive.box<Projeto>('projetos');
    demandaBox = Hive.box<Demanda>('demandas');
    recursoBox = Hive.box<Recurso>('recursos');
  }
  void _salvarNovaDemanda() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    // Gera um ID novo para o recurso
    final novoRecurso = Recurso(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nomeRecurso ??'',
      descricao: descricao ?? '',
      quantidadeTotal: 0,
      unidade: unidade??'',
      valorUnitario: valorUnitario ?? 0.0,
      quantidadeDisponivel: 0,
      estaNaPrefeitura: true,
      compartilhavel: false,
      status: RecursoStatus.aguardandoAprovacao,
      valorVenda: valorUnitario ?? 0.0,
      prediosVinculados: [widget.predioAtual],
      projetosVinculados: projetoSelecionado != null
          ? [projetoSelecionado!.nome]
          : [],
      historicoCompras: [],
      pathImagem: imagemSelecionada?.path,
    );

    final novaDemanda = Demanda(
      recursoId: novoRecurso.id,
      quantidadeSolicitada: quantidadeSolicitada,
      status: 'aguardandoAprovacao',
      dataSolicitacao: DateTime.now(),
      urgente: urgente,
      projetoSolicitante: projetoSelecionado?.nome ?? 'Desconhecido',
      descricao: descricao,
      link: link,
      valorUnitario: valorUnitario ?? 0.0,
      prazo: dataUrgente,
    );

    // salva o recurso antes de salvar a demanda
    await recursoBox.put(novoRecurso.id, novoRecurso);

    await demandaBox.add(novaDemanda);


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demanda criada com sucesso!')),
    );

    Navigator.pop(context, novaDemanda);
  }

  @override
  Widget build(BuildContext context) {
    final projetos = projetoBox.values
        .where((p) => p.categoria == widget.predioAtual)
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Demanda')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Prédio vinculado: ${widget.predioAtual}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),


              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome do recurso'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome do recurso';
                  }
                  return null;
                },
                onSaved: (value) => nomeRecurso = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                onSaved: (value) => descricao = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Link (opcional)'),
                onSaved: (value) => link = value,
              ),
              DropdownButtonFormField<Projeto>(
                decoration: const InputDecoration(labelText: 'Projeto solicitante'),
                items: projetos
                    .map(
                      (p) => DropdownMenuItem(
                    value: p,
                    child: Text(p.nome),
                  ),
                )
                    .toList(),
                onChanged: (p) => setState(() => projetoSelecionado = p),
                validator: (value) =>
                value == null ? 'Selecione um projeto' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quantidade solicitada'),
                initialValue: '1',
                keyboardType: TextInputType.number,
                onSaved: (value) => quantidadeSolicitada =
                    double.tryParse(value ?? '1') ?? 1,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Unidade (ex.: kg, m, L)'),
                onSaved: (value) => unidade = value,
              ),
              TextFormField(
                decoration:
                const InputDecoration(labelText: 'Valor unitário (opcional)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  valorUnitario =
                      double.tryParse(value?.replaceAll(',', '.') ?? '') ?? 0.0;
                },
              ),
              SwitchListTile(
                value: urgente,
                onChanged: (val) => setState(() => urgente = val),
                title: const Text('Urgente?'),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: Text(
                  imagemSelecionada == null
                      ? 'Selecionar imagem'
                      : 'Imagem selecionada',
                ),
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    setState(() {
                      imagemSelecionada = File(pickedFile.path);
                    });
                  }
                },
              ),
              if (imagemSelecionada != null) ...[
                const SizedBox(height: 16),
                Image.file(
                  imagemSelecionada!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ],
              //CASO SEJA URGENTE A DEMANDA
              if (urgente) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Prazo desejado (data)',
                  ),
                  readOnly: true,
                  controller: _dataUrgenteController,
                  validator: (value) {
                    if (urgente && (value == null || value.isEmpty)) {
                      return 'Informe a data desejada';
                    }
                    return null;
                  },
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dataUrgente = pickedDate;
                        _dataUrgenteController.text =
                        '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';

                      });
                    }
                  },
                ),
              ],
              ElevatedButton(
                onPressed: _salvarNovaDemanda,
                child: const Text('Salvar Demanda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _dataUrgenteController.dispose();
    super.dispose();
  }
}

