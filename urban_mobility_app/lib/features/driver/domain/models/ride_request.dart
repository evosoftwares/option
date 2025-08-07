/// Solicitação de viagem conforme regras de negócio (Seção 4.4)
class RideRequest {
  const RideRequest({
    required this.id,
    required this.passengerId,
    required this.passengerName,
    required this.passengerPhone,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.estimatedDistance,
    required this.estimatedDuration,
    required this.estimatedPrice,
    required this.vehicleCategory,
    required this.status,
    required this.createdAt,
    this.passengerPhoto,
    this.passengerRating,
    this.specialRequests,
    this.notes,
    this.expiresAt,
    this.acceptedAt,
    this.rejectedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  /// ID único da solicitação
  final String id;

  /// ID do passageiro
  final String passengerId;

  /// Nome do passageiro
  final String passengerName;

  /// Telefone do passageiro
  final String passengerPhone;

  /// Foto do passageiro (opcional)
  final String? passengerPhoto;

  /// Avaliação do passageiro
  final double? passengerRating;

  /// Local de embarque
  final RideLocation pickupLocation;

  /// Local de destino
  final RideLocation destinationLocation;

  /// Distância estimada em km
  final double estimatedDistance;

  /// Duração estimada em minutos
  final int estimatedDuration;

  /// Preço estimado
  final double estimatedPrice;

  /// Categoria do veículo solicitada
  final VehicleCategory vehicleCategory;

  /// Solicitações especiais
  final List<SpecialRequest>? specialRequests;

  /// Observações do passageiro
  final String? notes;

  /// Status da solicitação
  final RideRequestStatus status;

  /// Data de criação
  final DateTime createdAt;

  /// Data de expiração
  final DateTime? expiresAt;

  /// Data de aceitação
  final DateTime? acceptedAt;

  /// Data de rejeição
  final DateTime? rejectedAt;

  /// Data de cancelamento
  final DateTime? cancelledAt;

  /// Motivo do cancelamento
  final String? cancellationReason;

  /// Verifica se a solicitação ainda está válida
  bool get isValid =>
      status == RideRequestStatus.pending &&
      (expiresAt == null || DateTime.now().isBefore(expiresAt!));

  /// Verifica se pode ser aceita
  bool get canBeAccepted => status == RideRequestStatus.pending && isValid;

  /// Verifica se pode ser rejeitada
  bool get canBeRejected => status == RideRequestStatus.pending && isValid;

  /// Verifica se foi aceita
  bool get isAccepted => status == RideRequestStatus.accepted;

  /// Verifica se foi rejeitada
  bool get isRejected => status == RideRequestStatus.rejected;

  /// Verifica se foi cancelada
  bool get isCancelled => status == RideRequestStatus.cancelled;

  /// Verifica se expirou
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Tempo restante em segundos (para compatibilidade)
  int get timeRemaining {
    if (expiresAt == null) return 0;
    final remaining = expiresAt!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Origem (alias para pickupLocation)
  RideLocation get origin => pickupLocation;

  /// Destino (alias para destinationLocation)
  RideLocation get destination => destinationLocation;

  /// Distância formatada
  String get formattedDistance => '${estimatedDistance.toStringAsFixed(1)} km';

  /// Duração formatada
  String get formattedDuration {
    final hours = estimatedDuration ~/ 60;
    final minutes = estimatedDuration % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  /// Preço formatado
  String get formattedPrice => 'R\$ ${estimatedPrice.toStringAsFixed(2)}';

  /// Cria uma cópia com novos valores
  RideRequest copyWith({
    String? id,
    String? passengerId,
    String? passengerName,
    String? passengerPhone,
    String? passengerPhoto,
    double? passengerRating,
    RideLocation? pickupLocation,
    RideLocation? destinationLocation,
    double? estimatedDistance,
    int? estimatedDuration,
    double? estimatedPrice,
    VehicleCategory? vehicleCategory,
    List<SpecialRequest>? specialRequests,
    String? notes,
    RideRequestStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return RideRequest(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerPhoto: passengerPhoto ?? this.passengerPhoto,
      passengerRating: passengerRating ?? this.passengerRating,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      specialRequests: specialRequests ?? this.specialRequests,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerId': passengerId,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'passengerPhoto': passengerPhoto,
      'passengerRating': passengerRating,
      'pickupLocation': pickupLocation.toJson(),
      'destinationLocation': destinationLocation.toJson(),
      'estimatedDistance': estimatedDistance,
      'estimatedDuration': estimatedDuration,
      'estimatedPrice': estimatedPrice,
      'vehicleCategory': vehicleCategory.name,
      'specialRequests': specialRequests?.map((req) => req.toJson()).toList(),
      'notes': notes,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }

  /// Cria instância a partir do JSON
  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: json['id'] as String,
      passengerId: json['passengerId'] as String,
      passengerName: json['passengerName'] as String,
      passengerPhone: json['passengerPhone'] as String,
      passengerPhoto: json['passengerPhoto'] as String?,
      passengerRating: (json['passengerRating'] as num?)?.toDouble(),
      pickupLocation: RideLocation.fromJson(
        json['pickupLocation'] as Map<String, dynamic>,
      ),
      destinationLocation: RideLocation.fromJson(
        json['destinationLocation'] as Map<String, dynamic>,
      ),
      estimatedDistance: (json['estimatedDistance'] as num).toDouble(),
      estimatedDuration: json['estimatedDuration'] as int,
      estimatedPrice: (json['estimatedPrice'] as num).toDouble(),
      vehicleCategory: VehicleCategory.values.firstWhere(
        (e) => e.name == json['vehicleCategory'],
      ),
      specialRequests: json['specialRequests'] != null
          ? (json['specialRequests'] as List<dynamic>)
                .map(
                  (req) => SpecialRequest.fromJson(req as Map<String, dynamic>),
                )
                .toList()
          : null,
      notes: json['notes'] as String?,
      status: RideRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
    );
  }
}

/// Status da solicitação de viagem
enum RideRequestStatus {
  /// Pendente - aguardando resposta do motorista
  pending,

  /// Aceita pelo motorista
  accepted,

  /// Rejeitada pelo motorista
  rejected,

  /// Cancelada pelo passageiro ou sistema
  cancelled,

  /// Expirada - tempo limite atingido
  expired,
}

extension RideRequestStatusExtension on RideRequestStatus {
  /// Nome amigável
  String get displayName {
    switch (this) {
      case RideRequestStatus.pending:
        return 'Pendente';
      case RideRequestStatus.accepted:
        return 'Aceita';
      case RideRequestStatus.rejected:
        return 'Rejeitada';
      case RideRequestStatus.cancelled:
        return 'Cancelada';
      case RideRequestStatus.expired:
        return 'Expirada';
    }
  }

  /// Cor associada
  String get colorHex {
    switch (this) {
      case RideRequestStatus.pending:
        return '#FF9800'; // Laranja
      case RideRequestStatus.accepted:
        return '#4CAF50'; // Verde
      case RideRequestStatus.rejected:
        return '#F44336'; // Vermelho
      case RideRequestStatus.cancelled:
        return '#9E9E9E'; // Cinza
      case RideRequestStatus.expired:
        return '#795548'; // Marrom
    }
  }
}

/// Local da viagem (embarque ou destino)
class RideLocation {
  const RideLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.complement,
    this.reference,
    this.neighborhood,
    this.city,
    this.state,
    this.zipCode,
  });

  /// Latitude
  final double latitude;

  /// Longitude
  final double longitude;

  /// Endereço principal
  final String address;

  /// Complemento (apto, sala, etc.)
  final String? complement;

  /// Ponto de referência
  final String? reference;

  /// Bairro
  final String? neighborhood;

  /// Cidade
  final String? city;

  /// Estado
  final String? state;

  /// CEP
  final String? zipCode;

  /// Endereço completo formatado
  String get fullAddress {
    final parts = <String>[address];
    if (complement?.isNotEmpty == true) parts.add(complement!);
    if (neighborhood?.isNotEmpty == true) parts.add(neighborhood!);
    if (city?.isNotEmpty == true) parts.add(city!);
    if (state?.isNotEmpty == true) parts.add(state!);
    return parts.join(', ');
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'complement': complement,
      'reference': reference,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }

  /// Cria instância a partir do JSON
  factory RideLocation.fromJson(Map<String, dynamic> json) {
    return RideLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      complement: json['complement'] as String?,
      reference: json['reference'] as String?,
      neighborhood: json['neighborhood'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
    );
  }
}

/// Solicitação especial do passageiro
class SpecialRequest {
  const SpecialRequest({
    required this.type,
    required this.description,
    this.additionalFee = 0.0,
  });

  /// Tipo da solicitação
  final SpecialRequestType type;

  /// Descrição detalhada
  final String description;

  /// Taxa adicional
  final double additionalFee;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'description': description,
      'additionalFee': additionalFee,
    };
  }

