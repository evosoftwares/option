/// Ganhos da Viagem (Seção 4.5)
/// Implementa a gestão pós-viagem e cálculo de ganhos
class TripEarnings {
  const TripEarnings({
    required this.tripId,
    required this.basePrice,
    required this.serviceFees,
    required this.platformFee,
    required this.netEarnings,
    required this.paymentMethod,
    required this.completedAt,
    required this.distance,
    required this.duration,
    this.tips = 0.0,
    this.bonuses = 0.0,
    this.deductions = 0.0,
    this.notes,
  });

  final String tripId;

  // Componentes do preço
  final double basePrice; // Preço base da viagem
  final double serviceFees; // Taxas de serviços adicionais
  final double tips; // Gorjetas
  final double bonuses; // Bônus (ex: horário de pico)
  final double deductions; // Deduções (ex: cancelamentos)

  // Taxas da plataforma
  final double platformFee; // Taxa da plataforma
  final double netEarnings; // Ganho líquido do motorista

  // Informações da viagem
  final PaymentMethod paymentMethod;
  final DateTime completedAt;
  final double distance; // Distância real percorrida
  final Duration duration; // Duração real da viagem
  final String? notes;

  /// Receita bruta total (antes das taxas da plataforma)
  double get grossRevenue =>
      basePrice + serviceFees + tips + bonuses - deductions;

  /// Taxa da plataforma em percentual
  double get platformFeePercentage =>
      grossRevenue > 0 ? (platformFee / grossRevenue) * 100 : 0.0;

  /// Ganho por quilômetro
  double get earningsPerKm => distance > 0 ? netEarnings / distance : 0.0;

  /// Ganho por hora
  double get earningsPerHour {
    final hours = duration.inMinutes / 60.0;
    return hours > 0 ? netEarnings / hours : 0.0;
  }

  /// Receita bruta formatada
  String get formattedGrossRevenue => 'R\$ ${grossRevenue.toStringAsFixed(2)}';

  /// Ganho líquido formatado
  String get formattedNetEarnings => 'R\$ ${netEarnings.toStringAsFixed(2)}';

  /// Taxa da plataforma formatada
  String get formattedPlatformFee => 'R\$ ${platformFee.toStringAsFixed(2)}';

  /// Distância formatada
  String get formattedDistance => '${distance.toStringAsFixed(1)} km';

  /// Duração formatada
  String get formattedDuration {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}min';
    }
  }

  /// Ganho por km formatado
  String get formattedEarningsPerKm =>
      'R\$ ${earningsPerKm.toStringAsFixed(2)}/km';

  /// Ganho por hora formatado
  String get formattedEarningsPerHour =>
      'R\$ ${earningsPerHour.toStringAsFixed(2)}/h';

  /// Adicionar gorjeta
  TripEarnings addTip(double tipAmount) {
    return copyWith(
      tips: tips + tipAmount,
      netEarnings:
          netEarnings + tipAmount, // Gorjeta vai direto para o motorista
    );
  }

  /// Adicionar bônus
  TripEarnings addBonus(double bonusAmount, String reason) {
    return copyWith(
      bonuses: bonuses + bonusAmount,
      netEarnings: netEarnings + bonusAmount,
      notes: notes != null ? '$notes\nBônus: $reason' : 'Bônus: $reason',
    );
  }

  /// Aplicar dedução
  TripEarnings applyDeduction(double deductionAmount, String reason) {
    return copyWith(
      deductions: deductions + deductionAmount,
      netEarnings: netEarnings - deductionAmount,
      notes: notes != null ? '$notes\nDedução: $reason' : 'Dedução: $reason',
    );
  }

  TripEarnings copyWith({
    String? tripId,
    double? basePrice,
    double? serviceFees,
    double? tips,
    double? bonuses,
    double? deductions,
    double? platformFee,
    double? netEarnings,
    PaymentMethod? paymentMethod,
    DateTime? completedAt,
    double? distance,
    Duration? duration,
    String? notes,
  }) {
    return TripEarnings(
      tripId: tripId ?? this.tripId,
      basePrice: basePrice ?? this.basePrice,
      serviceFees: serviceFees ?? this.serviceFees,
      tips: tips ?? this.tips,
      bonuses: bonuses ?? this.bonuses,
      deductions: deductions ?? this.deductions,
      platformFee: platformFee ?? this.platformFee,
      netEarnings: netEarnings ?? this.netEarnings,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      completedAt: completedAt ?? this.completedAt,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
    );
  }

  factory TripEarnings.fromJson(Map<String, dynamic> json) {
    return TripEarnings(
      tripId: json['tripId'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      serviceFees: (json['serviceFees'] as num).toDouble(),
      tips: (json['tips'] as num?)?.toDouble() ?? 0.0,
      bonuses: (json['bonuses'] as num?)?.toDouble() ?? 0.0,
      deductions: (json['deductions'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platformFee'] as num).toDouble(),
      netEarnings: (json['netEarnings'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == json['paymentMethod'],
        orElse: () => PaymentMethod.money,
      ),
      completedAt: DateTime.parse(json['completedAt'] as String),
      distance: (json['distance'] as num).toDouble(),
      duration: Duration(seconds: json['duration'] as int),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'basePrice': basePrice,
      'serviceFees': serviceFees,
      'tips': tips,
      'bonuses': bonuses,
      'deductions': deductions,
      'platformFee': platformFee,
      'netEarnings': netEarnings,
      'paymentMethod': paymentMethod.name,
      'completedAt': completedAt.toIso8601String(),
      'distance': distance,
      'duration': duration.inSeconds,
      'notes': notes,
    };
  }

  /// Calcular ganhos a partir de uma viagem ativa
  factory TripEarnings.fromActiveTrip({
    required String tripId,
    required double basePrice,
    required double serviceFees,
    required PaymentMethod paymentMethod,
    required DateTime completedAt,
    required double distance,
    required Duration duration,
    double platformFeePercentage = 20.0, // 20% padrão da plataforma
    double tips = 0.0,
    double bonuses = 0.0,
    double deductions = 0.0,
  }) {
    final grossRevenue = basePrice + serviceFees + tips + bonuses - deductions;
    final platformFee = grossRevenue * (platformFeePercentage / 100);
    final netEarnings = grossRevenue - platformFee;

    return TripEarnings(
      tripId: tripId,
      basePrice: basePrice,
      serviceFees: serviceFees,
      tips: tips,
      bonuses: bonuses,
      deductions: deductions,
      platformFee: platformFee,
      netEarnings: netEarnings,
      paymentMethod: paymentMethod,
      completedAt: completedAt,
      distance: distance,
      duration: duration,
    );
  }
}

/// Método de pagamento
enum PaymentMethod {
  money, // Dinheiro
  pix, // PIX
  card, // Cartão
}
