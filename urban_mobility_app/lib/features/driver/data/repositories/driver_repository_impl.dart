import '../../domain/models/driver_profile.dart';
import '../../domain/models/driver_work_config.dart';
import '../../domain/models/driver_status.dart' hide DriverLocation;
import '../../domain/models/ride_request.dart' hide VehicleCategory;
import '../../domain/models/active_ride.dart';
import '../../domain/models/driver_documents.dart';
import '../../domain/models/vehicle_info.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_datasource.dart';
import '../datasources/driver_local_datasource.dart';

/// Implementação do repositório do motorista seguindo Clean Architecture
class DriverRepositoryImpl implements DriverRepository {
  const DriverRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  final DriverRemoteDatasource remoteDatasource;
  final DriverLocalDatasource localDatasource;

  // ========== Gestão de Perfil (Seção 4.1) ==========

  @override
  Future<DriverProfile?> getDriverProfile(String driverId) async {
    try {
      // Tentar buscar do cache local primeiro
      final cachedProfile = await localDatasource.getDriverProfile(driverId);
      if (cachedProfile != null) {
        return cachedProfile;
      }

      // Buscar do servidor
      final profile = await remoteDatasource.getDriverProfile(driverId);
      if (profile != null) {
        // Salvar no cache
        await localDatasource.saveDriverProfile(profile);
      }
      return profile;
    } catch (e) {
      // Em caso de erro, tentar retornar do cache
      return await localDatasource.getDriverProfile(driverId);
    }
  }

  @override
  Future<void> updateDriverProfile(DriverProfile profile) async {
    await remoteDatasource.updateDriverProfile(profile);
    await localDatasource.saveDriverProfile(profile);
  }

  @override
  Future<String> createDriverProfile(DriverProfile profile) async {
    final profileId = await remoteDatasource.createDriverProfile(profile);
    final updatedProfile = profile.copyWith(id: profileId);
    await localDatasource.saveDriverProfile(updatedProfile);
    return profileId;
  }

  @override
  Future<void> updatePersonalInfo(
    String driverId,
    PersonalInfo personalInfo,
  ) async {
    await remoteDatasource.updatePersonalInfo(driverId, personalInfo);

    // Atualizar cache local
    final cachedProfile = await localDatasource.getDriverProfile(driverId);
    if (cachedProfile != null) {
      final updatedProfile = cachedProfile.copyWith(personalInfo: personalInfo);
      await localDatasource.saveDriverProfile(updatedProfile);
    }
  }

  @override
  Future<void> updateVehicleInfo(
    String driverId,
    VehicleInfo vehicleInfo,
  ) async {
    await remoteDatasource.updateVehicleInfo(driverId, vehicleInfo);

    // Atualizar cache local
    final cachedProfile = await localDatasource.getDriverProfile(driverId);
    if (cachedProfile != null) {
      final updatedProfile = cachedProfile.copyWith(vehicleInfo: vehicleInfo);
      await localDatasource.saveDriverProfile(updatedProfile);
    }
  }

  @override
  Future<void> updateDriverDocuments(
    String driverId,
    DriverDocuments documents,
  ) async {
    await remoteDatasource.updateDriverDocuments(driverId, documents);

    // Atualizar cache local
    final cachedProfile = await localDatasource.getDriverProfile(driverId);
    if (cachedProfile != null) {
      final updatedProfile = cachedProfile.copyWith(documents: documents);
      await localDatasource.saveDriverProfile(updatedProfile);
    }
  }

  @override
  Future<String> uploadDocumentPhoto(
    String driverId,
    String documentType,
    String filePath,
  ) async {
    return await remoteDatasource.uploadDocumentPhoto(
      driverId,
      documentType,
      filePath,
    );
  }

  @override
  Future<void> submitDocumentsForVerification(String driverId) async {
    await remoteDatasource.submitDocumentsForVerification(driverId);
  }

  // ========== Configuração de Trabalho (Seção 4.2) ==========

  @override
  Future<DriverWorkConfig?> getWorkConfig(String driverId) async {
    try {
      final config = await remoteDatasource.getWorkConfig(driverId);
      if (config != null) {
        await localDatasource.saveWorkConfig(driverId, config);
      }
      return config;
    } catch (e) {
      return await localDatasource.getWorkConfig(driverId);
    }
  }

  @override
  Future<void> updateWorkConfig(
    String driverId,
    DriverWorkConfig config,
  ) async {
    await remoteDatasource.updateWorkConfig(driverId, config);
    await localDatasource.saveWorkConfig(driverId, config);
  }

