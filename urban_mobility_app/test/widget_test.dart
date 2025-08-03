/*
  [Arquivo de Teste] Smoke test do app (widget_test)

  O que está sendo testado:
  - Renderização inicial do app (smoke) e presença de elementos-chave na UI.

  Dependências principais:
  - WidgetTester (flutter_test) para construção e consulta da árvore de widgets.
  - InDriverApp como entry point.

  Cobertura de cenários:
  - App inicializa sem exceções.
  - Título, mensagens de boas-vindas e navegação inferior são renderizados.
  - Seções iniciais esperadas (localização e corridas recentes) estão presentes.

  Observações:
  - Teste simples e determinístico sem interações complexas. AAA destacado.
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:urban_mobility_app/main.dart';

void main() {
  /// Smoke test garantindo que a árvore inicial carrega com elementos essenciais.
  testWidgets('InDriver app smoke test', (WidgetTester tester) async {
    // Arrange & Act: constrói o app e avança um frame
    await tester.pumpWidget(const InDriverApp());
    await tester.pump();

    // Assert: valida elementos de UI iniciais
    expect(find.text('InDriver'), findsOneWidget); // título
    expect(find.text('Encontre sua corrida!'), findsOneWidget); // mensagem de boas-vindas

    // Navegação inferior
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Corridas'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    // Seções da tela inicial
    expect(find.text('Sua Localização'), findsOneWidget);
    expect(find.text('Corridas Recentes'), findsOneWidget);
  });
}
