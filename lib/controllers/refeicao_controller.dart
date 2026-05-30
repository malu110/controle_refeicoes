import 'package:flutter/material.dart';

import '../models/estimativa_nutricional.dart';
import '../models/refeicao.dart';
import '../services/caloria_ia_service.dart';
import '../services/refeicao_service.dart';

class RefeicaoController extends ChangeNotifier {
  static const int metaCalorias = 2000;
  static const double metaProteinas = 150;
  static const double metaCarboidratos = 250;
  static const double metaGorduras = 70;

  final RefeicaoService _service = RefeicaoService();
  final CaloriaIaService _caloriaIaService = CaloriaIaService();

  List<Refeicao> _refeicoes = [];
  bool _carregando = false;
  bool _estimandoNutrientes = false;
  String? _erro;

  List<Refeicao> get refeicoes => List.unmodifiable(_refeicoes);
  bool get carregando => _carregando;
  bool get estimandoNutrientes => _estimandoNutrientes;
  String? get erro => _erro;

  int get totalCalorias {
    return _refeicoes.fold<int>(
      0,
      (total, refeicao) => total + refeicao.calorias,
    );
  }

  double get totalProteinas {
    return _refeicoes.fold<double>(
      0,
      (total, refeicao) => total + refeicao.proteinas,
    );
  }

  double get totalCarboidratos {
    return _refeicoes.fold<double>(
      0,
      (total, refeicao) => total + refeicao.carboidratos,
    );
  }

  double get totalGorduras {
    return _refeicoes.fold<double>(
      0,
      (total, refeicao) => total + refeicao.gorduras,
    );
  }

  Future<void> carregarRefeicoes() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _refeicoes = await _service.obterRefeicoes();
    } catch (_) {
      _erro = 'Nao foi possivel carregar as refeicoes.';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> adicionar({
    required String nome,
    required String descricao,
    required int calorias,
    required double proteinas,
    required double carboidratos,
    required double gorduras,
    required String data,
    required String local,
    required int avaliacao,
  }) async {
    final refeicao = Refeicao(
      nome: nome,
      descricao: descricao,
      calorias: calorias,
      proteinas: proteinas,
      carboidratos: carboidratos,
      gorduras: gorduras,
      dataRefeicao: data,
      local: local,
      avaliacao: avaliacao,
    );

    await _service.adicionarRefeicao(refeicao);
    await carregarRefeicoes();
  }

  Future<void> atualizar(Refeicao refeicao) async {
    await _service.atualizarRefeicao(refeicao);
    await carregarRefeicoes();
  }

  Future<void> remover(int id) async {
    await _service.deletarRefeicao(id);
    await carregarRefeicoes();
  }

  Future<EstimativaNutricional> estimarNutrientes({
    required String refeicao,
    required int pesoGramas,
  }) async {
    _estimandoNutrientes = true;
    notifyListeners();

    try {
      return await _caloriaIaService.estimarNutrientes(
        refeicao: refeicao,
        pesoGramas: pesoGramas,
      );
    } finally {
      _estimandoNutrientes = false;
      notifyListeners();
    }
  }
}
