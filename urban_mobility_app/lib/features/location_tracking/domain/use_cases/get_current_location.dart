import '../entities/location_data.dart';
import '../entities/tracking_config.dart';
import '../repositories/location_repository.dart';
import 'start_location_tracking.dart';

/// Caso de uso para obter localização atual
/// 
/// Encapsula a lógica de negócio para obter a localização
/// atual do dispositivo com validações e tratamento de erros.
class GetCurrentLocationUseCase {

  const GetCurrentLocationUseCase(this._repository);
  final LocationRepository _repository;

  /// Executa o caso de uso
  /// 
  /// [config] - Configuração para obtenção da localização
  /// 
  /// Retorna [EnhancedLocationData] com a localização atual
  /// ou lança exceção em caso de erro.
  Future<EnhancedLocationData> execute([TrackingConfig? config]) async {
    // Usar configuração padrão se não fornecida
    final trackingConfig = config ?? TrackingConfig.balanced();

    // Validar permissões
    final hasPermission = await _repository.hasLocationPermission();
    if (!hasPermission) {
      final granted = await _repository.requestLocationPermission();
      if (!granted) {
        throw const LocationPermissionDeniedException(
          'Permissão de localização é necessária'
        );
      }
    }

    // Validar serviço de localização
    final isServiceEnabled = await _repository.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw const LocationServiceDisabledException(
        'Serviço de localização está desabilitado'
      );
    }

    // Obter localização atual
    try {
      return await _repository.getCurrentLocation(trackingConfig);
    } catch (e) {
      throw LocationTrackingException(
        'Erro ao obter localização atual: ${e.toString()}'
      );
    }
  }
}