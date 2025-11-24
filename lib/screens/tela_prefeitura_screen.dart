import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/demanda.dart';
import '../models/recurso.dart';
import '../models/predio.dart';
import '../widgets/carrossel_demandas.dart';
import '../screens/tela_orcamento.dart';
import '../screens/novo_recurso_screen.dart';
import 'package:cidade_da_vida/screens/insumos_screen.dart';
import 'package:cidade_da_vida/screens/lista_compras_screen.dart';
import 'package:cidade_da_vida/screens/editar_insumos_screen.dart';
import 'package:cidade_da_vida/widgets/inventario_central_screen.dart';
import 'package:cidade_da_vida/screens/tesouraria_screen.dart';

/// Função para migrar recursos para demandas, caso necessário
void migrarRecursosParaDemandas() {
  final recursoBox = Hive.box<Recurso>('recursos');
  final demandaBox = Hive.box<Demanda>('demandas');

  int recursosMigrados = 0;

  for (final recurso in recursoBox.values) {
    if (recurso.status == 'esperandoAprovacao') {
      // Verifica se já existe demanda para esse recurso
      Demanda? demandaExistente;

      try {
        demandaExistente = demandaBox.values.firstWhere(
              (d) => d.recursoId == recurso.id,
        );
      } catch (e) {
        demandaExistente = null;
      }

      if (demandaExistente == null) {
        final novaDemanda = Demanda(
          recursoId: recurso.id,
          quantidadeSolicitada: recurso.quantidadeTotal,
          status: 'aguardandoAprovacao',
          dataSolicitacao: recurso.historicoCompras.isNotEmpty
              ? recurso.historicoCompras.last
              : DateTime.now(),
          urgente: false,
          projetoSolicitante: (recurso.projetosVinculados != null &&
              recurso.projetosVinculados!.isNotEmpty)
              ? recurso.projetosVinculados!.first
              : 'Desconhecido',
          descricao: recurso.descricao,
          link: null,
          valorUnitario: recurso.valorVenda,
        );

        demandaBox.add(novaDemanda);
        recursosMigrados++;
        print(
            '✅ Migrado recurso "${recurso.nome}" (ID: ${recurso.id}) para demanda.');
      }
    }
  }

  if (recursosMigrados > 0) {
    print(
        '🚀 Migração completa. $recursosMigrados recurso(s) foram transformados em demandas!');
  } else {
    print('🔎 Nenhum recurso “esperandoAprovacao” precisava ser migrado.');
  }
}

class TelaPrefeituraScreen extends StatefulWidget {
  const TelaPrefeituraScreen({super.key});

  @override
  State<TelaPrefeituraScreen> createState() => _TelaPrefeituraScreenState();
}

class _TelaPrefeituraScreenState extends State<TelaPrefeituraScreen> {
  @override
  void initState() {
    super.initState();
    migrarRecursosParaDemandas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB0D3C3),
      appBar: AppBar(
        title: const Text('Prefeitura - Administração Central'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _BotaoPrefeitura(
              icone: Icons.assignment,
              titulo: 'Ver Demandas',
              onTap: () {
                final demandasAprovacao = Hive.box<Demanda>('demandas')
                    .values
                    .where((d) => d.status == 'aguardandoAprovacao')
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text('Demandas')),
                      body: CarrosselDemandasWidget(demandas: demandasAprovacao),
                    ),
                  ),
                );
              },
            ),
            _BotaoPrefeitura(
              icone: Icons.pending_actions,
              titulo: 'Demandas em Espera',
              onTap: () {
                final demandasEmEspera = Hive.box<Demanda>('demandas')
                    .values
                    .where((d) => d.status == 'solicitada')
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text('Demandas em Espera')),
                      body: CarrosselDemandasWidget(demandas: demandasEmEspera),
                    ),
                  ),
                );
              },
            ),
            _BotaoPrefeitura(
              icone: Icons.inventory_2,
              titulo: 'Inventário Central',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InventarioCentralScreen(),
                  ),
                );
              },
            ),
            _BotaoPrefeitura(
              icone: Icons.attach_money,
              titulo: 'Orçamento',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaOrcamentoScreen(),
                  ),
                );
              },
            ),

            _BotaoPrefeitura(
              icone: Icons.account_balance_wallet,
              titulo: 'Tesouraria',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TesourariaScreen(),
                  ),
                );
              },
            ),
            _BotaoPrefeitura(
              icone: Icons.add_box,
              titulo: 'Novo Recurso',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovoRecursoScreen(
                      predioAtual: 'Prefeitura',
                      permitirEscolherPredio: true,
                    ),
                  ),
                );
              },
            ),
            _BotaoPrefeitura(
              icone: Icons.shopping_basket,
              titulo: 'Insumos',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add, color: Colors.teal),
                        title: const Text('Novo Insumo'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NovoInsumoScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.teal),
                        title: const Text('Editar Insumos'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditarInsumosScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            _BotaoPrefeitura(
              icone: Icons.shopping_cart,
              titulo: 'Lista de Compras',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListaComprasScreen(),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}

class _BotaoPrefeitura extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onTap;

  const _BotaoPrefeitura({
    required this.icone,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(8),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, size: 32, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}