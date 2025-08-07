import '../../models/active_ride.dart';
import '../../repositories/driver_repository.dart';

/// Caso de uso para finalizar uma viagem
class CompleteRideUseCase {
  const CompleteRideUseCase(this._repository);

  final DriverRepository _repository;

  /// Executa o caso de uso
  Future<void> call({
    required String rideId,
    required double finalPrice,
    double? actualDistance,
    int? actualDuration,
    int? waitingTime,
    String? notes,
  }) async {
    if (rideId.isEmpty) {
      throw ArgumentError('Ride ID não pode estar vazio');
    }

    if (finalPrice < 0) {
      throw ArgumentError('Preço final não pode ser negativo');
    }

    // Verificar se a viagem existe e está ativa
    final ride = await _repository.getCurrentActiveRide(rideId);
    if (ride == null) {
      throw StateError('Viagem não encontrada');
    }

    if (ride.status != ActiveRideStatus.onTrip) {
      throw StateError(
        'Viagem não pode ser finalizada no status atual: ${ride.status.displayName}',
      );
    }

    // Validar dados opcionais
    if (actualDistance != null && actualDistance < 0) {
      throw ArgumentError('Distância real não pode ser negativa');
    }

    if (actualDuration != null && actualDuration < 0) {
      throw ArgumentError('Duração real não pode ser negativa');
    }

    if (waitingTime != null && waitingTime < 0) {
      throw ArgumentError('Tempo de espera não pode ser negativo');
    }

    // Finalizar a viagem
    await _repository.completeRide(
      rideId,
      finalPrice: finalPrice,
      actualDistance: actualDistance,
      actualDuration: actualDuration,
      waitingTime: waitingTime,
      notes: notes,
    );
  }
}
