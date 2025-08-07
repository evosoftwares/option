import 'dart:async';
import 'dart:math';

import '../../domain/models/driver_profile.dart';
import '../../domain/models/driver_work_config.dart';
import '../../domain/models/driver_status.dart';
import '../../domain/models/ride_request.dart' as ride_models;
import '../../domain/models/active_ride.dart';
import '../../domain/models/driver_verification_status.dart';
import '../../domain/models/driver_documents.dart';
import '../../domain/models/vehicle_info.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_remote_datasource.dart';

/// Implementação mock do datasource remoto do motorista
class DriverRemoteDatasourceImpl implements DriverRemoteDatasource {
  final Random _random = Random();

  // Dados em memória para simulação
  final Map<String, DriverProfile> _driverProfiles = {};
  final Map<String, DriverWorkConfig> _workConfigs = {};
  final Map<String, DriverStatus> _driverStatuses = {};
  final Map<String, List<ride_models.RideRequest>> _pendingRequests = {};
  final Map<String, ActiveRide?> _activeRides = {};
  final Map<String, List<ActiveRide>> _rideHistory = {};
  final Map<String, DriverStatistics> _driverStats = {};
  final Map<String, DriverEarnings> _driverEarnings = {};
  final Map<String, List<DriverRating>> _driverRatings = {};
  final Map<String, List<DriverNotification>> _notifications = {};
  final Map<String, DriverAppSettings> _appSettings = {};
  final Map<String, NotificationSettings> _notificationSettings = {};

  @override
  Future<DriverProfile?> getDriverProfile(String driverId) async {
    await _simulateNetworkDelay();
    return _driverProfiles[driverId] ?? _createMockDriverProfile(driverId);
  }

  @override
  Future<void> updateDriverProfile(DriverProfile profile) async {
    await _simulateNetworkDelay();
    _driverProfiles[profile.id] = profile;
  }

  @override
  Future<String> createDriverProfile(DriverProfile profile) async {
    await _simulateNetworkDelay();
    final id = 'driver_${DateTime.now().millisecondsSinceEpoch}';
    final newProfile = profile.copyWith(id: id);
    _driverProfiles[id] = newProfile;
    return id;
  }

  @override
  Future<void> updatePersonalInfo(
    String driverId,
    PersonalInfo personalInfo,
  ) async {
    await _simulateNetworkDelay();
    final profile = _driverProfiles[driverId];
    if (profile != null) {
      _driverProfiles[driverId] = profile.copyWith(personalInfo: personalInfo);
    }
  }

  @override
  Future<void> updateVehicleInfo(
    String driverId,
    VehicleInfo vehicleInfo,
  ) async {
    await _simulateNetworkDelay();
    final profile = _driverProfiles[driverId];
    if (profile != null) {
      _driverProfiles[driverId] = profile.copyWith(vehicleInfo: vehicleInfo);
    }
  }

  @override
  Future<DriverWorkConfig?> getWorkConfig(String driverId) async {
    await _simulateNetworkDelay();
    return _workConfigs[driverId] ?? _createMockWorkConfig();
  }

  @override
  Future<void> updateWorkConfig(
    String driverId,
    DriverWorkConfig config,
  ) async {
    await _simulateNetworkDelay();
    _workConfigs[driverId] = config;
  }

  @override
  Future<DriverStatus> getDriverStatus(String driverId) async {
    await _simulateNetworkDelay();
    return _driverStatuses[driverId] ?? DriverStatus.offline;
  }

  @override
  Future<void> updateDriverStatus(String driverId, DriverStatus status) async {
    await _simulateNetworkDelay();
    _driverStatuses[driverId] = status;
  }

  @override
  Future<void> goOnline(String driverId, DriverLocation location) async {
    await _simulateNetworkDelay();
    _driverStatuses[driverId] = DriverStatus.online;
  }

  @override
  Future<void> goOffline(String driverId) async {
    await _simulateNetworkDelay();
    _driverStatuses[driverId] = DriverStatus.offline;
  }

  @override
  Future<void> pauseActivity(String driverId, String reason) async {
    await _simulateNetworkDelay();
    _driverStatuses[driverId] = DriverStatus.paused;
  }

  @override
  Future<void> resumeActivity(String driverId) async {
    await _simulateNetworkDelay();
    _driverStatuses[driverId] = DriverStatus.online;
  }

  @override
  Future<void> updateLocation(String driverId, DriverLocation location) async {
    await _simulateNetworkDelay();
    // Simula atualização de localização
  }

  @override
  Stream<List<ride_models.RideRequest>> getPendingRideRequests(
    String driverId,
  ) {
    return Stream.periodic(const Duration(seconds: 5), (_) {
      final status = _driverStatuses[driverId] ?? DriverStatus.offline;
      if (status == DriverStatus.online && _random.nextBool()) {
        return [_createMockRideRequest()];
      }
      return <ride_models.RideRequest>[];
    });
  }

