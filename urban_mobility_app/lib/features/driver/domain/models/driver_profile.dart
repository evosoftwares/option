import 'package:cloud_firestore/cloud_firestore.dart';
import 'driver_work_config.dart';
import 'driver_verification_status.dart';
import 'driver_documents.dart';
import 'vehicle_info.dart';

/// Perfil completo do condutor conforme regras de negócio (Seções 4.1-4.5)
class DriverProfile {
  const DriverProfile({
    required this.id,
    required this.personalInfo,
    required this.vehicleInfo,
    required this.documents,
    required this.verificationStatus,
    required this.workConfig,
    required this.isOnline,
    this.currentLocation,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.totalEarnings = 0.0,
    this.joinDate,
    this.lastStatusChange,
  });

  /// ID único do motorista
  final String id;

  /// Informações pessoais
  final PersonalInfo personalInfo;

  /// Informações do veículo
  final VehicleInfo vehicleInfo;

  /// Documentos para verificação
  final DriverDocuments documents;

  /// Status de verificação
  final DriverVerificationStatus verificationStatus;

  /// Configurações de trabalho
  final DriverWorkConfig workConfig;

  /// Status online/offline
  final bool isOnline;

  /// Localização atual (quando online)
  final DriverLocation? currentLocation;

  /// Avaliação média
  final double rating;

  /// Total de viagens realizadas
  final int totalTrips;

  /// Total de ganhos
  final double totalEarnings;

  /// Data de cadastro
  final DateTime? joinDate;

  /// Última mudança de status
  final DateTime? lastStatusChange;

  /// Verifica se pode ficar online (seção 4.3)
  bool get canGoOnline =>
      verificationStatus.canGoOnline &&
      !documents.isCnhExpired &&
      vehicleInfo.isComplete;

  /// Verifica se o perfil está completo
  bool get isProfileComplete =>
      personalInfo.isComplete &&
      vehicleInfo.isComplete &&
      documents.hasAllRequiredDocuments;

  /// Cria uma cópia com novos valores
  DriverProfile copyWith({
    String? id,
    PersonalInfo? personalInfo,
    VehicleInfo? vehicleInfo,
    DriverDocuments? documents,
    DriverVerificationStatus? verificationStatus,
    DriverWorkConfig? workConfig,
    bool? isOnline,
    DriverLocation? currentLocation,
    double? rating,
    int? totalTrips,
    double? totalEarnings,
    DateTime? joinDate,
    DateTime? lastStatusChange,
  }) {
    return DriverProfile(
      id: id ?? this.id,
      personalInfo: personalInfo ?? this.personalInfo,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      documents: documents ?? this.documents,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      workConfig: workConfig ?? this.workConfig,
      isOnline: isOnline ?? this.isOnline,
      currentLocation: currentLocation ?? this.currentLocation,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      joinDate: joinDate ?? this.joinDate,
      lastStatusChange: lastStatusChange ?? this.lastStatusChange,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personalInfo': personalInfo.toJson(),
      'vehicleInfo': vehicleInfo.toJson(),
      'documents': documents.toJson(),
      'verificationStatus': verificationStatus.name,
      'workConfig': workConfig.toJson(),
      'isOnline': isOnline,
      'currentLocation': currentLocation?.toJson(),
      'rating': rating,
      'totalTrips': totalTrips,
      'totalEarnings': totalEarnings,
      'joinDate': joinDate?.toIso8601String(),
      'lastStatusChange': lastStatusChange?.toIso8601String(),
    };
  }

