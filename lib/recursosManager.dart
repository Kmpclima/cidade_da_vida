// lib/recurso_manager.dart
import 'package:hive/hive.dart';
import 'models/recurso.dart';

class RecursoManager {
  final Box<Recurso> _box;

  RecursoManager(this._box);

  List<Recurso> get todos => _box.values.toList();

  Future<void> adicionar(Recurso recurso) async {
    await _box.add(recurso);
  }

  Future<void> atualizar(int index, Recurso recurso) async {
    await _box.putAt(index, recurso   );
  }

  Future<void> remover(int index) async {
    await _box.deleteAt(index);
  }
}