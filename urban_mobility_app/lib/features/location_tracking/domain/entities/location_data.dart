import 'dart:math' as math;

/// Fonte da localização
enum LocationSource {
  /// GPS do dispositivo
  gps,
  
  /// Rede (WiFi/Celular)
  network,
  
  /// Geocoding
  geocoding,
  
  /// Cache
  cache,
  
  /// Simulação/Mock
  mock,
}

/// Entidade de dados de localização enriquecida
/// 
/// Representa uma localização com informações completas incluindo
/// coordenadas, precisão, timestamp e dados contextuais.
class EnhancedLocationData {

  const EnhancedLocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.heading,
    this.speed,
    this.speedAccuracy,
    this.source = LocationSource.gps,
    required this.timestamp,
    this.address,
    this.provider,
    this.metadata,
  });

  /// Cria instância a partir de Map
  factory EnhancedLocationData.fromJson(Map<String, dynamic> json) {
    return EnhancedLocationData(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
      altitude: json['altitude']?.toDouble(),
      heading: json['heading']?.toDouble(),
      speed: json['speed']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      address: json['address'],
      provider: json['provider'],
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
    );
  }
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? altitude;
  final double? heading;
  final double? speed;
  
  /// Precisão da velocidade em m/s (opcional)
  final double? speedAccuracy;
  
  /// Fonte da localização
  final LocationSource source;
  
  final DateTime timestamp;
  final String? address;
  final String? provider;
  final Map<String, dynamic>? metadata;

  /// Cria uma cópia com modificações
  EnhancedLocationData copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? heading,
    double? speed,
    double? speedAccuracy,
    LocationSource? source,
    DateTime? timestamp,
    String? address,
    String? provider,
    Map<String, dynamic>? metadata,
  }) {
    return EnhancedLocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      speedAccuracy: speedAccuracy ?? this.speedAccuracy,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
      address: address ?? this.address,
      provider: provider ?? this.provider,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converte para Map para serialização
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'heading': heading,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
      'provider': provider,
      'metadata': metadata,
    };
  }

  /// Calcula distância para outra localização em metros
  double distanceTo(EnhancedLocationData other) {
    const double earthRadius = 6371000; // metros
    final double lat1Rad = latitude * (math.pi / 180);
    final double lat2Rad = other.latitude * (math.pi / 180);
    final double deltaLatRad = (other.latitude - latitude) * (math.pi / 180);
    final double deltaLonRad = (other.longitude - longitude) * (math.pi / 180);

    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLonRad / 2) * math.sin(deltaLonRad / 2);
    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnhancedLocationData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.accuracy == accuracy &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(latitude, longitude, accuracy, timestamp);
  }

  @override
  String toString() {
    return 'EnhancedLocationData(lat: $latitude, lng: $longitude, accuracy: ${accuracy}m, time: $timestamp)';
  }
}