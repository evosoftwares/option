import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'trip_request.dart';

/// Viagem Ativa (Seção 4.4)
/// Implementa o fluxo completo de realização da viagem
class ActiveTrip {
  const ActiveTrip({
    required this.id,
    required this.passengerId,
    required this.passengerName,
    required this.passengerPhone,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.destination,
    required this.destinationAddress,
    required this.status,
    required this.basePrice,
    required this.totalPrice,
    required this.paymentMethod,
    required this.startedAt,
    this.estimatedDuration,
    this.actualDuration,
    this.estimatedDistance,
    this.actualDistance,
    this.specialInstructions,
    this.numberOfStops = 0,
    this.stopLocations = const [],
    this.needsPetTransport = false,
    this.needsTrunkService = false,
    this.needsCondominiumAccess = false,
    this.pickedUpAt,
    this.completedAt,
    this.driverNotes,
    this.passengerRating,
    this.driverRating,
  });

  final String id;
  final String passengerId;
  final String passengerName;
  final String? passengerPhone;

  // Localização
  final LatLng pickupLocation;
  final String pickupAddress;
  final LatLng destination;
  final String destinationAddress;

  // Paradas adicionais
  final int numberOfStops;
  final List<TripStop> stopLocations;

  // Status e controle de tempo
  final TripStatus status;
  final DateTime startedAt;
  final DateTime? pickedUpAt;
  final DateTime? completedAt;

  // Estimativas vs Realidade
  final Duration? estimatedDuration;
  final Duration? actualDuration;
  final double? estimatedDistance;
  final double? actualDistance;

  // Preços
  final double basePrice;
  final double totalPrice;
  final PaymentMethod paymentMethod;

  // Requisitos especiais
  final bool needsPetTransport;
  final bool needsTrunkService;
  final bool needsCondominiumAccess;
  final String? specialInstructions;

  // Notas e avaliações
  final String? driverNotes;
  final double? passengerRating; // Avaliação do passageiro pelo motorista
  final double? driverRating; // Avaliação do motorista pelo passageiro

  /// Duração atual da viagem
  Duration get currentDuration {
    if (completedAt != null) {
      return actualDuration ?? completedAt!.difference(startedAt);
    }
    return DateTime.now().difference(startedAt);
  }

  /// Se o passageiro já foi coletado
  bool get isPassengerPickedUp => pickedUpAt != null;

  /// Se a viagem está em andamento
  bool get isInProgress => status == TripStatus.inProgress;

  /// Se a viagem foi concluída
  bool get isCompleted => status == TripStatus.completed;

  /// Preço formatado
  String get formattedPrice => 'R\$ ${totalPrice.toStringAsFixed(2)}';

  /// Distância formatada
  String get formattedDistance {
    final distance = actualDistance ?? estimatedDistance ?? 0.0;
    return '${distance.toStringAsFixed(1)} km';
  }

