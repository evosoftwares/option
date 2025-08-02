# 🧑‍💻 Development Guide - Urban Mobility App

Guia completo de padrões de desenvolvimento, arquitetura e boas práticas para o projeto.

## 🏗️ Arquitetura do Projeto

### Clean Architecture Implementation

```
lib/
├── core/                          # Camada de infraestrutura
│   ├── constants/                # Constantes globais
│   ├── di/service_locator.dart   # Injeção de dependência
│   ├── network/api_client.dart   # Cliente HTTP centralizado
│   ├── storage/cache_service.dart # Sistema de cache
│   └── utils/                    # Utilitários (logging, etc.)
├── features/                     # Camada de apresentação por domínio
│   ├── auth/                    # Autenticação
│   ├── home/                    # Tela inicial
│   ├── map/                     # Mapas e navegação
│   ├── profile/                 # Perfil do usuário
│   └── rides/                   # Gerenciamento de corridas
└── shared/                      # Serviços compartilhados
    └── services/                # LocationService, etc.
```

### Padrões Arquiteturais

#### 1. Service Locator Pattern
```dart
// Configuração em di/service_locator.dart
void setupServiceLocator() {
  // Serviços core
  sl.registerLazySingleton<ApiClient>(() => ApiClient.defaultConfig());
  sl.registerLazySingleton<CacheService>(() => CacheService());
  
  // Serviços de domínio
  sl.registerFactory<LocationService>(() => LocationService(
    locationProvider: sl(),
    logger: sl(),
  ));
}

// Uso nos widgets
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(locationService: sl<LocationService>()),
      child: HomeView(),
    );
  }
}
```

#### 2. Provider Pattern para Estado
```dart
// Provider com separação de responsabilidades
class RideProvider extends ChangeNotifier {
  final RideService _rideService;
  RideState _state = RideState.initial();
  
  RideProvider({required RideService rideService}) : _rideService = rideService;
  
  RideState get state => _state;
  
  Future<void> requestRide(RideRequest request) async {
    _updateState(_state.copyWith(status: RideStatus.loading));
    
    try {
      final ride = await _rideService.requestRide(request);
      _updateState(_state.copyWith(
        status: RideStatus.success,
        currentRide: ride,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        status: RideStatus.error,
        error: e.toString(),
      ));
    }
  }
  
  void _updateState(RideState newState) {
    _state = newState;
    notifyListeners();
  }
}
```

#### 3. Repository Pattern
```dart
// Interface abstrata
abstract class RideRepository {
  Future<List<Ride>> getActiveRides();
  Future<Ride> createRide(RideRequest request);
  Future<void> updateRideStatus(String rideId, RideStatus status);
}

// Implementação concreta
class ApiRideRepository implements RideRepository {
  final ApiClient _apiClient;
  final CacheService _cache;
  
  ApiRideRepository({
    required ApiClient apiClient,
    required CacheService cache,
  }) : _apiClient = apiClient, _cache = cache;
  
  @override
  Future<List<Ride>> getActiveRides() async {
    // Verificar cache primeiro
    final cached = await _cache.get('active_rides');
    if (cached != null) {
      return (cached as List).map((e) => Ride.fromJson(e)).toList();
    }
    
    // Buscar da API
    final response = await _apiClient.get('/rides/active');
    final rides = (response['data'] as List)
        .map((e) => Ride.fromJson(e))
        .toList();
    
    // Cachear resultado
    await _cache.set('active_rides', rides.map((e) => e.toJson()).toList());
    
    return rides;
  }
}
```

## 📝 Padrões de Comentários

### Cabeçalho de Arquivo
```dart
// Arquivo: lib/core/network/api_client.dart
// Propósito: Cliente HTTP centralizado com autenticação, timeouts e retries.
// Camadas/Dependências: core/network; integra com core/storage para tokens.
// Responsabilidades: Executar requisições REST, mapear erros e telemetria.
// Pontos de extensão: Injeção via Service Locator; sobrescrever interceptadores.
```

### Docstrings com ///
```dart
/// Serviço de localização com cache curto e stream de atualizações.
///
/// Lida com permissões, precisão e thresholds de distância.
/// Exibe erros específicos para simplificar a UI.
class LocationService {
  /// Fonte subjacente de localização.
  final LocationProvider locationProvider;

  /// Cria o serviço de localização.
  ///
  /// Parâmetros:
  /// - [locationProvider]: provider real ou mockado em testes.
  /// - [logger]: logger injetado; evitar uso de print.
  LocationService({
    required this.locationProvider,
    required this.logger,
  });

  /// Obtém posição atual com timeout e cache curto.
  ///
  /// Retorna [GeoPoint] ou lança exceção específica.
  /// Utiliza cache por curto período para reduzir consumo.
  Future<GeoPoint> getCurrent({Duration timeout = Duration(seconds: 5)}) async {
    // Implementação...
  }
}
```