  @override
  Future<ActiveRide> acceptRideRequest(
    String driverId,
    String requestId,
  ) async {
    await _simulateNetworkDelay();
    final activeRide = _createMockActiveRide(driverId, requestId);
    _activeRides[driverId] = activeRide;
    _driverStatuses[driverId] = DriverStatus.onTrip;
    return activeRide;
  }

  @override
  Future<void> rejectRideRequest(
    String driverId,
    String requestId,
    String reason,
  ) async {
    await _simulateNetworkDelay();
    // Remove da lista de pendentes
  }

  @override
  Future<ActiveRide?> getCurrentActiveRide(String driverId) async {
    await _simulateNetworkDelay();
    return _activeRides[driverId];
  }

  @override
  Future<void> updateActiveRideStatus(
    String rideId,
    ActiveRideStatus status,
  ) async {
    await _simulateNetworkDelay();
    // Atualiza status da viagem ativa
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
    await _simulateNetworkDelay();
    // Finaliza a viagem
  }

  @override
  Future<List<ActiveRide>> getRideHistory(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    await _simulateNetworkDelay();
    return _rideHistory[driverId] ?? [];
  }

  @override
  Future<DriverStatistics> getDriverStatistics(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _simulateNetworkDelay();
    return _driverStats[driverId] ?? _createMockDriverStatistics();
  }

  @override
  Future<DriverEarnings> getDriverEarnings(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _simulateNetworkDelay();
    return _driverEarnings[driverId] ?? _createMockDriverEarnings();
  }

  @override
  Future<List<DriverRating>> getDriverRatings(
    String driverId, {
    int? limit,
    int? offset,
  }) async {
    await _simulateNetworkDelay();
    return _driverRatings[driverId] ?? [];
  }

  @override
  Future<List<DriverNotification>> getNotifications(
    String driverId, {
    bool? unreadOnly,
    int? limit,
  }) async {
    await _simulateNetworkDelay();
    var notifications = _notifications[driverId] ?? [];
    if (unreadOnly == true) {
      notifications = notifications.where((n) => !n.isRead).toList();
    }
    if (limit != null) {
      notifications = notifications.take(limit).toList();
    }
    return notifications;
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await _simulateNetworkDelay();
    // Marca notificação como lida
  }

  @override
  Future<DriverAppSettings> getAppSettings(String driverId) async {
    await _simulateNetworkDelay();
    return _appSettings[driverId] ?? _getDefaultAppSettings();
  }

  @override
  Future<void> updateAppSettings(
    String driverId,
    DriverAppSettings settings,
  ) async {
    await _simulateNetworkDelay();
    _appSettings[driverId] = settings;
  }

  @override
  Future<NotificationSettings> getNotificationSettings(String driverId) async {
    await _simulateNetworkDelay();
    return _notificationSettings[driverId] ?? _getDefaultNotificationSettings();
  }

  @override
  Future<void> updateNotificationSettings(
    String driverId,
    NotificationSettings settings,
  ) async {
    await _simulateNetworkDelay();
    _notificationSettings[driverId] = settings;
  }

  // Métodos auxiliares para criar dados mock
  DriverProfile _createMockDriverProfile(String driverId) {
    return DriverProfile(
      id: driverId,
      personalInfo: PersonalInfo(
        name: 'João Silva',
        email: 'joao.silva@email.com',
        phone: '+5511999999999',
      ),
      vehicleInfo: VehicleInfo(
        brand: 'Toyota',
        model: 'Corolla',
        year: 2020,
        color: 'Branco',
        licensePlate: 'ABC-1234',
        category: VehicleCategory.car,
      ),
      documents: DriverDocuments.empty(),
      verificationStatus: DriverVerificationStatus.approved,
      workConfig: DriverWorkConfig.defaultConfig(),
      isOnline: false,
      joinDate: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  DriverWorkConfig _createMockWorkConfig() {
    return DriverWorkConfig(
      pricingConfig: PricingConfig(
        useCustomPricing: false,
        basePricePerKm: 2.5,
        timeMultiplier: 0.5,
        minimumFare: 8.0,
      ),
      serviceFees: ServiceFees(
        petTransport: PetTransportService(isActive: false, fee: 5.0),
        trunkService: TrunkService(isActive: false, fee: 3.0),
        condominiumAccess: CondominiumAccessService(isActive: false, fee: 2.0),
        stopService: StopService(isActive: false, fee: 1.0),
        airConditioningPolicy: AirConditioningPolicy.onRequest,
        airConditioningFee: 2.0,
      ),
      workingAreas: [],
      isActive: true,
    );
  }

  ride_models.RideRequest _createMockRideRequest() {
    return ride_models.RideRequest(
      id: 'request_${DateTime.now().millisecondsSinceEpoch}',
      passengerId: 'passenger_123',
      passengerName: 'Maria Santos',
      passengerPhone: '+5511888888888',
      pickupLocation: ride_models.RideLocation(
        latitude: -23.5505,
        longitude: -46.6333,
        address: 'Av. Paulista, 1000 - São Paulo, SP',
      ),
      destinationLocation: ride_models.RideLocation(
        latitude: -23.5629,
        longitude: -46.6544,
        address: 'Shopping Ibirapuera - São Paulo, SP',
      ),
      estimatedDistance: 5.2,
      estimatedDuration: 15,
      estimatedPrice: 18.50,
      vehicleCategory: ride_models.VehicleCategory.carroComum,
      status: ride_models.RideRequestStatus.pending,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 2)),
    );
  }

