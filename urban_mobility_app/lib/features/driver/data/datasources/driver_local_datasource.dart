import '../../domain/models/driver_profile.dart';
import '../../domain/models/driver_work_config.dart';
import '../../domain/models/driver_status.dart' hide DriverLocation;
import '../../domain/models/active_ride.dart';
import '../../domain/repositories/driver_repository.dart';

/// Interface para operações locais (cache/storage) do motorista
abstract class DriverLocalDatasource {
  // ========== Cache de Perfil ==========
  Future<DriverProfile?> getDriverProfile(String driverId);
  Future<void> saveDriverProfile(DriverProfile profile);
  Future<void> clearDriverProfile(String driverId);

  // ========== Cache de Configuração ==========
  Future<DriverWorkConfig?> getWorkConfig(String driverId);
  Future<void> saveWorkConfig(String driverId, DriverWorkConfig config);
  Future<void> clearWorkConfig(String driverId);

  // ========== Cache de Status ==========
  Future<DriverStatus?> getDriverStatus(String driverId);
  Future<void> saveDriverStatus(String driverId, DriverStatus status);
  Future<DriverLocation?> getLastLocation(String driverId);
  Future<void> saveLastLocation(String driverId, DriverLocation location);

  // ========== Cache de Viagem Ativa ==========
  Future<ActiveRide?> getCurrentActiveRide(String driverId);
  Future<void> saveActiveRide(ActiveRide ride);
  Future<void> clearActiveRide();

  // ========== Cache de Configurações ==========
  Future<DriverAppSettings?> getAppSettings(String driverId);
  Future<void> saveAppSettings(String driverId, DriverAppSettings settings);
  Future<NotificationSettings?> getNotificationSettings(String driverId);
  Future<void> saveNotificationSettings(
    String driverId,
    NotificationSettings settings,
  );

  // ========== Operações Gerais ==========
  Future<void> clearAllCache(String driverId);
  Future<bool> hasValidCache(String driverId);
}
