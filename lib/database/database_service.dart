import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  DatabaseService._();

  static Future<void> inicializar() async {
    await Supabase.initialize(
      url: 'https://bigzlijjduesmquipang.supabase.co',
      anonKey: 'sb_publishable_cTJQrhyKIMIgV_3tU2UPUw_m-qccIxA',
    );
  }
}
