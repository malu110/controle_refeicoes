import 'package:flutter/material.dart';

import '../controllers/refeicao_controller.dart';

class TelaDashboard extends StatelessWidget {
  final RefeicaoController controller;
  final VoidCallback onAbrirLista;

  const TelaDashboard({
    super.key,
    required this.controller,
    required this.onAbrirLista,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          if (controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.erro != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(controller.erro!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: controller.carregarRefeicoes,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final refeicaoMaisRecente = controller.refeicoes.isEmpty
              ? null
              : controller.refeicoes.first;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Metas da pessoa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _MetaCard(
                titulo: 'Calorias',
                consumido: controller.totalCalorias.toDouble(),
                meta: RefeicaoController.metaCalorias.toDouble(),
                unidade: 'kcal',
                icone: Icons.local_fire_department,
              ),
              _MetaCard(
                titulo: 'Proteinas',
                consumido: controller.totalProteinas,
                meta: RefeicaoController.metaProteinas,
                unidade: 'g',
                icone: Icons.fitness_center,
              ),
              _MetaCard(
                titulo: 'Carboidratos',
                consumido: controller.totalCarboidratos,
                meta: RefeicaoController.metaCarboidratos,
                unidade: 'g',
                icone: Icons.grain,
              ),
              _MetaCard(
                titulo: 'Gorduras',
                consumido: controller.totalGorduras,
                meta: RefeicaoController.metaGorduras,
                unidade: 'g',
                icone: Icons.opacity,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ResumoCard(
                      titulo: 'Refeicoes',
                      valor: '${controller.refeicoes.length}',
                      icone: Icons.restaurant_menu,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ResumoCard(
                      titulo: 'Atingido',
                      valor:
                          '${_percentual(controller.totalCalorias, RefeicaoController.metaCalorias)}%',
                      icone: Icons.flag,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ultima refeicao',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (refeicaoMaisRecente == null)
                        const Text('Nenhuma refeicao cadastrada ainda.')
                      else ...[
                        Text(
                          refeicaoMaisRecente.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(refeicaoMaisRecente.descricao),
                        Text('Local: ${refeicaoMaisRecente.local}'),
                        const SizedBox(height: 4),
                        Text(
                          '${refeicaoMaisRecente.calorias} kcal | '
                          'P ${refeicaoMaisRecente.proteinas.toStringAsFixed(1)}g | '
                          'C ${refeicaoMaisRecente.carboidratos.toStringAsFixed(1)}g | '
                          'G ${refeicaoMaisRecente.gorduras.toStringAsFixed(1)}g',
                        ),
                        const SizedBox(height: 4),
                        _AvaliacaoEstrelas(
                          avaliacao: refeicaoMaisRecente.avaliacao,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAbrirLista,
                icon: const Icon(Icons.list),
                label: const Text('Ver lista de refeicoes'),
              ),
            ],
          );
        },
      ),
    );
  }

  int _percentual(int consumido, int meta) {
    if (meta <= 0) return 0;
    return ((consumido / meta) * 100).round();
  }
}

class _MetaCard extends StatelessWidget {
  final String titulo;
  final double consumido;
  final double meta;
  final String unidade;
  final IconData icone;

  const _MetaCard({
    required this.titulo,
    required this.consumido,
    required this.meta,
    required this.unidade,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final progresso = meta <= 0 ? 0.0 : (consumido / meta).clamp(0.0, 1.0);
    final percentual = meta <= 0 ? 0 : ((consumido / meta) * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: const Color(0xFF2D6A4F)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('$percentual%'),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progresso),
            const SizedBox(height: 8),
            Text(
              '${_formatar(consumido)} de ${_formatar(meta)} $unidade',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatar(double valor) {
    return valor % 1 == 0 ? valor.toInt().toString() : valor.toStringAsFixed(1);
  }
}

class _ResumoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _ResumoCard({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: const Color(0xFF2D6A4F)),
            const SizedBox(height: 12),
            Text(
              valor,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(titulo),
          ],
        ),
      ),
    );
  }
}

class _AvaliacaoEstrelas extends StatelessWidget {
  final int avaliacao;

  const _AvaliacaoEstrelas({required this.avaliacao});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < avaliacao ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }
}
