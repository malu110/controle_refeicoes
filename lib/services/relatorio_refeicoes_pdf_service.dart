import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/refeicao.dart';

class RelatorioRefeicoesPdfService {
  Future<void> exportar({
    required List<Refeicao> refeicoes,
    required String criterio,
    required String busca,
    required int? avaliacao,
  }) async {
    final bytes = await gerar(
      refeicoes: refeicoes,
      criterio: criterio,
      busca: busca,
      avaliacao: avaliacao,
    );

    final nomeArquivo =
        'relatorio_refeicoes_${DateTime.now().millisecondsSinceEpoch}.pdf';

    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: nomeArquivo);
      return;
    }

    final arquivo = await _salvarArquivoTemporario(bytes, nomeArquivo);

    if (defaultTargetPlatform == TargetPlatform.windows) {
      final resultado = await OpenFile.open(arquivo.path);

      if (resultado.type != ResultType.done) {
        throw Exception(resultado.message);
      }

      return;
    }

    if (_isMobile) {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(arquivo.path, mimeType: 'application/pdf', name: nomeArquivo),
          ],
          text: 'Relatorio de refeicoes',
        ),
      );
      return;
    }

    await OpenFile.open(arquivo.path);
  }

  Future<Uint8List> gerar({
    required List<Refeicao> refeicoes,
    required String criterio,
    required String busca,
    required int? avaliacao,
  }) async {
    final documento = pw.Document();
    final totais = _Totais.fromRefeicoes(refeicoes);

    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Text(
              'Relatorio de refeicoes',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Criterio: $criterio'),
            pw.Text('Busca: ${busca.trim().isEmpty ? 'Todas' : busca.trim()}'),
            pw.Text(
              'Nota: ${avaliacao == null ? 'Todas' : '$avaliacao estrela(s)'}',
            ),
            pw.Text('Total de resultados: ${refeicoes.length}'),
            pw.SizedBox(height: 18),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: const {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
                3: pw.FlexColumnWidth(1),
                4: pw.FlexColumnWidth(1),
                5: pw.FlexColumnWidth(1),
              },
              children: [
                _linhaTabela([
                  'Refeicao',
                  'Kcal',
                  'Prot.',
                  'Carb.',
                  'Gord.',
                  'Nota',
                ], destaque: true),
                ...refeicoes.map(
                  (refeicao) => _linhaTabela([
                    refeicao.nome,
                    refeicao.calorias.toString(),
                    refeicao.proteinas.toStringAsFixed(1),
                    refeicao.carboidratos.toStringAsFixed(1),
                    refeicao.gorduras.toStringAsFixed(1),
                    refeicao.avaliacao.toString(),
                  ]),
                ),
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              'Resumo',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Calorias: ${totais.calorias} kcal'),
            pw.Text('Proteinas: ${totais.proteinas.toStringAsFixed(1)} g'),
            pw.Text(
              'Carboidratos: ${totais.carboidratos.toStringAsFixed(1)} g',
            ),
            pw.Text('Gorduras: ${totais.gorduras.toStringAsFixed(1)} g'),
          ];
        },
      ),
    );

    return documento.save();
  }

  bool get _isMobile {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<File> _salvarArquivoTemporario(
    Uint8List bytes,
    String nomeArquivo,
  ) async {
    final diretorio = await getTemporaryDirectory();
    final arquivo = File(
      '${diretorio.path}${Platform.pathSeparator}$nomeArquivo',
    );
    return arquivo.writeAsBytes(bytes, flush: true);
  }

  pw.TableRow _linhaTabela(List<String> valores, {bool destaque = false}) {
    return pw.TableRow(
      decoration: destaque
          ? const pw.BoxDecoration(color: PdfColors.green100)
          : null,
      children: valores.map((valor) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            valor,
            style: destaque
                ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _Totais {
  final int calorias;
  final double proteinas;
  final double carboidratos;
  final double gorduras;

  const _Totais({
    required this.calorias,
    required this.proteinas,
    required this.carboidratos,
    required this.gorduras,
  });

  factory _Totais.fromRefeicoes(List<Refeicao> refeicoes) {
    return _Totais(
      calorias: refeicoes.fold(0, (total, item) => total + item.calorias),
      proteinas: refeicoes.fold(0, (total, item) => total + item.proteinas),
      carboidratos: refeicoes.fold(
        0,
        (total, item) => total + item.carboidratos,
      ),
      gorduras: refeicoes.fold(0, (total, item) => total + item.gorduras),
    );
  }
}
