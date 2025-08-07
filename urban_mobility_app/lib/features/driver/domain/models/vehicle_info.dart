/// Informações do veículo do condutor (Seção 4.1)
/// Implementa os dados do veículo necessários para verificação
class VehicleInfo {
  const VehicleInfo({
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.category,
    this.seats = 4,
    this.hasAirConditioning = false,
    this.hasTrunk = true,
    this.observations,
  });

  /// Marca do veículo
  final String brand;

  /// Modelo do veículo
  final String model;

  /// Ano do veículo
  final int year;

  /// Cor do veículo
  final String color;

  /// Placa do veículo
  final String licensePlate;

  /// Categoria do veículo
  final VehicleCategory category;

  /// Número de assentos
  final int seats;

  /// Possui ar-condicionado
  final bool hasAirConditioning;

  /// Possui porta-malas
  final bool hasTrunk;

  /// Observações adicionais
  final String? observations;

  /// Descrição completa do veículo
  String get fullDescription => '$brand $model $year - $color';

  /// Verifica se todos os campos obrigatórios estão preenchidos
  bool get isComplete =>
      brand.isNotEmpty &&
      model.isNotEmpty &&
      year > 1990 &&
      color.isNotEmpty &&
      licensePlate.isNotEmpty;

  /// Cria uma cópia com novos valores
  VehicleInfo copyWith({
    String? brand,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    VehicleCategory? category,
    int? seats,
    bool? hasAirConditioning,
    bool? hasTrunk,
    String? observations,
  }) {
    return VehicleInfo(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      category: category ?? this.category,
      seats: seats ?? this.seats,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      hasTrunk: hasTrunk ?? this.hasTrunk,
      observations: observations ?? this.observations,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'licensePlate': licensePlate,
      'category': category.name,
      'seats': seats,
      'hasAirConditioning': hasAirConditioning,
      'hasTrunk': hasTrunk,
      'observations': observations,
    };
  }

  /// Cria instância a partir do JSON
  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      color: json['color'] as String,
      licensePlate: json['licensePlate'] as String,
      category: VehicleCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => VehicleCategory.car,
      ),
      seats: json['seats'] as int? ?? 4,
      hasAirConditioning: json['hasAirConditioning'] as bool? ?? false,
      hasTrunk: json['hasTrunk'] as bool? ?? true,
      observations: json['observations'] as String?,
    );
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Cria instância vazia para novos motoristas
  factory VehicleInfo.empty() {
    return const VehicleInfo(
      brand: '',
      model: '',
      year: 2020,
      color: '',
      licensePlate: '',
      category: VehicleCategory.car,
    );
  }
}

/// Categorias de veículo conforme regras de negócio
enum VehicleCategory {
  /// Carro comum (até 4 passageiros)
  car,

  /// Carro grande (5-7 passageiros)
  carLarge,

  /// Veículo para frete
  freight,

  /// Guincho
  tow,
}

/// Extensão para facilitar o uso do enum
extension VehicleCategoryExtension on VehicleCategory {
  /// Nome amigável da categoria
  String get displayName {
    switch (this) {
      case VehicleCategory.car:
        return 'Carro Comum';
      case VehicleCategory.carLarge:
        return 'Carro 7 lugares';
      case VehicleCategory.freight:
        return 'Frete';
      case VehicleCategory.tow:
        return 'Guincho';
    }
  }

  /// Descrição da categoria
  String get description {
    switch (this) {
      case VehicleCategory.car:
        return 'Transporte de passageiros até 4 pessoas';
      case VehicleCategory.carLarge:
        return 'Transporte de passageiros de 5 a 7 pessoas';
      case VehicleCategory.freight:
        return 'Transporte de cargas e mudanças';
      case VehicleCategory.tow:
        return 'Reboque e guincho de veículos';
    }
  }

  /// Capacidade máxima de passageiros
  int get maxPassengers {
    switch (this) {
      case VehicleCategory.car:
        return 4;
      case VehicleCategory.carLarge:
        return 7;
      case VehicleCategory.freight:
        return 2;
      case VehicleCategory.tow:
        return 2;
    }
  }
}
