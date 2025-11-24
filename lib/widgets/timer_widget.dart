import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cidade_da_vida/models/kanban_historico_task.dart';

class TimerWidget extends StatefulWidget {
  final KanbanHistoricoTask task;

  const TimerWidget({
    super.key,
    required this.task,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  int segundosPassados = 0;
  bool estaRodando = false;

  @override
  void initState() {
    super.initState();

    final acumuladoMin = widget.task.tempoGastoMinutos ?? 0;

    if (widget.task.inicioExecucao != null) {
      final segundosDecorridos = DateTime.now()
          .difference(widget.task.inicioExecucao!)
          .inSeconds;

      // inclui o acumulado anterior (em segundos) + o que já correu
      segundosPassados = (acumuladoMin * 60) + segundosDecorridos;

      iniciarTimer();
    } else {
      // só mostra o acumulado salvo
      segundosPassados = acumuladoMin * 60;
    }
  }

  int obterTempoGastoMinutos() {
    return (segundosPassados / 60).round();
  }

  void iniciarTimer() {
    if (widget.task.inicioExecucao == null) {
      widget.task.inicioExecucao = DateTime.now();
      print('⏱️ Timer iniciado em: ${widget.task.inicioExecucao}');

      if (widget.task.isInBox) {
        widget.task.save();
      }
    }

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        segundosPassados++;
      });
    });
    setState(() {
      estaRodando = true;
    });
  }

  void pausarTimer() async {
    _timer?.cancel();

    // acumula o que rodou agora
    widget.task.tempoGastoMinutos = (segundosPassados / 60).round();

    // ✅ MUITO IMPORTANTE: limpar o marcador de execução
    widget.task.inicioExecucao = null;

    if (widget.task.isInBox) {
      await widget.task.save();
    }

    setState(() {
      estaRodando = false;
    });
  }

  void resetarTimer() async {
    _timer?.cancel();
    widget.task.inicioExecucao = null;
    widget.task.tempoGastoMinutos = 0;

    if (widget.task.isInBox) {
      await widget.task.save();
    }

    setState(() {
      segundosPassados = 0;
      estaRodando = false;
    });
  }

  String formatarTempo(int segundos) {
    final duracao = Duration(seconds: segundos);
    return duracao.toString().split('.').first.padLeft(8, "0");
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print('🔄 TimerWidget build chamado para ${widget.task.nome}');
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '⏱️ Tempo investido',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              formatarTempo(segundosPassados),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(estaRodando ? Icons.pause : Icons.play_arrow),
                  tooltip: estaRodando ? 'Pausar' : 'Iniciar',
                  onPressed: estaRodando ? pausarTimer : iniciarTimer,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Resetar',
                  onPressed: resetarTimer,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}