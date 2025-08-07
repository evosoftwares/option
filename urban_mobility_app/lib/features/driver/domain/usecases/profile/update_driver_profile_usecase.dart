import '../../models/driver_profile.dart';
import '../../repositories/driver_repository.dart';

/// Caso de uso para atualizar o perfil do motorista
class UpdateDriverProfileUseCase {
  const UpdateDriverProfileUseCase(this._repository);

  final DriverRepository _repository;

  /// Executa o caso de uso
  Future<void> call(DriverProfile profile) async {
    if (profile.id.isEmpty) {
      throw ArgumentError('ID do perfil não pode estar vazio');
    }

    // Validações de negócio
    _validateProfile(profile);

    await _repository.updateDriverProfile(profile);
  }

  void _validateProfile(DriverProfile profile) {
    // Validar informações pessoais obrigatórias
    if (profile.personalInfo.name.isEmpty) {
      throw ArgumentError('Nome completo é obrigatório');
    }

    if (profile.personalInfo.email.isEmpty) {
      throw ArgumentError('Email é obrigatório');
    }

    if (profile.personalInfo.phone.isEmpty) {
      throw ArgumentError('Telefone é obrigatório');
    }

    if (profile.personalInfo.cpf?.isEmpty ?? true) {
      throw ArgumentError('CPF é obrigatório');
    }

    // Validar informações do veículo se fornecidas
    if (profile.vehicleInfo.brand.isEmpty ||
        profile.vehicleInfo.model.isEmpty ||
        profile.vehicleInfo.licensePlate.isEmpty) {
      throw ArgumentError('Informações básicas do veículo são obrigatórias');
    }

    // Validar documentos se fornecidos
    if (profile.documents.cnhNumber.isNotEmpty &&
        profile.documents.cnhExpiryDate == null) {
      throw ArgumentError('Data de vencimento da CNH é obrigatória');
    }
  }
}