  @override
  Future<void> updatePricingConfig(
    String driverId,
    PricingConfig pricing,
  ) async {
    await remoteDatasource.updatePricingConfig(driverId, pricing);
  }

  @override
  Future<void> updateServiceFees(String driverId, ServiceFees fees) async {
    await remoteDatasource.updateServiceFees(driverId, fees);
  }

  @override
  Future<void> addWorkingArea(String driverId, WorkingArea area) async {
    await remoteDatasource.addWorkingArea(driverId, area);
  }

  @override
  Future<void> removeWorkingArea(String driverId, String areaId) async {
    await remoteDatasource.removeWorkingArea(driverId, areaId);
  }

  // ========== Gestão de Status (Seção 4.3) ==========

  @override
  Future<DriverStatus> getDriverStatus(String driverId) async {
    try {
      final status = await remoteDatasource.getDriverStatus(driverId);
      await localDatasource.saveDriverStatus(driverId, status);
      return status;
    } catch (e) {
      final cachedStatus = await localDatasource.getDriverStatus(driverId);
      return cachedStatus ?? DriverStatus.offline;
    }
  }

  @override
  Future<void> updateDriverStatus(String driverId, DriverStatus status) async {
    await remoteDatasource.updateDriverStatus(driverId, status);
    await localDatasource.saveDriverStatus(driverId, status);
  }

  @override
  Future<void> goOnline(String driverId, DriverLocation location) async {
    await remoteDatasource.goOnline(driverId, location);
    await localDatasource.saveDriverStatus(driverId, DriverStatus.online);
    await localDatasource.saveLastLocation(driverId, location);
  }

  @override
  Future<void> goOffline(String driverId) async {
    await remoteDatasource.goOffline(driverId);
    await localDatasource.saveDriverStatus(driverId, DriverStatus.offline);
  }

  @override
  Future<void> pauseActivity(String driverId, String reason) async {
    await remoteDatasource.pauseActivity(driverId, reason);
    await localDatasource.saveDriverStatus(driverId, DriverStatus.paused);
  }

  @override
  Future<void> resumeActivity(String driverId) async {
    await remoteDatasource.resumeActivity(driverId);
    await localDatasource.saveDriverStatus(driverId, DriverStatus.online);
  }

  @override
  Future<void> updateLocation(String driverId, DriverLocation location) async {
    await remoteDatasource.updateLocation(driverId, location);
    await localDatasource.saveLastLocation(driverId, location);
  }

