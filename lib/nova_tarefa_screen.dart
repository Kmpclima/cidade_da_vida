import 'package:flutter/material.dart';
import 'tarefa_manager.dart';
import 'models/tarefa.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'models/projeto.dart';
import 'package:uuid/uuid.dart';

class NovaTarefaScreen extends StatefulWidget {
  const NovaTarefaScreen({super.key});

  @override
  State<NovaTarefaScreen> createState() => _NovaTarefaScreenState();
}

class _NovaTarefaScreenState extends State<NovaTarefaScreen> {
  final _formKey = GlobalKey<FormState>();

  String nome = '';
  String categoria = 'Escola';
  String status = 'Normal';
  int xp = 0;
  int conhecimento = 0;
  int criatividade = 0;
  int estamina = 0;
  int conexao = 0;
  int espiritualidade = 0;
  int energiaVital = 0;
  int tempoEstimadoMinutos = 0;

  bool temDataFinal = false;
  DateTime? dataFinal;

  Projeto? projetoSelecionado;
  List<Projeto> projetos = [];

  final List<String> categorias = [
    'Escola',
    'Prefeitura',
    'Hospital',
    'Cozinha',
    'Espiritual',
    'Finanças',
    'Moradia',
    'Família e amigos',
    'Lazer',
    'Ateliê',
    'Horta',
    'Workshop',
  ];

  final List<String> statusList = [
    'Urgente',
    'Normal',
    'Em espera',
   // 'Congelado',
   // 'Boost',
  ];

  @override
  void initState() {
    super.initState();
   // _carregarProjetos();
  }


  @override
  Widget build(BuildContext context) {
    final projetoBox = Hive.box<Projeto>('projetos');

    final projetos = categoria == null
        ? <Projeto>[]
        : projetoBox.values
        .where((p) => p.categoria == categoria)
        .toList();
    final tarefaManager = Provider.of<TarefaManager>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Tarefa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição da tarefa'),
                onChanged: (value) => setState(() => nome = value),
                validator: (value) => value == null || value.isEmpty ? 'Informe a tarefa' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: 'Categoria'),
                value: categoria,
                items: categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) => setState(() => categoria = value.toString()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Projeto>(
                decoration: const InputDecoration(labelText: 'Projeto (opcional)'),
                value: projetoSelecionado,
                items: projetos.map((proj) {
                  return DropdownMenuItem(
                    value: proj,
                    child: Text(proj.nome),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    projetoSelecionado = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: status,
                items: statusList.map((stat) {
                  return DropdownMenuItem(
                    value: stat,
                    child: Text(stat),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    status = value ?? 'Normal';
                  });
                },
              ),

              const SizedBox(height: 16),

              _buildNumberField('XP', (v) => xp = v),
              _buildNumberField('Conhecimento', (v) => conhecimento = v),
              _buildNumberField('Criatividade', (v) => criatividade = v),
              _buildNumberField('Estamina', (v) => estamina = v),
              _buildNumberField('Conexão', (v) => conexao = v),
              _buildNumberField('Espiritualidade', (v) => espiritualidade = v),
              _buildNumberField('Energia Vital', (v) => energiaVital = v),
              _buildNumberField('Tempo estimado (minutos)', (v)=> tempoEstimadoMinutos = v ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: temDataFinal,
                    onChanged: (value) => setState(() => temDataFinal = value ?? false),
                  ),
                  const Text('Incluir data final'),
                ],
              ),
              if (temDataFinal)
                ListTile(
                  title: Text(dataFinal == null
                      ? 'Escolher data'
                      : 'Data: ${dataFinal!.day}/${dataFinal!.month}/${dataFinal!.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final dataEscolhida = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (dataEscolhida != null) {
                      setState(() => dataFinal = dataEscolhida);
                    }
                  },
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final nova = Tarefa(
                      id: const Uuid().v4(),
                      nome: nome,
                      categoria: categoria,
                      status: status,
                      kanbanColumn: KanbanColumn.TO_DO,
                      xp: xp,
                      conhecimento: conhecimento,
                      criatividade: criatividade,
                      estamina: estamina,
                      conexao: conexao,
                      espiritualidade: espiritualidade,
                      energiaVital: energiaVital,
                      dataFinal: temDataFinal ? dataFinal : null,
                      projetoId: projetoSelecionado?.id,
                      dataCriacao: DateTime.now(),
                      tempoEstimadoMinutos: tempoEstimadoMinutos,
                    );
                    await tarefaManager.adicionar(nova);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar Tarefa'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, Function(int) onSaved) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      onChanged: (value) => onSaved(int.tryParse(value) ?? 0),
    );
  }
}