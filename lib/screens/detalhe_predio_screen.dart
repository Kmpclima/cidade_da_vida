import 'dart:ffi';
import 'package:cidade_da_vida/screens/nova_receita_screen.dart';
import 'package:flutter/material.dart';
import '../tarefa_manager.dart';
import '../models/tarefa.dart';
import '../screens/historico_screen.dart';
import 'package:provider/provider.dart';
import '../models/jogadora_status.dart';
import '../models/projeto.dart';
import '../models/recurso.dart';
import '../screens/novo_recurso_screen.dart';
import '../screens/novo_servico_screen.dart';
import '../controllers/audio_controller.dart';
import '../screens/detalhe_projeto_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/recursos_utils.dart';
import '../models/predio.dart';
import '../models/servico.dart';
import '../models/demanda.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cidade_da_vida/screens/ajustes_avancados_screen.dart';
import 'package:cidade_da_vida/screens/livro_receitas_screen.dart';
import 'package:cidade_da_vida/screens/cardapio_screen.dart';
import 'package:cidade_da_vida/controllers/cardapio_manager.dart';
import 'package:cidade_da_vida/models/cardapio.dart';
import 'package:cidade_da_vida/utils/data_utils.dart';
import '../animations/animations_manager.dart';
import 'package:cidade_da_vida/models/lista_geral.dart';
import 'package:cidade_da_vida/screens/listasScreen.dart';

class DetalhePredioScreen extends StatefulWidget {
  final String nome;
  final TarefaManager tarefaManager;
  final List<Projeto> todosProjetos;

  const DetalhePredioScreen({
    super.key,
    required this.nome,
    required this.tarefaManager,
    required this.todosProjetos,
  });

  @override
  State<DetalhePredioScreen> createState() => _DetalhePredioScreenState();
}

class _DetalhePredioScreenState extends State<DetalhePredioScreen> {
  Predio? predio;

