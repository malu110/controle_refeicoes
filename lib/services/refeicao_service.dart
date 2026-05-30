import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/refeicao.dart';

class RefeicaoService {
  static const String _tabela = 'refeicoes';

  final _client = Supabase.instance.client;

  Future<List<Refeicao>> obterRefeicoes() async {
    final response = await _client
        .from(_tabela)
        .select()
        .order('id', ascending: false);

    return response.map<Refeicao>((item) => Refeicao.fromMap(item)).toList();
  }

  Future<void> adicionarRefeicao(Refeicao refeicao) async {
    await _client.from(_tabela).insert(refeicao.toMap());
  }

  Future<void> atualizarRefeicao(Refeicao refeicao) async {
    final id = refeicao.id;

    if (id == null) {
      throw ArgumentError('A refeicao precisa ter id para ser atualizada.');
    }

    await _client.from(_tabela).update(refeicao.toMap()).eq('id', id);
  }

  Future<void> deletarRefeicao(int id) async {
    await _client.from(_tabela).delete().eq('id', id);
  }
}