  ActiveRide _createMockActiveRide(String driverId, String requestId) {
    return ActiveRide(
      id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
      rideRequestId: requestId,
      driverId: driverId,
      passengerId: 'passenger_123',
      passengerName: 'Maria Santos',
      passengerPhone: '+5511888888888',
      pickupLocation: ride_models.RideLocation(
        latitude: -23.5505,
        longitude: -46.6333,
        address: 'Av. Paulista, 1000 - São Paulo, SP',
      ),
      destinationLocation: ride_models.RideLocation(
        latitude: -23.5629,
        longitude: -46.6544,
        address: 'Shopping Ibirapuera - São Paulo, SP',
      ),
      status: ActiveRideStatus.goingToPickup,
      startedAt: DateTime.now(),
      estimatedPrice: 18.50,
      finalPrice: 18.50,
    );
  }

  DriverStatistics _createMockDriverStatistics() {
    return DriverStatistics(
      totalTrips: 150,
      totalDistance: 2500.0,
      totalDuration: 3000,
      averageRating: 4.8,
      totalEarnings: 4500.0,
      acceptanceRate: 0.85,
      cancellationRate: 0.05,
      onlineTime: 4800,
      period: DatePeriod(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      ),
    );
  }

  DriverEarnings _createMockDriverEarnings() {
    return DriverEarnings(
      totalEarnings: 4500.0,
      tripEarnings: 4200.0,
      bonuses: 300.0,
      fees: -200.0,
      netEarnings: 4300.0,
      period: DatePeriod(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      ),
      dailyBreakdown: [],
    );
  }

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

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));
  }

  // Implementações vazias para métodos não utilizados no mock
  @override
  Future<void> updatePricingConfig(
    String driverId,
    PricingConfig pricing,
  ) async {
    await _simulateNetworkDelay();
  }

  @override
  Future<void> updateServiceFees(String driverId, ServiceFees fees) async {
    await _simulateNetworkDelay();
  }

  @override
  Future<void> addWorkingArea(String driverId, WorkingArea area) async {
    await _simulateNetworkDelay();
  }

  @override
  Future<void> removeWorkingArea(String driverId, String areaId) async {
    await _simulateNetworkDelay();
  }

  @override
  Future<List<DriverStatusHistory>> getStatusHistory(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    await _simulateNetworkDelay();
    return [];
  }

  @override
  Future<ride_models.RideRequest?> getRideRequestDetails(
    String requestId,
  ) async {
    await _simulateNetworkDelay();
    return null;
  }

  @override
  Future<void> markArrivedAtPickup(String rideId) async {
    await _simulateNetworkDelay();
  }

  @override
  Future<void> markPassengerPickedUp(String rideId) async {
    await _simulateNetworkDelay();
  }

  @override
  Future<void> markArrivedAtDestination(String rideId) async {
    await _simulateNetworkDelay();
  }

  @override
  Future<void> cancelRide(String rideId, String reason) async {
    await _simulateNetworkDelay();
  }

  @override
  Future<void> addExtraStop(
    String rideId,
    ride_models.RideLocation stop,
  ) async {
    await _simulateNetworkDelay();
  }

  @override
  Future<void> updateRideRoute(String rideId, RideRoute route) async {
    await _simulateNetworkDelay();
  }

  @override
  Future<void> markAllNotificationsAsRead(String driverId) async {
    await _simulateNetworkDelay();
  }

  @override
  Future<String> uploadDocumentPhoto(
    String driverId,
    String documentType,
    String filePath,
  ) async {
    await _simulateNetworkDelay();
    return 'https://example.com/document_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  @override
  Future<void> updateDriverDocuments(
    String driverId,
    DriverDocuments documents,
  ) async {
    await _simulateNetworkDelay();
  }

  @override
  Future<void> submitDocumentsForVerification(String driverId) async {
    await _simulateNetworkDelay();
  }
}
