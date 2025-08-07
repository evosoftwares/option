import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/driver_profile.dart';
import '../../domain/models/driver_work_config.dart';
import '../../domain/models/driver_status.dart' hide DriverLocation;
import '../../domain/models/active_ride.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_local_datasource.dart';

/// Implementação real do datasource local do motorista usando SharedPreferences
class DriverLocalDatasourceImpl implements DriverLocalDatasource {
  DriverLocalDatasourceImpl(this._prefs);

  final SharedPreferences _prefs;

  String _getKey(String prefix, String driverId) => '${prefix}_$driverId';

  // ========== Cache de Perfil ==========
  @override
  Future<DriverProfile?> getDriverProfile(String driverId) async {
    try {
      final key = _getKey('driver_profile', driverId);
      final profileJson = _prefs.getString(key);
      if (profileJson == null) return null;

      final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
      return DriverProfile.fromJson(profileData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveDriverProfile(DriverProfile profile) async {
    final key = _getKey('driver_profile', profile.id);
    final profileJson = jsonEncode(profile.toJson());
    await _prefs.setString(key, profileJson);
  }

  @override
  Future<void> clearDriverProfile(String driverId) async {
    final key = _getKey('driver_profile', driverId);
    await _prefs.remove(key);
  }

  // ========== Cache de Configuração ==========
  @override
  Future<DriverWorkConfig?> getWorkConfig(String driverId) async {
    try {
      final key = _getKey('work_config', driverId);
      final configJson = _prefs.getString(key);
      if (configJson == null) return null;

      final configData = jsonDecode(configJson) as Map<String, dynamic>;
      return DriverWorkConfig.fromJson(configData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveWorkConfig(String driverId, DriverWorkConfig config) async {
    final key = _getKey('work_config', driverId);
    final configJson = jsonEncode(config.toJson());
    await _prefs.setString(key, configJson);
  }

  @override
  Future<void> clearWorkConfig(String driverId) async {
    final key = _getKey('work_config', driverId);
    await _prefs.remove(key);
  }

  // ========== Cache de Status ==========
  @override
  Future<DriverStatus?> getDriverStatus(String driverId) async {
    try {
      final key = _getKey('driver_status', driverId);
      final statusName = _prefs.getString(key);
      if (statusName == null) return null;

      return DriverStatus.values.firstWhere(
        (status) => status.name == statusName,
        orElse: () => DriverStatus.offline,
      );
    } catch (e) {
      return DriverStatus.offline;
    }
  }

  @override
  Future<void> saveDriverStatus(String driverId, DriverStatus status) async {
    final key = _getKey('driver_status', driverId);
    await _prefs.setString(key, status.name);
  }

  @override
  Future<DriverLocation?> getLastLocation(String driverId) async {
    try {
      final key = _getKey('last_location', driverId);
      final locationJson = _prefs.getString(key);
      if (locationJson == null) return null;

      final locationData = jsonDecode(locationJson) as Map<String, dynamic>;
      return DriverLocation.fromJson(locationData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveLastLocation(String driverId, DriverLocation location) async {
    final key = _getKey('last_location', driverId);
    final locationJson = jsonEncode(location.toJson());
    await _prefs.setString(key, locationJson);
  }

  // ========== Cache de Viagem Ativa ==========
  @override
  Future<ActiveRide?> getCurrentActiveRide(String driverId) async {
    try {
      final key = _getKey('active_ride', driverId);
      final rideJson = _prefs.getString(key);
      if (rideJson == null) return null;

      final rideData = jsonDecode(rideJson) as Map<String, dynamic>;
      return ActiveRide.fromJson(rideData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveActiveRide(ActiveRide ride) async {
    final key = _getKey('active_ride', ride.driverId);
    final rideJson = jsonEncode(ride.toJson());
    await _prefs.setString(key, rideJson);
  }

  @override
  Future<void> clearActiveRide() async {
    // Remove todas as viagens ativas (pode haver múltiplos drivers)
    final keys = _prefs.getKeys().where((key) => key.startsWith('active_ride_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  // ========== Cache de Configurações ==========
  @override
  Future<DriverAppSettings?> getAppSettings(String driverId) async {
    try {
      final key = _getKey('app_settings', driverId);
      final settingsJson = _prefs.getString(key);
      if (settingsJson == null) return null;

      final settingsData = jsonDecode(settingsJson) as Map<String, dynamic>;
      return DriverAppSettings.fromJson(settingsData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveAppSettings(String driverId, DriverAppSettings settings) async {
    final key = _getKey('app_settings', driverId);
    final settingsJson = jsonEncode(settings.toJson());
    await _prefs.setString(key, settingsJson);
  }

  @override
  Future<NotificationSettings?> getNotificationSettings(String driverId) async {
    try {
      final key = _getKey('notification_settings', driverId);
      final settingsJson = _prefs.getString(key);
      if (settingsJson == null) return null;

      final settingsData = jsonDecode(settingsJson) as Map<String, dynamic>;
      return NotificationSettings.fromJson(settingsData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveNotificationSettings(
    String driverId,
    NotificationSettings settings,
  ) async {
    final key = _getKey('notification_settings', driverId);
    final settingsJson = jsonEncode(settings.toJson());
    await _prefs.setString(key, settingsJson);
  }

  // ========== Operações Gerais ==========
  @override
  Future<void> clearAllCache(String driverId) async {
    final keysToRemove = _prefs.getKeys().where((key) => key.endsWith('_$driverId'));
    await Future.wait(keysToRemove.map((key) => _prefs.remove(key)));
  }

  @override
  Future<bool> hasValidCache(String driverId) async {
    final profile = await getDriverProfile(driverId);
    return profile != null;
  }
}