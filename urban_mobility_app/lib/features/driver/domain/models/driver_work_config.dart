/// Configurações de trabalho do condutor conforme regras de negócio (Seção 4.2)
class DriverWorkConfig {
  const DriverWorkConfig({
    required this.pricingConfig,
    required this.serviceFees,
    required this.workingAreas,
    required this.isActive,
    this.lastUpdated,
  });

  /// Configurações de preços
  final PricingConfig pricingConfig;

  /// Taxas de serviços adicionais
  final ServiceFees serviceFees;

  /// Áreas de trabalho
  final List<WorkingArea> workingAreas;

  /// Se as configurações estão ativas
  final bool isActive;

  /// Última atualização
  final DateTime? lastUpdated;

  /// Cria uma cópia com novos valores
  DriverWorkConfig copyWith({
    PricingConfig? pricingConfig,
    ServiceFees? serviceFees,
    List<WorkingArea>? workingAreas,
    bool? isActive,
    DateTime? lastUpdated,
  }) {
    return DriverWorkConfig(
      pricingConfig: pricingConfig ?? this.pricingConfig,
      serviceFees: serviceFees ?? this.serviceFees,
      workingAreas: workingAreas ?? this.workingAreas,
      isActive: isActive ?? this.isActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'pricingConfig': pricingConfig.toJson(),
      'serviceFees': serviceFees.toJson(),
      'workingAreas': workingAreas.map((area) => area.toJson()).toList(),
      'isActive': isActive,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Cria instância a partir do JSON
  factory DriverWorkConfig.fromJson(Map<String, dynamic> json) {
    return DriverWorkConfig(
      pricingConfig: PricingConfig.fromJson(
        json['pricingConfig'] as Map<String, dynamic>,
      ),
      serviceFees: ServiceFees.fromJson(
        json['serviceFees'] as Map<String, dynamic>,
      ),
      workingAreas: (json['workingAreas'] as List<dynamic>)
          .map((area) => WorkingArea.fromJson(area as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  /// Cria instância a partir do Firestore
  factory DriverWorkConfig.fromFirestore(Map<String, dynamic> data, String id) {
    return DriverWorkConfig.fromJson(data);
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Configuração padrão para novos motoristas
  factory DriverWorkConfig.defaultConfig() {
    return DriverWorkConfig(
      pricingConfig: PricingConfig.defaultConfig(),
      serviceFees: ServiceFees.defaultConfig(),
      workingAreas: [],
      isActive: false,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Configurações de preços (Seção 4.2.1)
class PricingConfig {
  const PricingConfig({
    required this.useCustomPricing,
    required this.basePricePerKm,
    required this.timeMultiplier,
    required this.minimumFare,
    this.peakHourMultiplier = 1.0,
    this.nightMultiplier = 1.0,
  });

  /// Se usa preços personalizados
  final bool useCustomPricing;

  /// Preço base por km
  final double basePricePerKm;

  /// Multiplicador de tempo
  final double timeMultiplier;

  /// Tarifa mínima
  final double minimumFare;

  /// Multiplicador para horário de pico
  final double peakHourMultiplier;

  /// Multiplicador noturno
  final double nightMultiplier;

  /// Cria uma cópia com novos valores
  PricingConfig copyWith({
    bool? useCustomPricing,
    double? basePricePerKm,
    double? timeMultiplier,
    double? minimumFare,
    double? peakHourMultiplier,
    double? nightMultiplier,
  }) {
    return PricingConfig(
      useCustomPricing: useCustomPricing ?? this.useCustomPricing,
      basePricePerKm: basePricePerKm ?? this.basePricePerKm,
      timeMultiplier: timeMultiplier ?? this.timeMultiplier,
      minimumFare: minimumFare ?? this.minimumFare,
      peakHourMultiplier: peakHourMultiplier ?? this.peakHourMultiplier,
      nightMultiplier: nightMultiplier ?? this.nightMultiplier,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'useCustomPricing': useCustomPricing,
      'basePricePerKm': basePricePerKm,
      'timeMultiplier': timeMultiplier,
      'minimumFare': minimumFare,
      'peakHourMultiplier': peakHourMultiplier,
      'nightMultiplier': nightMultiplier,
    };
  }

  /// Cria instância a partir do JSON
  factory PricingConfig.fromJson(Map<String, dynamic> json) {
    return PricingConfig(
      useCustomPricing: json['useCustomPricing'] as bool? ?? false,
      basePricePerKm: (json['basePricePerKm'] as num?)?.toDouble() ?? 2.50,
      timeMultiplier: (json['timeMultiplier'] as num?)?.toDouble() ?? 1.0,
      minimumFare: (json['minimumFare'] as num?)?.toDouble() ?? 5.00,
      peakHourMultiplier:
          (json['peakHourMultiplier'] as num?)?.toDouble() ?? 1.0,
      nightMultiplier: (json['nightMultiplier'] as num?)?.toDouble() ?? 1.0,
    );
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Configuração padrão
  factory PricingConfig.defaultConfig() {
    return const PricingConfig(
      useCustomPricing: false,
      basePricePerKm: 2.50,
      timeMultiplier: 1.0,
      minimumFare: 5.00,
      peakHourMultiplier: 1.0,
      nightMultiplier: 1.0,
    );
  }
}

/// Taxas de serviços adicionais (Seção 4.2.2)
class ServiceFees {
  const ServiceFees({
    required this.petTransport,
    required this.trunkService,
    required this.condominiumAccess,
    required this.stopService,
    required this.airConditioningPolicy,
    this.airConditioningFee = 0.0,
  });

  /// Transporte de animais
  final PetTransportService petTransport;

  /// Serviço de porta-malas
  final TrunkService trunkService;

  /// Acesso a condomínio
  final CondominiumAccessService condominiumAccess;

  /// Serviço de paradas
  final StopService stopService;

  /// Política de ar-condicionado
  final AirConditioningPolicy airConditioningPolicy;

  /// Taxa de ar-condicionado
  final double airConditioningFee;

  /// Cria uma cópia com novos valores
  ServiceFees copyWith({
    PetTransportService? petTransport,
    TrunkService? trunkService,
    CondominiumAccessService? condominiumAccess,
    StopService? stopService,
    AirConditioningPolicy? airConditioningPolicy,
    double? airConditioningFee,
  }) {
    return ServiceFees(
      petTransport: petTransport ?? this.petTransport,
      trunkService: trunkService ?? this.trunkService,
      condominiumAccess: condominiumAccess ?? this.condominiumAccess,
      stopService: stopService ?? this.stopService,
      airConditioningPolicy:
          airConditioningPolicy ?? this.airConditioningPolicy,
      airConditioningFee: airConditioningFee ?? this.airConditioningFee,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'petTransport': petTransport.toJson(),
      'trunkService': trunkService.toJson(),
      'condominiumAccess': condominiumAccess.toJson(),
      'stopService': stopService.toJson(),
      'airConditioningPolicy': airConditioningPolicy.name,
      'airConditioningFee': airConditioningFee,
    };
  }

  /// Cria instância a partir do JSON
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
      airConditioningPolicy: AirConditioningPolicy.values.firstWhere(
        (e) => e.name == json['airConditioningPolicy'],
        orElse: () => AirConditioningPolicy.onRequest,
      ),
      airConditioningFee:
          (json['airConditioningFee'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Configuração padrão
  factory ServiceFees.defaultConfig() {
    return ServiceFees(
      petTransport: PetTransportService(isActive: false, fee: 5.0),
      trunkService: TrunkService(isActive: false, fee: 3.0),
      condominiumAccess: CondominiumAccessService(isActive: false, fee: 2.0),
      stopService: StopService(isActive: false, fee: 1.0),
      airConditioningPolicy: AirConditioningPolicy.onRequest,
      airConditioningFee: 2.0,
    );
  }
}

/// Serviço de transporte de animais
class PetTransportService {
  const PetTransportService({required this.isActive, required this.fee});

  /// Se o serviço está ativo
  final bool isActive;

  /// Taxa do serviço
  final double fee;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {'isActive': isActive, 'fee': fee};
  }

  /// Cria instância a partir do JSON
  factory PetTransportService.fromJson(Map<String, dynamic> json) {
    return PetTransportService(
      isActive: json['isActive'] as bool? ?? false,
      fee: (json['fee'] as num?)?.toDouble() ?? 5.0,
    );
  }
}

/// Serviço de porta-malas
class TrunkService {
  const TrunkService({required this.isActive, required this.fee});

  /// Se o serviço está ativo
  final bool isActive;

  /// Taxa do serviço
  final double fee;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {'isActive': isActive, 'fee': fee};
  }

  /// Cria instância a partir do JSON
  factory TrunkService.fromJson(Map<String, dynamic> json) {
    return TrunkService(
      isActive: json['isActive'] as bool? ?? false,
      fee: (json['fee'] as num?)?.toDouble() ?? 3.0,
    );
  }
}

/// Serviço de acesso a condomínio
class CondominiumAccessService {
  const CondominiumAccessService({required this.isActive, required this.fee});

  /// Se o serviço está ativo
  final bool isActive;

  /// Taxa do serviço
  final double fee;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {'isActive': isActive, 'fee': fee};
  }

  /// Cria instância a partir do JSON
  factory CondominiumAccessService.fromJson(Map<String, dynamic> json) {
    return CondominiumAccessService(
      isActive: json['isActive'] as bool? ?? false,
      fee: (json['fee'] as num?)?.toDouble() ?? 2.0,
    );
  }
}

/// Serviço de paradas
class StopService {
  const StopService({required this.isActive, required this.fee});

  /// Se o serviço está ativo
  final bool isActive;

  /// Taxa do serviço
  final double fee;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {'isActive': isActive, 'fee': fee};
  }

  /// Cria instância a partir do JSON
  factory StopService.fromJson(Map<String, dynamic> json) {
    return StopService(
      isActive: json['isActive'] as bool? ?? false,
      fee: (json['fee'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

/// Política de ar-condicionado
enum AirConditioningPolicy {
  /// Sempre ligado
  alwaysOn,

  /// Sob demanda
  onRequest,

  /// Nunca
  never,
}

extension AirConditioningPolicyExtension on AirConditioningPolicy {
  /// Nome amigável
  String get displayName {
    switch (this) {
      case AirConditioningPolicy.alwaysOn:
        return 'Sempre Ligado';
      case AirConditioningPolicy.onRequest:
        return 'Sob Demanda';
      case AirConditioningPolicy.never:
        return 'Nunca';
    }
  }

  /// Descrição
  String get description {
    switch (this) {
      case AirConditioningPolicy.alwaysOn:
        return 'Ar-condicionado sempre ligado durante a viagem';
      case AirConditioningPolicy.onRequest:
        return 'Ar-condicionado ligado apenas quando solicitado';
      case AirConditioningPolicy.never:
        return 'Ar-condicionado não disponível';
    }
  }
}

/// Área de trabalho do motorista
class WorkingArea {
  const WorkingArea({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.isActive,
    this.priority = 1,
  });

  /// ID da área
  final String id;

  /// Nome da área
  final String name;

  /// Coordenadas da área (polígono)
  final List<AreaCoordinate> coordinates;

  /// Se a área está ativa
  final bool isActive;

  /// Prioridade da área (1 = maior prioridade)
  final int priority;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coordinates': coordinates.map((coord) => coord.toJson()).toList(),
      'isActive': isActive,
      'priority': priority,
    };
  }

  /// Cria instância a partir do JSON
  factory WorkingArea.fromJson(Map<String, dynamic> json) {
    return WorkingArea(
      id: json['id'] as String,
      name: json['name'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map(
            (coord) => AreaCoordinate.fromJson(coord as Map<String, dynamic>),
          )
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
      priority: json['priority'] as int? ?? 1,
    );
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}

/// Coordenada de área
class AreaCoordinate {
  const AreaCoordinate({required this.latitude, required this.longitude});

  /// Latitude
  final double latitude;

  /// Longitude
  final double longitude;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  /// Cria instância a partir do JSON
  factory AreaCoordinate.fromJson(Map<String, dynamic> json) {
    return AreaCoordinate(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
