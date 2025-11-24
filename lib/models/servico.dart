import 'package:hive/hive.dart';

part 'servico.g.dart';

@HiveType(typeId: 101)
class Servico extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String? descricao;

  @HiveField(3)
  double valor;

  @HiveField(4)
  bool recorrente;

  @HiveField(5)
  String? frequencia;

  @HiveField(6)
  DateTime? dataVencimento;

  @HiveField(7)
  String status;
  // "pendente", "pago", "arquivado"

  @HiveField(8)
  String predioId;

  @HiveField(9)
  String? linkDocumento;

  @HiveField(10)
  DateTime? dataPagamento;

  // ✅ NOVOS CAMPOS

  /// Id da Demanda que originou este serviço (opcional)
  @HiveField(11)
  String? demandaId;

  /// Número da parcela (ex.: 2 para "Parcela 2/5")
  @HiveField(12)
  int? numParcela;

  /// Quantidade total de parcelas
  @HiveField(13)
  int? totalParcelas;

  Servico({
    required this.id,
    required this.nome,
    this.descricao,
    required this.valor,
    required this.recorrente,
    this.frequencia,
    this.dataVencimento,
    this.status = "pendente",
    required this.predioId,
    this.linkDocumento,
    this.dataPagamento,
    this.demandaId,
    this.numParcela,
    this.totalParcelas,
  });
}