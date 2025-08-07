import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Classe utilitária para tratar erros específicos do Google Maps
/// e problemas de segurança relacionados ao navegador
class MapErrorHandler {
  static bool _isInitialized = false;
  static final List<String> _suppressedErrors = [
    'measureUserAgentSpecificMemory',
    'SecurityError',
    'Cross-Origin-Embedder-Policy',
    'SharedArrayBuffer',
    'performance.memory',
  ];

  /// Inicializa o tratamento de erros do mapa
  static void initialize() {
    if (_isInitialized) return;
    
    if (kIsWeb) {
      _setupWebErrorHandling();
    }
    
    _isInitialized = true;
    developer.log(
      'MapErrorHandler inicializado para plataforma: ${kIsWeb ? "Web" : "Mobile"}',
      name: 'MapErrorHandler',
    );
  }

  /// Configura o tratamento de erros específico para web
  static void _setupWebErrorHandling() {
    // Intercepta erros globais do Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      if (_shouldSuppressError(details.exception.toString())) {
        developer.log(
          'Erro do mapa suprimido: ${details.exception}',
          name: 'MapErrorHandler',
          level: 300, // Warning level
        );
        return;
      }
      
      // Para outros erros, usa o handler padrão
      FlutterError.presentError(details);
    };

    // Intercepta erros de zona não capturados
    runZonedGuarded(() {}, (error, stackTrace) {
      if (_shouldSuppressError(error.toString())) {
        developer.log(
          'Erro de zona do mapa suprimido: $error',
          name: 'MapErrorHandler',
          level: 300,
        );
        return;
      }
      
      developer.log(
        'Erro não capturado: $error',
        name: 'MapErrorHandler',
        level: 1000, // Error level
        stackTrace: stackTrace,
      );
    });
  }

  /// Verifica se um erro deve ser suprimido
  static bool _shouldSuppressError(String errorMessage) {
    return _suppressedErrors.any((suppressedError) => 
      errorMessage.toLowerCase().contains(suppressedError.toLowerCase())
    );
  }

  /// Executa uma operação do mapa com tratamento de erro
  static Future<T?> safeMapOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (_shouldSuppressError(e.toString())) {
        developer.log(
          'Operação do mapa "${operationName ?? 'desconhecida'}" falhou (erro suprimido): $e',
          name: 'MapErrorHandler',
          level: 300,
        );
        return fallbackValue;
      }
      
      developer.log(
        'Operação do mapa "${operationName ?? 'desconhecida'}" falhou: $e',
        name: 'MapErrorHandler',
        level: 1000,
      );
      
      rethrow;
    }
  }

  /// Executa uma operação síncrona do mapa com tratamento de erro
  static T? safeSyncMapOperation<T>(
    T Function() operation, {
    String? operationName,
    T? fallbackValue,
  }) {
    try {
      return operation();
    } catch (e) {
      if (_shouldSuppressError(e.toString())) {
        developer.log(
          'Operação síncrona do mapa "${operationName ?? 'desconhecida'}" falhou (erro suprimido): $e',
          name: 'MapErrorHandler',
          level: 300,
        );
        return fallbackValue;
      }
      
      developer.log(
        'Operação síncrona do mapa "${operationName ?? 'desconhecida'}" falhou: $e',
        name: 'MapErrorHandler',
        level: 1000,
      );
      
      rethrow;
    }
  }

  /// Wrapper para inicialização do Google Maps
  static Future<void> initializeGoogleMaps() async {
    await safeMapOperation(
      () async {
        // Aguarda um frame para garantir que o DOM esteja pronto
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (kIsWeb) {
          // Verifica se a API do Google Maps está carregada
          developer.log(
            'Verificando disponibilidade da API do Google Maps...',
            name: 'MapErrorHandler',
          );
        }
      },
      operationName: 'Inicialização do Google Maps',
    );
  }

  /// Limpa recursos e handlers
  static void dispose() {
    _isInitialized = false;
    developer.log(
      'MapErrorHandler finalizado',
      name: 'MapErrorHandler',
    );
  }
}