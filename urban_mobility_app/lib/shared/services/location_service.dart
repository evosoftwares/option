/* [Service: Location] Serviço de localização com estado reativo (ChangeNotifier).
   Exibe posição/endereço atuais, loading e erro para a UI. */
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/* [Service: Location] Mantém dados e regras de permissão de localização. */
class LocationService extends ChangeNotifier {
  /* [State] Campos internos observáveis. */
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  String? _error;

  /* [Selectors] Getters expostos à UI. */
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /* [Permissions] Verifica serviços e solicita permissão ao usuário. */
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error = 'Serviços de localização estão desabilitados.';
      notifyListeners();
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error = 'Permissões de localização foram negadas.';
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _error = 'Permissões de localização foram negadas permanentemente.';
      notifyListeners();
      return false;
    }

    return true;
  }

  /* [Actions] Obtém posição atual e resolve endereço (reverso). */
  Future<void> getCurrentPosition() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _getAddressFromLatLng(_currentPosition!);
    } catch (e) {
      _error = 'Erro ao obter localização: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* [Geocoding] Converte latitude/longitude em endereço legível. */
  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.locality}';
      }
    } catch (e) {
      _currentAddress = 'Endereço não encontrado';
    }
  }

  /* [Search] Busca coordenadas por texto de endereço. */
  Future<List<Location>> searchLocation(String query) async {
    try {
      return await locationFromAddress(query);
    } catch (e) {
      throw Exception('Erro ao buscar localização: $e');
    }
  }

  /* [Utils] Calcula a distância em metros entre dois pontos. */
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /* [State] Limpa mensagem de erro. */
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
