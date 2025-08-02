/* [Logger] Sistema de logging para debugging e monitoramento */
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class AppLogger {
  static const String _name = 'InDriverApp';
  
  // Configuração de níveis de log por ambiente
  static LogLevel get _minLevel {
    if (kDebugMode) return LogLevel.debug;
    if (kProfileMode) return LogLevel.info;
    return LogLevel.warning; // Release mode
  }

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  void critical(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.critical, message, error, stackTrace);
  }

  void _log(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (level.index < _minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelName = level.name.toUpperCase();
    final formattedMessage = '[$timestamp] [$levelName] $message';

    // Log no console do desenvolvedor
    developer.log(
      formattedMessage,
      name: _name,
      level: _getLevelValue(level),
      error: error,
      stackTrace: stackTrace,
    );

    // Em produção, você pode enviar logs para serviços como Crashlytics
    if (!kDebugMode && level.index >= LogLevel.error.index) {
      _sendToAnalytics(level, message, error, stackTrace);
    }
  }

  int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }

  void _sendToAnalytics(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // TODO: Implementar envio para Firebase Crashlytics ou similar
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  // Métodos de conveniência para logging de performance
  void logPerformance(String operation, Duration duration) {
    info('Performance: $operation took ${duration.inMilliseconds}ms');
  }

  void logApiCall(String endpoint, int statusCode, Duration duration) {
    final message = 'API: $endpoint - Status: $statusCode - Duration: ${duration.inMilliseconds}ms';
    if (statusCode >= 400) {
      error(message);
    } else {
      info(message);
    }
  }

  void logUserAction(String action, Map<String, dynamic>? parameters) {
    final params = parameters != null ? ' - Params: $parameters' : '';
    info('User Action: $action$params');
  }
}