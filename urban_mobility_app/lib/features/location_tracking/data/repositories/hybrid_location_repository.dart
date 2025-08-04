import 'dart:async';
import '../../../../core/data/repositories/supabase_location_repository.dart';
import '../../../../core/data/models/location_data.dart';
import '../../domain/entities/location_data.dart';
import '../../domain/entities/tracking_config.dart';
import '../../domain/repositories/location_repository.dart';

/// Repositório híbrido que combina tracking local com sincronização Supabase
/// 
/// Este repositório implementa o padrão Decorator, adicionando funcionalidades
/// de sincronização com Supabase ao repositório local existente.
class HybridLocationRepository implements LocationRepository {
  
  HybridLocationRepository({
    required LocationRepository localRepository,
    required SupabaseLocationRepository supabaseRepository,
    required String userId,
  }) : _localRepository = localRepository,
       _supabaseRepository = supabaseRepository,
       _userId = userId;
  final LocationRepository _localRepository;
  final SupabaseLocationRepository _supabaseRepository;
  final String _userId;
  
  StreamController<EnhancedLocationData>? _locationController;
  StreamSubscription<EnhancedLocationData>? _localSubscription;

  @override
  Future<EnhancedLocationData> getCurrentLocation(TrackingConfig config) async {
    // Obtém localização do repositório local
    final location = await _localRepository.getCurrentLocation(config);
    
    // Sincroniza com Supabase em background
    _syncLocationToSupabase(location);
    
    return location;
  }

  @override
  Stream<EnhancedLocationData> startLocationTracking(TrackingConfig config) {
    // Cria controller para o stream híbrido
    _locationController = StreamController<EnhancedLocationData>.broadcast();
    
    // Inicia tracking local
    final localStream = _localRepository.startLocationTracking(config);
    
    // Inicia tracking em tempo real no Supabase
    _supabaseRepository.startRealtimeTracking();
    
    // Escuta atualizações do repositório local
    _localSubscription = localStream.listen(
      (location) {
        // Repassa a localização para o stream híbrido
        _locationController?.add(location);
        
        // Sincroniza com Supabase em background
        _syncLocationToSupabase(location);
      },
      onError: (error) {
        _locationController?.addError(error);
      },
      onDone: () {
        _locationController?.close();
      },
    );
    
    print('🚀 Tracking híbrido iniciado (Local + Supabase)');
    return _locationController!.stream;
  }

  @override
  Future<void> stopLocationTracking() async {
    // Para tracking local
    await _localRepository.stopLocationTracking();
    
    // Para tracking em tempo real no Supabase
    _supabaseRepository.stopRealtimeTracking();
    
    // Cancela subscription e fecha controller
    await _localSubscription?.cancel();
    _localSubscription = null;
    
    await _locationController?.close();
    _locationController = null;
    
    print('🛑 Tracking híbrido parado');
  }

  @override
  bool get isTrackingActive => _localRepository.isTrackingActive;

  @override
  Future<bool> hasLocationPermission() async {
    return await _localRepository.hasLocationPermission();
  }

  @override
  Future<bool> requestLocationPermission() async {
    return await _localRepository.requestLocationPermission();
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await _localRepository.isLocationServiceEnabled();
  }

  @override
  Future<void> openLocationSettings() async {
    return await _localRepository.openLocationSettings();
  }

  @override
  double calculateDistance(EnhancedLocationData from, EnhancedLocationData to) {
    return _localRepository.calculateDistance(from, to);
  }

  @override
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    return await _localRepository.getAddressFromCoordinates(latitude, longitude);
  }

  @override
  Future<EnhancedLocationData?> getCoordinatesFromAddress(String address) async {
    return await _localRepository.getCoordinatesFromAddress(address);
  }

  @override
  Future<void> clearLocationCache() async {
    return await _localRepository.clearLocationCache();
  }

  @override
  Future<Map<String, dynamic>> getTrackingStatistics() async {
    final localStats = await _localRepository.getTrackingStatistics();
    
    // Adiciona estatísticas específicas do Supabase
    localStats['supabase_enabled'] = true;
    localStats['user_id'] = _userId;
    localStats['sync_enabled'] = true;
    
    return localStats;
  }

  /// Sincroniza localização com Supabase em background
  Future<void> _syncLocationToSupabase(EnhancedLocationData location) async {
    try {
      // Converte EnhancedLocationData para LocationData do Supabase
      final supabaseLocation = LocationData(
        userId: _userId,
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy,
        speed: location.speed,
        heading: location.heading,
        timestamp: location.timestamp,
        metadata: {
          'source': location.source.name,
          'provider': location.provider,
          'altitude': location.altitude,
          ...?location.metadata,
        },
      );
      
      // Salva no histórico do Supabase
      await _supabaseRepository.saveLocation(
        userId: supabaseLocation.userId,
        latitude: supabaseLocation.latitude,
        longitude: supabaseLocation.longitude,
        accuracy: supabaseLocation.accuracy,
        speed: supabaseLocation.speed,
        heading: supabaseLocation.heading,
        metadata: supabaseLocation.metadata,
      );
      
      // Atualiza localização atual
      await _supabaseRepository.updateCurrentLocation(
        userId: _userId,
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy,
        speed: location.speed,
        heading: location.heading,
        metadata: supabaseLocation.metadata,
      );
      
      print('✅ Localização sincronizada com Supabase');
    } catch (e) {
      print('⚠️ Erro ao sincronizar com Supabase: $e');
      // Não propaga o erro para não afetar o tracking local
    }
  }

  /// Obtém histórico de localizações do Supabase
  Future<List<LocationData>> getLocationHistory({int limit = 100}) async {
    try {
      return await _supabaseRepository.getLocationHistory(
        userId: _userId,
        limit: limit,
      );
    } catch (e) {
      print('⚠️ Erro ao obter histórico do Supabase: $e');
      return [];
    }
  }

  /// Obtém localizações atuais de todos os usuários
  Future<List<LocationData>> getCurrentLocations() async {
    try {
      return await _supabaseRepository.getCurrentLocations();
    } catch (e) {
      print('⚠️ Erro ao obter localizações atuais: $e');
      return [];
    }
  }

  /// Limpa recursos
  void dispose() {
    stopLocationTracking();
    _supabaseRepository.dispose();
  }
}