import '../../domain/models/driver_profile.dart';
import '../../domain/models/driver_work_config.dart';
import '../../domain/models/driver_status.dart' hide DriverLocation;
import '../../domain/models/ride_request.dart' hide VehicleCategory;
import '../../domain/models/active_ride.dart';
import '../../domain/models/driver_documents.dart';
import '../../domain/models/vehicle_info.dart';
import '../../domain/repositories/driver_repository.dart';

/// Interface para operações remotas (API) do motorista
abstract class DriverRemoteDatasource {
  // ========== Gestão de Perfil ==========
  Future<DriverProfile?> getDriverProfile(String driverId);
  Future<void> updateDriverProfile(DriverProfile profile);
  Future<String> createDriverProfile(DriverProfile profile);
  Future<void> updatePersonalInfo(String driverId, PersonalInfo personalInfo);
  Future<void> updateVehicleInfo(String driverId, VehicleInfo vehicleInfo);
  Future<void> updateDriverDocuments(
    String driverId,
    DriverDocuments documents,
  );
  Future<String> uploadDocumentPhoto(
    String driverId,
    String documentType,
    String filePath,
  );
  Future<void> submitDocumentsForVerification(String driverId);

  // ========== Configuração de Trabalho ==========
  Future<DriverWorkConfig?> getWorkConfig(String driverId);
  Future<void> updateWorkConfig(String driverId, DriverWorkConfig config);
  Future<void> updatePricingConfig(String driverId, PricingConfig pricing);
  Future<void> updateServiceFees(String driverId, ServiceFees fees);
  Future<void> addWorkingArea(String driverId, WorkingArea area);
  Future<void> removeWorkingArea(String driverId, String areaId);

  // ========== Gestão de Status ==========
  Future<DriverStatus> getDriverStatus(String driverId);
  Future<void> updateDriverStatus(String driverId, DriverStatus status);
  Future<void> goOnline(String driverId, DriverLocation location);
  Future<void> goOffline(String driverId);
  Future<void> pauseActivity(String driverId, String reason);
  Future<void> resumeActivity(String driverId);
  Future<void> updateLocation(String driverId, DriverLocation location);
  Future<List<DriverStatusHistory>> getStatusHistory(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  // ========== Solicitações de Viagem ==========
  Stream<List<RideRequest>> getPendingRideRequests(String driverId);
  Future<ActiveRide> acceptRideRequest(String driverId, String requestId);
  Future<void> rejectRideRequest(
    String driverId,
    String requestId,
    String reason,
  );
  Future<RideRequest?> getRideRequestDetails(String requestId);

  // ========== Viagens Ativas ==========
  Future<ActiveRide?> getCurrentActiveRide(String driverId);
  Future<void> updateActiveRideStatus(String rideId, ActiveRideStatus status);
  Future<void> markArrivedAtPickup(String rideId);
  Future<void> markPassengerPickedUp(String rideId);
  Future<void> markArrivedAtDestination(String rideId);
  Future<void> completeRide(
    String rideId, {
    required double finalPrice,
    double? actualDistance,
    int? actualDuration,
    int? waitingTime,
    String? notes,
  });
  Future<void> cancelRide(String rideId, String reason);
  Future<void> addExtraStop(String rideId, RideLocation stop);
  Future<void> updateRideRoute(String rideId, RideRoute route);

  // ========== Histórico e Relatórios ==========
  Future<List<ActiveRide>> getRideHistory(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });
  Future<DriverStatistics> getDriverStatistics(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<DriverEarnings> getDriverEarnings(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<DriverRating>> getDriverRatings(
    String driverId, {
    int? limit,
    int? offset,
  });

  // ========== Notificações ==========
  Future<List<DriverNotification>> getNotifications(
    String driverId, {
    bool? unreadOnly,
    int? limit,
  });
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> markAllNotificationsAsRead(String driverId);

  // ========== Configurações ==========
  Future<DriverAppSettings> getAppSettings(String driverId);
  Future<void> updateAppSettings(String driverId, DriverAppSettings settings);
  Future<NotificationSettings> getNotificationSettings(String driverId);
  Future<void> updateNotificationSettings(
    String driverId,
    NotificationSettings settings,
  );
}
