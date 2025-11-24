import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cidade_da_vida/services/board_queue_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:cidade_da_vida/models/peca_tabuleiro.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  // Tamanho do tabuleiro (ajuste à vontade)

  static const int rows = 8;
  static const int cols = 10;
  int get cellCount => rows * cols;

  late Box<PecaTabuleiro> _box;

  int _rowFromIndex(int i) => i ~/ cols;
  int _colFromIndex(int i) => i % cols;
  int _indexFromRC(int r, int c) => r * cols + c;

  // Estado do tabuleiro: célula -> peça
  final Map<int, _BoardPiece> _piecesByCell = {};

  // Seleção para tentar merge
  int? _selectedIndex;

  // "Modo sorte": permite tiers mais altos ocasionalmente
  bool luckMode = false;

  // ======================
  // 🔸 NOVO BLOCO (pendências)
  // ======================
  final Map<String, int> _pending = {}; // categoria -> estamina pendente

  Future<void> _loadPendings() async {
    _pending
      ..clear()
      ..addAll(await BoardQueueService.getAllPendings());
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _box = Hive.box<PecaTabuleiro>('pecas_tabuleiro');
    _restoreBoardFromHive();
    _loadPendings();
  }

  void _restoreBoardFromHive() {
    _piecesByCell.clear();
    for (final p in _box.values) {
      final idx = _indexFromRC(p.row, p.col);
      _piecesByCell[idx] = _BoardPiece(
        id: p.id,
        categoria: p.tipo,
        tier: p.nivel,
        createdAt: DateTime.now(),
      );
    }
    setState(() {});
  }


  // Lista de símbolos por categoria (básico -> avançado)
  final Map<String, List<String>> symbolsByCategoria = {
    'Cozinha': [
      'assets/board/cozinha/COZINHA1.png',
      'assets/board/cozinha/COZINHA2.png',
      'assets/board/cozinha/COZINHA3.png',
      'assets/board/cozinha/COZINHA4.png',
      'assets/board/cozinha/COZINHA5.png',
      'assets/board/cozinha/COZINHA6.png',
      'assets/board/cozinha/COZINHA7.png',
      'assets/board/cozinha/COZINHA8.png',
      'assets/board/cozinha/COZINHA9.png',
      'assets/board/cozinha/COZINHA10.png',
    ],
    'Escola' : [

      'assets/board/escola/escola1.png',
      'assets/board/escola/escola2.png',
      'assets/board/escola/escola3.png',
      'assets/board/escola/escola4.png',
    ],
    'Horta'  : [
      'assets/board/herbgarden/HORTA.png',
      'assets/board/herbgarden/HORTA1.png',
      'assets/board/herbgarden/HORTA2.png',
      'assets/board/herbgarden/HORTA3.png',
      'assets/board/herbgarden/HORTA4.png',
      'assets/board/herbgarden/HORTA5.png',
      'assets/board/herbgarden/HORTA6.png',
      'assets/board/herbgarden/HORTA7.png',
      'assets/board/herbgarden/HORTA8.png',
      'assets/board/herbgarden/HORTA9.png',
      'assets/board/herbgarden/HORTA10.png',
      'assets/board/herbgarden/HORTA11.png',

    ],
    'Casa'   : ['🧹', '🧺', '🧼', '🏡'],
    'Moradia': [
      'assets/board/casa/casa1.png',
      'assets/board/casa/casa2.png',
      'assets/board/casa/casa3.png',
      'assets/board/casa/casa4.png',
      'assets/board/casa/casa5.png',
      'assets/board/casa/casa6.png',
      'assets/board/casa/casa10.png',
    ],
    'Ateliê' : [
      'assets/board/atelie/atelie1.png',
      'assets/board/atelie/atelie2.png',
      'assets/board/atelie/atelie3.png',
      'assets/board/atelie/atelie4.png',
      'assets/board/atelie/atelie5.png',
      'assets/board/atelie/atelie6.png',
      'assets/board/atelie/atelie7.png',
      'assets/board/atelie/atelie8.png',

    ],
    'Finanças': [
      'assets/board/financas/FINANCAS1.png',
      'assets/board/financas/FINANCAS2.png',
      'assets/board/financas/FINANCAS3.png',
      'assets/board/financas/FINANCAS4.png',
    ],
    'Família e Amigos': [
      'assets/board/familia/FAMILIA1.png',
      'assets/board/familia/FAMILIA2.png',
      'assets/board/familia/FAMILIA3.png',
      'assets/board/familia/FAMILIA4.png',
      'assets/board/familia/FAMILIA5.png',
      'assets/board/familia/FAMILIA6.png',
      'assets/board/familia/FAMILIA7.png',
      'assets/board/familia/FAMILIA8.png',
      'assets/board/familia/FAMILIA9.png',
      'assets/board/familia/FAMILIA10.png',
      'assets/board/familia/FAMILIA11.png',
      'assets/board/familia/FAMILIA12.png',
      'assets/board/familia/FAMILIA13.png',

    ],
    'Espiritual': [
      'assets/board/espiritual/espiritual1.png',
      'assets/board/espiritual/espiritual2.png',
      'assets/board/espiritual/espiritual3.png',
      'assets/board/espiritual/espiritual4.png',
      'assets/board/espiritual/espiritual5.png',
      'assets/board/espiritual/espiritual6.png',

    ],
    'Hospital': [
      'assets/board/saude/saude1.png',
      'assets/board/saude/saude2.png',
      'assets/board/saude/saude3.png',
      'assets/board/saude/saude4.png',
      'assets/board/saude/saude5.png',
      'assets/board/saude/saude6.png',
      'assets/board/saude/saude7.png',

    ],
    'Prefeitura': [
      'assets/board/prefeitura/prefeitura1.png',
      'assets/board/prefeitura/prefeitura2.png',
      'assets/board/prefeitura/prefeitura3.png',
      'assets/board/prefeitura/prefeitura4.png',
      'assets/board/prefeitura/prefeitura5.png',
      'assets/board/prefeitura/prefeitura6.png',
      'assets/board/prefeitura/prefeitura7.png',
    ],
    'Lazer': [
      'assets/board/lazer/lazer1.png',
      'assets/board/lazer/lazer2.png',
      'assets/board/lazer/lazer3.png',
      'assets/board/lazer/lazer4.png',
      'assets/board/lazer/lazer5.png',
      'assets/board/lazer/lazer6.png',
      'assets/board/lazer/lazer7.png',
      'assets/board/lazer/lazer8.png',
      'assets/board/lazer/lazer9.png',
      'assets/board/lazer/lazer10.png',
      'assets/board/lazer/lazer11.png',
    ],
    'Workshop': [
      'assets/board/workshop/WORKSHOP1.png',
      'assets/board/workshop/WORKSHOP2.png',
      'assets/board/workshop/WORKSHOP3.png',
      'assets/board/workshop/WORKSHOP4.png',
      'assets/board/workshop/WORKSHOP5.png',
    ],
    'Geral'  : [
      'assets/board/geral/geral1.png',
      'assets/board/geral/geral2.png',
      'assets/board/geral/geral3.png',
    ],
  };

  // ======= LÓGICA DE GERAR PEÇAS =======

  // Fórmula:  estamina/4 (floor), limitado entre 1 e 10
  int _piecesFromEstamina(int estamina) {
    final p = (estamina / 4).floor();
    return p.clamp(1, 10);
  }

  // Sorteio do "tier" com peso (favorita o tier 0)
  int _pickTierWeighted(String categoria) {
    final list = symbolsByCategoria[categoria] ?? symbolsByCategoria['Geral']!;
    if (!luckMode || list.length == 1) return 0;

    final tiers = list.length;
    final r = Random().nextDouble();
    if (tiers >= 3) {
      // 80% tier0 | 15% tier1 | 5% tier2+
      if (r < 0.80) return 0;
      if (r < 0.95) return 1;
      return 2;
    } else if (tiers == 2) {
      // 85% tier0 | 15% tier1
      return r < 0.85 ? 0 : 1;
    } else {
      return 0;
    }
  }

  // Adiciona peças aleatórias em células vazias
  Future<void> _addPieces({required String categoria, required int estamina}) async {
    final rng = Random();
    final target = _piecesFromEstamina(estamina);
    int placed = 0;
    int safety = 0;

    while (placed < target && safety < 500) {
      safety++;
      final idx = rng.nextInt(cellCount);
      if (_piecesByCell.containsKey(idx)) continue;

      final uuid = const Uuid().v4();
      final r = _rowFromIndex(idx);
      final c = _colFromIndex(idx);

// salva no Hive
      final hivePiece = PecaTabuleiro(
        id: uuid,
        tipo: categoria,
        nivel: _pickTierWeighted(categoria),
        row: r,
        col: c,
      );
      await _box.put(uuid, hivePiece);

// adiciona no mapa da UI
      final piece = _BoardPiece(
        id: uuid,
        categoria: categoria,
        tier: hivePiece.nivel,
        createdAt: DateTime.now(),
      );

      _piecesByCell[idx] = piece;
      placed++;
    }
    setState(() {});
  }

  Widget _genButton({String? emoji, IconData? icon, required String categoria}) {
    final count = _pending[categoria] ?? 0;
    return ElevatedButton.icon(
      icon: icon != null ? Icon(icon) : Text(emoji ?? '•'),
      label: Text('$categoria ($count)'),
      onPressed: () async {
        final e = await BoardQueueService.consumePending(categoria);
        if (e > 0) {
         await _addPieces(categoria: categoria, estamina: e);
        }
        await _loadPendings();
      },
    );
  }

  // ======= LÓGICA DE MERGE =======

  bool _areAdjacent(int a, int b) {
    final ax = a % cols, ay = a ~/ cols;
    final bx = b % cols, by = b ~/ cols;
    final dx = (ax - bx).abs(), dy = (ay - by).abs();
    return (dx + dy) == 1; // vizinhos 4-direções
  }

  void _onCellTap(int index) {
    final piece = _piecesByCell[index];

    if (_selectedIndex == null) {
      if (piece != null) setState(() => _selectedIndex = index);
      return;
    }

    // Já havia selecionada
    final from = _selectedIndex!;
    if (from == index) {
      setState(() => _selectedIndex = null); // deseleciona
      return;
    }

    final pA = _piecesByCell[from];
    final pB = _piecesByCell[index];

    if (pA != null && pB != null) {
      // Agora junta mesmo à distância (inclusive diagonal)
      if (pA.categoria == pB.categoria && pA.tier == pB.tier) {
        _mergePieces(from, index);
        return;
      }
    }

    // Se não deu merge, troca seleção se clicou em outra peça
    setState(() => _selectedIndex = (piece != null) ? index : null);
  }

  Future<void> _mergePieces(int fromIndex, int toIndex) async {
    final a = _piecesByCell[fromIndex]!;
    final b = _piecesByCell[toIndex]!;

    final list = symbolsByCategoria[a.categoria] ?? symbolsByCategoria['Geral']!;
    final isMaxTier = a.tier >= list.length - 1;

    if (isMaxTier) {
      // ⚠️ Já está no nível máximo: não faz merge
      // Opcional: pode tocar um som, mostrar um efeito ou mensagem
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ ${a.categoria} já atingiu o nível máximo!'),
          duration: const Duration(seconds: 1),
        ),
      );
      setState(() => _selectedIndex = null);
      return;
    }

    // Caso contrário, segue o merge normal
    final nextTier = a.tier + 1;
    final row = _rowFromIndex(toIndex);
    final col = _colFromIndex(toIndex);

    final newId = const Uuid().v4();
    final mergedHive = PecaTabuleiro(
      id: newId,
      tipo: a.categoria,
      nivel: nextTier,
      row: row,
      col: col,
    );

    await _box.deleteAll([a.id, b.id]);
    await _box.put(newId, mergedHive);

    _piecesByCell[toIndex] = _BoardPiece(
      id: newId,
      categoria: a.categoria,
      tier: nextTier,
      createdAt: DateTime.now(),
    );
    _piecesByCell.remove(fromIndex);
    setState(() => _selectedIndex = null);
  }

  // ======= UI =======

  void _clearBoard() {
    _piecesByCell.clear();
    _selectedIndex = null;
    _box.clear(); // apaga tudo salvo
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabuleiro de Recompensas'),
        actions: [
          IconButton(
            tooltip: luckMode ? 'Luck ON' : 'Luck OFF',
            icon: Icon(luckMode ? Icons.casino : Icons.casino_outlined),
            onPressed: () => setState(() => luckMode = !luckMode),
          ),
          IconButton(
            tooltip: 'Limpar tabuleiro',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearBoard,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 6.0;
          const padding = 12.0;

          // 👇 Novo: limite de largura do tabuleiro
          const double maxGridWidth = 800; // ajuste como preferir (ex.: 420, 480…)

          // Largura realmente disponível na tela (com padding)
          final availableWidth = constraints.maxWidth - padding * 2;

          // 👇 Usa o menor entre a largura disponível e o limite
          final double gridWidth = min(availableWidth, maxGridWidth);

          // Tamanho da célula agora vem do gridWidth "capado"
          final cellSize = (gridWidth - spacing * (cols - 1)) / cols;

          // Altura do grid acompanha o novo cellSize
          final gridHeight = cellSize * rows + spacing * (rows - 1);

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Center(
                    child: SizedBox(
                      width: gridWidth,
                      height: gridHeight,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: 1,
                        ),
                        itemCount: cellCount,
                        itemBuilder: (context, index) {
                          final piece = _piecesByCell[index];
                          final isSelected = _selectedIndex == index;
                          return GestureDetector(
                            onTap: () => _onCellTap(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outlineVariant,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: piece == null
                                  ? const SizedBox.shrink()
                                  : Center(
                                child: Builder(
                                  builder: (_) {
                                    final list = symbolsByCategoria[piece.categoria] ??
                                        symbolsByCategoria['Geral']!;
                                    return piece.buildWidget(
                                      cellSize: cellSize,
                                      symbolsByCategoria: symbolsByCategoria,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Botões de teste (simulam conclusão de tarefa)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _genButton(emoji: '🍳', categoria: 'Cozinha'),
                      _genButton(emoji: '📚', categoria: 'Escola'),
                      _genButton(emoji: '🌱', categoria: 'Horta'),
                      _genButton(emoji: '🎨', categoria: 'Ateliê'),
                      _genButton(emoji: '💰', categoria: 'Finanças'),
                      _genButton(emoji: '👨‍👩‍👧‍👦', categoria: 'Família e Amigos'),
                      _genButton(emoji: '🧘‍♀️', categoria: 'Espiritual'),
                      _genButton(emoji: '🏥', categoria: 'Hospital'),
                      _genButton(emoji: '🏛️', categoria: 'Prefeitura'),
                      _genButton(emoji: '🎭', categoria: 'Lazer'),
                      _genButton(emoji: '🧰', categoria: 'Workshop'),
                      _genButton(emoji: '🏠', categoria: 'Moradia'),
                      _genButton(icon: Icons.bolt, categoria: 'Geral'),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.playlist_add_check),
                        label: const Text('Gerar Tudo'),
                        onPressed: () async {
                          final all = await BoardQueueService.consumeAll();
                          for (final entry in all.entries) {
                            final cat = entry.key;
                            final est = entry.value;
                            if (est > 0) {
                              await _addPieces(categoria: cat, estamina: est);
                            }
                          }
                          await _loadPendings();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ======= MODELO DA PEÇA (tier-based) =======

class _BoardPiece {
  final String id;
  final String categoria;
  final int tier;
  final DateTime createdAt;

  _BoardPiece({
    required this.id,
    required this.categoria,
    required this.tier,
    required this.createdAt,
  });

  Widget buildWidget({
    required double cellSize,
    required Map<String, List<String>> symbolsByCategoria,
  }) {
    final list = symbolsByCategoria[categoria] ?? symbolsByCategoria['Geral']!;
    final idx = tier.clamp(0, list.length - 1);
    final ref = list[idx];

    // 👇 Aqui ele descobre se é imagem ou emoji
    if (ref.startsWith('assets/')) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Image.asset(
          ref,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) {
            return Center(
              child: Text(
                '🧩',
                style: TextStyle(fontSize: cellSize * 0.45),
              ),
            );
          },
        ),
      );
    }

    // Caso não seja imagem, mostra o texto normalmente
    return Center(
      child: Text(
        ref,
        style: TextStyle(fontSize: cellSize * 0.55),
        textAlign: TextAlign.center,
      ),
    );
  }
}