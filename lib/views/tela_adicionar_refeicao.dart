import 'package:flutter/material.dart';

import '../controllers/refeicao_controller.dart';
import '../models/refeicao.dart';

class TelaAdicionarRefeicao extends StatefulWidget {
  final RefeicaoController controller;
  final Refeicao? refeicao;

  const TelaAdicionarRefeicao({
    super.key,
    required this.controller,
    this.refeicao,
  });

  @override
  State<TelaAdicionarRefeicao> createState() => _TelaAdicionarRefeicaoState();
}

class _TelaAdicionarRefeicaoState extends State<TelaAdicionarRefeicao> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nomeController;
  late final TextEditingController descricaoController;
  late final TextEditingController pesoController;
  late final TextEditingController caloriasController;
  late final TextEditingController proteinasController;
  late final TextEditingController carboidratosController;
  late final TextEditingController gordurasController;
  late final TextEditingController localController;
  late final TextEditingController dataController;

  bool _salvando = false;
  int _avaliacao = 3;

  bool get _editando => widget.refeicao != null;

  @override
  void initState() {
    super.initState();
    final refeicao = widget.refeicao;

    nomeController = TextEditingController(text: refeicao?.nome ?? '');
    descricaoController = TextEditingController(
      text: refeicao?.descricao ?? '',
    );
    pesoController = TextEditingController();
    caloriasController = TextEditingController(
      text: refeicao?.calorias.toString() ?? '',
    );
    proteinasController = TextEditingController(
      text: refeicao == null ? '' : refeicao.proteinas.toStringAsFixed(1),
    );
    carboidratosController = TextEditingController(
      text: refeicao == null ? '' : refeicao.carboidratos.toStringAsFixed(1),
    );
    gordurasController = TextEditingController(
      text: refeicao == null ? '' : refeicao.gorduras.toStringAsFixed(1),
    );
    localController = TextEditingController(text: refeicao?.local ?? '');
    dataController = TextEditingController(
      text:
          refeicao?.dataRefeicao ??
          DateTime.now().toIso8601String().substring(0, 10),
    );
    _avaliacao = refeicao?.avaliacao ?? 3;
  }

  @override
  void dispose() {
    nomeController.dispose();
    descricaoController.dispose();
    pesoController.dispose();
    caloriasController.dispose();
    proteinasController.dispose();
    carboidratosController.dispose();
    gordurasController.dispose();
    localController.dispose();
    dataController.dispose();
    super.dispose();
  }

  Future<void> _calcularNutrientesComIa() async {
    final nome = nomeController.text.trim();
    final peso = int.tryParse(pesoController.text.trim());

    if (nome.isEmpty) {
      _mostrarMensagem('Informe a refeicao primeiro.');
      return;
    }

    if (peso == null || peso <= 0) {
      _mostrarMensagem('Informe o peso em gramas.');
      return;
    }

    final estimativa = await widget.controller.estimarNutrientes(
      refeicao: nome,
      pesoGramas: peso,
    );

    if (!mounted) return;

    caloriasController.text = estimativa.calorias.toString();
    proteinasController.text = estimativa.proteinas.toStringAsFixed(1);
    carboidratosController.text = estimativa.carboidratos.toStringAsFixed(1);
    gordurasController.text = estimativa.gorduras.toStringAsFixed(1);
    _mostrarMensagem('Dados nutricionais estimados com IA.');
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final calorias = int.parse(caloriasController.text.trim());
      final proteinas = double.parse(proteinasController.text.trim());
      final carboidratos = double.parse(carboidratosController.text.trim());
      final gorduras = double.parse(gordurasController.text.trim());

      if (_editando) {
        await widget.controller.atualizar(
          Refeicao(
            id: widget.refeicao!.id,
            nome: nomeController.text.trim(),
            descricao: descricaoController.text.trim(),
            calorias: calorias,
            proteinas: proteinas,
            carboidratos: carboidratos,
            gorduras: gorduras,
            dataRefeicao: dataController.text.trim(),
            local: localController.text.trim(),
            avaliacao: _avaliacao,
          ),
        );
      } else {
        await widget.controller.adicionar(
          nome: nomeController.text.trim(),
          descricao: descricaoController.text.trim(),
          calorias: calorias,
          proteinas: proteinas,
          carboidratos: carboidratos,
          gorduras: gorduras,
          data: dataController.text.trim(),
          local: localController.text.trim(),
          avaliacao: _avaliacao,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        _mostrarMensagem(_mensagemErroSalvar(error));
      }
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  String _mensagemErroSalvar(Object error) {
    final detalhe = error.toString();

    if (detalhe.contains('proteinas') ||
        detalhe.contains('carboidratos') ||
        detalhe.contains('gorduras') ||
        detalhe.contains('local') ||
        detalhe.contains('avaliacao')) {
      return 'Nao foi possivel salvar. Atualize a tabela refeicoes no Supabase com as novas colunas.';
    }

    return 'Nao foi possivel salvar a refeicao. Tente novamente.';
  }

  String? _validarTextoObrigatorio(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe $campo.';
    }

    return null;
  }

  String? _validarNumero(String? value) {
    final numero = double.tryParse(value?.trim() ?? '');

    if (numero == null || numero < 0) {
      return 'Informe um valor valido.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Refeicao' : 'Adicionar Refeicao'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome do prato'),
              validator: (value) => _validarTextoObrigatorio(value, 'o nome'),
            ),
            TextFormField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descricao'),
              validator: (value) =>
                  _validarTextoObrigatorio(value, 'a descricao'),
            ),
            TextFormField(
              controller: localController,
              decoration: const InputDecoration(
                labelText: 'Local onde comeu',
                prefixIcon: Icon(Icons.place),
              ),
              validator: (value) => _validarTextoObrigatorio(value, 'o local'),
            ),
            TextFormField(
              controller: pesoController,
              decoration: const InputDecoration(
                labelText: 'Peso aproximado do prato',
                suffixText: 'g',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: widget.controller,
              builder: (context, child) {
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.controller.estimandoNutrientes
                        ? null
                        : _calcularNutrientesComIa,
                    icon: widget.controller.estimandoNutrientes
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      widget.controller.estimandoNutrientes
                          ? 'Calculando...'
                          : 'Calcular nutrientes com IA',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: caloriasController,
                    decoration: const InputDecoration(labelText: 'Calorias'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final calorias = int.tryParse(value?.trim() ?? '');

                      if (calorias == null || calorias < 0) {
                        return 'Valor invalido.';
                      }

                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: proteinasController,
                    decoration: const InputDecoration(
                      labelText: 'Proteinas',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validarNumero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: carboidratosController,
                    decoration: const InputDecoration(
                      labelText: 'Carboidratos',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validarNumero,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: gordurasController,
                    decoration: const InputDecoration(
                      labelText: 'Gorduras',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validarNumero,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: dataController,
              decoration: const InputDecoration(
                labelText: 'Data da refeicao',
                hintText: 'AAAA-MM-DD',
              ),
              validator: (value) => _validarTextoObrigatorio(value, 'a data'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Avaliacao do prato',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(5, (index) {
                final valor = index + 1;

                return IconButton(
                  onPressed: () => setState(() => _avaliacao = valor),
                  icon: Icon(
                    valor <= _avaliacao ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  tooltip: '$valor estrelas',
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              child: Text(_salvando ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
