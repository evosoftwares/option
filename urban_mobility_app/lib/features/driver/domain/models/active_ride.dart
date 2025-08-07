import 'ride_request.dart';

/// Viagem ativa conforme regras de negócio (Seção 4.5)
class ActiveRide {
  const ActiveRide({
    required this.id,
    required this.rideRequestId,
    required this.driverId,
    required this.passengerId,
    required this.passengerName,
    required this.passengerPhone,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.status,
    required this.startedAt,
    required this.estimatedPrice,
    required this.finalPrice,
    this.passengerPhoto,
    this.passengerRating,
    this.specialRequests,
    this.notes,
    this.arrivedAtPickupAt,
    this.pickedUpAt,
    this.arrivedAtDestinationAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.route,
    this.actualDistance,
    this.actualDuration,
    this.waitingTime,
    this.additionalStops,
    this.paymentMethod,
    this.paymentStatus,
    this.driverRating,
    this.passengerFeedback,
    this.driverFeedback,
  });

  /// ID único da viagem
  final String id;

  /// ID da solicitação original
  final String rideRequestId;

  /// ID do motorista
  final String driverId;

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

  /// Status atual da viagem
  final ActiveRideStatus status;

  /// Data/hora de início da viagem
  final DateTime startedAt;

  /// Data/hora de chegada ao local de embarque
  final DateTime? arrivedAtPickupAt;

  /// Data/hora de embarque do passageiro
  final DateTime? pickedUpAt;

  /// Data/hora de chegada ao destino
  final DateTime? arrivedAtDestinationAt;

  /// Data/hora de conclusão da viagem
  final DateTime? completedAt;

  /// Data/hora de cancelamento
  final DateTime? cancelledAt;

  /// Motivo do cancelamento
  final String? cancellationReason;

  /// Preço estimado inicial
  final double estimatedPrice;

  /// Preço final da viagem
  final double finalPrice;

  /// Solicitações especiais
  final List<SpecialRequest>? specialRequests;

  /// Observações
  final String? notes;

  /// Rota da viagem
  final RideRoute? route;

  /// Distância real percorrida
  final double? actualDistance;

  /// Duração real da viagem
  final int? actualDuration;

  /// Tempo de espera (em minutos)
  final int? waitingTime;

  /// Paradas adicionais
  final List<RideLocation>? additionalStops;

  /// Método de pagamento
  final PaymentMethod? paymentMethod;

  /// Status do pagamento
  final PaymentStatus? paymentStatus;

  /// Avaliação do motorista pelo passageiro
  final double? driverRating;

  /// Feedback do passageiro
  final String? passengerFeedback;

  /// Feedback do motorista
  final String? driverFeedback;

  /// Verifica se a viagem está em andamento
  bool get isInProgress =>
      status == ActiveRideStatus.goingToPickup ||
      status == ActiveRideStatus.waitingForPassenger ||
      status == ActiveRideStatus.onTrip;

  /// Verifica se a viagem foi concluída
  bool get isCompleted => status == ActiveRideStatus.completed;

  /// Verifica se a viagem foi cancelada
  bool get isCancelled => status == ActiveRideStatus.cancelled;

  /// Verifica se pode ser cancelada
  bool get canBeCancelled =>
      status != ActiveRideStatus.completed &&
      status != ActiveRideStatus.cancelled;

  /// Verifica se o motorista chegou ao local de embarque
  bool get hasArrivedAtPickup => arrivedAtPickupAt != null;

  /// Verifica se o passageiro embarcou
  bool get hasPickedUpPassenger => pickedUpAt != null;

  /// Verifica se chegou ao destino
  bool get hasArrivedAtDestination => arrivedAtDestinationAt != null;

