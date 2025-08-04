import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:urban_mobility_app/core/data/models/location_data.dart' as remote;
import 'package:urban_mobility_app/core/data/repositories/supabase_location_repository.dart';
import 'package:urban_mobility_app/features/location_tracking/data/repositories/hybrid_location_repository.dart';
import 'package:urban_mobility_app/features/location_tracking/domain/entities/location_data.dart';
import 'package:urban_mobility_app/features/location_tracking/domain/entities/tracking_config.dart';
import 'package:urban_mobility_app/features/location_tracking/domain/repositories/location_repository.dart';

/// Stubs/Fakes simples (sem dependências externas) para facilitar controle do comportamento
class FakeLocalRepository implements LocationRepository {
  FakeLocalRepository({
    this.currentLocation,
    this.streamItems = const [],
    this.hasPermission = true,
    this.serviceEnabled = true,
    this.address,
    this.geocodedLocation,
  });

  EnhancedLocationData? currentLocation;
  final List<EnhancedLocationData> streamItems;
  bool hasPermission;
  bool serviceEnabled;

  // geocoding
  String? address;
  EnhancedLocationData? geocodedLocation;

  // controles internos
  bool _tracking = false;
  final StreamController<EnhancedLocationData> _controller =
      StreamController<EnhancedLocationData>.broadcast();

  // métricas de chamadas
  int getCurrentLocationCalls = 0;
  int startTrackingCalls = 0;
  int stopTrackingCalls = 0;
  int hasPermissionCalls = 0;
  int requestPermissionCalls = 0;
  int isServiceEnabledCalls = 0;
  int openSettingsCalls = 0;
  int reverseGeocodeCalls = 0;
  int geocodeCalls = 0;

  @override
  Future<EnhancedLocationData> getCurrentLocation(TrackingConfig config) async {
    getCurrentLocationCalls++;
    if (currentLocation == null) {
      throw StateError('No currentLocation configured');
    }
    return currentLocation!;
  }

  @override
  Stream<EnhancedLocationData> startLocationTracking(TrackingConfig config) {
    startTrackingCalls++;
    _tracking = true;

    // emite a sequência configurada de pontos de forma assíncrona
    Future.microtask(() async {
      for (final item in streamItems) {
        if (!_tracking) break;
        _controller.add(item);
        await Future.delayed(const Duration(milliseconds: 5));
      }
    });

    return _controller.stream;
  }

  @override
  Future<void> stopLocationTracking() async {
    stopTrackingCalls++;
    _tracking = false;
  }

  @override
  bool get isTrackingActive => _tracking;

  @override
  Future<bool> hasLocationPermission() async {
    hasPermissionCalls++;
    return hasPermission;
  }

  @override
  Future<bool> requestLocationPermission() async {
    requestPermissionCalls++;
    hasPermission = true;
    return true;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    isServiceEnabledCalls++;
    return serviceEnabled;
  }

  @override
  Future<void> openLocationSettings() async {
    openSettingsCalls++;
  }

  @override
  double calculateDistance(EnhancedLocationData from, EnhancedLocationData to) {
    // usa a própria entidade para calcular
    return from.distanceTo(to);
  }

  @override
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    reverseGeocodeCalls++;
    return address;
  }

  @override
  Future<EnhancedLocationData?> getCoordinatesFromAddress(String address) async {
    geocodeCalls++;
    return geocodedLocation;
  }

  @override
  Future<void> clearLocationCache() async {}

  @override
  Future<Map<String, dynamic>> getTrackingStatistics() async => {};
}

class FakeSupabaseRepository implements SupabaseLocationRepository {
  // flags de falha para simular fallback
  bool failSave = false;
  bool failUpdateCurrent = false;
  bool failHistory = false;
  bool failCurrentLocations = false;

  // métricas
  int saveCalls = 0;
  int updateCurrentCalls = 0;
  int startRealtimeCalls = 0;
  int stopRealtimeCalls = 0;
  int disposeCalls = 0;

  // dados simulados
  List<remote.LocationData> history = const [];
  List<remote.LocationData> currentLocations = const [];

  // stream simulada de realtime
  final StreamController<List<remote.LocationData>> _locationsController =
      StreamController<List<remote.LocationData>>.broadcast();

  @override
  Stream<List<remote.LocationData>> get locationsStream => _locationsController.stream;

