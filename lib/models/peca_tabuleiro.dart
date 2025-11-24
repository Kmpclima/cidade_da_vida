import 'package:hive/hive.dart';
part 'peca_tabuleiro.g.dart';

@HiveType(typeId: 200) // usa um número livre no seu projeto
class PecaTabuleiro extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String tipo;

  @HiveField(2)
  int nivel;

  @HiveField(3)
  int row;

  @HiveField(4)
  int col;

  PecaTabuleiro({
    required this.id,
    required this.tipo,
    required this.nivel,
    required this.row,
    required this.col,
  });
}