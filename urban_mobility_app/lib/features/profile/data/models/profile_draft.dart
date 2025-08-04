import 'dart:convert';
import 'user_profile.dart';

/// Rascunho de edição de perfil para autosave local
class ProfileDraft {

  const ProfileDraft({
    required this.userId,
    required this.lastModified,
    required this.changes,
    required this.section,
    this.hasUnsavedChanges = true,
  });

  factory ProfileDraft.fromJson(Map<String, dynamic> json) {
    return ProfileDraft(
      userId: json['userId'] as String,
      lastModified: DateTime.parse(json['lastModified'] as String),
      changes: Map<String, dynamic>.from(json['changes']),
      section: ProfileSection.values.firstWhere(
        (e) => e.name == json['section'],
        orElse: () => ProfileSection.basic,
      ),
      hasUnsavedChanges: json['hasUnsavedChanges'] as bool? ?? true,
    );
  }

  factory ProfileDraft.fromJsonString(String jsonString) {
    return ProfileDraft.fromJson(jsonDecode(jsonString));
  }
  final String userId;
  final DateTime lastModified;
  final Map<String, dynamic> changes;
  final ProfileSection section;
  final bool hasUnsavedChanges;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lastModified': lastModified.toIso8601String(),
      'changes': changes,
      'section': section.name,
      'hasUnsavedChanges': hasUnsavedChanges,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  ProfileDraft copyWith({
    String? userId,
    DateTime? lastModified,
    Map<String, dynamic>? changes,
    ProfileSection? section,
    bool? hasUnsavedChanges,
  }) {
    return ProfileDraft(
      userId: userId ?? this.userId,
      lastModified: lastModified ?? this.lastModified,
      changes: changes ?? this.changes,
      section: section ?? this.section,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  /// Aplica as mudanças do draft ao perfil base
  UserProfile applyTo(UserProfile profile) {
    final updatedProfile = profile.copyWith(
      firstName: changes['firstName'] as String?,
      lastName: changes['lastName'] as String?,
      phone: changes['phone'] as String?,
      bio: changes['bio'] as String?,
      dateOfBirth: changes['dateOfBirth'] != null
          ? DateTime.parse(changes['dateOfBirth'] as String)
          : null,
      avatarUrl: changes['avatarUrl'] as String?,
    );

    // Aplicar mudanças nas preferências
    if (changes.containsKey('preferences')) {
      final preferencesChanges = changes['preferences'] as Map<String, dynamic>;
      final updatedPreferences = profile.preferences.copyWith(
        notificationsEnabled: preferencesChanges['notificationsEnabled'] as bool?,
        darkModeEnabled: preferencesChanges['darkModeEnabled'] as bool?,
        locationEnabled: preferencesChanges['locationEnabled'] as bool?,
        language: preferencesChanges['language'] as String?,
        currency: preferencesChanges['currency'] as String?,
        soundEnabled: preferencesChanges['soundEnabled'] as bool?,
        vibrationEnabled: preferencesChanges['vibrationEnabled'] as bool?,
      );
      return updatedProfile.copyWith(preferences: updatedPreferences);
    }

    // Aplicar mudanças no perfil do motorista
    if (changes.containsKey('driverProfile') && profile.driverProfile != null) {
      final driverChanges = changes['driverProfile'] as Map<String, dynamic>;
      final updatedDriverProfile = profile.driverProfile!.copyWith(
        ratePerKm: (driverChanges['ratePerKm'] as num?)?.toDouble(),
        isAvailable: driverChanges['isAvailable'] as bool?,
        licenseNumber: driverChanges['licenseNumber'] as String?,
        bankAccount: driverChanges['bankAccount'] as String?,
        pix: driverChanges['pix'] as String?,
      );
      return updatedProfile.copyWith(driverProfile: updatedDriverProfile);
    }

    // Aplicar mudanças no perfil do passageiro
    if (changes.containsKey('passengerProfile') && profile.passengerProfile != null) {
      final passengerChanges = changes['passengerProfile'] as Map<String, dynamic>;
      final updatedPassengerProfile = profile.passengerProfile!.copyWith(
        emergencyContactName: passengerChanges['emergencyContactName'] as String?,
        emergencyContactPhone: passengerChanges['emergencyContactPhone'] as String?,
        paymentMethod: passengerChanges['paymentMethod'] as String?,
      );
      return updatedProfile.copyWith(passengerProfile: updatedPassengerProfile);
    }

    return updatedProfile;
  }
}

/// Seções do perfil para organizar o autosave
enum ProfileSection {
  basic,        // Nome, telefone, bio, avatar
  preferences,  // Configurações de notificação, tema, etc
  passenger,    // Dados específicos do passageiro
  driver,       // Dados específicos do motorista
  vehicle,      // Informações do veículo
  documents,    // Documentos e verificações
  payment,      // Dados de pagamento
}

/// Validador de mudanças no perfil
class ProfileValidator {
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxBioLength = 200;

  static Map<String, String> validateBasicInfo(Map<String, dynamic> changes) {
    final errors = <String, String>{};

    // Validar nome
    final firstName = changes['firstName'] as String?;
    if (firstName != null) {
      if (firstName.trim().isEmpty) {
        errors['firstName'] = 'Nome é obrigatório';
      } else if (firstName.trim().length < minNameLength) {
        errors['firstName'] = 'Nome deve ter pelo menos $minNameLength caracteres';
      } else if (firstName.length > maxNameLength) {
        errors['firstName'] = 'Nome deve ter no máximo $maxNameLength caracteres';
      }
    }

    final lastName = changes['lastName'] as String?;
    if (lastName != null) {
      if (lastName.trim().isEmpty) {
        errors['lastName'] = 'Sobrenome é obrigatório';
      } else if (lastName.trim().length < minNameLength) {
        errors['lastName'] = 'Sobrenome deve ter pelo menos $minNameLength caracteres';
      } else if (lastName.length > maxNameLength) {
        errors['lastName'] = 'Sobrenome deve ter no máximo $maxNameLength caracteres';
      }
    }

    // Validar telefone
    final phone = changes['phone'] as String?;
    if (phone != null && phone.isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,15}$');
      if (!phoneRegex.hasMatch(phone)) {
        errors['phone'] = 'Formato de telefone inválido';
      }
    }

    // Validar bio
    final bio = changes['bio'] as String?;
    if (bio != null && bio.length > maxBioLength) {
      errors['bio'] = 'Bio deve ter no máximo $maxBioLength caracteres';
    }

    // Validar data de nascimento
    final dateOfBirth = changes['dateOfBirth'] as String?;
    if (dateOfBirth != null) {
      try {
        final date = DateTime.parse(dateOfBirth);
        final now = DateTime.now();
        final age = now.year - date.year;
        if (age < 16 || age > 100) {
          errors['dateOfBirth'] = 'Idade deve estar entre 16 e 100 anos';
        }
      } catch (e) {
        errors['dateOfBirth'] = 'Data de nascimento inválida';
      }
    }

    return errors;
  }

  static Map<String, String> validateDriverInfo(Map<String, dynamic> changes) {
    final errors = <String, String>{};

    // Validar taxa por km
    final ratePerKm = changes['ratePerKm'] as num?;
    if (ratePerKm != null) {
      if (ratePerKm < 1.0 || ratePerKm > 10.0) {
        errors['ratePerKm'] = 'Taxa deve estar entre R\$ 1,00 e R\$ 10,00';
      }
    }

    // Validar número da CNH
    final licenseNumber = changes['licenseNumber'] as String?;
    if (licenseNumber != null && licenseNumber.isNotEmpty) {
      if (licenseNumber.length != 11) {
        errors['licenseNumber'] = 'Número da CNH deve ter 11 dígitos';
      }
    }

    return errors;
  }

  static Map<String, String> validateVehicleInfo(Map<String, dynamic> changes) {
    final errors = <String, String>{};

    // Validar placa do veículo
    final licensePlate = changes['licensePlate'] as String?;
    if (licensePlate != null && licensePlate.isNotEmpty) {
      // Formato brasileiro: ABC-1234 ou ABC1D23
      final plateRegex = RegExp(r'^[A-Z]{3}[-]?\d{1}[A-Z]?\d{2}$');
      if (!plateRegex.hasMatch(licensePlate.toUpperCase())) {
        errors['licensePlate'] = 'Formato de placa inválido';
      }
    }

    // Validar ano do veículo
    final year = changes['year'] as int?;
    if (year != null) {
      final currentYear = DateTime.now().year;
      if (year < 1990 || year > currentYear + 1) {
        errors['year'] = 'Ano deve estar entre 1990 e ${currentYear + 1}';
      }
    }

    return errors;
  }
}