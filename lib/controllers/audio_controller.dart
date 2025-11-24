import 'package:audioplayers/audioplayers.dart';

class AudioController {
  static final AudioPlayer musicPlayer = AudioPlayer();
  static final AudioPlayer efeitosPlayer = AudioPlayer();

  static String? efeitoAtual;

  static double musicaVolume = 1.0;
  static double efeitosVolume = 1.0;

  static Future<void> tocarMusicaFundo(String nomeArquivo) async {
    await musicPlayer.stop();
    await musicPlayer.setVolume(musicaVolume);
    await musicPlayer.setReleaseMode(ReleaseMode.loop);
    await musicPlayer.play(AssetSource('audio/$nomeArquivo'));
  }

  static Future<void> pararMusica() async {
    await musicPlayer.stop();
  }

  static Future<void> tocarEfeito(String nomeArquivo, {bool loop = false}) async {
    if (efeitoAtual == nomeArquivo) {
      return;
    }

    efeitoAtual = nomeArquivo;

    await efeitosPlayer.stop();
    await efeitosPlayer.setVolume(efeitosVolume);
    await efeitosPlayer.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.release);
    await efeitosPlayer.play(AssetSource('audio/efeitos/$nomeArquivo'));
  }

  static Future<void> pararEfeito() async {
    efeitoAtual = null;
    await efeitosPlayer.stop();
  }

  static Future<void> setMusicaVolume(double volume) async {
    musicaVolume = volume.clamp(0.0, 1.0);
    await musicPlayer.setVolume(musicaVolume);
  }

  static Future<void> setEfeitosVolume(double volume) async {
    efeitosVolume = volume.clamp(0.0, 1.0);
    await efeitosPlayer.setVolume(efeitosVolume);
  }
}