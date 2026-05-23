class Refeicao {
  final String id;
  final String name;
  final String description;
  final String category;
  final int calories;
  final double proteins;
  final double carbs;
  final double fats;
  final String imageEmoji;
  final DateTime dateTime;
  final String? local;
  final double? avaliacao;

  Refeicao({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.imageEmoji,
    required this.dateTime,
    this.local,
    this.avaliacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'imageEmoji': imageEmoji,
      'dateTime': dateTime.toIso8601String(),
      'local': local,
      'avaliacao': avaliacao,
    };
  }

  factory Refeicao.fromJson(Map<String, dynamic> json) {
    return Refeicao(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      category: json['category'],
      calories: json['calories'],
      // Conversão segura para double para evitar erros de JSON
      proteins: (json['proteins'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      imageEmoji: json['imageEmoji'],
      dateTime: DateTime.parse(json['dateTime']),
      local: json['local'],
      avaliacao: json['avaliacao'] != null ? (json['avaliacao'] as num).toDouble() : null,
    );
  }
}