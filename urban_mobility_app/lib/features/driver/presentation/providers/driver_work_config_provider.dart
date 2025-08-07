import 'package:flutter/foundation.dart';
import '../../domain/models/driver_work_config.dart';
import '../../domain/models/pricing_config.dart';
import '../../domain/models/service_fees.dart';
import '../../domain/models/excluded_zones.dart';

/// Provider para gerenciar a configuração do perfil de trabalho do motorista
class DriverWorkConfigProvider extends ChangeNotifier {
  DriverWorkConfig _config = DriverWorkConfig.defaultConfig();
  bool _isLoading = false;
  String? _error;

  DriverWorkConfig get config => _config;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carrega a configuração do motorista
  Future<void> loadConfig() async {
    _setLoading(true);
    try {
      // TODO: Implementar carregamento do backend/storage local
      // Por enquanto, usa configuração padrão
      _config = DriverWorkConfig.defaultConfig();
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar configurações: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Salva a configuração atual
  Future<void> saveConfig() async {
    _setLoading(true);
    try {
      // TODO: Implementar salvamento no backend/storage local
      _config = _config.copyWith(lastUpdated: DateTime.now());
      _error = null;
    } catch (e) {
      _error = 'Erro ao salvar configurações: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Métodos para atualizar configurações
  void updatePricingConfig(PricingConfig newConfig) {
    _config = _config.copyWith(pricingConfig: newConfig);
    notifyListeners();
  }

  void toggleCustomPricing(bool useCustom) {
    final newPricing = _config.pricingConfig.copyWith(
      useCustomPricing: useCustom,
    );
    _config = _config.copyWith(pricingConfig: newPricing);
    notifyListeners();
  }

  void updateCustomPricePerKm(double price) {
    final newPricing = _config.pricingConfig.copyWith(customPricePerKm: price);
    _config = _config.copyWith(pricingConfig: newPricing);
    notifyListeners();
  }

  void updateTimeMultiplier(double multiplier) {
    final newPricing = _config.pricingConfig.copyWith(
      timeMultiplier: multiplier,
    );
    _config = _config.copyWith(pricingConfig: newPricing);
    notifyListeners();
  }

  void updateServiceFees(ServiceFees newFees) {
    _config = _config.copyWith(serviceFees: newFees);
    notifyListeners();
  }

  void toggleService(String serviceType, bool isActive) {
    final services = _config.serviceFees;
    ServiceFees newServices;

    switch (serviceType) {
      case 'pet':
        newServices = ServiceFees(
          petTransport: PetTransportService(
            isActive: isActive,
            fee: services.petTransport.fee,
          ),
          trunkService: services.trunkService,
          condominiumAccess: services.condominiumAccess,
          stopService: services.stopService,
        );
        break;
      case 'trunk':
        newServices = ServiceFees(
          petTransport: services.petTransport,
          trunkService: TrunkService(
            isActive: isActive,
            fee: services.trunkService.fee,
          ),
          condominiumAccess: services.condominiumAccess,
          stopService: services.stopService,
        );
        break;
      case 'condominium':
        newServices = ServiceFees(
          petTransport: services.petTransport,
          trunkService: services.trunkService,
          condominiumAccess: CondominiumAccessService(
            isActive: isActive,
            fee: services.condominiumAccess.fee,
          ),
          stopService: services.stopService,
        );
        break;
      case 'stop':
        newServices = ServiceFees(
          petTransport: services.petTransport,
          trunkService: services.trunkService,
          condominiumAccess: services.condominiumAccess,
          stopService: StopService(
            isActive: isActive,
            fee: services.stopService.fee,
          ),
        );
        break;
      default:
        return;
    }

    _config = _config.copyWith(serviceFees: newServices);
    notifyListeners();
  }

  void updateServiceFee(String serviceType, double fee) {
    final services = _config.serviceFees;
    ServiceFees newServices;

    switch (serviceType) {
      case 'pet':
        newServices = ServiceFees(
          petTransport: PetTransportService(
            isActive: services.petTransport.isActive,
            fee: fee,
          ),
          trunkService: services.trunkService,
          condominiumAccess: services.condominiumAccess,
          stopService: services.stopService,
        );
        break;
      case 'trunk':
        newServices = ServiceFees(
          petTransport: services.petTransport,
          trunkService: TrunkService(
            isActive: services.trunkService.isActive,
            fee: fee,
          ),
          condominiumAccess: services.condominiumAccess,
          stopService: services.stopService,
        );
        break;
      case 'condominium':
        newServices = ServiceFees(
          petTransport: services.petTransport,
          trunkService: services.trunkService,
          condominiumAccess: CondominiumAccessService(
            isActive: services.condominiumAccess.isActive,
            fee: fee,
          ),
          stopService: services.stopService,
        );
        break;
      case 'stop':
        newServices = ServiceFees(
          petTransport: services.petTransport,
          trunkService: services.trunkService,
          condominiumAccess: services.condominiumAccess,
          stopService: StopService(
            isActive: services.stopService.isActive,
            fee: fee,
          ),
        );
        break;
      default:
        return;
    }

    _config = _config.copyWith(serviceFees: newServices);
    notifyListeners();
  }

  void updateAirConditioningPolicy(AirConditioningPolicy policy) {
    _config = _config.copyWith(airConditioningPolicy: policy);
    notifyListeners();
  }

  void updateExcludedZones(ExcludedZones zones) {
    _config = _config.copyWith(excludedZones: zones);
    notifyListeners();
  }

  /// Ativa/desativa o uso de preços personalizados
  void toggleCustomPricing(bool useCustom) {
    final newPricingConfig = _config.pricingConfig.copyWith(
      useCustomPricing: useCustom,
    );
    updatePricingConfig(newPricingConfig);
  }

  /// Atualiza o preço por KM personalizado
  void updateCustomPricePerKm(double? price) {
    final newPricingConfig = _config.pricingConfig.copyWith(
      customPricePerKm: price,
    );
    updatePricingConfig(newPricingConfig);
  }

  /// Atualiza o multiplicador de tempo
  void updateTimeMultiplier(double multiplier) {
    final newPricingConfig = _config.pricingConfig.copyWith(
      timeMultiplier: multiplier,
    );
    updatePricingConfig(newPricingConfig);
  }

  /// Ativa/desativa um serviço específico
  void toggleService(String serviceType, bool isActive) {
    final currentFees = _config.serviceFees;
    ServiceFees newFees;

    switch (serviceType) {
      case 'pet':
        newFees = ServiceFees(
          petTransport: PetTransportService(
            isActive: isActive,
            fee: currentFees.petTransport.fee,
          ),
          trunkService: currentFees.trunkService,
          condominiumAccess: currentFees.condominiumAccess,
          stopService: currentFees.stopService,
        );
        break;
      case 'trunk':
        newFees = ServiceFees(
          petTransport: currentFees.petTransport,
          trunkService: TrunkService(
            isActive: isActive,
            fee: currentFees.trunkService.fee,
          ),
          condominiumAccess: currentFees.condominiumAccess,
          stopService: currentFees.stopService,
        );
        break;
      case 'condominium':
        newFees = ServiceFees(
          petTransport: currentFees.petTransport,
          trunkService: currentFees.trunkService,
          condominiumAccess: CondominiumAccessService(
            isActive: isActive,
            fee: currentFees.condominiumAccess.fee,
          ),
          stopService: currentFees.stopService,
        );
        break;
      case 'stop':
        newFees = ServiceFees(
          petTransport: currentFees.petTransport,
          trunkService: currentFees.trunkService,
          condominiumAccess: currentFees.condominiumAccess,
          stopService: StopService(
            isActive: isActive,
            fee: currentFees.stopService.fee,
          ),
        );
        break;
      default:
        return;
    }

    updateServiceFees(newFees);
  }

  /// Atualiza a taxa de um serviço específico
  void updateServiceFee(String serviceType, double fee) {
    final currentFees = _config.serviceFees;
    ServiceFees newFees;

    switch (serviceType) {
      case 'pet':
        newFees = ServiceFees(
          petTransport: PetTransportService(
            isActive: currentFees.petTransport.isActive,
            fee: fee,
          ),
          trunkService: currentFees.trunkService,
          condominiumAccess: currentFees.condominiumAccess,
          stopService: currentFees.stopService,
        );
        break;
      case 'trunk':
        newFees = ServiceFees(
          petTransport: currentFees.petTransport,
          trunkService: TrunkService(
            isActive: currentFees.trunkService.isActive,
            fee: fee,
          ),
          condominiumAccess: currentFees.condominiumAccess,
          stopService: currentFees.stopService,
        );
        break;
      case 'condominium':
        newFees = ServiceFees(
          petTransport: currentFees.petTransport,
          trunkService: currentFees.trunkService,
          condominiumAccess: CondominiumAccessService(
            isActive: currentFees.condominiumAccess.isActive,
            fee: fee,
          ),
          stopService: currentFees.stopService,
        );
        break;
      case 'stop':
        newFees = ServiceFees(
          petTransport: currentFees.petTransport,
          trunkService: currentFees.trunkService,
          condominiumAccess: currentFees.condominiumAccess,
          stopService: StopService(
            isActive: currentFees.stopService.isActive,
            fee: fee,
          ),
        );
        break;
      default:
        return;
    }

    updateServiceFees(newFees);
  }

  /// Adiciona um bairro à lista de exclusão
  void addExcludedNeighborhood(ExcludedNeighborhood neighborhood) {
    final newExcludedZones = _config.excludedZones.addNeighborhood(
      neighborhood,
    );
    updateExcludedZones(newExcludedZones);
  }

  /// Remove um bairro da lista de exclusão
  void removeExcludedNeighborhood(String neighborhoodName, String city) {
    final newExcludedZones = _config.excludedZones.removeNeighborhood(
      neighborhoodName,
      city,
    );
    updateExcludedZones(newExcludedZones);
  }

  /// Valida se a configuração está válida
  bool get isValid {
    // Verifica se preços personalizados estão válidos
    if (_config.pricingConfig.useCustomPricing) {
      if (_config.pricingConfig.customPricePerKm == null ||
          _config.pricingConfig.customPricePerKm! <= 0) {
        return false;
      }
    }

    // Verifica se multiplicador de tempo é válido
    if (_config.pricingConfig.timeMultiplier <= 0) {
      return false;
    }

    // Verifica se taxas de serviços ativos são válidas
    if (_config.serviceFees.petTransport.isActive &&
        _config.serviceFees.petTransport.fee < 0) {
      return false;
    }

    if (_config.serviceFees.trunkService.isActive &&
        _config.serviceFees.trunkService.fee < 0) {
      return false;
    }

    if (_config.serviceFees.condominiumAccess.isActive &&
        _config.serviceFees.condominiumAccess.fee < 0) {
      return false;
    }

    if (_config.serviceFees.stopService.isActive &&
        _config.serviceFees.stopService.fee < 0) {
      return false;
    }

    return true;
  }

  /// Lista de bairros excluídos
  List<ExcludedNeighborhood> get excludedNeighborhoods =>
      _config.excludedZones.neighborhoods;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
