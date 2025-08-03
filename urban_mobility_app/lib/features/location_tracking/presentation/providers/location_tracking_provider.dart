import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/location_data.dart';
import '../../domain/entities/tracking_config.dart';
import '../../domain/entities/tracking_status.dart';
import '../../domain/use_cases/get_current_location.dart';
import '../../domain/use_cases/start_location_tracking.dart';
import '../../domain/use_cases/stop_location_tracking.dart';

/// Provider para gerenciamento de estado do rastreamento de localização
/// 
/// Implementa padrão MVVM/Provider para coordenar operações de localização
/// e manter estado reativo da UI.
class LocationTrackingProvider extends ChangeNotifier {

  LocationTrackingProvider(
    this._getCurrentLocationUseCase,
    this._startTrackingUseCase,
    this._stopTrackingUseCase,
  );
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final StartLocationTrackingUseCase _startTrackingUseCase;
  final StopLocationTrackingUseCase _stopTrackingUseCase;

  // Estado interno
  TrackingStatus _status = TrackingStatus.idle;
  EnhancedLocationData? _currentLocation;
  TrackingConfig _config = TrackingConfig.balanced();
  String? _errorMessage;
  StreamSubscription<EnhancedLocationData>? _trackingSubscription;
  final List<EnhancedLocationData> _locationHistory = [];
  final Map<String, dynamic> _statistics = {};

  // Getters públicos
  TrackingStatus get status => _status;
  EnhancedLocationData? get currentLocation => _currentLocation;
  TrackingConfig get config => _config;
  String? get errorMessage => _errorMessage;
  List<EnhancedLocationData> get locationHistory => List.unmodifiable(_locationHistory);
  Map<String, dynamic> get statistics => Map.unmodifiable(_statistics);

  // Getters de conveniência
  bool get isTracking => _status.isActive;
  bool get isPaused => _status.isPaused;
  bool get hasError => _status.hasError;
  bool get canStart => _status.canStart;
  bool get canPause => _status.canPause;
  bool get canStop => _status.canStop;
  bool get hasLocation => _currentLocation != null;
  bool get isLoading => _status == TrackingStatus.active && _currentLocation == null;

  /// Obtém a localização atual
  Future<void> getCurrentLocation([TrackingConfig? customConfig]) async {
    try {
      _setStatus(TrackingStatus.active);
      _clearError();

      final location = await _getCurrentLocationUseCase.execute(
        customConfig ?? _config,
      );

      _setCurrentLocation(location);
      _setStatus(TrackingStatus.idle);
    } catch (e) {
      _handleError(e);
    }
  }

  /// Inicia o rastreamento contínuo
  Future<void> startTracking([TrackingConfig? customConfig]) async {
    if (_status.isActive) {
      throw StateError('Rastreamento já está ativo');
    }

    try {
      _setStatus(TrackingStatus.active);
      _clearError();

      if (customConfig != null) {
        _config = customConfig;
      }

      final stream = await _startTrackingUseCase.execute(_config);
      
      _trackingSubscription = stream.listen(
        _onLocationUpdate,
        onError: _handleError,
        onDone: () => _setStatus(TrackingStatus.idle),
      );

    } catch (e) {
      _handleError(e);
    }
  }

  /// Para o rastreamento
  Future<void> stopTracking() async {
    if (!_status.isActive && !_status.isPaused) {
      return;
    }

    try {
      await _trackingSubscription?.cancel();
      _trackingSubscription = null;

      await _stopTrackingUseCase.execute();
      
      _setStatus(TrackingStatus.idle);
      _clearError();
    } catch (e) {
      _handleError(e);
    }
  }

  /// Pausa o rastreamento
  Future<void> pauseTracking() async {
    if (!_status.canPause) {
      return;
    }

    await _trackingSubscription?.cancel();
    _trackingSubscription = null;
    _setStatus(TrackingStatus.paused);
  }

  /// Resume o rastreamento
  Future<void> resumeTracking() async {
    if (!_status.isPaused) {
      return;
    }

    await startTracking(_config);
  }

