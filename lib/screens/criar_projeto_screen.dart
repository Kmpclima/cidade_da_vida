import 'package:flutter/material.dart';
import '../models/projeto.dart';
import 'package:uuid/uuid.dart';
import '../models/recurso.dart';
import 'novo_recurso_screen.dart';
import '../models/recurso_alocado.dart';
import 'package:hive/hive.dart';
import '../widgets/selecionar_recurso_modal.dart';
import 'nova_demanda_screen.dart';

class NovoProjetoScreen extends StatefulWidget {
  final Function(Projeto) onSalvar;

  const NovoProjetoScreen({super.key, required this.onSalvar});

  @override
  State<NovoProjetoScreen> createState() => _NovoProjetoScreenState();
}

class _NovoProjetoScreenState extends State<NovoProjetoScreen> {
  final _formKey = GlobalKey<FormState>();

  String nome = '';
  String categoria = 'Cozinha';
  String descricao = '';
  String corHex = '#FFA726';
  double orcamento = 0;
  DateTime? prazoFinal;
  List<RecursoAlocado> recursosAlocados = [];
  List<String> contatos = [];
  double horasGastas = 0;
  String licoes = '';
  List<String> conquistas = [];

  final _contatoController = TextEditingController();
  final _conquistaController = TextEditingController();
  final List<String> categorias = [
    'Cozinha', 'Horta', 'Moradia', 'Espiritual', 'Finanças',
    'Escola', 'Lazer', 'Ateliê', 'Família e amigos', 'Workshop', 'Hospital', 'Prefeitura'
  ];

  @override
  Widget build(BuildContext context) {//construção da tela de cadastro
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Projeto')), //título da tela
      body: Padding(
        padding: const EdgeInsets.all(16), //margens
        child: Form( //início da construção do formulário
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(//cria um campo de input de texto para o nome do Projeto
                decoration: const InputDecoration(labelText: 'Nome do projeto'),
                onChanged: (value) => nome = value, //ao editar o campo, substitui a variável nome pelo que foi digitado
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              DropdownButtonFormField( //lista de categorias
                value: categoria,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) => setState(() => categoria = value!),//coloca a opção escolhida dentro da variável categoria
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                onChanged: (value) => descricao = value,//define o campo descrição a partir do input
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Orçamento (R\$)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => orcamento = double.tryParse(v) ?? 0, //define o orçamento a partir do input, passando para double
                ),
                ListTile(
                  title: Text(prazoFinal == null ? 'Escolher prazo' : 'Prazo: ${prazoFinal!.day}/${prazoFinal!.month}/${prazoFinal!.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(), //define os critérios para a exibição do Picker
                      lastDate: DateTime(2100),
                    );
                    if (data != null) setState(() => prazoFinal = data);//define a data escolhida como prazo final
                  },
                ),

                //RECURSOS

                const Text('Recursos:'),

                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Selecionar recurso existente'), //configuração do botão
                  onPressed: () async {
                    final boxRecursos = await Hive.openBox<Recurso>('recursos');//espera o Hive abrir a box de recursos
                    final recursosDoPredio = boxRecursos.values
                        .where((r) => r.projetosVinculados.contains(categoria)) //traz apenas os recursos do predio
                        .toList();

                    final resultado = await showDialog<Map<String, dynamic>>(//essa parte abre o modal para escolher o recurso
                      context: context,
                      builder: (context) => SelecionarRecursoModal(
                        predioAtual: categoria,
                        recursosDisponiveis: recursosDoPredio,
                        onSelecionar: (recurso, quantidade) {
                          Navigator.pop(context, {
                            'recurso': recurso,
                            'quantidade': quantidade,
                          });
                        },
                        onNovoRecurso: ()  {
                        },
                      ),
                    );

                    if (resultado != null && resultado['recurso' != null]) {//se o usuário selecionar algum recurso ele vai voltar para a tela anterior trazendo o recurso e a quantidade
                      final recurso = resultado['recurso'] as Recurso;
                      final quantidade = resultado['quantidade'] as double;

                      setState(() {
                        recursosAlocados.add(
                          RecursoAlocado(
                            recursoId: recurso.id,
                            quantidade: quantidade,
                          ),
                        );
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Recurso "${recurso.nome}" adicionado.')),
                      );
                    }
                  },
                ),


                FutureBuilder(
                  future: Hive.openBox<Recurso>('recursos'),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final box = snapshot.data as Box<Recurso>;

                    return Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: recursosAlocados.map((rAlocado) {
                        final recurso = box.get(rAlocado.recursoId);
                        if (recurso == null) return const SizedBox();

                        return InputChip(
                          label: Text('${recurso.nome} (${rAlocado.quantidade} ${recurso.unidade}) - R\$ ${recurso.valorUnitario.toStringAsFixed(2) ?? "0.00"}'),
                          avatar: Tooltip(
                            message: 'Status: ${recurso.status.name}',
                            child: Icon(
                              Icons.circle,
                              size: 12,
                              color: () {
                                switch (recurso.status) {
                                  case RecursoStatus.pendente:
                                    return Colors.orange;
                                  default:
                                    return Colors.grey;
                                }
                              }(),
                            ),
                          ),
                          onDeleted: () {
                            setState(() {
                              recursosAlocados.remove(rAlocado);
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 12),

                const Text('Contatos úteis:'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(controller: _contatoController),
                    ),
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
                  decoration: const InputDecoration(labelText: 'Horas gastas'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => horasGastas = double.tryParse(v) ?? 0,
                ),
                TextFormField(
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

                //DINAMICA PARA SALVAR O PROJETO:

              ElevatedButton(
                child: const Text('Salvar Projeto'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final novoProjeto = Projeto(
                        id: const Uuid().v4(),
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
                        arquivado: false,
                      );

                      final box = await Hive.openBox<Projeto>('projetos');//abre a box dos projetos para salvar
                      //await box.add(novoProjeto);

                      ScaffoldMessenger.of(context).showSnackBar(//notificação caso de certo
                        SnackBar(content: Text('Projeto "${novoProjeto.nome}" salvo com sucesso!')),
                      );

                      widget.onSalvar(novoProjeto);
                      Navigator.pop(context, novoProjeto);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(//notificacao caso de erro interno
                        SnackBar(content: Text('Erro ao salvar projeto: $e'), backgroundColor: Colors.red),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(//notificacao caso nao passe pela validacao
                      const SnackBar(content: Text('Preencha todos os campos obrigatórios.')),
                    );
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
