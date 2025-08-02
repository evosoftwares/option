/* [Cache] Serviço de cache para otimização de performance */
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class CacheService {
  final SharedPreferences _prefs;
  final Map<String, CacheItem> _memoryCache = {};

  CacheService(this._prefs);

  Future<void> init() async {
    // Limpar cache expirado na inicialização
    await _clearExpiredCache();
  }

  // Salvar dados no cache
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

    // Cache em memória
    _memoryCache[key] = cacheItem;

    // Cache persistente
    final jsonString = jsonEncode({
      'value': _serializeValue(value),
      'expiryTime': expiryTime.millisecondsSinceEpoch,
    });

    await _prefs.setString(key, jsonString);
  }

  // Recuperar dados do cache
  T? get<T>(String key) {
    // Verificar cache em memória primeiro
    final memoryCacheItem = _memoryCache[key];
    if (memoryCacheItem != null && !memoryCacheItem.isExpired) {
      return memoryCacheItem.value as T?;
    }

    // Verificar cache persistente
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString);
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(json['expiryTime']);
      
      if (DateTime.now().isAfter(expiryTime)) {
        remove(key);
        return null;
      }

      final value = _deserializeValue<T>(json['value']);
      
      // Atualizar cache em memória
      _memoryCache[key] = CacheItem(
        value: value,
        expiryTime: expiryTime,
      );

      return value;
    } catch (e) {
      remove(key);
      return null;
    }
  }

  // Verificar se existe no cache
  bool has(String key) {
    return get(key) != null;
  }

  // Remover item do cache
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    await _prefs.remove(key);
  }

  // Limpar todo o cache
  Future<void> clear() async {
    _memoryCache.clear();
    await _prefs.clear();
  }

  // Limpar cache expirado
  Future<void> _clearExpiredCache() async {
    final keys = _prefs.getKeys().toList();
    
    for (final key in keys) {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) continue;

      try {
        final json = jsonDecode(jsonString);
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(json['expiryTime']);
        
        if (DateTime.now().isAfter(expiryTime)) {
          await _prefs.remove(key);
        }
      } catch (e) {
        await _prefs.remove(key);
      }
    }

    // Limpar cache em memória expirado
    _memoryCache.removeWhere((key, item) => item.isExpired);
  }

  // Serializar valor para JSON
  dynamic _serializeValue<T>(T value) {
    if (value is String || value is num || value is bool) {
      return value;
    } else if (value is Map || value is List) {
      return value;
    } else {
      return value.toString();
    }
  }

  // Deserializar valor do JSON
  T? _deserializeValue<T>(dynamic value) {
    if (value is T) {
      return value;
    }
    return null;
  }
}

class CacheItem {
  final dynamic value;
  final DateTime expiryTime;

  CacheItem({
    required this.value,
    required this.expiryTime,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}