import 'package:cidade_da_vida/tarefa_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'app/cidade_da_vida_app.dart';
import 'models/tarefa.dart';
import 'models/jogadora_status.dart';
import 'models/jogadora_status_adapter.dart';
import 'models/projeto.dart';
import 'models/recurso.dart';
import 'models/recurso_alocado.dart';
import 'models/demanda.dart';
import 'models/predio.dart';
import 'models/predio_habilidade.dart';
import 'models/servico.dart';
import 'models/insumo.dart';
import 'models/compra.dart';
import 'models/receita.dart';
import 'models/cardapio.dart';
import 'models/receita_preparada.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'projeto_manager.dart';
import 'recursosManager.dart';
import 'utils/data_utils.dart';
import 'utils/receita_utils.dart';
import 'utils/migrations.dart';
import 'models/kanban_historico.dart';
import 'models/kanban_historico_task.dart';
import 'screens/kanban_screen.dart';
import 'models/tesouraria.dart';
import 'models/distribuicao_orcamentaria.dart';
import 'models/entrada_financeira.dart';
import 'models/tarefaRecorrente.dart';
import 'models/lista_geral.dart';
import 'models/peca_tabuleiro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();

  // Cria a pasta DadosCidadeDaVida dentro de Documents
  final hiveDir = Directory('${dir.path}/DadosCidadeDaVida');
  if (!await hiveDir.exists()) {
    await hiveDir.create(recursive: true);
  }

  Hive.init(hiveDir.path);

  print("👉 Hive salvará dados em: ${hiveDir.path}");

  await Hive.initFlutter();

  _registerAdapters();

  // -----------------------
  // ABERTURA DAS BOXES
  // -----------------------
  final predioBox = await Hive.openBox<Predio>('predios');
  await salvarPrediosIniciais(predioBox);

  final receitasBox = await Hive.openBox<Receita>('receitas');
  final statusBox = await Hive.openBox<JogadoraStatusHive>('jogadora_status');
  final tarefaBox = await Hive.openBox<Tarefa>('tarefas');
  final servicoBox = await Hive.openBox<Servico>('servicos');
  final recursoBox = await Hive.openBox<Recurso>('recursos');
  final configBox = await Hive.openBox('configuracoes');
  final insumoBox = await Hive.openBox<Insumo>('insumos');
  final projetoBox = await Hive.openBox<Projeto>('projetos');
  final demandaBox = await Hive.openBox<Demanda>('demandas');
  final comprasBox = await Hive.openBox<Compra>('compras');
  await Hive.openBox<ReceitaPreparada>('receitasPreparadas');
  await Hive.openBox<Cardapio>('cardapios');
  await Hive.openBox<KanbanHistorico>('kanban_historico');
  await Hive.openBox<KanbanHistoricoTask>('kanban_historico_tasks');
  await Hive.openBox<ListaGeral>('listas');
  await Hive.openBox<PecaTabuleiro>('pecas_tabuleiro');
  final boxTesouraria = await Hive.openBox<Tesouraria>('tesouraria');
  final boxRecorrentes = await Hive.openBox<TarefaRecorrente>('tarefasRecorrentes');


  // -----------------------
  // MIGRAÇÕES E AJUSTES
  // -----------------------
  await migrarChavesInsumosParaUuid(insumoBox);
  await recalcularCustosDeTodasAsReceitas(receitasBox, insumoBox);
  await migrarTarefasAntigas();
 // await corrigirTarefasKanban(); // <<< aqui

  // -----------------------
  // MANAGERS
  // -----------------------
  final tarefaManager = TarefaManager(tarefaBox);
  final projetoManager = ProjetoManager(projetoBox);
  final recursoManager = RecursoManager(recursoBox);
  if (!Hive.isBoxOpen('tags')) {
    await Hive.openBox<List<String>>('tags');
  }

  // -----------------------
  // INICIALIZAÇÕES
  // -----------------------

// inicializa caso não exista ainda
  if (boxTesouraria.isEmpty) {
    final tesouraria = Tesouraria(saldoAtual: 0.0, entradas: [], distribuicoes: []);
    await boxTesouraria.add(tesouraria);
  }

  if (statusBox.isEmpty) {
    await statusBox.put(
      'status',
      JogadoraStatusHive(
        xp: 0,
        nivel: 0,
        conhecimento: 0,
        criatividade: 0,
        estamina: 100,
        conexao: 0,
        espiritualidade: 0,
        energiaVital: 100,
        xpDiarioPorPredio: {},
        xpTotalPorPredio: {},
        avatarAtual: 'avatar_padrao',
        dataUltimoAcesso: DateTime.now(),
      ),
    );
  }

  if (projetoBox.isEmpty) {
    await projetoBox.add(
      Projeto(
        id: '1',
        nome: 'Planejamento da Semana',
        categoria: 'Moradia',
        descricao: 'Organizar tarefas e rotinas da semana.',
        corHex: '#FFB74D',
      ),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<TarefaManager>.value(value: tarefaManager),
        ChangeNotifierProvider(create: (_) => JogadoraStatus(statusBox)),
        Provider<ProjetoManager>.value(value: projetoManager),
        Provider<RecursoManager>.value(value: recursoManager),
      ],
      child: const CidadeDaVidaApp(),
    ),
  );
}

/// Registra todos os Adapters Hive
void _registerAdapters() {
  Hive.registerAdapter(TarefaAdapter());
  Hive.registerAdapter(JogadoraStatusHiveAdapter());
  Hive.registerAdapter(ProjetoAdapter());
  Hive.registerAdapter(RecursoAdapter());
  Hive.registerAdapter(RecursoStatusAdapter());
  Hive.registerAdapter(RecursoAlocadoAdapter());
  Hive.registerAdapter(DemandaAdapter());
  Hive.registerAdapter(PredioStatusAdapter());
  Hive.registerAdapter(PredioAdapter());
  Hive.registerAdapter(PredioHabilidadeAdapter());
  Hive.registerAdapter(ServicoAdapter());
  Hive.registerAdapter(InsumoAdapter());
  Hive.registerAdapter(CompraAdapter());
  Hive.registerAdapter(IngredientesReceitaAdapter());
  Hive.registerAdapter(ReceitaAdapter());
  Hive.registerAdapter(ItemAvulsoAdapter());
  Hive.registerAdapter(RefeicaoAdapter());
  Hive.registerAdapter(CardapioAdapter());
  Hive.registerAdapter(ReceitaPreparadaAdapter());
  Hive.registerAdapter(KanbanColumnAdapter());
  Hive.registerAdapter(KanbanHistoricoTaskAdapter());
  Hive.registerAdapter(KanbanHistoricoAdapter());
  Hive.registerAdapter(EntradaFinanceiraAdapter());
  Hive.registerAdapter(DistribuicaoOrcamentariaAdapter());
  Hive.registerAdapter(TesourariaAdapter());
  Hive.registerAdapter(TarefaRecorrenteAdapter());
  Hive.registerAdapter(ItemListaAdapter());
  Hive.registerAdapter(ListaGeralAdapter());
  Hive.registerAdapter(PecaTabuleiroAdapter());
}