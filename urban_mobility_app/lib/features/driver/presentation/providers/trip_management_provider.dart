import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/models/active_trip.dart';
import '../../domain/models/trip_status.dart';
import '../../domain/repositories/driver_repository.dart';

/// Provider para gerenciamento de viagem ativa
class TripManagementProvider extends ChangeNotifier {
  TripManagementProvider({required this.driverRepository});

  final DriverRepository driverRepository;

  // Estado da viagem
  ActiveTrip? _activeTrip;
  bool _isLoading = false;
  String? _error;

  // Dados do mapa
  Set<Polyline> _routePolylines = {};
  Timer? _locationTimer;

  // Getters
  ActiveTrip? get activeTrip => _activeTrip;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<Polyline> get routePolylines => _routePolylines;

  /// Carrega uma viagem específica
  Future<void> loadTrip(String tripId) async {
    _setLoading(true);
    try {
      // TODO: Implementar carregamento real da viagem
      _activeTrip = _createMockTrip(tripId);
      _startLocationTracking();
      _clearError();
    } catch (e) {
      _setError('Erro ao carregar viagem: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Marca que chegou no local de embarque
  Future<void> markArrivedAtPickup() async {
    if (_activeTrip == null || _isLoading) return;

    _setLoading(true);
    try {
      _activeTrip = _activeTrip!.copyWith(status: TripStatus.arrivedAtPickup);
      // TODO: Notificar passageiro
      _clearError();
    } catch (e) {
      _setError('Erro ao marcar chegada: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Inicia a viagem
  Future<void> startTrip() async {
    if (_activeTrip == null || _isLoading) return;

    _setLoading(true);
    try {
      _activeTrip = _activeTrip!.copyWith(
        status: TripStatus.onTrip,
        pickedUpAt: DateTime.now(),
      );
      _clearError();
    } catch (e) {
      _setError('Erro ao iniciar viagem: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Marca que chegou no destino
  Future<void> markArrivedAtDestination() async {
    if (_activeTrip == null || _isLoading) return;

    _setLoading(true);
    try {
      _activeTrip = _activeTrip!.copyWith(
        status: TripStatus.arrivedAtDestination,
      );
      _clearError();
    } catch (e) {
      _setError('Erro ao marcar chegada no destino: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Finaliza a viagem
  Future<void> completeTrip() async {
    if (_activeTrip == null || _isLoading) return;

    _setLoading(true);
    try {
      final now = DateTime.now();
      final actualDuration = _activeTrip!.pickedUpAt != null
          ? now.difference(_activeTrip!.pickedUpAt!)
          : _activeTrip!.estimatedDuration;

      _activeTrip = _activeTrip!.copyWith(
        status: TripStatus.completed,
        completedAt: now,
        actualDuration: actualDuration,
        actualPrice: _calculateFinalPrice(),
      );

      _stopLocationTracking();
      _clearError();
    } catch (e) {
      _setError('Erro ao finalizar viagem: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Cancela a viagem
  Future<void> cancelTrip(String reason) async {
    if (_activeTrip == null || _isLoading) return;

    _setLoading(true);
    try {
      _activeTrip = _activeTrip!.copyWith(
        status: TripStatus.cancelled,
        completedAt: DateTime.now(),
      );

      _stopLocationTracking();
      // TODO: Implementar lógica de cancelamento e possível cobrança
      _clearError();
    } catch (e) {
      _setError('Erro ao cancelar viagem: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Inicia o rastreamento de localização
  void _startLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // TODO: Atualizar localização atual e recalcular rota
      _updateRoute();
    });
  }

  /// Para o rastreamento de localização
  void _stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  /// Atualiza a rota no mapa
  void _updateRoute() {
    if (_activeTrip == null) return;

    // TODO: Implementar cálculo real da rota usando Google Directions API
    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: [_activeTrip!.pickupLocation, _activeTrip!.destination],
      color: Colors.blue,
      width: 5,
    );

    _routePolylines = {polyline};
    notifyListeners();
  }

  /// Calcula o preço final da viagem
  double _calculateFinalPrice() {
    if (_activeTrip == null) return 0.0;

    // Preço base
    double finalPrice = _activeTrip!.estimatedPrice;

    // Adicionar taxa de espera se aplicável
    if (_activeTrip!.waitingTime.inMinutes > 5) {
      final extraMinutes = _activeTrip!.waitingTime.inMinutes - 5;
      finalPrice += extraMinutes * 0.50; // R$ 0,50 por minuto extra
    }

    return finalPrice;
  }

  /// Cria uma viagem mock para demonstração
  ActiveTrip _createMockTrip(String tripId) {
    return ActiveTrip(
      id: tripId,
      passengerId: 'passenger_123',
      passengerName: 'Maria Silva',
      passengerPhone: '+5511999999999',
      passengerRating: 4.8,
      pickupLocation: const LatLng(-23.5505, -46.6333), // São Paulo
      pickupAddress: 'Av. Paulista, 1000 - Bela Vista, São Paulo - SP',
      destination: const LatLng(-23.5629, -46.6544), // Ibirapuera
      destinationAddress: 'Parque Ibirapuera - Vila Mariana, São Paulo - SP',
      estimatedPrice: 25.50,
      estimatedDistance: 8.5,
      estimatedDuration: const Duration(minutes: 25),
      status: TripStatus.goingToPickup,
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      specialRequests: ['Ar condicionado', 'Música baixa'],
      paymentMethod: 'Cartão de Crédito',
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopLocationTracking();
    super.dispose();
  }
}
