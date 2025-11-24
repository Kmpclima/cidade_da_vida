import 'package:hive/hive.dart';

DateTime ultimoDomingo(DateTime data) {
  return DateTime(
      data.year,
      data.month,
      data.day
  ).subtract(Duration(days: data.weekday % 7));
}

bool ehNovoDia(Box configBox) {
  final hoje = DateTime.now();
  final ultimaDataSalva = configBox.get('ultimaData') as String?;

  if (ultimaDataSalva == null) {
    configBox.put('ultimaData', hoje.toIso8601String());
    return true;
  }

  final ultimaData = DateTime.parse(ultimaDataSalva);

  final ehNovo = hoje.year != ultimaData.year ||
      hoje.month != ultimaData.month ||
      hoje.day != ultimaData.day;

  if (ehNovo) {
    configBox.put('ultimaData', hoje.toIso8601String());
  }

  return ehNovo;
}