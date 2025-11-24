import 'package:flutter/material.dart';
import '../controllers/audio_controller.dart';

class VolumeSheet extends StatefulWidget {
  final VoidCallback onClose;

  const VolumeSheet({super.key, required this.onClose});

  @override
  State<VolumeSheet> createState() => _VolumeSheetState();
}

class _VolumeSheetState extends State<VolumeSheet> {
  double musicVolume = AudioController.musicaVolume;
  double efeitosVolume = AudioController.efeitosVolume;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Volume da Música", style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: musicVolume,
            onChanged: (value) {
              setState(() {
                musicVolume = value;
              });
              AudioController.setMusicaVolume(value);
            },
            min: 0,
            max: 1,
            divisions: 10,
            label: "${(musicVolume * 100).toInt()}%",
          ),
          SizedBox(height: 20),
          Text("Volume dos Efeitos", style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: efeitosVolume,
            onChanged: (value) {
              setState(() {
                efeitosVolume = value;
              });
              AudioController.setEfeitosVolume(value);
            },
            min: 0,
            max: 1,
            divisions: 10,
            label: "${(efeitosVolume * 100).toInt()}%",
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onClose();
            },
            child: Text("Fechar"),
          )
        ],
      ),
    );
  }
}