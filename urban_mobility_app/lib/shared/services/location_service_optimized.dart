////
/// Arquivo: Serviço de Localização Otimizado (camada shared/services)
///
/// Propósito:
/// - Prover localização com experiência resiliente: cache por tempo,
///   retry exponencial simples, timeouts e mensagens de erro descritivas.
///
/// Camadas/Dependências:
/// - Depende de geolocator/geocoding e Flutter foundation (ChangeNotifier).
/// - Substitui/estende o comportamento do LocationService básico.
///
/// Responsabilidades:
/// - Controlar estado consolidado via LocationResult (posição, endereço, erro).
/// - Aplicar cache com expiração para evitar chamadas redundantes.
/// - Realizar leitura de posição com retry e timeout.
/// - Propagar erros e estados específicos (permissionDenied).
///
/// Pontos de extensão:
/// - Estratégia de retry/backoff.
/// - Politicas de precisão e timeouts.
/// - Observação contínua via streams.
///
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Estados possíveis do ciclo de obtenção de localização.
enum LocationStatus { initial, loading, success, error, permissionDenied }

/// Resultado imutável de uma tentativa de localização.
/// Agrega posição/endereço/erro e o estado atual.
class LocationResult {
  /// Última posição obtida (pode ser nula em initial/error).
  final Position? position;

  /// Último endereço resolvido (pode ser nulo).
  final String? address;

  /// Mensagem de erro descritiva (quando status == error/permissionDenied).
  final String? error;

  /// Estado atual do fluxo de localização.
  final LocationStatus status;

  /// Construtor do resultado de localização.
  const LocationResult({
    this.position,
    this.address,
    this.error,
    required this.status,
  });

  /// Cria uma nova instância atualizando campos específicos.
  LocationResult copyWith({
    Position? position,
    String? address,
    String? error,
    LocationStatus? status,
  }) {
    return LocationResult(
      position: position ?? this.position,
      address: address ?? this.address,
      error: error ?? this.error,
      status: status ?? this.status,
    );
  }
}

/// Serviço otimizado de localização com cache, retry e tratamento de erros.
/// Mantém um estado consolidado e notifica ouvintes a cada transição.
class LocationServiceOptimized extends ChangeNotifier {
  /// Estado interno consolidado (imutável por instância).
  LocationResult _state = const LocationResult(status: LocationStatus.initial);

  /// Momento da última atualização bem-sucedida (para validade de cache).
  DateTime? _lastUpdate;

  /// Janela de validade do cache da última posição/endereço.
  static const Duration _cacheTimeout = Duration(minutes: 5);

  /// Número máximo de tentativas durante a leitura de posição.
  static const int _maxRetries = 3;

  /// Estado exposto (somente leitura) para consumo pela UI.
  LocationResult get state => _state;

  /// Atalhos convenientes para UI.
  Position? get currentPosition => _state.position;
  String? get currentAddress => _state.address;
  bool get isLoading => _state.status == LocationStatus.loading;
  String? get error => _state.error;

  /// Atualiza o estado interno e notifica ouvintes.
  void _updateState(LocationResult newState) {
    _state = newState;
    notifyListeners();
  }

