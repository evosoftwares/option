import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'confirm_pickup_screen.dart';

/// Página de exemplo para demonstrar a funcionalidade de confirmação de embarque
/// Esta página pode ser acessada através da rota '/transport-example'
class TransportExamplePage extends ConsumerWidget {
  const TransportExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplo - Confirmação de Embarque'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Funcionalidade de Confirmação de Embarque',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Esta implementação inclui:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildFeatureItem('📍', 'Google Maps integrado com dados reais'),
            _buildFeatureItem('🎯', 'Pin animado que responde ao movimento do mapa'),
            _buildFeatureItem('📍', 'Geocodificação reversa em tempo real'),
            _buildFeatureItem('🔍', 'Busca de endereços com autocompletar'),
            _buildFeatureItem('📱', 'Gerenciamento de permissões de localização'),
            _buildFeatureItem('⚡', 'Debounce para otimizar performance'),
            _buildFeatureItem('🎨', 'UI moderna com animações fluidas'),
            _buildFeatureItem('🏗️', 'Arquitetura limpa com Riverpod'),
            
            const SizedBox(height: 32),
            
            const Text(
              'Tecnologias utilizadas:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildTechItem('Google Maps Flutter'),
            _buildTechItem('Geolocator'),
            _buildTechItem('Geocoding'),
            _buildTechItem('Permission Handler'),
            _buildTechItem('Flutter Riverpod'),
            
            const Spacer(),
            
            // Botão para abrir a tela
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConfirmPickupScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Abrir Confirmação de Embarque',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Nota sobre configuração
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                border: Border.all(color: Colors.amber[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Certifique-se de configurar a API Key do Google Maps para funcionalidade completa.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String tech) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(
            tech,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}