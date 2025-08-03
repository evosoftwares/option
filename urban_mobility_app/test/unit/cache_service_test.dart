/*
  [Arquivo de Teste] CacheService - unidade

  O que está sendo testado:
  - Comportamento do serviço de cache (armazenamento, leitura, existência, remoção e limpeza).
  - Suporte a serialização de tipos primitivos e mapas simples.
  - Mecanismo de expiração por TTL (time-to-live).

  Dependências e mocks principais:
  - SharedPreferences (em modo mock via setMockInitialValues).
  - Instância real de CacheService inicializada com SharedPreferences mockado.

  Cobertura de cenários:
  - Gravação/leitura de String.
  - Gravação/leitura de objeto simples (Map) com serialização.
  - Chave inexistente retorna null.
  - Expiração por TTL invalida o valor após o tempo configurado (lazy eviction na leitura).
  - Verificação de existência de chave.
  - Remoção específica de chave.
  - Limpeza total do cache.

  Observações:
  - Timeouts/temporizadores: usamos um TTL curto em milissegundos para validar expiração sem tornar o teste lento.
  - AAA (Arrange, Act, Assert) está marcado nos testes para facilitar manutenção e leitura.
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_mobility_app/core/storage/cache_service.dart';

void main() {
  /// Grupo principal cobrindo as operações públicas do CacheService:
  /// set/get, has, remove e clear, incluindo cenários com TTL.
  group('CacheService Tests', () {
    late CacheService cacheService;

    /// Prepara um SharedPreferences em memória (mock) e inicializa o CacheService para cada teste.
    /// Mantém os casos isolados e reprodutíveis.
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      cacheService = CacheService(prefs);
      await cacheService.init();
    });

    test('should store and retrieve string value', () async {
      // Arrange
      const key = 'test_string';
      const value = 'Hello World';

      // Act
      await cacheService.set(key, value);
      final retrieved = cacheService.get<String>(key);

      // Assert
      expect(retrieved, equals(value));
    });

    test('should store and retrieve complex object', () async {
      // Arrange
      const key = 'test_map';
      final value = {'name': 'John', 'age': 30};

      // Act
      await cacheService.set(key, value);
      final retrieved = cacheService.get<Map<String, dynamic>>(key);

      // Assert
      expect(retrieved, equals(value));
    });

    test('should return null for non-existent key', () {
      // Arrange & Act
      final retrieved = cacheService.get<String>('non_existent');

      // Assert
      expect(retrieved, isNull);
    });

    test('should handle cache expiry', () async {
      // Arrange
      const key = 'expiring_key';
      const value = 'expiring_value';

      // Act
      await cacheService.set(
        key,
        value,
        expiry: const Duration(milliseconds: 100),
      );

      // Assert (imediato): antes do TTL, valor deve existir
      expect(cacheService.get<String>(key), equals(value));

      // Espera passar do TTL para validar expiração.
      // Usamos 150ms (>100ms) para evitar flakiness por variações de agendamento.
      await Future.delayed(const Duration(milliseconds: 150));

      // Assert (após expirar): leitura deve retornar null (estratégia lazy: invalida na leitura)
      expect(cacheService.get<String>(key), isNull);
    });

    test('should check if key exists', () async {
      // Arrange
      const key = 'existence_test';
      const value = 'test_value';

      // Assert (pré-condição)
      expect(cacheService.has(key), isFalse);

      // Act
      await cacheService.set(key, value);

      // Assert
      expect(cacheService.has(key), isTrue);
    });

    test('should remove specific key', () async {
      // Arrange
      const key = 'removable_key';
      const value = 'removable_value';

      // Act
      await cacheService.set(key, value);

      // Assert (pré-condição)
      expect(cacheService.has(key), isTrue);

      // Act
      await cacheService.remove(key);

      // Assert
      expect(cacheService.has(key), isFalse);
    });

    test('should clear all cache', () async {
      // Arrange
      await cacheService.set('key1', 'value1');
      await cacheService.set('key2', 'value2');

      // Assert (pré-condição)
      expect(cacheService.has('key1'), isTrue);
      expect(cacheService.has('key2'), isTrue);

      // Act
      await cacheService.clear();

      // Assert
      expect(cacheService.has('key1'), isFalse);
      expect(cacheService.has('key2'), isFalse);
    });
  });
}