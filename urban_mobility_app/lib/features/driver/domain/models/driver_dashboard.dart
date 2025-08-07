import 'trip_earnings.dart';

/// Painel de Controle do Motorista (Seção 4.5)
/// Implementa a gestão pós-viagem e dashboard de ganhos
class DriverDashboard {
  const DriverDashboard({
    required this.driverId,
    required this.todayEarnings,
    required this.weekEarnings,
    required this.monthEarnings,
    required this.totalTrips,
    required this.todayTrips,
    required this.weekTrips,
    required this.monthTrips,
    required this.averageRating,
    required this.totalRatings,
    required this.onlineHours,
    required this.acceptanceRate,
    required this.cancellationRate,
    required this.recentTrips,
    this.lastUpdated,
  });

  final String driverId;

  // Ganhos
  final double todayEarnings;
  final double weekEarnings;
  final double monthEarnings;

  // Estatísticas de viagens
  final int totalTrips;
  final int todayTrips;
  final int weekTrips;
  final int monthTrips;

  // Avaliações
  final double averageRating;
  final int totalRatings;

  // Métricas de performance
  final Duration onlineHours;
  final double acceptanceRate; // Percentual de aceitação
  final double cancellationRate; // Percentual de cancelamento

  // Histórico recente
  final List<TripEarnings> recentTrips;

  final DateTime? lastUpdated;

  /// Ganhos por hora hoje
  double get earningsPerHour {
    if (onlineHours.inMinutes == 0) return 0.0;
    return todayEarnings / (onlineHours.inMinutes / 60.0);
  }

  /// Ganhos médios por viagem hoje
  double get averageEarningsPerTrip {
    if (todayTrips == 0) return 0.0;
    return todayEarnings / todayTrips;
  }

  /// Ganhos formatados de hoje
  String get formattedTodayEarnings =>
      'R\$ ${todayEarnings.toStringAsFixed(2)}';

  /// Ganhos formatados da semana
  String get formattedWeekEarnings => 'R\$ ${weekEarnings.toStringAsFixed(2)}';

  /// Ganhos formatados do mês
  String get formattedMonthEarnings =>
      'R\$ ${monthEarnings.toStringAsFixed(2)}';

  /// Avaliação formatada
  String get formattedRating => '${averageRating.toStringAsFixed(1)} ⭐';

  /// Taxa de aceitação formatada
  String get formattedAcceptanceRate =>
      '${(acceptanceRate * 100).toStringAsFixed(1)}%';

  /// Taxa de cancelamento formatada
  String get formattedCancellationRate =>
      '${(cancellationRate * 100).toStringAsFixed(1)}%';

  /// Horas online formatadas
  String get formattedOnlineHours {
    final hours = onlineHours.inHours;
    final minutes = onlineHours.inMinutes % 60;
    return '${hours}h ${minutes}min';
  }

  /// Ganhos por hora formatados
  String get formattedEarningsPerHour =>
      'R\$ ${earningsPerHour.toStringAsFixed(2)}/h';

  /// Ganhos médios por viagem formatados
  String get formattedAverageEarningsPerTrip =>
      'R\$ ${averageEarningsPerTrip.toStringAsFixed(2)}';

  /// Verificar se teve bom desempenho hoje
  bool get hasGoodPerformanceToday {
    return acceptanceRate >= 0.8 && // 80% de aceitação
        cancellationRate <= 0.05 && // Máximo 5% de cancelamento
        averageRating >= 4.5; // Avaliação mínima 4.5
  }

  /// Obter meta de ganhos diários (baseada na média semanal)
  double get dailyEarningsGoal {
    return weekEarnings / 7;
  }

  /// Progresso da meta diária (0.0 a 1.0)
  double get dailyGoalProgress {
    final goal = dailyEarningsGoal;
    if (goal == 0) return 0.0;
    return (todayEarnings / goal).clamp(0.0, 1.0);
  }

  /// Progresso da meta diária formatado
  String get formattedDailyGoalProgress {
    return '${(dailyGoalProgress * 100).toStringAsFixed(0)}%';
  }

  /// Atualizar ganhos de hoje
  DriverDashboard updateTodayEarnings(double earnings) {
    return copyWith(todayEarnings: earnings, lastUpdated: DateTime.now());
  }

