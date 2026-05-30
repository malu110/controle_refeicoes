import 'package:flutter/material.dart';

import '../models/refeicao.dart';

class TelaDetalheRefeicao extends StatelessWidget {
  final Refeicao refeicao;

  const TelaDetalheRefeicao({super.key, required this.refeicao});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Refeicao')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            refeicao.nome,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _AvaliacaoEstrelas(avaliacao: refeicao.avaliacao),
          const SizedBox(height: 20),
          _DetalheLinha(titulo: 'Descricao', valor: refeicao.descricao),
          _DetalheLinha(titulo: 'Local', valor: refeicao.local),
          _DetalheLinha(
            titulo: 'Data da refeicao',
            valor: refeicao.dataRefeicao,
          ),
          const SizedBox(height: 12),
          _MacroCard(
            titulo: 'Calorias',
            valor: '${refeicao.calorias}',
            unidade: 'kcal',
            icone: Icons.local_fire_department,
          ),
          _MacroCard(
            titulo: 'Proteinas',
            valor: refeicao.proteinas.toStringAsFixed(1),
            unidade: 'g',
            icone: Icons.fitness_center,
          ),
          _MacroCard(
            titulo: 'Carboidratos',
            valor: refeicao.carboidratos.toStringAsFixed(1),
            unidade: 'g',
            icone: Icons.grain,
          ),
          _MacroCard(
            titulo: 'Gorduras',
            valor: refeicao.gorduras.toStringAsFixed(1),
            unidade: 'g',
            icone: Icons.opacity,
          ),
        ],
      ),
    );
  }
}

class _DetalheLinha extends StatelessWidget {
  final String titulo;
  final String valor;

  const _DetalheLinha({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titulo:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(valor.isEmpty ? 'Nao informado' : valor),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String unidade;
  final IconData icone;

  const _MacroCard({
    required this.titulo,
    required this.valor,
    required this.unidade,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icone),
        title: Text(titulo),
        trailing: Text(
          '$valor $unidade',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
      children: List.generate(5, (index) {
        return Icon(
          index < avaliacao ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }
}
