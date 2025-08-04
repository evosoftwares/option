import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/profile_draft.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/services/profile_analytics_service.dart';

/// Provider para gerenciar a edição de perfil com autosave e validação
class ProfileEditProvider extends ChangeNotifier {

  ProfileEditProvider(this._repository, this._analytics);
  final ProfileRepository _repository;
  final ProfileAnalyticsService _analytics;
  
  UserProfile? _originalProfile;
  UserProfile? _currentProfile;
  ProfileDraft? _currentDraft;
  
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _error;
  DateTime? _lastSavedAt;
  
  Timer? _autosaveTimer;
  Timer? _analyticsTimer;
  
  static const Duration _autosaveDelay = Duration(seconds: 3);
  static const Duration _analyticsDelay = Duration(seconds: 10);

  // Getters
  UserProfile? get originalProfile => _originalProfile;
  UserProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingAvatar => _isUploadingAvatar;
  String? get error => _error;
  DateTime? get lastSavedAt => _lastSavedAt;
  
  bool get hasUnsavedChanges => _currentDraft?.hasUnsavedChanges == true;

  /// Carrega o perfil inicial e recupera rascunhos salvos
  Future<void> loadProfile(UserProfile profile) async {
    _setLoading(true);
    _error = null;
    
    try {
      _originalProfile = profile;
      _currentProfile = profile;
      
      // Recuperar rascunho salvo localmente
      await _loadDraft(profile.id);
      
      // Aplicar rascunho se existir
      if (_currentDraft != null) {
        _currentProfile = _currentDraft!.applyTo(profile);
      }
      
      _analytics.trackProfileEditStarted(profile.id, profile.userType);
      
    } catch (e) {
      _error = e.toString();
      _analytics.trackProfileEditError(profile.id, 'load_error', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza um campo específico do perfil
  void updateField(ProfileSection section, String field, dynamic value) {
    if (_currentProfile == null) return;
    
    _startEditSession();
    
    final changes = _getCurrentChanges();
    changes[field] = value;
    
    _updateDraft(section, changes);
    _scheduleAutosave();
    _trackFieldChange(section, field, value);
  }

  /// Atualiza as preferências do usuário
  void updatePreferences(UserPreferences preferences) {
    if (_currentProfile == null) return;
    
    _startEditSession();
    
    final changes = _getCurrentChanges();
    changes['preferences'] = preferences.toJson();
    
    _currentProfile = _currentProfile!.copyWith(preferences: preferences);
    _updateDraft(ProfileSection.preferences, changes);
    _scheduleAutosave();
    
    _analytics.trackPreferencesChanged(_currentProfile!.id, preferences);
  }

  /// Atualiza campo específico do perfil de passageiro
  void updatePassengerField(String field, dynamic value) {
    if (_currentProfile == null) return;
    
    _startEditSession();
    
    final changes = _getCurrentChanges();
    final passengerChanges = (changes['passengerProfile'] as Map<String, dynamic>?) ?? {};
    passengerChanges[field] = value;
    changes['passengerProfile'] = passengerChanges;
    
    _updatePassengerProfile(field, value);
    _updateDraft(ProfileSection.passenger, changes);
    _scheduleAutosave();
    _trackFieldChange(ProfileSection.passenger, field, value);
  }

  /// Upload de avatar
  Future<void> uploadAvatar(File file) async {
    if (_currentProfile == null) return;
    
    _isUploadingAvatar = true;
    notifyListeners();
    
    try {
      final startTime = DateTime.now();
      final avatarUrl = await _repository.uploadAvatar(_currentProfile!.id, file);
      final uploadTime = DateTime.now().difference(startTime);
      
      _currentProfile = _currentProfile!.copyWith(avatarUrl: avatarUrl);
      
      final changes = _getCurrentChanges();
      changes['avatarUrl'] = avatarUrl;
      _updateDraft(ProfileSection.basic, changes);
      
      _analytics.trackAvatarUploaded(_currentProfile!.id, file.lengthSync(), uploadTime);
      
      await _saveCurrentChanges();
      
    } catch (e) {
      _analytics.trackAvatarUploadError(_currentProfile!.id, e.toString());
      rethrow;
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  /// Remove avatar
  Future<void> removeAvatar() async {
    if (_currentProfile == null) return;
    
    try {
      await _repository.removeAvatar(_currentProfile!.id);
      
      _currentProfile = _currentProfile!.copyWith(avatarUrl: null);
      
      final changes = _getCurrentChanges();
      changes['avatarUrl'] = null;
      _updateDraft(ProfileSection.basic, changes);
      
      _analytics.trackAvatarRemoved(_currentProfile!.id);
      
      await _saveCurrentChanges();
      
    } catch (e) {
      _analytics.trackProfileEditError(_currentProfile!.id, 'avatar_remove_error', e.toString());
      rethrow;
    }
  }

  /// Salva o perfil no backend
  Future<void> saveProfile() async {
    if (_currentProfile == null || _isSaving) return;
    
    _isSaving = true;
    _error = null;
    notifyListeners();
    
    try {
      final startTime = DateTime.now();
      
      // Validar dados antes de salvar
      final validationErrors = _validateProfile(_currentProfile!);
      if (validationErrors.isNotEmpty) {
        throw ValidationException(validationErrors);
      }
      
      final updatedProfile = await _repository.updateProfile(_currentProfile!);
      _originalProfile = updatedProfile;
      _currentProfile = updatedProfile;
      
      // Limpar rascunho após salvar
      await _clearDraft();
      
      _lastSavedAt = DateTime.now();
      final saveTime = _lastSavedAt!.difference(startTime);
      
      _analytics.trackProfileSaved(updatedProfile.id, saveTime);
      
    } catch (e) {
      _error = e.toString();
      _analytics.trackProfileSaveError(_currentProfile!.id, e.toString());
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Descarta as mudanças e restaura o perfil original
  void discardChanges() {
    if (_originalProfile != null) {
      _currentProfile = _originalProfile;
      _clearDraft();
      _analytics.trackProfileEditCancelled(_originalProfile!.id);
      notifyListeners();
    }
  }

  /// Retry em caso de erro
  Future<void> retry() async {
    if (_originalProfile != null) {
      await loadProfile(_originalProfile!);
    }
  }

  /// Inicia uma nova sessão de edição
  void _startEditSession() {
    if (_currentDraft == null && _currentProfile != null) {
      _analytics.trackProfileEditStarted(_currentProfile!.id, _currentProfile!.userType);
    }
  }

  /// Atualiza o rascunho local
  void _updateDraft(ProfileSection section, Map<String, dynamic> changes) {
    if (_currentProfile == null) return;
    
    _currentDraft = ProfileDraft(
      userId: _currentProfile!.id,
      lastModified: DateTime.now(),
      changes: changes,
      section: section,
      hasUnsavedChanges: true,
    );
    
    notifyListeners();
  }

  /// Agenda o autosave
  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDelay, () {
      _saveDraftLocally();
    });
  }

  /// Salva o rascunho localmente
  Future<void> _saveDraftLocally() async {
    if (_currentDraft == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'profile_draft_${_currentDraft!.userId}';
      await prefs.setString(key, _currentDraft!.toJsonString());
      
    } catch (e) {
      debugPrint('Erro ao salvar rascunho localmente: $e');
    }
  }

  /// Carrega o rascunho salvo localmente
  Future<void> _loadDraft(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'profile_draft_$userId';
      final draftJson = prefs.getString(key);
      
      if (draftJson != null) {
        _currentDraft = ProfileDraft.fromJsonString(draftJson);
        
        // Verificar se o rascunho não é muito antigo (24h)
        final age = DateTime.now().difference(_currentDraft!.lastModified);
        if (age.inHours > 24) {
          await _clearDraft();
          _currentDraft = null;
        }
      }
      
    } catch (e) {
      debugPrint('Erro ao carregar rascunho: $e');
      _currentDraft = null;
    }
  }

  /// Limpa o rascunho salvo localmente
  Future<void> _clearDraft() async {
    if (_currentProfile == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'profile_draft_${_currentProfile!.id}';
      await prefs.remove(key);
      _currentDraft = null;
      
    } catch (e) {
      debugPrint('Erro ao limpar rascunho: $e');
    }
  }

  /// Salva as mudanças atuais sem notificar
  Future<void> _saveCurrentChanges() async {
    if (_currentProfile != null) {
      _originalProfile = _currentProfile;
      await _clearDraft();
      _lastSavedAt = DateTime.now();
    }
  }

  /// Obtém as mudanças atuais
  Map<String, dynamic> _getCurrentChanges() {
    return _currentDraft?.changes ?? <String, dynamic>{};
  }

  /// Atualiza campos do perfil de passageiro
  void _updatePassengerProfile(String field, dynamic value) {
    if (_currentProfile == null) return;
    
    var passengerProfile = _currentProfile!.passengerProfile ?? const PassengerProfile();
    
    switch (field) {
      case 'emergencyContactName':
        passengerProfile = passengerProfile.copyWith(emergencyContactName: value as String?);
        break;
      case 'emergencyContactPhone':
        passengerProfile = passengerProfile.copyWith(emergencyContactPhone: value as String?);
        break;
      case 'paymentMethod':
        passengerProfile = passengerProfile.copyWith(paymentMethod: value as String?);
        break;
    }
    
    _currentProfile = _currentProfile!.copyWith(passengerProfile: passengerProfile);
  }

  /// Valida o perfil antes de salvar
  Map<String, String> _validateProfile(UserProfile profile) {
    final errors = <String, String>{};
    
    // Validações básicas
    if (profile.firstName.trim().isEmpty) {
      errors['firstName'] = 'Nome é obrigatório';
    }
    
    if (profile.lastName.trim().isEmpty) {
      errors['lastName'] = 'Sobrenome é obrigatório';
    }
    
    // Validar telefone se fornecido
    if (profile.phone != null && profile.phone!.isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,15}$');
      if (!phoneRegex.hasMatch(profile.phone!)) {
        errors['phone'] = 'Formato de telefone inválido';
      }
    }
    
    return errors;
  }

  /// Rastreia mudanças em campos específicos
  void _trackFieldChange(ProfileSection section, String field, dynamic value) {
    _analyticsTimer?.cancel();
    _analyticsTimer = Timer(_analyticsDelay, () {
      if (_currentProfile != null) {
        _analytics.trackFieldChanged(_currentProfile!.id, section, field, value);
      }
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _analyticsTimer?.cancel();
    super.dispose();
  }
}

/// Exceção para erros de validação
class ValidationException implements Exception {
  
  ValidationException(this.errors);
  final Map<String, String> errors;
  
  @override
  String toString() {
    return 'Erros de validação: ${errors.values.join(', ')}';
  }
}