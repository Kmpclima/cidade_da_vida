import 'package:hive/hive.dart';

part 'lista_geral.g.dart';

@HiveType(typeId: 161) // <<< ajuste se necessário
class ItemLista {
  @HiveField(0)
  String id;

  @HiveField(1)
  String descricao;

  @HiveField(2)
  double? quantidade;

  @HiveField(3)
  String? unidade;

  @HiveField(4)
  String? observacao;

  @HiveField(5)
  bool concluido;

  // opcional: se um item virar tarefa, podemos guardar o id
  @HiveField(6)
  String? tarefaIdVinculada;

  ItemLista({
    required this.id,
    required this.descricao,
    this.quantidade,
    this.unidade,
    this.observacao,
    this.concluido = false,
    this.tarefaIdVinculada,
  });
}


@HiveType(typeId: 162) // mesmo de antes
class ListaGeral extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String predioId;

  @HiveField(2)
  String titulo;

  @HiveField(3)
  List<ItemLista> itens;

  @HiveField(4)
  DateTime criadoEm;

  @HiveField(5)
  bool arquivada;

  // NOVO: controla se exibe o botão de criar tarefa nos itens
  @HiveField(6)
  bool executavel; // <<< ADICIONE ESTE CAMPO

  ListaGeral({
    required this.id,
    required this.predioId,
    required this.titulo,
    List<ItemLista>? itens,
    DateTime? criadoEm,
    this.arquivada = false,
    this.executavel = false, // por padrão é só checklist
  })  : itens = itens ?? [],
        criadoEm = criadoEm ?? DateTime.now();
}