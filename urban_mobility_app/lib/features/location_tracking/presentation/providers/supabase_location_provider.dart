import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/data/repositories/supabase_location_repository.dart';
import '../../../../core/data/models/location_data.dart';
import '../../../../core/services/supabase_service.dart';

/// Provider que integra o Supabase com o sistema de tracking de localização
/// 
/// Este provider demonstra como usar o Supabase para:
/// - Sincronizar localizações em tempo real
/// - Compartilhar localização com outros usuários
/// - Manter histórico de localizações na nuvem
class SupabaseLocationProvider extends ChangeNotifier {
  final SupabaseLocationRepository _repository = SupabaseLocationRepository();
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  // Estado do provider
  bool _isTracking = false;
  bool _isConnected = false;
  String? _currentUserId;
  LocationData? _currentLocation;
  List<LocationData> _nearbyUsers = [];
  List<LocationData> _locationHistory = [];
  String? _errorMessage;
  
  // Timers e streams
  Timer? _syncTimer;
  StreamSubscription? _realtimeSubscription;
  
  // Getters
  bool get isTracking => _isTracking;
  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;
  LocationData? get currentLocation => _currentLocation;
  List<LocationData> get nearbyUsers => _nearbyUsers;
  List<LocationData> get locationHistory => _locationHistory;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  
  /// Inicializa o provider e verifica a conexão com Supabase
  Future<void> initialize() async {
    try {
      _errorMessage = null;
      
      // Verificar se o Supabase está inicializado
      if (!_supabaseService.isInitialized) {
        throw Exception('Supabase não foi inicializado');
      }
      
      // Verificar autenticação
      final user = _supabaseService.currentUser;
      if (user != null) {
        _currentUserId = user.id;
        _isConnected = true;
        print('✅ Usuário autenticado: ${user.email}');
      } else {
        // Para demonstração, criar um usuário temporário
        _currentUserId = 'demo_user_${DateTime.now().millisecondsSinceEpoch}';
        _isConnected = true;
        print('📱 Usando usuário demo: $_currentUserId');
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao inicializar: $e';
      _isConnected = false;
      print('❌ Erro na inicialização: $e');
      notifyListeners();
    }
  }
  
  /// Inicia o tracking de localização com sincronização no Supabase
  Future<void> startTracking() async {
    if (_isTracking || !_isConnected || _currentUserId == null) {
      return;
    }
    
    try {
      _isTracking = true;
      _errorMessage = null;
      notifyListeners();
      
      // Iniciar tracking em tempo real
      _repository.startRealtimeTracking();
      
      // Escutar mudanças de localização em tempo real
      _realtimeSubscription = _repository.locationsStream.listen(
        (locations) {
          _nearbyUsers = locations.where((loc) => loc.userId != _currentUserId).toList();
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Erro no realtime: $error';
          notifyListeners();
        },
      );
      
      // Iniciar timer para sincronização periódica
      _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _syncCurrentLocation();
      });
      
      print('✅ Tracking com Supabase iniciado');
    } catch (e) {
      _errorMessage = 'Erro ao iniciar tracking: $e';
      _isTracking = false;
      print('❌ Erro ao iniciar tracking: $e');
      notifyListeners();
    }
  }
  
  /// Para o tracking de localização
  Future<void> stopTracking() async {
    if (!_isTracking) return;
    
    try {
      _isTracking = false;
      
      // Parar realtime tracking
      _repository.stopRealtimeTracking();
      
      // Cancelar subscriptions e timers
      await _realtimeSubscription?.cancel();
      _syncTimer?.cancel();
      
      _realtimeSubscription = null;
      _syncTimer = null;
      
      print('✅ Tracking com Supabase parado');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao parar tracking: $e';
      print('❌ Erro ao parar tracking: $e');
      notifyListeners();
    }
  }
  
  /// Atualiza a localização atual e sincroniza com Supabase
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
    double? speed,
    double? heading,
  }) async {
    if (!_isConnected || _currentUserId == null) return;
    
    try {
      // Criar objeto de localização
      final locationData = LocationData(
        userId: _currentUserId!,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        speed: speed,
        heading: heading,
        timestamp: DateTime.now(),
      );
      
      _currentLocation = locationData;
      
      // Salvar no Supabase se estiver tracking
      if (_isTracking) {
        await _repository.updateCurrentLocation(
          userId: _currentUserId!,
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
          speed: speed,
          heading: heading,
        );
        
        // Também salvar no histórico
        await _repository.saveLocation(
          userId: _currentUserId!,
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
          speed: speed,
          heading: heading,
        );
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao atualizar localização: $e';
      print('❌ Erro ao atualizar localização: $e');
      notifyListeners();
    }
  }
  
  /// Carrega o histórico de localizações do usuário
  Future<void> loadLocationHistory() async {
    if (!_isConnected || _currentUserId == null) return;
    
    try {
      _locationHistory = await _repository.getLocationHistory(
        userId: _currentUserId!,
        limit: 100,
      );
      
      print('✅ Histórico carregado: ${_locationHistory.length} localizações');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar histórico: $e';
      print('❌ Erro ao carregar histórico: $e');
      notifyListeners();
    }
  }
  
  /// Carrega localizações de usuários próximos
  Future<void> loadNearbyUsers() async {
    if (!_isConnected) return;
    
    try {
      final allLocations = await _repository.getCurrentLocations();
      _nearbyUsers = allLocations.where((loc) => loc.userId != _currentUserId).toList();
      
      print('✅ Usuários próximos carregados: ${_nearbyUsers.length}');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar usuários próximos: $e';
      print('❌ Erro ao carregar usuários próximos: $e');
      notifyListeners();
    }
  }
  
  /// Sincroniza a localização atual (chamado periodicamente)
  Future<void> _syncCurrentLocation() async {
    if (_currentLocation != null) {
      await updateLocation(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        accuracy: _currentLocation!.accuracy,
        speed: _currentLocation!.speed,
        heading: _currentLocation!.heading,
      );
    }
  }
  
  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Testa a conexão com Supabase
  Future<bool> testConnection() async {
    try {
      // Tentar fazer uma operação simples para testar a conexão
      await _repository.getCurrentLocations();
      _isConnected = true;
      _errorMessage = null;
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao testar conexão: $e';
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Obtém estatísticas do tracking
  Map<String, dynamic> getTrackingStats() {
    return {
      'isTracking': _isTracking,
      'isConnected': _isConnected,
      'currentUserId': _currentUserId,
      'hasCurrentLocation': _currentLocation != null,
      'nearbyUsersCount': _nearbyUsers.length,
      'historyCount': _locationHistory.length,
      'hasError': hasError,
      'errorMessage': _errorMessage,
    };
  }
  
  @override
  void dispose() {
    stopTracking();
    _repository.dispose();
    super.dispose();
  }
}