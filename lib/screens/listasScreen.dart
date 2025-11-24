// lib/screens/listas_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/lista_geral.dart';
import '../nova_tarefa_screen.dart'; // sua tela já existente

class ListasScreen extends StatefulWidget {
  final String predioNome; // aqui é o NOME do prédio
  const ListasScreen({super.key, required this.predioNome});

  @override
  State<ListasScreen> createState() => _ListasScreenState();
}

class _ListasScreenState extends State<ListasScreen> {
  late Box<ListaGeral> listasBox;


  // um controller por lista (ExpansionTile)
  final Map<String, ScrollController> _itemCtrls = {};
  ScrollController _ctrlFor(String id) =>
      _itemCtrls.putIfAbsent(id, () => ScrollController());

  @override
  void initState() {
    super.initState();
    listasBox = Hive.box<ListaGeral>('listas');
  }

  @override
  void dispose() {
    for (final c in _itemCtrls.values) c.dispose();
    _itemCtrls.clear();
    super.dispose();
  }

  Future<void> _novaLista() async {
    final lista = ListaGeral(
      id: const Uuid().v4(),
      predioId: widget.predioNome,
      titulo: 'Nova lista',
      executavel: false,
    );
    await listasBox.add(lista);
    if (mounted) setState(() {});
  }
//PARA EDITAR A LISTA
  Future<void> _editarCabecalhoLista(ListaGeral lista) async {
    final ctrl = TextEditingController(text: lista.titulo);
    bool executavel = lista.executavel;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar lista'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: 'Título'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Lista executável'),
              subtitle: const Text('Mostra botão "Criar tarefa" nos itens'),
              value: executavel,
              onChanged: (v) => setState(() { executavel = v; }),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              lista.titulo = ctrl.text.trim().isEmpty ? 'Lista sem título' : ctrl.text.trim();
              lista.executavel = executavel;
              await lista.save();
              if (mounted) setState(() {});
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _adicionarItem(ListaGeral lista) async {
    String descricao = '';
    String quantidadeStr = '';
    String unidade = '';
    String observacao = '';

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Novo item'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Descrição *'),
                  autofocus: true,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
                  onChanged: (v) => descricao = v,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => quantidadeStr = v,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Unidade (opcional)'),
                  onChanged: (v) => unidade = v,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Observações (opcional)'),
                  maxLines: 2,
                  onChanged: (v) => observacao = v,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result == true) {
      final q = quantidadeStr.trim().isEmpty
          ? null
          : double.tryParse(quantidadeStr.replaceAll(',', '.'));
      final item = ItemLista(
        id: const Uuid().v4(),
        descricao: descricao.trim(),
        quantidade: q,
        unidade: unidade.trim().isEmpty ? null : unidade.trim(),
        observacao: observacao.trim().isEmpty ? null : observacao.trim(),
      );
      lista.itens.add(item);
      await lista.save();
      if (mounted) setState(() {});
    }
  }



  Future<void> _toggleItem(ListaGeral lista, ItemLista item, bool v) async {
    item.concluido = v;
    await lista.save();
    if (mounted) setState(() {});
  }

  Future<void> _editarItemDialog(ListaGeral lista, ItemLista item) async {
    String descricao = item.descricao;
    String quantidadeStr = item.quantidade?.toString() ?? '';
    String unidade = item.unidade ?? '';
    String observacao = item.observacao ?? '';
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar item'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: descricao,
                  decoration: const InputDecoration(labelText: 'Descrição *'),
                  autofocus: true,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
                  onChanged: (v) => descricao = v,
                ),
                TextFormField(
                  initialValue: quantidadeStr,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => quantidadeStr = v,
                ),
                TextFormField(
                  initialValue: unidade,
                  decoration: const InputDecoration(labelText: 'Unidade (opcional)'),
                  onChanged: (v) => unidade = v,
                ),
                TextFormField(
                  initialValue: observacao,
                  decoration: const InputDecoration(labelText: 'Observações (opcional)'),
                  maxLines: 2,
                  onChanged: (v) => observacao = v,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true) {
      item.descricao = descricao.trim();
      item.quantidade = quantidadeStr.trim().isEmpty
          ? null
          : double.tryParse(quantidadeStr.replaceAll(',', '.'));
      item.unidade = unidade.trim().isEmpty ? null : unidade.trim();
      item.observacao = observacao.trim().isEmpty ? null : observacao.trim();
      await lista.save();
      if (mounted) setState(() {});
    }
  }

  Future<void> _criarTarefaAPartirDoItem(ListaGeral lista, ItemLista item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NovaTarefaScreen()),
    );
    // opcional: salvar item.tarefaIdVinculada quando sua NovaTarefaScreen retornar a tarefa criada
    // item.tarefaIdVinculada = tarefa.id; await lista.save(); setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas'),
        actions: [
          IconButton(
            tooltip: 'Nova lista',
            icon: const Icon(Icons.add),
            onPressed: _novaLista,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: listasBox.listenable(),
        builder: (_, Box<ListaGeral> box, __) {
          final listas = box.values
              .where((l) => l.predioId == widget.predioNome && !l.arquivada)
              .toList()
            ..sort((a, b) => a.criadoEm.compareTo(b.criadoEm));

          if (listas.isEmpty) {
            return const Center(child: Text('Nenhuma lista por aqui ainda.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: listas.length,
            itemBuilder: (_, i) {
              final lista = listas[i];

              return Card(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: ExpansionTile(
                  maintainState: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: Icon(lista.executavel ? Icons.playlist_add : Icons.checklist_rtl),
                  title: Row(
                    children: [
                      Expanded(child: Text(lista.titulo)),
                      IconButton(
                        tooltip: 'Editar título e modo',
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editarCabecalhoLista(lista),
                      ),
                      IconButton(
                        tooltip: 'Adicionar item',
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _adicionarItem(lista),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Mais ações',
                        onSelected: (v) async {
                          if (v == 'arquivar') {
                            lista.arquivada = true;
                            await lista.save();
                          } else if (v == 'excluir') {
                            await lista.delete();
                          }
                          if (mounted) setState(() {});
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'arquivar', child: Text('Arquivar')),
                          PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                        ],
                      ),
                    ],
                  ),
                  children: [
                    // área rolável dos itens (rápida de consultar)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 260),
                        child: lista.itens.isEmpty
                            ? const Center(heightFactor: 3, child: Text('Sem itens ainda.'))
                            : Builder(
                          builder: (_) {
                            final ctrl = _ctrlFor(lista.id); // 👈 controller dedicado da lista
                            return Scrollbar(
                              controller: ctrl,
                              thumbVisibility: true,                 // 👈 barra sempre visível
                              child: ListView.builder(
                                controller: ctrl,
                                padding: EdgeInsets.zero,
                                itemCount: lista.itens.length,
                                itemBuilder: (_, j) {
                                  final item = lista.itens[j];
                                  return ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.only(left: 4, right: 4),
                                    leading: Checkbox(
                                      value: item.concluido,
                                      onChanged: (v) => _toggleItem(lista, item, v ?? false),
                                    ),
                                    title: Text(item.descricao),
                                    subtitle: _buildSubtitle(item),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (lista.executavel)
                                          IconButton(
                                            tooltip: 'Criar tarefa',
                                            icon: const Icon(Icons.playlist_add),
                                            onPressed: () => _criarTarefaAPartirDoItem(lista, item),
                                          ),
                                        IconButton(
                                          tooltip: 'Editar item',
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _editarItemDialog(lista, item),
                                        ),
                                        IconButton(
                                          tooltip: 'Remover item',
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: () async {
                                            lista.itens.removeWhere((it) => it.id == item.id);
                                            await lista.save();
                                            if (mounted) setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget? _buildSubtitle(ItemLista item) {
    final partes = <String>[];
    if (item.quantidade != null) {
      final q = item.quantidade!.toStringAsFixed(
        item.quantidade!.truncateToDouble() == item.quantidade! ? 0 : 2,
      );
      partes.add(item.unidade != null ? '$q ${item.unidade}' : q);
    } else if (item.unidade != null) {
      partes.add(item.unidade!);
    }
    if ((item.observacao ?? '').isNotEmpty) partes.add(item.observacao!.trim());
    if (item.tarefaIdVinculada != null) partes.add('tarefa: ${item.tarefaIdVinculada}');
    if (partes.isEmpty) return null;
    return Text(partes.join(' · '));
  }
}