  /// Duração formatada
  String get formattedDuration {
    final duration = actualDuration ?? estimatedDuration ?? currentDuration;
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}min';
    }
  }

  /// Marcar que chegou ao local de coleta
  ActiveTrip arrivedAtPickup() {
    return copyWith(status: TripStatus.waitingPassenger);
  }

  /// Marcar que coletou o passageiro
  ActiveTrip pickupPassenger() {
    return copyWith(status: TripStatus.inProgress, pickedUpAt: DateTime.now());
  }

  /// Completar a viagem
  ActiveTrip complete({double? finalDistance, String? notes}) {
    final now = DateTime.now();
    return copyWith(
      status: TripStatus.completed,
      completedAt: now,
      actualDuration: now.difference(startedAt),
      actualDistance: finalDistance,
      driverNotes: notes,
    );
  }

  /// Avaliar o passageiro
  ActiveTrip ratePassenger(double rating) {
    return copyWith(passengerRating: rating);
  }

  /// Receber avaliação do passageiro
  ActiveTrip receiveRating(double rating) {
    return copyWith(driverRating: rating);
  }

  /// Criar viagem ativa a partir de uma solicitação aceita
  factory ActiveTrip.fromTripRequest(TripRequest request) {
    return ActiveTrip(
      id: request.id,
      passengerId: request.passengerId,
      passengerName: request.passengerName,
      passengerPhone: request.passengerPhone,
      pickupLocation: request.pickupLocation,
      pickupAddress: request.pickupAddress,
      destination: request.destination,
      destinationAddress: request.destinationAddress,
      numberOfStops: request.numberOfStops,
      stopLocations: request.stopLocations,
      status: TripStatus.goingToPickup,
      basePrice: request.basePrice,
      totalPrice: request.totalPrice,
      paymentMethod: request.paymentMethod,
      estimatedDuration: request.estimatedDuration,
      estimatedDistance: request.estimatedDistance,
      needsPetTransport: request.needsPetTransport,
      needsTrunkService: request.needsTrunkService,
      needsCondominiumAccess: request.needsCondominiumAccess,
      specialInstructions: request.specialRequests,
      startedAt: DateTime.now(),
    );
  }

  ActiveTrip copyWith({
    String? id,
    String? passengerId,
    String? passengerName,
    String? passengerPhone,
    LatLng? pickupLocation,
    String? pickupAddress,
    LatLng? destination,
    String? destinationAddress,
    int? numberOfStops,
    List<TripStop>? stopLocations,
    TripStatus? status,
    DateTime? startedAt,
    DateTime? pickedUpAt,
    DateTime? completedAt,
    Duration? estimatedDuration,
    Duration? actualDuration,
    double? estimatedDistance,
    double? actualDistance,
    double? basePrice,
    double? totalPrice,
    PaymentMethod? paymentMethod,
    bool? needsPetTransport,
    bool? needsTrunkService,
    bool? needsCondominiumAccess,
    String? specialInstructions,
    String? driverNotes,
    double? passengerRating,
    double? driverRating,
  }) {
    return ActiveTrip(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destination: destination ?? this.destination,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      numberOfStops: numberOfStops ?? this.numberOfStops,
      stopLocations: stopLocations ?? this.stopLocations,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      actualDistance: actualDistance ?? this.actualDistance,
      basePrice: basePrice ?? this.basePrice,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      needsPetTransport: needsPetTransport ?? this.needsPetTransport,
      needsTrunkService: needsTrunkService ?? this.needsTrunkService,
      needsCondominiumAccess:
          needsCondominiumAccess ?? this.needsCondominiumAccess,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      driverNotes: driverNotes ?? this.driverNotes,
      passengerRating: passengerRating ?? this.passengerRating,
      driverRating: driverRating ?? this.driverRating,
    );
  }

  factory ActiveTrip.fromJson(Map<String, dynamic> json) {
    return ActiveTrip(
      id: json['id'] as String,
      passengerId: json['passengerId'] as String,
      passengerName: json['passengerName'] as String,
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
      status: TripStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => TripStatus.goingToPickup,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      pickedUpAt: json['pickedUpAt'] != null
          ? DateTime.parse(json['pickedUpAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      estimatedDuration: json['estimatedDuration'] != null
          ? Duration(seconds: json['estimatedDuration'] as int)
          : null,
      actualDuration: json['actualDuration'] != null
          ? Duration(seconds: json['actualDuration'] as int)
          : null,
      estimatedDistance: json['estimatedDistance'] != null
          ? (json['estimatedDistance'] as num).toDouble()
          : null,
      actualDistance: json['actualDistance'] != null
          ? (json['actualDistance'] as num).toDouble()
          : null,
      basePrice: (json['basePrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == json['paymentMethod'],
        orElse: () => PaymentMethod.money,
      ),
      needsPetTransport: json['needsPetTransport'] as bool? ?? false,
      needsTrunkService: json['needsTrunkService'] as bool? ?? false,
      needsCondominiumAccess: json['needsCondominiumAccess'] as bool? ?? false,
      specialInstructions: json['specialInstructions'] as String?,
      driverNotes: json['driverNotes'] as String?,
      passengerRating: json['passengerRating'] != null
          ? (json['passengerRating'] as num).toDouble()
          : null,
      driverRating: json['driverRating'] != null
          ? (json['driverRating'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerId': passengerId,
      'passengerName': passengerName,
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
      'status': status.name,
      'startedAt': startedAt.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'estimatedDuration': estimatedDuration?.inSeconds,
      'actualDuration': actualDuration?.inSeconds,
      'estimatedDistance': estimatedDistance,
      'actualDistance': actualDistance,
      'basePrice': basePrice,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod.name,
      'needsPetTransport': needsPetTransport,
      'needsTrunkService': needsTrunkService,
      'needsCondominiumAccess': needsCondominiumAccess,
      'specialInstructions': specialInstructions,
      'driverNotes': driverNotes,
      'passengerRating': passengerRating,
      'driverRating': driverRating,
    };
  }
}

/// Status da viagem ativa
enum TripStatus {
  goingToPickup, // Indo buscar o passageiro
  waitingPassenger, // Aguardando o passageiro no local
  inProgress, // Viagem em andamento (passageiro coletado)
  completed, // Viagem concluída
}
