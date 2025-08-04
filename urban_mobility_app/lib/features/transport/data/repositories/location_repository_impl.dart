import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/models/location_data.dart';
import '../../domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  static const double _defaultLat = -23.682160; // São Bernardo do Campo
  static const double _defaultLng = -46.565360;

  @override
  Future<LocationData> getCurrentLocation() async {
    try {
      // Verificar se o serviço está habilitado
      if (!await isLocationServiceEnabled()) {
        throw LocationServiceDisabledException();
      }

      // Verificar permissões
      if (!await hasLocationPermission()) {
        final granted = await requestLocationPermission();
        if (!granted) {
          throw LocationPermissionDeniedException();
        }
      }

      // Obter posição atual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Converter para endereço
      return await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      // Em caso de erro, retornar localização padrão
      return await getAddressFromCoordinates(_defaultLat, _defaultLng);
    }
  }

  @override
  Future<LocationData> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      
      if (placemarks.isNotEmpty) {
        return LocationData.fromPlacemark(lat, lng, placemarks.first);
      }
      
      // Fallback se não encontrar endereço
      return LocationData(
        latitude: lat,
        longitude: lng,
        address: 'Localização não identificada',
        city: 'São Bernardo do Campo',
        state: 'SP',
      );
    } catch (e) {
      // Fallback em caso de erro
      return LocationData(
        latitude: lat,
        longitude: lng,
        address: 'Erro ao obter endereço',
        city: 'São Bernardo do Campo',
        state: 'SP',
      );
    }
  }

  @override
  Future<List<LocationData>> searchAddresses(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      
      final locations = await locationFromAddress(query);
      final results = <LocationData>[];
      
      for (final location in locations.take(5)) {
        try {
          final locationData = await getAddressFromCoordinates(
            location.latitude,
            location.longitude,
          );
          results.add(locationData);
        } catch (e) {
          // Ignorar erros individuais
          continue;
        }
      }
      
      return results;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> hasLocationPermission() async {
    final permission = await Permission.location.status;
    return permission.isGranted;
  }

  @override
  Future<bool> requestLocationPermission() async {
    final permission = await Permission.location.request();
    return permission.isGranted;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}

// Exceções customizadas
class LocationServiceDisabledException implements Exception {
  final String message = 'Serviço de localização desabilitado';
}

class LocationPermissionDeniedException implements Exception {
  final String message = 'Permissão de localização negada';
}