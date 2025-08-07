/// Serviços Adicionais e Taxas do Condutor (Seção 4.2)
/// Implementa os serviços que o condutor oferece e suas taxas
class ServiceFees {
  const ServiceFees({
    required this.petTransport,
    required this.trunkService,
    required this.condominiumAccess,
    required this.stopService,
  });

  /// Serviço de transporte de pets
  final PetTransportService petTransport;

  /// Serviço de uso do porta-malas (mercado)
  final TrunkService trunkService;

  /// Serviço de acesso a condomínios
  final CondominiumAccessService condominiumAccess;

  /// Serviço de paradas no trajeto
  final StopService stopService;

  /// Calcula o total de taxas adicionais para uma viagem
  double calculateTotalFees({
    bool needsPetTransport = false,
    bool needsTrunkService = false,
    bool needsCondominiumAccess = false,
    int numberOfStops = 0,
  }) {
    double total = 0.0;

    if (needsPetTransport && petTransport.isActive) {
      total += petTransport.fee;
    }

    if (needsTrunkService && trunkService.isActive) {
      total += trunkService.fee;
    }

    if (needsCondominiumAccess && condominiumAccess.isActive) {
      total += condominiumAccess.fee;
    }

    if (numberOfStops > 0 && stopService.isActive) {
      total += stopService.fee * numberOfStops;
    }

    return total;
  }

  /// Verifica se atende aos requisitos do passageiro
  bool meetsPassengerRequirements({
    bool needsPet = false,
    bool needsTrunk = false,
    bool needsCondominium = false,
    bool needsStops = false,
  }) {
    if (needsPet && !petTransport.isActive) return false;
    if (needsTrunk && !trunkService.isActive) return false;
    if (needsCondominium && !condominiumAccess.isActive) return false;
    if (needsStops && !stopService.isActive) return false;

    return true;
  }

  factory ServiceFees.fromJson(Map<String, dynamic> json) {
    return ServiceFees(
      petTransport: PetTransportService.fromJson(
        json['petTransport'] as Map<String, dynamic>,
      ),
      trunkService: TrunkService.fromJson(
        json['trunkService'] as Map<String, dynamic>,
      ),
      condominiumAccess: CondominiumAccessService.fromJson(
        json['condominiumAccess'] as Map<String, dynamic>,
      ),
      stopService: StopService.fromJson(
        json['stopService'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'petTransport': petTransport.toJson(),
      'trunkService': trunkService.toJson(),
      'condominiumAccess': condominiumAccess.toJson(),
      'stopService': stopService.toJson(),
    };
  }

  /// Configuração padrão (todos os serviços desativados)
  factory ServiceFees.defaultConfig() {
    return const ServiceFees(
      petTransport: PetTransportService(isActive: false, fee: 0.0),
      trunkService: TrunkService(isActive: false, fee: 0.0),
      condominiumAccess: CondominiumAccessService(isActive: false, fee: 0.0),
      stopService: StopService(isActive: false, fee: 0.0),
    );
  }
}

/// Serviço de Transporte de Pet
class PetTransportService {
  const PetTransportService({required this.isActive, required this.fee});

  final bool isActive;
  final double fee;

  factory PetTransportService.fromJson(Map<String, dynamic> json) {
    return PetTransportService(
      isActive: json['isActive'] as bool,
      fee: (json['fee'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'isActive': isActive, 'fee': fee};
  }

  String get formattedFee => 'R\$ ${fee.toStringAsFixed(2)}';
}

/// Serviço de Uso do Porta-Malas (Mercado)
class TrunkService {
  const TrunkService({required this.isActive, required this.fee});

  final bool isActive;
  final double fee;

  factory TrunkService.fromJson(Map<String, dynamic> json) {
    return TrunkService(
      isActive: json['isActive'] as bool,
      fee: (json['fee'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'isActive': isActive, 'fee': fee};
  }

  String get formattedFee => 'R\$ ${fee.toStringAsFixed(2)}';
}

/// Serviço de Acesso a Condomínio
class CondominiumAccessService {
  const CondominiumAccessService({required this.isActive, required this.fee});

  final bool isActive;
  final double fee;

  factory CondominiumAccessService.fromJson(Map<String, dynamic> json) {
    return CondominiumAccessService(
      isActive: json['isActive'] as bool,
      fee: (json['fee'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'isActive': isActive, 'fee': fee};
  }

  String get formattedFee => 'R\$ ${fee.toStringAsFixed(2)}';
}

/// Serviço de Paradas no Trajeto
class StopService {
  const StopService({required this.isActive, required this.fee});

  final bool isActive;
  final double fee; // Taxa por parada

  factory StopService.fromJson(Map<String, dynamic> json) {
    return StopService(
      isActive: json['isActive'] as bool,
      fee: (json['fee'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'isActive': isActive, 'fee': fee};
  }

  String get formattedFee => 'R\$ ${fee.toStringAsFixed(2)} por parada';
}
