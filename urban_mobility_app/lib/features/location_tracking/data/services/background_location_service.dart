import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../models/location_point.dart';
import 'enhanced_location_service.dart';

/// Estados do serviço de background
enum BackgroundServiceState {
  stopped,
  starting,
  running,
  paused,
  stopping,
  error,
}

/// Modos de operação do tracking
enum TrackingMode {
  eco,        // Máxima economia de bateria
  balanced,   // Equilibrio entre precisão e bateria
  precise,    // Máxima precisão
  adaptive,   // Adapta automaticamente
}

/// Configurações do serviço de background
class BackgroundServiceConfig {
  
  const BackgroundServiceConfig({
    this.mode = TrackingMode.adaptive,
    this.minInterval = const Duration(seconds: 5),
    this.maxInterval = const Duration(minutes: 5),
    this.minDistance = 10.0,
    this.accuracy = LocationAccuracy.medium,
    this.enableAdaptiveTracking = true,
    this.enableBatteryOptimization = true,
    this.enableMotionDetection = true,
    this.maxCachedPoints = 1000,
    this.syncInterval = const Duration(minutes: 5),
  });
  
  factory BackgroundServiceConfig.fromJson(Map<String, dynamic> json) {
    return BackgroundServiceConfig(
      mode: TrackingMode.values[json['mode'] ?? 3],
      minInterval: Duration(milliseconds: json['minInterval'] ?? 5000),
      maxInterval: Duration(milliseconds: json['maxInterval'] ?? 300000),
      minDistance: (json['minDistance'] ?? 10.0).toDouble(),
      accuracy: LocationAccuracy.values[json['accuracy'] ?? 3],
      enableAdaptiveTracking: json['enableAdaptiveTracking'] ?? true,
      enableBatteryOptimization: json['enableBatteryOptimization'] ?? true,
      enableMotionDetection: json['enableMotionDetection'] ?? true,
      maxCachedPoints: json['maxCachedPoints'] ?? 1000,
      syncInterval: Duration(milliseconds: json['syncInterval'] ?? 300000),
    );
  }
  final TrackingMode mode;
  final Duration minInterval;
  final Duration maxInterval;
  final double minDistance;
  final LocationAccuracy accuracy;
  final bool enableAdaptiveTracking;
  final bool enableBatteryOptimization;
  final bool enableMotionDetection;
  final int maxCachedPoints;
  final Duration syncInterval;
  
  Map<String, dynamic> toJson() => {
    'mode': mode.index,
    'minInterval': minInterval.inMilliseconds,
    'maxInterval': maxInterval.inMilliseconds,
    'minDistance': minDistance,
    'accuracy': accuracy.index,
    'enableAdaptiveTracking': enableAdaptiveTracking,
    'enableBatteryOptimization': enableBatteryOptimization,
    'enableMotionDetection': enableMotionDetection,
    'maxCachedPoints': maxCachedPoints,
    'syncInterval': syncInterval.inMilliseconds,
  };
}

/// Estatísticas do serviço de background
class BackgroundServiceStats {
  
  const BackgroundServiceStats({
    required this.startTime,
    required this.uptime,
    required this.pointsCollected,
    required this.pointsSynced,
    required this.syncErrors,
    required this.batteryUsage,
    required this.currentMode,
    this.lastSync,
    this.lastLocation,
  });
  final DateTime startTime;
  final Duration uptime;
  final int pointsCollected;
  final int pointsSynced;
  final int syncErrors;
  final double batteryUsage;
  final TrackingMode currentMode;
  final DateTime? lastSync;
  final DateTime? lastLocation;
  
  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'uptime': uptime.inMilliseconds,
    'pointsCollected': pointsCollected,
    'pointsSynced': pointsSynced,
    'syncErrors': syncErrors,
    'batteryUsage': batteryUsage,
    'currentMode': currentMode.index,
    'lastSync': lastSync?.toIso8601String(),
    'lastLocation': lastLocation?.toIso8601String(),
  };
}

/// Serviço de localização em background otimizado
class BackgroundLocationService {
  
  BackgroundLocationService._();
  static const String _serviceName = 'background_location_service';
  static const String _channelName = 'location_tracking_channel';
  static const String _notificationId = 'location_tracking_notification';
  
