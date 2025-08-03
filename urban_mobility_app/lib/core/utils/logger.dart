 // Arquivo: lib/core/utils/logger.dart
 // Propósito: Prover log estruturado por níveis para debugging, monitoramento e auditoria.
 // Camadas/Dependências: core/utils; usa dart:developer e sinalizadores de modo do Flutter.
 // Responsabilidades: Filtrar por nível, formatar mensagens e encaminhar para destinos (console/analytics).
 // Pontos de extensão: Integração com Crashlytics/Sentry; roteamento por nível; campos de contexto.
 
 import 'dart:developer' as developer;
 import 'package:flutter/foundation.dart';
 
 /// Níveis suportados pelo logger da aplicação.
 enum LogLevel {
   debug,
   info,
   warning,
   error,
   critical,
 }
 
 /// Logger central da aplicação.
 ///
 /// - Aplica nível mínimo por modo (debug/profile/release).
 /// - Encaminha mensagens para `developer.log` e opcionalmente para analytics.
 class AppLogger {
   static const String _name = 'InDriverApp';
 
   // Determina o menor nível aceito conforme o modo de build.
   static LogLevel get _minLevel {
     if (kDebugMode) return LogLevel.debug;
     if (kProfileMode) return LogLevel.info;
     return LogLevel.warning; // Release mode
   }
 
   /// Registra mensagem no nível debug (apenas em builds não-release).
   void debug(String message, [Object? error, StackTrace? stackTrace]) {
     _log(LogLevel.debug, message, error, stackTrace);
   }
 
   /// Registra informação útil para acompanhamento do fluxo normal.
   void info(String message, [Object? error, StackTrace? stackTrace]) {
     _log(LogLevel.info, message, error, stackTrace);
   }
 
   /// Registra condições inesperadas que não interrompem o fluxo.
   void warning(String message, [Object? error, StackTrace? stackTrace]) {
     _log(LogLevel.warning, message, error, stackTrace);
   }
 
   /// Registra erros que impactam funcionalidades.
   void error(String message, [Object? error, StackTrace? stackTrace]) {
     _log(LogLevel.error, message, error, stackTrace);
   }
 
   /// Registra falhas críticas que exigem atenção imediata.
   void critical(String message, [Object? error, StackTrace? stackTrace]) {
     _log(LogLevel.critical, message, error, stackTrace);
   }
 
   /// Implementação interna de logging.
   ///
   /// - Respeita [_minLevel].
   /// - Formata timestamp e nível.
   /// - Em produção, pode enviar erros para serviços externos.
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
 
     developer.log(
       formattedMessage,
       name: _name,
       level: _getLevelValue(level),
       error: error,
       stackTrace: stackTrace,
     );
 
     // Em produção, encaminha erros e críticos para analytics.
     if (!kDebugMode && level.index >= LogLevel.error.index) {
       _sendToAnalytics(level, message, error, stackTrace);
     }
   }
 
   /// Mapeia o [LogLevel] para valores inteiros esperados por `developer.log`.
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
 
   /// Hook para envio de logs a serviços de monitoramento.
   void _sendToAnalytics(
     LogLevel level,
     String message,
     Object? error,
     StackTrace? stackTrace,
   ) {
     // TODO(maintainers): Implementar envio para Firebase Crashlytics ou similar
     // TEST: Validar que erros são reportados apenas em builds de release.
     // FirebaseCrashlytics.instance.recordError(error, stackTrace);
   }
 
   /// Registra métrica de performance com duração da operação.
   void logPerformance(String operation, Duration duration) {
     info('Performance: $operation took ${duration.inMilliseconds}ms');
   }
 
   /// Registra resultado de chamadas de API com tempo de execução.
   void logApiCall(String endpoint, int statusCode, Duration duration) {
     final message =
         'API: $endpoint - Status: $statusCode - Duration: ${duration.inMilliseconds}ms';
     if (statusCode >= 400) {
       error(message);
     } else {
       info(message);
     }
   }
 
   /// Registra ações do usuário para auditoria.
   void logUserAction(String action, Map<String, dynamic>? parameters) {
     final params = parameters != null ? ' - Params: $parameters' : '';
     info('User Action: $action$params');
   }
 }