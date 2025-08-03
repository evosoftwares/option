import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Estados de permissão de localização
enum LocationPermissionState {
  notRequested,
  whenInUse,
  always,
  denied,
  permanentlyDenied,
}

/// Estratégias de solicitação de permissão
enum PermissionStrategy {
  gentle,      // Abordagem suave com educação
  direct,      // Solicitação direta
  persistent,  // Insistente mas respeitosa
  emergency,   // Para casos críticos
}

/// Contextos de uso para personalizar mensagens
enum UsageContext {
  onboarding,
  firstRide,
  backgroundTracking,
  safetyFeature,
  analytics,
}

/// Gerenciador de permissões progressivas com estratégias educativas
class PermissionManager {
  static const String _keyPermissionRequests = 'permission_requests_count';
  static const String _keyLastRequest = 'last_permission_request';
  static const String _keyUserEducated = 'user_educated_location';
  static const String _keyEngagementLevel = 'user_engagement_level';
  static const String _keyPermissionDenials = 'permission_denials_count';
  
  static final PermissionManager _instance = PermissionManager._();
  static PermissionManager get instance => _instance;
  
  PermissionManager._();
  
  late final SharedPreferences _prefs;
  bool _initialized = false;
  
  // Callbacks para UI
  Function(String title, String message, List<String> benefits)? onShowEducationalDialog;
  Function(String title, String message, VoidCallback onSettings)? onShowSettingsDialog;
  Function(LocationPermissionState state)? onPermissionStateChanged;
  