  // Chaves para comunicação entre isolates
  static const String _keyConfig = 'service_config';
  static const String _keyCommand = 'service_command';
  static const String _keyStats = 'service_stats';
  static const String _keyLocationUpdate = 'location_update';
  
  static final BackgroundLocationService _instance = BackgroundLocationService._();
  static BackgroundLocationService get instance => _instance;
  
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();
  BackgroundServiceState _state = BackgroundServiceState.stopped;
  BackgroundServiceConfig _config = const BackgroundServiceConfig();
  
  // Streams para comunicação
  final StreamController<BackgroundServiceState> _stateController = 
      StreamController<BackgroundServiceState>.broadcast();
  final StreamController<LocationPoint> _locationController = 
      StreamController<LocationPoint>.broadcast();
  final StreamController<BackgroundServiceStats> _statsController = 
      StreamController<BackgroundServiceStats>.broadcast();
  
  // Getters para streams
  Stream<BackgroundServiceState> get stateStream => _stateController.stream;
  Stream<LocationPoint> get locationStream => _locationController.stream;
  Stream<BackgroundServiceStats> get statsStream => _statsController.stream;
  
  BackgroundServiceState get state => _state;
  BackgroundServiceConfig get config => _config;
  
  /// Inicializa o serviço de background
  Future<void> initialize() async {
    try {
      await _backgroundService.configure(
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: _onStart,
          onBackground: _onIosBackground,
        ),
        androidConfiguration: AndroidConfiguration(
          autoStart: false,
          onStart: _onStart,
          isForegroundMode: true,
          autoStartOnBoot: false,
          notificationChannelId: _channelName,
          initialNotificationTitle: 'Rastreamento de Localização',
          initialNotificationContent: 'Coletando dados de localização...',
          foregroundServiceNotificationId: 888,
        ),
      );
      
      // Configurar listeners para comunicação
      _setupCommunication();
      
      debugPrint('✅ BackgroundLocationService inicializado');
      
    } catch (e) {
      debugPrint('❌ Erro ao inicializar BackgroundLocationService: $e');
      _updateState(BackgroundServiceState.error);
      rethrow;
    }
  }
  
  /// Inicia o serviço de tracking
  Future<bool> startTracking({
    BackgroundServiceConfig? config,
  }) async {
    if (_state == BackgroundServiceState.running) {
      debugPrint('⚠️ Serviço já está rodando');
      return true;
    }
    
    try {
      _updateState(BackgroundServiceState.starting);
      
      // Atualizar configuração se fornecida
      if (config != null) {
        _config = config;
        await _saveConfig();
      }
      
      // Verificar permissões
      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        _updateState(BackgroundServiceState.error);
        return false;
      }
      
      // Iniciar serviço
      final started = await _backgroundService.startService();
      
      if (started) {
        _updateState(BackgroundServiceState.running);
        debugPrint('✅ Serviço de tracking iniciado');
        return true;
      } else {
        _updateState(BackgroundServiceState.error);
        debugPrint('❌ Falha ao iniciar serviço de tracking');
        return false;
      }
      
    } catch (e) {
      debugPrint('❌ Erro ao iniciar tracking: $e');
      _updateState(BackgroundServiceState.error);
      return false;
    }
  }
  
  /// Para o serviço de tracking
  Future<bool> stopTracking() async {
    if (_state == BackgroundServiceState.stopped) {
      debugPrint('⚠️ Serviço já está parado');
      return true;
    }
    
    try {
      _updateState(BackgroundServiceState.stopping);
      
      _backgroundService.invoke('stop');
      _updateState(BackgroundServiceState.stopped);
      debugPrint('✅ Serviço de tracking parado');
      return true;
      
    } catch (e) {
      debugPrint('❌ Erro ao parar tracking: $e');
      return false;
    }
  }
  
  /// Pausa o tracking temporariamente
  Future<bool> pauseTracking() async {
    if (_state != BackgroundServiceState.running) {
      return false;
    }
    
    try {
      _backgroundService.invoke('pause');
      _updateState(BackgroundServiceState.paused);
      debugPrint('⏸️ Tracking pausado');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao pausar tracking: $e');
      return false;
    }
  }
  
  /// Resume o tracking
  Future<bool> resumeTracking() async {
    if (_state != BackgroundServiceState.paused) {
      return false;
    }
    
    try {
      _backgroundService.invoke('resume');
      _updateState(BackgroundServiceState.running);
      debugPrint('▶️ Tracking resumido');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao resumir tracking: $e');
      return false;
    }
  }
  
  /// Atualiza a configuração do serviço
  Future<bool> updateConfig(BackgroundServiceConfig newConfig) async {
    try {
      _config = newConfig;
      await _saveConfig();
      
      // Enviar nova configuração para o serviço
      if (_state == BackgroundServiceState.running) {
        _backgroundService.invoke('updateConfig', {
          'config': newConfig.toJson(),
        });
      }
      
      debugPrint('✅ Configuração atualizada');
      return true;
      
    } catch (e) {
      debugPrint('❌ Erro ao atualizar configuração: $e');
      return false;
    }
  }
  
  /// Força sincronização dos dados
  Future<bool> forcSync() async {
    if (_state != BackgroundServiceState.running) {
      return false;
    }
    
    try {
      _backgroundService.invoke('forceSync');
      debugPrint('🔄 Sincronização forçada');
      return true;
      
    } catch (e) {
      debugPrint('❌ Erro ao forçar sincronização: $e');
      return false;
    }
  }
  
  /// Obtém estatísticas do serviço
  Future<BackgroundServiceStats?> getStats() async {
    if (_state == BackgroundServiceState.stopped) {
      return null;
    }
    
    try {
      final result = _backgroundService.invoke('getStats');
      
      if (result != null && result is Map<String, dynamic>) {
        return BackgroundServiceStats(
          startTime: DateTime.parse(result['startTime']),
          uptime: Duration(milliseconds: result['uptime']),
          pointsCollected: result['pointsCollected'],
          pointsSynced: result['pointsSynced'],
          syncErrors: result['syncErrors'],
          batteryUsage: result['batteryUsage'].toDouble(),
          currentMode: TrackingMode.values[result['currentMode']],
          lastSync: result['lastSync'] != null 
              ? DateTime.parse(result['lastSync']) 
              : null,
          lastLocation: result['lastLocation'] != null 
              ? DateTime.parse(result['lastLocation']) 
              : null,
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Erro ao obter estatísticas: $e');
      return null;
    }
  }
  
  /// Verifica se o serviço está rodando
  Future<bool> isRunning() async {
    try {
      return await _backgroundService.isRunning();
    } catch (e) {
      debugPrint('❌ Erro ao verificar status do serviço: $e');
      return false;
    }
  }
  
  /// Limpa recursos
  void dispose() {
    _stateController.close();
    _locationController.close();
    _statsController.close();
  }
  
  // Métodos privados
  
  void _updateState(BackgroundServiceState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
      debugPrint('🔄 Estado do serviço: ${newState.name}');
    }
  }
  
  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyConfig, jsonEncode(_config.toJson()));
    } catch (e) {
      debugPrint('❌ Erro ao salvar configuração: $e');
    }
  }
  
  Future<BackgroundServiceConfig> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_keyConfig);
      
      if (configJson != null) {
        final configMap = jsonDecode(configJson) as Map<String, dynamic>;
        return BackgroundServiceConfig.fromJson(configMap);
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar configuração: $e');
    }
    
    return const BackgroundServiceConfig();
  }
  
  Future<bool> _checkPermissions() async {
    try {
      final permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('❌ Permissão de localização negada');
        return false;
      }
      
      if (permission == LocationPermission.whileInUse) {
        debugPrint('⚠️ Apenas permissão "while in use" - funcionalidade limitada');
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao verificar permissões: $e');
      return false;
    }
  }
  
  void _setupCommunication() {
    // Listener para atualizações de localização
    _backgroundService.on(_keyLocationUpdate).listen((event) {
      try {
        if (event != null) {
          final locationPoint = LocationPoint.fromJson(event);
          _locationController.add(locationPoint);
        }
      } catch (e) {
        debugPrint('❌ Erro ao processar atualização de localização: $e');
      }
    });
    
    // Listener para estatísticas
    _backgroundService.on(_keyStats).listen((event) {
      try {
        if (event != null) {
          final stats = BackgroundServiceStats(
            startTime: DateTime.parse(event['startTime']),
            uptime: Duration(milliseconds: event['uptime']),
            pointsCollected: event['pointsCollected'],
            pointsSynced: event['pointsSynced'],
            syncErrors: event['syncErrors'],
            batteryUsage: event['batteryUsage'].toDouble(),
            currentMode: TrackingMode.values[event['currentMode']],
            lastSync: event['lastSync'] != null 
                ? DateTime.parse(event['lastSync']) 
                : null,
            lastLocation: event['lastLocation'] != null 
                ? DateTime.parse(event['lastLocation']) 
                : null,
          );
          _statsController.add(stats);
        }
      } catch (e) {
        debugPrint('❌ Erro ao processar estatísticas: $e');
      }
    });
  }
  
  // Handlers do serviço de background
  
  @pragma('vm:entry-point')
  static Future<void> _onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    
    debugPrint('🚀 Serviço de background iniciado');
    
    // Carregar configuração
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_keyConfig);
    BackgroundServiceConfig config = const BackgroundServiceConfig();
    
    if (configJson != null) {
      try {
        final configMap = jsonDecode(configJson) as Map<String, dynamic>;
        config = BackgroundServiceConfig.fromJson(configMap);
      } catch (e) {
        debugPrint('❌ Erro ao carregar configuração: $e');
      }
    }
    
    // Inicializar tracking engine
    final trackingEngine = _BackgroundTrackingEngine(service, config);
    await trackingEngine.initialize();
    
    // Configurar handlers de comandos
    service.on('stop').listen((event) async {
      await trackingEngine.stop();
      service.stopSelf();
    });
    
    service.on('pause').listen((event) async {
      await trackingEngine.pause();
    });
    
    service.on('resume').listen((event) async {
      await trackingEngine.resume();
    });
    
    service.on('updateConfig').listen((event) async {
      if (event != null && event['config'] != null) {
        final newConfig = BackgroundServiceConfig.fromJson(event['config']);
        await trackingEngine.updateConfig(newConfig);
      }
    });
    
    service.on('forceSync').listen((event) async {
      await trackingEngine.forceSync();
    });
    
    service.on('getStats').listen((event) async {
      final stats = trackingEngine.getStats();
      service.invoke('getStats', stats.toJson());
    });
    
    // Iniciar tracking
    await trackingEngine.start();
  }
  
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    debugPrint('📱 Serviço iOS em background');
    return true;
  }
}

