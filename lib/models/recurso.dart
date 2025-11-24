  import 'package:hive/hive.dart';

part 'recurso.g.dart';

@HiveType(typeId: 3)
enum  RecursoStatus {
  @HiveField(0)
  pendente,
  @HiveField(1)
  disponivel,
  @HiveField(2)
  emUso,
  @HiveField(3)
  reservado,
  @HiveField(4)
  danificado,
  @HiveField(5)
  descartado,
  @HiveField(6)
  solicitado,
  @HiveField(7)
  aguardandoAprovacao,
}

@HiveType(typeId: 4)
class Recurso extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String unidade;

  @HiveField(3)
  double quantidadeTotal;

  @HiveField(4)
  double quantidadeDisponivel;

  @HiveField(5)
  double valorUnitario;

  @HiveField(6)
  bool compartilhavel;

  @HiveField(7)
  List<String> projetosVinculados;

  @HiveField(8)
  List<DateTime> historicoCompras;

  @HiveField(9)
  String? descricao;

  @HiveField(10)
  String? origem; // Ex: "Já tinha em casa", "Doação", etc.

  @HiveField(11)
  String? pathImagem;

  @HiveField(12)
  double? valorVenda;

  @HiveField(13)
  bool estaNaPrefeitura;

  @HiveField(14)
  RecursoStatus status;

  @HiveField(15)
  List<String> prediosVinculados;

  Recurso({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.quantidadeTotal,
    required this.quantidadeDisponivel,
    required this.valorUnitario,
    required this.compartilhavel,
    required this.projetosVinculados,
    required this.historicoCompras,
    this.descricao,
    this.origem,
    this.pathImagem,
    this.valorVenda,
    required this.estaNaPrefeitura,
    required this.status,
    required this.prediosVinculados,
  });

  factory Recurso.vazio() => Recurso(
    id: '',
    nome: 'Desconhecido',
    valorUnitario: 0,
   // quantidade: 0,
    status: RecursoStatus.pendente,
    origem: 'existente',
    descricao: '',
    estaNaPrefeitura: false,
    pathImagem: '',
    quantidadeDisponivel: 0,
    compartilhavel: false,
    historicoCompras: [],
    prediosVinculados: [],
    projetosVinculados: [],
    unidade: '',
    quantidadeTotal: 0,
  );
}