/// Status da viagem do motorista
enum TripStatus {
  /// Aguardando solicitação
  waiting,

  /// Indo buscar o passageiro
  goingToPickup,

  /// Chegou no local de embarque
  arrivedAtPickup,

  /// Aguardando o passageiro entrar
  waitingPassenger,

  /// Viagem em andamento
  onTrip,

  /// Chegou no destino
  arrivedAtDestination,

  /// Aguardando pagamento
  waitingPayment,

  /// Viagem finalizada
  completed,

  /// Viagem cancelada
  cancelled,
}

/// Extensão para facilitar o uso do enum
extension TripStatusExtension on TripStatus {
  String get displayName {
    switch (this) {
      case TripStatus.waiting:
        return 'Aguardando';
      case TripStatus.goingToPickup:
        return 'Indo Buscar';
      case TripStatus.arrivedAtPickup:
        return 'Chegou no Local';
      case TripStatus.waitingPassenger:
        return 'Aguardando Passageiro';
      case TripStatus.onTrip:
        return 'Em Viagem';
      case TripStatus.arrivedAtDestination:
        return 'Chegou no Destino';
      case TripStatus.waitingPayment:
        return 'Aguardando Pagamento';
      case TripStatus.completed:
        return 'Finalizada';
      case TripStatus.cancelled:
        return 'Cancelada';
    }
  }

  String get description {
    switch (this) {
      case TripStatus.waiting:
        return 'Aguardando nova solicitação de viagem';
      case TripStatus.goingToPickup:
        return 'Navegando até o local de embarque';
      case TripStatus.arrivedAtPickup:
        return 'Chegou no local. Aguarde o passageiro';
      case TripStatus.waitingPassenger:
        return 'Passageiro está entrando no veículo';
      case TripStatus.onTrip:
        return 'Viagem em andamento para o destino';
      case TripStatus.arrivedAtDestination:
        return 'Chegou no destino. Aguarde o desembarque';
      case TripStatus.waitingPayment:
        return 'Aguardando confirmação do pagamento';
      case TripStatus.completed:
        return 'Viagem concluída com sucesso';
      case TripStatus.cancelled:
        return 'Viagem foi cancelada';
    }
  }

  bool get canCancelTrip {
    return [
      TripStatus.goingToPickup,
      TripStatus.arrivedAtPickup,
      TripStatus.waitingPassenger,
    ].contains(this);
  }

  bool get requiresNavigation {
    return [TripStatus.goingToPickup, TripStatus.onTrip].contains(this);
  }

  bool get canStartTrip {
    return this == TripStatus.waitingPassenger;
  }

  bool get canCompleteTrip {
    return this == TripStatus.arrivedAtDestination;
  }
}