/// Engine de tracking que roda no isolate de background
class _BackgroundTrackingEngine {
  
  _BackgroundTrackingEngine(this.service, this.config) 
      : _currentMode = config.mode;
  final ServiceInstance service;
  BackgroundServiceConfig config;
  
  late EnhancedLocationService _locationService;
  Timer? _trackingTimer;
  Timer? _syncTimer;
  Timer? _statsTimer;
  
  bool _isRunning = false;
  bool _isPaused = false;
  DateTime? _startTime;
  int _pointsCollected = 0;
  int _pointsSynced = 0;
  int _syncErrors = 0;
  DateTime? _lastSync;
  DateTime? _lastLocationTime;
  TrackingMode _currentMode;
  
  // Adaptive tracking variables
  DateTime? _lastMovement;
  double _currentSpeed = 0.0;
  LocationPoint? _lastLocationPoint;
  
  Future<void> initialize() async {
    _locationService = EnhancedLocationService();
    await _locationService.initialize();
    
    debugPrint('✅ Background tracking engine inicializado');
  }
  
  Future<void> start() async {
    if (_isRunning) return;
    
    _isRunning = true;
    _isPaused = false;
    _startTime = DateTime.now();
    
    // Iniciar tracking de localização
    await _startLocationTracking();
    
    // Iniciar sincronização periódica
    _startPeriodicSync();
    
    // Iniciar envio de estatísticas
    _startStatsReporting();
    
    debugPrint('🎯 Tracking iniciado em background');
  }
  
