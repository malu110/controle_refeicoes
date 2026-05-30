class EstimativaNutricional {
  final int calorias;
  final double proteinas;
  final double carboidratos;
  final double gorduras;

  const EstimativaNutricional({
    required this.calorias,
    required this.proteinas,
    required this.carboidratos,
    required this.gorduras,
  });

  factory EstimativaNutricional.fromMap(Map<String, dynamic> map) {
    return EstimativaNutricional(
      calorias: _intFromValue(map['calorias']),
      proteinas: _doubleFromValue(map['proteinas']),
      carboidratos: _doubleFromValue(map['carboidratos']),
      gorduras: _doubleFromValue(map['gorduras']),
    );
  }

  static int _intFromValue(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _doubleFromValue(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
