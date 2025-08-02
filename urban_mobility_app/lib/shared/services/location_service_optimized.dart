/* [Service: Location] Serviço otimizado de localização com retry, cache e melhor tratamento de erros */
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

enum LocationStatus { initial, loading, success, error, permissionDenied }

class LocationResult {
  final Position? position;
  final String? address;
  final String? error;
  final LocationStatus status;

  const LocationResult({
    this.position,
    this.address,
    this.error,
    required this.status,
  });

  LocationResult copyWith({
    Position? position,
    String? address,
    String? error,
    LocationStatus? status,
  }) {
    return LocationResult(
      position: position ?? this.position,
      address: address ?? this.address,
      error: error ?? this.error,
      status: status ?? this.status,
    );
  }
}

class LocationServiceOptimized extends ChangeNotifier {
  LocationResult _state = const LocationResult(status: LocationStatus.initial);
  DateTime? _lastUpdate;
  static const Duration _cacheTimeout = Duration(minutes: 5);
  static const int _maxRetries = 3;

  LocationResult get state => _state;
  Position? get currentPosition => _state.position;
  String? get currentAddress => _state.address;
  bool get isLoading => _state.status == LocationStatus.loading;
  String? get error => _state.error;

  void _updateState(LocationResult newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> getCurrentPosition({bool forceRefresh = false}) async {
    // Cache check
    if (!forceRefresh && _isCacheValid()) {
      return;
    }

    _updateState(_state.copyWith(status: LocationStatus.loading, error: null));

    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;

      final position = await _getCurrentPositionWithRetry();
      final address = await _getAddressFromLatLng(position);
      
      _lastUpdate = DateTime.now();
      _updateState(LocationResult(
        position: position,
        address: address,
        status: LocationStatus.success,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        status: LocationStatus.error,
        error: 'Erro ao obter localização: ${e.toString()}',
      ));
    }
  }

  bool _isCacheValid() {
    return _lastUpdate != null &&
        DateTime.now().difference(_lastUpdate!) < _cacheTimeout &&
        _state.status == LocationStatus.success;
  }

  Future<Position> _getCurrentPositionWithRetry() async {
    Exception? lastException;
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }
    
    throw lastException!;
  }

  Future<bool> _handleLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateState(_state.copyWith(
          status: LocationStatus.error,
          error: 'Serviços de localização estão desabilitados.',
        ));
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _updateState(_state.copyWith(
            status: LocationStatus.permissionDenied,
            error: 'Permissões de localização foram negadas.',
          ));
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _updateState(_state.copyWith(
          status: LocationStatus.permissionDenied,
          error: 'Permissões de localização foram negadas permanentemente.',
        ));
        return false;
      }

      return true;
    } catch (e) {
      _updateState(_state.copyWith(
        status: LocationStatus.error,
        error: 'Erro ao verificar permissões: ${e.toString()}',
      ));
      return false;
    }
  }

  Future<String> _getAddressFromLatLng(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}';
      }
      return 'Endereço não encontrado';
    } catch (e) {
      return 'Erro ao obter endereço';
    }
  }

  Future<List<Location>> searchLocation(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      return await locationFromAddress(query);
    } catch (e) {
      throw Exception('Erro ao buscar localização: ${e.toString()}');
    }
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  void clearError() {
    if (_state.error != null) {
      _updateState(_state.copyWith(error: null));
    }
  }

  void reset() {
    _state = const LocationResult(status: LocationStatus.initial);
    _lastUpdate = null;
    notifyListeners();
  }
}