  Future<void> stop() async {
    _isRunning = false;
    _isPaused = false;
    
    _trackingTimer?.cancel();
    _syncTimer?.cancel();
    _statsTimer?.cancel();
    
    // Sincronizar dados pendentes
    await _syncPendingData();
    
    debugPrint('🛑 Tracking parado');
  }
  
  Future<void> pause() async {
    _isPaused = true;
    _trackingTimer?.cancel();
    debugPrint('⏸️ Tracking pausado');
  }
  
  Future<void> resume() async {
    if (!_isRunning) return;
    
    _isPaused = false;
    await _startLocationTracking();
    debugPrint('▶️ Tracking resumido');
  }
  
  Future<void> updateConfig(BackgroundServiceConfig newConfig) async {
    config = newConfig;
    _currentMode = config.mode;
    
    if (_isRunning && !_isPaused) {
      // Reiniciar tracking com nova configuração
      _trackingTimer?.cancel();
      await _startLocationTracking();
    }
    
    debugPrint('⚙️ Configuração atualizada em background');
  }
  
  Future<bool> forceSync() async {
    try {
      await _syncPendingData();
      return true;
    } catch (e) {
      debugPrint('❌ Erro na sincronização forçada: $e');
      return false;
    }
  }
  
  BackgroundServiceStats getStats() {
    return BackgroundServiceStats(
      startTime: _startTime ?? DateTime.now(),
      uptime: _startTime != null 
          ? DateTime.now().difference(_startTime!) 
          : Duration.zero,
      pointsCollected: _pointsCollected,
      pointsSynced: _pointsSynced,
      syncErrors: _syncErrors,
      batteryUsage: _calculateBatteryUsage(),
      currentMode: _currentMode,
      lastSync: _lastSync,
      lastLocation: _lastLocationTime,
    );
  }
  
