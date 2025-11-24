import 'package:flutter/material.dart';
import '../models/recurso.dart';
import 'package:cidade_da_vida/models/demanda.dart';
import 'package:cidade_da_vida/screens/nova_demanda_screen.dart';

class SelecionarRecursoModal extends StatefulWidget {

  final List<Recurso> recursosDisponiveis;
  final Function(Recurso recurso, double quantidade) onSelecionar;
  final VoidCallback onNovoRecurso;
  final String predioAtual;

  const SelecionarRecursoModal({
    super.key,
    required this.recursosDisponiveis,
    required this.onSelecionar,
    required this.onNovoRecurso,
    required this.predioAtual,
  });

  @override
  State<SelecionarRecursoModal> createState() => _SelecionarRecursoModalState();
}

class _SelecionarRecursoModalState extends State<SelecionarRecursoModal> {
  Recurso? recursoSelecionado;
  double quantidade = 1.0;

  @override
  Widget build(BuildContext context) {
    return Material( // <-- RESOLVE o erro de "No Material widget found"
      color: Colors.white,
      child: SingleChildScrollView( // <-- PREVINE overflow com teclado ou conteúdo grande
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecionar recurso',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Recurso>(
                decoration: const InputDecoration(labelText: 'Recurso'),
                items: widget.recursosDisponiveis.map((recurso) {
                  return DropdownMenuItem(
                    value: recurso,
                    child: Text('${recurso.nome} (${recurso.quantidadeDisponivel} disponíveis)'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => recursoSelecionado = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quantidade desejada'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => quantidade = double.tryParse(v) ?? 1),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                child: const Text('Confirmar'),
                onPressed: () {
                  if (recursoSelecionado == null) return;
                  final recurso = recursoSelecionado!;
                  if (quantidade <= recurso.quantidadeDisponivel) {
                    widget.onSelecionar(recurso, quantidade);
                    Navigator.pop(context);
                  } else {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Quantidade insuficiente'),
                        content: Text(
                          'Atualmente existem ${recurso.quantidadeDisponivel} unidades de "${recurso.nome}" disponíveis.\n'
                              'Você solicitou $quantidade. Deseja solicitar o que falta?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              widget.onSelecionar(recurso, recurso.quantidadeDisponivel);
                              Navigator.pop(ctx); // fecha o alerta
                              Navigator.pop(context); // fecha o modal
                            },
                            child: const Text('Sim, solicitar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              //BOTAO NOVA DEMANDA:
              const Divider(height: 32),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Solicitar novo recurso'),
                onPressed: () async {
                  Navigator.pop (context);
                  final novaDemanda = await Navigator.push<Demanda>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NovaDemandaScreen(predioAtual: widget.predioAtual),
                    ),
                  );

                  if (novaDemanda != null) {
                    //opcional, atualizar dropdown automaticamente
                    setState(() {});
                  }
                },
              ),
              //BOTAO CANCELAR:
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}