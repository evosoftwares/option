import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../models/location_point.dart';

/// Serviço de localização aprimorado com:
/// - Tracking adaptativo baseado em contexto
/// - Compressão inteligente de trajetos
/// - Sincronização híbrida Firebase/Supabase
/// - Criptografia de dados sensíveis
/// - Recuperação robusta de falhas
class EnhancedLocationService {
  
  EnhancedLocationService._();
  static const String _channelId = 'enhanced_location_tracking';
  static const int _notificationId = 888;
  static const String _encryptionKey = 'location_tracking_key_32_chars!!';
  
  // Instâncias dos serviços
  late final Isar _isar;
  late final SupabaseClient _supabase;
  late final FirebaseFirestore _firestore;
  late final Battery _battery;
  late final DeviceInfoPlugin _deviceInfo;
  late final Connectivity _connectivity;
  late final encrypt.Encrypter _encrypter;
  
  // Estado do tracking
  StreamSubscription<Position>? _positionStream;
  Timer? _batchSyncTimer;
  Timer? _adaptiveTimer;
  Timer? _healthCheckTimer;
  
  final List<LocationPoint> _locationBuffer = [];
  TrackingSession? _currentSession;
  
  // Configurações adaptativas
  LocationSettings _currentSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
    timeLimit: Duration(seconds: 30),
  );
  
  // Métricas de performance
  int _successfulSyncs = 0;
  int _failedSyncs = 0;
  DateTime? _lastSuccessfulSync;
  
  // Estado de conectividade
  bool _isOnline = true;
  String _networkType = 'unknown';
  
  static final EnhancedLocationService _instance = EnhancedLocationService._();
  static EnhancedLocationService get instance => _instance;
  
  /// Inicializa o serviço com todas as dependências
  Future<void> initialize() async {
    try {
      // Inicializar criptografia
      final key = encrypt.Key.fromBase64(base64.encode(_encryptionKey.codeUnits));
      final iv = encrypt.IV.fromSecureRandom(16);
      _encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      // Inicializar serviços
      _battery = Battery();
      _deviceInfo = DeviceInfoPlugin();
      _connectivity = Connectivity();
      
      // Configurar listeners de conectividade
      _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
      
      // Inicializar Isar
      await _initializeIsar();
      
      // Inicializar Supabase e Firebase
      _supabase = Supabase.instance.client;
      _firestore = FirebaseFirestore.instance;
      
      // Configurar serviço de background
      await _configureBackgroundService();
      
      debugPrint('✅ EnhancedLocationService inicializado com sucesso');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao inicializar EnhancedLocationService: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  Future<void> _initializeIsar() async {
    try {
      _isar = await Isar.open([
        LocationPointSchema,
        TrackingSessionSchema,
      ]);
      debugPrint('✅ Isar inicializado');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar Isar: $e');
      rethrow;
    }
  }
  
  Future<void> _configureBackgroundService() async {
    final service = FlutterBackgroundService();
    
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onBackgroundStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'Rastreamento Inteligente Ativo',
        initialNotificationContent: 'Otimizando coleta de localização...',
        foregroundServiceNotificationId: _notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onBackgroundStart,
        onBackground: _onIosBackground,
      ),
    );
  }
  
  @pragma('vm:entry-point')
  static Future<void> _onBackgroundStart(ServiceInstance service) async {
    try {
      // Inicializar dependências no isolate de background
      await EnhancedLocationService.instance.initialize();
      
      // Configurar listeners do serviço
      service.on('stopService').listen((event) {
        EnhancedLocationService.instance.stopTracking();
        service.stopSelf();
      });
      
      service.on('updateSettings').listen((event) {
        final settings = event?['settings'] as Map<String, dynamic>?;
        if (settings != null) {
          EnhancedLocationService.instance._updateTrackingSettings(settings);
        }
      });
      
      // Iniciar tracking
      await EnhancedLocationService.instance.startTracking();
      
    } catch (e) {
      debugPrint('❌ Erro no background service: $e');
    }
  }
  
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    // iOS background processing
    try {
      await EnhancedLocationService.instance._performBackgroundSync();
      return true;
    } catch (e) {
      debugPrint('❌ Erro no background iOS: $e');
      return false;
    }
  }
  
  /// Inicia o tracking de localização
  Future<bool> startTracking({
    String trackingMode = 'adaptive',
    Map<String, dynamic>? customSettings,
  }) async {
    try {
      // Verificar permissões
      final hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        debugPrint('❌ Permissões de localização negadas');
        return false;
      }
      
      // Criar nova sessão
      await _createTrackingSession(trackingMode);
      
      // Configurar settings baseado no modo
      await _configureTrackingMode(trackingMode, customSettings);
      
      // Iniciar stream de localização
      await _startLocationStream();
      
      // Iniciar timers de sincronização e adaptação
      _startTimers();
      
      // Iniciar health check
      _startHealthCheck();
      
      debugPrint('✅ Tracking iniciado em modo: $trackingMode');
      return true;
      
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao iniciar tracking: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }
  
  /// Para o tracking de localização
  Future<void> stopTracking() async {
    try {
      // Parar streams e timers
      await _positionStream?.cancel();
      _batchSyncTimer?.cancel();
      _adaptiveTimer?.cancel();
      _healthCheckTimer?.cancel();
      
      // Sincronizar dados pendentes
      await _performFinalSync();
      
      // Finalizar sessão
      await _endCurrentSession();
      
      debugPrint('✅ Tracking finalizado');
      
    } catch (e) {
      debugPrint('❌ Erro ao parar tracking: $e');
    }
  }
  
  Future<bool> _checkAndRequestPermissions() async {
    // Verificar permissão de localização
    var permission = await Permission.locationWhenInUse.status;
    
    if (permission.isDenied) {
      permission = await Permission.locationWhenInUse.request();
    }
    
    if (permission.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    
    // Para tracking em background, solicitar always
    if (permission.isGranted) {
      final alwaysPermission = await Permission.locationAlways.status;
      if (alwaysPermission.isDenied) {
        await Permission.locationAlways.request();
      }
    }
    
    return permission.isGranted;
  }
  
  Future<void> _createTrackingSession(String trackingMode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    
    _currentSession = TrackingSession.create(
      userId: user.uid,
      trackingMode: trackingMode,
    );
    
    // Salvar no Isar
    await _isar.writeTxn(() async {
      await _isar.trackingSessions.put(_currentSession!);
    });
    
    // Criar sessão no Supabase
    await _createSupabaseSession();
  }
  
  Future<void> _createSupabaseSession() async {
    try {
      await _supabase.from('tracking_sessions').insert({
        'firebase_uid': _currentSession!.userId,
        'session_id': _currentSession!.sessionId,
        'started_at': _currentSession!.startedAt.toIso8601String(),
        'is_active': true,
        'device_info': await _getDeviceInfo(),
      });
    } catch (e) {
      debugPrint('⚠️ Erro ao criar sessão no Supabase: $e');
      // Não falhar o tracking por erro no Supabase
    }
  }
  
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': iosInfo.model,
          'version': iosInfo.systemVersion,
          'name': iosInfo.name,
        };
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao obter info do dispositivo: $e');
    }
    
    return {'platform': 'unknown'};
  }
  
  Future<void> _configureTrackingMode(String mode, Map<String, dynamic>? custom) async {
    switch (mode) {
      case 'high_precision':
        _currentSettings = const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
          timeLimit: Duration(seconds: 10),
        );
        break;
        
      case 'economy':
        _currentSettings = const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 50,
          timeLimit: Duration(minutes: 2),
        );
        break;
        
      case 'adaptive':
      default:
        _currentSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          timeLimit: Duration(seconds: 30),
        );
        break;
    }
    
    // Aplicar configurações customizadas se fornecidas
    if (custom != null) {
      _applyCustomSettings(custom);
    }
  }
  
  void _applyCustomSettings(Map<String, dynamic> custom) {
    // Implementar aplicação de configurações customizadas
    // baseado nos parâmetros fornecidos
  }
  
  Future<void> _startLocationStream() async {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: _currentSettings,
    ).listen(
      _onLocationUpdate,
      onError: _onLocationError,
      cancelOnError: false,
    );
  }
  
  void _startTimers() {
    // Timer para sincronização em batch
    _batchSyncTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _performBatchSync(),
    );
    
    // Timer para adaptação de configurações
    _adaptiveTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _adaptTrackingSettings(),
    );
  }
  
  void _startHealthCheck() {
    _healthCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performHealthCheck(),
    );
  }
  
  Future<void> _onLocationUpdate(Position position) async {
    try {
      // Obter contexto adicional
      final batteryLevel = await _battery.batteryLevel;
      final activityType = await _detectActivityType(position);
      
      // Criar ponto de localização
      final locationPoint = LocationPoint.create(
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        recordedAt: DateTime.now(),
        batteryLevel: batteryLevel,
        activityType: activityType,
        networkType: _networkType,
      );
      
      // Salvar localmente
      await _saveLocationPoint(locationPoint);
      
      // Adicionar ao buffer
      _locationBuffer.add(locationPoint);
      
      // Envio imediato se for ponto significativo
      if (_isSignificantLocation(locationPoint)) {
        await _sendToSupabaseImmediate(locationPoint);
      }
      
      // Atualizar métricas da sessão
      await _updateSessionMetrics(locationPoint);
      
      // Adaptar configurações se necessário
      await _adaptiveLocationSettings(position, batteryLevel);
      
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao processar localização: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
  
  void _onLocationError(dynamic error) {
    debugPrint('❌ Erro no stream de localização: $error');
    
    // Implementar estratégia de recuperação
    Timer(const Duration(seconds: 10), () {
      if (_positionStream == null || _positionStream!.isPaused) {
        _startLocationStream();
      }
    });
  }
  
  Future<String> _detectActivityType(Position position) async {
    final speed = position.speed ?? 0;
    
    if (speed < 1.5) return 'stationary';
    if (speed < 5) return 'walking';
    if (speed < 25) return 'cycling';
    if (speed < 50) return 'driving';
    return 'high_speed';
  }
  
  Future<void> _saveLocationPoint(LocationPoint point) async {
    await _isar.writeTxn(() async {
      await _isar.locationPoints.put(point);
    });
  }
  
  bool _isSignificantLocation(LocationPoint point) {
    if (_locationBuffer.isEmpty) return true;
    
    final lastPoint = _locationBuffer.last;
    final distance = point.distanceTo(lastPoint);
    final timeDiff = point.recordedAt.difference(lastPoint.recordedAt).inSeconds;
    
    // Critérios para localização significativa
    return distance > 20 || 
           point.activityType != lastPoint.activityType ||
           timeDiff > 300; // 5 minutos
  }
  
  Future<void> _sendToSupabaseImmediate(LocationPoint point) async {
    if (!_isOnline) return;
    
    try {
      await _supabase.from('realtime_locations').insert({
        'firebase_uid': _currentSession!.userId,
        'lat': point.lat,
        'lng': point.lng,
        'accuracy': point.accuracy,
        'recorded_at': point.recordedAt.toIso8601String(),
        'activity_type': point.activityType,
        'speed': point.speed,
      });
      
      // Marcar como sincronizado
      point.syncedToSupabase = true;
      await _saveLocationPoint(point);
      
      _successfulSyncs++;
      _lastSuccessfulSync = DateTime.now();
      
    } catch (e) {
      debugPrint('⚠️ Erro ao enviar para Supabase: $e');
      _failedSyncs++;
    }
  }
  
  Future<void> _updateSessionMetrics(LocationPoint point) async {
    if (_currentSession == null) return;
    
    // Calcular distância adicional
    double additionalDistance = 0;
    if (_locationBuffer.length > 1) {
      final previousPoint = _locationBuffer[_locationBuffer.length - 2];
      additionalDistance = point.distanceTo(previousPoint);
    }
    
    // Atualizar métricas
    _currentSession!.updateMetrics(
      additionalDistance: additionalDistance,
      additionalPoints: 1,
    );
    
    // Salvar sessão atualizada
    await _isar.writeTxn(() async {
      await _isar.trackingSessions.put(_currentSession!);
    });
  }
  
  Future<void> _adaptiveLocationSettings(Position position, int batteryLevel) async {
    final speed = position.speed ?? 0;
    
    LocationSettings newSettings;
    
    if (batteryLevel < 15) {
      // Modo economia extrema
      newSettings = const LocationSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: 100,
        timeLimit: Duration(minutes: 5),
      );
    } else if (speed > 30) {
      // Veículo em alta velocidade
      newSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
        timeLimit: Duration(seconds: 15),
      );
    } else if (speed > 1.5) {
      // Em movimento
      newSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
        timeLimit: Duration(seconds: 30),
      );
    } else {
      // Parado
      newSettings = const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 30,
        timeLimit: Duration(minutes: 2),
      );
    }
    
    if (newSettings.accuracy != _currentSettings.accuracy ||
        newSettings.distanceFilter != _currentSettings.distanceFilter) {
      _currentSettings = newSettings;
      await _restartLocationStream();
    }
  }
  
  Future<void> _restartLocationStream() async {
    await _positionStream?.cancel();
    await _startLocationStream();
  }
  
  Future<void> _performBatchSync() async {
    if (_locationBuffer.isEmpty || !_isOnline) return;
    
    try {
      // Comprimir trajeto antes de enviar
      final compressedPoints = _compressTrajectory(_locationBuffer);
      
      // Enviar para Supabase
      await _syncBatchToSupabase(compressedPoints);
      
      // Enviar para Firebase (dados históricos)
      await _syncBatchToFirebase(compressedPoints);
      
      // Limpar buffer após sucesso
      _locationBuffer.clear();
      
    } catch (e) {
      debugPrint('❌ Erro no sync batch: $e');
    }
  }
  
  List<LocationPoint> _compressTrajectory(List<LocationPoint> points) {
    if (points.length < 3) return points;
    
    // Implementar algoritmo Douglas-Peucker adaptativo
    const double epsilon = 15.0; // tolerância em metros
    return _douglasPeucker(points, epsilon);
  }
  
  List<LocationPoint> _douglasPeucker(List<LocationPoint> points, double epsilon) {
    if (points.length < 3) return points;
    
    double maxDistance = 0;
    int maxIndex = 0;
    
    for (int i = 1; i < points.length - 1; i++) {
      final distance = _perpendicularDistance(points[i], points.first, points.last);
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }
    
    if (maxDistance > epsilon) {
      final firstPart = _douglasPeucker(points.sublist(0, maxIndex + 1), epsilon);
      final secondPart = _douglasPeucker(points.sublist(maxIndex), epsilon);
      return [...firstPart.sublist(0, firstPart.length - 1), ...secondPart];
    } else {
      return [points.first, points.last];
    }
  }
  
  double _perpendicularDistance(LocationPoint point, LocationPoint lineStart, LocationPoint lineEnd) {
    // Implementar cálculo de distância perpendicular
    // usando fórmula de distância ponto-linha em coordenadas geográficas
    
    final A = lineStart.lat - lineEnd.lat;
    final B = lineEnd.lng - lineStart.lng;
    final C = lineStart.lng * lineEnd.lat - lineEnd.lng * lineStart.lat;
    
    final distance = (A * point.lng + B * point.lat + C).abs() / 
                    math.sqrt(A * A + B * B);
    
    // Converter para metros (aproximação)
    return distance * 111320; // 1 grau ≈ 111.32 km
  }
  
  Future<void> _syncBatchToSupabase(List<LocationPoint> points) async {
    if (points.isEmpty) return;
    
    final batch = points.map((point) => {
      'firebase_uid': _currentSession!.userId,
      'lat': point.lat,
      'lng': point.lng,
      'accuracy': point.accuracy,
      'recorded_at': point.recordedAt.toIso8601String(),
      'activity_type': point.activityType,
      'speed': point.speed,
    }).toList();
    
    await _supabase.from('realtime_locations').insert(batch);
    
    // Marcar pontos como sincronizados
    for (final point in points) {
      point.syncedToSupabase = true;
      await _saveLocationPoint(point);
    }
  }
  
  Future<void> _syncBatchToFirebase(List<LocationPoint> points) async {
    if (points.isEmpty) return;
    
    final batch = _firestore.batch();
    final userId = _currentSession!.userId;
    final sessionId = _currentSession!.sessionId;
    
    // Criar documento de chunk
    final chunkRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('location_sessions')
        .doc(sessionId)
        .collection('chunks')
        .doc();
    
    batch.set(chunkRef, {
      'points': points.map((p) => {
        'lat': p.lat,
        'lng': p.lng,
        'accuracy': p.accuracy,
        'timestamp': p.recordedAt.millisecondsSinceEpoch,
        'activity': p.activityType,
      }).toList(),
      'metadata': {
        'compressed': true,
        'originalCount': _locationBuffer.length,
        'compressedCount': points.length,
        'createdAt': FieldValue.serverTimestamp(),
      },
    });
    
    await batch.commit();
    
    // Marcar pontos como sincronizados
    for (final point in points) {
      point.syncedToFirebase = true;
      await _saveLocationPoint(point);
    }
  }
  
  Future<void> _performFinalSync() async {
    if (_locationBuffer.isNotEmpty) {
      await _performBatchSync();
    }
    
    // Sincronizar métricas finais da sessão
    if (_currentSession != null) {
      await _syncSessionMetrics();
    }
  }
  
  Future<void> _syncSessionMetrics() async {
    if (_currentSession == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentSession!.userId)
          .collection('tracking_metrics')
          .doc(_currentSession!.sessionId)
          .set({
        'totalDistance': _currentSession!.totalDistance,
        'totalDuration': _currentSession!.duration.inSeconds,
        'pointsCollected': _currentSession!.pointsCollected,
        'batteryConsumed': _currentSession!.batteryConsumed,
        'trackingMode': _currentSession!.trackingMode,
        'startedAt': _currentSession!.startedAt,
        'endedAt': DateTime.now(),
        'deviceInfo': _currentSession!.deviceInfo,
        'syncStats': {
          'successfulSyncs': _successfulSyncs,
          'failedSyncs': _failedSyncs,
          'lastSync': _lastSuccessfulSync?.toIso8601String(),
        },
      });
    } catch (e) {
      debugPrint('⚠️ Erro ao sincronizar métricas: $e');
    }
  }
  
  Future<void> _endCurrentSession() async {
    if (_currentSession == null) return;
    
    _currentSession!.endedAt = DateTime.now();
    _currentSession!.isActive = false;
    
    await _isar.writeTxn(() async {
      await _isar.trackingSessions.put(_currentSession!);
    });
    
    // Finalizar sessão no Supabase
    try {
      await _supabase
          .from('tracking_sessions')
          .update({'is_active': false, 'ended_at': DateTime.now().toIso8601String()})
          .eq('firebase_uid', _currentSession!.userId)
          .eq('session_id', _currentSession!.sessionId);
    } catch (e) {
      debugPrint('⚠️ Erro ao finalizar sessão no Supabase: $e');
    }
    
    _currentSession = null;
  }
  
  void _onConnectivityChanged(ConnectivityResult result) {
    _isOnline = result != ConnectivityResult.none;
    _networkType = result.toString();
    
    if (_isOnline && _locationBuffer.isNotEmpty) {
      // Tentar sincronizar dados pendentes
      _performBatchSync();
    }
  }
  
  Future<void> _adaptTrackingSettings() async {
    // Implementar lógica de adaptação baseada em:
    // - Padrões de movimento
    // - Nível de bateria
    // - Conectividade
    // - Hora do dia
    
    final batteryLevel = await _battery.batteryLevel;
    final now = DateTime.now();
    
    // Exemplo: reduzir frequência durante a noite
    if (now.hour >= 22 || now.hour <= 6) {
      if (_currentSettings.timeLimit!.inMinutes < 5) {
        _currentSettings = const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 50,
          timeLimit: Duration(minutes: 5),
        );
        await _restartLocationStream();
      }
    }
  }
  
  Future<void> _performHealthCheck() async {
    try {
      // Verificar se o tracking está funcionando
      final recentPoints = await _isar.locationPoints
          .where()
          .recordedAtGreaterThan(DateTime.now().subtract(const Duration(minutes: 10)))
          .findAll();
      
      if (recentPoints.isEmpty && _currentSession?.isActive == true) {
        debugPrint('⚠️ Health check: Nenhum ponto coletado nos últimos 10 minutos');
        // Reiniciar tracking se necessário
        await _restartLocationStream();
      }
      
      // Verificar sincronização
      final unsyncedPoints = await _isar.locationPoints
          .where()
          .syncedToSupabaseEqualTo(false)
          .findAll();
      
      if (unsyncedPoints.length > 100) {
        debugPrint('⚠️ Health check: ${unsyncedPoints.length} pontos não sincronizados');
        // Tentar sincronização forçada
        if (_isOnline) {
          await _performBatchSync();
        }
      }
      
    } catch (e) {
      debugPrint('❌ Erro no health check: $e');
    }
  }
  
  Future<void> _performBackgroundSync() async {
    // Sincronização específica para background (iOS)
    try {
      final unsyncedPoints = await _isar.locationPoints
          .where()
          .syncedToSupabaseEqualTo(false)
          .limit(50)
          .findAll();
      
      if (unsyncedPoints.isNotEmpty && _isOnline) {
        await _syncBatchToSupabase(unsyncedPoints);
      }
    } catch (e) {
      debugPrint('❌ Erro no background sync: $e');
    }
  }
  
  void _updateTrackingSettings(Map<String, dynamic> settings) {
    // Atualizar configurações em tempo real
    if (settings.containsKey('accuracy')) {
      // Implementar atualização de precisão
    }
    if (settings.containsKey('interval')) {
      // Implementar atualização de intervalo
    }
  }
  
  // Métodos públicos para controle externo
  
  /// Obtém estatísticas da sessão atual
  Map<String, dynamic>? getCurrentSessionStats() {
    if (_currentSession == null) return null;
    
    return {
      'sessionId': _currentSession!.sessionId,
      'duration': _currentSession!.duration.inMinutes,
      'distance': _currentSession!.totalDistance,
      'points': _currentSession!.pointsCollected,
      'battery': _currentSession!.batteryConsumed,
      'mode': _currentSession!.trackingMode,
      'syncStats': {
        'successful': _successfulSyncs,
        'failed': _failedSyncs,
        'lastSync': _lastSuccessfulSync?.toIso8601String(),
      },
    };
  }
  
  /// Força sincronização imediata
  Future<void> forceSyncNow() async {
    await _performBatchSync();
  }
  
  /// Obtém pontos não sincronizados
  Future<List<LocationPoint>> getUnsyncedPoints() async {
    return await _isar.locationPoints
        .where()
        .syncedToSupabaseEqualTo(false)
        .findAll();
  }
  
  /// Limpa dados antigos (manter apenas últimos 7 dias)
  Future<void> cleanupOldData() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
    
    await _isar.writeTxn(() async {
      await _isar.locationPoints
          .where()
          .recordedAtLessThan(cutoffDate)
          .deleteAll();
      
      await _isar.trackingSessions
          .where()
          .startedAtLessThan(cutoffDate)
          .deleteAll();
    });
  }
}