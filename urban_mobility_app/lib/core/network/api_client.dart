 // Arquivo: lib/core/network/api_client.dart
 // Propósito: Cliente HTTP centralizado com autenticação, timeouts e mapeamento de erros.
 // Camadas/Dependências: core/network; usa http.Client; integra com core/constants e core/utils/logger.
 // Responsabilidades: Executar requisições REST, aplicar timeout configurado e normalizar respostas/erros.
 // Pontos de extensão: Injeção via Service Locator; função [fromJson] para desserialização customizável; headers customizados.
 
 import 'dart:convert';
 import 'dart:io';
 import 'package:http/http.dart' as http;
 import '../constants/app_constants.dart';
 import '../utils/logger.dart';
 
 /// Cliente de API para comunicação HTTP com o backend.
 ///
 /// - Usa [http.Client] injetado para facilitar testes.
 /// - Aplica timeout padrão ([AppConstants.networkTimeout]) a todas as requisições.
 /// - Normaliza resposta em [ApiResponse] sem lançar exceções para fluxos esperados.
 class ApiClient {
   final http.Client _client;
   final AppLogger _logger;
 
   /// Cria um [ApiClient].
   ///
   /// Parâmetros:
   /// - [_client]: cliente HTTP subjacente (pode ser mockado em testes).
   /// - [_logger]: logger para auditoria de chamadas e falhas.
   ApiClient(this._client, this._logger);
 
   /// Executa uma requisição GET.
   ///
   /// Parâmetros:
   /// - [endpoint]: caminho relativo à base configurada.
   /// - [headers]: cabeçalhos adicionais; mesclados aos padrões.
   /// - [queryParameters]: parâmetros de query opcionais.
   /// - [fromJson]: mapeador para transformar o JSON em [T].
   /// Retorno: [ApiResponse] com [data] em caso de sucesso.
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
 
   /// Executa uma requisição POST.
   ///
   /// Parâmetros:
   /// - [endpoint]: caminho relativo.
   /// - [headers]: cabeçalhos adicionais.
   /// - [body]: corpo a ser serializado como JSON.
   /// - [fromJson]: conversor do corpo JSON para [T].
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
 
   /// Executa uma requisição PUT.
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
 
   /// Executa uma requisição DELETE.
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
 
   /// Função interna que prepara e envia a requisição, aplica timeout e registra telemetria.
   ///
   /// - Não lança exceções para erros esperados de rede/HTTP; retorna [ApiResponse.error].
   /// - Em caso de falha de parsing, registra log e normaliza mensagem ao consumidor.
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
 
       // Seleciona método HTTP correspondente e aplica timeout global definido em constantes.
       switch (method) {
         case 'GET':
           response = await _client
               .get(uri, headers: requestHeaders)
               .timeout(AppConstants.networkTimeout);
           break;
         case 'POST':
           response = await _client
               .post(
                 uri,
                 headers: requestHeaders,
                 body: body != null ? jsonEncode(body) : null,
               )
               .timeout(AppConstants.networkTimeout);
           break;
         case 'PUT':
           response = await _client
               .put(
                 uri,
                 headers: requestHeaders,
                 body: body != null ? jsonEncode(body) : null,
               )
               .timeout(AppConstants.networkTimeout);
           break;
         case 'DELETE':
           response = await _client
               .delete(uri, headers: requestHeaders)
               .timeout(AppConstants.networkTimeout);
           break;
         default:
           // Erro de programação: método não suportado.
           throw ApiException('Unsupported HTTP method: $method');
       }
 
       stopwatch.stop();
       _logger.logApiCall(endpoint, response.statusCode, stopwatch.elapsed);
 
       return _handleResponse<T>(response, fromJson);
     } on SocketException {
       stopwatch.stop();
       // Rede indisponível: retorna erro amigável sem exceção.
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
 
   /// Constrói a URI absoluta a partir do [endpoint] e parâmetros de query opcionais.
   Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
     final baseUri =
         Uri.parse('${AppConstants.baseUrl}/${AppConstants.apiVersion}');
     final uri = baseUri.resolve(endpoint);
 
     if (queryParameters != null && queryParameters.isNotEmpty) {
       // Converte todos os valores para string para garantir compatibilidade com Uri.
       return uri.replace(
         queryParameters: queryParameters.map(
           (key, value) => MapEntry(key, value.toString()),
         ),
       );
     }
 
     return uri;
   }
 
   /// Constrói headers padrão e mescla com [customHeaders] quando fornecido.
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
 
   /// Trata a resposta HTTP, executando desserialização opcional com [fromJson].
   ///
   /// - Sucesso (2xx): tenta decodificar JSON e aplicar [fromJson] se possível.
   /// - Erros (>=400): extrai mensagem amigável e inclui [statusCode].
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
 
         // Quando o chamador não fornece [fromJson], repassa JSON cru (Map/List) como T?.
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
 
   /// Extrai mensagem de erro amigável de um corpo de resposta padronizado.
   String _extractErrorMessage(http.Response response) {
     try {
       final jsonData = jsonDecode(response.body);
       if (jsonData is Map<String, dynamic>) {
         return jsonData['message'] ?? jsonData['error'] ?? 'Erro desconhecido';
       }
     } catch (e) {
       // NOTE: Se parsing falhar, usa fallback por status code.
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
 
   /// Encerra o cliente HTTP subjacente.
   void dispose() {
     _client.close();
   }
 }
 
 /// Wrapper de resultado de chamadas de API.
 class ApiResponse<T> {
   /// Dados resultantes quando [isSuccess] é verdadeiro.
   final T? data;
 
   /// Exceção normalizada quando ocorre erro.
   final ApiException? error;
 
   /// Indica sucesso da chamada.
   final bool isSuccess;
 
   /// Cria uma resposta de sucesso.
   ApiResponse.success(this.data)
       : error = null,
         isSuccess = true;
 
   /// Cria uma resposta de erro.
   ApiResponse.error(this.error)
       : data = null,
         isSuccess = false;
 }
 
 /// Exceção de API com mensagem amigável e status opcional.
 class ApiException implements Exception {
   final String message;
   final int? statusCode;
 
   ApiException(this.message, [this.statusCode]);
 
   @override
   String toString() => message;
 }