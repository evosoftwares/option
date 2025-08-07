/// Documentos do condutor (Seção 4.1)
/// Implementa o sistema de verificação de documentos
class DriverDocuments {
  const DriverDocuments({
    required this.cnhNumber,
    required this.cnhExpiryDate,
    required this.cnhPhotoUrl,
    required this.crlvNumber,
    required this.crlvPhotoUrl,
    this.profilePhotoUrl,
    this.vehiclePhotoUrl,
    this.rejectionReason,
    this.lastSubmissionDate,
    this.approvalDate,
  });

  /// Número da CNH
  final String cnhNumber;

  /// Data de vencimento da CNH
  final DateTime cnhExpiryDate;

  /// URL da foto da CNH
  final String cnhPhotoUrl;

  /// Número do CRLV
  final String crlvNumber;

  /// URL da foto do CRLV
  final String crlvPhotoUrl;

  /// URL da foto do perfil (opcional)
  final String? profilePhotoUrl;

  /// URL da foto do veículo (opcional)
  final String? vehiclePhotoUrl;

  /// Motivo da rejeição (se aplicável)
  final String? rejectionReason;

  /// Data da última submissão
  final DateTime? lastSubmissionDate;

  /// Data da aprovação
  final DateTime? approvalDate;

  /// Verifica se a CNH está vencida
  bool get isCnhExpired => cnhExpiryDate.isBefore(DateTime.now());

  /// Verifica se todos os documentos obrigatórios foram enviados
  bool get hasAllRequiredDocuments =>
      cnhNumber.isNotEmpty &&
      cnhPhotoUrl.isNotEmpty &&
      crlvNumber.isNotEmpty &&
      crlvPhotoUrl.isNotEmpty;

  /// Cria uma cópia com novos valores
  DriverDocuments copyWith({
    String? cnhNumber,
    DateTime? cnhExpiryDate,
    String? cnhPhotoUrl,
    String? crlvNumber,
    String? crlvPhotoUrl,
    String? profilePhotoUrl,
    String? vehiclePhotoUrl,
    String? rejectionReason,
    DateTime? lastSubmissionDate,
    DateTime? approvalDate,
  }) {
    return DriverDocuments(
      cnhNumber: cnhNumber ?? this.cnhNumber,
      cnhExpiryDate: cnhExpiryDate ?? this.cnhExpiryDate,
      cnhPhotoUrl: cnhPhotoUrl ?? this.cnhPhotoUrl,
      crlvNumber: crlvNumber ?? this.crlvNumber,
      crlvPhotoUrl: crlvPhotoUrl ?? this.crlvPhotoUrl,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      vehiclePhotoUrl: vehiclePhotoUrl ?? this.vehiclePhotoUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      lastSubmissionDate: lastSubmissionDate ?? this.lastSubmissionDate,
      approvalDate: approvalDate ?? this.approvalDate,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'cnhNumber': cnhNumber,
      'cnhExpiryDate': cnhExpiryDate.toIso8601String(),
      'cnhPhotoUrl': cnhPhotoUrl,
      'crlvNumber': crlvNumber,
      'crlvPhotoUrl': crlvPhotoUrl,
      'profilePhotoUrl': profilePhotoUrl,
      'vehiclePhotoUrl': vehiclePhotoUrl,
      'rejectionReason': rejectionReason,
      'lastSubmissionDate': lastSubmissionDate?.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
    };
  }

  /// Cria instância a partir do JSON
  factory DriverDocuments.fromJson(Map<String, dynamic> json) {
    return DriverDocuments(
      cnhNumber: json['cnhNumber'] as String,
      cnhExpiryDate: DateTime.parse(json['cnhExpiryDate'] as String),
      cnhPhotoUrl: json['cnhPhotoUrl'] as String,
      crlvNumber: json['crlvNumber'] as String,
      crlvPhotoUrl: json['crlvPhotoUrl'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      vehiclePhotoUrl: json['vehiclePhotoUrl'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      lastSubmissionDate: json['lastSubmissionDate'] != null
          ? DateTime.parse(json['lastSubmissionDate'] as String)
          : null,
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'] as String)
          : null,
    );
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Cria instância vazia para novos motoristas
  factory DriverDocuments.empty() {
    return DriverDocuments(
      cnhNumber: '',
      cnhExpiryDate: DateTime.now().add(const Duration(days: 365)),
      cnhPhotoUrl: '',
      crlvNumber: '',
      crlvPhotoUrl: '',
    );
  }
}
