
import 'package:cidade_da_vida/tarefa_manager.dart';
import 'package:flutter/material.dart';
import '../screens/cidade_screen.dart';
import 'package:provider/provider.dart';

class CidadeDaVidaApp extends StatelessWidget {
  const CidadeDaVidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tarefaManager = Provider.of<TarefaManager>(context);

    return MaterialApp(
      title: 'Cidade da Vida',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: CidadeScreen(
        tarefaManager: tarefaManager,
      ),
    );
  }
}