### Comentários Inline
```dart
// Retry exponencial com jitter para distribuir carga em caso de falhas transitórias.
for (var attempt = 1; attempt <= maxAttempts; attempt++) {
  try {
    final res = await _http.get(uri).timeout(timeout);
    return _decode(res);
  } on TimeoutException {
    // PERF: Jitter reduz sincronização de tentativas sob alta concorrência.
    final backoff = Duration(milliseconds: 150 * pow(2, attempt).toInt());
    final jitter = Duration(milliseconds: _random.nextInt(80));
    if (attempt == maxAttempts) rethrow;
    await Future.delayed(backoff + jitter);
  }
}
```

### Tags Padronizadas
```dart
// TODO: Extrair política de retry para Strategy; pronto quando ApiClient aceitar injeção.
// FIXME: Evitar leak ao não cancelar subscription em dispose; analisar uso de auto-cancel.
// NOTE: Esta normalização segue o backend v2; alterar ao migrar para v3.
// PERF: Cachear resposta por 30s reduz chamadas em ~40% sob carga.
// TEST: Mockar LocationProvider para emitir sequência de pontos com jitter controlado.
```

## 🎯 Padrões de Widget

### StatefulWidget com Subscription
```dart
/// Card que exibe a localização atual do usuário.
///
/// Props:
/// - [onTap]: callback quando o card é tocado.
/// - [format]: formata o endereço exibido; padrão compacto.
/// Ciclo de vida:
/// - Inicia subscription no initState e cancela no dispose.
class LocationCard extends StatefulWidget {
  final VoidCallback? onTap;
  final String Function(Address)? format;

  const LocationCard({super.key, this.onTap, this.format});

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  StreamSubscription<Address>? _sub;

  @override
  void initState() {
    super.initState();
    // Assina a stream do serviço de localização.
    _sub = context.read<LocationService>().positions.listen((pos) {
      // NOTE: Atualiza somente se a mudança for relevante para evitar rebuilds desnecessários.
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    // Garante cancelamento da subscription para evitar leaks.
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Evitar lógica aqui; apenas composição e leitura de estado.
    return Selector<LocationService, Address?>(
      selector: (_, service) => service.currentAddress,
      builder: (context, address, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Card(
            child: ListTile(
              leading: Icon(Icons.location_on),
              title: Text(address?.street ?? 'Obtendo localização...'),
              subtitle: Text(widget.format?.call(address) ?? address?.city ?? ''),
            ),
          ),
        );
      },
    );
  }
}
```

### Provider Usage Patterns
```dart
// ✅ BOM: Uso de Selector para rebuilds seletivos
Selector<RideProvider, bool>(
  selector: (_, provider) => provider.state.isLoading,
  builder: (context, isLoading, child) {
    return isLoading ? CircularProgressIndicator() : child!;
  },
  child: RideList(),
)

// ❌ EVITAR: Consumer genérico causa rebuilds desnecessários
Consumer<RideProvider>(
  builder: (context, provider, child) {
    return provider.state.isLoading 
        ? CircularProgressIndicator() 
        : RideList();
  },
)
```

## 🧪 Padrões de Teste

### Unit Tests
```dart
// Arquivo: test/unit/cache_service_test.dart
// Propósito: Validar lógica de cache de chaves e expiração.
// Camadas/Dependências: core/storage/cache_service.dart; mocks de storage.
// Responsabilidades: Garantir invariantes de TTL e invalidação.
// Pontos de extensão: Fakes para storage e relógio controlado.

void main() {
  group('CacheService', () {
    late CacheService cache;
    late FakeClock clock;

    setUp(() {
      // TEST: Relógio controlado para simular avanço de tempo.
      clock = FakeClock();
      cache = CacheService(clock: clock);
    });

    test('salva e lê valor dentro do TTL', () async {
      await cache.set('k', 'v', ttl: Duration(seconds: 10));
      expect(await cache.get('k'), 'v');

      // Avança menos que o TTL; ainda válido.
      clock.advance(Duration(seconds: 5));
      expect(await cache.get('k'), 'v');
    });

    test('expira valor após TTL', () async {
      await cache.set('k', 'v', ttl: Duration(seconds: 2));
      clock.advance(Duration(seconds: 3));
      expect(await cache.get('k'), isNull);
    });
  });
}
```

### Widget Tests
```dart
void main() {
  group('LocationCard Widget', () {
    testWidgets('exibe loading quando localização não disponível', (tester) async {
      final mockLocationService = MockLocationService();
      when(mockLocationService.currentAddress).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LocationService>(
            create: (_) => mockLocationService,
            child: LocationCard(),
          ),
        ),
      );

      expect(find.text('Obtendo localização...'), findsOneWidget);
    });
  });
}
```

### Integration Tests
```dart
void main() {
  group('Ride Flow Integration', () {
    testWidgets('fluxo completo de solicitação de corrida', (tester) async {
      // Setup da aplicação com providers
      await tester.pumpWidget(MyApp());

      // Navegar para home
      expect(find.text('Defina seu preço!'), findsOneWidget);

      // Tocar em solicitar corrida
      await tester.tap(find.text('Solicitar Corrida'));
      await tester.pumpAndSettle();

      // Preencher origem e destino
      await tester.enterText(find.byKey(Key('origem')), 'Casa');
      await tester.enterText(find.byKey(Key('destino')), 'Trabalho');

      // Confirmar solicitação
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      // Verificar redirecionamento para corridas
      expect(find.text('Aguardando ofertas...'), findsOneWidget);
    });
  });
}
```

