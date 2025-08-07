import '../models/driver_profile.dart';
import '../models/driver_work_config.dart';
import '../models/driver_status.dart' hide DriverLocation;
import '../models/ride_request.dart' hide VehicleCategory;
import '../models/active_ride.dart';
import '../models/driver_documents.dart';
import '../models/vehicle_info.dart';

/// Repositório do motorista conforme regras de negócio
abstract class DriverRepository {
  // ========== Gestão de Perfil (Seção 4.1) ==========

  /// Obtém o perfil do motorista
  Future<DriverProfile?> getDriverProfile(String driverId);

  /// Atualiza o perfil do motorista
  Future<void> updateDriverProfile(DriverProfile profile);

  /// Cria um novo perfil de motorista
  Future<String> createDriverProfile(DriverProfile profile);

  /// Atualiza informações pessoais
  Future<void> updatePersonalInfo(String driverId, PersonalInfo personalInfo);

  /// Atualiza informações do veículo
  Future<void> updateVehicleInfo(String driverId, VehicleInfo vehicleInfo);

  /// Atualiza documentos do motorista
  Future<void> updateDriverDocuments(
    String driverId,
    DriverDocuments documents,
  );

  /// Faz upload de foto de documento
  Future<String> uploadDocumentPhoto(
    String driverId,
    String documentType,
    String filePath,
  );

  /// Submete documentos para verificação
  Future<void> submitDocumentsForVerification(String driverId);

  // ========== Configuração de Trabalho (Seção 4.2) ==========

  /// Obtém configuração de trabalho do motorista
  Future<DriverWorkConfig?> getWorkConfig(String driverId);

  /// Atualiza configuração de trabalho
  Future<void> updateWorkConfig(String driverId, DriverWorkConfig config);

  /// Atualiza configuração de preços
  Future<void> updatePricingConfig(String driverId, PricingConfig pricing);

  /// Atualiza taxas de serviços
  Future<void> updateServiceFees(String driverId, ServiceFees fees);

  /// Adiciona área de trabalho
  Future<void> addWorkingArea(String driverId, WorkingArea area);

  /// Remove área de trabalho
  Future<void> removeWorkingArea(String driverId, String areaId);

  // ========== Gestão de Status (Seção 4.3) ==========

  /// Obtém status atual do motorista
  Future<DriverStatus> getDriverStatus(String driverId);

  /// Atualiza status do motorista
  Future<void> updateDriverStatus(String driverId, DriverStatus status);

  /// Fica online
  Future<void> goOnline(String driverId, DriverLocation location);

  /// Fica offline
  Future<void> goOffline(String driverId);

  /// Pausa atividade
  Future<void> pauseActivity(String driverId, String reason);

  /// Retoma atividade
  Future<void> resumeActivity(String driverId);

  /// Atualiza localização do motorista
  Future<void> updateLocation(String driverId, DriverLocation location);

