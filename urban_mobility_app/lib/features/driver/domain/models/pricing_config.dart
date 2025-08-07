/// Configuração de Preços Personalizada do Condutor (Seção 4.2)
/// Implementa o "Ajuste de Ganhos (Dinâmico)" das regras de negócio
class PricingConfig {
  const PricingConfig({
    required this.customPricePerKm,
    required this.timeMultiplier,
    required this.useCustomPricing,
  });

  /// Preço por KM Personalizado (substitui o valor padrão da plataforma)
  final double? customPricePerKm;

  /// Multiplicador de Tempo (ex: 1.2x se aplica sobre o valor por minuto)
  final double timeMultiplier;

  /// Se deve usar preços personalizados ou padrão da plataforma
  final bool useCustomPricing;

  /// Obtém o preço por KM a ser aplicado
  double getPricePerKm(double platformDefaultPricePerKm) {
    if (useCustomPricing && customPricePerKm != null) {
      return customPricePerKm!;
    }
    return platformDefaultPricePerKm;
  }

  /// Calcula o componente de distância
  double calculateDistanceComponent(
    double distanceKm,
    double platformDefaultPricePerKm,
  ) {
    return getPricePerKm(platformDefaultPricePerKm) * distanceKm;
  }

  /// Calcula o componente de tempo
  double calculateTimeComponent(
    Duration duration,
    double platformPricePerMinute,
  ) {
    final minutes = duration.inMinutes.toDouble();
    return (platformPricePerMinute * minutes) * timeMultiplier;
  }

  factory PricingConfig.fromJson(Map<String, dynamic> json) {
    return PricingConfig(
      customPricePerKm: (json['customPricePerKm'] as num?)?.toDouble(),
      timeMultiplier: (json['timeMultiplier'] as num).toDouble(),
      useCustomPricing: json['useCustomPricing'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customPricePerKm': customPricePerKm,
      'timeMultiplier': timeMultiplier,
      'useCustomPricing': useCustomPricing,
    };
  }

  /// Configuração padrão (usa preços da plataforma)
  factory PricingConfig.defaultConfig() {
    return const PricingConfig(
      customPricePerKm: null,
      timeMultiplier: 1.0,
      useCustomPricing: false,
    );
  }

  /// Cria uma cópia com alterações
  PricingConfig copyWith({
    double? customPricePerKm,
    double? timeMultiplier,
    bool? useCustomPricing,
  }) {
    return PricingConfig(
      customPricePerKm: customPricePerKm ?? this.customPricePerKm,
      timeMultiplier: timeMultiplier ?? this.timeMultiplier,
      useCustomPricing: useCustomPricing ?? this.useCustomPricing,
    );
  }

  /// Formata o preço por KM para exibição
  String formatPricePerKm(double platformDefaultPricePerKm) {
    final price = getPricePerKm(platformDefaultPricePerKm);
    return 'R\$ ${price.toStringAsFixed(2)}/km';
  }

  /// Formata o multiplicador de tempo para exibição
  String get formattedTimeMultiplier {
    return '${timeMultiplier.toStringAsFixed(1)}x';
  }
}
