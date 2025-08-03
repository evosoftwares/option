import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/hybrid_location_tracking_provider.dart';
import '../../domain/entities/location_data.dart';
import '../../domain/entities/tracking_config.dart';
import '../../domain/use_cases/get_current_location.dart';
import '../../domain/use_cases/start_location_tracking.dart';
import '../../domain/use_cases/stop_location_tracking.dart';

/// Exemplo de uso do sistema híbrido de localização
/// 
/// Demonstra como integrar o HybridLocationRepository
/// com a interface do usuário.
class HybridLocationExamplePage extends StatefulWidget {
  const HybridLocationExamplePage({super.key});

  @override
  State<HybridLocationExamplePage> createState() => _HybridLocationExamplePageState();
}

class _HybridLocationExamplePageState extends State<HybridLocationExamplePage> {
  EnhancedLocationData? _currentLocation;
  bool _isTracking = false;
  String _status = 'Pronto para iniciar';
  final List<EnhancedLocationData> _locationHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localização Híbrida'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $_status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_currentLocation != null) ...[
                      Text('Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}'),
                      Text('Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}'),
                      Text('Precisão: ${_currentLocation!.accuracy.toStringAsFixed(1)}m'),
                      Text('Fonte: ${_currentLocation!.source.name}'),
                      if (_currentLocation!.address != null)
                        Text('Endereço: ${_currentLocation!.address}'),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Controles
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('Obter Localização'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTracking ? _stopTracking : _startTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTracking ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_isTracking ? 'Parar' : 'Iniciar'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Histórico
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Histórico (${_locationHistory.length})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            onPressed: _clearHistory,
                            icon: const Icon(Icons.clear),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _locationHistory.length,
                        itemBuilder: (context, index) {
                          final location = _locationHistory[index];
                          return ListTile(
                            leading: Icon(
                              location.source == LocationSource.gps
                                  ? Icons.gps_fixed
                                  : Icons.network_check,
                              color: location.source == LocationSource.gps
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                            title: Text(
                              '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                            ),
                            subtitle: Text(
                              '${location.accuracy.toStringAsFixed(1)}m - ${_formatTime(location.timestamp)}',
                            ),
                            trailing: Text(location.source.name),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _status = 'Obtendo localização...');
      
      final useCase = context.read<GetCurrentLocationUseCase>();
      final location = await useCase.execute(const TrackingConfig());
      
      setState(() {
        _currentLocation = location;
        _status = 'Localização obtida';
      });
    } catch (e) {
      setState(() => _status = 'Erro: $e');
    }
  }

  Future<void> _startTracking() async {
    try {
      setState(() => _status = 'Iniciando rastreamento...');
      
      final useCase = context.read<StartLocationTrackingUseCase>();
      final stream = await useCase.execute(const TrackingConfig());
      
      stream.listen(
        (location) {
          setState(() {
            _currentLocation = location;
            _locationHistory.insert(0, location);
            _status = 'Rastreando (${_locationHistory.length} pontos)';
            
            // Limita o histórico a 50 pontos
            if (_locationHistory.length > 50) {
              _locationHistory.removeLast();
            }
          });
        },
        onError: (error) {
          setState(() => _status = 'Erro no rastreamento: $error');
        },
      );
      
      setState(() => _isTracking = true);
    } catch (e) {
      setState(() => _status = 'Erro ao iniciar: $e');
    }
  }

  Future<void> _stopTracking() async {
    try {
      final useCase = context.read<StopLocationTrackingUseCase>();
      await useCase.execute();
      
      setState(() {
        _isTracking = false;
        _status = 'Rastreamento parado';
      });
    } catch (e) {
      setState(() => _status = 'Erro ao parar: $e');
    }
  }

  void _clearHistory() {
    setState(() {
      _locationHistory.clear();
      _status = 'Histórico limpo';
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}';
  }
}

/// Widget principal que configura o provider e exibe a página
class HybridLocationApp extends StatelessWidget {
  const HybridLocationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Localização Híbrida',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HybridLocationTrackingProvider(
        child: HybridLocationExamplePage(),
      ),
    );
  }
}