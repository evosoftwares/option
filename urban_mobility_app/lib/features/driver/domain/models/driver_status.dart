/// Status do motorista conforme regras de negócio (Seção 4.3)
enum DriverStatus {
  /// Offline - não está trabalhando
  offline,

  /// Online - disponível para receber viagens
  online,

  /// Em viagem - atualmente realizando uma viagem
  onTrip,

  /// Ocupado - processando solicitação ou indo buscar passageiro
  busy,

  /// Pausado - temporariamente indisponível
  paused,

  /// Suspenso - temporariamente bloqueado pelo sistema
  suspended,
}

extension DriverStatusExtension on DriverStatus {
  /// Nome amigável para exibição
  String get displayName {
    switch (this) {
      case DriverStatus.offline:
        return 'Offline';
      case DriverStatus.online:
        return 'Online';
      case DriverStatus.onTrip:
        return 'Em Viagem';
      case DriverStatus.busy:
        return 'Ocupado';
      case DriverStatus.paused:
        return 'Pausado';
      case DriverStatus.suspended:
        return 'Suspenso';
    }
  }

  /// Descrição detalhada do status
  String get description {
    switch (this) {
      case DriverStatus.offline:
        return 'Você está offline e não receberá solicitações de viagem';
      case DriverStatus.online:
        return 'Você está online e disponível para receber viagens';
      case DriverStatus.onTrip:
        return 'Você está realizando uma viagem';
      case DriverStatus.busy:
        return 'Você está ocupado processando uma solicitação';
      case DriverStatus.paused:
        return 'Você pausou temporariamente e não receberá novas viagens';
      case DriverStatus.suspended:
        return 'Sua conta foi temporariamente suspensa';
    }
  }

  /// Cor associada ao status
  String get colorHex {
    switch (this) {
      case DriverStatus.offline:
        return '#9E9E9E'; // Cinza
      case DriverStatus.online:
        return '#4CAF50'; // Verde
      case DriverStatus.onTrip:
        return '#2196F3'; // Azul
      case DriverStatus.busy:
        return '#FF5722'; // Laranja escuro
      case DriverStatus.paused:
        return '#FF9800'; // Laranja
      case DriverStatus.suspended:
        return '#F44336'; // Vermelho
    }
  }

  /// Verifica se pode receber solicitações (alias para canReceiveTrips)
  bool get canReceiveRequests => canReceiveTrips;

  /// Verifica se pode receber novas viagens
  bool get canReceiveTrips {
    switch (this) {
      case DriverStatus.online:
        return true;
      case DriverStatus.offline:
      case DriverStatus.onTrip:
      case DriverStatus.busy:
      case DriverStatus.paused:
      case DriverStatus.suspended:
        return false;
    }
  }

  /// Verifica se pode ficar online
  bool get canGoOnline {
    switch (this) {
      case DriverStatus.offline:
      case DriverStatus.paused:
        return true;
      case DriverStatus.online:
      case DriverStatus.onTrip:
      case DriverStatus.busy:
      case DriverStatus.suspended:
        return false;
    }
  }

  /// Verifica se pode ficar offline
  bool get canGoOffline {
    switch (this) {
      case DriverStatus.online:
      case DriverStatus.paused:
        return true;
      case DriverStatus.offline:
      case DriverStatus.onTrip:
      case DriverStatus.busy:
      case DriverStatus.suspended:
        return false;
    }
  }

  /// Verifica se pode pausar
  bool get canPause {
    switch (this) {
      case DriverStatus.online:
        return true;
      case DriverStatus.offline:
      case DriverStatus.onTrip:
      case DriverStatus.busy:
      case DriverStatus.paused:
      case DriverStatus.suspended:
        return false;
    }
  }

  /// Verifica se pode retomar (sair da pausa)
  bool get canResume {
    switch (this) {
      case DriverStatus.paused:
        return true;
      case DriverStatus.offline:
      case DriverStatus.online:
      case DriverStatus.onTrip:
      case DriverStatus.busy:
      case DriverStatus.suspended:
        return false;
    }
  }

  /// Verifica se está ativo (online ou em viagem)
  bool get isActive {
    switch (this) {
      case DriverStatus.online:
      case DriverStatus.onTrip:
      case DriverStatus.busy:
        return true;
      case DriverStatus.offline:
      case DriverStatus.paused:
      case DriverStatus.suspended:
        return false;
    }
  }

  /// Verifica se está bloqueado
  bool get isBlocked {
    switch (this) {
      case DriverStatus.suspended:
        return true;
      case DriverStatus.offline:
      case DriverStatus.online:
      case DriverStatus.onTrip:
      case DriverStatus.busy:
      case DriverStatus.paused:
        return false;
    }
  }
}

/// Histórico de mudanças de status do motorista
class DriverStatusHistory {
  const DriverStatusHistory({
    required this.id,
    required this.driverId,
    required this.previousStatus,
    required this.newStatus,
    required this.timestamp,
    this.reason,
    this.location,
  });

  /// ID único do registro
  final String id;

  /// ID do motorista
  final String driverId;

  /// Status anterior
  final DriverStatus previousStatus;

  /// Novo status
  final DriverStatus newStatus;

  /// Timestamp da mudança
  final DateTime timestamp;

  /// Motivo da mudança (opcional)
  final String? reason;

  /// Localização no momento da mudança (opcional)
  final DriverLocation? location;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'previousStatus': previousStatus.name,
      'newStatus': newStatus.name,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
      'location': location?.toJson(),
    };
  }

  /// Cria instância a partir do JSON
  factory DriverStatusHistory.fromJson(Map<String, dynamic> json) {
    return DriverStatusHistory(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      previousStatus: DriverStatus.values.firstWhere(
        (e) => e.name == json['previousStatus'],
      ),
      newStatus: DriverStatus.values.firstWhere(
        (e) => e.name == json['newStatus'],
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      reason: json['reason'] as String?,
      location: json['location'] != null
          ? DriverLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Cria instância a partir do Firestore
  factory DriverStatusHistory.fromFirestore(Map<String, dynamic> data, String id) {
    return DriverStatusHistory(
      id: id,
      driverId: data['driverId'] as String,
      previousStatus: DriverStatus.values.firstWhere(
        (e) => e.name == data['previousStatus'],
      ),
      newStatus: DriverStatus.values.firstWhere(
        (e) => e.name == data['newStatus'],
      ),
      timestamp: DateTime.parse(data['timestamp'] as String),
      reason: data['reason'] as String?,
      location: data['location'] != null
          ? DriverLocation.fromJson(data['location'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    final data = toJson();
    data.remove('id'); // ID é gerenciado pelo Firestore
    return data;
  }
}

/// Localização do motorista (importada do driver_profile.dart)
class DriverLocation {
  const DriverLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.timestamp,
  });

  final double latitude;
  final double longitude;
  final String? address;
  final DateTime? timestamp;

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }
}
