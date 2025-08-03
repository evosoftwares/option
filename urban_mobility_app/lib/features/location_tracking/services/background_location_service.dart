import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:isar/isar.dart';

import '../data/models/location_point.dart';
import '../data/services/enhanced_location_service.dart';

/// Estados do serviço de localização em background
enum BackgroundServiceState {
  stopped,
  starting,
  running,
  paused,
  stopping,
  error,
}

/// Modos de rastreamento disponíveis
enum TrackingMode {
  eco,
  balanced,
  precise,
  adaptive,
}

/// Configurações do serviço de background
class BackgroundServiceConfig {
  final TrackingMode mode;
  final Duration updateInterval;
  final double distanceFilter;
  final LocationAccuracy accuracy;
  final bool enableBatching;
  final int maxBatchSize;
  final Duration syncInterval;
  final bool adaptiveMode;

  const BackgroundServiceConfig({
    this.mode = TrackingMode.adaptive,
    this.updateInterval = const Duration(seconds: 30),
    this.distanceFilter = 10.0,
    this.accuracy = LocationAccuracy.high,
    this.enableBatching = true,
    this.maxBatchSize = 50,
    this.syncInterval = const Duration(minutes: 5),
    this.adaptiveMode = true,
  });

  BackgroundServiceConfig copyWith({
    TrackingMode? mode,
    Duration? updateInterval,
    double? distanceFilter,
    LocationAccuracy? accuracy,
    bool? enableBatching,
    int? maxBatchSize,
    Duration? syncInterval,
    bool? adaptiveMode,
  }) {
    return BackgroundServiceConfig(
      mode: mode ?? this.mode,
      updateInterval: updateInterval ?? this.updateInterval,
      distanceFilter: distanceFilter ?? this.distanceFilter,
      accuracy: accuracy ?? this.accuracy,
      enableBatching: enableBatching ?? this.enableBatching,
      maxBatchSize: maxBatchSize ?? this.maxBatchSize,
      syncInterval: syncInterval ?? this.syncInterval,
      adaptiveMode: adaptiveMode ?? this.adaptiveMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'updateInterval': updateInterval.inMilliseconds,
      'distanceFilter': distanceFilter,
      'accuracy': accuracy.name,
      'enableBatching': enableBatching,
      'maxBatchSize': maxBatchSize,
      'syncInterval': syncInterval.inMilliseconds,
      'adaptiveMode': adaptiveMode,
    };
  }

  factory BackgroundServiceConfig.fromJson(Map<String, dynamic> json) {
    return BackgroundServiceConfig(
      mode: TrackingMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => TrackingMode.adaptive,
      ),
      updateInterval: Duration(milliseconds: json['updateInterval'] ?? 30000),
      distanceFilter: (json['distanceFilter'] ?? 10.0).toDouble(),
      accuracy: LocationAccuracy.values.firstWhere(
        (e) => e.name == json['accuracy'],
        orElse: () => LocationAccuracy.high,
      ),
      enableBatching: json['enableBatching'] ?? true,
      maxBatchSize: json['maxBatchSize'] ?? 50,
      syncInterval: Duration(milliseconds: json['syncInterval'] ?? 300000),
      adaptiveMode: json['adaptiveMode'] ?? true,
    );
  }
}

/// Estatísticas do serviço de background
class BackgroundServiceStats {
  final int totalPoints;
  final int syncedPoints;
  final int failedSyncs;
  final DateTime? lastSync;
  final Duration uptime;
  final double batteryUsage;
  final int networkRequests;

  const BackgroundServiceStats({
    this.totalPoints = 0,
    this.syncedPoints = 0,
    this.failedSyncs = 0,
    this.lastSync,
    this.uptime = Duration.zero,
    this.batteryUsage = 0.0,
    this.networkRequests = 0,
  });