  String _fmtData(DateTime? d) {
    if (d == null) return 'Sem data';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  bool mostrarAnimacaoTarefaConcluida = false;

  @override
  void initState() {
    super.initState();
    arquivarServicosPagosAntigos();
  }

  void _exibirAnimacaoTarefaConcluida() {
    setState(() {
      mostrarAnimacaoTarefaConcluida = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          mostrarAnimacaoTarefaConcluida = false;
        });
      }
    });
  }
  DateTime _hoje0h() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  Future<void> _editarServicoDialog(Servico s) async {
    final nomeCtrl  = TextEditingController(text: s.nome);
    final valorCtrl = TextEditingController(text: s.valor.toStringAsFixed(2));
    DateTime? venc  = s.dataVencimento;
    String status   = s.status ?? 'pendente';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar serviço'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: valorCtrl,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Vencimento:  '),
                  Text(_fmtData(venc)),                // ✅
                  const SizedBox(width: 8), 
                  TextButton(
                    child: const Text('Alterar')





















































                    ,
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: venc ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        venc = picked;
                        (context as Element).markNeedsBuild();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
                  DropdownMenuItem(value: 'pago',     child: Text('Pago')),
                  DropdownMenuItem(value: 'cancelado',child: Text('Cancelado')),
                ],
                onChanged: (v) => status = v ?? 'pendente',
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              s
                ..nome = nomeCtrl.text.trim().isEmpty ? s.nome : nomeCtrl.text.trim()
                ..valor = double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? s.valor
                ..dataVencimento = venc
                ..status = status;
              await s.save();
              if (mounted) setState(() {});
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Color _corDoServico(Servico s) {
    final pago = (s.status?.toLowerCase() == 'pago');
    if (pago) return Colors.green[200]!;

    final venc = s.dataVencimento;
    if (venc != null && venc.isBefore(_hoje0h())) {
      // vencido e ainda pendente
      return Colors.red[200]!;
    }
    // pendente dentro do prazo
    return Colors.orange[200]!;
  }

  Widget _construirCardServico(Servico s) {
    final venc = s.dataVencimento;
    final dataFmt = _fmtData(s.dataVencimento);

    return Card(
      color: _corDoServico(s),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: InkWell(
        onTap: () async {
          // alterna pago/pendente
          final pago = (s.status?.toLowerCase() == 'pago');
          s.status = pago ? 'pendente' : 'pago';
          await s.save();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(pago
                ? 'Serviço marcado como pendente'
                : 'Serviço marcado como pago')),
          );
          setState(() {});
        },
        child: ListTile(
          title: Text(s.nome),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Valor: R\$ ${s.valor.toStringAsFixed(2)}'),
              Text('Vencimento: $dataFmt'),
              Text('Status: ${s.status ?? 'pendente'}'),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'editar') {
                await _editarServicoDialog(s);
                setState(() {});
              } else if (v == 'excluir') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Excluir serviço'),
                    content: Text('Excluir "${s.nome}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
                    ],
                  ),
                );
                if (ok == true) {
                  await s.delete();
                  if (mounted) setState(() {});
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'editar',  child: Text('Editar')),
              PopupMenuItem(value: 'excluir', child: Text('Excluir')),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    AudioController.tocarEfeito('porta_fechando.mp3');
    super.dispose();
  }

  void _marcarComoPago(Servico servico) async {
    if (predio == null) {
      print('⚠️ Nenhum prédio encontrado!');
      return;
    }
    servico.status = 'pago';
    await servico.save();
    predio!.orcamentoTotal -= servico.valor;
    await predio!.save();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Serviço "${servico.nome}" pago e debitado como pago.')),
    );

    setState(() {});
  }

  void _marcarComoCancelado(Servico servico) async {
    servico.status = 'cancelado';
    await servico.save();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Serviço "${servico.nome}" foi cancelado.')),
    );

    setState(() {});
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.brown.shade700,
            ),
            child: Text(
              'Menu ${widget.nome}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          if (widget.nome == "Cozinha") ...[
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Livro de Receitas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LivroReceitasScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Cardápio da Semana'),
              onTap: () async {
                Navigator.of(context).pop();

                if (!Hive.isBoxOpen('cardapios')) {
                  await Hive.openBox<Cardapio>('cardapios');
                }

                final box = Hive.box<Cardapio>('cardapios');
                final todos = box.values.toList();

                Cardapio? cardapioParaAbrir;

                if (todos.isNotEmpty) {
                  cardapioParaAbrir = todos.last;
                } else {
                  final inicioSemana = ultimoDomingo(DateTime.now());
                  final fimSemana = inicioSemana.add(const Duration(days: 6));

                  final novoCardapio = Cardapio(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    nome: "Semana ${inicioSemana.day}/${inicioSemana.month}",
                    dataInicio: inicioSemana,
                    dataFim: fimSemana,
                    refeicoes: [],
                  );

                  await box.put(novoCardapio.id, novoCardapio);
                  cardapioParaAbrir = novoCardapio;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CardapioScreen(cardapio: cardapioParaAbrir!),
                  ),
                );
              },
            ),
          ],
          // Novo botão Listas
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Listas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListasScreen(predioNome: widget.nome),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Voltar à Cidade'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  void arquivarServicosPagosAntigos() {
    final boxServicos = Hive.box<Servico>('servicos');
    final agora = DateTime.now();

    for (var servico in boxServicos.values) {
      final vencimento = servico.dataVencimento;

      final pago = servico.status == 'pago';

      // Verifica se o vencimento não é nulo e se é de mês anterior ao atual
      if (pago &&
          vencimento != null &&
          vencimento.isBefore(DateTime(agora.year, agora.month, 1))) {
        servico.status = 'arquivado';
        servico.save();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        Hive.isBoxOpen('projetos')
            ? Future.value()
            : Hive.openBox<Projeto>('projetos'),
        Hive.isBoxOpen('recursos')
            ? Future.value()
            : Hive.openBox<Recurso>('recursos'),
        Hive.isBoxOpen('predios')
            ? Future.value()
            : Hive.openBox<Predio>('predios'),
        Hive.isBoxOpen('servicos')
            ? Future.value()
            : Hive.openBox<Servico>('servicos'),
        Hive.isBoxOpen('demandas')
            ? Future.value()
            : Hive.openBox<Demanda>('demandas'),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildConteudoComBoxes();
      },
    );
  }
  Widget _construirConteudoPrincipal(List<Servico> servicosDoPredio) {
    final agora = DateTime.now();
    final inicioDoMes = DateTime(agora.year, agora.month);
    final fimDoMes = DateTime(agora.year, agora.month + 1).subtract(const Duration(days: 1));

    final servicosFiltrados = servicosDoPredio.where((s) {
      if (s.status == "arquivado") return false;
      if (s.dataVencimento == null) return true;
      return s.status != "arquivado" &&
          s.dataVencimento != null &&
          (
              // Está dentro do mês
              (s.dataVencimento!.isAfter(inicioDoMes.subtract(Duration(days: 1))) &&
                  s.dataVencimento!.isBefore(fimDoMes.add(Duration(days: 1))))
                  ||
                  // Está vencido, mas ainda está pendente
                  (s.dataVencimento!.isBefore(inicioDoMes) && s.status == "pendente")
          );
    }).toList();

    if (servicosFiltrados.isEmpty) return const SizedBox(); // ou um Text("Nenhum serviço...")

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16),
          child: Text(
            'Serviços vinculados neste mês:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...servicosFiltrados.map((s) => _construirCardServico(s)).toList(),
      ],
    );
  }

  Widget _buildConteudoComBoxes() {
    final recursoBox = Hive.box<Recurso>('recursos');
    final projetoBox = Hive.box<Projeto>('projetos');
    final predioBox = Hive.box<Predio>('predios');
    final servicoBox = Hive.box<Servico>('servicos');
    final demandaBox = Hive.box<Demanda>('demandas');

    final prediosFiltrados =
    predioBox.values.where((p) => p.nome == widget.nome).toList();

    predio = prediosFiltrados.isNotEmpty ? prediosFiltrados.first : null;

    if (predio == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.nome)),
        body: const Center(
          child: Text('Prédio não encontrado.'),
        ),
      );
    }

    final todosRecursos = recursoBox.values.toList();

    final recursosDoPredio = getRecursosVisiveisParaArea(
      nomeArea: widget.nome,
      todosRecursos: todosRecursos,
    );

    final recursosExternosCompartilhaveis =
    getRecursosCompartilhaveisDisponiveisEmOutrasAreas(
      nomeArea: widget.nome,
      todosRecursos: todosRecursos,
    );

    final servicosDoPredio = servicoBox.values
        .where((s) =>
    s.predioId == predio!.id && s.status != "arquivado")
        .toList();



    final totalDemandas = demandaBox.values.fold<double>(0.0, (prev, d) {
      final recurso = recursoBox.get(d.recursoId);
      if (recurso != null &&
          recurso.prediosVinculados.contains(predio!.categoria) &&
          d.status == "pendente") {
        return prev +
            ((d.quantidadeSolicitada ?? 0) *
                (d.valorUnitario ?? 0.0));
      }
      return prev;
    });

    final totalServicosPendentes = servicosDoPredio
        .where((s) => s.status == "pendente")
        .fold<double>(0.0, (prev, s) => prev + s.valor);

    final saldoDisponivel = predio!.orcamentoTotal;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Detalhes de ${widget.nome}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Buscar recursos externos',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => ListView(
                      children: recursosExternosCompartilhaveis
                          .map((r) => ListTile(
                        title: Text(r.nome),
                        subtitle: Text(
                            '${r.quantidadeDisponivel}/${r.quantidadeTotal} disponíveis'),
                        trailing: const Icon(Icons.construction),
                      ))
                          .toList(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Ver histórico',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoricoScreen(
                        nome: widget.nome,
                        tarefaManager: widget.tarefaManager,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Ajustes Avançados',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AjustesAvancadosScreen(predio: predio!),
                    ),
                  );
                },
              ),
            ],
          ),
          drawer: _buildDrawer(context),
          floatingActionButton: predio!.nome == "Cozinha"
              ? FloatingActionButton.extended(
            onPressed: () async {
              final selected = await showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(1000, 600, 16, 16),
                items: [
                  PopupMenuItem(
                    value: 'nova_receita',
                    child: ListTile(
                      leading: const Icon(Icons.restaurant_menu),
                      title: const Text('Nova Receita'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'novo_servico',
                    child: ListTile(
                      leading: const Icon(Icons.build),
                      title: const Text('Novo Serviço'),
                    ),
                  ),
                ],
              );

              if (selected == 'nova_receita') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NovaReceitaScreen(),
                  ),
                );
              } else if (selected == 'novo_servico') {
                final novoServico = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovoServicoScreen(predioId: predio!.id),
                  ),
                );
                if (novoServico != null) {
                  setState(() {});
                }
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Novo'),
          )
              : FloatingActionButton.extended(
            onPressed: () async {
              final novoServico = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NovoServicoScreen(predioId: predio!.id),
                ),
              );
              if (novoServico != null) {
                setState(() {});
              }
            },
            icon: const Icon(Icons.build),
            label: const Text('Novo Serviço'),
          ),
          body: ValueListenableBuilder(
            valueListenable: widget.tarefaManager.tarefasNotifier,
            builder: (context, List<Tarefa> tarefas, _) {
              final tarefasDoPredio = tarefas
                  .where((t) => t.categoria == widget.nome && !t.concluida)
                  .toList();

              return ValueListenableBuilder(
                valueListenable: projetoBox.listenable(),
                builder: (context, Box<Projeto> box, _) {
                  final projetosDoPredio = box.values
                      .where((p) =>
                  p.categoria == widget.nome &&
                      p.arquivado != true)
                      .toList();

                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          color: Colors.brown.shade200,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Orçamento Total: R\$ ${predio!.orcamentoTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    'Total Demandas Aprovadas: R\$ ${totalDemandas.toStringAsFixed(2)}'),
                                Text(
                                    'Total Serviços Pendentes: R\$ ${totalServicosPendentes.toStringAsFixed(2)}'),
                                Text(
                                  'Saldo Disponível: R\$ ${saldoDisponivel.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: saldoDisponivel >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (totalDemandas > 0 ||
                          totalServicosPendentes > 0 ||
                          saldoDisponivel != 0)
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 50,
                              sections: [
                                if (totalDemandas > 0)
                                  PieChartSectionData(
                                    value: totalDemandas,
                                    color: Colors.blue,
                                    title: 'Demandas',
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (totalServicosPendentes > 0)
                                  PieChartSectionData(
                                    value: totalServicosPendentes,
                                    color: Colors.orange,
                                    title: 'Serviços',
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (saldoDisponivel > 0)
                                  PieChartSectionData(
                                    value: saldoDisponivel,
                                    color: Colors.green,
                                    title: 'Disponível',
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (saldoDisponivel < 0)
                                  PieChartSectionData(
                                    value: saldoDisponivel.abs(),
                                    color: Colors.red,
                                    title: 'Déficit',
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ...projetosDoPredio.map((projeto) {
                        final tarefasDoProjeto = tarefas.where((t) =>
                        t.projetoId == projeto.id &&
                            t.categoria == widget.nome &&
                            !t.concluida).toList();

                        return Card(
                          child: ListTile(
                            title: Text(projeto.nome),
                            subtitle: Text('${tarefasDoProjeto.length} tarefas'),
                            trailing: const Icon(Icons.folder),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetalheProjetoScreen(
                                    projeto: projeto,
                                    nomeDoPredio: widget.nome,
                                    tarefas: tarefas,
                                    tarefaManager: widget.tarefaManager,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                      _construirConteudoPrincipal(servicosDoPredio),
                      if (recursosDoPredio.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 16, top: 16),
                          child: Text(
                            'Recursos vinculados:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...recursosDoPredio.map((r) => ListTile(
                          title: Text(r.nome),
                          subtitle: Text(
                              '${r.quantidadeDisponivel}/${r.quantidadeTotal} disponíveis'),
                          trailing: const Icon(Icons.construction),
                        )),
                      ],
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          'Tarefas avulsas:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...tarefas
                          .where((t) =>
                      t.categoria == widget.nome &&
                          !t.concluida &&
                          t.projetoId == null)
                          .map((tarefa) => ListTile(
                        title: Text(tarefa.nome),
                        subtitle: Text('XP: ${tarefa.xp}'),
                        trailing:
                        const Icon(Icons.check_circle_outline),
                        onTap: () async {
                          final jogadora =
                          Provider.of<JogadoraStatus>(
                              context,
                              listen: false);
                          final foiConcluidaAgora =
                          !tarefa.concluida;
                          final todasTarefas = widget
                              .tarefaManager
                              .tarefasNotifier
                              .value;
                          await widget.tarefaManager
                              .concluirTarefa(
                              tarefa, context);
                          if (foiConcluidaAgora) {
                            jogadora.aplicarTarefa(
                                tarefa, todasTarefas);
                            AudioController.tocarEfeito('tarefa_feita.mp3');
                            _exibirAnimacaoTarefaConcluida();
                          }
                        },
                      )),
                    ],
                  );
                },
              );
            },
          ),
        ),
        if (mostrarAnimacaoTarefaConcluida)
          Center(
            child: AnimationsManager.tarefaConcluida(
              width: 150,
              height: 150,
            ),
          ),
      ],
    );
  }
}