import 'dart:async';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geocoding/geocoding.dart';
import '../../domain/entities/location_data.dart';
import '../../domain/entities/tracking_config.dart';

/// Data source para operações de localização
/// 
/// Implementa acesso direto aos serviços de localização
/// do dispositivo usando geolocator e geocoding.
abstract class LocationDataSource {
  /// Obtém a localização atual
  Future<EnhancedLocationData> getCurrentLocation(TrackingConfig config);
  
  /// Inicia rastreamento contínuo
  Stream<EnhancedLocationData> startLocationTracking(TrackingConfig config);
  
  /// Para o rastreamento
  Future<void> stopLocationTracking();
  
  /// Verifica se está rastreando
  bool get isTrackingActive;
  
  /// Verifica permissões
  Future<bool> hasLocationPermission();
  
  /// Solicita permissões
  Future<bool> requestLocationPermission();
  
  /// Verifica se serviço está habilitado
  Future<bool> isLocationServiceEnabled();
  
  /// Abre configurações
  Future<void> openLocationSettings();
  
  /// Geocoding reverso
  Future<String?> getAddressFromCoordinates(double latitude, double longitude);
  
  /// Geocoding
  Future<EnhancedLocationData?> getCoordinatesFromAddress(String address);
}

/// Implementação do data source usando geolocator
class GeolocatorLocationDataSource implements LocationDataSource {
  StreamSubscription<geolocator.Position>? _positionSubscription;
  StreamController<EnhancedLocationData>? _locationController;
  bool _isTracking = false;

  @override
  bool get isTrackingActive => _isTracking;

  @override
  Future<EnhancedLocationData> getCurrentLocation(TrackingConfig config) async {
    final position = await geolocator.Geolocator.getCurrentPosition(
      desiredAccuracy: _mapAccuracy(config.accuracy),
      timeLimit: Duration(milliseconds: config.timeoutMs),
    );

    return _positionToLocationData(position);
  }

  @override
  Stream<EnhancedLocationData> startLocationTracking(TrackingConfig config) {
    if (_isTracking) {
      throw StateError('Rastreamento já está ativo');
    }

    _locationController = StreamController<EnhancedLocationData>.broadcast();
    _isTracking = true;

    final locationSettings = geolocator.LocationSettings(
      accuracy: _mapAccuracy(config.accuracy),
      distanceFilter: config.minDistanceMeters.round(),
      timeLimit: Duration(milliseconds: config.timeoutMs),
    );

    _positionSubscription = geolocator.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) {
        final locationData = _positionToLocationData(position);
        _locationController?.add(locationData);
      },
      onError: (error) {
        _locationController?.addError(error);
      },
    );

    return _locationController!.stream;
  }

  @override
  Future<void> stopLocationTracking() async {
    if (!_isTracking) return;

    await _positionSubscription?.cancel();
    _positionSubscription = null;
    
    await _locationController?.close();
    _locationController = null;
    
    _isTracking = false;
  }

  @override
  Future<bool> hasLocationPermission() async {
    final permission = await geolocator.Geolocator.checkPermission();
    return permission == geolocator.LocationPermission.always ||
           permission == geolocator.LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestLocationPermission() async {
    final permission = await geolocator.Geolocator.requestPermission();
    return permission == geolocator.LocationPermission.always ||
           permission == geolocator.LocationPermission.whileInUse;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await geolocator.Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<void> openLocationSettings() async {
    await geolocator.Geolocator.openLocationSettings();
  }

  @override
  Future<String?> getAddressFromCoordinates(
    double latitude, 
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return _formatAddress(placemark);
      }
    } catch (e) {
      // Log error but don't throw
      print('Erro no geocoding reverso: $e');
    }
    return null;
  }

  @override
  Future<EnhancedLocationData?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return EnhancedLocationData(
          latitude: location.latitude,
          longitude: location.longitude,
          accuracy: 100.0, // Precisão estimada para geocoding
          timestamp: DateTime.now(),
          address: address,
          source: LocationSource.geocoding,
        );
      }
    } catch (e) {
      // Log error but don't throw
      print('Erro no geocoding: $e');
    }
    return null;
  }

  /// Converte Position para EnhancedLocationData
  EnhancedLocationData _positionToLocationData(geolocator.Position position) {
    return EnhancedLocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      heading: position.heading,
      speed: position.speed,
      speedAccuracy: position.speedAccuracy,
      timestamp: position.timestamp ?? DateTime.now(),
      source: LocationSource.gps,
    );
  }

  /// Mapeia LocationAccuracy para geolocator LocationAccuracy
  geolocator.LocationAccuracy _mapAccuracy(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return geolocator.LocationAccuracy.lowest;
      case LocationAccuracy.low:
        return geolocator.LocationAccuracy.low;
      case LocationAccuracy.medium:
        return geolocator.LocationAccuracy.medium;
      case LocationAccuracy.high:
        return geolocator.LocationAccuracy.high;
      case LocationAccuracy.best:
        return geolocator.LocationAccuracy.best;
      case LocationAccuracy.bestForNavigation:
        return geolocator.LocationAccuracy.bestForNavigation;
    }
  }

  /// Formata endereço a partir de Placemark
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street?.isNotEmpty == true) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality?.isNotEmpty == true) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.country?.isNotEmpty == true) {
      parts.add(placemark.country!);
    }

    return parts.join(', ');
  }

  /// Limpa recursos ao destruir
  void dispose() {
    stopLocationTracking();
  }
}