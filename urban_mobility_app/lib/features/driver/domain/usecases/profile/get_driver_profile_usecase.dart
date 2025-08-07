import '../../models/driver_profile.dart';
import '../../repositories/driver_repository.dart';

/// Caso de uso para obter o perfil do motorista
class GetDriverProfileUseCase {
  const GetDriverProfileUseCase(this._repository);

  final DriverRepository _repository;

  /// Executa o caso de uso
  Future<DriverProfile?> call(String driverId) async {
    if (driverId.isEmpty) {
      throw ArgumentError('Driver ID não pode estar vazio');
    }

    return await _repository.getDriverProfile(driverId);
  }
}