  /// Adicionar nova viagem
  DriverDashboard addTrip(TripEarnings trip) {
    final updatedRecentTrips = [trip, ...recentTrips.take(9)].toList();

    return copyWith(
      todayEarnings: todayEarnings + trip.netEarnings,
      todayTrips: todayTrips + 1,
      totalTrips: totalTrips + 1,
      recentTrips: updatedRecentTrips,
      lastUpdated: DateTime.now(),
    );
  }

  /// Atualizar avaliação
  DriverDashboard updateRating(double newRating) {
    final totalScore = averageRating * totalRatings;
    final newTotalRatings = totalRatings + 1;
    final newAverageRating = (totalScore + newRating) / newTotalRatings;

    return copyWith(
      averageRating: newAverageRating,
      totalRatings: newTotalRatings,
      lastUpdated: DateTime.now(),
    );
  }

  /// Atualizar horas online
  DriverDashboard updateOnlineHours(Duration hours) {
    return copyWith(onlineHours: hours, lastUpdated: DateTime.now());
  }

  /// Dashboard padrão para novo motorista
  factory DriverDashboard.defaultForDriver(String driverId) {
    return DriverDashboard(
      driverId: driverId,
      todayEarnings: 0.0,
      weekEarnings: 0.0,
      monthEarnings: 0.0,
      totalTrips: 0,
      todayTrips: 0,
      weekTrips: 0,
      monthTrips: 0,
      averageRating: 5.0,
      totalRatings: 0,
      onlineHours: Duration.zero,
      acceptanceRate: 1.0,
      cancellationRate: 0.0,
      recentTrips: const [],
      lastUpdated: DateTime.now(),
    );
  }

  DriverDashboard copyWith({
    String? driverId,
    double? todayEarnings,
    double? weekEarnings,
    double? monthEarnings,
    int? totalTrips,
    int? todayTrips,
    int? weekTrips,
    int? monthTrips,
    double? averageRating,
    int? totalRatings,
    Duration? onlineHours,
    double? acceptanceRate,
    double? cancellationRate,
    List<TripEarnings>? recentTrips,
    DateTime? lastUpdated,
  }) {
    return DriverDashboard(
      driverId: driverId ?? this.driverId,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      weekEarnings: weekEarnings ?? this.weekEarnings,
      monthEarnings: monthEarnings ?? this.monthEarnings,
      totalTrips: totalTrips ?? this.totalTrips,
      todayTrips: todayTrips ?? this.todayTrips,
      weekTrips: weekTrips ?? this.weekTrips,
      monthTrips: monthTrips ?? this.monthTrips,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      onlineHours: onlineHours ?? this.onlineHours,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      cancellationRate: cancellationRate ?? this.cancellationRate,
      recentTrips: recentTrips ?? this.recentTrips,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory DriverDashboard.fromJson(Map<String, dynamic> json) {
    return DriverDashboard(
      driverId: json['driverId'] as String,
      todayEarnings: (json['todayEarnings'] as num).toDouble(),
      weekEarnings: (json['weekEarnings'] as num).toDouble(),
      monthEarnings: (json['monthEarnings'] as num).toDouble(),
      totalTrips: json['totalTrips'] as int,
      todayTrips: json['todayTrips'] as int,
      weekTrips: json['weekTrips'] as int,
      monthTrips: json['monthTrips'] as int,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      onlineHours: Duration(seconds: json['onlineHoursSeconds'] as int),
      acceptanceRate: (json['acceptanceRate'] as num).toDouble(),
      cancellationRate: (json['cancellationRate'] as num).toDouble(),
      recentTrips: (json['recentTrips'] as List<dynamic>)
          .map((item) => TripEarnings.fromJson(item as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'todayEarnings': todayEarnings,
      'weekEarnings': weekEarnings,
      'monthEarnings': monthEarnings,
      'totalTrips': totalTrips,
      'todayTrips': todayTrips,
      'weekTrips': weekTrips,
      'monthTrips': monthTrips,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'onlineHoursSeconds': onlineHours.inSeconds,
      'acceptanceRate': acceptanceRate,
      'cancellationRate': cancellationRate,
      'recentTrips': recentTrips.map((trip) => trip.toJson()).toList(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
}
