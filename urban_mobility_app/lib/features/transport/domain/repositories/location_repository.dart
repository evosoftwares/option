import '../models/location_data.dart';

abstract class LocationRepository {
  /// Obtém a localização atual do usuário
  Future<LocationData> getCurrentLocation();
  
  /// Converte coordenadas em endereço (geocodificação reversa)
  Future<LocationData> getAddressFromCoordinates(double lat, double lng);
  
  /// Busca endereços baseado em texto
  Future<List<LocationData>> searchAddresses(String query);
  
  /// Verifica se as permissões de localização estão concedidas
  Future<bool> hasLocationPermission();
  
  /// Solicita permissões de localização
  Future<bool> requestLocationPermission();
  
  /// Verifica se o serviço de localização está habilitado
  Future<bool> isLocationServiceEnabled();
}