  /// Cria instância a partir do JSON
  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] as String,
      personalInfo: PersonalInfo.fromJson(
        json['personalInfo'] as Map<String, dynamic>,
      ),
      vehicleInfo: VehicleInfo.fromJson(
        json['vehicleInfo'] as Map<String, dynamic>,
      ),
      documents: DriverDocuments.fromJson(
        json['documents'] as Map<String, dynamic>,
      ),
      verificationStatus: DriverVerificationStatus.values.firstWhere(
        (e) => e.name == json['verificationStatus'],
        orElse: () => DriverVerificationStatus.incomplete,
      ),
      workConfig: DriverWorkConfig.fromJson(
        json['workConfig'] as Map<String, dynamic>,
      ),
      isOnline: json['isOnline'] as bool? ?? false,
      currentLocation: json['currentLocation'] != null
          ? DriverLocation.fromJson(
              json['currentLocation'] as Map<String, dynamic>,
            )
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: json['totalTrips'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'] as String)
          : null,
      lastStatusChange: json['lastStatusChange'] != null
          ? DateTime.parse(json['lastStatusChange'] as String)
          : null,
    );
  }

  /// Cria instância a partir do Firestore
  factory DriverProfile.fromFirestore(Map<String, dynamic> data, String id) {
    return DriverProfile(
      id: id,
      personalInfo: PersonalInfo.fromJson(
        data['personalInfo'] as Map<String, dynamic>,
      ),
      vehicleInfo: VehicleInfo.fromJson(
        data['vehicleInfo'] as Map<String, dynamic>,
      ),
      documents: DriverDocuments.fromJson(
        data['documents'] as Map<String, dynamic>,
      ),
      verificationStatus: DriverVerificationStatus.values.firstWhere(
        (e) => e.name == data['verificationStatus'],
        orElse: () => DriverVerificationStatus.incomplete,
      ),
      workConfig: DriverWorkConfig.fromJson(
        data['workConfig'] as Map<String, dynamic>,
      ),
      isOnline: data['isOnline'] as bool? ?? false,
      currentLocation: data['currentLocation'] != null
          ? DriverLocation.fromJson(
              data['currentLocation'] as Map<String, dynamic>,
            )
          : null,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: data['totalTrips'] as int? ?? 0,
      totalEarnings: (data['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      joinDate: data['joinDate'] != null
          ? (data['joinDate'] as Timestamp).toDate()
          : null,
      lastStatusChange: data['lastStatusChange'] != null
          ? (data['lastStatusChange'] as Timestamp).toDate()
          : null,
    );
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    final data = toJson();
    data.remove('id'); // ID é gerenciado pelo Firestore
    return data;
  }

  /// Cria perfil vazio para novo motorista
  factory DriverProfile.newDriver({
    required String id,
    required String name,
    required String email,
    required String phone,
  }) {
    return DriverProfile(
      id: id,
      personalInfo: PersonalInfo(name: name, email: email, phone: phone),
      vehicleInfo: VehicleInfo.empty(),
      documents: DriverDocuments.empty(),
      verificationStatus: DriverVerificationStatus.incomplete,
      workConfig: DriverWorkConfig.defaultConfig(),
      isOnline: false,
      joinDate: DateTime.now(),
    );
  }
}

/// Informações pessoais do condutor
class PersonalInfo {
  const PersonalInfo({
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.cpf,
    this.birthDate,
  });

  /// Nome completo
  final String name;

  /// Email
  final String email;

  /// Telefone
  final String phone;

  /// URL da foto do perfil
  final String? photoUrl;

  /// CPF
  final String? cpf;

  /// Data de nascimento
  final DateTime? birthDate;

  /// Verifica se as informações estão completas
  bool get isComplete =>
      name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty;

  /// Cria uma cópia com novos valores
  PersonalInfo copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? cpf,
    DateTime? birthDate,
  }) {
    return PersonalInfo(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      cpf: cpf ?? this.cpf,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'cpf': cpf,
      'birthDate': birthDate?.toIso8601String(),
    };
  }

  /// Cria instância a partir do JSON
  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      photoUrl: json['photoUrl'] as String?,
      cpf: json['cpf'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
    );
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}

/// Localização do motorista
class DriverLocation {
  const DriverLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.timestamp,
  });

  /// Latitude
  final double latitude;

  /// Longitude
  final double longitude;

  /// Endereço (opcional)
  final String? address;

  /// Timestamp da localização
  final DateTime? timestamp;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  /// Cria instância a partir do JSON
  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}
