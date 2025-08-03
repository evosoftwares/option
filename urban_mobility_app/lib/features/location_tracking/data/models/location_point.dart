import 'dart:math' as math;
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location_point.g.dart';

@collection
@JsonSerializable()
class LocationPoint {
  Id id = Isar.autoIncrement;

  @Index()
  late double lat;

  @Index()
  late double lng;

  late double accuracy;

  double? altitude;
  double? speed;
  double? heading;

  @Index()
  late DateTime recordedAt;

  DateTime createdAt = DateTime.now();

  // Metadados do dispositivo
  int? batteryLevel;
  String? activityType;
  String? networkType;

  // Status de sincronização
  @Index()
  bool syncedToSupabase = false;
  
  @Index()
  bool syncedToFirebase = false;

  DateTime? lastSyncAttempt;
  String? syncError;

  // Dados criptografados (opcional para dados sensíveis)
  String? encryptedMetadata;

  LocationPoint();

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint()
      ..lat = json['lat']?.toDouble() ?? 0.0
      ..lng = json['lng']?.toDouble() ?? 0.0
      ..accuracy = json['accuracy']?.toDouble() ?? 0.0
      ..altitude = json['altitude']?.toDouble()
      ..speed = json['speed']?.toDouble()
      ..heading = json['heading']?.toDouble()
      ..recordedAt = DateTime.parse(json['recordedAt'] ?? DateTime.now().toIso8601String())
      ..batteryLevel = json['batteryLevel']?.toInt()
      ..activityType = json['activityType']
      ..networkType = json['networkType']
      ..syncedToSupabase = json['syncedToSupabase'] ?? false
      ..syncedToFirebase = json['syncedToFirebase'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'recordedAt': recordedAt.toIso8601String(),
      'batteryLevel': batteryLevel,
      'activityType': activityType,
      'networkType': networkType,
      'syncedToSupabase': syncedToSupabase,
      'syncedToFirebase': syncedToFirebase,
    };
  }

  // Método para criar ponto de localização com validação
  factory LocationPoint.create({
    required double lat,
    required double lng,
    required double accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? recordedAt,
    int? batteryLevel,
    String? activityType,
    String? networkType,
  }) {
    // Validações básicas
    if (lat < -90 || lat > 90) {
      throw ArgumentError('Latitude deve estar entre -90 e 90');
    }
    if (lng < -180 || lng > 180) {
      throw ArgumentError('Longitude deve estar entre -180 e 180');
    }
    if (accuracy < 0) {
      throw ArgumentError('Accuracy não pode ser negativa');
    }

    return LocationPoint()
      ..lat = lat
      ..lng = lng
      ..accuracy = accuracy
      ..altitude = altitude
      ..speed = speed
      ..heading = heading
      ..recordedAt = recordedAt ?? DateTime.now()
      ..batteryLevel = batteryLevel
      ..activityType = activityType
      ..networkType = networkType;
  }

  // Calcular distância para outro ponto (em metros)
  double distanceTo(LocationPoint other) {
    const double earthRadius = 6371000; // metros
    
    final lat1Rad = lat * (3.14159265359 / 180);
    final lat2Rad = other.lat * (3.14159265359 / 180);
    final deltaLatRad = (other.lat - lat) * (3.14159265359 / 180);
    final deltaLngRad = (other.lng - lng) * (3.14159265359 / 180);

    final a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    
    final c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  // Verificar se é um ponto significativo comparado ao anterior
  bool isSignificantChange(LocationPoint? previous) {
    if (previous == null) return true;
    
    final distance = distanceTo(previous);
    final timeDiff = recordedAt.difference(previous.recordedAt).inSeconds;
    
    // Critérios para mudança significativa:
    // 1. Distância > 10 metros
    // 2. Mudança de atividade
    // 3. Intervalo > 5 minutos
    return distance > 10 || 
           activityType != previous.activityType ||
           timeDiff > 300;
  }

  @override
  String toString() {
    return 'LocationPoint(lat: $lat, lng: $lng, accuracy: $accuracy, '
           'recordedAt: $recordedAt, synced: $syncedToSupabase)';
  }
}

@collection
@JsonSerializable()
class TrackingSession {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String sessionId;

  @Index()
  late String userId;

  @Index()
  late DateTime startedAt;

  DateTime? endedAt;

  @Index()
  bool isActive = true;

  // Métricas da sessão
  double totalDistance = 0.0;
  int pointsCollected = 0;
  int batteryConsumed = 0;

  // Configurações da sessão
  String trackingMode = 'normal'; // normal, economy, high_precision
  int intervalSeconds = 30;
  double distanceFilter = 10.0;

  // Metadados
  Map<String, dynamic> deviceInfo = {};
  String? lastError;

  TrackingSession();

  factory TrackingSession.fromJson(Map<String, dynamic> json) {
    return TrackingSession()
      ..sessionId = json['sessionId'] ?? ''
      ..userId = json['userId'] ?? ''
      ..startedAt = DateTime.parse(json['startedAt'] ?? DateTime.now().toIso8601String())
      ..endedAt = json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null
      ..isActive = json['isActive'] ?? true
      ..totalDistance = json['totalDistance']?.toDouble() ?? 0.0
      ..pointsCollected = json['pointsCollected']?.toInt() ?? 0
      ..batteryConsumed = json['batteryConsumed']?.toInt() ?? 0
      ..trackingMode = json['trackingMode'] ?? 'normal'
      ..intervalSeconds = json['intervalSeconds']?.toInt() ?? 30
      ..distanceFilter = json['distanceFilter']?.toDouble() ?? 10.0
      ..deviceInfo = Map<String, dynamic>.from(json['deviceInfo'] ?? {})
      ..lastError = json['lastError'];
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'isActive': isActive,
      'totalDistance': totalDistance,
      'pointsCollected': pointsCollected,
      'batteryConsumed': batteryConsumed,
      'trackingMode': trackingMode,
      'intervalSeconds': intervalSeconds,
      'distanceFilter': distanceFilter,
      'deviceInfo': deviceInfo,
      'lastError': lastError,
    };
  }

  factory TrackingSession.create({
    required String userId,
    String? sessionId,
    String trackingMode = 'normal',
  }) {
    return TrackingSession()
      ..sessionId = sessionId ?? DateTime.now().millisecondsSinceEpoch.toString()
      ..userId = userId
      ..startedAt = DateTime.now()
      ..trackingMode = trackingMode;
  }

  Duration get duration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  void updateMetrics({
    double? additionalDistance,
    int? additionalPoints,
    int? batteryUsed,
  }) {
    if (additionalDistance != null) {
      totalDistance += additionalDistance;
    }
    if (additionalPoints != null) {
      pointsCollected += additionalPoints;
    }
    if (batteryUsed != null) {
      batteryConsumed += batteryUsed;
    }
  }
}