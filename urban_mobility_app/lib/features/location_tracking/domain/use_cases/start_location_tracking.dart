import '../entities/location_data.dart';
import '../entities/tracking_config.dart';
import '../repositories/location_repository.dart';

/// Caso de uso para iniciar rastreamento de localização
/// 
/// Encapsula a lógica de negócio para iniciar o rastreamento
/// de localização com validações e tratamento de erros.
class StartLocationTrackingUseCase {

  const StartLocationTrackingUseCase(this._repository);
  final LocationRepository _repository;

  /// Executa o caso de uso
  /// 
  /// [config] - Configuração do rastreamento
  /// 
  /// Retorna um Stream de [EnhancedLocationData] com atualizações
  /// de localização ou lança exceção em caso de erro.
  Future<Stream<EnhancedLocationData>> execute(TrackingConfig config) async {
    // Validar permissões
    final hasPermission = await _repository.hasLocationPermission();
    if (!hasPermission) {
      final granted = await _repository.requestLocationPermission();
      if (!granted) {
        throw const LocationPermissionDeniedException(
          'Permissão de localização é necessária para o rastreamento'
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

    // Validar se já não está rastreando
    if (_repository.isTrackingActive) {
      throw const TrackingAlreadyActiveException(
        'Rastreamento já está ativo'
      );
    }

    // Iniciar rastreamento
    try {
      return _repository.startLocationTracking(config);
    } catch (e) {
      throw LocationTrackingException(
        'Erro ao iniciar rastreamento: ${e.toString()}'
      );
    }
  }
}

/// Exceções específicas do rastreamento de localização
class LocationTrackingException implements Exception {
  const LocationTrackingException(this.message);
  final String message;
  
  @override
  String toString() => 'LocationTrackingException: $message';
}

class LocationPermissionDeniedException extends LocationTrackingException {
  const LocationPermissionDeniedException(super.message);
}

class LocationServiceDisabledException extends LocationTrackingException {
  const LocationServiceDisabledException(super.message);
}

class TrackingAlreadyActiveException extends LocationTrackingException {
  const TrackingAlreadyActiveException(super.message);
}