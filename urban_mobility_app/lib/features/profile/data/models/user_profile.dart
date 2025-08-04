import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de usuário no sistema
enum UserType {
  passenger,
  driver,
  both,
}

/// Status de verificação do perfil
enum VerificationStatus {
  pending,
  verified,
  rejected,
  notRequired,
}

/// Modelo unificado de perfil de usuário
class UserProfile {

  const UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatarUrl,
    required this.userType,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
    this.bio,
    this.dateOfBirth,
    this.cpf,
    this.rg,
    required this.preferences,
    this.passengerProfile,
    this.driverProfile,
    required this.stats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      userType: UserType.values.firstWhere(
        (e) => e.name == json['userType'],
        orElse: () => UserType.passenger,
      ),
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == json['verificationStatus'],
        orElse: () => VerificationStatus.notRequired,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      bio: json['bio'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      cpf: json['cpf'] as String?,
      rg: json['rg'] as String?,
      preferences: UserPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>? ?? {},
      ),
      passengerProfile: json['passengerProfile'] != null
          ? PassengerProfile.fromJson(json['passengerProfile'] as Map<String, dynamic>)
          : null,
      driverProfile: json['driverProfile'] != null
          ? DriverProfile.fromJson(json['driverProfile'] as Map<String, dynamic>)
          : null,
      stats: UserStats.fromJson(
        json['stats'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return UserProfile.fromJson({...data, 'id': snapshot.id});
  }
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatarUrl;
  final UserType userType;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;
  
  // Informações básicas
  final String? bio;
  final DateTime? dateOfBirth;
  final String? cpf;
  final String? rg;
  
  // Preferências
  final UserPreferences preferences;
  
  // Dados específicos do passageiro
  final PassengerProfile? passengerProfile;
  
  // Dados específicos do motorista  
  final DriverProfile? driverProfile;
  
  // Estatísticas
  final UserStats stats;

  String get fullName => '$firstName $lastName';
  
  String get displayName => fullName.trim().isNotEmpty ? fullName : email;
  
  bool get isVerified => verificationStatus == VerificationStatus.verified;
  
  bool get canDrive => userType == UserType.driver || userType == UserType.both;
  
  bool get canRequestRides => userType == UserType.passenger || userType == UserType.both;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'userType': userType.name,
      'verificationStatus': verificationStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'cpf': cpf,
      'rg': rg,
      'preferences': preferences.toJson(),
      'passengerProfile': passengerProfile?.toJson(),
      'driverProfile': driverProfile?.toJson(),
      'stats': stats.toJson(),
    };
  }

  Map<String, dynamic> toFirestore() {
    final data = toJson();
    data.remove('id'); // ID é gerenciado pelo Firestore
    return data;
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    UserType? userType,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
    String? bio,
    DateTime? dateOfBirth,
    String? cpf,
    String? rg,
    UserPreferences? preferences,
    PassengerProfile? passengerProfile,
    DriverProfile? driverProfile,
    UserStats? stats,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      userType: userType ?? this.userType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      cpf: cpf ?? this.cpf,
      rg: rg ?? this.rg,
      preferences: preferences ?? this.preferences,
      passengerProfile: passengerProfile ?? this.passengerProfile,
      driverProfile: driverProfile ?? this.driverProfile,
      stats: stats ?? this.stats,
    );
  }
}

/// Preferências do usuário
class UserPreferences {

