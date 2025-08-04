import 'dart:math' as math;

/// Modelo de dados para representar informações de localização
/// 
/// Este modelo é usado para armazenar e transferir dados de localização
/// entre diferentes camadas da aplicação e o Supabase.
class LocationData {

  const LocationData({
    this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
    this.metadata,
  });

  /// Cria uma instância de LocationData a partir de um JSON
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  final String? id;
  final String userId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  /// Converte a instância para JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (heading != null) 'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Cria uma cópia da instância com valores modificados
  LocationData copyWith({
    String? id,
    String? userId,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? speed,
    double? heading,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return LocationData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Calcula a distância em metros para outra localização
  double distanceTo(LocationData other) {
    return _calculateDistance(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  /// Verifica se a localização é válida
  bool get isValid {
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180 &&
           accuracy >= 0;
  }

  /// Obtém uma representação textual da localização
  String get coordinatesString {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Verifica se a localização é recente (últimos 5 minutos)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inMinutes <= 5;
  }

  @override
  String toString() {
    return 'LocationData(id: $id, userId: $userId, lat: $latitude, lng: $longitude, accuracy: $accuracy, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is LocationData &&
        other.id == id &&
        other.userId == userId &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.accuracy == accuracy &&
        other.speed == speed &&
        other.heading == heading &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      latitude,
      longitude,
      accuracy,
      speed,
      heading,
      timestamp,
    );
  }
}

/// Calcula a distância entre duas coordenadas usando a fórmula de Haversine
/// 
/// Retorna a distância em metros
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // Raio da Terra em metros
  
  final double dLat = _degreesToRadians(lat2 - lat1);
  final double dLon = _degreesToRadians(lon2 - lon1);
  
  final double a = 
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) * 
      math.sin(dLon / 2) * math.sin(dLon / 2);
  
  final double c = 2 * math.asin(math.sqrt(a));
  
  return earthRadius * c;
}

/// Converte graus para radianos
double _degreesToRadians(double degrees) {
  return degrees * (3.14159265359 / 180);
}

/// Extensões úteis para trabalhar com coordenadas
extension CoordinateExtensions on double {
  /// Converte graus para radianos
  double get radians => this * (3.14159265359 / 180);
  
  /// Converte radianos para graus
  double get degrees => this * (180 / 3.14159265359);
  
  /// Arredonda coordenada para 6 casas decimais (precisão de ~1 metro)
  double get coordinatePrecision => double.parse(toStringAsFixed(6));
}