  @override
  Future<void> saveLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required double accuracy,
    double? speed,
    double? heading,
    Map<String, dynamic>? metadata,
  }) async {
    saveCalls++;
    if (failSave) {
      throw Exception('saveLocation failed');
    }
  }

  @override
  Future<void> updateCurrentLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required double accuracy,
    double? speed,
    double? heading,
    Map<String, dynamic>? metadata,
  }) async {
    updateCurrentCalls++;
    if (failUpdateCurrent) {
      throw Exception('updateCurrentLocation failed');
    }
  }

  @override
  Future<List<remote.LocationData>> getLocationHistory({
    required String userId,
    int limit = 100,
  }) async {
    if (failHistory) {
      throw Exception('getLocationHistory failed');
    }
    return history;
  }

  @override
  Future<List<remote.LocationData>> getCurrentLocations() async {
    if (failCurrentLocations) {
      throw Exception('getCurrentLocations failed');
    }
    return currentLocations;
  }

  // Métodos extras exigidos pela interface concreta
  @override
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
    // Para os testes do repositório híbrido, não usamos trips.
    // Retorna um ID fake determinístico.
    return 'trip_test_1';
  }

  @override
  Future<void> updateTripStatus({
    required String tripId,
    required String status,
    Map<String, dynamic>? metadata,
  }) async {
    // Sem efeito nos testes do repositório híbrido.
    return;
  }

  @override
  void startRealtimeTracking({String? tripId}) {
    startRealtimeCalls++;
    // emite uma lista vazia inicialmente
    _locationsController.add(const []);
  }

  @override
  void stopRealtimeTracking() {
    stopRealtimeCalls++;
  }

  @override
  void dispose() {
    disposeCalls++;
    stopRealtimeTracking();
    _locationsController.close();
  }
}

