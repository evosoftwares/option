import '../entities/location_data.dart';
import '../entities/tracking_config.dart';

/// Repositório abstrato para operações de localização
/// 
/// Define o contrato para acesso a dados de localização,
/// seguindo os princípios de Clean Architecture.
abstract class LocationRepository {
  /// Obtém a localização atual do dispositivo
  /// 
  /// [config] - Configuração para obtenção da localização
  /// 
  /// Retorna [EnhancedLocationData] com a localização atual
  /// ou lança exceção em caso de erro.
  Future<EnhancedLocationData> getCurrentLocation(TrackingConfig config);
  
  /// Inicia o rastreamento contínuo de localização
  /// 
  /// [config] - Configuração do rastreamento
  /// 
  /// Retorna um Stream de [EnhancedLocationData] com atualizações
  /// de localização em tempo real.
  Stream<EnhancedLocationData> startLocationTracking(TrackingConfig config);
  
  /// Para o rastreamento de localização
  Future<void> stopLocationTracking();
  
  /// Verifica se o rastreamento está ativo
  bool get isTrackingActive;
  
  /// Verifica se as permissões de localização estão concedidas
  Future<bool> hasLocationPermission();
  
  /// Solicita permissões de localização
  Future<bool> requestLocationPermission();
  
  /// Verifica se o serviço de localização está habilitado
  Future<bool> isLocationServiceEnabled();
  
  /// Abre as configurações de localização do dispositivo
  Future<void> openLocationSettings();
  
  /// Calcula a distância entre duas localizações
  /// 
  /// [from] - Localização de origem
  /// [to] - Localização de destino
  /// 
  /// Retorna a distância em metros.
  double calculateDistance(EnhancedLocationData from, EnhancedLocationData to);
  
  /// Obtém endereço a partir de coordenadas (geocoding reverso)
  /// 
  /// [latitude] - Latitude da localização
  /// [longitude] - Longitude da localização
  /// 
  /// Retorna o endereço formatado ou null se não encontrado.
  Future<String?> getAddressFromCoordinates(double latitude, double longitude);
  
  /// Obtém coordenadas a partir de endereço (geocoding)
  /// 
  /// [address] - Endereço a ser convertido
  /// 
  /// Retorna [EnhancedLocationData] com as coordenadas ou null se não encontrado.
  Future<EnhancedLocationData?> getCoordinatesFromAddress(String address);
  
  /// Limpa cache de localizações
  Future<void> clearLocationCache();
  
  /// Obtém estatísticas do rastreamento
  /// 
  /// Retorna informações sobre precisão, número de atualizações,
  /// tempo de rastreamento, etc.
  Future<Map<String, dynamic>> getTrackingStatistics();
}