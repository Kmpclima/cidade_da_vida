// 1. Classe auxiliar para representar o uso de um recurso em um projeto
import 'package:hive/hive.dart';

part 'recurso_alocado.g.dart';

@HiveType(typeId: 11) // Escolha um typeId único
class RecursoAlocado {
  @HiveField(0)
  final String recursoId; // Só o id do recurso, para puxar o objeto depois

  @HiveField(1)
  final double quantidade; // Quanto foi usado no projeto

  RecursoAlocado({
    required this.recursoId,
    required this.quantidade
  });
}

// 2. No modelo Projeto (em projeto.dart), você pode adicionar isso:
//
// @HiveField(12)
// List<RecursoAlocado> recursosAlocados;
//
// 3. Quando quiser pegar o recurso completo, pode usar:
// final box = await Hive.openBox<Recurso>('recursos');
// final recursoCompleto = box.get(recursoAlocado.recursoId);

// 4. Ao adicionar um recurso em EditarProjetoScreen:
// recursosAlocados.add(RecursoAlocado(recursoId: recurso.id, quantidade: 2));

// 5. Para exibir chips, você pode mapear os objetos alocados e buscar os dados em tempo real:
// recursosAlocados.map((ra) async {
//   final r = await box.get(ra.recursoId);
//   return Chip(label: Text('${r?.nome} (${ra.quantidade})'));
// })

// Isso te dá rastreabilidade e consistência.