  BackgroundServiceStats copyWith({
    int? totalPoints,
    int? syncedPoints,
    int? failedSyncs,
    DateTime? lastSync,
    Duration? uptime,
    double? batteryUsage,
    int? networkRequests,
  }) {
    return BackgroundServiceStats(
      totalPoints: totalPoints ?? this.totalPoints,
      syncedPoints: syncedPoints ?? this.syncedPoints,
      failedSyncs: failedSyncs ?? this.failedSyncs,
      lastSync: lastSync ?? this.lastSync,
      uptime: uptime ?? this.uptime,
      batteryUsage: batteryUsage ?? this.batteryUsage,
      networkRequests: networkRequests ?? this.networkRequests,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'syncedPoints': syncedPoints,
      'failedSyncs': failedSyncs,
      'lastSync': lastSync?.toIso8601String(),
      'uptime': uptime.inMilliseconds,
      'batteryUsage': batteryUsage,
      'networkRequests': networkRequests,
    };
  }
}

/// Serviço de localização em background
class BackgroundLocationService {
  static const String _serviceId = 'background_location_service';
  static const String _channelId = 'location_tracking_channel';
  static const int _notificationId = 1001;

  // Instância singleton
  static final BackgroundLocationService _instance = BackgroundLocationService._internal();
  factory BackgroundLocationService() => _instance;
  BackgroundLocationService._internal();

  // Estado do serviço
  BackgroundServiceState _state = BackgroundServiceState.stopped;
  BackgroundServiceConfig _config = const BackgroundServiceConfig();
  BackgroundServiceStats _stats = const BackgroundServiceStats();

  // Serviços
  FlutterBackgroundService? _backgroundService;
  StreamSubscription<Position>? _positionStream;
  Timer? _syncTimer;
  Timer? _adaptiveTimer;

  // Dados
  final List<LocationPoint> _locationBuffer = [];
  LocationPoint? _lastLocationPoint;
  DateTime? _serviceStartTime;

  // Getters
  BackgroundServiceState get state => _state;
  BackgroundServiceConfig get config => _config;
  BackgroundServiceStats get stats => _stats;
  bool get isRunning => _state == BackgroundServiceState.running;

  /// Inicializa o serviço de background
  Future<bool> initialize() async {
    try {
      _backgroundService = FlutterBackgroundService();
      
      await _backgroundService!.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: _onStart,
          autoStart: false,
          isForegroundMode: true,
          notificationChannelId: _channelId,
          initialNotificationTitle: 'Rastreamento de Localização',
          initialNotificationContent: 'Coletando dados de localização...',
          foregroundServiceNotificationId: _notificationId,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: _onStart,
          onBackground: _onIosBackground,
        ),
      );

