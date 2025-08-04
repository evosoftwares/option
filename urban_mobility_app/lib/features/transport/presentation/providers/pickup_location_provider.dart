import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/models/location_data.dart';
import '../../domain/repositories/location_repository.dart';
import '../../data/repositories/location_repository_impl.dart';

// Provider do repositório
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl();
});

// Estado da tela de pickup
class PickupLocationState {

  const PickupLocationState({
    this.currentLocation,
    this.currentAddress = "Obtendo localização...",
    this.isLoadingAddress = false,
    this.isMapMoving = false,
    this.hasLocationPermission = false,
    this.isLocationServiceEnabled = false,
    this.errorMessage,
    this.cameraPosition,
  });
  final LocationData? currentLocation;
  final String currentAddress;
  final bool isLoadingAddress;
  final bool isMapMoving;
  final bool hasLocationPermission;
  final bool isLocationServiceEnabled;
  final String? errorMessage;
  final CameraPosition? cameraPosition;

  PickupLocationState copyWith({
    LocationData? currentLocation,
    String? currentAddress,
    bool? isLoadingAddress,
    bool? isMapMoving,
    bool? hasLocationPermission,
    bool? isLocationServiceEnabled,
    String? errorMessage,
    CameraPosition? cameraPosition,
  }) {
    return PickupLocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      currentAddress: currentAddress ?? this.currentAddress,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      isMapMoving: isMapMoving ?? this.isMapMoving,
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
      isLocationServiceEnabled: isLocationServiceEnabled ?? this.isLocationServiceEnabled,
      errorMessage: errorMessage,
      cameraPosition: cameraPosition ?? this.cameraPosition,
    );
  }
}

// Provider principal
class PickupLocationNotifier extends StateNotifier<PickupLocationState> {

  PickupLocationNotifier(this._locationRepository) : super(const PickupLocationState());
  final LocationRepository _locationRepository;
  Timer? _debounce;
  GoogleMapController? _mapController;

  // Posição inicial (São Bernardo do Campo)
  static const double _initialLat = -23.682160;
  static const double _initialLng = -46.565360;
  static const double _defaultZoom = 16.0;

  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(_initialLat, _initialLng),
    zoom: _defaultZoom,
  );

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> initializeLocation() async {
    state = state.copyWith(isLoadingAddress: true, errorMessage: null);

    try {
      // Verificar permissões e serviços
      final hasPermission = await _locationRepository.hasLocationPermission();
      final serviceEnabled = await _locationRepository.isLocationServiceEnabled();

      state = state.copyWith(
        hasLocationPermission: hasPermission,
        isLocationServiceEnabled: serviceEnabled,
      );

      if (!serviceEnabled) {
        state = state.copyWith(
          currentAddress: 'Serviço de localização desabilitado',
          isLoadingAddress: false,
          errorMessage: 'Por favor, habilite o serviço de localização',
        );
        return;
      }

      if (!hasPermission) {
        final granted = await _locationRepository.requestLocationPermission();
        state = state.copyWith(hasLocationPermission: granted);
        
        if (!granted) {
          state = state.copyWith(
            currentAddress: 'Permissão de localização negada',
            isLoadingAddress: false,
            errorMessage: 'Permissão de localização é necessária',
          );
          await _updateAddressFromCoordinates(_initialLat, _initialLng);
          return;
        }
      }

      // Obter localização atual
      final location = await _locationRepository.getCurrentLocation();
      
      state = state.copyWith(
        currentLocation: location,
        currentAddress: location.shortAddress,
        isLoadingAddress: false,
        cameraPosition: CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: _defaultZoom,
        ),
      );

      // Mover o mapa para a localização atual
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(location.latitude, location.longitude),
            _defaultZoom,
          ),
        );
      }

    } catch (e) {
      state = state.copyWith(
        currentAddress: 'Erro ao obter localização',
        isLoadingAddress: false,
        errorMessage: e.toString(),
      );
      
      // Usar localização padrão em caso de erro
      await _updateAddressFromCoordinates(_initialLat, _initialLng);
    }
  }

  void onCameraMove() {
    if (!state.isMapMoving) {
      state = state.copyWith(isMapMoving: true);
    }

    // Cancelar debounce anterior
    _debounce?.cancel();

    // Configurar novo debounce
    _debounce = Timer(const Duration(milliseconds: 800), () {
      onCameraIdle();
    });
  }

  Future<void> onCameraIdle() async {
    state = state.copyWith(isMapMoving: false);

    if (_mapController == null) return;

    try {
      // Obter posição central do mapa
      final LatLng center = await _mapController!.getLatLng(
        const ScreenCoordinate(x: 0, y: 0), // Centro da tela
      );

      await _updateAddressFromCoordinates(center.latitude, center.longitude);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao obter endereço do mapa',
      );
    }
  }

  Future<void> _updateAddressFromCoordinates(double lat, double lng) async {
    state = state.copyWith(
      isLoadingAddress: true,
      currentAddress: 'Obtendo endereço...',
    );

    try {
      final location = await _locationRepository.getAddressFromCoordinates(lat, lng);
      
      state = state.copyWith(
        currentLocation: location,
        currentAddress: location.shortAddress,
        isLoadingAddress: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        currentAddress: 'Endereço não encontrado',
        isLoadingAddress: false,
        errorMessage: 'Erro ao obter endereço',
      );

      // Tentar novamente após 3 segundos
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _updateAddressFromCoordinates(lat, lng);
        }
      });
    }
  }

  Future<void> moveToCurrentLocation() async {
    if (_mapController == null) return;

    try {
      state = state.copyWith(isLoadingAddress: true);
      
      final location = await _locationRepository.getCurrentLocation();
      
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude),
          _defaultZoom,
        ),
      );

      state = state.copyWith(
        currentLocation: location,
        currentAddress: location.shortAddress,
        isLoadingAddress: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingAddress: false,
        errorMessage: 'Erro ao obter localização atual',
      );
    }
  }

  Future<List<LocationData>> searchAddresses(String query) async {
    try {
      return await _locationRepository.searchAddresses(query);
    } catch (e) {
      return [];
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// Provider final
final pickupLocationProvider = StateNotifierProvider<PickupLocationNotifier, PickupLocationState>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return PickupLocationNotifier(repository);
});