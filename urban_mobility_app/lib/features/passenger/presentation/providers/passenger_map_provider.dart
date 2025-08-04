import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
  });
  final GoogleMapController? mapController;
  final LocationData? currentLocation;
  final bool isLoading;
  final String? error;
  final Set<Marker> markers;
  final CameraPosition cameraPosition;

  PassengerMapState copyWith({
    GoogleMapController? mapController,
    LocationData? currentLocation,
    bool? isLoading,
    String? error,
    Set<Marker>? markers,
    CameraPosition? cameraPosition,
  }) {
    return PassengerMapState(
      mapController: mapController ?? this.mapController,
      currentLocation: currentLocation ?? this.currentLocation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      markers: markers ?? this.markers,
      cameraPosition: cameraPosition ?? this.cameraPosition,
    );
  }
}

/// Notifier para gerenciar o estado do mapa do passageiro
class PassengerMapNotifier extends StateNotifier<PassengerMapState> {

  PassengerMapNotifier(this._locationRepository) : super(const PassengerMapState());
  final LocationRepository _locationRepository;

  /// Inicializa o controlador do mapa
  void setMapController(GoogleMapController controller) {
    state = state.copyWith(mapController: controller);
    _getCurrentLocation();
  }

  /// Obtém a localização atual do usuário
  Future<void> _getCurrentLocation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final locationData = await _locationRepository.getCurrentLocation();
      
      final newCameraPosition = CameraPosition(
        target: LatLng(locationData.latitude, locationData.longitude),
        zoom: 16.0,
      );

      final markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(locationData.latitude, locationData.longitude),
          infoWindow: InfoWindow(
            title: 'Sua localização',
            snippet: locationData.fullAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      };

      state = state.copyWith(
        currentLocation: locationData,
        isLoading: false,
        markers: markers,
        cameraPosition: newCameraPosition,
      );

      // Move a câmera para a localização atual
      if (state.mapController != null) {
        await state.mapController!.animateCamera(
          CameraUpdate.newCameraPosition(newCameraPosition),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao obter localização: ${e.toString()}',
      );
    }
  }

  /// Atualiza a localização manualmente
  Future<void> updateCurrentLocation() async {
    await _getCurrentLocation();
  }

  /// Move a câmera para uma posição específica
  Future<void> moveToLocation(double latitude, double longitude) async {
    if (state.mapController != null) {
      final newPosition = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 16.0,
      );

      await state.mapController!.animateCamera(
        CameraUpdate.newCameraPosition(newPosition),
      );

      state = state.copyWith(cameraPosition: newPosition);
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