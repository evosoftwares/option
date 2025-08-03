/// Configuração do rastreamento de localização
/// 
/// Define parâmetros para otimização de performance e precisão
class TrackingConfig {

  const TrackingConfig({
    this.updateIntervalMs = 5000, // 5 segundos
    this.minDistanceMeters = 10.0, // 10 metros
    this.accuracy = LocationAccuracy.high,
    this.timeoutMs = 15000, // 15 segundos
    this.maxRetries = 3,
    this.retryDelayMs = 2000, // 2 segundos
    this.cacheValidityMs = 30000, // 30 segundos
    this.enableBackground = false,
    this.enableBatteryOptimization = true,
    this.enableNoiseFilter = true,
    this.noiseFilterRadius = 50.0, // 50 metros
  });

  /// Configuração para alta precisão
  factory TrackingConfig.highPrecision() {
    return const TrackingConfig(
      updateIntervalMs: 1000, // 1 segundo
      minDistanceMeters: 1.0, // 1 metro
      accuracy: LocationAccuracy.best,
      timeoutMs: 10000,
      enableBatteryOptimization: false,
      noiseFilterRadius: 10.0,
    );
  }

  /// Configuração para economia de bateria
  factory TrackingConfig.batterySaver() {
    return const TrackingConfig(
      updateIntervalMs: 30000, // 30 segundos
      minDistanceMeters: 100.0, // 100 metros
      accuracy: LocationAccuracy.medium,
      timeoutMs: 20000,
      enableBatteryOptimization: true,
      noiseFilterRadius: 200.0,
    );
  }

  /// Configuração balanceada
  factory TrackingConfig.balanced() {
    return const TrackingConfig(
      updateIntervalMs: 10000, // 10 segundos
      minDistanceMeters: 25.0, // 25 metros
      accuracy: LocationAccuracy.high,
      timeoutMs: 15000,
      enableBatteryOptimization: true,
      noiseFilterRadius: 75.0,
    );
  }

  /// Cria instância a partir de Map
  factory TrackingConfig.fromMap(Map<String, dynamic> map) {
    return TrackingConfig(
      updateIntervalMs: map['updateIntervalMs'] ?? 5000,
      minDistanceMeters: map['minDistanceMeters'] ?? 10.0,
      accuracy: LocationAccuracy.values[map['accuracy'] ?? 3],
      timeoutMs: map['timeoutMs'] ?? 15000,
      maxRetries: map['maxRetries'] ?? 3,
      retryDelayMs: map['retryDelayMs'] ?? 2000,
      cacheValidityMs: map['cacheValidityMs'] ?? 30000,
      enableBackground: map['enableBackground'] ?? false,
      enableBatteryOptimization: map['enableBatteryOptimization'] ?? true,
      enableNoiseFilter: map['enableNoiseFilter'] ?? true,
      noiseFilterRadius: map['noiseFilterRadius'] ?? 50.0,
    );
  }
  /// Intervalo mínimo entre atualizações (milissegundos)
  final int updateIntervalMs;
  
  /// Distância mínima para atualização (metros)
  final double minDistanceMeters;
  
  /// Precisão desejada da localização
  final LocationAccuracy accuracy;
  
  /// Timeout para obter localização (milissegundos)
  final int timeoutMs;
  
  /// Máximo de tentativas em caso de erro
  final int maxRetries;
  
  /// Intervalo entre tentativas (milissegundos)
  final int retryDelayMs;
  
  /// Cache de localização válido por (milissegundos)
  final int cacheValidityMs;
  
  /// Habilitar rastreamento em background
  final bool enableBackground;
  
  /// Habilitar otimizações de bateria
  final bool enableBatteryOptimization;
  
  /// Filtro de ruído para coordenadas
  final bool enableNoiseFilter;
  
  /// Raio do filtro de ruído (metros)
  final double noiseFilterRadius;

