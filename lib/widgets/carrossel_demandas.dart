import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import '../models/demanda.dart';
import '../models/recurso.dart';
import 'package:cidade_da_vida/models/predio.dart';
import 'package:collection/collection.dart';
import 'package:cidade_da_vida/models/servico.dart';
import 'package:cidade_da_vida/widgets/dialog_parcelamento.dart';


Future<bool> _confirmarRejeicao(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar rejeição'),
      content: const Text(
        'Deseja realmente rejeitar esta demanda? Essa ação não poderá ser desfeita.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Rejeitar'),
        ),
      ],
    ),
  ).then((value) => value ?? false);
}

class CarrosselDemandasWidget extends StatelessWidget {
  final List<Demanda> demandas;


  const CarrosselDemandasWidget({
    super.key,
    required this.demandas,
  });

  @override
  Widget build(BuildContext context) {
    final recursoBox = Hive.box<Recurso>('recursos');

    if (demandas.isEmpty) {
      return const Center(
        child: Text('Nenhuma demanda encontrada.'),
      );
    }

    return PageView.builder(
      itemCount: demandas.length,
      itemBuilder: (context, index) {
        final demanda = demandas[index];
        final recurso = recursoBox.get(demanda.recursoId);

        Predio? predio;
        if (recurso != null && recurso.prediosVinculados.isNotEmpty) {
          final predioBox = Hive.box<Predio>('predios');
          final categoriaPredio = recurso.prediosVinculados.first;
          predio = predioBox.values
              .firstWhereOrNull((p) => p.categoria == categoriaPredio);
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recurso?.pathImagem != null)
                  Image.file(
                    File(recurso!.pathImagem!),
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 8),
                Text(
                  recurso?.nome ?? 'Recurso desconhecido',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (recurso?.descricao?.isNotEmpty == true)
                  Text(recurso!.descricao!),
                if (demanda.link != null && demanda.link!.isNotEmpty)
                  Text(
                    demanda.link!,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                const SizedBox(height: 4),
                Text('Projeto: ${demanda.projetoSolicitante}'),

                if (predio != null)
                  Text(
                    'Prédio: ${predio.nome}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                Text(
                    'Qtd: ${demanda.quantidadeSolicitada} ${recurso?.unidade ?? ""}'),

                if (demanda.valorUnitario != null)
                  Text(
                    'Valor unitário: R\$ ${demanda.valorUnitario!.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                if (demanda.valorUnitario != null)
                  Text(
                    'Subtotal: R\$ ${((demanda.quantidadeSolicitada ?? 0) * (demanda.valorUnitario ?? 0)).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                Text('Status: ${demanda.status}'),
                const SizedBox(height: 12),

                // BOTÕES
                Row(
                  children: [

                      ElevatedButton(
                        onPressed: () async {
                          final resultado = await showDialog<Map<String, dynamic>>(
                            context: context,
                            builder: (_) => DialogParcelamento(
                              demanda: demanda,
                            ),
                          );

                          if (resultado == null) return; // usuário cancelou o diálogo

                          final tipoPagamento = resultado["tipoPagamento"] as String;
                          final valorEntrada = resultado["valorEntrada"] as double?;
                          final numeroParcelas = resultado["numeroParcelas"] as int?;
                          final dataInicial = resultado["dataInicial"] as DateTime?;

                          final valorTotal = (demanda.quantidadeSolicitada) *
                              (demanda.valorUnitario ?? 0.0);

                          // Debitar orçamento ou criar serviços conforme tipo de pagamento
                          if (tipoPagamento == "a_vista") {
                            if (predio != null) {
                              predio.orcamentoTotal -= valorTotal;
                              await predio.save();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Demanda aprovada à vista. Débito de R\$ ${valorTotal.toStringAsFixed(2)} realizado.',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '⚠️ Prédio não encontrado para debitar a demanda.',
                                  ),
                                ),
                              );
                            }
                          } else {
                            // Parcelado ou parcela única futura
                            final servicoBox = Hive.box<Servico>('servicos');

                            double valorParcela = 0;
                            double valorRestante = valorTotal;

                            if (valorEntrada != null && valorEntrada > 0) {
                              if (predio != null) {
                                predio.orcamentoTotal -= valorEntrada;
                                await predio.save();
                              }
                              valorRestante -= valorEntrada;
                            }

                            int parcelas = numeroParcelas ?? 1;
                            valorParcela = valorRestante / parcelas;

                            List<String> idsServicosGerados = [];

                            for (int i = 0; i < parcelas; i++) {
                              final servico = Servico(
                                id: DateTime.now().millisecondsSinceEpoch.toString() + "_$i",
                                nome:
                                "Parcela ${i + 1}/$parcelas - ${recurso?.nome ?? 'Recurso'}",
                                descricao: demanda.descricao,
                                valor: valorParcela,
                                recorrente: false,
                                frequencia: null,
                                dataVencimento:
                                dataInicial?.add(Duration(days: i * 30)) ?? DateTime.now(),
                                status: "pendente",
                                predioId: predio?.id ?? "",
                                linkDocumento: null,
                                dataPagamento: null,
                                demandaId: demanda.key?.toString() ?? "",
                                numParcela: i + 1,
                                totalParcelas: parcelas,
                              );

                              await servicoBox.add(servico);
                              idsServicosGerados.add(servico.key.toString());
                            }

                            demanda.parcelasServicoIds = idsServicosGerados;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Demanda aprovada em $parcelas parcela(s). Serviços criados.',
                                ),
                              ),
                            );
                          }

                          // Atualizar recurso sempre para pendente
                          if (recurso != null) {
                            recurso.status = RecursoStatus.pendente;
                            await recurso.save();
                          }

                          // Atualizar demanda
                          demanda.status = "pendente";
                          demanda.tipoPagamento = tipoPagamento;
                          demanda.valorEntrada = valorEntrada;
                          demanda.numeroParcelas = numeroParcelas;
                          await demanda.save();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Aprovar'),
                      ),

                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        demanda.status = 'solicitada';
                        if (recurso != null) {
                          recurso.status = RecursoStatus.solicitado;
                          await recurso.save();
                        }
                        await demanda.save();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Demanda movida para Em Espera.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                      ),
                      child: const Text('Em espera'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final confirmacao = await _confirmarRejeicao(context);
                        if (confirmacao) {
                          demanda.status = 'descartado';
                          if (recurso != null) {
                            recurso.status = RecursoStatus.descartado;
                            await recurso.save();
                          }
                          await demanda.save();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Demanda descartada.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Rejeitar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}