  /// Cria instância a partir do JSON
  factory SpecialRequest.fromJson(Map<String, dynamic> json) {
    return SpecialRequest(
      type: SpecialRequestType.values.firstWhere((e) => e.name == json['type']),
      description: json['description'] as String,
      additionalFee: (json['additionalFee'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Tipos de solicitações especiais
enum SpecialRequestType {
  /// Transporte de animal de estimação
  petTransport,

  /// Uso do porta-malas
  trunkService,

  /// Acesso a condomínio
  condominiumAccess,

  /// Parada adicional
  additionalStop,

  /// Ar-condicionado
  airConditioning,

  /// Acessibilidade
  accessibility,

  /// Outros
  other,
}

extension SpecialRequestTypeExtension on SpecialRequestType {
  /// Nome amigável
  String get displayName {
    switch (this) {
      case SpecialRequestType.petTransport:
        return 'Transporte de Pet';
      case SpecialRequestType.trunkService:
        return 'Uso do Porta-malas';
      case SpecialRequestType.condominiumAccess:
        return 'Acesso a Condomínio';
      case SpecialRequestType.additionalStop:
        return 'Parada Adicional';
      case SpecialRequestType.airConditioning:
        return 'Ar-condicionado';
      case SpecialRequestType.accessibility:
        return 'Acessibilidade';
      case SpecialRequestType.other:
        return 'Outros';
    }
  }

  /// Ícone associado
  String get iconName {
    switch (this) {
      case SpecialRequestType.petTransport:
        return 'pets';
      case SpecialRequestType.trunkService:
        return 'luggage';
      case SpecialRequestType.condominiumAccess:
        return 'home';
      case SpecialRequestType.additionalStop:
        return 'add_location';
      case SpecialRequestType.airConditioning:
        return 'ac_unit';
      case SpecialRequestType.accessibility:
        return 'accessible';
      case SpecialRequestType.other:
        return 'more_horiz';
    }
  }
}

/// Categoria de veículo (importada do vehicle_info.dart)
enum VehicleCategory { carroComum, carro7Lugares, frete, guincho }

extension VehicleCategoryExtension on VehicleCategory {
  String get displayName {
    switch (this) {
      case VehicleCategory.carroComum:
        return 'Carro Comum';
      case VehicleCategory.carro7Lugares:
        return 'Carro 7 Lugares';
      case VehicleCategory.frete:
        return 'Frete';
      case VehicleCategory.guincho:
        return 'Guincho';
    }
  }
}
