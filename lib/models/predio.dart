import 'package:hive/hive.dart';
import 'package:cidade_da_vida/models/predio_habilidade.dart';

part 'predio.g.dart';

@HiveType(typeId: 34)
enum PredioStatus {
  @HiveField(0)
  ativo,

  @HiveField(1)
  pegandoFogo,

  @HiveField(2)
  abandonado,

  @HiveField(3)
  boost,

  @HiveField(4)
  pausado,

  @HiveField(5)
  fumaceando,
}

@HiveType(typeId: 33)
class Predio extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String categoria;

  @HiveField(3)
  int nivel;

  @HiveField(4)
  int xpTotal;

  @HiveField(5)
  int xpDiario;

  @HiveField(6)
  PredioStatus status;

  @HiveField(7)
  double x1;

  @HiveField(8)
  double y1;

  @HiveField(9)
  double x2;

  @HiveField(10)
  double y2;

  @HiveField(11)
  List<String>? imagens;

  @HiveField(12)
  List<PredioHabilidade>? habilidadesDesbloqueadas;

  @HiveField(13)
  double orcamentoTotal;

  @HiveField(14)
  double orcamentoMensal;

  @HiveField(15)
  String cor;

  @HiveField(16)
  PredioStatus? statusManual;

  @HiveField(17)
  DateTime? statusManualExpira;

  Predio({
    required this.id,
    required this.nome,
    required this.categoria,
    this.nivel = 1,
    this.xpTotal = 0,
    this.xpDiario = 0,
    this.status = PredioStatus.ativo,
    this.x1 = 0,
    this.y1 = 0,
    this.x2 = 0,
    this.y2 = 0,
    this.imagens,
    this.habilidadesDesbloqueadas,
    this.orcamentoMensal = 0,
    this.orcamentoTotal = 0,
    this.cor = '',
    this.statusManual,
    this.statusManualExpira,
  });
}