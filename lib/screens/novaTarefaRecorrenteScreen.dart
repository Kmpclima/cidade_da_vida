import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/tarefaRecorrente.dart';
import '../models/projeto.dart';
import '../models/insumo.dart';
import '../models/tarefa.dart';
import '../utils/data_utils.dart';
import 'package:uuid/uuid.dart';

class NovaTarefaRecorrenteScreen extends StatefulWidget {
  const NovaTarefaRecorrenteScreen({super.key});

  @override
  State<NovaTarefaRecorrenteScreen> createState() => _NovaTarefaRecorrenteScreenState();
}

class _NovaTarefaRecorrenteScreenState extends State<NovaTarefaRecorrenteScreen> {
  final _formKey = GlobalKey<FormState>();

  late Box<TarefaRecorrente> tarefaRecorrenteBox;
  late Box<Projeto> projetoBox;
  late Box<Insumo> insumoBox;
  late Box<Tarefa> tarefaBox;

  String? nome;
  String? categoria;
  String status = 'normal';
  Projeto? projetoSelecionado;
  bool gerarNoDiaAtual = true;
  int intervaloDiasSelecionado = 7;
  int xp = 0, conhecimento = 0, criatividade = 0, estamina = 0, conexao = 0, espiritualidade = 0, energiaVital = 0;
  int? tempoEstimadoMinutos;

  List<Projeto> projetos = [];
  List<Map<String, dynamic>> _insumosSelecionados = [];

  @override
  void initState() {
    super.initState();
    tarefaRecorrenteBox = Hive.box<TarefaRecorrente>('tarefasRecorrentes');
    projetoBox = Hive.box<Projeto>('projetos');
    insumoBox = Hive.box<Insumo>('insumos');
    tarefaBox = Hive.box<Tarefa>('tarefas');
  }

  List<String> getCategoriasDisponiveis() {
    return projetoBox.values.map((p) => p.categoria).toSet().toList();
  }

  List<Projeto> getProjetosDaCategoria() {
    return projetoBox.values.where((p) => p.categoria == categoria).toList();
  }

  void salvarTarefaRecorrente() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final insumos = _insumosSelecionados.map((e) => e['insumo'] as Insumo).toList();

    final novaTarefaRecorrente = TarefaRecorrente(
      nome: nome!,
      categoria: categoria!,
      status: status,
      xp: xp,
      ativa: true,
      dataInicio: DateTime.now(),
      intervaloDias: intervaloDiasSelecionado,
      gerarNoDiaAtual: gerarNoDiaAtual,
      conhecimento: conhecimento,
      criatividade: criatividade,
      estamina: estamina,
      conexao: conexao,
      espiritualidade: espiritualidade,
      energiaVital: energiaVital,
      insumos: insumos,
      encerrar: false,
      ultimaExecucao: gerarNoDiaAtual ? DateTime.now() : null,
      dataCriacao: DateTime.now(),
      tempoEstimadoMinutos: tempoEstimadoMinutos,
      projeto: projetoSelecionado!,
    );

    await tarefaRecorrenteBox.add(novaTarefaRecorrente);

    if (gerarNoDiaAtual) {
      final novaTarefa = Tarefa(
        id: const Uuid().v4(),
        nome: novaTarefaRecorrente.nome,
        categoria: novaTarefaRecorrente.categoria,
        status: novaTarefaRecorrente.status,
        xp: novaTarefaRecorrente.xp,
        conhecimento: novaTarefaRecorrente.conhecimento,
        criatividade: novaTarefaRecorrente.criatividade,
        estamina: novaTarefaRecorrente.estamina,
        conexao: novaTarefaRecorrente.conexao,
        espiritualidade: novaTarefaRecorrente.espiritualidade,
        energiaVital: novaTarefaRecorrente.energiaVital,
        dataFinal: DateTime.now(),
        concluida: false,
        dataCriacao: DateTime.now(),
        projetoId: novaTarefaRecorrente.projeto.id,
        kanbanColumn: KanbanColumn.TO_DO,
        tempoEstimadoMinutos: novaTarefaRecorrente.tempoEstimadoMinutos,
        tempoGastoMinutos: novaTarefaRecorrente.tempoEstimadoMinutos,
        //insumos: insumos,
      );

      await tarefaBox.add(novaTarefa);
    }