  /// Inicializa o gerenciador
  Future<void> initialize() async {
    if (_initialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    
    debugPrint('✅ PermissionManager inicializado');
  }
  
  /// Obtém o estado atual das permissões
  Future<LocationPermissionState> getCurrentPermissionState() async {
    final status = await Permission.locationWhenInUse.status;
    final alwaysStatus = await Permission.locationAlways.status;
    
    if (status.isPermanentlyDenied || alwaysStatus.isPermanentlyDenied) {
      return LocationPermissionState.permanentlyDenied;
    }
    
    if (alwaysStatus.isGranted) {
      return LocationPermissionState.always;
    }
    
    if (status.isGranted) {
      return LocationPermissionState.whenInUse;
    }
    
    if (status.isDenied || alwaysStatus.isDenied) {
      return LocationPermissionState.denied;
    }
    
    return LocationPermissionState.notRequested;
  }
  
  /// Solicita permissões de localização com estratégia adaptativa
  Future<LocationPermissionState> requestLocationPermission({
    required UsageContext context,
    bool requireAlways = false,
    PermissionStrategy? strategy,
  }) async {
    await _ensureInitialized();
    
    final currentState = await getCurrentPermissionState();
    
    // Se já temos a permissão necessária, retornar
    if (_hasRequiredPermission(currentState, requireAlways)) {
      return currentState;
    }
    
    // Determinar estratégia baseada no contexto e histórico
    final effectiveStrategy = strategy ?? await _determineOptimalStrategy(context);
    
    // Executar estratégia de solicitação
    final result = await _executePermissionStrategy(
      context: context,
      strategy: effectiveStrategy,
      requireAlways: requireAlways,
      currentState: currentState,
    );
    
    // Registrar resultado
    await _recordPermissionAttempt(result);
    
    // Notificar mudança de estado
    onPermissionStateChanged?.call(result);
    
    return result;
  }
  
  /// Verifica se o usuário está engajado o suficiente para permissão "always"
  Future<bool> isUserReadyForAlwaysPermission() async {
    await _ensureInitialized();
    
    final engagementLevel = _prefs.getInt(_keyEngagementLevel) ?? 0;
    final requestCount = _prefs.getInt(_keyPermissionRequests) ?? 0;
    final denialCount = _prefs.getInt(_keyPermissionDenials) ?? 0;
    
    // Critérios para estar pronto:
    // 1. Nível de engajamento alto (>= 3)
    // 2. Poucas negações de permissão (< 2)
    // 3. Não solicitou muitas vezes recentemente (< 3)
    return engagementLevel >= 3 && denialCount < 2 && requestCount < 3;
  }
  
  /// Incrementa o nível de engajamento do usuário
  Future<void> incrementEngagement({
    String? action,
    int points = 1,
  }) async {
    await _ensureInitialized();
    
    final currentLevel = _prefs.getInt(_keyEngagementLevel) ?? 0;
    await _prefs.setInt(_keyEngagementLevel, currentLevel + points);
    
    debugPrint('📈 Engajamento incrementado: $action (+$points) = ${currentLevel + points}');
  }
  
  /// Mostra educação sobre benefícios da localização
  Future<bool> showLocationEducation({
    required UsageContext context,
    bool force = false,
  }) async {
    await _ensureInitialized();
    
    final wasEducated = _prefs.getBool(_keyUserEducated) ?? false;
    if (wasEducated && !force) return true;
    
    final education = _getEducationContent(context);
    
    if (onShowEducationalDialog != null) {
      final completer = Completer<bool>();
      
      onShowEducationalDialog!(
        education['title']!,
        education['message']!,
        education['benefits']!.cast<String>(),
      );
      
      // Marcar como educado após mostrar
      await _prefs.setBool(_keyUserEducated, true);
      return true;
    }
    
    return false;
  }
  
  /// Abre configurações do sistema para permissões
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
      
      // Aguardar retorno do usuário e verificar permissões
      Timer(const Duration(seconds: 2), () async {
        final newState = await getCurrentPermissionState();
        onPermissionStateChanged?.call(newState);
      });
      
    } catch (e) {
      debugPrint('❌ Erro ao abrir configurações: $e');
    }
  }
  
  /// Verifica se deve mostrar rationale para permissão
  Future<bool> shouldShowRationale() async {
    if (Platform.isAndroid) {
      return await Permission.locationWhenInUse.shouldShowRequestRationale;
    }
    
    // No iOS, sempre mostrar educação na primeira vez
    final requestCount = _prefs.getInt(_keyPermissionRequests) ?? 0;
    return requestCount == 0;
  }
  
  /// Obtém estatísticas de permissões
  Map<String, dynamic> getPermissionStats() {
    return {
      'requestCount': _prefs.getInt(_keyPermissionRequests) ?? 0,
      'denialCount': _prefs.getInt(_keyPermissionDenials) ?? 0,
      'engagementLevel': _prefs.getInt(_keyEngagementLevel) ?? 0,
      'wasEducated': _prefs.getBool(_keyUserEducated) ?? false,
      'lastRequest': _prefs.getString(_keyLastRequest),
    };
  }
  
  /// Reseta estatísticas (para testes ou reset de usuário)
  Future<void> resetStats() async {
    await _ensureInitialized();
    
    await _prefs.remove(_keyPermissionRequests);
    await _prefs.remove(_keyLastRequest);
    await _prefs.remove(_keyUserEducated);
    await _prefs.remove(_keyEngagementLevel);
    await _prefs.remove(_keyPermissionDenials);
    
    debugPrint('🔄 Estatísticas de permissão resetadas');
  }
  
  // Métodos privados
  
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }
  
  bool _hasRequiredPermission(LocationPermissionState state, bool requireAlways) {
    if (requireAlways) {
      return state == LocationPermissionState.always;
    } else {
      return state == LocationPermissionState.whenInUse || 
             state == LocationPermissionState.always;
    }
  }
  
  Future<PermissionStrategy> _determineOptimalStrategy(UsageContext context) async {
    final requestCount = _prefs.getInt(_keyPermissionRequests) ?? 0;
    final denialCount = _prefs.getInt(_keyPermissionDenials) ?? 0;
    final engagementLevel = _prefs.getInt(_keyEngagementLevel) ?? 0;
    
    // Primeira solicitação - sempre gentil
    if (requestCount == 0) {
      return PermissionStrategy.gentle;
    }
    
    // Muitas negações - ser mais educativo
    if (denialCount >= 2) {
      return PermissionStrategy.persistent;
    }
    
    // Alto engajamento - pode ser mais direto
    if (engagementLevel >= 5) {
      return PermissionStrategy.direct;
    }
    
    // Contextos críticos
    if (context == UsageContext.safetyFeature) {
      return PermissionStrategy.emergency;
    }
    
    return PermissionStrategy.gentle;
  }
  
  Future<LocationPermissionState> _executePermissionStrategy({
    required UsageContext context,
    required PermissionStrategy strategy,
    required bool requireAlways,
    required LocationPermissionState currentState,
  }) async {
    
    switch (strategy) {
      case PermissionStrategy.gentle:
        return await _executeGentleStrategy(context, requireAlways, currentState);
        
      case PermissionStrategy.direct:
        return await _executeDirectStrategy(requireAlways);
        
      case PermissionStrategy.persistent:
        return await _executePersistentStrategy(context, requireAlways, currentState);
        
      case PermissionStrategy.emergency:
        return await _executeEmergencyStrategy(context, requireAlways);
    }
  }
  
  Future<LocationPermissionState> _executeGentleStrategy(
    UsageContext context,
    bool requireAlways,
    LocationPermissionState currentState,
  ) async {
    // Mostrar educação primeiro
    await showLocationEducation(context: context);
    
    // Aguardar um pouco para o usuário processar
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Solicitar permissão básica primeiro
    if (currentState == LocationPermissionState.notRequested ||
        currentState == LocationPermissionState.denied) {
      final status = await Permission.locationWhenInUse.request();
      
      if (!status.isGranted) {
        return await getCurrentPermissionState();
      }
    }
    
    // Se precisar de "always", solicitar em segundo momento
    if (requireAlways) {
      // Verificar se usuário está pronto
      final isReady = await isUserReadyForAlwaysPermission();
      if (isReady) {
        await Permission.locationAlways.request();
      }
    }
    
    return await getCurrentPermissionState();
  }
  
  Future<LocationPermissionState> _executeDirectStrategy(bool requireAlways) async {
    if (requireAlways) {
      await Permission.locationAlways.request();
    } else {
      await Permission.locationWhenInUse.request();
    }
    
    return await getCurrentPermissionState();
  }
  
  Future<LocationPermissionState> _executePersistentStrategy(
    UsageContext context,
    bool requireAlways,
    LocationPermissionState currentState,
  ) async {
    // Mostrar educação mais detalhada
    await showLocationEducation(context: context, force: true);
    
    // Explicar por que é importante
    final content = _getPersistentEducationContent(context);
    
    if (onShowEducationalDialog != null) {
      onShowEducationalDialog!(
        content['title']!,
        content['message']!,
        content['benefits']!.cast<String>(),
      );
    }
    
    // Aguardar mais tempo para reflexão
    await Future.delayed(const Duration(seconds: 1));
    
    // Solicitar permissão
    if (requireAlways) {
      await Permission.locationAlways.request();
    } else {
      await Permission.locationWhenInUse.request();
    }
    
    final newState = await getCurrentPermissionState();
    
    // Se ainda negado, oferecer ir para configurações
    if (newState == LocationPermissionState.denied ||
        newState == LocationPermissionState.permanentlyDenied) {
      
      if (onShowSettingsDialog != null) {
        onShowSettingsDialog!(
          'Permissão Necessária',
          'Para usar este recurso, você precisa habilitar a localização nas configurações do app.',
          () => openAppSettings(),
        );
      }
    }
    
    return newState;
  }
  
  Future<LocationPermissionState> _executeEmergencyStrategy(
    UsageContext context,
    bool requireAlways,
  ) async {
    final content = _getEmergencyEducationContent(context);
    
    if (onShowEducationalDialog != null) {
      onShowEducationalDialog!(
        content['title']!,
        content['message']!,
        content['benefits']!.cast<String>(),
      );
    }
    
    // Solicitar imediatamente
    if (requireAlways) {
      await Permission.locationAlways.request();
    } else {
      await Permission.locationWhenInUse.request();
    }
    
    return await getCurrentPermissionState();
  }
  
  Future<void> _recordPermissionAttempt(LocationPermissionState result) async {
    final requestCount = _prefs.getInt(_keyPermissionRequests) ?? 0;
    await _prefs.setInt(_keyPermissionRequests, requestCount + 1);
    await _prefs.setString(_keyLastRequest, DateTime.now().toIso8601String());
    
    // Registrar negação se aplicável
    if (result == LocationPermissionState.denied ||
        result == LocationPermissionState.permanentlyDenied) {
      final denialCount = _prefs.getInt(_keyPermissionDenials) ?? 0;
      await _prefs.setInt(_keyPermissionDenials, denialCount + 1);
    }
  }
  
  Map<String, dynamic> _getEducationContent(UsageContext context) {
    switch (context) {
      case UsageContext.onboarding:
        return {
          'title': 'Localização para Melhor Experiência',
          'message': 'Permitir acesso à localização nos ajuda a oferecer rotas mais precisas e encontrar motoristas próximos a você.',
          'benefits': [
            'Encontrar motoristas mais rapidamente',
            'Rotas otimizadas e precisas',
            'Estimativas de tempo mais exatas',
            'Recursos de segurança aprimorados',
          ],
        };
        
      case UsageContext.firstRide:
        return {
          'title': 'Localização para Sua Primeira Viagem',
          'message': 'Para conectar você com o motorista mais próximo e garantir uma experiência segura.',
          'benefits': [
            'Localização automática do ponto de partida',
            'Motorista encontra você facilmente',
            'Acompanhamento da viagem em tempo real',
          ],
        };
        
      case UsageContext.backgroundTracking:
        return {
          'title': 'Rastreamento em Segundo Plano',
          'message': 'Permitir localização sempre ativa melhora significativamente sua experiência e segurança.',
          'benefits': [
            'Localização instantânea ao abrir o app',
            'Recursos de segurança 24/7',
            'Histórico de viagens mais preciso',
            'Notificações baseadas em localização',
          ],
        };
        
      case UsageContext.safetyFeature:
        return {
          'title': 'Recursos de Segurança',
          'message': 'A localização é essencial para recursos de segurança como compartilhamento de viagem e botão de emergência.',
          'benefits': [
            'Compartilhamento de localização em tempo real',
            'Botão de emergência funcional',
            'Alertas de desvio de rota',
            'Suporte rápido em emergências',
          ],
        };
        
      case UsageContext.analytics:
        return {
          'title': 'Melhorar Nossos Serviços',
          'message': 'Dados de localização nos ajudam a melhorar rotas e disponibilidade de motoristas.',
          'benefits': [
            'Melhor disponibilidade de motoristas',
            'Rotas mais eficientes',
            'Preços mais justos',
            'Experiência personalizada',
          ],
        };
    }
  }
  
  Map<String, dynamic> _getPersistentEducationContent(UsageContext context) {
    return {
      'title': 'Por que a Localização é Importante?',
      'message': 'Entendemos sua preocupação com privacidade. Vamos explicar exatamente como usamos sua localização e por que é importante para sua experiência.',
      'benefits': [
        'Seus dados são criptografados e seguros',
        'Localização usada apenas para melhorar o serviço',
        'Você pode desativar a qualquer momento',
        'Transparência total sobre o uso dos dados',
        'Recursos de segurança que podem salvar vidas',
      ],
    };
  }
  
  Map<String, dynamic> _getEmergencyEducationContent(UsageContext context) {
    return {
      'title': 'Recurso de Segurança Crítico',
      'message': 'Este recurso de segurança requer acesso à localização para funcionar adequadamente em situações de emergência.',
      'benefits': [
        'Localização precisa em emergências',
        'Resposta rápida de equipes de segurança',
        'Compartilhamento automático com contatos',
        'Pode ser a diferença entre vida e morte',
      ],
    };
  }
}

/// Extensões para facilitar o uso
extension LocationPermissionStateExtension on LocationPermissionState {
  bool get isGranted => this == LocationPermissionState.whenInUse || 
                       this == LocationPermissionState.always;
  
  bool get isDenied => this == LocationPermissionState.denied || 
                      this == LocationPermissionState.permanentlyDenied;
  
  bool get canRequestAgain => this != LocationPermissionState.permanentlyDenied;
  
  String get displayName {
    switch (this) {
      case LocationPermissionState.notRequested:
        return 'Não solicitada';
      case LocationPermissionState.whenInUse:
        return 'Permitida durante uso';
      case LocationPermissionState.always:
        return 'Sempre permitida';
      case LocationPermissionState.denied:
        return 'Negada';
      case LocationPermissionState.permanentlyDenied:
        return 'Permanentemente negada';
    }
  }
}