## ⚡ Performance Guidelines

### Otimizações de Build
```dart
// ✅ BOM: Builder com const constructor
class OptimizedWidget extends StatelessWidget {
  const OptimizedWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.location_on), // const evita rebuild
        SizedBox(height: 16),
      ],
    );
  }
}

// ✅ BOM: ListView.builder para listas longas
ListView.builder(
  itemCount: rides.length,
  itemBuilder: (context, index) {
    final ride = rides[index];
    return RideCard(ride: ride, key: ValueKey(ride.id));
  },
)

// ❌ EVITAR: Column com muitos filhos
Column(
  children: rides.map((ride) => RideCard(ride: ride)).toList(),
)
```

### Cache Strategy
```dart
class CacheService {
  final Map<String, CacheEntry> _memoryCache = {};
  final SharedPreferences _prefs;
  
  /// Cache com TTL e persistência opcional
  Future<void> set(
    String key, 
    dynamic value, {
    Duration? ttl,
    bool persist = false,
  }) async {
    final entry = CacheEntry(
      value: value,
      createdAt: DateTime.now(),
      ttl: ttl,
    );
    
    // Cache em memória
    _memoryCache[key] = entry;
    
    // Persistir se solicitado
    if (persist) {
      await _prefs.setString(key, jsonEncode(entry.toJson()));
    }
  }
  
  /// Busca com fallback para cache persistente
  Future<T?> get<T>(String key) async {
    // Verificar cache em memória primeiro
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return memoryEntry.value as T?;
    }
    
    // Fallback para cache persistente
    final persistedData = _prefs.getString(key);
    if (persistedData != null) {
      final entry = CacheEntry.fromJson(jsonDecode(persistedData));
      if (!entry.isExpired) {
        _memoryCache[key] = entry; // Recarregar em memória
        return entry.value as T?;
      }
    }
    
    return null;
  }
}
```

## 🚀 CI/CD Guidelines

### Pre-commit Hooks
```bash
# Scripts úteis em development
#!/bin/bash
# scripts/pre_commit.sh

echo "🔍 Executando análise de código..."
flutter analyze

echo "🧪 Executando testes..."
flutter test

echo "🎨 Verificando formatação..."
flutter format --dry-run --set-exit-if-changed .

echo "✅ Pre-commit checks passed!"
```

### Build Pipeline
```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.8.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Build APK
      run: flutter build apk --release
```

## 🔒 Security Best Practices

### Sensitive Data
```dart
// ❌ NUNCA fazer isso
const String API_KEY = "sk_live_123456789"; // Hard-coded

// ✅ Usar environment variables
class ApiConfig {
  static String get apiKey => 
      const String.fromEnvironment('API_KEY', defaultValue: '');
  
  static String get baseUrl => 
      const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com');
}
```

### Input Validation
```dart
class RideRequest {
  final String origin;
  final String destination;
  final double? suggestedPrice;
  
  RideRequest({
    required this.origin,
    required this.destination,
    this.suggestedPrice,
  }) {
    // Validação de entrada
    if (origin.trim().isEmpty) {
      throw ArgumentError('Origem não pode estar vazia');
    }
    if (destination.trim().isEmpty) {
      throw ArgumentError('Destino não pode estar vazio');
    }
    if (suggestedPrice != null && suggestedPrice! < 0) {
      throw ArgumentError('Preço sugerido deve ser positivo');
    }
  }
}
```

## 📋 Code Review Checklist

### ✅ Checklist Básico
- [ ] Código segue padrões de nomenclatura
- [ ] Documentação adequada (docstrings em métodos públicos)
- [ ] Testes unitários para lógica de negócio
- [ ] Performance otimizada (const, Selector, builders)
- [ ] Tratamento de erros adequado
- [ ] Disposal de resources (subscriptions, controllers)
- [ ] Validação de entrada
- [ ] Logs apropriados (sem print)

### ✅ Arquitetura
- [ ] Separação clara de responsabilidades
- [ ] Injeção de dependência adequada
- [ ] Camadas bem definidas (core, features, shared)
- [ ] Abstração adequada (interfaces quando necessário)

### ✅ UI/UX
- [ ] Responsivo para diferentes tamanhos de tela
- [ ] Accessibility (semantics, contrast)
- [ ] Loading states e feedback visual
- [ ] Tratamento de edge cases

---

## 📞 Suporte ao Desenvolvimento

**Dúvidas sobre padrões?**
1. Consultar este guia
2. Revisar código existente similar
3. Executar `flutter analyze` 
4. Verificar testes existentes como referência

**Ferramentas recomendadas:**
- **VS Code**: Flutter/Dart extensions
- **Lints**: Configurado em `analysis_options.yaml`
- **Testing**: flutter_test + mockito
- **CI/CD**: GitHub Actions configurado