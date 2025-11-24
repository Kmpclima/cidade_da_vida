import 'package:flutter/material.dart';

class DialogParcelamento extends StatefulWidget {
  final demanda;

  const DialogParcelamento({
    super.key,
    required this.demanda,
  });

  @override
  State<DialogParcelamento> createState() => _DialogParcelamentoState();
}

class _DialogParcelamentoState extends State<DialogParcelamento> {
  String _tipoPagamento = "a_vista";
  double? _valorEntrada;
  int? _numeroParcelas;
  DateTime? _dataInicial;

  final TextEditingController _entradaController = TextEditingController();
  final TextEditingController _parcelasController = TextEditingController();

  @override
  void dispose() {
    _entradaController.dispose();
    _parcelasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Condições de Pagamento"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text("À Vista"),
              value: "a_vista",
              groupValue: _tipoPagamento,
              onChanged: (value) {
                setState(() {
                  _tipoPagamento = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text("Parcelado sem entrada"),
              value: "parcelado_sem_entrada",
              groupValue: _tipoPagamento,
              onChanged: (value) {
                setState(() {
                  _tipoPagamento = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text("Parcelado com entrada"),
              value: "parcelado_com_entrada",
              groupValue: _tipoPagamento,
              onChanged: (value) {
                setState(() {
                  _tipoPagamento = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text("Futura parcela única"),
              value: "futuro_unica",
              groupValue: _tipoPagamento,
              onChanged: (value) {
                setState(() {
                  _tipoPagamento = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            if (_tipoPagamento == "parcelado_com_entrada") ...[
              TextField(
                controller: _entradaController,
                decoration: const InputDecoration(
                  labelText: "Valor da entrada",
                  prefixText: "R\$ ",
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
            ],

            if (_tipoPagamento != "a_vista") ...[
              TextField(
                controller: _parcelasController,
                decoration: const InputDecoration(
                  labelText: "Número de parcelas",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Text("Data da 1ª parcela: "),
                  TextButton(
                    onPressed: () async {
                      final data = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (data != null) {
                        setState(() {
                          _dataInicial = data;
                        });
                      }
                    },
                    child: Text(
                      _dataInicial != null
                          ? "${_dataInicial!.day}/${_dataInicial!.month}/${_dataInicial!.year}"
                          : "Escolher data",
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: const Text("Salvar"),
          onPressed: () {
            if (_tipoPagamento != "a_vista") {
              if (_parcelasController.text.isEmpty ||
                  int.tryParse(_parcelasController.text) == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Informe o número de parcelas."),
                  ),
                );
                return;
              }
            }

            Navigator.pop(context, {
              "tipoPagamento": _tipoPagamento,
              "valorEntrada": _tipoPagamento == "parcelado_com_entrada"
                  ? double.tryParse(_entradaController.text) ?? 0.0
                  : null,
              "numeroParcelas": _tipoPagamento != "a_vista"
                  ? int.tryParse(_parcelasController.text) ?? 1
                  : null,
              "dataInicial": _dataInicial,
            });
          },
        )
      ],
    );
  }
}