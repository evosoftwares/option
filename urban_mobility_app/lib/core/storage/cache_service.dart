 // Arquivo: lib/core/storage/cache_service.dart
 // Propósito: Serviço de cache híbrido (memória + persistente) com expiração (TTL) para otimizar leituras.
 // Camadas/Dependências: core/storage; usa SharedPreferences; integra com core/constants para timeouts padrão.
 // Responsabilidades: Ler/gravar itens com TTL, invalidar expirados e manter coerência entre camadas.
 // Pontos de extensão: Injetar relógio/serialização customizada em versões futuras; chaves e TTLs ajustáveis por chamada.
 
 import 'dart:convert';
 import 'package:shared_preferences/shared_preferences.dart';
 import '../constants/app_constants.dart';
 
 /// Serviço de cache com suporte a expiração (TTL) em memória e persistente.
 ///
 /// - Mantém cópia em memória para leituras rápidas e fallback no armazenamento.
 /// - Remove itens expirados de forma preguiçosa (on-read) e pró-ativa na inicialização.
 class CacheService {
   final SharedPreferences _prefs;
   final Map<String, CacheItem> _memoryCache = {};
 
   /// Cria um [CacheService] com dependência de [SharedPreferences] injetada.
   CacheService(this._prefs);
 
   /// Inicializa a limpeza de itens expirados.
   ///
   /// Efeitos colaterais: pode remover chaves do armazenamento persistente.
   Future<void> init() async {
     // Remove itens expirados de forma pró-ativa ao iniciar o app.
     await _clearExpiredCache();
   }
 
   /// Salva [value] sob [key] com expiração opcional [expiry].
   ///
   /// - Quando [expiry] é nulo, utiliza o timeout padrão de [AppConstants.locationCacheTimeout].
   /// - Serializa o valor para JSON quando necessário.
   Future<void> set<T>(
     String key,
     T value, {
     Duration? expiry,
   }) async {
     final expiryTime = expiry != null
         ? DateTime.now().add(expiry)
         : DateTime.now().add(AppConstants.locationCacheTimeout);
 
     final cacheItem = CacheItem(
       value: value,
       expiryTime: expiryTime,
     );
 
     // Cache em memória para leitura rápida.
     _memoryCache[key] = cacheItem;
 
     // Persiste como JSON com metadados de expiração.
     final jsonString = jsonEncode({
       'value': _serializeValue(value),
       'expiryTime': expiryTime.millisecondsSinceEpoch,
     });
 
     await _prefs.setString(key, jsonString);
   }
 
   /// Recupera valor tipado de [key] ou null se não existir/expirar.
   ///
   /// - Estratégia: tenta memória -> persistente -> invalida se expirado.
   T? get<T>(String key) {
     // Verifica cache em memória primeiro para reduzir latência.
     final memoryCacheItem = _memoryCache[key];
     if (memoryCacheItem != null && !memoryCacheItem.isExpired) {
       return memoryCacheItem.value as T?;
     }
 
     // Fallback no armazenamento persistente.
     final jsonString = _prefs.getString(key);
     if (jsonString == null) return null;
 
     try {
       final json = jsonDecode(jsonString);
       final expiryTime =
           DateTime.fromMillisecondsSinceEpoch(json['expiryTime']);
 
       if (DateTime.now().isAfter(expiryTime)) {
         // Invalida chave expirada em ambas as camadas.
         remove(key);
         return null;
       }
 
       final value = _deserializeValue<T>(json['value']);
 
       // Atualiza cache em memória para leituras subsequentes.
       _memoryCache[key] = CacheItem(
         value: value,
         expiryTime: expiryTime,
       );
 
       return value;
     } catch (e) {
       // Em caso de corrupção de dados, remove chave para evitar loops de erro.
       remove(key);
       return null;
     }
   }
 
   /// Indica se há um valor válido (não expirado) para [key].
   bool has(String key) {
     return get(key) != null;
   }
 
   /// Remove item de [key] de memória e persistência.
   Future<void> remove(String key) async {
     _memoryCache.remove(key);
     await _prefs.remove(key);
   }
 
   /// Limpa todo o cache (memória + persistente).
   Future<void> clear() async {
     _memoryCache.clear();
     await _prefs.clear();
   }
 
   /// Remove chaves expiradas do armazenamento e do cache em memória.
   Future<void> _clearExpiredCache() async {
     final keys = _prefs.getKeys().toList();
 
     for (final key in keys) {
       final jsonString = _prefs.getString(key);
       if (jsonString == null) continue;
 
       try {
         final json = jsonDecode(jsonString);
         final expiryTime =
             DateTime.fromMillisecondsSinceEpoch(json['expiryTime']);
 
         if (DateTime.now().isAfter(expiryTime)) {
           await _prefs.remove(key);
         }
       } catch (e) {
         // NOTE: Se o conteúdo estiver corrompido, remove a chave para manter integridade.
         await _prefs.remove(key);
       }
     }
 
     // Purga entradas expiradas do cache em memória.
     _memoryCache.removeWhere((key, item) => item.isExpired);
   }
 
   /// Serializa valores simples para JSON.
   ///
   /// - Para tipos não primitivos, utiliza `toString()` como fallback.
   dynamic _serializeValue<T>(T value) {
     if (value is String || value is num || value is bool) {
       return value;
     } else if (value is Map || value is List) {
       return value;
     } else {
       return value.toString();
     }
   }
 
   /// Desserializa valor vindo do JSON como [T] quando possível.
   T? _deserializeValue<T>(dynamic value) {
     if (value is T) {
       return value;
     }
     return null;
   }
 }
 
 /// Container de item de cache com metadados de expiração.
 class CacheItem {
   /// Valor armazenado; pode ser primitivo, Map ou List.
   final dynamic value;
 
   /// Instante de expiração absoluta.
   final DateTime expiryTime;
 
   CacheItem({
     required this.value,
     required this.expiryTime,
   });
 
   /// Indica se o item está expirado considerando o relógio atual.
   bool get isExpired => DateTime.now().isAfter(expiryTime);
 }