  const UserPreferences({
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.locationEnabled = true,
    this.language = 'pt_BR',
    this.currency = 'BRL',
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      locationEnabled: json['locationEnabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'pt_BR',
      currency: json['currency'] as String? ?? 'BRL',
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool locationEnabled;
  final String language;
  final String currency;
  final bool soundEnabled;
  final bool vibrationEnabled;

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'locationEnabled': locationEnabled,
      'language': language,
      'currency': currency,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? locationEnabled,
    String? language,
    String? currency,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

/// Perfil específico do passageiro
class PassengerProfile {

  const PassengerProfile({
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.favoriteAddresses = const [],
    this.paymentMethod,
  });

  factory PassengerProfile.fromJson(Map<String, dynamic> json) {
    return PassengerProfile(
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      favoriteAddresses: List<String>.from(json['favoriteAddresses'] ?? []),
      paymentMethod: json['paymentMethod'] as String?,
    );
  }
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final List<String> favoriteAddresses;
  final String? paymentMethod;

  Map<String, dynamic> toJson() {
    return {
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'favoriteAddresses': favoriteAddresses,
      'paymentMethod': paymentMethod,
    };
  }

  PassengerProfile copyWith({
    String? emergencyContactName,
    String? emergencyContactPhone,
    List<String>? favoriteAddresses,
    String? paymentMethod,
  }) {
    return PassengerProfile(
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      favoriteAddresses: favoriteAddresses ?? this.favoriteAddresses,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

/// Perfil específico do motorista
class DriverProfile {

  const DriverProfile({
    this.licenseNumber,
    this.licenseExpiryDate,
    this.licensePhotoUrl,
    this.vehicle,
    this.ratePerKm = 2.5,
    this.isAvailable = false,
    this.documents = const [],
    this.bankAccount,
    this.pix,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      licenseNumber: json['licenseNumber'] as String?,
      licenseExpiryDate: json['licenseExpiryDate'] != null
          ? DateTime.parse(json['licenseExpiryDate'] as String)
          : null,
      licensePhotoUrl: json['licensePhotoUrl'] as String?,
      vehicle: json['vehicle'] != null
          ? VehicleInfo.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      ratePerKm: (json['ratePerKm'] as num?)?.toDouble() ?? 2.5,
      isAvailable: json['isAvailable'] as bool? ?? false,
      documents: List<String>.from(json['documents'] ?? []),
      bankAccount: json['bankAccount'] as String?,
      pix: json['pix'] as String?,
    );
  }
  final String? licenseNumber;
  final DateTime? licenseExpiryDate;
  final String? licensePhotoUrl;
  final VehicleInfo? vehicle;
  final double ratePerKm;
  final bool isAvailable;
  final List<String> documents;
  final String? bankAccount;
  final String? pix;

  Map<String, dynamic> toJson() {
    return {
      'licenseNumber': licenseNumber,
      'licenseExpiryDate': licenseExpiryDate?.toIso8601String(),
      'licensePhotoUrl': licensePhotoUrl,
      'vehicle': vehicle?.toJson(),
      'ratePerKm': ratePerKm,
      'isAvailable': isAvailable,
      'documents': documents,
      'bankAccount': bankAccount,
      'pix': pix,
    };
  }

  DriverProfile copyWith({
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    String? licensePhotoUrl,
    VehicleInfo? vehicle,
    double? ratePerKm,
    bool? isAvailable,
    List<String>? documents,
    String? bankAccount,
    String? pix,
  }) {
    return DriverProfile(
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      licensePhotoUrl: licensePhotoUrl ?? this.licensePhotoUrl,
      vehicle: vehicle ?? this.vehicle,
      ratePerKm: ratePerKm ?? this.ratePerKm,
      isAvailable: isAvailable ?? this.isAvailable,
      documents: documents ?? this.documents,
      bankAccount: bankAccount ?? this.bankAccount,
      pix: pix ?? this.pix,
    );
  }
}

/// Informações do veículo
class VehicleInfo {

  const VehicleInfo({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    this.photoUrl,
    this.documentUrl,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      color: json['color'] as String,
      licensePlate: json['licensePlate'] as String,
      photoUrl: json['photoUrl'] as String?,
      documentUrl: json['documentUrl'] as String?,
    );
  }
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final String? photoUrl;
  final String? documentUrl;

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'licensePlate': licensePlate,
      'photoUrl': photoUrl,
      'documentUrl': documentUrl,
    };
  }

  String get displayName => '$make $model $year';

  VehicleInfo copyWith({
    String? make,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    String? photoUrl,
    String? documentUrl,
  }) {
    return VehicleInfo(
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      photoUrl: photoUrl ?? this.photoUrl,
      documentUrl: documentUrl ?? this.documentUrl,
    );
  }
}

/// Estatísticas do usuário
class UserStats {

  const UserStats({
    this.totalRides = 0,
    this.totalDistance = 0.0,
    this.totalTime = Duration.zero,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.totalEarnings = 0.0,
    this.totalSpent = 0.0,
    this.co2Saved = 0.0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalRides: json['totalRides'] as int? ?? 0,
      totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
      totalTime: Duration(seconds: json['totalTimeSeconds'] as int? ?? 0),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['totalRatings'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      co2Saved: (json['co2Saved'] as num?)?.toDouble() ?? 0.0,
    );
  }
  final int totalRides;
  final double totalDistance;
  final Duration totalTime;
  final double averageRating;
  final int totalRatings;
  final double totalEarnings;
  final double totalSpent;
  final double co2Saved;

  Map<String, dynamic> toJson() {
    return {
      'totalRides': totalRides,
      'totalDistance': totalDistance,
      'totalTimeSeconds': totalTime.inSeconds,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'totalEarnings': totalEarnings,
      'totalSpent': totalSpent,
      'co2Saved': co2Saved,
    };
  }

  UserStats copyWith({
    int? totalRides,
    double? totalDistance,
    Duration? totalTime,
    double? averageRating,
    int? totalRatings,
    double? totalEarnings,
    double? totalSpent,
    double? co2Saved,
  }) {
    return UserStats(
      totalRides: totalRides ?? this.totalRides,
      totalDistance: totalDistance ?? this.totalDistance,
      totalTime: totalTime ?? this.totalTime,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalSpent: totalSpent ?? this.totalSpent,
      co2Saved: co2Saved ?? this.co2Saved,
    );
  }
}