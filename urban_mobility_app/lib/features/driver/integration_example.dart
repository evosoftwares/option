import 'package:flutter/material.dart';
import 'presentation/pages/driver_demo_page.dart';

/// Exemplo de como integrar a feature do motorista no app principal
///
/// Este arquivo demonstra diferentes formas de navegar para a tela do motorista
class DriverIntegrationExample {
  /// Navega para a tela principal do motorista (versão demo)
  static void navigateToDriverDemo(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const DriverDemoPage()));
  }

  /// Widget de botão para testar a feature do motorista
  static Widget buildTestButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () => navigateToDriverDemo(context),
        icon: const Icon(Icons.drive_eta),
        label: const Text('Testar Feature do Motorista'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// Card de demonstração para adicionar na home
  static Widget buildDemoCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.drive_eta,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feature do Motorista',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tela principal com controle de status, solicitações e estatísticas',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Funcionalidades implementadas:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Controle de status (Online/Offline)'),
                Text('• Recebimento de solicitações de viagem'),
                Text('• Dashboard de estatísticas'),
                Text('• Configuração de preços'),
                Text('• Informações do sistema'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => navigateToDriverDemo(context),
                child: const Text('Abrir Demo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para adicionar na home do app para testar a feature
class DriverFeatureTestWidget extends StatelessWidget {
  const DriverFeatureTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DriverIntegrationExample.buildDemoCard(context);
  }
}
