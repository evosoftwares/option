import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Dependências do módulo
import 'di/location_tracking_dependencies.dart';

// Tela principal
import 'presentation/screens/location_tracking_screen.dart';

// Provider necessário
import 'presentation/providers/location_tracking_provider.dart';

/// Exemplo de como integrar o sistema de rastreamento de localização
/// 
/// Este arquivo demonstra como configurar e usar o módulo completo
/// de rastreamento de localização em uma aplicação Flutter.
class LocationTrackingExample extends StatelessWidget {
  const LocationTrackingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Rastreamento de Localização',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MultiProvider(
        providers: LocationTrackingDependencies.getProviders(),
        child: const LocationTrackingScreen(),
      ),
    );
  }
}

/// Widget de demonstração para uso básico
class BasicLocationTrackingDemo extends StatelessWidget {
  const BasicLocationTrackingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Básico - Rastreamento'),
      ),
      body: MultiProvider(
        providers: LocationTrackingDependencies.getProviders(),
        child: const LocationTrackingScreen(),
      ),
    );
  }
}

/// Exemplo de uso com configuração personalizada
class CustomLocationTrackingDemo extends StatelessWidget {
  const CustomLocationTrackingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Personalizado - Rastreamento'),
        backgroundColor: Colors.green,
      ),
      body: MultiProvider(
        providers: LocationTrackingDependencies.getProviders(),
        child: Consumer<LocationTrackingProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Status personalizado
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: provider.isTracking ? Colors.green.shade100 : Colors.grey.shade100,
                  child: Text(
                    provider.isTracking 
                        ? '🟢 Rastreamento Ativo - ${provider.locationHistory.length} pontos'
                        : '⚪ Rastreamento Inativo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Tela principal
                const Expanded(
                  child: LocationTrackingScreen(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Exemplo de uso em uma página existente
class IntegratedLocationExample extends StatefulWidget {
  const IntegratedLocationExample({super.key});

  @override
  State<IntegratedLocationExample> createState() => _IntegratedLocationExampleState();
}

class _IntegratedLocationExampleState extends State<IntegratedLocationExample> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: LocationTrackingDependencies.getProviders(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('App com Rastreamento Integrado'),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            // Página principal do app
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home, size: 64, color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    'Página Principal',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Navegue para "Localização" para usar o rastreamento'),
                ],
              ),
            ),
            
            // Sistema de rastreamento
            LocationTrackingScreen(),
            
            // Outras páginas...
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Configurações',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Localização',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Configurações',
            ),
          ],
        ),
      ),
    );
  }
}

/// Exemplo de uso programático (sem UI)
class ProgrammaticLocationExample {
  static Future<void> demonstrateUsage() async {
    // Este exemplo mostra como usar o sistema programaticamente
    // sem interface gráfica, útil para serviços em background
    
    print('🚀 Demonstração do Sistema de Rastreamento');
    print('');
    
    // Simular inicialização
    print('📍 Inicializando sistema de localização...');
    await Future.delayed(const Duration(seconds: 1));
    
    print('✅ Sistema inicializado com sucesso!');
    print('');
    
    // Simular obtenção de localização
    print('🔍 Obtendo localização atual...');
    await Future.delayed(const Duration(seconds: 2));
    
    print('📍 Localização obtida:');
    print('   Latitude: -23.5505');
    print('   Longitude: -46.6333');
    print('   Precisão: ±5m');
    print('   Endereço: São Paulo, SP, Brasil');
    print('');
    
    // Simular rastreamento
    print('🎯 Iniciando rastreamento...');
    await Future.delayed(const Duration(seconds: 1));
    
    for (int i = 1; i <= 5; i++) {
      await Future.delayed(const Duration(seconds: 1));
      print('📊 Ponto $i registrado - Distância total: ${i * 0.1}km');
    }
    
    print('');
    print('⏹️ Parando rastreamento...');
    await Future.delayed(const Duration(seconds: 1));
    
    print('📈 Estatísticas finais:');
    print('   Pontos registrados: 5');
    print('   Distância total: 0.5km');
    print('   Tempo total: 5 segundos');
    print('   Velocidade média: 360 km/h (simulação)');
    print('');
    print('✅ Demonstração concluída!');
  }
}