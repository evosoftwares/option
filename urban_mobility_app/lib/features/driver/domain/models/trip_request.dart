import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Solicitação de Viagem (Seção 4.3)
/// Implementa o fluxo de disponibilidade e aceitação de viagens
class TripRequest {
  const TripRequest({
    required this.id,
    required this.passengerId,
    required this.passengerName,
    required this.passengerRating,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.destination,
    required this.destinationAddress,
    required this.estimatedDistance,
    required this.estimatedDuration,
    required this.basePrice,
    required this.totalPrice,
    required this.requestedAt,
    required this.expiresAt,
    required this.status,
    this.passengerPhone,
    this.specialRequests,
    this.paymentMethod = PaymentMethod.money,
    this.needsPetTransport = false,
    this.needsTrunkService = false,
    this.needsCondominiumAccess = false,
    this.numberOfStops = 0,
    this.stopLocations = const [],
  });

  final String id;
  final String passengerId;
  final String passengerName;
  final double passengerRating;
  final String? passengerPhone;

  // Localização
  final LatLng pickupLocation;
  final String pickupAddress;
  final LatLng destination;
  final String destinationAddress;

  // Paradas adicionais
  final int numberOfStops;
  final List<TripStop> stopLocations;

  // Estimativas
  final double estimatedDistance; // em km
  final Duration estimatedDuration;

  // Preços
  final double basePrice;
  final double totalPrice; // inclui taxas adicionais

  // Requisitos especiais
  final bool needsPetTransport;
  final bool needsTrunkService;
  final bool needsCondominiumAccess;
  final String? specialRequests;

  // Pagamento
  final PaymentMethod paymentMethod;

  // Controle de tempo
  final DateTime requestedAt;
  final DateTime expiresAt;
  final TripRequestStatus status;