  /// Duração total da viagem em minutos
  int? get totalDurationMinutes {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt).inMinutes;
  }

  /// Tempo de espera formatado
  String get formattedWaitingTime {
    if (waitingTime == null) return '0min';
    return '${waitingTime}min';
  }

  /// Preço final formatado
  String get formattedFinalPrice => 'R\$ ${finalPrice.toStringAsFixed(2)}';

  /// Cria uma cópia com novos valores
  ActiveRide copyWith({
    String? id,
    String? rideRequestId,
    String? driverId,
    String? passengerId,
    String? passengerName,
    String? passengerPhone,
    String? passengerPhoto,
    double? passengerRating,
    RideLocation? pickupLocation,
    RideLocation? destinationLocation,
    ActiveRideStatus? status,
    DateTime? startedAt,
    DateTime? arrivedAtPickupAt,
    DateTime? pickedUpAt,
    DateTime? arrivedAtDestinationAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    double? estimatedPrice,
    double? finalPrice,
    List<SpecialRequest>? specialRequests,
    String? notes,
    RideRoute? route,
    double? actualDistance,
    int? actualDuration,
    int? waitingTime,
    List<RideLocation>? additionalStops,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    double? driverRating,
    String? passengerFeedback,
    String? driverFeedback,
  }) {
    return ActiveRide(
      id: id ?? this.id,
      rideRequestId: rideRequestId ?? this.rideRequestId,
      driverId: driverId ?? this.driverId,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerPhoto: passengerPhoto ?? this.passengerPhoto,
      passengerRating: passengerRating ?? this.passengerRating,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      arrivedAtPickupAt: arrivedAtPickupAt ?? this.arrivedAtPickupAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      arrivedAtDestinationAt:
          arrivedAtDestinationAt ?? this.arrivedAtDestinationAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      specialRequests: specialRequests ?? this.specialRequests,
      notes: notes ?? this.notes,
      route: route ?? this.route,
      actualDistance: actualDistance ?? this.actualDistance,
      actualDuration: actualDuration ?? this.actualDuration,
      waitingTime: waitingTime ?? this.waitingTime,
      additionalStops: additionalStops ?? this.additionalStops,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      driverRating: driverRating ?? this.driverRating,
      passengerFeedback: passengerFeedback ?? this.passengerFeedback,
      driverFeedback: driverFeedback ?? this.driverFeedback,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideRequestId': rideRequestId,
      'driverId': driverId,
      'passengerId': passengerId,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'passengerPhoto': passengerPhoto,
      'passengerRating': passengerRating,
      'pickupLocation': pickupLocation.toJson(),
      'destinationLocation': destinationLocation.toJson(),
      'status': status.name,
      'startedAt': startedAt.toIso8601String(),
      'arrivedAtPickupAt': arrivedAtPickupAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'arrivedAtDestinationAt': arrivedAtDestinationAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'estimatedPrice': estimatedPrice,
      'finalPrice': finalPrice,
      'specialRequests': specialRequests?.map((req) => req.toJson()).toList(),
      'notes': notes,
      'route': route?.toJson(),
      'actualDistance': actualDistance,
      'actualDuration': actualDuration,
      'waitingTime': waitingTime,
      'additionalStops': additionalStops?.map((stop) => stop.toJson()).toList(),
      'paymentMethod': paymentMethod?.name,
      'paymentStatus': paymentStatus?.name,
      'driverRating': driverRating,
      'passengerFeedback': passengerFeedback,
      'driverFeedback': driverFeedback,
    };
  }

  /// Cria instância a partir do JSON
  factory ActiveRide.fromJson(Map<String, dynamic> json) {
    return ActiveRide(
      id: json['id'] as String,
      rideRequestId: json['rideRequestId'] as String,
      driverId: json['driverId'] as String,
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
      status: ActiveRideStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      arrivedAtPickupAt: json['arrivedAtPickupAt'] != null
          ? DateTime.parse(json['arrivedAtPickupAt'] as String)
          : null,
      pickedUpAt: json['pickedUpAt'] != null
          ? DateTime.parse(json['pickedUpAt'] as String)
          : null,
      arrivedAtDestinationAt: json['arrivedAtDestinationAt'] != null
          ? DateTime.parse(json['arrivedAtDestinationAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      estimatedPrice: (json['estimatedPrice'] as num).toDouble(),
      finalPrice: (json['finalPrice'] as num).toDouble(),
      specialRequests: json['specialRequests'] != null
          ? (json['specialRequests'] as List<dynamic>)
                .map(
                  (req) => SpecialRequest.fromJson(req as Map<String, dynamic>),
                )
                .toList()
          : null,
      notes: json['notes'] as String?,
      route: json['route'] != null
          ? RideRoute.fromJson(json['route'] as Map<String, dynamic>)
          : null,
      actualDistance: (json['actualDistance'] as num?)?.toDouble(),
      actualDuration: json['actualDuration'] as int?,
      waitingTime: json['waitingTime'] as int?,
      additionalStops: json['additionalStops'] != null
          ? (json['additionalStops'] as List<dynamic>)
                .map(
                  (stop) => RideLocation.fromJson(stop as Map<String, dynamic>),
                )
                .toList()
          : null,
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.name == json['paymentMethod'],
            )
          : null,
      paymentStatus: json['paymentStatus'] != null
          ? PaymentStatus.values.firstWhere(
              (e) => e.name == json['paymentStatus'],
            )
          : null,
      driverRating: (json['driverRating'] as num?)?.toDouble(),
      passengerFeedback: json['passengerFeedback'] as String?,
      driverFeedback: json['driverFeedback'] as String?,
    );
  }
}

/// Status da viagem ativa
enum ActiveRideStatus {
  /// Indo para o local de embarque
  goingToPickup,

  /// Aguardando o passageiro no local de embarque
  waitingForPassenger,

  /// Em viagem com o passageiro
  onTrip,

  /// Viagem concluída
  completed,

  /// Viagem cancelada
  cancelled,
}

extension ActiveRideStatusExtension on ActiveRideStatus {
  /// Nome amigável
  String get displayName {
    switch (this) {
      case ActiveRideStatus.goingToPickup:
        return 'Indo para Embarque';
      case ActiveRideStatus.waitingForPassenger:
        return 'Aguardando Passageiro';
      case ActiveRideStatus.onTrip:
        return 'Em Viagem';
      case ActiveRideStatus.completed:
        return 'Concluída';
      case ActiveRideStatus.cancelled:
        return 'Cancelada';
    }
  }

