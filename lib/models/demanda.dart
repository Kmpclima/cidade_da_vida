import 'package:hive/hive.dart';

part 'demanda.g.dart';

@HiveType(typeId: 7)
class Demanda extends HiveObject {
  @HiveField(0)
  String recursoId;

  @HiveField(1)
  double quantidadeSolicitada;

  @HiveField(2)
  String status; // aguardandoAprovacao, solicitado, pendente, etc.

  @HiveField(3)
  DateTime dataSolicitacao;

  @HiveField(4)
  DateTime? prazo;

  @HiveField(5)
  bool urgente;

  @HiveField(6)
  String projetoSolicitante;

  @HiveField(7)
  double? valorUnitario;

  @HiveField(8)
  String? descricao;

  @HiveField(9)
  String? link;

  // ✅ NOVOS CAMPOS

  /// Forma de pagamento (ex.: "a_vista", "parcelado_sem_entrada", etc.)
  @HiveField(10)
  String? tipoPagamento;

  /// Valor da entrada, se houver
  @HiveField(11)
  double? valorEntrada;

  /// Número de parcelas, se parcelado
  @HiveField(12)
  int? numeroParcelas;

  /// Lista de IDs dos serviços (boletos) gerados
  @HiveField(13)
  List<String>? parcelasServicoIds;

  Demanda({
    required this.recursoId,
    required this.quantidadeSolicitada,
    required this.status,
    required this.dataSolicitacao,
    this.prazo,
    required this.urgente,
    required this.projetoSolicitante,
    this.valorUnitario,
    this.descricao,
    this.link,
    this.tipoPagamento,
    this.valorEntrada,
    this.numeroParcelas,
    this.parcelasServicoIds,
  });
}