void main() {
  group('HybridLocationRepository - cenários principais', () {
    late FakeLocalRepository local;
    late FakeSupabaseRepository supabase;
    late HybridLocationRepository hybrid;

    const userId = 'user_test';

    EnhancedLocationData point({
      required double lat,
      required double lng,
      double accuracy = 5.0,
      LocationSource source = LocationSource.gps,
      DateTime? time,
      Map<String, dynamic>? metadata,
    }) {
      return EnhancedLocationData(
        latitude: lat,
        longitude: lng,
        accuracy: accuracy,
        source: source,
        timestamp: time ?? DateTime.now(),
        metadata: metadata,
      );
    }

    setUp(() {
      local = FakeLocalRepository(
        currentLocation: point(lat: -23.5505, lng: -46.6333),
        streamItems: [
          point(lat: -23.5506, lng: -46.6334),
          point(lat: -23.5507, lng: -46.6335, source: LocationSource.network),
        ],
        hasPermission: true,
        serviceEnabled: true,
        address: 'Av. Paulista, São Paulo - SP',
        geocodedLocation: point(lat: -23.561, lng: -46.656),
      );

      supabase = FakeSupabaseRepository();

      hybrid = HybridLocationRepository(
        localRepository: local,
        supabaseRepository: supabase,
        userId: userId,
      );
    });

    test('getCurrentLocation delega ao local e sincroniza no Supabase (histórico + current)', () async {
      // Act
      final result = await hybrid.getCurrentLocation(const TrackingConfig());

      // Assert - delegação
      expect(result.latitude, equals(local.currentLocation!.latitude));
      expect(local.getCurrentLocationCalls, equals(1));

      // Assert - sync background (não garante ordem, mas deve ter sido chamado ao menos 1x)
      // Como as chamadas são async, aguarda um microtask
      await Future.delayed(const Duration(milliseconds: 10));
      expect(supabase.saveCalls, equals(1));
      expect(supabase.updateCurrentCalls, equals(1));
    });

    test('startLocationTracking: inicia local + realtime Supabase e sincroniza cada ponto', () async {
      // Act
      final stream = hybrid.startLocationTracking(const TrackingConfig());

      // Collect emissions
      final received = <EnhancedLocationData>[];
      final sub = stream.listen(received.add);

      // aguarda emissões da fake stream
      await Future.delayed(const Duration(milliseconds: 30));

      // Assert - iniciou local e realtime
      expect(local.startTrackingCalls, equals(1));
      expect(supabase.startRealtimeCalls, equals(1));

      // Assert - fluxo de pontos repassado
      expect(received.length, equals(local.streamItems.length));
      expect(hybrid.isTrackingActive, isTrue);

      // Cada ponto sincroniza com Supabase (save + update)
      // 2 itens emitidos => 2 saves e 2 updates
      expect(supabase.saveCalls, greaterThanOrEqualTo(2));
      expect(supabase.updateCurrentCalls, greaterThanOrEqualTo(2));

      await sub.cancel();
    });

    test('stopLocationTracking: para local e realtime, cancela recursos', () async {
      // Arrange - inicia primeiro
      final stream = hybrid.startLocationTracking(const TrackingConfig());
      final sub = stream.listen((_) {});
      await Future.delayed(const Duration(milliseconds: 10));

      // Act
      await hybrid.stopLocationTracking();

      // Assert
      expect(local.stopTrackingCalls, equals(1));
      expect(supabase.stopRealtimeCalls, equals(1));
      expect(hybrid.isTrackingActive, isFalse);

      await sub.cancel();
    });

    test('fallback: falha ao salvar no Supabase não quebra tracking local (log apenas)', () async {
      // Arrange
      supabase.failSave = true;

      final stream = hybrid.startLocationTracking(const TrackingConfig());
      final received = <EnhancedLocationData>[];
      final sub = stream.listen(received.add, onError: (e) {});

      // Act
      await Future.delayed(const Duration(milliseconds: 30));

      // Assert - mesmo com erro no save, os pontos fluem
      expect(received.length, equals(local.streamItems.length));
      // updateCurrent pode ter sido chamado mesmo com falha em save
      expect(supabase.updateCurrentCalls, greaterThanOrEqualTo(1));

      await hybrid.stopLocationTracking();
      await sub.cancel();
    });

    test('fallback: falha ao atualizar current location no Supabase também não quebra tracking', () async {
      // Arrange
      supabase.failUpdateCurrent = true;

      final stream = hybrid.startLocationTracking(const TrackingConfig());
      final received = <EnhancedLocationData>[];
      final sub = stream.listen(received.add, onError: (e) {});

      // Act
      await Future.delayed(const Duration(milliseconds: 30));

      // Assert - fluxo local continua
      expect(received.length, equals(local.streamItems.length));
      // save ainda deve acontecer
      expect(supabase.saveCalls, greaterThanOrEqualTo(1));

      await hybrid.stopLocationTracking();
      await sub.cancel();
    });

    test('delegação de permissões e geocodificação para repositório local', () async {
      // Act
      final hasPerm = await hybrid.hasLocationPermission();
      final serviceOn = await hybrid.isLocationServiceEnabled();
      final addr = await hybrid.getAddressFromCoordinates(-23.0, -46.0);
      final geocoded = await hybrid.getCoordinatesFromAddress('Paulista');
      await hybrid.openLocationSettings();

      // Assert
      expect(hasPerm, isTrue);
      expect(serviceOn, isTrue);
      expect(addr, equals(local.address));
      expect(geocoded, equals(local.geocodedLocation));

      expect(local.hasPermissionCalls, equals(1));
      expect(local.isServiceEnabledCalls, equals(1));
      expect(local.reverseGeocodeCalls, equals(1));
      expect(local.geocodeCalls, equals(1));
      expect(local.openSettingsCalls, equals(1));
    });

    test('getLocationHistory() e getCurrentLocations() consultam Supabase (happy path)', () async {
      // Arrange
      supabase.history = [
        remote.LocationData(
          userId: userId,
          latitude: -23.1,
          longitude: -46.1,
          accuracy: 5,
          timestamp: DateTime.now(),
        ),
      ];
      supabase.currentLocations = [
        remote.LocationData(
          userId: 'other',
          latitude: -23.2,
          longitude: -46.2,
          accuracy: 6,
          timestamp: DateTime.now(),
        ),
      ];

      // Act
      final history = await hybrid.getLocationHistory(limit: 10);
      final currents = await hybrid.getCurrentLocations();

      // Assert
      expect(history, isNotEmpty);
      expect(currents, isNotEmpty);
    });

    test('getLocationHistory() e getCurrentLocations() retornam lista vazia no erro', () async {
      // Arrange
      supabase.failHistory = true;
      supabase.failCurrentLocations = true;

      // Act
      final history = await hybrid.getLocationHistory(limit: 10);
      final currents = await hybrid.getCurrentLocations();

      // Assert
      expect(history, isEmpty);
      expect(currents, isEmpty);
    });
  });
}