  /// Descrição detalhada
  String get description {
    switch (this) {
      case ActiveRideStatus.goingToPickup:
        return 'Dirigindo-se ao local de embarque do passageiro';
      case ActiveRideStatus.waitingForPassenger:
        return 'Aguardando o passageiro no local de embarque';
      case ActiveRideStatus.onTrip:
        return 'Transportando o passageiro ao destino';
      case ActiveRideStatus.completed:
        return 'Viagem finalizada com sucesso';
      case ActiveRideStatus.cancelled:
        return 'Viagem foi cancelada';
    }
  }

  /// Cor associada
  String get colorHex {
    switch (this) {
      case ActiveRideStatus.goingToPickup:
        return '#2196F3'; // Azul
      case ActiveRideStatus.waitingForPassenger:
        return '#FF9800'; // Laranja
      case ActiveRideStatus.onTrip:
        return '#4CAF50'; // Verde
      case ActiveRideStatus.completed:
        return '#8BC34A'; // Verde claro
      case ActiveRideStatus.cancelled:
        return '#F44336'; // Vermelho
    }
  }

  /// Verifica se está em progresso
  bool get isInProgress =>
      this == ActiveRideStatus.goingToPickup ||
      this == ActiveRideStatus.waitingForPassenger ||
      this == ActiveRideStatus.onTrip;
}

/// Rota da viagem
class RideRoute {
  const RideRoute({
    required this.points,
    required this.distance,
    required this.duration,
    this.polyline,
    this.instructions,
  });

  /// Pontos da rota (coordenadas)
  final List<RideLocation> points;

  /// Distância total em km
  final double distance;

  /// Duração estimada em minutos
  final int duration;

  /// Polyline codificada para exibição no mapa
  final String? polyline;

  /// Instruções de navegação
  final List<String>? instructions;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'points': points.map((point) => point.toJson()).toList(),
      'distance': distance,
      'duration': duration,
      'polyline': polyline,
      'instructions': instructions,
    };
  }

  /// Cria instância a partir do JSON
  factory RideRoute.fromJson(Map<String, dynamic> json) {
    return RideRoute(
      points: (json['points'] as List<dynamic>)
          .map((point) => RideLocation.fromJson(point as Map<String, dynamic>))
          .toList(),
      distance: (json['distance'] as num).toDouble(),
      duration: json['duration'] as int,
      polyline: json['polyline'] as String?,
      instructions: json['instructions'] != null
          ? List<String>.from(json['instructions'] as List<dynamic>)
          : null,
    );
  }
}

/// Método de pagamento
enum PaymentMethod {
  /// Dinheiro
  cash,

  /// Cartão de crédito
  creditCard,

  /// Cartão de débito
  debitCard,

  /// PIX
  pix,

  /// Carteira digital
  digitalWallet,
}

extension PaymentMethodExtension on PaymentMethod {
  /// Nome amigável
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Dinheiro';
      case PaymentMethod.creditCard:
        return 'Cartão de Crédito';
      case PaymentMethod.debitCard:
        return 'Cartão de Débito';
      case PaymentMethod.pix:
        return 'PIX';
      case PaymentMethod.digitalWallet:
        return 'Carteira Digital';
    }
  }

  /// Ícone associado
  String get iconName {
    switch (this) {
      case PaymentMethod.cash:
        return 'attach_money';
      case PaymentMethod.creditCard:
        return 'credit_card';
      case PaymentMethod.debitCard:
        return 'payment';
      case PaymentMethod.pix:
        return 'qr_code';
      case PaymentMethod.digitalWallet:
        return 'account_balance_wallet';
    }
  }
}

/// Status do pagamento
enum PaymentStatus {
  /// Pendente
  pending,

  /// Processando
  processing,

  /// Aprovado
  approved,

  /// Rejeitado
  rejected,

  /// Cancelado
  cancelled,
}

extension PaymentStatusExtension on PaymentStatus {
  /// Nome amigável
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pendente';
      case PaymentStatus.processing:
        return 'Processando';
      case PaymentStatus.approved:
        return 'Aprovado';
      case PaymentStatus.rejected:
        return 'Rejeitado';
      case PaymentStatus.cancelled:
        return 'Cancelado';
    }
  }

  /// Cor associada
  String get colorHex {
    switch (this) {
      case PaymentStatus.pending:
        return '#FF9800'; // Laranja
      case PaymentStatus.processing:
        return '#2196F3'; // Azul
      case PaymentStatus.approved:
        return '#4CAF50'; // Verde
      case PaymentStatus.rejected:
        return '#F44336'; // Vermelho
      case PaymentStatus.cancelled:
        return '#9E9E9E'; // Cinza
    }
  }
}

/// Importações necessárias dos outros modelos
/// (RideLocation e SpecialRequest já estão definidos em ride_request.dart)
