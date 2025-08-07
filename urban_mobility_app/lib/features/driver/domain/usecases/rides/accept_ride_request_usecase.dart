import '../../models/active_ride.dart';
import '../../models/driver_status.dart' hide DriverLocation;
import '../../models/ride_request.dart' hide VehicleCategory;
import '../../repositories/driver_repository.dart';

/// Caso de uso para aceitar uma solicitação de viagem
class AcceptRideRequestUseCase {
  const AcceptRideRequestUseCase(this._repository);

  final DriverRepository _repository;

  /// Executa o caso de uso
  Future<ActiveRide> call(String driverId, String requestId) async {
    if (driverId.isEmpty) {
      throw ArgumentError('Driver ID não pode estar vazio');
    }

    if (requestId.isEmpty) {
      throw ArgumentError('Request ID não pode estar vazio');
    }

    // Verificar status do motorista
    final driverStatus = await _repository.getDriverStatus(driverId);
    if (driverStatus != DriverStatus.online) {
      throw StateError('Motorista deve estar online para aceitar viagens');
    }

    // Verificar se já tem viagem ativa
    final currentRide = await _repository.getCurrentActiveRide(driverId);
    if (currentRide != null) {
      throw StateError('Motorista já possui uma viagem ativa');
    }

    // Verificar se a solicitação ainda está válida
    final request = await _repository.getRideRequestDetails(requestId);
    if (request == null) {
      throw StateError('Solicitação de viagem não encontrada');
    }

    if (!request.canBeAccepted) {
      throw StateError('Solicitação não pode mais ser aceita');
    }

    // Aceitar a viagem
    final activeRide = await _repository.acceptRideRequest(driverId, requestId);

    return activeRide;
  }
}
