/// Status do rastreamento de localização
enum TrackingStatus {
  /// Rastreamento não iniciado
  idle,
  
  /// Rastreamento ativo
  active,
  
  /// Rastreamento pausado
  paused,
  
  /// Erro no rastreamento
  error,
  
  /// Permissões negadas
  permissionDenied,
  
  /// Serviço de localização desabilitado
  serviceDisabled,
}

/// Extensões para TrackingStatus
extension TrackingStatusExtension on TrackingStatus {
  /// Retorna se o rastreamento está ativo
  bool get isActive => this == TrackingStatus.active;
  
  /// Retorna se o rastreamento está pausado
  bool get isPaused => this == TrackingStatus.paused;
  
  /// Retorna se há erro
  bool get hasError => this == TrackingStatus.error || 
                       this == TrackingStatus.permissionDenied || 
                       this == TrackingStatus.serviceDisabled;
  
  /// Retorna se pode iniciar rastreamento
  bool get canStart => this == TrackingStatus.idle || 
                       this == TrackingStatus.paused;
  
  /// Retorna se pode pausar rastreamento
  bool get canPause => this == TrackingStatus.active;
  
  /// Retorna se pode parar rastreamento
  bool get canStop => this == TrackingStatus.active || 
                      this == TrackingStatus.paused;
  
  /// Retorna descrição amigável do status
  String get description {
    switch (this) {
      case TrackingStatus.idle:
        return 'Rastreamento inativo';
      case TrackingStatus.active:
        return 'Rastreamento ativo';
      case TrackingStatus.paused:
        return 'Rastreamento pausado';
      case TrackingStatus.error:
        return 'Erro no rastreamento';
      case TrackingStatus.permissionDenied:
        return 'Permissão de localização negada';
      case TrackingStatus.serviceDisabled:
        return 'Serviço de localização desabilitado';
    }
  }
}