      _updateState(BackgroundServiceState.stopped);
      debugPrint('✅ BackgroundLocationService inicializado');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao inicializar BackgroundLocationService: $e');
      _updateState(BackgroundServiceState.error);
      return false;
    }
  }

  /// Inicia o serviço de tracking
  Future<bool> start({BackgroundServiceConfig? config}) async {
    if (_state == BackgroundServiceState.running) {
      debugPrint('⚠️ Serviço já está rodando');
      return true;
    }

    try {
      _updateState(BackgroundServiceState.starting);
      
      if (config != null) {
        _config = config;
      }

      // Verificar permissões
      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        debugPrint('❌ Permissões de localização não concedidas');
        _updateState(BackgroundServiceState.error);
        return false;
      }

      // Iniciar serviço de background
      final started = await _backgroundService?.startService() ?? false;
      if (!started) {
        debugPrint('❌ Falha ao iniciar serviço de background');
        _updateState(BackgroundServiceState.error);
        return false;
      }

      _serviceStartTime = DateTime.now();
      _updateState(BackgroundServiceState.running);
      
      // Iniciar coleta de localização
      await _startLocationTracking();
      
      // Iniciar timers
      _startTimers();

      debugPrint('✅ BackgroundLocationService iniciado');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao iniciar BackgroundLocationService: $e');
      _updateState(BackgroundServiceState.error);
      return false;
    }
  }

  /// Para o serviço de tracking
  Future<void> stop() async {
    if (_state == BackgroundServiceState.stopped) {
      return;
    }

    try {
      _updateState(BackgroundServiceState.stopping);
      
      // Parar timers
      _syncTimer?.cancel();
      _adaptiveTimer?.cancel();
      
      // Parar stream de localização
      await _positionStream?.cancel();
      
      // Sincronizar dados pendentes
      await _syncPendingData();
      
      // Parar serviço de background
      _backgroundService?.invoke('stopService');
      
      // Limpar estado
      _locationBuffer.clear();
      _lastLocationPoint = null;
      _serviceStartTime = null;
      
      _updateState(BackgroundServiceState.stopped);
      debugPrint('✅ BackgroundLocationService parado');
    } catch (e) {
      debugPrint('❌ Erro ao parar BackgroundLocationService: $e');
      _updateState(BackgroundServiceState.error);
    }
  }

  /// Pausa o serviço temporariamente
  Future<void> pause() async {
    if (_state != BackgroundServiceState.running) {
      return;
    }

    try {
      await _positionStream?.cancel();
      _syncTimer?.cancel();
      _adaptiveTimer?.cancel();
      
      _updateState(BackgroundServiceState.paused);
      debugPrint('⏸️ BackgroundLocationService pausado');
    } catch (e) {
      debugPrint('❌ Erro ao pausar BackgroundLocationService: $e');
    }
  }

  /// Resume o serviço após pausa
  Future<void> resume() async {
    if (_state != BackgroundServiceState.paused) {
      return;
    }

    try {
      await _startLocationTracking();
      _startTimers();
      
      _updateState(BackgroundServiceState.running);
      debugPrint('▶️ BackgroundLocationService resumido');
    } catch (e) {
      debugPrint('❌ Erro ao resumir BackgroundLocationService: $e');
    }
  }

  /// Atualiza a configuração do serviço
  Future<void> updateConfig(BackgroundServiceConfig newConfig) async {
    _config = newConfig;
    
    if (_state == BackgroundServiceState.running) {
      // Reiniciar tracking com nova configuração
      await _positionStream?.cancel();
      await _startLocationTracking();
    }
    
    debugPrint('🔧 Configuração atualizada: ${_config.mode.name}');
  }

  /// Força sincronização dos dados pendentes
  Future<bool> forcSync() async {
    try {
      await _syncPendingData();
      return true;
    } catch (e) {
      debugPrint('❌ Erro na sincronização forçada: $e');
      return false;
    }
  }

  /// Obtém estatísticas atuais do serviço
  BackgroundServiceStats getStats() {
    final uptime = _serviceStartTime != null 
        ? DateTime.now().difference(_serviceStartTime!)
        : Duration.zero;
    
    return _stats.copyWith(uptime: uptime);
  }

  // Métodos privados

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    // Configurar listeners do serviço
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
    
    service.on('updateConfig').listen((event) {
      final configData = event?['config'] as Map<String, dynamic>?;
      if (configData != null) {
        final config = BackgroundServiceConfig.fromJson(configData);
        BackgroundLocationService()._config = config;
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    // Processar dados em background no iOS
    try {
      await BackgroundLocationService()._syncPendingData();
      return true;
    } catch (e) {
      debugPrint('❌ Erro no background iOS: $e');
      return false;
    }
  }

  void _updateState(BackgroundServiceState newState) {
    _state = newState;
    debugPrint('🔄 Estado do serviço: ${newState.name}');
  }

  Future<bool> _checkPermissions() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      return requested != LocationPermission.denied && 
             requested != LocationPermission.deniedForever;
    }
    return permission != LocationPermission.deniedForever;
  }

  Future<void> _startLocationTracking() async {
    final settings = LocationSettings(
      accuracy: _config.accuracy,
      distanceFilter: _config.distanceFilter.round(),
      timeLimit: _config.updateInterval,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      _onLocationUpdate,
      onError: _onLocationError,
      cancelOnError: false,
    );
  }

  void _startTimers() {
    // Timer de sincronização
    _syncTimer = Timer.periodic(_config.syncInterval, (_) {
      _syncPendingData();
    });

    // Timer adaptativo (se habilitado)
    if (_config.adaptiveMode) {
      _adaptiveTimer = Timer.periodic(
        const Duration(minutes: 2),
        (_) => _adaptTrackingSettings(),
      );
    }
  }

  Future<void> _onLocationUpdate(Position position) async {
    try {
      // Criar LocationPoint
      final locationPoint = LocationPoint.create(
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        recordedAt: DateTime.now(),
      );

      // Verificar se é uma mudança significativa
      if (_lastLocationPoint == null || 
          locationPoint.hasSignificantChange(_lastLocationPoint)) {
        
        // Adicionar ao buffer
        _locationBuffer.add(locationPoint);
        _lastLocationPoint = locationPoint;
        
        // Atualizar estatísticas
        _stats = _stats.copyWith(
          totalPoints: _stats.totalPoints + 1,
        );

        // Verificar se precisa sincronizar
        if (_locationBuffer.length >= _config.maxBatchSize) {
          await _syncPendingData();
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao processar localização: $e');
    }
  }

  void _onLocationError(dynamic error) {
    debugPrint('❌ Erro no stream de localização: $error');
  }

  Future<void> _syncPendingData() async {
    if (_locationBuffer.isEmpty) return;

    try {
      // Salvar no Isar local
      final isar = await Isar.open(
        [LocationPointSchema, TrackingSessionSchema],
        directory: '',
      );
      await isar.writeTxn(() async {
        await isar.locationPoints.putAll(_locationBuffer);
      });

      // Tentar sincronizar com serviços remotos
      await _syncToRemoteServices();

      // Limpar buffer após sincronização bem-sucedida
      final syncedCount = _locationBuffer.length;
      _locationBuffer.clear();

      // Atualizar estatísticas
      _stats = _stats.copyWith(
        syncedPoints: _stats.syncedPoints + syncedCount,
        lastSync: DateTime.now(),
        networkRequests: _stats.networkRequests + 1,
      );

      debugPrint('✅ Sincronizados $syncedCount pontos');
    } catch (e) {
      debugPrint('❌ Erro na sincronização: $e');
      _stats = _stats.copyWith(
        failedSyncs: _stats.failedSyncs + 1,
      );
    }
  }

  Future<void> _syncToRemoteServices() async {
    // Implementar sincronização com Firebase/Supabase
    // usando o EnhancedLocationService
    try {
      final enhancedService = EnhancedLocationService.instance;
      // Delegar a sincronização para o serviço principal
      // enhancedService.syncLocationPoints(_locationBuffer);
    } catch (e) {
      debugPrint('⚠️ Erro na sincronização remota: $e');
      // Não falhar a sincronização local por erro remoto
    }
  }

  Future<void> _adaptTrackingSettings() async {
    if (!_config.adaptiveMode) return;

    try {
      // Implementar lógica adaptativa baseada em:
      // - Velocidade atual
      // - Nível de bateria
      // - Conectividade
      // - Padrões de movimento
      
      // Exemplo simples: reduzir frequência se bateria baixa
      // final battery = await Battery().batteryLevel;
      // if (battery < 20) {
      //   _config = _config.copyWith(
      //     updateInterval: Duration(minutes: 2),
      //     distanceFilter: 50.0,
      //   );
      // }
      
      debugPrint('🔧 Configurações adaptadas');
    } catch (e) {
      debugPrint('❌ Erro na adaptação: $e');
    }
  }
}