  /// Atualiza a configuração do rastreamento
  void updateConfig(TrackingConfig newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  /// Limpa o histórico de localizações
  void clearHistory() {
    _locationHistory.clear();
    notifyListeners();
  }

  /// Obtém estatísticas de rastreamento
  Map<String, dynamic> getTrackingStatistics() {
    if (_locationHistory.isEmpty) {
      return {
        'totalDistance': 0.0,
        'averageSpeed': 0.0,
        'averageAccuracy': 0.0,
        'totalTime': Duration.zero,
      };
    }

    double totalDistance = 0.0;
    double totalSpeed = 0.0;
    double totalAccuracy = 0.0;
    int speedCount = 0;
    
    for (int i = 1; i < _locationHistory.length; i++) {
      final prev = _locationHistory[i - 1];
      final current = _locationHistory[i];
      
      totalDistance += prev.distanceTo(current);
      totalAccuracy += current.accuracy;
      
      if (current.speed != null && current.speed! > 0) {
        totalSpeed += current.speed! * 3.6; // Convert m/s to km/h
        speedCount++;
      }
    }

    final firstLocation = _locationHistory.first;
    final lastLocation = _locationHistory.last;
    final totalTime = lastLocation.timestamp.difference(firstLocation.timestamp);

    return {
      'totalDistance': totalDistance / 1000, // Convert to km
      'averageSpeed': speedCount > 0 ? totalSpeed / speedCount : 0.0,
      'averageAccuracy': totalAccuracy / _locationHistory.length,
      'totalTime': totalTime,
    };
  }

  /// Limpa mensagens de erro
  void clearError() {
    _clearError();
  }

  /// Calcula distância total percorrida
  double get totalDistance {
    if (_locationHistory.length < 2) return 0.0;

    double total = 0.0;
    for (int i = 1; i < _locationHistory.length; i++) {
      total += _locationHistory[i-1].distanceTo(_locationHistory[i]);
    }
    return total;
  }

  /// Calcula velocidade média
  double get averageSpeed {
    if (_locationHistory.isEmpty) return 0.0;

    final speeds = _locationHistory
        .where((location) => location.speed != null && location.speed! > 0)
        .map((location) => location.speed!)
        .toList();

    if (speeds.isEmpty) return 0.0;

    return speeds.reduce((a, b) => a + b) / speeds.length;
  }

  /// Calcula precisão média
  double get averageAccuracy {
    if (_locationHistory.isEmpty) return 0.0;

    final accuracies = _locationHistory.map((location) => location.accuracy);
    return accuracies.reduce((a, b) => a + b) / accuracies.length;
  }

  /// Tempo total de rastreamento
  Duration get totalTrackingTime {
    if (_locationHistory.length < 2) return Duration.zero;

    final first = _locationHistory.first.timestamp;
    final last = _locationHistory.last.timestamp;
    return last.difference(first);
  }

  // Métodos privados

  void _onLocationUpdate(EnhancedLocationData location) {
    _setCurrentLocation(location);
    _addToHistory(location);
  }

  void _setCurrentLocation(EnhancedLocationData location) {
    _currentLocation = location;
    notifyListeners();
  }

  void _addToHistory(EnhancedLocationData location) {
    _locationHistory.add(location);
    
    // Limitar histórico para evitar uso excessivo de memória
    const maxHistorySize = 1000;
    if (_locationHistory.length > maxHistorySize) {
      _locationHistory.removeAt(0);
    }
    
    notifyListeners();
  }

  void _setStatus(TrackingStatus status) {
    if (_status != status) {
      _status = status;
      notifyListeners();
    }
  }

  void _handleError(dynamic error) {
    _errorMessage = error.toString();
    
    if (error.toString().contains('permission')) {
      _setStatus(TrackingStatus.permissionDenied);
    } else if (error.toString().contains('service')) {
      _setStatus(TrackingStatus.serviceDisabled);
    } else {
      _setStatus(TrackingStatus.error);
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    super.dispose();
  }
}