  /// Cria uma cópia com modificações
  TrackingConfig copyWith({
    int? updateIntervalMs,
    double? minDistanceMeters,
    LocationAccuracy? accuracy,
    int? timeoutMs,
    int? maxRetries,
    int? retryDelayMs,
    int? cacheValidityMs,
    bool? enableBackground,
    bool? enableBatteryOptimization,
    bool? enableNoiseFilter,
    double? noiseFilterRadius,
  }) {
    return TrackingConfig(
      updateIntervalMs: updateIntervalMs ?? this.updateIntervalMs,
      minDistanceMeters: minDistanceMeters ?? this.minDistanceMeters,
      accuracy: accuracy ?? this.accuracy,
      timeoutMs: timeoutMs ?? this.timeoutMs,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelayMs: retryDelayMs ?? this.retryDelayMs,
      cacheValidityMs: cacheValidityMs ?? this.cacheValidityMs,
      enableBackground: enableBackground ?? this.enableBackground,
      enableBatteryOptimization: enableBatteryOptimization ?? this.enableBatteryOptimization,
      enableNoiseFilter: enableNoiseFilter ?? this.enableNoiseFilter,
      noiseFilterRadius: noiseFilterRadius ?? this.noiseFilterRadius,
    );
  }

  /// Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'updateIntervalMs': updateIntervalMs,
      'minDistanceMeters': minDistanceMeters,
      'accuracy': accuracy.index,
      'timeoutMs': timeoutMs,
      'maxRetries': maxRetries,
      'retryDelayMs': retryDelayMs,
      'cacheValidityMs': cacheValidityMs,
      'enableBackground': enableBackground,
      'enableBatteryOptimization': enableBatteryOptimization,
      'enableNoiseFilter': enableNoiseFilter,
      'noiseFilterRadius': noiseFilterRadius,
    };
  }

  @override
  String toString() {
    return 'TrackingConfig('
        'updateInterval: ${updateIntervalMs}ms, '
        'minDistance: ${minDistanceMeters}m, '
        'accuracy: $accuracy, '
        'timeout: ${timeoutMs}ms'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrackingConfig &&
        other.updateIntervalMs == updateIntervalMs &&
        other.minDistanceMeters == minDistanceMeters &&
        other.accuracy == accuracy &&
        other.timeoutMs == timeoutMs &&
        other.maxRetries == maxRetries &&
        other.retryDelayMs == retryDelayMs &&
        other.cacheValidityMs == cacheValidityMs &&
        other.enableBackground == enableBackground &&
        other.enableBatteryOptimization == enableBatteryOptimization &&
        other.enableNoiseFilter == enableNoiseFilter &&
        other.noiseFilterRadius == noiseFilterRadius;
  }

  @override
  int get hashCode {
    return Object.hash(
      updateIntervalMs,
      minDistanceMeters,
      accuracy,
      timeoutMs,
      maxRetries,
      retryDelayMs,
      cacheValidityMs,
      enableBackground,
      enableBatteryOptimization,
      enableNoiseFilter,
      noiseFilterRadius,
    );
  }
}

/// Precisão da localização
enum LocationAccuracy {
  /// Precisão mais baixa (~3km)
  lowest,
  
  /// Precisão baixa (~1km)
  low,
  
  /// Precisão média (~100m)
  medium,
  
  /// Precisão alta (~10m)
  high,
  
  /// Melhor precisão (~3m)
  best,
  
  /// Precisão para navegação (~1m)
  bestForNavigation,
}

/// Extensões para LocationAccuracy
extension LocationAccuracyExtension on LocationAccuracy {
  /// Retorna a precisão em metros (aproximada)
  double get accuracyInMeters {
    switch (this) {
      case LocationAccuracy.lowest:
        return 3000.0;
      case LocationAccuracy.low:
        return 1000.0;
      case LocationAccuracy.medium:
        return 100.0;
      case LocationAccuracy.high:
        return 10.0;
      case LocationAccuracy.best:
        return 3.0;
      case LocationAccuracy.bestForNavigation:
        return 1.0;
    }
  }
  
  /// Retorna descrição da precisão
  String get description {
    switch (this) {
      case LocationAccuracy.lowest:
        return 'Precisão mais baixa (~3km)';
      case LocationAccuracy.low:
        return 'Precisão baixa (~1km)';
      case LocationAccuracy.medium:
        return 'Precisão média (~100m)';
      case LocationAccuracy.high:
        return 'Precisão alta (~10m)';
      case LocationAccuracy.best:
        return 'Melhor precisão (~3m)';
      case LocationAccuracy.bestForNavigation:
        return 'Precisão para navegação (~1m)';
    }
  }
}