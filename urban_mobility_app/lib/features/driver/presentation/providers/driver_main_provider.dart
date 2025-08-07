import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/models/driver_status.dart';
import '../../domain/models/ride_request.dart';
import '../../domain/repositories/driver_repository.dart';

/// Provider para a tela principal do motorista
class DriverMainProvider extends ChangeNotifier {
  DriverMainProvider({required this.driverRepository});

  final DriverRepository driverRepository;

  // Estado do motorista
  DriverStatus _status = DriverStatus.offline;
  bool _isLoading = false;
  String? _error;

  // Dados do motorista
  Map<String, dynamic>? _driverProfile;
  Map<String, dynamic>? _driverStats;
  double _ratePerKm = 2.50;
  bool _isAvailable = false;

  // Solicitações de viagem
  RideRequest? _currentRideRequest;
  StreamSubscription<RideRequest?>? _rideRequestSubscription;
  Timer? _requestTimer;

  // Getters
  DriverStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get driverProfile => _driverProfile;
  Map<String, dynamic>? get driverStats => _driverStats;
  double get ratePerKm => _ratePerKm;
  bool get isAvailable => _isAvailable;
  RideRequest? get currentRideRequest => _currentRideRequest;

  // Computed properties
  bool get canGoOnline => _driverProfile != null && !_isLoading;
  bool get isOnline => _status == DriverStatus.online;
  String get statusDisplayName => _status.displayName;
  String get statusDescription => _status.description;

  /// Inicializa o provider carregando dados do motorista
  Future<void> initialize(String driverId) async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadDriverProfile(driverId),
        _loadDriverStats(driverId),
        _loadDriverStatus(driverId),
      ]);

      // Inicia o stream de solicitações se estiver online
      if (_status.canReceiveRequests) {
        _startListeningToRideRequests(driverId);
      }
    } catch (e) {
      _setError('Erro ao carregar dados: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega o perfil do motorista
  Future<void> _loadDriverProfile(String driverId) async {
    // TODO: Implement when backend is ready
    // _driverProfile = await driverRepository.getDriverProfile(driverId);
    _driverProfile = {'name': 'Driver Demo', 'isAvailable': true};
    if (_driverProfile != null) {
      _ratePerKm = (_driverProfile!['ratePerKm'] as num?)?.toDouble() ?? 2.50;
      _isAvailable = _driverProfile!['isAvailable'] as bool? ?? false;
    }
  }

  /// Carrega as estatísticas do motorista
  Future<void> _loadDriverStats(String driverId) async {
    // TODO: Implement when backend is ready
    // _driverStats = await driverRepository.getDriverStats(driverId);
    _driverStats = {'totalRides': 150, 'rating': 4.8};
  }

  /// Carrega o status atual do motorista
  Future<void> _loadDriverStatus(String driverId) async {
    _status = await driverRepository.getDriverStatus(driverId);
  }

  /// Alterna o status online/offline do motorista
  Future<void> toggleOnlineStatus(String driverId) async {
    if (_isLoading) return;

    _setLoading(true);
    try {
      final newStatus = _status == DriverStatus.offline
          ? DriverStatus.online
          : DriverStatus.offline;

      await driverRepository.updateDriverStatus(driverId, newStatus);
      _status = newStatus;

      if (newStatus == DriverStatus.online) {
        _startListeningToRideRequests(driverId);
      } else {
        _stopListeningToRideRequests();
      }

      _clearError();
    } catch (e) {
      _setError('Erro ao alterar status: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza a taxa por quilômetro
  Future<void> updateRatePerKm(String driverId, double newRate) async {
    if (_isLoading || newRate <= 0) return;

    _setLoading(true);
    try {
      // TODO: Implement when backend is ready
      // await driverRepository.updateDriverRates(driverId, newRate);
      _ratePerKm = newRate;
      _clearError();
    } catch (e) {
      _setError('Erro ao atualizar taxa: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Inicia o stream de solicitações de viagem
  void _startListeningToRideRequests(String driverId) {
    _rideRequestSubscription?.cancel();
    // TODO: Implement when backend is ready
    // _rideRequestSubscription = driverRepository
    //     .getRideRequestsStream(driverId)
    //     .listen(
    //       (request) {
    //         _currentRideRequest = request;
    //         if (request != null) {
    //           _startRequestTimer();
    //         } else {
    //           _stopRequestTimer();
    //         }
    //         notifyListeners();
    //       },
    //       onError: (error) {
    //         _setError('Erro ao receber solicitações: $error');
    //       },
    //     );
  }

  /// Para o stream de solicitações
  void _stopListeningToRideRequests() {
    _rideRequestSubscription?.cancel();
    _rideRequestSubscription = null;
    _currentRideRequest = null;
    _stopRequestTimer();
  }

  /// Inicia o timer da solicitação (10 segundos)
  void _startRequestTimer() {
    _stopRequestTimer();
    _requestTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentRideRequest?.isValid != true) {
        _currentRideRequest = null;
        _stopRequestTimer();
        notifyListeners();
      } else {
        notifyListeners(); // Para atualizar o countdown
      }
    });
  }

  /// Para o timer da solicitação
  void _stopRequestTimer() {
    _requestTimer?.cancel();
    _requestTimer = null;
  }

  /// Aceita uma solicitação de viagem
  Future<void> acceptRideRequest() async {
    if (_currentRideRequest == null || _isLoading) return;

    _setLoading(true);
    try {
      // TODO: Fix acceptRideRequest signature when backend is ready
      // await driverRepository.acceptRideRequest(_currentRideRequest!.id);
      _status = DriverStatus.onTrip;
      _currentRideRequest = null;
      _stopRequestTimer();
      _clearError();
    } catch (e) {
      _setError('Erro ao aceitar viagem: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Recusa uma solicitação de viagem
  Future<void> declineRideRequest() async {
    if (_currentRideRequest == null || _isLoading) return;

    _setLoading(true);
    try {
      // TODO: Implement when backend is ready
      // await driverRepository.declineRideRequest(_currentRideRequest!.id);
      _currentRideRequest = null;
      _stopRequestTimer();
      _clearError();
    } catch (e) {
      _setError('Erro ao recusar viagem: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza a localização do motorista
  Future<void> updateLocation(
    String driverId,
    double latitude,
    double longitude,
  ) async {
    try {
      // TODO: Implement when backend is ready
      // await driverRepository.updateDriverLocation(driverId, latitude, longitude);
    } catch (e) {
      // Log do erro, mas não exibe para o usuário (atualização de localização é silenciosa)
      debugPrint('Erro ao atualizar localização: $e');
    }
  }

  /// Recarrega os dados do motorista
  Future<void> refresh(String driverId) async {
    await initialize(driverId);
  }

  // Métodos auxiliares
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
    _rideRequestSubscription?.cancel();
    _requestTimer?.cancel();
    super.dispose();
  }
}
