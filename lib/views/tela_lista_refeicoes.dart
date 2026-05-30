import 'package:flutter/material.dart';

import '../controllers/refeicao_controller.dart';
import '../models/refeicao.dart';
import 'tela_adicionar_refeicao.dart';
import 'tela_detalhe_refeicao.dart';

class TelaListaRefeicoes extends StatelessWidget {
  final RefeicaoController controller;
  final VoidCallback? onRefeicaoSalva;

  const TelaListaRefeicoes({
    super.key,
    required this.controller,
    this.onRefeicaoSalva,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refeicoes')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          if (controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.erro != null) {
            return _MensagemErro(
              mensagem: controller.erro!,
              onTentarNovamente: controller.carregarRefeicoes,
            );
          }

          if (controller.refeicoes.isEmpty) {
            return const Center(child: Text('Nenhuma refeicao cadastrada'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.refeicoes.length,
            itemBuilder: (context, index) {
              final Refeicao refeicao = controller.refeicoes[index];

              return Card(
                child: ListTile(
                  title: Text(refeicao.nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(refeicao.descricao),
                      const SizedBox(height: 4),
                      Text(
                        '${refeicao.calorias} kcal | '
                        'P ${refeicao.proteinas.toStringAsFixed(1)}g | '
                        'C ${refeicao.carboidratos.toStringAsFixed(1)}g | '
                        'G ${refeicao.gorduras.toStringAsFixed(1)}g',
                      ),
                      Text('Local: ${refeicao.local}'),
                      Text('Data: ${refeicao.dataRefeicao}'),
                      _AvaliacaoEstrelas(avaliacao: refeicao.avaliacao),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TelaDetalheRefeicao(refeicao: refeicao),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: refeicao.id == null
                        ? null
                        : () async {
                            await controller.remover(refeicao.id!);
                          },
                    tooltip: 'Excluir',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final salvou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => TelaAdicionarRefeicao(controller: controller),
            ),
          );

          if (salvou == true) {
            onRefeicaoSalva?.call();
          }
        },
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

class _MensagemErro extends StatelessWidget {
  final String mensagem;
  final Future<void> Function() onTentarNovamente;

  const _MensagemErro({
    required this.mensagem,
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensagem, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onTentarNovamente,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
