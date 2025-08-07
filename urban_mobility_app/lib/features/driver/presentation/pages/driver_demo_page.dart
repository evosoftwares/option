import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../driver_module.dart';
import '../../domain/repositories/driver_repository.dart';
import '../providers/driver_main_provider.dart';
import 'driver_main_page.dart';

/// Página de demonstração da tela principal do motorista
/// Esta página configura os providers necessários e exibe a tela principal
class DriverDemoPage extends StatelessWidget {
  const DriverDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = DriverModule.createRepository();

    return MultiProvider(
      providers: [
        Provider<DriverRepository>.value(value: repository),
        ChangeNotifierProvider<DriverMainProvider>(
          create: (_) => DriverModule.createMainProvider(repository),
        ),
      ],
      child: const DriverMainPage(),
    );
  }
}

/// Widget para navegar para a demo do motorista
class DriverDemoButton extends StatelessWidget {
  const DriverDemoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const DriverDemoPage()));
      },
      child: const Text('Demo - Tela Principal do Motorista'),
    );
  }
}