  // Métodos privados
  
  Future<void> _startLocationTracking() async {
    if (_isPaused || !_isRunning) return;
    
    final interval = _calculateOptimalInterval();
    
    _trackingTimer = Timer.periodic(interval, (timer) async {
      if (_isPaused || !_isRunning) {
        timer.cancel();
        return;
      }
      
      await _collectLocationPoint();
    });
  }
  
  Duration _calculateOptimalInterval() {
    switch (_currentMode) {
      case TrackingMode.eco:
        return config.maxInterval;
        
      case TrackingMode.balanced:
        return Duration(
          milliseconds: (config.minInterval.inMilliseconds + 
                        config.maxInterval.inMilliseconds) ~/ 2
        );
        
      case TrackingMode.precise:
        return config.minInterval;
        
      case TrackingMode.adaptive:
        return _calculateAdaptiveInterval();
    }
  }
  
  Duration _calculateAdaptiveInterval() {
    // Fatores para cálculo adaptativo:
    // 1. Velocidade atual
    // 2. Tempo desde último movimento
    // 3. Nível de bateria
    // 4. Conectividade
    
    var interval = config.minInterval;
    
    // Ajustar baseado na velocidade
    if (_currentSpeed < 1.0) { // Parado
      interval = Duration(
        milliseconds: (interval.inMilliseconds * 3).clamp(
          config.minInterval.inMilliseconds,
          config.maxInterval.inMilliseconds,
        ),
      );
    } else if (_currentSpeed > 15.0) { // Movimento rápido
      interval = config.minInterval;
    }
    
    // Ajustar baseado no tempo sem movimento
    if (_lastMovement != null) {
      final timeSinceMovement = DateTime.now().difference(_lastMovement!);
      if (timeSinceMovement.inMinutes > 5) {
        interval = Duration(
          milliseconds: (interval.inMilliseconds * 2).clamp(
            config.minInterval.inMilliseconds,
            config.maxInterval.inMilliseconds,
          ),
        );
      }
    }
    
    return interval;
  }
  
