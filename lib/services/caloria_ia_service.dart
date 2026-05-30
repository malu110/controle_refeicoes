import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/estimativa_nutricional.dart';

class CaloriaIaService {
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyDlTD_iLDImReKxJP8r8wO4838l6Psns5g',
  );

  Future<EstimativaNutricional> estimarNutrientes({
    required String refeicao,
    required int pesoGramas,
  }) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

      final prompt =
          '''
Estime os nutrientes totais de uma refeicao para controle de dieta.
Refeicao: "$refeicao"
Peso total aproximado: $pesoGramas gramas

Considere calorias, proteinas, carboidratos e gorduras.
Responda somente JSON valido neste formato:
{"calorias": 0, "proteinas": 0, "carboidratos": 0, "gorduras": 0}
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final cleanJson = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final data = jsonDecode(cleanJson) as Map<String, dynamic>;

      return EstimativaNutricional.fromMap(data);
    } catch (_) {
      return _estimarLocalmente(refeicao: refeicao, pesoGramas: pesoGramas);
    }
  }

  EstimativaNutricional _estimarLocalmente({
    required String refeicao,
    required int pesoGramas,
  }) {
    final nome = refeicao.toLowerCase();
    var kcalPor100g = 180.0;
    var proteinasPor100g = 8.0;
    var carboidratosPor100g = 22.0;
    var gordurasPor100g = 6.0;

    if (nome.contains('salada') || nome.contains('legume')) {
      kcalPor100g = 70;
      proteinasPor100g = 3;
      carboidratosPor100g = 10;
      gordurasPor100g = 2;
    } else if (nome.contains('frango') || nome.contains('peixe')) {
      kcalPor100g = 165;
      proteinasPor100g = 28;
      carboidratosPor100g = 0;
      gordurasPor100g = 5;
    } else if (nome.contains('arroz') || nome.contains('macarrao')) {
      kcalPor100g = 140;
      proteinasPor100g = 4;
      carboidratosPor100g = 28;
      gordurasPor100g = 1;
    } else if (nome.contains('pizza') ||
        nome.contains('hamburguer') ||
        nome.contains('lanche')) {
      kcalPor100g = 285;
      proteinasPor100g = 12;
      carboidratosPor100g = 30;
      gordurasPor100g = 13;
    } else if (nome.contains('bolo') || nome.contains('doce')) {
      kcalPor100g = 360;
      proteinasPor100g = 5;
      carboidratosPor100g = 55;
      gordurasPor100g = 14;
    }

    final fator = pesoGramas / 100;

    return EstimativaNutricional(
      calorias: (kcalPor100g * fator).round(),
      proteinas: proteinasPor100g * fator,
      carboidratos: carboidratosPor100g * fator,
      gorduras: gordurasPor100g * fator,
    );
  }
}
