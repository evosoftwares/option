import '../../models/driver_profile.dart';
import '../../models/driver_status.dart' hide DriverLocation;
import '../../repositories/driver_repository.dart';

/// Caso de uso para o motorista ficar online
class GoOnlineUseCase {
  const GoOnlineUseCase(this._repository);

  final DriverRepository _repository;

  /// Executa o caso de uso
  Future<void> call(String driverId, DriverLocation location) async {
    if (driverId.isEmpty) {
      throw ArgumentError('Driver ID não pode estar vazio');
    }

    // Verificar se o motorista pode ficar online
    final profile = await _repository.getDriverProfile(driverId);
    if (profile == null) {
      throw StateError('Perfil do motorista não encontrado');
    }

    if (!profile.canGoOnline) {
      throw StateError(
        'Motorista não pode ficar online. Verifique se o perfil está completo e aprovado.',
      );
    }

    // Verificar status atual
    final currentStatus = await _repository.getDriverStatus(driverId);
    if (currentStatus == DriverStatus.onTrip) {
      throw StateError('Não é possível ficar online durante uma viagem');
    }

    if (currentStatus == DriverStatus.suspended) {
      throw StateError('Conta suspensa. Entre em contato com o suporte.');
    }

    // Ficar online
    await _repository.goOnline(driverId, location);
  }
}
