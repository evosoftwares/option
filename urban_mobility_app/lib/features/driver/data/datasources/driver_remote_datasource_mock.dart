import '../../domain/models/driver_profile.dart';
import '../../domain/models/driver_work_config.dart';
import '../../domain/models/driver_status.dart' hide DriverLocation;
import '../../domain/models/ride_request.dart' hide VehicleCategory;
import '../../domain/models/active_ride.dart';
import '../../domain/models/driver_documents.dart';
import '../../domain/models/vehicle_info.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_remote_datasource.dart';

/// Implementação mock do DriverRemoteDatasource para desenvolvimento
class DriverRemoteDatasourceMock implements DriverRemoteDatasource {
  @override
  Future<DriverProfile?> getDriverProfile(String driverId) async {
    return null; // Mock implementation
  }

  @override
  Future<void> updateDriverProfile(DriverProfile profile) async {
    // Mock implementation
  }

  @override
  Future<String> createDriverProfile(DriverProfile profile) async {
    return 'mock-profile-id';
  }

  @override
  Future<void> updatePersonalInfo(String driverId, PersonalInfo personalInfo) async {
    // Mock implementation
  }

  @override
  Future<void> updateVehicleInfo(String driverId, VehicleInfo vehicleInfo) async {
    // Mock implementation
  }

  @override
  Future<void> updateDriverDocuments(String driverId, DriverDocuments documents) async {
    // Mock implementation
  }

  @override
  Future<String> uploadDocumentPhoto(String driverId, String documentType, String filePath) async {
    return 'mock-photo-url';
  }

  @override
  Future<void> submitDocumentsForVerification(String driverId) async {
    // Mock implementation
  }

  @override
  Future<DriverWorkConfig?> getWorkConfig(String driverId) async {
    return null; // Mock implementation
  }

  @override
  Future<void> updateWorkConfig(String driverId, DriverWorkConfig config) async {
    // Mock implementation
  }

  @override
  Future<void> updatePricingConfig(String driverId, PricingConfig pricing) async {
    // Mock implementation
  }

  @override
  Future<void> updateServiceFees(String driverId, ServiceFees fees) async {
    // Mock implementation
  }

  @override
  Future<void> addWorkingArea(String driverId, WorkingArea area) async {
    // Mock implementation
  }

  @override
  Future<void> removeWorkingArea(String driverId, String areaId) async {
    // Mock implementation
  }

  @override
  Future<DriverStatus> getDriverStatus(String driverId) async {
    return DriverStatus.offline;
  }

  @override
  Future<void> updateDriverStatus(String driverId, DriverStatus status) async {
    // Mock implementation
  }

  @override
  Future<void> goOnline(String driverId, DriverLocation location) async {
    // Mock implementation
  }

  @override
  Future<void> goOffline(String driverId) async {
    // Mock implementation
  }

  @override
  Future<void> pauseActivity(String driverId, String reason) async {
    // Mock implementation
  }

  @override
  Future<void> resumeActivity(String driverId) async {
    // Mock implementation
  }

  @override
  Future<void> updateLocation(String driverId, DriverLocation location) async {
    // Mock implementation
  }

  @override
  Future<List<DriverStatusHistory>> getStatusHistory(String driverId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    return [];
  }

  @override
  Stream<List<RideRequest>> getPendingRideRequests(String driverId) {
    return Stream.value([]);
  }

  @override
  Future<ActiveRide> acceptRideRequest(String driverId, String requestId) async {
    throw UnimplementedError('Mock implementation');
  }

  @override
  Future<void> rejectRideRequest(String driverId, String requestId, String reason) async {
    // Mock implementation
  }

  @override
  Future<RideRequest?> getRideRequestDetails(String requestId) async {
    return null;
  }

  @override
  Future<ActiveRide?> getCurrentActiveRide(String driverId) async {
    return null;
  }

  @override
  Future<void> updateActiveRideStatus(String rideId, ActiveRideStatus status) async {
    // Mock implementation
  }

  @override
  Future<void> markArrivedAtPickup(String rideId) async {
    // Mock implementation
  }

  @override
  Future<void> markPassengerPickedUp(String rideId) async {
    // Mock implementation
  }

  @override
  Future<void> markArrivedAtDestination(String rideId) async {
    // Mock implementation
  }

  @override
  Future<void> completeRide(String rideId, {
    required double finalPrice,
    double? actualDistance,
    int? actualDuration,
    int? waitingTime,
    String? notes,
  }) async {
    // Mock implementation
  }

  @override
  Future<void> cancelRide(String rideId, String reason) async {
    // Mock implementation
  }

  @override
  Future<void> addExtraStop(String rideId, RideLocation stop) async {
    // Mock implementation
  }

  @override
  Future<void> updateRideRoute(String rideId, RideRoute route) async {
    // Mock implementation
  }

  @override
  Future<List<ActiveRide>> getRideHistory(String driverId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    return [];
  }

  @override
  Future<DriverStatistics> getDriverStatistics(String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    throw UnimplementedError('Mock implementation');
  }

  @override
  Future<DriverEarnings> getDriverEarnings(String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    throw UnimplementedError('Mock implementation');
  }

  @override
  Future<List<DriverRating>> getDriverRatings(String driverId, {
    int? limit,
    int? offset,
  }) async {
    return [];
  }

  @override
  Future<List<DriverNotification>> getNotifications(String driverId, {
    bool? unreadOnly,
    int? limit,
  }) async {
    return [];
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    // Mock implementation
  }

  @override
  Future<void> markAllNotificationsAsRead(String driverId) async {
    // Mock implementation
  }

  @override
  Future<DriverAppSettings> getAppSettings(String driverId) async {
    throw UnimplementedError('Mock implementation');
  }

  @override
  Future<void> updateAppSettings(String driverId, DriverAppSettings settings) async {
    // Mock implementation
  }

  @override
  Future<NotificationSettings> getNotificationSettings(String driverId) async {
    throw UnimplementedError('Mock implementation');
  }

  @override
  Future<void> updateNotificationSettings(String driverId, NotificationSettings settings) async {
    // Mock implementation
  }
}