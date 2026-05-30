import 'package:flutter/material.dart';

import 'database/database_service.dart';
import 'views/tela_splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.inicializar();

  runApp(const MealControlApp());
}

class MealControlApp extends StatelessWidget {
  const MealControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de Refeicoes',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const TelaSplash(),
    );
  }
}
