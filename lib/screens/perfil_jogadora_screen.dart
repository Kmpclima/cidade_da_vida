import 'package:flutter/material.dart';
import '../models/jogadora_status.dart';
import 'package:provider/provider.dart';


class PerfilJogadoraScreen extends StatelessWidget {
  const PerfilJogadoraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jogadora = Provider.of<JogadoraStatus>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil da Jogadora')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Consumer<JogadoraStatus>(
              builder: (context, jogadora, _) {

                return Column(
                  children: [
                    Text(
                      'XP: ${jogadora.xp}/100',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    LinearProgressIndicator(
                      value: jogadora.xp / 100,
                      backgroundColor: Colors.grey[300],
                      color: Colors.amber,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Avatar
           Consumer<JogadoraStatus>(
              builder: (context, jogadora, _) => CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/${jogadora.avatarAtual}.png'),

            ),
           ),

            // Atributos
            Consumer<JogadoraStatus>(
              builder: (context, jogadora, _) =>
                  _buildAtributo('Conhecimento', jogadora.conhecimento, Icons.menu_book),
            ),
            Consumer<JogadoraStatus>(
              builder: (context, jogadora, _) =>
                  _buildAtributo('Criatividade', jogadora.criatividade, Icons.brush ),
            ),
            Consumer<JogadoraStatus>(
              builder: (context, jogadora, _) =>
                  _buildAtributo('Estamina', jogadora.estamina, Icons.directions_run),
            ),
            Consumer<JogadoraStatus>(
              builder: (context, jogadora, _) =>
                  _buildAtributo('Energia Vital', jogadora.energiaVital, Icons.favorite),
            ),
            Consumer<JogadoraStatus>(
              builder: (context, jogadora, _) =>
                  _buildAtributo('Conexão', jogadora.conexao, Icons.people),
            ),
            Consumer<JogadoraStatus>(
              builder: (context, jogadora, _) =>
                  _buildAtributo('Espiritualidade', jogadora.espiritualidade, Icons.self_improvement),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtributo(String nome, int valor, IconData icone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icone, size: 24),
          const SizedBox(width: 10),
          Expanded(child: Text(nome)),
          Text('$valor/100'),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: valor / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          ),
        ],
      ),
    );
  }
}