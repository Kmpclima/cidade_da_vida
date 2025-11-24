import 'package:hive/hive.dart';

part 'jogadora_status_adapter.g.dart';

@HiveType(typeId: 1)
class JogadoraStatusHive extends HiveObject {
  @HiveField(0)
  int xp;

  @HiveField(1)
  int nivel;

  @HiveField(2)
  int conhecimento;

  @HiveField(3)
  int criatividade;

  @HiveField(4)
  int estamina;

  @HiveField(5)
  int conexao;

  @HiveField(6)
  int espiritualidade;

  @HiveField(7)
  int energiaVital;

  @HiveField(8)
  Map<String, int> xpDiarioPorPredio;

  @HiveField(9)
  Map<String, int> xpTotalPorPredio;

  @HiveField(10)
  String avatarAtual;

  @HiveField(11)
  DateTime? dataUltimoAcesso;

  JogadoraStatusHive({
    required this.xp,
    required this.nivel,
    required this.conhecimento,
    required this.criatividade,
    required this.estamina,
    required this.conexao,
    required this.espiritualidade,
    required this.energiaVital,
    required this.xpDiarioPorPredio,
    required this.xpTotalPorPredio,
    required this.avatarAtual,
    required this.dataUltimoAcesso,
  });
}