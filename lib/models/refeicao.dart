class Refeicao {
  int? id;
  String nome;
  String descricao;
  int calorias;
  double proteinas;
  double carboidratos;
  double gorduras;
  String dataRefeicao;
  String local;
  int avaliacao;

  Refeicao({
    this.id,
    required this.nome,
    required this.descricao,
    required this.calorias,
    required this.proteinas,
    required this.carboidratos,
    required this.gorduras,
    required this.dataRefeicao,
    required this.local,
    required this.avaliacao,
  });

  factory Refeicao.fromMap(Map<String, dynamic> map) {
    return Refeicao(
      id: map['id'] as int?,
      nome: map['nome'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
      calorias: _intFromValue(map['calorias']),
      proteinas: _doubleFromValue(map['proteinas']),
      carboidratos: _doubleFromValue(map['carboidratos']),
      gorduras: _doubleFromValue(map['gorduras']),
      dataRefeicao: map['data_refeicao'] as String? ?? '',
      local: map['local'] as String? ?? '',
      avaliacao: _intFromValue(map['avaliacao']).clamp(1, 5),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'descricao': descricao,
      'calorias': calorias,
      'proteinas': proteinas,
      'carboidratos': carboidratos,
      'gorduras': gorduras,
      'data_refeicao': dataRefeicao,
      'local': local,
      'avaliacao': avaliacao,
    };
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
