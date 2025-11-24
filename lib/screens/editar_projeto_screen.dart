import 'package:cidade_da_vida/models/recurso.dart';
import 'package:cidade_da_vida/models/recurso_alocado.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/projeto.dart';
import '../widgets/selecionar_recurso_modal.dart';
import '../utils/recursos_utils.dart';
import 'novo_recurso_screen.dart';

class EditarProjetoScreen extends StatefulWidget {
  final Projeto projeto;
  final List<Recurso> recursosDoPredio;
  final Function(Projeto) onAtualizar;
  final String nomeDoPredio;

  const EditarProjetoScreen({
    super.key,
    required this.projeto,
    required this.onAtualizar,
    required this.recursosDoPredio,
    required this.nomeDoPredio,
  });

  @override
  State<EditarProjetoScreen> createState() => _EditarProjetoScreenState();
}

class _EditarProjetoScreenState extends State<EditarProjetoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String nome;
  late String categoria;
  late String descricao;
  late String corHex;
  late double orcamento;
  late DateTime? prazoFinal;
  late List<RecursoAlocado> recursosAlocados;
  late List<String> contatos;
  late double horasGastas;
  late String licoes;
  late List<String> conquistas;

  final _contatoController = TextEditingController();
  final _conquistaController = TextEditingController();

  final List<String> categorias = [
    'Cozinha', 'Horta', 'Moradia', 'Espiritual', 'Financas',
    'Escola', 'Lazer', 'Ateliê', 'Família e amigos', 'Workshop', 'Hospital', 'Prefeitura'
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.projeto;
    nome = p.nome;
    categoria = p.categoria;
    descricao = p.descricao;
    corHex = p.corHex;
    orcamento = p.orcamento ?? 0;
    prazoFinal = p.prazoFinal;
    recursosAlocados = List.from(p.recursosAlocados ?? []);
    contatos = List.from(p.contatosUteis ?? []);
    horasGastas = p.horasGastas ?? 0;
    licoes = p.licoesAprendidas ?? '';
    conquistas = List.from(p.conquistas ?? []);
  }

  Future<double?> _solicitarQuantidade(BuildContext context, Recurso recurso) async {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quantidade de ${recurso.nome}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Quantidade desejada'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final qtd = double.tryParse(controller.text);
              if (qtd != null && qtd > 0) {
                Navigator.pop(context, qtd);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Informe uma quantidade válida')),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _mostrarSnackBar(String mensagem) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Projeto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: nome,
                decoration: const InputDecoration(labelText: 'Nome do projeto'),
                onChanged: (value) => nome = value,
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              DropdownButtonFormField(
                value: categoria,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) => setState(() => categoria = value!),
              ),
              TextFormField(
                initialValue: descricao,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                onChanged: (value) => descricao = value,
              ),
              TextFormField(
                initialValue: orcamento.toString(),
                decoration: const InputDecoration(labelText: 'Orçamento (R\$)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => orcamento = double.tryParse(v) ?? 0,
              ),
              ListTile(
                title: Text(prazoFinal == null ? 'Escolher prazo' : 'Prazo: ${prazoFinal!.day}/${prazoFinal!.month}/${prazoFinal!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final data = await showDatePicker(
                    context: context,
                    initialDate: prazoFinal ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (data != null) setState(() => prazoFinal = data);
                },
              ),
              const Text('Recursos do projeto:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final recursoSelecionado = await showDialog<Recurso>(
                    context: context,
                    builder: (context) => SelecionarRecursoModal(
                      recursosDisponiveis: widget.recursosDoPredio,
                      predioAtual: widget.nomeDoPredio,
                      onSelecionar: (recurso, quantidade) {
                        recurso.quantidadeDisponivel = quantidade;
                        Navigator.pop(context, recurso);
                      },
                      onNovoRecurso: () async {
                        final novo = await Navigator.push<Recurso?>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NovoRecursoScreen(
                              predioAtual: categoria,
                              onSalvar: (r) => Navigator.of(context, rootNavigator: true).pop(r),
                            ),
                          ),
                        );

                        if (novo != null) {
                          setState(() {
                            widget.recursosDoPredio.add(novo);
                          });
                          _mostrarSnackBar('Recurso cadastrado com sucesso!');
                        }
                      },
                    ),
                  );

                  if (recursoSelecionado != null) {
                    final quantidadeDesejada = await _solicitarQuantidade(context, recursoSelecionado);
                    if (quantidadeDesejada != null) {
                      await alocarRecursoParaProjeto(
                        recursoSelecionado,
                        widget.projeto.id,
                        quantidadeDesejada,
                      );

                      setState(() {
                        recursosAlocados.add(
                          RecursoAlocado(
                            recursoId: recursoSelecionado.id,
                            quantidade: quantidadeDesejada,
                          ),
                        );
                      });
                      _mostrarSnackBar('Recurso adicionado ao projeto!');
                    }
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Adicionar recurso'),
              ),
              const SizedBox(height: 8),
              if (recursosAlocados.isEmpty)
                const Text('Nenhum recurso adicionado ainda.')
              else
                Wrap(
                  spacing: 8,
                  children: recursosAlocados.map((r) {
                    final recursoOriginal = widget.recursosDoPredio.firstWhere(
                          (re) => re.id == r.recursoId,
                      orElse: () => Recurso.vazio(),
                    );

                    return Chip(
                      label: Text('${recursoOriginal.nome} (${r.quantidade} x R\$ ${recursoOriginal.valorUnitario.toStringAsFixed(2)})'),
                      onDeleted: () => setState(() => recursosAlocados.remove(r)),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              const Text('Contatos úteis:'),
              Row(
                children: [
                  Expanded(child: TextField(controller: _contatoController)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_contatoController.text.trim().isNotEmpty) {
                        setState(() {
                          contatos.add(_contatoController.text.trim());
                          _contatoController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: contatos.map((c) => Chip(label: Text(c))).toList(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: horasGastas.toString(),
                decoration: const InputDecoration(labelText: 'Horas gastas'),
                keyboardType: TextInputType.number,
                onChanged: (v) => horasGastas = double.tryParse(v) ?? 0,
              ),
              TextFormField(
                initialValue: licoes,
                decoration: const InputDecoration(labelText: 'Lições aprendidas'),
                maxLines: 3,
                onChanged: (v) => licoes = v,
              ),
              const SizedBox(height: 12),
              const Text('Conquistas:'),
              Row(
                children: [
                  Expanded(child: TextField(controller: _conquistaController)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_conquistaController.text.trim().isNotEmpty) {
                        setState(() {
                          conquistas.add(_conquistaController.text.trim());
                          _conquistaController.clear();
                        });
                      }
                    },
                  )
                ],
              ),
              Wrap(
                spacing: 8,
                children: conquistas.map((c) => Chip(label: Text(c))).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Salvar alterações'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final atualizado = Projeto(
                      id: widget.projeto.id,
                      nome: nome,
                      categoria: categoria,
                      descricao: descricao,
                      corHex: corHex,
                      orcamento: orcamento,
                      prazoFinal: prazoFinal,
                      recursosAlocados: recursosAlocados,
                      contatosUteis: contatos,
                      horasGastas: horasGastas,
                      licoesAprendidas: licoes,
                      conquistas: conquistas,
                      arquivado: widget.projeto.arquivado ?? false,
                    );

                    final box = await Hive.openBox<Projeto>('projetos');
                    final index = box.values.toList().indexWhere((p) => p.id == widget.projeto.id);
                    if (index != -1) {
                      await box.putAt(index, atualizado);
                      widget.onAtualizar(atualizado);
                      _mostrarSnackBar('Projeto atualizado com sucesso!');
                    }

                    if (mounted) Navigator.pop(context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