  @override
  Future<List<DriverStatusHistory>> getStatusHistory(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    return await remoteDatasource.getStatusHistory(
      driverId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  // ========== Solicitações de Viagem (Seção 4.4) ==========

  @override
  Stream<List<RideRequest>> getPendingRideRequests(String driverId) {
    return remoteDatasource.getPendingRideRequests(driverId);
  }

  @override
  Future<ActiveRide> acceptRideRequest(
    String driverId,
    String requestId,
  ) async {
    final activeRide = await remoteDatasource.acceptRideRequest(
      driverId,
      requestId,
    );
    await localDatasource.saveActiveRide(activeRide);
    await localDatasource.saveDriverStatus(driverId, DriverStatus.onTrip);
    return activeRide;
  }

  @override
  Future<void> rejectRideRequest(
    String driverId,
    String requestId,
    String reason,
  ) async {
    await remoteDatasource.rejectRideRequest(driverId, requestId, reason);
  }

  @override
  Future<RideRequest?> getRideRequestDetails(String requestId) async {
    return await remoteDatasource.getRideRequestDetails(requestId);
  }

  // ========== Viagens Ativas (Seção 4.5) ==========

  @override
  Future<ActiveRide?> getCurrentActiveRide(String driverId) async {
    try {
      final activeRide = await remoteDatasource.getCurrentActiveRide(driverId);
      if (activeRide != null) {
        await localDatasource.saveActiveRide(activeRide);
      }
      return activeRide;
    } catch (e) {
      return await localDatasource.getCurrentActiveRide(driverId);
    }
  }

  @override
  Future<void> updateActiveRideStatus(
    String rideId,
    ActiveRideStatus status,
  ) async {
    await remoteDatasource.updateActiveRideStatus(rideId, status);
  }

  @override
  Future<void> markArrivedAtPickup(String rideId) async {
    await remoteDatasource.markArrivedAtPickup(rideId);
  }

  @override
  Future<void> markPassengerPickedUp(String rideId) async {
    await remoteDatasource.markPassengerPickedUp(rideId);
  }

  @override
  Future<void> markArrivedAtDestination(String rideId) async {
    await remoteDatasource.markArrivedAtDestination(rideId);
  }

  @override
  Future<void> completeRide(
    String rideId, {
    required double finalPrice,
    double? actualDistance,
    int? actualDuration,
    int? waitingTime,
    String? notes,
  }) async {
    await remoteDatasource.completeRide(
      rideId,
      finalPrice: finalPrice,
      actualDistance: actualDistance,
      actualDuration: actualDuration,
      waitingTime: waitingTime,
      notes: notes,
    );

    // Limpar viagem ativa do cache
    await localDatasource.clearActiveRide();
  }

  @override
  Future<void> cancelRide(String rideId, String reason) async {
    await remoteDatasource.cancelRide(rideId, reason);
    await localDatasource.clearActiveRide();
  }

  @override
  Future<void> addExtraStop(String rideId, RideLocation stop) async {
    await remoteDatasource.addExtraStop(rideId, stop);
  }

  @override
  Future<void> updateRideRoute(String rideId, RideRoute route) async {
    await remoteDatasource.updateRideRoute(rideId, route);
  }

  // ========== Histórico e Relatórios (Seção 4.6) ==========

  @override
  Future<List<ActiveRide>> getRideHistory(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    return await remoteDatasource.getRideHistory(
      driverId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<DriverStatistics> getDriverStatistics(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await remoteDatasource.getDriverStatistics(
      driverId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<DriverEarnings> getDriverEarnings(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await remoteDatasource.getDriverEarnings(
      driverId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<DriverRating>> getDriverRatings(
    String driverId, {
    int? limit,
    int? offset,
  }) async {
    return await remoteDatasource.getDriverRatings(
      driverId,
      limit: limit,
      offset: offset,
    );
  }

  // ========== Notificações ==========

  @override
  Future<List<DriverNotification>> getNotifications(
    String driverId, {
    bool? unreadOnly,
    int? limit,
  }) async {
    return await remoteDatasource.getNotifications(
      driverId,
      unreadOnly: unreadOnly,
      limit: limit,
    );
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await remoteDatasource.markNotificationAsRead(notificationId);
  }

  @override
  Future<void> markAllNotificationsAsRead(String driverId) async {
    await remoteDatasource.markAllNotificationsAsRead(driverId);
  }

  // ========== Configurações ==========

  @override
  Future<DriverAppSettings> getAppSettings(String driverId) async {
    try {
      final settings = await remoteDatasource.getAppSettings(driverId);
      await localDatasource.saveAppSettings(driverId, settings);
      return settings;
    } catch (e) {
      final cachedSettings = await localDatasource.getAppSettings(driverId);
      return cachedSettings ?? _getDefaultAppSettings();
    }
  }

  @override
  Future<void> updateAppSettings(
    String driverId,
    DriverAppSettings settings,
  ) async {
    await remoteDatasource.updateAppSettings(driverId, settings);
    await localDatasource.saveAppSettings(driverId, settings);
  }

  @override
  Future<NotificationSettings> getNotificationSettings(String driverId) async {
    try {
      final settings = await remoteDatasource.getNotificationSettings(driverId);
      await localDatasource.saveNotificationSettings(driverId, settings);
      return settings;
    } catch (e) {
      final cachedSettings = await localDatasource.getNotificationSettings(
        driverId,
      );
      return cachedSettings ?? _getDefaultNotificationSettings();
    }
  }

  @override
  Future<void> updateNotificationSettings(
    String driverId,
    NotificationSettings settings,
  ) async {
    await remoteDatasource.updateNotificationSettings(driverId, settings);
    await localDatasource.saveNotificationSettings(driverId, settings);
  }

  // Métodos auxiliares para configurações padrão
  DriverAppSettings _getDefaultAppSettings() {
    return const DriverAppSettings(
      language: 'pt_BR',
      theme: 'light',
      mapStyle: 'standard',
      voiceNavigation: true,
      autoAcceptRides: false,
      maxDistanceForRides: 10.0,
      preferredVehicleCategories: [VehicleCategory.car],
    );
  }

  NotificationSettings _getDefaultNotificationSettings() {
    return const NotificationSettings(
      rideRequests: true,
      rideUpdates: true,
      payments: true,
      documents: true,
      system: true,
      promotions: false,
      sound: true,
      vibration: true,
    );
  }
}