  /// Tempo restante para aceitar a viagem
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) {
      return Duration.zero;
    }
    return expiresAt.difference(now);
  }

  /// Se a solicitação ainda está válida
  bool get isValid =>
      DateTime.now().isBefore(expiresAt) && status == TripRequestStatus.pending;

  /// Se a solicitação expirou
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Preço formatado
  String get formattedPrice => 'R\$ ${totalPrice.toStringAsFixed(2)}';

  /// Distância formatada
  String get formattedDistance => '${estimatedDistance.toStringAsFixed(1)} km';

  /// Duração formatada
  String get formattedDuration {
    final minutes = estimatedDuration.inMinutes;
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}min';
    }
  }

  /// Aceitar a viagem
  TripRequest accept() {
    return copyWith(status: TripRequestStatus.accepted);
  }

  /// Rejeitar a viagem
  TripRequest reject() {
    return copyWith(status: TripRequestStatus.rejected);
  }

  /// Expirar a viagem
  TripRequest expire() {
    return copyWith(status: TripRequestStatus.expired);
  }

  TripRequest copyWith({
    String? id,
    String? passengerId,
    String? passengerName,
    double? passengerRating,
    String? passengerPhone,
    LatLng? pickupLocation,
    String? pickupAddress,
    LatLng? destination,
    String? destinationAddress,
    int? numberOfStops,
    List<TripStop>? stopLocations,
    double? estimatedDistance,
    Duration? estimatedDuration,
    double? basePrice,
    double? totalPrice,
    bool? needsPetTransport,
    bool? needsTrunkService,
    bool? needsCondominiumAccess,
    String? specialRequests,
    PaymentMethod? paymentMethod,
    DateTime? requestedAt,
    DateTime? expiresAt,
    TripRequestStatus? status,
  }) {
    return TripRequest(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      passengerRating: passengerRating ?? this.passengerRating,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destination: destination ?? this.destination,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      numberOfStops: numberOfStops ?? this.numberOfStops,
      stopLocations: stopLocations ?? this.stopLocations,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      basePrice: basePrice ?? this.basePrice,
      totalPrice: totalPrice ?? this.totalPrice,
      needsPetTransport: needsPetTransport ?? this.needsPetTransport,
      needsTrunkService: needsTrunkService ?? this.needsTrunkService,
      needsCondominiumAccess:
          needsCondominiumAccess ?? this.needsCondominiumAccess,
      specialRequests: specialRequests ?? this.specialRequests,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      requestedAt: requestedAt ?? this.requestedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
    );
  }

  factory TripRequest.fromJson(Map<String, dynamic> json) {
    return TripRequest(
      id: json['id'] as String,
      passengerId: json['passengerId'] as String,
      passengerName: json['passengerName'] as String,
      passengerRating: (json['passengerRating'] as num).toDouble(),
      passengerPhone: json['passengerPhone'] as String?,
      pickupLocation: LatLng(
        (json['pickupLocation']['latitude'] as num).toDouble(),
        (json['pickupLocation']['longitude'] as num).toDouble(),
      ),
      pickupAddress: json['pickupAddress'] as String,
      destination: LatLng(
        (json['destination']['latitude'] as num).toDouble(),
        (json['destination']['longitude'] as num).toDouble(),
      ),
      destinationAddress: json['destinationAddress'] as String,
      numberOfStops: json['numberOfStops'] as int? ?? 0,
      stopLocations:
          (json['stopLocations'] as List<dynamic>?)
              ?.map((item) => TripStop.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      estimatedDistance: (json['estimatedDistance'] as num).toDouble(),
      estimatedDuration: Duration(seconds: json['estimatedDuration'] as int),
      basePrice: (json['basePrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      needsPetTransport: json['needsPetTransport'] as bool? ?? false,
      needsTrunkService: json['needsTrunkService'] as bool? ?? false,
      needsCondominiumAccess: json['needsCondominiumAccess'] as bool? ?? false,
      specialRequests: json['specialRequests'] as String?,
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == json['paymentMethod'],
        orElse: () => PaymentMethod.money,
      ),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: TripRequestStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => TripRequestStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerId': passengerId,
      'passengerName': passengerName,
      'passengerRating': passengerRating,
      'passengerPhone': passengerPhone,
      'pickupLocation': {
        'latitude': pickupLocation.latitude,
        'longitude': pickupLocation.longitude,
      },
      'pickupAddress': pickupAddress,
      'destination': {
        'latitude': destination.latitude,
        'longitude': destination.longitude,
      },
      'destinationAddress': destinationAddress,
      'numberOfStops': numberOfStops,
      'stopLocations': stopLocations.map((stop) => stop.toJson()).toList(),
      'estimatedDistance': estimatedDistance,
      'estimatedDuration': estimatedDuration.inSeconds,
      'basePrice': basePrice,
      'totalPrice': totalPrice,
      'needsPetTransport': needsPetTransport,
      'needsTrunkService': needsTrunkService,
      'needsCondominiumAccess': needsCondominiumAccess,
      'specialRequests': specialRequests,
      'paymentMethod': paymentMethod.name,
      'requestedAt': requestedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'status': status.name,
    };
  }
}

/// Parada adicional na viagem
class TripStop {
  const TripStop({
    required this.location,
    required this.address,
    required this.order,
    this.instructions,
  });

  final LatLng location;
  final String address;
  final int order; // Ordem da parada (1, 2, 3...)
  final String? instructions; // Instruções específicas para a parada

  factory TripStop.fromJson(Map<String, dynamic> json) {
    return TripStop(
      location: LatLng(
        (json['location']['latitude'] as num).toDouble(),
        (json['location']['longitude'] as num).toDouble(),
      ),
      address: json['address'] as String,
      order: json['order'] as int,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'address': address,
      'order': order,
      'instructions': instructions,
    };
  }
}

/// Status da solicitação de viagem
enum TripRequestStatus {
  pending, // Aguardando resposta do motorista
  accepted, // Aceita pelo motorista
  rejected, // Rejeitada pelo motorista
  expired, // Expirou o tempo limite
  cancelled, // Cancelada pelo passageiro
}

/// Método de pagamento
enum PaymentMethod {
  money, // Dinheiro
  pix, // PIX
  card, // Cartão
}