    Navigator.pop(context);
  }

  void _abrirModalSelecionarInsumo(BuildContext context) {
    Insumo? insumoSelecionado;
    double quantidade = 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecionar Insumo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Insumo>(
                value: null,
                items: insumoBox.values.map((i) {
                  return DropdownMenuItem(
                    value: i,
                    child: Text(i.nome),
                  );
                }).toList(),
                onChanged: (value) => insumoSelecionado = value,
                decoration: const InputDecoration(labelText: 'Insumo'),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                onChanged: (value) => quantidade = double.tryParse(value) ?? 1,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (insumoSelecionado != null) {
                  setState(() {
                    _insumosSelecionados.add({
                      'insumo': insumoSelecionado!,
                      'quantidade': quantidade,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = getCategoriasDisponiveis();
    final projetos = getProjetosDaCategoria();

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Tarefa Recorrente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome'),
                onSaved: (val) => nome = val,
                validator: (val) => val == null || val.isEmpty ? 'Informe um nome' : null,
              ),
              DropdownButtonFormField<String>(
                value: categoria,
                items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => categoria = val),
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              DropdownButtonFormField<Projeto>(
                value: projetoSelecionado,
                items: projetos
                    .map<DropdownMenuItem<Projeto>>((p) => DropdownMenuItem<Projeto>(value: p, child: Text(p.nome)))
                    .toList(),
                onChanged: (val) => setState(() => projetoSelecionado = val),
                decoration: const InputDecoration(labelText: 'Projeto'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'XP'),
                keyboardType: TextInputType.number,
                onSaved: (val) => xp = int.tryParse(val ?? '0') ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tempo estimado (minutos)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => tempoEstimadoMinutos = int.tryParse(val ?? '0') ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Intervalo em dias'),
                keyboardType: TextInputType.number,
                onSaved: (val) => intervaloDiasSelecionado = int.tryParse(val ?? '1') ?? 1,
              ),

              const SizedBox(height: 16),
              Text('Insumos:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._insumosSelecionados.map((item) => ListTile(
                title: Text('${item['insumo'].nome}'),
                subtitle: Text('Qtd: ${item['quantidade']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _insumosSelecionados.remove(item);
                    });
                  },
                ),
              )),

              TextButton.icon(
                onPressed: () => _abrirModalSelecionarInsumo(context),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Insumo'),
              ),
              SwitchListTile(
                title: const Text('Gerar tarefa hoje?'),
                value: gerarNoDiaAtual,
                onChanged: (val) => setState(() => gerarNoDiaAtual = val),
              ),
              const SizedBox(height: 16),
              const Text('Pontos adicionais'),
              ...[
                ['Conhecimento', conhecimento],
                ['Criatividade', criatividade],
                ['Estamina', estamina],
                ['Conexão', conexao],
                ['Espiritualidade', espiritualidade],
                ['Energia Vital', energiaVital],
              ].map((ponto) {
                return TextFormField(
                  decoration: InputDecoration(labelText: ponto[0] as String),
                  keyboardType: TextInputType.number,
                  onSaved: (val) {
                    final valor = int.tryParse(val ?? '0') ?? 0;
                    switch (ponto[0]) {
                      case 'Conhecimento': conhecimento = valor; break;
                      case 'Criatividade': criatividade = valor; break;
                      case 'Estamina': estamina = valor; break;
                      case 'Conexão': conexao = valor; break;
                      case 'Espiritualidade': espiritualidade = valor; break;
                      case 'Energia Vital': energiaVital = valor; break;
                    }
                  },
                );
              }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: salvarTarefaRecorrente,
                child: const Text('Salvar Tarefa Recorrente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
