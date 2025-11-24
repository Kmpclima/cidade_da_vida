
import 'package:hive/hive.dart';
import 'package:cidade_da_vida/models/predio_habilidade.dart';

part 'predio_habilidade.g.dart';

@HiveType(typeId: 35)
class PredioHabilidade extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String descricao;

  @HiveField(3)
  int nivelNecessario;

  @HiveField(4)
  String? iconePath;

  PredioHabilidade({
    required this.id,
    required this.nome,
    required this.descricao,
    this.nivelNecessario = 1,
    this.iconePath,
  });
}
