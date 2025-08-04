import 'dart:convert';
import 'dart:math' as math;

import 'package:isar/isar.dart';

part 'location_point.g.dart';

@collection
class LocationPoint {
  
  LocationPoint();
  
  LocationPoint.create({
    required this.lat,
    required this.lng,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.recordedAt,
    this.activityType = 'unknown',
    this.batteryLevel = 100,
    this.networkType = 'unknown',
    Map<String, dynamic>? deviceInfo,
  }) {
    if (deviceInfo != null) {
      deviceInfoJson = jsonEncode(deviceInfo);
    }
  }
  
  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    final point = LocationPoint();
    point.id = json['id'] ?? Isar.autoIncrement;
    point.lat = (json['lat'] as num).toDouble();
    point.lng = (json['lng'] as num).toDouble();
    point.accuracy = (json['accuracy'] as num).toDouble();
    point.altitude = json['altitude']?.toDouble();
    point.speed = json['speed']?.toDouble();
    point.heading = json['heading']?.toDouble();
    point.recordedAt = DateTime.parse(json['recordedAt']);
    point.syncedAt = json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null;
    point.activityType = json['activityType'] ?? 'unknown';
    point.batteryLevel = json['batteryLevel'] ?? 100;
    point.networkType = json['networkType'] ?? 'unknown';
    point.syncedToSupabase = json['syncedToSupabase'] ?? false;
    point.syncedToFirebase = json['syncedToFirebase'] ?? false;
    point.deviceInfo = json['deviceInfo'] ?? {};
    point.lastError = json['lastError'];
    return point;
  }
  Id id = Isar.autoIncrement;
  
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
  
  // Contexto
  String activityType = 'unknown';
  int batteryLevel = 100;
  String networkType = 'unknown';
  
  // Estado de sincronização
  bool syncedToSupabase = false;
  bool syncedToFirebase = false;
  
  // Metadados como String JSON
  String deviceInfoJson = '{}';
  String? lastError;
  
  // Getter para deviceInfo
  @ignore
  Map<String, dynamic> get deviceInfo {
    try {
      return jsonDecode(deviceInfoJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
  
  // Setter para deviceInfo
  @ignore
  set deviceInfo(Map<String, dynamic> value) {
    deviceInfoJson = jsonEncode(value);
  }
  
  /// Calcula distância para outro ponto em metros
  double distanceTo(LocationPoint other) {
    const double earthRadius = 6371000; // metros
    
    final lat1Rad = lat * (math.pi / 180);
    final lat2Rad = other.lat * (math.pi / 180);
    final deltaLatRad = (other.lat - lat) * (math.pi / 180);
    final deltaLngRad = (other.lng - lng) * (math.pi / 180);
    
    final a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    
    final c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }
  
  /// Verifica se houve mudança significativa
  bool hasSignificantChange(LocationPoint? previous) {
    if (previous == null) return true;
    
    final distance = distanceTo(previous);
    final timeDiff = recordedAt.difference(previous.recordedAt).inSeconds;
    
    return distance > 10 || timeDiff > 300 || activityType != previous.activityType;
  }
  
  /// Valida se o ponto é válido
  bool get isValid {
    return lat.abs() <= 90 && 
           lng.abs() <= 180 && 
           accuracy > 0 && 
           accuracy < 1000;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': lat,
      'lng': lng,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'recordedAt': recordedAt.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
      'activityType': activityType,
      'batteryLevel': batteryLevel,
      'networkType': networkType,
      'syncedToSupabase': syncedToSupabase,
      'syncedToFirebase': syncedToFirebase,
      'deviceInfo': deviceInfo,
      'lastError': lastError,
    };
  }
}

@collection
class TrackingSession {
  
  TrackingSession();
  
  TrackingSession.create({
    required this.userId,
    this.trackingMode = 'adaptive',
    Map<String, dynamic>? deviceInfo,
  }) {
    sessionId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
    startedAt = DateTime.now();
    isActive = true;
    
    if (deviceInfo != null) {
      deviceInfoJson = jsonEncode(deviceInfo);
    }
  }
  
  factory TrackingSession.fromJson(Map<String, dynamic> json) {
    final session = TrackingSession();
    session.id = json['id'] ?? Isar.autoIncrement;
    session.sessionId = json['sessionId'];
    session.userId = json['userId'];
    session.startedAt = DateTime.parse(json['startedAt']);
    session.endedAt = json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null;
    session.trackingMode = json['trackingMode'] ?? 'adaptive';
    session.isActive = json['isActive'] ?? true;
    session.totalDistance = (json['totalDistance'] as num?)?.toDouble() ?? 0.0;
    session.pointsCollected = json['pointsCollected'] ?? 0;
    session.batteryConsumed = json['batteryConsumed'] ?? 0;
    session.deviceInfo = json['deviceInfo'] ?? {};
    session.lastError = json['lastError'];
    return session;
  }
  Id id = Isar.autoIncrement;
  
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
  
  // Metadados como String JSON
  String deviceInfoJson = '{}';
  String? lastError;
  
  // Getter para deviceInfo
  @ignore
  Map<String, dynamic> get deviceInfo {
    try {
      return jsonDecode(deviceInfoJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
  
  // Setter para deviceInfo
  @ignore
  set deviceInfo(Map<String, dynamic> value) {
    deviceInfoJson = jsonEncode(value);
  }
  
  /// Duração da sessão
  @ignore
  Duration get duration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }
  
  /// Atualiza métricas da sessão
  void updateMetrics({
    double additionalDistance = 0,
    int additionalPoints = 0,
    int additionalBattery = 0,
  }) {
    totalDistance += additionalDistance;
    pointsCollected += additionalPoints;
    batteryConsumed += additionalBattery;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'trackingMode': trackingMode,
      'isActive': isActive,
      'totalDistance': totalDistance,
      'pointsCollected': pointsCollected,
      'batteryConsumed': batteryConsumed,
      'deviceInfo': deviceInfo,
      'lastError': lastError,
    };
  }
}