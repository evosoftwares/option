import '../repositories/location_repository.dart';
import 'start_location_tracking.dart';

/// Caso de uso para parar rastreamento de localização
/// 
/// Encapsula a lógica de negócio para parar o rastreamento
/// de localização com validações e limpeza de recursos.
class StopLocationTrackingUseCase {

  const StopLocationTrackingUseCase(this._repository);
  final LocationRepository _repository;

  /// Executa o caso de uso
  /// 
  /// Para o rastreamento ativo e limpa recursos.
  /// Lança exceção se não houver rastreamento ativo.
  Future<void> execute() async {
    // Validar se há rastreamento ativo
    if (!_repository.isTrackingActive) {
      throw const TrackingNotActiveException(
        'Não há rastreamento ativo para parar'
      );
    }

    try {
      // Parar rastreamento
      await _repository.stopLocationTracking();
    } catch (e) {
      throw LocationTrackingException(
        'Erro ao parar rastreamento: ${e.toString()}'
      );
    }
  }
}

/// Exceção para quando não há rastreamento ativo
class TrackingNotActiveException extends LocationTrackingException {
  const TrackingNotActiveException(super.message);
}