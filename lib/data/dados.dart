import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/refeicao.dart';
import '../models/comida.dart';

class Dados {
  static List<Refeicao> meals = [];
  
  static List<Map<String, dynamic>> weeklyProgress = [
    {'day': 'Seg', 'calories': 1800, 'goal': 2000},
    {'day': 'Ter', 'calories': 2100, 'goal': 2000},
    {'day': 'Qua', 'calories': 1500, 'goal': 2000},
    {'day': 'Qui', 'calories': 1950, 'goal': 2000},
    {'day': 'Sex', 'calories': 2200, 'goal': 2000},
    {'day': 'Sáb', 'calories': 2500, 'goal': 2000},
    {'day': 'Dom', 'calories': 1700, 'goal': 2000},
  ];

  static Map<String, int> dailyGoals = {
    'calories': 2000,
    'proteins': 150,
  };

  static List<Comida> foodItems = [
    Comida(id: '1', name: 'Arroz', caloriesPer100g: 130, proteinsPer100g: 2.7, carbsPer100g: 28.0, fatsPer100g: 0.3, emoji: '🍚', category: 'Carboidratos'),
    Comida(id: '2', name: 'Frango', caloriesPer100g: 165, proteinsPer100g: 31.0, carbsPer100g: 0.0, fatsPer100g: 3.6, emoji: '🍗', category: 'Proteínas'),
  ];

  static Future<void> salvarRefeicoes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(meals.map((m) => m.toMap()).toList());
    await prefs.setString('nutri_meals', jsonString);
  }

  static Future<void> carregarRefeicoes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('nutri_meals');
    if (jsonString != null) {
      final List<dynamic> list = jsonDecode(jsonString);
      meals = list.map((item) => Refeicao.fromJson(item)).toList();
    }
  }
}