/// Status de verificação do condutor (Seção 4.1)
/// Implementa o fluxo de onboarding e verificação
enum DriverVerificationStatus {
  /// Perfil criado mas documentos não enviados
  incomplete,

  /// Documentos enviados, aguardando aprovação do administrador
  pending,

  /// Documentos aprovados, pode ficar online
  approved,

  /// Documentos rejeitados, precisa reenviar
  rejected,

  /// Conta suspensa pelo administrador
  suspended,
}

/// Extensão para facilitar o uso do enum
extension DriverVerificationStatusExtension on DriverVerificationStatus {
  /// Verifica se o motorista pode ficar online
  bool get canGoOnline => this == DriverVerificationStatus.approved;

  /// Verifica se precisa enviar documentos
  bool get needsDocuments =>
      this == DriverVerificationStatus.incomplete ||
      this == DriverVerificationStatus.rejected;

  /// Verifica se está aguardando aprovação
  bool get isPending => this == DriverVerificationStatus.pending;

  /// Verifica se está suspenso
  bool get isSuspended => this == DriverVerificationStatus.suspended;

  /// Descrição amigável do status
  String get description {
    switch (this) {
      case DriverVerificationStatus.incomplete:
        return 'Complete seu perfil enviando os documentos necessários';
      case DriverVerificationStatus.pending:
        return 'Documentos em análise. Aguarde a aprovação';
      case DriverVerificationStatus.approved:
        return 'Perfil aprovado. Você pode ficar online';
      case DriverVerificationStatus.rejected:
        return 'Documentos rejeitados. Envie novamente';
      case DriverVerificationStatus.suspended:
        return 'Conta suspensa. Entre em contato com o suporte';
    }
  }

  /// Cor associada ao status
  String get colorHex {
    switch (this) {
      case DriverVerificationStatus.incomplete:
        return '#FFA726'; // Orange
      case DriverVerificationStatus.pending:
        return '#42A5F5'; // Blue
      case DriverVerificationStatus.approved:
        return '#66BB6A'; // Green
      case DriverVerificationStatus.rejected:
        return '#EF5350'; // Red
      case DriverVerificationStatus.suspended:
        return '#8D6E63'; // Brown
    }
  }
}
