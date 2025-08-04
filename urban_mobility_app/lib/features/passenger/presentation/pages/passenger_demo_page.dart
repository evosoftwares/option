import 'package:flutter/material.dart';
import 'passenger_home_page.dart';

/// Página de demonstração da tela do passageiro
/// Mostra a tela em um container simulando um dispositivo móvel
class PassengerDemoPage extends StatelessWidget {
  const PassengerDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppBar(
        title: const Text('Demo - Tela do Passageiro'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: 375, // Largura típica de um iPhone
          height: 812, // Altura típica de um iPhone
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: const PassengerHomePage(),
        ),
      ),
    );
  }
}