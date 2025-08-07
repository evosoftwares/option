# 📖 Urban Mobility App - InDriver Style - Documentação Completa

> Aplicativo de mobilidade urbana desenvolvido em Flutter onde usuários **definem seus próprios preços** para corridas, seguindo o modelo inovador do InDriver.

---

## 📑 Índice

1. [🚀 Visão Geral](#-visão-geral)
2. [⚡ Quick Start](#-quick-start)
3. [🛠️ Configuração Completa](#️-configuração-completa)
4. [🏗️ Arquitetura e Desenvolvimento](#️-arquitetura-e-desenvolvimento)
5. [🧪 Testes e CI/CD](#-testes-e-cicd)
6. [🔒 Segurança e Performance](#-segurança-e-performance)
7. [📞 Suporte](#-suporte)

---

## 🚀 Visão Geral

### ✨ Características Principais

- 🎯 **Defina seu preço**: Sistema de negociação entre passageiros e motoristas
- 🗺️ **Mapas integrados**: Google Maps com localização em tempo real
- 🏗️ **Arquitetura Enterprise**: Clean Architecture com padrões de qualidade
- ⚡ **Performance otimizada**: Cache inteligente e rebuilds seletivos
- 🎨 **UI/UX moderna**: Material Design 3 com tema claro/escuro

### 🎯 Contexto do Projeto

Este app foi refatorado de uma solução genérica de mobilidade urbana para implementar especificamente o modelo de negócio do InDriver:
- **Passageiros** definem preços iniciais
- **Motoristas** fazem ofertas competitivas  
- **Sistema** promove negociação transparente

### 📱 Funcionalidades Core

- **🏠 Home**: Solicitação rápida de corridas com preço personalizado
- **🗺️ Mapas**: Visualização de motoristas próximos e rotas
- **🚗 Rides**: Sistema de ofertas, acompanhamento e histórico
- **👤 Perfil**: Configurações de usuário e motorista (taxas por km)

### 🚀 Tecnologias

**Core:** Flutter 3.8+, Dart 3.0+  
**Estado:** Provider + get_it  
**Mapas:** google_maps_flutter + geolocator  
**UI:** Material Design 3 + google_fonts  

### 📊 Performance

- **Hot Restart**: < 2s | **Cold Start**: < 5s
- **Memory**: < 100MB | **APK Size**: < 50MB
- **Otimizações**: Selective rebuilds, cache inteligente, lazy loading

---

## ⚡ Quick Start

### Instalação Rápida

```bash
# Clone e configure
git clone https://github.com/evosoftwares/option.git
cd option/urban_mobility_app
flutter pub get

# Execute
flutter run
```

### Comandos Essenciais

```bash
# Desenvolvimento
flutter analyze              # Análise de código
flutter test                 # Executar testes
flutter format .             # Formatação

# Build
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

**⚠️ Configuração adicional necessária:** Google Maps API e permissões (veja seção completa abaixo).

---

## 🛠️ Configuração Completa

### 📋 Pré-requisitos

#### Essenciais
- **Flutter SDK 3.8+** - [Instalação oficial](https://docs.flutter.dev/get-started/install)
- **Dart SDK 3.0+** - Incluído com Flutter
- **Android Studio** - Para desenvolvimento Android
- **VS Code** - Editor recomendado

#### Plataforma Específica
- **Android**: Android SDK, NDK
- **iOS**: Xcode 14+ (macOS apenas)
- **Google Maps API Key** - [Google Cloud Console](https://console.cloud.google.com/)

### 🗺️ Configuração do Google Maps

#### 1. Obter API Key
1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Crie um projeto ou selecione existente
3. Ative as APIs:
   - Maps SDK for Android
   - Maps SDK for iOS  
   - Places API
   - Geocoding API
4. Crie credenciais → API Key
5. Configure restrições de segurança

#### 2. Configurar no Android
Edite `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
    <meta-data 
        android:name="com.google.android.geo.API_KEY"
        android:value="SUA_API_KEY_AQUI"/>
</application>
```

#### 3. Configurar no iOS
Edite `ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("SUA_API_KEY_AQUI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 📱 Setup Android

#### Configuração do Projeto
- **NDK Version**: 27.0.12077973 (configurado)
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Compile SDK**: 34

#### Permissões de Localização ✅
Já configurado em `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Permissões obrigatórias -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Permissões opcionais -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

#### Emuladores e Execução
```bash
# Listar emuladores
flutter emulators

# Iniciar emulador específico (recomendado: Pixel 6 API 34)
flutter emulators --launch Pixel_6_API_34

# Executar no emulador
flutter run -d emulator-5554

# Hot reload durante desenvolvimento
r     # Hot reload
R     # Hot restart
h     # Listar comandos
q     # Quit
```

### 🍎 Setup iOS

#### Pré-requisitos
- **macOS** (obrigatório)
- **Xcode 14+**
- **CocoaPods** instalado

#### Configuração
```bash
# Navegar para iOS
cd ios

# Instalar dependências
pod install

# Abrir projeto no Xcode
open Runner.xcworkspace
```

#### Configurações no Xcode
1. **Bundle Identifier**: `com.urbanmobility.urban_mobility_app`
2. **Team**: Selecionar team de desenvolvimento
3. **Deployment Target**: iOS 12.0+

#### Permissões de Localização
Edite `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Este app precisa de acesso à localização para mostrar sua posição no mapa e encontrar corridas próximas.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Este app precisa de acesso à localização para rastrear corridas em andamento e otimizar a experiência.</string>
```

### 🔧 Verificação e Testes

#### Teste de Localização
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Verificar serviços de localização
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  print('Localização habilitada: $serviceEnabled');
  
  // Verificar permissões
  final permission = await Geolocator.checkPermission();
  print('Permissão atual: $permission');
  
  runApp(MyApp());
}
```

#### Testes no Dispositivo Físico

**Android:**
```bash
# Habilitar modo desenvolvedor: Configurações → Sobre o telefone → Tocar 7x em "Número da versão"
# Habilitar depuração USB: Configurações → Opções do desenvolvedor → Depuração USB
adb devices
flutter run -d <device-id>
```

**iOS:**
```bash
# Conectar iPhone via USB e confiar no computador
flutter run -d <device-id>
```

### 🐛 Troubleshooting

#### Problemas Comuns Android
- **"No location permissions"** → ✅ Resolvido - Permissões configuradas
- **Build falha** → `flutter clean && flutter pub get`
- **Emulador não inicia** → `flutter emulators --create --name novo_emulador`

#### Problemas Comuns iOS
- **CocoaPods errors** → `cd ios && pod deintegrate && pod install`
- **Certificado inválido** → Xcode → Preferences → Accounts → Adicionar Apple ID

#### Problemas de Localização
- **Serviços desabilitados** → Configurações → Localização → Ativar
- **Permissões negadas** → Configurações → Apps → Urban Mobility → Permissões → Localização
- **Permissões permanentemente negadas** → Reinstalar o app

### 🚀 Build para Produção

#### Android
```bash
# Build release
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Build para Play Store (AAB)
flutter build appbundle --release
```

#### iOS
```bash
# Build release
flutter build ios --release

# Archive no Xcode para App Store
# Product → Archive no Xcode
```

---

## 🏗️ Arquitetura e Desenvolvimento

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

**Padrões:** Service Locator, Provider Pattern, Repository Pattern, Clean Architecture

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

### 📝 Padrões de Comentários

#### Cabeçalho de Arquivo
```dart
// Arquivo: lib/core/network/api_client.dart
// Propósito: Cliente HTTP centralizado com autenticação, timeouts e retries.
// Camadas/Dependências: core/network; integra com core/storage para tokens.
// Responsabilidades: Executar requisições REST, mapear erros e telemetria.
// Pontos de extensão: Injeção via Service Locator; sobrescrever interceptadores.
```

#### Docstrings com ///
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

#### Tags Padronizadas
```dart
// TODO: Extrair política de retry para Strategy; pronto quando ApiClient aceitar injeção.
// FIXME: Evitar leak ao não cancelar subscription em dispose; analisar uso de auto-cancel.
// NOTE: Esta normalização segue o backend v2; alterar ao migrar para v3.
// PERF: Cachear resposta por 30s reduz chamadas em ~40% sob carga.
// TEST: Mockar LocationProvider para emitir sequência de pontos com jitter controlado.
```

### 🎯 Padrões de Widget

#### StatefulWidget com Subscription
```dart
/// Card que exibe a localização atual do usuário.
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
    _sub = context.read<LocationService>().positions.listen((pos) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

#### Provider Usage Patterns
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

### ⚡ Performance Guidelines

#### Otimizações de Build
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

#### Cache Strategy
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

---

## 🧪 Testes e CI/CD

### Unit Tests
```dart
// Arquivo: test/unit/cache_service_test.dart
// Propósito: Validar lógica de cache de chaves e expiração.

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

### CI/CD Pipeline

#### Pre-commit Hooks
```bash
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

#### GitHub Actions
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

---

## 🔒 Segurança e Performance

### 🔐 Considerações de Segurança

#### API Keys
- ❌ **Nunca committar** API keys no código
- ✅ **Usar** environment variables ou arquivos de configuração locais
- ✅ **Configurar** restrições no Google Cloud Console

#### Sensitive Data
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

#### Input Validation
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

#### Permissões
- ✅ Solicitar permissões contextualizadas
- ✅ Explicar por que são necessárias
- ✅ Implementar fallbacks graciais

#### Build Release
- ✅ Habilitar ofuscação de código
- ✅ Remover logs de debug
- ✅ Validar certificados de assinatura

### 📊 Performance e Otimização

#### Configurações Recomendadas
```dart
// Configuração de localização otimizada
final position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
  timeLimit: Duration(seconds: 10),
);

// Configuração de cache
final cacheOptions = CacheOptions(
  maxAge: Duration(minutes: 5),
  maxStale: Duration(minutes: 15),
);
```

#### Métricas Esperadas
- **Tempo de build inicial**: 15-20s
- **Hot reload**: <3s
- **Uso de memória**: <150MB (Android), <100MB (iOS)
- **Tamanho do app**: <50MB

### 📋 Code Review Checklist

#### ✅ Checklist Básico
- [ ] Código segue padrões de nomenclatura
- [ ] Documentação adequada (docstrings em métodos públicos)
- [ ] Testes unitários para lógica de negócio
- [ ] Performance otimizada (const, Selector, builders)
- [ ] Tratamento de erros adequado
- [ ] Disposal de resources (subscriptions, controllers)
- [ ] Validação de entrada
- [ ] Logs apropriados (sem print)

#### ✅ Arquitetura
- [ ] Separação clara de responsabilidades
- [ ] Injeção de dependência adequada
- [ ] Camadas bem definidas (core, features, shared)
- [ ] Abstração adequada (interfaces quando necessário)

#### ✅ UI/UX
- [ ] Responsivo para diferentes tamanhos de tela
- [ ] Accessibility (semantics, contrast)
- [ ] Loading states e feedback visual
- [ ] Tratamento de edge cases

---

## 🤝 Contribuição

1. **Fork** → **Branch** → **Commit** → **Push** → **Pull Request**
2. Siga os padrões documentados neste guia
3. Execute testes antes de enviar
4. Use as ferramentas recomendadas:
   - **VS Code**: Flutter/Dart extensions
   - **Lints**: Configurado em `analysis_options.yaml`
   - **Testing**: flutter_test + mockito
   - **CI/CD**: GitHub Actions configurado

---

## 📞 Suporte

### Problemas de Configuração
1. Verificar este guia
2. Consultar logs: `flutter logs`
3. Testar em dispositivo físico
4. Verificar versões: `flutter doctor`

### Dúvidas sobre Padrões
1. Consultar seções de arquitetura e desenvolvimento
2. Revisar código existente similar
3. Executar `flutter analyze` 
4. Verificar testes existentes como referência

### Status do Projeto
**Status**: ✅ Configurado e funcionando  
**Última atualização**: $(date)  
**Versão**: 1.0.0

---

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

---

**Desenvolvido com ❤️ pela EvoSoftwares**