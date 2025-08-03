import '../../domain/entities/location_data.dart';
import '../../domain/entities/tracking_config.dart';
import '../../domain/repositories/location_repository.dart';
import '../data_sources/location_data_source.dart';

/// Implementação do repositório de localização
/// 
/// Implementa o contrato definido no domínio, coordenando
/// operações entre data sources e aplicando regras de negócio.
class LocationRepositoryImpl implements LocationRepository {

  LocationRepositoryImpl(this._dataSource);
  final LocationDataSource _dataSource;
  final Map<String, dynamic> _statistics = {};

  @override
  Future<EnhancedLocationData> getCurrentLocation(TrackingConfig config) async {
    try {
      final location = await _dataSource.getCurrentLocation(config);
      _updateStatistics('getCurrentLocation', true);
      return location;
    } catch (e) {
      _updateStatistics('getCurrentLocation', false);
      rethrow;
    }
  }

  @override
  Stream<EnhancedLocationData> startLocationTracking(TrackingConfig config) {
    try {
      final stream = _dataSource.startLocationTracking(config);
      _updateStatistics('startTracking', true);
      
      // Adicionar filtros e transformações se necessário
      return stream.map((location) {
        _updateStatistics('locationUpdate', true);
        return location;
      }).handleError((error) {
        _updateStatistics('locationUpdate', false);
        throw error;
      });
    } catch (e) {
      _updateStatistics('startTracking', false);
      rethrow;
    }
  }

  @override
  Future<void> stopLocationTracking() async {
    try {
      await _dataSource.stopLocationTracking();
      _updateStatistics('stopTracking', true);
    } catch (e) {
      _updateStatistics('stopTracking', false);
      rethrow;
    }
  }

  @override
  bool get isTrackingActive => _dataSource.isTrackingActive;

  @override
  Future<bool> hasLocationPermission() async {
    try {
      final hasPermission = await _dataSource.hasLocationPermission();
      _updateStatistics('checkPermission', true);
      return hasPermission;
    } catch (e) {
      _updateStatistics('checkPermission', false);
      rethrow;
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      final granted = await _dataSource.requestLocationPermission();
      _updateStatistics('requestPermission', granted);
      return granted;
    } catch (e) {
      _updateStatistics('requestPermission', false);
      rethrow;
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      final enabled = await _dataSource.isLocationServiceEnabled();
      _updateStatistics('checkService', true);
      return enabled;
    } catch (e) {
      _updateStatistics('checkService', false);
      rethrow;
    }
  }

  @override
  Future<void> openLocationSettings() async {
    try {
      await _dataSource.openLocationSettings();
      _updateStatistics('openSettings', true);
    } catch (e) {
      _updateStatistics('openSettings', false);
      rethrow;
    }
  }

  @override
  double calculateDistance(EnhancedLocationData from, EnhancedLocationData to) {
    try {
      final distance = from.distanceTo(to);
      _updateStatistics('calculateDistance', true);
      return distance;
    } catch (e) {
      _updateStatistics('calculateDistance', false);
      rethrow;
    }
  }

  @override
  Future<String?> getAddressFromCoordinates(
    double latitude, 
    double longitude,
  ) async {
    try {
      final address = await _dataSource.getAddressFromCoordinates(
        latitude, 
        longitude,
      );
      _updateStatistics('reverseGeocode', address != null);
      return address;
    } catch (e) {
      _updateStatistics('reverseGeocode', false);
      rethrow;
    }
  }

  @override
  Future<EnhancedLocationData?> getCoordinatesFromAddress(String address) async {
    try {
      final location = await _dataSource.getCoordinatesFromAddress(address);
      _updateStatistics('geocode', location != null);
      return location;
    } catch (e) {
      _updateStatistics('geocode', false);
      rethrow;
    }
  }

  @override
  Future<void> clearLocationCache() async {
    try {
      // Implementar limpeza de cache se necessário
      _updateStatistics('clearCache', true);
    } catch (e) {
      _updateStatistics('clearCache', false);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getTrackingStatistics() async {
    return Map<String, dynamic>.from(_statistics);
  }

  /// Atualiza estatísticas internas
  void _updateStatistics(String operation, bool success) {
    final key = '${operation}_${success ? 'success' : 'error'}';
    _statistics[key] = (_statistics[key] ?? 0) + 1;
    _statistics['last_operation'] = operation;
    _statistics['last_operation_time'] = DateTime.now().toIso8601String();
    _statistics['last_operation_success'] = success;
  }
}