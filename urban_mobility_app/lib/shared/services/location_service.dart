////
/// Arquivo: Serviço de Localização (camada shared/services)
///
/// Propósito:
/// - Fornecer posição atual do dispositivo e resolver endereço reverso,
///   expondo estado reativo (posição, endereço, loading, erro) para a UI.
///
/// Camadas/Dependências:
/// - Depende apenas de pacotes de infraestrutura (geolocator, geocoding)
///   e de Flutter foundation (ChangeNotifier). Não depende de features.
/// - Pode ser consumido por widgets em shared/ e por camadas de features.
///
/// Responsabilidades:
/// - Gerenciar fluxo de permissão de localização.
/// - Obter a posição atual com precisão alta.
/// - Resolver endereço a partir de latitude/longitude.
/// - Manter e notificar estado reativo para a UI.
///
/// Pontos de extensão:
/// - Estratégias de precisão/timeout.
/// - Integração com streams de atualização contínua.
/// - Intercâmbio por implementação otimizada (LocationServiceOptimized).
////

library;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

///
/// Serviço básico de localização baseado em ChangeNotifier.
/// Mantém o último Position e endereço resolvido, com indicadores
/// de carregamento e erro para consumo direto na UI.
///
class LocationService extends ChangeNotifier {
  /// Última posição conhecida. Pode ser nula se ainda não resolvida.
  Position? _currentPosition;

  /// Último endereço resolvido via geocoding reverso. Pode ser nulo.
  String? _currentAddress;

  /// Flag de carregamento para operações ativas.
  bool _isLoading = false;

  /// Mensagem de erro para consumo pela UI. Nula quando sem erros.
  String? _error;

  /// Posição atual exposta para a UI (somente leitura).
  Position? get currentPosition => _currentPosition;

  /// Endereço atual exposto para a UI (somente leitura).
  String? get currentAddress => _currentAddress;

  /// Indicador de carregamento exposto para a UI.
  bool get isLoading => _isLoading;

  /// Último erro exposto para a UI (se houver).
  String? get error => _error;

  ///
  /// Verifica se o serviço de localização está habilitado e solicita
  /// permissões quando necessário.
  ///
  /// Retorno:
  /// - true: permissões válidas e serviços habilitados.
  /// - false: alguma condição impeditiva (erro preenchido).
  ///
  /// Efeitos colaterais:
  /// - Atualiza [_error] com mensagens descritivas e notifica listeners.
  ///
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de localização do dispositivo está ativo.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error = 'Serviços de localização estão desabilitados.';
      notifyListeners();
      return false;
    }

    // Checa e solicita permissões conforme necessário.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error = 'Permissões de localização foram negadas.';
        notifyListeners();
        return false;
      }
    }

    // Caso de negação permanente exige abrir configurações do sistema.
    if (permission == LocationPermission.deniedForever) {
      _error = 'Permissões de localização foram negadas permanentemente.';
      notifyListeners();
      return false;
    }

    return true;
  }

  ///
  /// Obtém a posição atual com alta precisão e resolve o endereço
  /// correspondente via geocoding reverso.
  ///
  /// Fluxo:
  /// 1) Valida/solicita permissões.
  /// 2) Obtém posição com LocationAccuracy.high.
  /// 3) Resolve endereço a partir da posição.
  ///
  /// Efeitos colaterais:
  /// - Atualiza [_isLoading], [_currentPosition], [_currentAddress], [_error].
  /// - Emite notifyListeners em transições de estado.
  ///
  /// Erros:
  /// - Mensagens são atribuídas em [_error]; exceções internas são capturadas.
  ///
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

      // Solicita uma única leitura da posição com precisão alta.
      // Observação: sem timeout aqui; ver implementação otimizada para retry.
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Resolve endereço associado à posição atual.
      await _getAddressFromLatLng(_currentPosition!);
    } catch (e) {
      _error = 'Erro ao obter localização: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ///
  /// Converte latitude/longitude em endereço legível.
  ///
  /// Parâmetros:
  /// - position: posição de origem para geocoding reverso.
  ///
  /// Efeitos colaterais:
  /// - Atualiza [_currentAddress] com resultado ou mensagem padrão.
  ///
  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        
        // Constrói o endereço filtrando campos vazios/nulos
        final addressParts = <String>[];
        
        // Adiciona rua e número se disponível
        if (place.street != null && place.street!.isNotEmpty) {
          String streetInfo = place.street!;
          if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
            streetInfo = '${place.subThoroughfare}, $streetInfo';
          }
          addressParts.add(streetInfo);
        }
        
        // Adiciona bairro se disponível
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        
        // Adiciona cidade se disponível
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        
        // Se não conseguiu nenhuma informação específica, usa informações administrativas
        if (addressParts.isEmpty) {
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            addressParts.add(place.administrativeArea!);
          }
          if (place.country != null && place.country!.isNotEmpty) {
            addressParts.add(place.country!);
          }
        }
        
        _currentAddress = addressParts.isNotEmpty 
            ? addressParts.join(', ') 
            : 'Localização encontrada';
      } else {
        _currentAddress = 'Endereço não disponível';
      }
    } catch (e) {
      _currentAddress = 'Erro ao obter endereço';
    }
  }

  ///
  /// Busca coordenadas estimadas a partir de um texto de endereço.
  ///
  /// Parâmetros:
  /// - query: texto do endereço a ser geocodificado.
  ///
  /// Retorno:
  /// - Lista de [Location] possíveis para a consulta.
  ///
  /// Erros:
  /// - Lança [Exception] com mensagem descritiva em caso de falha.
  ///
  Future<List<Location>> searchLocation(String query) async {
    try {
      return await locationFromAddress(query);
    } catch (e) {
      throw Exception('Erro ao buscar localização: $e');
    }
  }

  ///
  /// Calcula a distância em metros entre dois pontos (lat/long).
  ///
  /// Parâmetros:
  /// - startLatitude, startLongitude: ponto inicial.
  /// - endLatitude, endLongitude: ponto final.
  ///
  /// Retorno:
  /// - Distância em metros como [double].
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
  /// Limpa a mensagem de erro atual e notifica ouvintes.
  ///
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
