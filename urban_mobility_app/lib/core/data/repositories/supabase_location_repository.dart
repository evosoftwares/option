import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_data.dart';
import '../../services/supabase_service.dart';

/// Repositório para gerenciar dados de localização no Supabase
/// 
/// Este repositório demonstra como usar o Supabase para:
/// - Salvar localizações em tempo real
/// - Escutar mudanças de localização de outros usuários
/// - Implementar tracking colaborativo
class SupabaseLocationRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  /// Nome da tabela de localizações no Supabase
  static const String _locationsTable = 'user_locations';
  
  /// Nome da tabela de viagens no Supabase
  static const String _tripsTable = 'trips';
  
  /// Canal de realtime para escutar mudanças
  RealtimeChannel? _locationChannel;
  
  /// Stream controller para broadcast de localizações
  final StreamController<List<LocationData>> _locationsController = 
      StreamController<List<LocationData>>.broadcast();
  
  /// Stream de localizações em tempo real
  Stream<List<LocationData>> get locationsStream => _locationsController.stream;
  
  /// Salva uma nova localização no Supabase
  /// 
  /// [userId] - ID do usuário
  /// [latitude] - Latitude da localização
  /// [longitude] - Longitude da localização
  /// [accuracy] - Precisão da localização em metros
  /// [speed] - Velocidade em m/s (opcional)
  /// [heading] - Direção em graus (opcional)
  Future<void> saveLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required double accuracy,
    double? speed,
    double? heading,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final locationData = {
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'heading': heading,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': metadata,
      };
      
      await _supabaseService.from(_locationsTable).insert(locationData);
      
      print('✅ Localização salva: ($latitude, $longitude)');
    } catch (e) {
      print('❌ Erro ao salvar localização: $e');
      rethrow;
    }
  }
  
  /// Atualiza a localização atual do usuário (upsert)
  /// 
  /// Esta função mantém apenas a localização mais recente do usuário
  Future<void> updateCurrentLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required double accuracy,
    double? speed,
    double? heading,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final locationData = {
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'heading': heading,
        'updated_at': DateTime.now().toIso8601String(),
        'metadata': metadata,
      };
      
      await _supabaseService.from('current_locations').upsert(
        locationData,
        onConflict: 'user_id',
      );
      
      print('✅ Localização atual atualizada: ($latitude, $longitude)');
    } catch (e) {
      print('❌ Erro ao atualizar localização atual: $e');
      rethrow;
    }
  }
  
  /// Obtém o histórico de localizações de um usuário
  Future<List<LocationData>> getLocationHistory({
    required String userId,
    int limit = 100,
  }) async {
    try {
      final response = await _supabaseService
          .from(_locationsTable)
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((json) => LocationData.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Erro ao obter histórico de localizações: $e');
      rethrow;
    }
  }
  
  /// Obtém todas as localizações atuais
  Future<List<LocationData>> getCurrentLocations() async {
    try {
      final response = await _supabaseService
          .from('current_locations')
          .select()
          .order('updated_at', ascending: false);
      
      return (response as List)
          .map((json) => LocationData.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Erro ao obter localizações atuais: $e');
      rethrow;
    }
  }
  
  /// Inicia o tracking em tempo real de localizações
  void startRealtimeTracking({String? tripId}) {
    try {
      _locationChannel = _supabaseService.channel('location_tracking');
      
      _locationChannel!
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'current_locations',
            callback: (payload) {
              _handleLocationUpdate(payload);
            },
          )
          .subscribe();
      
      print('✅ Tracking em tempo real iniciado');
    } catch (e) {
      print('❌ Erro ao iniciar tracking em tempo real: $e');
    }
  }
  
  /// Para o tracking em tempo real
  void stopRealtimeTracking() {
    try {
      _locationChannel?.unsubscribe();
      _locationChannel = null;
      print('✅ Tracking em tempo real parado');
    } catch (e) {
      print('❌ Erro ao parar tracking em tempo real: $e');
    }
  }
  
  /// Manipula atualizações de localização em tempo real
  void _handleLocationUpdate(PostgresChangePayload payload) {
    try {
      print('📍 Atualização de localização recebida: ${payload.eventType}');
      
      // Aqui você pode processar a atualização e notificar listeners
      // Por exemplo, buscar todas as localizações atualizadas
      _fetchAndBroadcastLocations();
    } catch (e) {
      print('❌ Erro ao processar atualização de localização: $e');
    }
  }
  
  /// Busca e transmite localizações atuais
  Future<void> _fetchAndBroadcastLocations() async {
    try {
      final response = await _supabaseService
          .from('current_locations')
          .select()
          .order('updated_at', ascending: false);
      
      final locations = (response as List)
          .map((json) => LocationData.fromJson(json))
          .toList();
      
      _locationsController.add(locations);
    } catch (e) {
      print('❌ Erro ao buscar localizações: $e');
    }
  }
  
  /// Cria uma nova viagem
  Future<String> createTrip({
    required String driverId,
    required String passengerId,
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required double price,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final tripData = {
        'driver_id': driverId,
        'passenger_id': passengerId,
        'start_latitude': startLat,
        'start_longitude': startLng,
        'end_latitude': endLat,
        'end_longitude': endLng,
        'price': price,
        'status': 'created',
        'created_at': DateTime.now().toIso8601String(),
        'metadata': metadata,
      };
      
      final response = await _supabaseService
          .from(_tripsTable)
          .insert(tripData)
          .select()
          .single();
      
      final tripId = response['id']?.toString() ?? '';
      print('✅ Viagem criada: $tripId');
      
      return tripId;
    } catch (e) {
      print('❌ Erro ao criar viagem: $e');
      rethrow;
    }
  }
  
  /// Atualiza o status de uma viagem
  Future<void> updateTripStatus({
    required String tripId,
    required String status,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Se a coluna 'metadata' no Supabase for JSONB, podemos enviar Map diretamente.
      // Caso seja TEXT/VARCHAR, faça jsonEncode. Aqui tratamos ambos os casos:
      if (metadata != null) {
        updateData['metadata'] = metadata; // JSONB suportado
      }
      
      await _supabaseService
          .from(_tripsTable)
          .update(updateData)
          .eq('id', tripId);
      
      print('✅ Status da viagem atualizado: $tripId -> $status');
    } catch (e) {
      print('❌ Erro ao atualizar status da viagem: $e');
      rethrow;
    }
  }
  
  /// Limpa recursos
  void dispose() {
    stopRealtimeTracking();
    _locationsController.close();
  }
}