  Future<void> _collectLocationPoint() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: config.accuracy,
        timeLimit: const Duration(seconds: 10),
      );
      
      // Verificar se a localização mudou significativamente
      if (_lastLocationPoint != null) {
        final distance = _lastLocationPoint!.distanceTo(
          position.latitude,
          position.longitude,
        );
        
        if (distance < config.minDistance) {
          return; // Não mudou o suficiente
        }
        
        // Calcular velocidade
        final timeDiff = DateTime.now().difference(_lastLocationPoint!.timestamp);
        if (timeDiff.inSeconds > 0) {
          _currentSpeed = distance / timeDiff.inSeconds; // m/s
        }
      }
      
      // Criar ponto de localização
      final locationPoint = LocationPoint(
        id: DateTime.now().millisecondsSinceEpoch,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: DateTime.now(),
        deviceInfoJson: jsonEncode(await _getDeviceInfo()),
      );
      
      // Salvar localmente (simulado - implementar com Isar)
      // await _locationService.saveLocationPoint(locationPoint);
      
      _pointsCollected++;
      _lastLocationPoint = locationPoint;
      _lastLocationTime = DateTime.now();
      _lastMovement = DateTime.now();
      
      // Enviar para UI principal
      service.invoke('location_update', locationPoint.toJson());
      
      // Atualizar notificação
      await _updateNotification(locationPoint);
      
    } catch (e) {
      debugPrint('❌ Erro ao coletar localização: $e');
    }
  }
  
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(config.syncInterval, (timer) async {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      
      await _syncPendingData();
    });
  }
  
  Future<void> _syncPendingData() async {
    try {
      // Simular sincronização - implementar com serviço real
      const syncedCount = 5; // await _locationService.syncPendingData();
      _pointsSynced += syncedCount;
      _lastSync = DateTime.now();
      
      debugPrint('🔄 Sincronizados $syncedCount pontos');
      
    } catch (e) {
      _syncErrors++;
      debugPrint('❌ Erro na sincronização: $e');
    }
  }
  
  void _startStatsReporting() {
    _statsTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      
      final stats = getStats();
      service.invoke('stats', stats.toJson());
    });
  }
  
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': iosInfo.model,
          'version': iosInfo.systemVersion,
          'name': iosInfo.name,
        };
      }
    } catch (e) {
      debugPrint('❌ Erro ao obter info do dispositivo: $e');
    }
    
    return {
      'platform': Platform.operatingSystem,
      'error': 'Could not get device info',
    };
  }
  
  Future<void> _updateNotification(LocationPoint location) async {
    try {
      final content = 'Última localização: ${DateTime.now().toString().substring(11, 19)}';
      
      if (Platform.isAndroid) {
        service.setNotificationInfo(
          title: 'Rastreamento Ativo',
          content: content,
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar notificação: $e');
    }
  }
  
  double _calculateBatteryUsage() {
    // Estimativa simples baseada no tempo de execução e modo
    if (_startTime == null) return 0.0;
    
    final uptime = DateTime.now().difference(_startTime!);
    final hours = uptime.inHours.toDouble();
    
    // Estimativas por modo (% por hora)
    double usagePerHour;
    switch (_currentMode) {
      case TrackingMode.eco:
        usagePerHour = 0.5;
        break;
      case TrackingMode.balanced:
        usagePerHour = 1.0;
        break;
      case TrackingMode.precise:
        usagePerHour = 2.0;
        break;
      case TrackingMode.adaptive:
        usagePerHour = 0.8;
        break;
    }
    
    return hours * usagePerHour;
  }
}

/// Extensões para facilitar o uso
extension TrackingModeExtension on TrackingMode {
  String get displayName {
    switch (this) {
      case TrackingMode.eco:
        return 'Economia';
      case TrackingMode.balanced:
        return 'Equilibrado';
      case TrackingMode.precise:
        return 'Preciso';
      case TrackingMode.adaptive:
        return 'Adaptativo';
    }
  }
  
  String get description {
    switch (this) {
      case TrackingMode.eco:
        return 'Máxima economia de bateria, menor precisão';
      case TrackingMode.balanced:
        return 'Equilibrio entre bateria e precisão';
      case TrackingMode.precise:
        return 'Máxima precisão, maior uso de bateria';
      case TrackingMode.adaptive:
        return 'Adapta automaticamente baseado no contexto';
    }
  }
}

extension BackgroundServiceStateExtension on BackgroundServiceState {
  bool get isActive => this == BackgroundServiceState.running || 
                      this == BackgroundServiceState.paused;
  
  bool get canStart => this == BackgroundServiceState.stopped || 
                      this == BackgroundServiceState.error;
  
  bool get canStop => isActive || this == BackgroundServiceState.starting;
}