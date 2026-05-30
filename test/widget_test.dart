import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renderiza texto base do aplicativo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Controle de Refeicoes'),
      ),
    );

    expect(find.text('Controle de Refeicoes'), findsOneWidget);
  });
}
