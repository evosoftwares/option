import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/profile_draft.dart';

/// Serviço de analytics para rastrear eventos de perfil e KPIs
class ProfileAnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static const String _eventPrefix = 'profile_';

  // KPIs principais
  DateTime? _editStartTime;
  int _fieldsChanged = 0;
  int _validationErrors = 0;

  /// Track início da edição de perfil
  Future<void> trackProfileEditStarted(String userId, UserType userType) async {
    _editStartTime = DateTime.now();
    _fieldsChanged = 0;
    _validationErrors = 0;
    
    await _analytics.logEvent(
      name: '${_eventPrefix}edit_started',
      parameters: {
        'user_id': userId,
        'user_type': userType.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track campo alterado
  Future<void> trackFieldChanged(String userId, ProfileSection section, String field, dynamic value) async {
    _fieldsChanged++;
    
    await _analytics.logEvent(
      name: '${_eventPrefix}field_changed',
      parameters: {
        'user_id': userId,
        'section': section.name,
        'field': field,
        'has_value': value != null && value.toString().isNotEmpty,
        'fields_changed_count': _fieldsChanged,
      },
    );
  }

  /// Track erro de validação
  Future<void> trackValidationError(String userId, String field, String error) async {
    _validationErrors++;
    
    await _analytics.logEvent(
      name: '${_eventPrefix}validation_error',
      parameters: {
        'user_id': userId,
        'field': field,
        'error_type': _categorizeError(error),
        'validation_errors_count': _validationErrors,
      },
    );
  }

  /// Track perfil salvo com sucesso
  Future<void> trackProfileSaved(String userId, Duration saveTime) async {
    final editDuration = _editStartTime != null 
        ? DateTime.now().difference(_editStartTime!)
        : Duration.zero;
    
    await _analytics.logEvent(
      name: '${_eventPrefix}saved',
      parameters: {
        'user_id': userId,
        'edit_duration_seconds': editDuration.inSeconds,
        'save_time_ms': saveTime.inMilliseconds,
        'fields_changed': _fieldsChanged,
        'validation_errors': _validationErrors,
        'success': true,
      },
    );
    
    // Track KPI específico: tempo para salvar perfil
    await _analytics.logEvent(
      name: 'kpi_profile_save_time',
      parameters: {
        'duration_seconds': editDuration.inSeconds,
        'complexity_score': _calculateComplexityScore(),
      },
    );
  }

  /// Track erro ao salvar perfil
  Future<void> trackProfileSaveError(String userId, String error) async {
    final editDuration = _editStartTime != null 
        ? DateTime.now().difference(_editStartTime!)
        : Duration.zero;
    
    await _analytics.logEvent(
      name: '${_eventPrefix}save_error',
      parameters: {
        'user_id': userId,
        'edit_duration_seconds': editDuration.inSeconds,
        'fields_changed': _fieldsChanged,
        'validation_errors': _validationErrors,
        'error_type': _categorizeError(error),
        'success': false,
      },
    );
  }

  /// Track edição cancelada
  Future<void> trackProfileEditCancelled(String userId) async {
    final editDuration = _editStartTime != null 
        ? DateTime.now().difference(_editStartTime!)
        : Duration.zero;
    
    await _analytics.logEvent(
      name: '${_eventPrefix}edit_cancelled',
      parameters: {
        'user_id': userId,
        'edit_duration_seconds': editDuration.inSeconds,
        'fields_changed': _fieldsChanged,
        'had_unsaved_changes': _fieldsChanged > 0,
      },
    );
  }

  /// Track upload de avatar
  Future<void> trackAvatarUploaded(String userId, int fileSizeBytes, Duration uploadTime) async {
    await _analytics.logEvent(
      name: '${_eventPrefix}avatar_uploaded',
      parameters: {
        'user_id': userId,
        'file_size_kb': (fileSizeBytes / 1024).round(),
        'upload_time_ms': uploadTime.inMilliseconds,
        'success': true,
      },
    );
  }

  /// Track erro no upload de avatar
  Future<void> trackAvatarUploadError(String userId, String error) async {
    await _analytics.logEvent(
      name: '${_eventPrefix}avatar_upload_error',
      parameters: {
        'user_id': userId,
        'error_type': _categorizeError(error),
        'success': false,
      },
    );
  }

  /// Track remoção de avatar
  Future<void> trackAvatarRemoved(String userId) async {
    await _analytics.logEvent(
      name: '${_eventPrefix}avatar_removed',
      parameters: {
        'user_id': userId,
      },
    );
  }

  /// Track mudanças nas preferências
  Future<void> trackPreferencesChanged(String userId, UserPreferences preferences) async {
    await _analytics.logEvent(
      name: '${_eventPrefix}preferences_changed',
      parameters: {
        'user_id': userId,
        'notifications_enabled': preferences.notificationsEnabled,
        'dark_mode_enabled': preferences.darkModeEnabled,
        'location_enabled': preferences.locationEnabled,
        'language': preferences.language,
        'currency': preferences.currency,
      },
    );
  }

  /// Track erro genérico na edição de perfil
  Future<void> trackProfileEditError(String userId, String errorType, String errorMessage) async {
    await _analytics.logEvent(
      name: '${_eventPrefix}edit_error',
      parameters: {
        'user_id': userId,
        'error_type': errorType,
        'error_category': _categorizeError(errorMessage),
      },
    );
  }

  /// Track performance de autosave
  Future<void> trackAutosavePerformance(String userId, Duration saveTime, bool success) async {
    await _analytics.logEvent(
      name: '${_eventPrefix}autosave',
      parameters: {
        'user_id': userId,
        'save_time_ms': saveTime.inMilliseconds,
        'success': success,
      },
    );
  }

  /// Track sessão de edição completa (para análise de funil)
  Future<void> trackEditingSessionComplete(String userId, {
    required Duration totalTime,
    required int fieldsChanged,
    required int validationErrors,
    required bool completed,
    String? exitReason,
  }) async {
    await _analytics.logEvent(
      name: '${_eventPrefix}session_complete',
      parameters: {
        'user_id': userId,
        'total_time_seconds': totalTime.inSeconds,
        'fields_changed': fieldsChanged,
        'validation_errors': validationErrors,
        'completed': completed,
        'exit_reason': exitReason ?? 'unknown',
        'completion_rate': completed ? 1.0 : 0.0,
      },
    );
  }

  /// Categoriza erros para análise
  String _categorizeError(String error) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('network') || errorLower.contains('connection')) {
      return 'network';
    } else if (errorLower.contains('validation') || errorLower.contains('invalid')) {
      return 'validation';
    } else if (errorLower.contains('permission') || errorLower.contains('unauthorized')) {
      return 'permission';
    } else if (errorLower.contains('storage') || errorLower.contains('upload')) {
      return 'storage';
    } else if (errorLower.contains('timeout')) {
      return 'timeout';
    } else {
      return 'unknown';
    }
  }

  /// Calcula score de complexidade da edição
  int _calculateComplexityScore() {
    int score = 0;
    
    // Base score por número de campos alterados
    score += _fieldsChanged * 2;
    
    // Penalidade por erros de validação
    score += _validationErrors * 5;
    
    // Tempo de edição (mais tempo = maior complexidade)
    if (_editStartTime != null) {
      final editMinutes = DateTime.now().difference(_editStartTime!).inMinutes;
      score += editMinutes;
    }
    
    return score;
  }

  // Métodos para dashboards e KPIs
  
  /// Track métricas de engajamento
  Future<void> trackEngagementMetrics(String userId, {
    required Duration timeOnPage,
    required int scrollDepth,
    required int tapsCount,
  }) async {
    await _analytics.logEvent(
      name: '${_eventPrefix}engagement',
      parameters: {
        'user_id': userId,
        'time_on_page_seconds': timeOnPage.inSeconds,
        'scroll_depth_percent': scrollDepth,
        'taps_count': tapsCount,
      },
    );
  }

  /// Track métricas de UX
  Future<void> trackUXMetrics(String userId, {
    required String action,
    required Duration responseTime,
    required bool success,
  }) async {
    await _analytics.logEvent(
      name: '${_eventPrefix}ux_metric',
      parameters: {
        'user_id': userId,
        'action': action,
        'response_time_ms': responseTime.inMilliseconds,
        'success': success,
      },
    );
  }

  /// Set user properties para segmentação
  Future<void> setUserProperties(UserProfile profile) async {
    await _analytics.setUserProperty(
      name: 'user_type',
      value: profile.userType.name,
    );
    
    await _analytics.setUserProperty(
      name: 'verification_status',
      value: profile.verificationStatus.name,
    );
    
    await _analytics.setUserProperty(
      name: 'profile_completeness',
      value: _calculateProfileCompleteness(profile).toString(),
    );
  }

  /// Calcula completude do perfil (para KPIs)
  int _calculateProfileCompleteness(UserProfile profile) {
    int score = 0;
    final int maxScore = 10;
    
    // Campos básicos (peso 3)
    if (profile.firstName.isNotEmpty) score++;
    if (profile.lastName.isNotEmpty) score++;
    if (profile.phone != null && profile.phone!.isNotEmpty) score++;
    
    // Avatar (peso 2)
    if (profile.avatarUrl != null) score += 2;
    
    // Bio (peso 1)
    if (profile.bio != null && profile.bio!.isNotEmpty) score++;
    
    // Data de nascimento (peso 1)
    if (profile.dateOfBirth != null) score++;
    
    // Configurações específicas por tipo de usuário (peso 2)
    if (profile.canRequestRides && profile.passengerProfile != null) {
      if (profile.passengerProfile!.emergencyContactName != null) score++;
    }
    
    if (profile.canDrive && profile.driverProfile != null) {
      if (profile.driverProfile!.licenseNumber != null) score++;
    }
    
    return ((score / maxScore) * 100).round();
  }
}

/// Extensões para facilitar o uso
extension ProfileAnalyticsExtensions on ProfileAnalyticsService {
  /// Helper para track de tempo de resposta de APIs
  Future<T> trackApiCall<T>(
    String userId,
    String apiName,
    Future<T> Function() apiCall,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await apiCall();
      stopwatch.stop();
      
      await trackUXMetrics(
        userId,
        action: 'api_$apiName',
        responseTime: stopwatch.elapsed,
        success: true,
      );
      
      return result;
    } catch (e) {
      stopwatch.stop();
      
      await trackUXMetrics(
        userId,
        action: 'api_$apiName',
        responseTime: stopwatch.elapsed,
        success: false,
      );
      
      rethrow;
    }
  }
}