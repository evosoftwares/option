import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/map_error_handler.dart';
import '../../../transport/domain/models/location_data.dart';
import '../../../transport/domain/repositories/location_repository.dart';
import '../../../transport/data/repositories/location_repository_impl.dart';

/// Provider para o repositório de localização
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl();
});

/// Estado do mapa do passageiro
class PassengerMapState {

  const PassengerMapState({
    this.mapController,
    this.currentLocation,
    this.isLoading = false,
    this.error,
    this.markers = const {},
    this.cameraPosition = const CameraPosition(
      target: LatLng(-23.5505, -46.6333), // São Paulo como padrão
      zoom: 15.0,
    ),
    this.lastLocationUpdate,
    this.isLocationUpdateInProgress = false,
  });
  final GoogleMapController? mapController;
  final LocationData? currentLocation;
  final bool isLoading;
  final String? error;
  final Set<Marker> markers;
  final CameraPosition cameraPosition;
  final DateTime? lastLocationUpdate;
  final bool isLocationUpdateInProgress;

  PassengerMapState copyWith({
    GoogleMapController? mapController,
    LocationData? currentLocation,
    bool? isLoading,
    String? error,
    Set<Marker>? markers,
    CameraPosition? cameraPosition,
    DateTime? lastLocationUpdate,
    bool? isLocationUpdateInProgress,
  }) {
    return PassengerMapState(
      mapController: mapController ?? this.mapController,
      currentLocation: currentLocation ?? this.currentLocation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      markers: markers ?? this.markers,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      isLocationUpdateInProgress: isLocationUpdateInProgress ?? this.isLocationUpdateInProgress,
    );
  }
}

/// Notifier para gerenciar o estado do mapa do passageiro
class PassengerMapNotifier extends StateNotifier<PassengerMapState> {

  PassengerMapNotifier(this._locationRepository) : super(const PassengerMapState());
  final LocationRepository _locationRepository;
  
  // Cache settings
  static const Duration _cacheTimeout = Duration(minutes: 2);
  static const Duration _rateLimitInterval = Duration(seconds: 1);
  DateTime? _lastLocationRequest;

  /// Inicializa o controlador do mapa
  void setMapController(GoogleMapController controller) {
    MapErrorHandler.safeSyncMapOperation(
      () {
        state = state.copyWith(mapController: controller);
        _getCurrentLocation(forceUpdate: false); // Use cache if available
      },
      operationName: 'Configuração do controlador do mapa',
    );
  }

  /// Verifica se a localização em cache ainda é válida
  bool _isLocationCacheValid() {
    if (state.lastLocationUpdate == null) return false;
    final timeSinceUpdate = DateTime.now().difference(state.lastLocationUpdate!);
    return timeSinceUpdate < _cacheTimeout;
  }

  /// Verifica rate limiting
  bool _isRateLimited() {
    if (_lastLocationRequest == null) return false;
    final timeSinceRequest = DateTime.now().difference(_lastLocationRequest!);
    return timeSinceRequest < _rateLimitInterval;
  }

  /// Obtém a localização atual do usuário com cache e rate limiting
  Future<void> _getCurrentLocation({bool forceUpdate = false}) async {
    // Rate limiting check
    if (!forceUpdate && _isRateLimited()) {
      return;
    }

    // Cache check
    if (!forceUpdate && _isLocationCacheValid() && state.currentLocation != null) {
      _moveToCurrentLocation();
      return;
    }

    // Prevent concurrent requests
    if (state.isLocationUpdateInProgress) {
      return;
    }

    try {
      state = state.copyWith(
        isLoading: true, 
        error: null,
        isLocationUpdateInProgress: true,
      );
      
      _lastLocationRequest = DateTime.now();
      final locationData = await _locationRepository.getCurrentLocation();
      
      final newCameraPosition = CameraPosition(
        target: LatLng(locationData.latitude, locationData.longitude),
        zoom: 16.0,
      );

      state = state.copyWith(
        currentLocation: locationData,
        isLoading: false,
        cameraPosition: newCameraPosition,
        lastLocationUpdate: DateTime.now(),
        isLocationUpdateInProgress: false,
      );

      // Move a câmera para a localização atual
      await _moveToCurrentLocation();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLocationUpdateInProgress: false,
        error: 'Erro ao obter localização: ${e.toString()}',
      );
    }
  }

  /// Move a câmera para a localização atual
  Future<void> _moveToCurrentLocation() async {
    if (state.mapController != null && state.currentLocation != null) {
      await MapErrorHandler.safeMapOperation(
        () async {
          final newCameraPosition = CameraPosition(
            target: LatLng(
              state.currentLocation!.latitude, 
              state.currentLocation!.longitude,
            ),
            zoom: 16.0,
          );
          
          await state.mapController!.animateCamera(
            CameraUpdate.newCameraPosition(newCameraPosition),
          );
        },
        operationName: 'Movimento da câmera para localização atual',
      );
    }
  }

  /// Atualiza a localização manualmente com opção de forçar
  Future<void> updateCurrentLocation({bool forceUpdate = true}) async {
    await _getCurrentLocation(forceUpdate: forceUpdate);
  }

  /// Move a câmera para uma posição específica
  Future<void> moveToLocation(double latitude, double longitude) async {
    if (state.mapController != null) {
      await MapErrorHandler.safeMapOperation(
        () async {
          final newPosition = CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 16.0,
          );

          await state.mapController!.animateCamera(
            CameraUpdate.newCameraPosition(newPosition),
          );

          state = state.copyWith(cameraPosition: newPosition);
        },
        operationName: 'Movimento da câmera para posição específica',
      );
    }
  }

  /// Adiciona um marcador no mapa
  void addMarker(String id, double latitude, double longitude, String title, {String? snippet}) {
    final newMarker = Marker(
      markerId: MarkerId(id),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
    );

    final updatedMarkers = Set<Marker>.from(state.markers)..add(newMarker);
    state = state.copyWith(markers: updatedMarkers);
  }

  /// Remove um marcador do mapa
  void removeMarker(String id) {
    final updatedMarkers = Set<Marker>.from(state.markers)
      ..removeWhere((marker) => marker.markerId.value == id);
    state = state.copyWith(markers: updatedMarkers);
  }

  /// Limpa todos os marcadores exceto a localização atual
  void clearMarkers() {
    final currentLocationMarker = state.markers
        .where((marker) => marker.markerId.value == 'current_location')
        .toSet();
    state = state.copyWith(markers: currentLocationMarker);
  }

  /// Limpa erros
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider principal para o estado do mapa do passageiro
final passengerMapProvider = StateNotifierProvider<PassengerMapNotifier, PassengerMapState>((ref) {
  return PassengerMapNotifier(ref.read(locationRepositoryProvider));
});