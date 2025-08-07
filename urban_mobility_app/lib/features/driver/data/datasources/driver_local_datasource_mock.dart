import '../../domain/models/driver_profile.dart';
import '../../domain/models/driver_work_config.dart';
import '../../domain/models/driver_status.dart' hide DriverLocation;
import '../../domain/models/active_ride.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_local_datasource.dart';

/// Implementação mock do DriverLocalDatasource para desenvolvimento
class DriverLocalDatasourceMock implements DriverLocalDatasource {
  @override
  Future<DriverProfile?> getDriverProfile(String driverId) async {
    return null;
  }

  @override
  Future<void> saveDriverProfile(DriverProfile profile) async {
    // Mock implementation
  }

  @override
  Future<void> clearDriverProfile(String driverId) async {
    // Mock implementation
  }

  @override
  Future<void> clearWorkConfig(String driverId) async {
    // Mock implementation
  }

  @override
  Future<DriverWorkConfig?> getWorkConfig(String driverId) async {
    return null;
  }

  @override
  Future<void> saveWorkConfig(String driverId, DriverWorkConfig config) async {
    // Mock implementation
  }

  @override
  Future<DriverStatus?> getDriverStatus(String driverId) async {
    return null;
  }

  @override
  Future<void> saveDriverStatus(String driverId, DriverStatus status) async {
    // Mock implementation
  }

  @override
  Future<DriverLocation?> getLastLocation(String driverId) async {
    return null;
  }

  @override
  Future<void> saveLastLocation(String driverId, DriverLocation location) async {
    // Mock implementation
  }

  @override
  Future<ActiveRide?> getCurrentActiveRide(String driverId) async {
    return null;
  }

  @override
  Future<void> saveActiveRide(ActiveRide ride) async {
    // Mock implementation
  }

  @override
  Future<void> clearActiveRide() async {
    // Mock implementation
  }

  @override
  Future<DriverAppSettings?> getAppSettings(String driverId) async {
    return null;
  }

  @override
  Future<void> saveAppSettings(String driverId, DriverAppSettings settings) async {
    // Mock implementation
  }

  @override
  Future<NotificationSettings?> getNotificationSettings(String driverId) async {
    return null;
  }

  @override
  Future<void> saveNotificationSettings(String driverId, NotificationSettings settings) async {
    // Mock implementation
  }

  @override
  Future<void> clearAllCache(String driverId) async {
    // Mock implementation
  }

  @override
  Future<bool> hasValidCache(String driverId) async {
    return false;
  }
}