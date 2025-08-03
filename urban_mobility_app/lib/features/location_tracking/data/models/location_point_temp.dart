import 'dart:convert';
import 'dart:math' as math;

// Versão temporária sem Isar para testar o aplicativo
class LocationPoint {
  int? id;
  
  // Coordenadas
  late double lat;
  late double lng;
  late double accuracy;
  double? altitude;
  double? speed;
  double? heading;
  
  // Timestamps
  late DateTime recordedAt;
  DateTime? syncedAt;
  
  // Metadados
  String? activityType;
  bool isValid = true;
  String? lastError;
  
  // Informações do dispositivo
  String? deviceInfoJson;
  String? networkType;
  int? batteryLevel;
  
  // Sincronização
  bool syncedToFirebase = false;
  bool syncedToSupabase = false;

  LocationPoint({
    this.id,
    required this.lat,
    required this.lng,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.recordedAt,
    this.syncedAt,
    this.activityType,
    this.isValid = true,
    this.lastError,
    this.deviceInfoJson,
    this.networkType,
    this.batteryLevel,
    this.syncedToFirebase = false,
    this.syncedToSupabase = false,
  });

  // Conversão para Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lat': lat,
      'lng': lng,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'recordedAt': recordedAt.millisecondsSinceEpoch,
      'syncedAt': syncedAt?.millisecondsSinceEpoch,
      'activityType': activityType,
      'isValid': isValid ? 1 : 0,
      'lastError': lastError,
      'deviceInfoJson': deviceInfoJson,
      'networkType': networkType,
      'batteryLevel': batteryLevel,
      'syncedToFirebase': syncedToFirebase ? 1 : 0,
      'syncedToSupabase': syncedToSupabase ? 1 : 0,
    };
  }

  // Conversão de Map (do SQLite)
  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      id: map['id'],
      lat: map['lat']?.toDouble() ?? 0.0,
      lng: map['lng']?.toDouble() ?? 0.0,
      accuracy: map['accuracy']?.toDouble() ?? 0.0,
      altitude: map['altitude']?.toDouble(),
      speed: map['speed']?.toDouble(),
      heading: map['heading']?.toDouble(),
      recordedAt: DateTime.fromMillisecondsSinceEpoch(map['recordedAt'] ?? 0),
      syncedAt: map['syncedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['syncedAt']) 
          : null,
      activityType: map['activityType'],
      isValid: (map['isValid'] ?? 1) == 1,
      lastError: map['lastError'],
      deviceInfoJson: map['deviceInfoJson'],
      networkType: map['networkType'],
      batteryLevel: map['batteryLevel'],
      syncedToFirebase: (map['syncedToFirebase'] ?? 0) == 1,
      syncedToSupabase: (map['syncedToSupabase'] ?? 0) == 1,
    );
  }

  // Conversão para JSON
  Map<String, dynamic> toJson() => toMap();

  // Conversão de JSON
  factory LocationPoint.fromJson(Map<String, dynamic> json) => LocationPoint.fromMap(json);

  // Cálculo de distância entre dois pontos
  double distanceTo(LocationPoint other) {
    return math.sqrt(
      math.pow(lat - other.lat, 2) + math.pow(lng - other.lng, 2)
    ) * 111000; // Aproximação em metros
  }

  @override
  String toString() {
    return 'LocationPoint(lat: $lat, lng: $lng, accuracy: $accuracy, recordedAt: $recordedAt)';
  }
}

// Versão temporária da TrackingSession sem Isar
class TrackingSession {
  int? id;
  
  // Identificadores
  late String sessionId;
  late String userId;
  
  // Timestamps
  late DateTime startedAt;
  DateTime? endedAt;
  
  // Configuração
  String trackingMode = 'adaptive';
  bool isActive = true;
  
  // Métricas
  double totalDistance = 0.0;
  int pointsCollected = 0;
  int batteryConsumed = 0;
  
  // Informações do dispositivo
  String? deviceInfoJson;

  TrackingSession({
    this.id,
    required this.sessionId,
    required this.userId,
    required this.startedAt,
    this.endedAt,
    this.trackingMode = 'adaptive',
    this.isActive = true,
    this.totalDistance = 0.0,
    this.pointsCollected = 0,
    this.batteryConsumed = 0,
    this.deviceInfoJson,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'startedAt': startedAt.millisecondsSinceEpoch,
      'endedAt': endedAt?.millisecondsSinceEpoch,
      'trackingMode': trackingMode,
      'isActive': isActive ? 1 : 0,
      'totalDistance': totalDistance,
      'pointsCollected': pointsCollected,
      'batteryConsumed': batteryConsumed,
      'deviceInfoJson': deviceInfoJson,
    };
  }

  factory TrackingSession.fromMap(Map<String, dynamic> map) {
    return TrackingSession(
      id: map['id'],
      sessionId: map['sessionId'] ?? '',
      userId: map['userId'] ?? '',
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['startedAt'] ?? 0),
      endedAt: map['endedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endedAt']) 
          : null,
      trackingMode: map['trackingMode'] ?? 'adaptive',
      isActive: (map['isActive'] ?? 1) == 1,
      totalDistance: map['totalDistance']?.toDouble() ?? 0.0,
      pointsCollected: map['pointsCollected'] ?? 0,
      batteryConsumed: map['batteryConsumed'] ?? 0,
      deviceInfoJson: map['deviceInfoJson'],
    );
  }
}