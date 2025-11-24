import 'package:hive/hive.dart';

class BoardQueueService {
  static const _boxName = 'board_queue'; // Box<int>, chave = categoria

  static Future<Box<int>> _box() async =>
      await Hive.openBox<int>(_boxName);

  // adiciona estamina pendente para uma categoria
  static Future<void> addPending(String categoria, int estamina) async {
    final box = await _box();
    final current = box.get(categoria, defaultValue: 0) ?? 0;
    await box.put(categoria, current + estamina);
  }

  // lê pendente de uma categoria (sem consumir)
  static Future<int> getPending(String categoria) async {
    final box = await _box();
    return box.get(categoria, defaultValue: 0) ?? 0;
  }

  // consome (zera) e devolve o valor consumido
  static Future<int> consumePending(String categoria) async {
    final box = await _box();
    final v = box.get(categoria, defaultValue: 0) ?? 0;
    await box.put(categoria, 0);
    return v;
  }

  // pega todas as categorias com valor > 0 (mapa)
  static Future<Map<String, int>> getAllPendings() async {
    final box = await _box();
    final map = <String, int>{};
    for (final k in box.keys) {
      final v = box.get(k as String, defaultValue: 0) ?? 0;
      if (v > 0) map[k] = v;
    }
    return map;
  }

  // consome tudo (retorna o mapa e zera)
  static Future<Map<String, int>> consumeAll() async {
    final box = await _box();
    final out = <String, int>{};
    for (final k in box.keys) {
      final key = k as String;
      final v = box.get(key, defaultValue: 0) ?? 0;
      if (v > 0) out[key] = v;
      await box.put(key, 0);
    }
    return out;
  }
}