  ///
  /// Obtém a posição atual e endereço, respeitando cache e permissões.
  ///
  /// Parâmetros:
  /// - forceRefresh: quando true, ignora cache válido.
  ///
  /// Fluxo:
  /// 1) Se cache válido e !forceRefresh, retorna imediatamente.
  /// 2) Vai para loading e limpa erro.
  /// 3) Valida/solicita permissões.
  /// 4) Lê posição com retry e timeout.
  /// 5) Resolve endereço por geocoding reverso.
  /// 6) Atualiza estado para success e carimba _lastUpdate.
  ///
  /// Erros:
  /// - Em falhas, estado passa a error com mensagem descritiva.
  ///
  Future<void> getCurrentPosition({bool forceRefresh = false}) async {
    // Verifica cache válido para evitar chamadas redundantes.
    if (!forceRefresh && _isCacheValid()) {
      return;
    }

    _updateState(_state.copyWith(status: LocationStatus.loading, error: null));

    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;

      // Leitura com timeout e múltiplas tentativas.
      final position = await _getCurrentPositionWithRetry();

      // Geocoding reverso para endereço humano.
      final address = await _getAddressFromLatLng(position);
      
      _lastUpdate = DateTime.now();
      _updateState(LocationResult(
        position: position,
        address: address,
        status: LocationStatus.success,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        status: LocationStatus.error,
        error: 'Erro ao obter localização: ${e.toString()}',
      ));
    }
  }

  /// Retorna true quando o cache ainda está dentro da janela de validade
  /// e o último estado foi bem-sucedido.
  bool _isCacheValid() {
    return _lastUpdate != null &&
        DateTime.now().difference(_lastUpdate!) < _cacheTimeout &&
        _state.status == LocationStatus.success;
  }

  ///
  /// Tenta obter a posição atual com múltiplas tentativas.
  ///
  /// Estratégia:
  /// - timeLimit de 10s por tentativa.
  /// - Backoff linear simples (1s, 2s, ...).
  ///
  /// Retorno:
  /// - Posição atual do dispositivo.
  ///
  /// Erros:
  /// - Propaga a última exceção após esgotar tentativas.
  ///
  Future<Position> _getCurrentPositionWithRetry() async {
    Exception? lastException;
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        // Backoff linear crescente entre tentativas.
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }
    
    throw lastException!;
  }

  ///
  /// Verifica serviço de localização e fluxo de permissões.
  ///
  /// Retorno:
  /// - true: permissões válidas e serviço habilitado.
  /// - false: estado será atualizado para error/permissionDenied.
  ///
  /// Efeitos colaterais:
  /// - Atualiza [_state] com mensagens de erro e status apropriados.
  ///
  Future<bool> _handleLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateState(_state.copyWith(
          status: LocationStatus.error,
          error: 'Serviços de localização estão desabilitados.',
        ));
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _updateState(_state.copyWith(
            status: LocationStatus.permissionDenied,
            error: 'Permissões de localização foram negadas.',
          ));
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _updateState(_state.copyWith(
          status: LocationStatus.permissionDenied,
          error: 'Permissões de localização foram negadas permanentemente.',
        ));
        return false;
      }

      return true;
    } catch (e) {
      _updateState(_state.copyWith(
        status: LocationStatus.error,
        error: 'Erro ao verificar permissões: ${e.toString()}',
      ));
      return false;
    }
  }

  ///
  /// Resolve endereço humano a partir de uma [Position].
  ///
  /// Retorno:
  /// - Texto de endereço ou mensagens padrão em falhas.
  ///
  Future<String> _getAddressFromLatLng(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}';
      }
      return 'Endereço não encontrado';
    } catch (e) {
      return 'Erro ao obter endereço';
    }
  }

  ///
  /// Geocodifica um texto de endereço em uma lista de coordenadas candidatas.
  ///
  /// Parâmetros:
  /// - query: termo de busca. Valores em branco retornam lista vazia.
  ///
  /// Erros:
  /// - Lança [Exception] quando a operação falha.
  ///
  Future<List<Location>> searchLocation(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      return await locationFromAddress(query);
    } catch (e) {
      throw Exception('Erro ao buscar localização: ${e.toString()}');
    }
  }

  ///
  /// Calcula a distância em metros entre dois pontos (lat/long).
  ///
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

  ///
  /// Limpa somente o erro atual preservando demais campos do estado.
  ///
  void clearError() {
    if (_state.error != null) {
      _updateState(_state.copyWith(error: null));
    }
  }

  ///
  /// Reseta o estado para initial e invalida o cache.
  ///
  void reset() {
    _state = const LocationResult(status: LocationStatus.initial);
    _lastUpdate = null;
    notifyListeners();
  }
}