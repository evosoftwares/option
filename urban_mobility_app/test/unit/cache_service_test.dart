/* [Test] Testes unitários para CacheService */
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/core/storage/cache_service.dart';

void main() {
  group('CacheService Tests', () {
    late CacheService cacheService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      cacheService = CacheService(prefs);
      await cacheService.init();
    });

    test('should store and retrieve string value', () async {
      const key = 'test_string';
      const value = 'Hello World';

      await cacheService.set(key, value);
      final retrieved = cacheService.get<String>(key);

      expect(retrieved, equals(value));
    });

    test('should store and retrieve complex object', () async {
      const key = 'test_map';
      final value = {'name': 'John', 'age': 30};

      await cacheService.set(key, value);
      final retrieved = cacheService.get<Map<String, dynamic>>(key);

      expect(retrieved, equals(value));
    });

    test('should return null for non-existent key', () {
      final retrieved = cacheService.get<String>('non_existent');
      expect(retrieved, isNull);
    });

    test('should handle cache expiry', () async {
      const key = 'expiring_key';
      const value = 'expiring_value';

      await cacheService.set(
        key, 
        value, 
        expiry: const Duration(milliseconds: 100),
      );

      // Should exist immediately
      expect(cacheService.get<String>(key), equals(value));

      // Wait for expiry
      await Future.delayed(const Duration(milliseconds: 150));

      // Should be null after expiry
      expect(cacheService.get<String>(key), isNull);
    });

    test('should check if key exists', () async {
      const key = 'existence_test';
      const value = 'test_value';

      expect(cacheService.has(key), isFalse);

      await cacheService.set(key, value);
      expect(cacheService.has(key), isTrue);
    });

    test('should remove specific key', () async {
      const key = 'removable_key';
      const value = 'removable_value';

      await cacheService.set(key, value);
      expect(cacheService.has(key), isTrue);

      await cacheService.remove(key);
      expect(cacheService.has(key), isFalse);
    });

    test('should clear all cache', () async {
      await cacheService.set('key1', 'value1');
      await cacheService.set('key2', 'value2');

      expect(cacheService.has('key1'), isTrue);
      expect(cacheService.has('key2'), isTrue);

      await cacheService.clear();

      expect(cacheService.has('key1'), isFalse);
      expect(cacheService.has('key2'), isFalse);
    });
  });
}