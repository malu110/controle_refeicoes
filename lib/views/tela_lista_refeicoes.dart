import 'package:flutter/material.dart';

import '../controllers/refeicao_controller.dart';
import '../models/refeicao.dart';
import '../services/relatorio_refeicoes_pdf_service.dart';
import 'tela_adicionar_refeicao.dart';
import 'tela_detalhe_refeicao.dart';

class TelaListaRefeicoes extends StatefulWidget {
  final RefeicaoController controller;
  final VoidCallback? onRefeicaoSalva;

  const TelaListaRefeicoes({
    super.key,
    required this.controller,
    this.onRefeicaoSalva,
  });

  @override
  State<TelaListaRefeicoes> createState() => _TelaListaRefeicoesState();
}

class _TelaListaRefeicoesState extends State<TelaListaRefeicoes> {
  final TextEditingController _buscaController = TextEditingController();
  final RelatorioRefeicoesPdfService _pdfService =
      RelatorioRefeicoesPdfService();

  _CriterioOrdenacao _criterio = _CriterioOrdenacao.calorias;
  String _busca = '';
  int? _avaliacao;

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<Refeicao> _aplicarFiltros(List<Refeicao> refeicoes) {
    final termo = _busca.trim().toLowerCase();
    final filtradas = refeicoes.where((refeicao) {
      final correspondeAoTexto =
          termo.isEmpty ||
          refeicao.nome.toLowerCase().contains(termo) ||
          refeicao.descricao.toLowerCase().contains(termo) ||
          refeicao.local.toLowerCase().contains(termo);

      final correspondeANota =
          _avaliacao == null || refeicao.avaliacao == _avaliacao;

      return correspondeAoTexto && correspondeANota;
    }).toList();

    filtradas.sort((a, b) {
      return _valorCriterio(
        b,
        _criterio,
      ).compareTo(_valorCriterio(a, _criterio));
    });

    return filtradas;
  }

  double _valorCriterio(Refeicao refeicao, _CriterioOrdenacao criterio) {
    return switch (criterio) {
      _CriterioOrdenacao.calorias => refeicao.calorias.toDouble(),
      _CriterioOrdenacao.proteinas => refeicao.proteinas,
      _CriterioOrdenacao.carboidratos => refeicao.carboidratos,
      _CriterioOrdenacao.gorduras => refeicao.gorduras,
      _CriterioOrdenacao.avaliacao => refeicao.avaliacao.toDouble(),
    };
  }

  Future<void> _gerarPdf(List<Refeicao> refeicoes) async {
    if (refeicoes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum resultado para gerar PDF.')),
      );
      return;
    }

    try {
      await _pdfService.exportar(
        refeicoes: refeicoes,
        criterio: _criterio.rotulo,
        busca: _busca,
        avaliacao: _avaliacao,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel gerar o PDF.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refeicoes')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          if (widget.controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.controller.erro != null) {
            return _MensagemErro(
              mensagem: widget.controller.erro!,
              onTentarNovamente: widget.controller.carregarRefeicoes,
            );
          }

          if (widget.controller.refeicoes.isEmpty) {
            return const Center(child: Text('Nenhuma refeicao cadastrada'));
          }

          final refeicoes = _aplicarFiltros(widget.controller.refeicoes);

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: refeicoes.isEmpty ? 2 : refeicoes.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _FiltrosRefeicoes(
                  buscaController: _buscaController,
                  busca: _busca,
                  criterio: _criterio,
                  avaliacao: _avaliacao,
                  quantidadeResultados: refeicoes.length,
                  onBuscaAlterada: (valor) => setState(() => _busca = valor),
                  onCriterioAlterado: (valor) {
                    if (valor == null) return;
                    setState(() => _criterio = valor);
                  },
                  onAvaliacaoAlterada: (valor) =>
                      setState(() => _avaliacao = valor),
                  onGerarPdf: () => _gerarPdf(refeicoes),
                );
              }

              if (refeicoes.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(child: Text('Nenhuma refeicao encontrada')),
                );
              }

              final Refeicao refeicao = refeicoes[index - 1];

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
                            await widget.controller.remover(refeicao.id!);
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
              builder: (_) =>
                  TelaAdicionarRefeicao(controller: widget.controller),
            ),
          );

          if (salvou == true) {
            widget.onRefeicaoSalva?.call();
          }
        },
      ),
    );
  }
}

enum _CriterioOrdenacao {
  calorias('Maior calorias'),
  proteinas('Maior proteinas'),
  carboidratos('Maior carboidratos'),
  gorduras('Maior gorduras'),
  avaliacao('Melhor avaliacao');

  final String rotulo;

  const _CriterioOrdenacao(this.rotulo);
}

class _FiltrosRefeicoes extends StatelessWidget {
  final TextEditingController buscaController;
  final String busca;
  final _CriterioOrdenacao criterio;
  final int? avaliacao;
  final int quantidadeResultados;
  final ValueChanged<String> onBuscaAlterada;
  final ValueChanged<_CriterioOrdenacao?> onCriterioAlterado;
  final ValueChanged<int?> onAvaliacaoAlterada;
  final VoidCallback onGerarPdf;

  const _FiltrosRefeicoes({
    required this.buscaController,
    required this.busca,
    required this.criterio,
    required this.avaliacao,
    required this.quantidadeResultados,
    required this.onBuscaAlterada,
    required this.onCriterioAlterado,
    required this.onAvaliacaoAlterada,
    required this.onGerarPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: buscaController,
              onChanged: onBuscaAlterada,
              decoration: InputDecoration(
                labelText: 'Buscar refeicao',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: busca.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Limpar busca',
                        onPressed: () {
                          buscaController.clear();
                          onBuscaAlterada('');
                        },
                      ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<_CriterioOrdenacao>(
              initialValue: criterio,
              decoration: const InputDecoration(
                labelText: 'Ordenar por',
                prefixIcon: Icon(Icons.filter_list),
              ),
              items: _CriterioOrdenacao.values.map((item) {
                return DropdownMenuItem(value: item, child: Text(item.rotulo));
              }).toList(),
              onChanged: onCriterioAlterado,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: avaliacao,
              decoration: const InputDecoration(
                labelText: 'Filtrar por nota',
                prefixIcon: Icon(Icons.star),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todas as notas'),
                ),
                ...List.generate(5, (index) {
                  final nota = index + 1;
                  return DropdownMenuItem<int?>(
                    value: nota,
                    child: Text('$nota estrela(s)'),
                  );
                }),
              ],
              onChanged: onAvaliacaoAlterada,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$quantidadeResultados resultado(s)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: onGerarPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF'),
                ),
              ],
            ),
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
