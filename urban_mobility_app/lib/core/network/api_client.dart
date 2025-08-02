/* [Network] Cliente HTTP otimizado com interceptors */
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class ApiClient {
  final http.Client _client;
  final AppLogger _logger;
  
  ApiClient(this._client, this._logger);

  // GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _makeRequest<T>(
      'GET',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _makeRequest<T>(
      'POST',
      endpoint,
      headers: headers,
      body: body,
      fromJson: fromJson,
    );
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _makeRequest<T>(
      'PUT',
      endpoint,
      headers: headers,
      body: body,
      fromJson: fromJson,
    );
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _makeRequest<T>(
      'DELETE',
      endpoint,
      headers: headers,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final requestHeaders = _buildHeaders(headers);
      
      _logger.info('$method request to: $uri');
      
      late http.Response response;
      
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: requestHeaders)
              .timeout(AppConstants.networkTimeout);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(AppConstants.networkTimeout);
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(AppConstants.networkTimeout);
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: requestHeaders)
              .timeout(AppConstants.networkTimeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      stopwatch.stop();
      _logger.logApiCall(endpoint, response.statusCode, stopwatch.elapsed);

      return _handleResponse<T>(response, fromJson);
      
    } on SocketException {
      stopwatch.stop();
      _logger.error('Network error for $method $endpoint', SocketException);
      return ApiResponse.error(ApiException('Sem conexão com a internet'));
    } on HttpException {
      stopwatch.stop();
      _logger.error('HTTP error for $method $endpoint', HttpException);
      return ApiResponse.error(ApiException('Erro de comunicação com o servidor'));
    } on FormatException {
      stopwatch.stop();
      _logger.error('Format error for $method $endpoint', FormatException);
      return ApiResponse.error(ApiException('Resposta inválida do servidor'));
    } catch (e) {
      stopwatch.stop();
      _logger.error('Unexpected error for $method $endpoint', e);
      return ApiResponse.error(ApiException('Erro inesperado: ${e.toString()}'));
    }
  }

  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final baseUri = Uri.parse('${AppConstants.baseUrl}/${AppConstants.apiVersion}');
    final uri = baseUri.resolve(endpoint);
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
    }
    
    return uri;
  }

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    
    return headers;
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.success(null);
      }
      
      try {
        final jsonData = jsonDecode(response.body);
        
        if (fromJson != null && jsonData is Map<String, dynamic>) {
          final data = fromJson(jsonData);
          return ApiResponse.success(data);
        }
        
        return ApiResponse.success(jsonData as T?);
      } catch (e) {
        _logger.error('JSON parsing error', e);
        return ApiResponse.error(ApiException('Erro ao processar resposta'));
      }
    } else {
      final errorMessage = _extractErrorMessage(response);
      _logger.error('API error: ${response.statusCode} - $errorMessage');
      return ApiResponse.error(ApiException(errorMessage, response.statusCode));
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final jsonData = jsonDecode(response.body);
      if (jsonData is Map<String, dynamic>) {
        return jsonData['message'] ?? jsonData['error'] ?? 'Erro desconhecido';
      }
    } catch (e) {
      // Ignore JSON parsing errors for error messages
    }
    
    switch (response.statusCode) {
      case 400:
        return 'Requisição inválida';
      case 401:
        return 'Não autorizado';
      case 403:
        return 'Acesso negado';
      case 404:
        return 'Recurso não encontrado';
      case 500:
        return 'Erro interno do servidor';
      default:
        return 'Erro de comunicação (${response.statusCode})';
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiResponse<T> {
  final T? data;
  final ApiException? error;
  final bool isSuccess;

  ApiResponse.success(this.data)
      : error = null,
        isSuccess = true;

  ApiResponse.error(this.error)
      : data = null,
        isSuccess = false;
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}