// lib/projeto_manager.dart
import 'package:hive/hive.dart';
import 'models/projeto.dart';

class ProjetoManager {
  final Box<Projeto> _box;

  ProjetoManager(this._box);

  List<Projeto> obterProjetos() {
    return _box.values.toList();
  }

  Future<void> adicionarProjeto(Projeto projeto) async {
    await _box.add(projeto);
  }

// Você pode expandir com editar/remover depois se quiser
}