  /// Obtém histórico de status
  Future<List<DriverStatusHistory>> getStatusHistory(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  // ========== Solicitações de Viagem (Seção 4.4) ==========

  /// Obtém solicitações de viagem pendentes
  Stream<List<RideRequest>> getPendingRideRequests(String driverId);

  /// Aceita uma solicitação de viagem
  Future<ActiveRide> acceptRideRequest(String driverId, String requestId);

  /// Rejeita uma solicitação de viagem
  Future<void> rejectRideRequest(
    String driverId,
    String requestId,
    String reason,
  );

  /// Obtém detalhes de uma solicitação específica
  Future<RideRequest?> getRideRequestDetails(String requestId);

  // ========== Viagens Ativas (Seção 4.5) ==========

  /// Obtém viagem ativa atual
  Future<ActiveRide?> getCurrentActiveRide(String driverId);

  /// Atualiza status da viagem ativa
  Future<void> updateActiveRideStatus(String rideId, ActiveRideStatus status);

  /// Marca chegada ao local de embarque
  Future<void> markArrivedAtPickup(String rideId);

  /// Marca embarque do passageiro
  Future<void> markPassengerPickedUp(String rideId);

  /// Marca chegada ao destino
  Future<void> markArrivedAtDestination(String rideId);

  /// Finaliza viagem
  Future<void> completeRide(
    String rideId, {
    required double finalPrice,
    double? actualDistance,
    int? actualDuration,
    int? waitingTime,
    String? notes,
  });

  /// Cancela viagem
  Future<void> cancelRide(String rideId, String reason);

  /// Adiciona parada extra
  Future<void> addExtraStop(String rideId, RideLocation stop);

  /// Atualiza rota da viagem
  Future<void> updateRideRoute(String rideId, RideRoute route);

  // ========== Histórico e Relatórios (Seção 4.6) ==========

  /// Obtém histórico de viagens
  Future<List<ActiveRide>> getRideHistory(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  /// Obtém estatísticas do motorista
  Future<DriverStatistics> getDriverStatistics(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Obtém ganhos do motorista
  Future<DriverEarnings> getDriverEarnings(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Obtém avaliações recebidas
  Future<List<DriverRating>> getDriverRatings(
    String driverId, {
    int? limit,
    int? offset,
  });

  // ========== Notificações ==========

  /// Obtém notificações do motorista
  Future<List<DriverNotification>> getNotifications(
    String driverId, {
    bool? unreadOnly,
    int? limit,
  });

  /// Marca notificação como lida
  Future<void> markNotificationAsRead(String notificationId);

  /// Marca todas as notificações como lidas
  Future<void> markAllNotificationsAsRead(String driverId);

  // ========== Configurações ==========

  /// Obtém configurações do app
  Future<DriverAppSettings> getAppSettings(String driverId);

  /// Atualiza configurações do app
  Future<void> updateAppSettings(String driverId, DriverAppSettings settings);

  /// Obtém configurações de notificação
  Future<NotificationSettings> getNotificationSettings(String driverId);

  /// Atualiza configurações de notificação
  Future<void> updateNotificationSettings(
    String driverId,
    NotificationSettings settings,
  );
}

/// Estatísticas do motorista
class DriverStatistics {
  const DriverStatistics({
    required this.totalTrips,
    required this.totalDistance,
    required this.totalDuration,
    required this.averageRating,
    required this.totalEarnings,
    required this.acceptanceRate,
    required this.cancellationRate,
    required this.onlineTime,
    required this.period,
  });

  final int totalTrips;
  final double totalDistance;
  final int totalDuration; // em minutos
  final double averageRating;
  final double totalEarnings;
  final double acceptanceRate; // 0.0 a 1.0
  final double cancellationRate; // 0.0 a 1.0
  final int onlineTime; // em minutos
  final DatePeriod period;

  factory DriverStatistics.fromJson(Map<String, dynamic> json) {
    return DriverStatistics(
      totalTrips: json['totalTrips'] as int,
      totalDistance: (json['totalDistance'] as num).toDouble(),
      totalDuration: json['totalDuration'] as int,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      acceptanceRate: (json['acceptanceRate'] as num).toDouble(),
      cancellationRate: (json['cancellationRate'] as num).toDouble(),
      onlineTime: json['onlineTime'] as int,
      period: DatePeriod.fromJson(json['period'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTrips': totalTrips,
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'averageRating': averageRating,
      'totalEarnings': totalEarnings,
      'acceptanceRate': acceptanceRate,
      'cancellationRate': cancellationRate,
      'onlineTime': onlineTime,
      'period': period.toJson(),
    };
  }
}

/// Ganhos do motorista
class DriverEarnings {
  const DriverEarnings({
    required this.totalEarnings,
    required this.tripEarnings,
    required this.bonuses,
    required this.fees,
    required this.netEarnings,
    required this.period,
    required this.dailyBreakdown,
  });

  final double totalEarnings;
  final double tripEarnings;
  final double bonuses;
  final double fees;
  final double netEarnings;
  final DatePeriod period;
  final List<DailyEarnings> dailyBreakdown;

  factory DriverEarnings.fromJson(Map<String, dynamic> json) {
    return DriverEarnings(
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      tripEarnings: (json['tripEarnings'] as num).toDouble(),
      bonuses: (json['bonuses'] as num).toDouble(),
      fees: (json['fees'] as num).toDouble(),
      netEarnings: (json['netEarnings'] as num).toDouble(),
      period: DatePeriod.fromJson(json['period'] as Map<String, dynamic>),
      dailyBreakdown: (json['dailyBreakdown'] as List<dynamic>)
          .map((item) => DailyEarnings.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEarnings': totalEarnings,
      'tripEarnings': tripEarnings,
      'bonuses': bonuses,
      'fees': fees,
      'netEarnings': netEarnings,
      'period': period.toJson(),
      'dailyBreakdown': dailyBreakdown.map((item) => item.toJson()).toList(),
    };
  }
}

/// Ganhos diários
class DailyEarnings {
  const DailyEarnings({
    required this.date,
    required this.earnings,
    required this.trips,
    required this.onlineTime,
  });

  final DateTime date;
  final double earnings;
  final int trips;
  final int onlineTime; // em minutos

  factory DailyEarnings.fromJson(Map<String, dynamic> json) {
    return DailyEarnings(
      date: DateTime.parse(json['date'] as String),
      earnings: (json['earnings'] as num).toDouble(),
      trips: json['trips'] as int,
      onlineTime: json['onlineTime'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'earnings': earnings,
      'trips': trips,
      'onlineTime': onlineTime,
    };
  }
}

/// Período de datas
class DatePeriod {
  const DatePeriod({required this.startDate, required this.endDate});

  final DateTime startDate;
  final DateTime endDate;

  factory DatePeriod.fromJson(Map<String, dynamic> json) {
    return DatePeriod(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

/// Avaliação do motorista
class DriverRating {
  const DriverRating({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.passengerName,
  });

  final String id;
  final String rideId;
  final String passengerId;
  final String? passengerName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  factory DriverRating.fromJson(Map<String, dynamic> json) {
    return DriverRating(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      passengerId: json['passengerId'] as String,
      passengerName: json['passengerName'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'passengerId': passengerId,
      'passengerName': passengerName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Notificação do motorista
class DriverNotification {
  const DriverNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.data,
    this.actionUrl,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? actionUrl;

  factory DriverNotification.fromJson(Map<String, dynamic> json) {
    return DriverNotification(
      id: json['id'] as String,
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
      data: json['data'] as Map<String, dynamic>?,
      actionUrl: json['actionUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'data': data,
      'actionUrl': actionUrl,
    };
  }
}

/// Tipos de notificação
enum NotificationType {
  rideRequest,
  rideUpdate,
  payment,
  document,
  system,
  promotion,
}

/// Configurações do app
class DriverAppSettings {
  const DriverAppSettings({
    required this.language,
    required this.theme,
    required this.mapStyle,
    required this.voiceNavigation,
    required this.autoAcceptRides,
    required this.maxDistanceForRides,
    required this.preferredVehicleCategories,
  });

  final String language;
  final String theme;
  final String mapStyle;
  final bool voiceNavigation;
  final bool autoAcceptRides;
  final double maxDistanceForRides;
  final List<VehicleCategory> preferredVehicleCategories;

  factory DriverAppSettings.fromJson(Map<String, dynamic> json) {
    return DriverAppSettings(
      language: json['language'] as String,
      theme: json['theme'] as String,
      mapStyle: json['mapStyle'] as String,
      voiceNavigation: json['voiceNavigation'] as bool,
      autoAcceptRides: json['autoAcceptRides'] as bool,
      maxDistanceForRides: (json['maxDistanceForRides'] as num).toDouble(),
      preferredVehicleCategories:
          (json['preferredVehicleCategories'] as List<dynamic>)
              .map(
                (category) => VehicleCategory.values.firstWhere(
                  (e) => e.name == category,
                ),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme,
      'mapStyle': mapStyle,
      'voiceNavigation': voiceNavigation,
      'autoAcceptRides': autoAcceptRides,
      'maxDistanceForRides': maxDistanceForRides,
      'preferredVehicleCategories': preferredVehicleCategories
          .map((e) => e.name)
          .toList(),
    };
  }
}

/// Configurações de notificação
class NotificationSettings {
  const NotificationSettings({
    required this.rideRequests,
    required this.rideUpdates,
    required this.payments,
    required this.documents,
    required this.system,
    required this.promotions,
    required this.sound,
    required this.vibration,
  });

  final bool rideRequests;
  final bool rideUpdates;
  final bool payments;
  final bool documents;
  final bool system;
  final bool promotions;
  final bool sound;
  final bool vibration;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      rideRequests: json['rideRequests'] as bool,
      rideUpdates: json['rideUpdates'] as bool,
      payments: json['payments'] as bool,
      documents: json['documents'] as bool,
      system: json['system'] as bool,
      promotions: json['promotions'] as bool,
      sound: json['sound'] as bool,
      vibration: json['vibration'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideRequests': rideRequests,
      'rideUpdates': rideUpdates,
      'payments': payments,
      'documents': documents,
      'system': system,
      'promotions': promotions,
      'sound': sound,
      'vibration': vibration,
    };
  }
}
