# COMMENTING_GUIDE.md

Guia sucinto e prático de padronização de comentários para o projeto Flutter.

Compatível com as lints em [`analysis_options.yaml`](urban_mobility_app/analysis_options.yaml), incluindo:
- prefer_single_quotes
- flutter_style_todos
- no_logic_in_create_state
- always_declare_return_types
- type_annotate_public_apis
- evitar prints e códigos mortos

Observação: o arquivo base de lints inclui `package:flutter_lints/flutter.yaml`, que pode impor limites de linha padrão. Evite linhas longas; quebre descrições maiores em múltiplas linhas para garantir compatibilidade.

---

## 1. Cabeçalho por arquivo

Incluir no topo de cada arquivo Dart do app (lib/ e test/) um cabeçalho que descreve objetivo, dependências/camadas, responsabilidades e pontos de extensão. Autor/Data são opcionais e devem ser omitidos se o histórico do Git já for suficiente.

Modelo:

```dart
// Arquivo: path/para/arquivo.dart
// Propósito: Descrever brevemente o que este arquivo implementa.
// Camadas/Dependências: core/network, features/...; mencionar pacotes externos relevantes.
// Responsabilidades: O que este módulo faz e os limites do que NÃO faz.
// Pontos de extensão: Como injetar, como mockar em testes, como estender.
// Autor: opcional
// Data: opcional
```

Exemplo para core (api_client.dart):

```dart
// Arquivo: lib/core/network/api_client.dart
// Propósito: Cliente HTTP centralizado com interceptadores, mapeamento de erros
// e integração com autenticação.
// Camadas/Dependências: core/network; depende de http/dio (conforme implementação),
// integra com core/storage para tokens.
// Responsabilidades: Executar requisições, aplicar timeouts e backoff, normalizar
// respostas de erro.
// Pontos de extensão: Injeção via Service Locator; permitir troca de implementação
// em testes por um Fake/Mock; interceptadores configuráveis.
// Autor: opcional
// Data: opcional
```

Regras:
- Seja objetivo; 4–8 linhas é suficiente.
- Evite incluir detalhes de implementação que mudam com frequência.
- Quebre linhas longas para respeitar o limite de linha.

---

## 2. Docstrings com ///

Use `///` para documentação compatível com dartdoc. Aplique em:
- Classes públicas e privadas relevantes quando contêm lógica.
- Construtores e fábricas, descrevendo parâmetros.
- Métodos públicos: parâmetros nomeados/posicionais, retorno e efeitos colaterais.
- Campos públicos importantes: streams, controllers, singletons.

Diretrizes:
- Frases curtas; primeira linha como resumo. Detalhes adicionais em parágrafos subsequentes.
- Preferir Markdown simples: listas com `-` e exemplos curtos com blocos de código.
- Evitar redundâncias que repitam o óbvio do nome/assinatura.

Exemplo de classe de serviço (LocationService):

```dart
/// Serviço responsável por obter e observar a localização do usuário.
///
/// - Encapsula permissões, cache curto e stream de atualizações.
/// - Pode aplicar filtros de precisão e thresholds de distância.
/// - Expõe erros específicos para facilitar tratamento na UI.
class LocationService {
  /// Cria uma instância do serviço de localização.
  ///
  /// Parâmetros:
  /// - [locationProvider]: fonte de dados de localização subjacente.
  /// - [logger]: logger para rastrear eventos e falhas.
  LocationService({
    required this.locationProvider,
    required this.logger,
  });

  /// Stream de localizações normalizadas.
  ///
  /// Emite valores apenas quando há mudança relevante conforme thresholds.
  Stream<GeoPoint> get positions;

  /// Obtém a última localização conhecida, com timeout.
  ///
  /// Retorna um [GeoPoint] ou lança uma exceção específica em caso de timeout
  /// ou permissão negada. Pode utilizar cache por um curto período para
  /// reduzir consumo.
  Future<GeoPoint> getLastKnown({Duration? timeout});

  /// Inicia a escuta contínua da localização com política de filtro.
  ///
  /// Efeitos colaterais:
  /// - Abre stream interna e gerencia recursos que exigem `dispose`.
  /// - Cancela automaticamente em `dispose` do consumidor quando integrado.
  void startListening();
}
```

Exemplo em construtor e fábrica:

```dart
/// Cria um cliente de API com interceptadores e política de retry.
class ApiClient {
  /// Construtor padrão.
  ///
  /// Parâmetros:
  /// - [baseUrl]: URL base do backend.
  /// - [authTokenProvider]: função assíncrona que retorna token JWT atual.
  /// - [timeout]: timeout por requisição; usa valor padrão quando nulo.
  ApiClient({
    required String baseUrl,
    required Future<String?> Function() authTokenProvider,
    Duration? timeout,
  });

  /// Fábrica que cria um cliente usando configuração padrão do app.
  factory ApiClient.defaultConfig(AppConfig config) {
    // ...
  }
}
```

Exemplo em método público:

```dart
/// Executa uma requisição GET com retry exponencial.
///
/// Parâmetros:
/// - [path]: caminho relativo à base.
/// - [query]: parâmetros de query opcionais.
/// - [maxAttempts]: número máximo de tentativas, mínimo 1.
/// Retorno:
/// - Mapa já decodificado a partir do JSON.
/// Erros:
/// - Lança `ApiTimeoutException` e `ApiUnauthorizedException` conforme o caso.
/// Efeitos colaterais:
/// - Atualiza métricas internas de telemetria.
Future<Map<String, dynamic>> get(
  String path, {
  Map<String, String>? query,
  int maxAttempts = 3,
});
```

---

## 3. Comentários inline com //

Use `//` para explicar pontos não triviais:
- Lógica complexa, erros, retries, timeouts, invalidação de cache.
- Cálculos geoespaciais; integrações com mapas/serviços; stream subscriptions.
- Decisões de design e trade-offs.
- Invariantes, pré/pós-condições.

Evite:
- Repetir o que o código já diz de forma clara.
- Comentários desatualizados; mantenha próximos da lógica que explicam.

Exemplo explicando retry com backoff:

```dart
for (var attempt = 1; attempt <= maxAttempts; attempt++) {
  try {
    return await _send(request);
  } on TimeoutException catch (_) {
    // Aumenta delay exponencialmente com jitter para reduzir thundering herd.
    final base = pow(2, attempt);
    final jitterMs = _random.nextInt(100);
    final delay = Duration(milliseconds: 200 * base.toInt() + jitterMs);
    if (attempt == maxAttempts) rethrow;
    await Future.delayed(delay);
    continue;
  }
}
```

Exemplo marcando invariantes:

```dart
// Pré-condição: token não pode ser nulo neste ponto; validado no login.
final token = await _tokenProvider();
assert(token != null);
```

---

## 4. Tags padronizadas

Seguir `flutter_style_todos`. Formato:

- `// TODO: Descrição clara da ação, critério de pronto e responsável opcional`
- `// FIXME: Problema conhecido, efeito observado e direção de correção`
- `// NOTE: Observação importante para manutenção futura`
- `// PERF: Observação de performance e possível otimização`
- `// TEST: Dica de testes ou mocking`

Exemplos:

```dart
// TODO: Extrair política de retry para Strategy; pronto quando ApiClient aceitar injeção.
```

```dart
// FIXME: Evitar leak ao não cancelar subscription em dispose; analisar uso de auto-cancel.
```

```dart
// NOTE: Esta normalização segue o backend v2; alterar ao migrar para v3.
```

```dart
// PERF: Cachear resposta por 30s reduz chamadas em ~40% sob carga.
```

```dart
// TEST: Mockar LocationProvider para emitir sequência de pontos com jitter controlado.
```

Boas práticas:
- Uma linha inicial objetiva; se precisar, linhas subsequentes curtas.
- Use preferencialmente uma tag por comentário.

---

## 5. Compatibilidade com lints

- `prefer_single_quotes`: use aspas simples em strings dos exemplos.
- `flutter_style_todos`: manter o formato `// TODO: ...` com letra maiúscula e dois pontos.
- `always_declare_return_types` e `type_annotate_public_apis`: tipar membros públicos.
- `no_logic_in_create_state`: evite lógica em `createState`; documente qualquer exceção necessária.
- Evitar `print`; use o logger do projeto.
- `dead_code` é warning: não deixe blocos de código comentados grandes; se inevitável, curto e com justificativa.
- Evite linhas longas; quebre texto em múltiplas linhas.

---

## 6. Exemplos concretos prontos para uso

### 6.1 Cabeçalho para core/api_client.dart

```dart
// Arquivo: lib/core/network/api_client.dart
// Propósito: Cliente HTTP centralizado com autenticação, timeouts e retries.
// Camadas/Dependências: core/network; integra com core/storage para tokens.
// Responsabilidades: Executar requisições REST, mapear erros e telemetria.
// Pontos de extensão: Injeção via Service Locator; sobrescrever interceptadores.
// Autor: opcional
// Data: opcional
```

### 6.2 Docstring para serviço LocationService

```dart
/// Serviço de localização com cache curto e stream de atualizações.
///
/// Lida com permissões, precisão e thresholds de distância.
/// Exibe erros específicos para simplificar a UI.
class LocationService {
  /// Fonte subjacente de localização.
  final LocationProvider locationProvider;

  /// Logger do app para auditoria.
  final Logger logger;

  /// Cria o serviço de localização.
  ///
  /// Parâmetros:
  /// - [locationProvider]: provider real ou mockado em testes.
  /// - [logger]: logger injetado; evitar uso de print.
  LocationService({
    required this.locationProvider,
    required this.logger,
  });

  /// Stream contínua de posições normalizadas.
  Stream<GeoPoint> get positions => locationProvider.positions;

  /// Obtém posição atual com timeout e cache curto.
  Future<GeoPoint> getCurrent({Duration timeout = Duration(seconds: 5)}) async {
    // Tenta usar cache recente para reduzir consumo de bateria e latência.
    // Em fallback, consulta provider com timeout.
    return locationProvider.getCurrent(timeout: timeout);
  }
}
```

### 6.3 Comentário inline explicando retry com backoff

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

### 6.4 Exemplo para StatefulWidget

```dart
/// Card que exibe a localização atual do usuário.
///
/// Props:
/// - [onTap]: callback quando o card é tocado.
/// - [format]: formata o endereço exibido; padrão compacto.
/// Ciclo de vida:
/// - Inicia subscription no `initState` e cancela no `dispose`.
class LocationCard extends StatefulWidget {
  /// Callback do toque no card.
  final VoidCallback? onTap;

  /// Função de formatação do endereço.
  final String Function(Address)? format;

  /// Cria o widget LocationCard.
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
      setState(() {});
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
    return GestureDetector(
      onTap: widget.onTap,
      child: const Text('Localização atual'),
    );
  }
}
```

### 6.5 Exemplo para testes

```dart
// Arquivo: test/unit/cache_service_test.dart
// Propósito: Validar lógica de cache de chaves e expiração.
// Camadas/Dependências: core/storage/cache_service.dart; mocks de storage.
// Responsabilidades: Garantir invariantes de TTL e invalidação.
// Pontos de extensão: Fakes para storage e relógio controlado.

import 'package:flutter_test/flutter_test.dart';

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
      // Pré-condição: cache vazio.
      expect(await cache.get('k'), isNull);

      await cache.set('k', 'v', ttl: const Duration(seconds: 10));
      expect(await cache.get('k'), 'v');

      // Avança menos que o TTL; ainda válido.
      clock.advance(const Duration(seconds: 5));
      expect(await cache.get('k'), 'v');
    });

    test('expira valor após TTL', () async {
      await cache.set('k', 'v', ttl: const Duration(seconds: 2));
      clock.advance(const Duration(seconds: 3));
      expect(await cache.get('k'), isNull);
    });
  });
}
```

---

## 7. Quando comentar vs não comentar

Comentar quando:
- A lógica não é óbvia no primeiro olhar.
- Há dependências externas com contratos relevantes.
- Existem invariantes, pré/pós-condições e efeitos colaterais.
- Decisões arquiteturais e trade-offs precisam de rastro.
- O comportamento de retry, timeouts, cache e subscrições pode surpreender.

Não comentar quando:
- O nome e a assinatura já comunicam claramente.
- O comentário repetiria literalmente o código.
- Seria necessário manter comentário sincronizado com detalhes voláteis.

Dica: prefira nomear melhor variáveis/métodos a explicar o óbvio.

---

## 8. Checklist rápido de conformidade

- Cabeçalho presente e objetivo no topo do arquivo.
- `///` em classes relevantes, construtores, métodos públicos e campos públicos importantes.
- `//` apenas para pontos não triviais; comentários próximos ao código.
- Tags padronizadas: TODO, FIXME, NOTE, PERF, TEST seguindo `flutter_style_todos`.
- Sem `print`; usar logger do projeto.
- Sem blocos grandes de código comentado; evitar dead code.
- Linhas curtas; quebre textos maiores.

---

## 9. Aplicação em arquivos existentes

Sugestões de onde começar:
- core/network/api_client.dart: adicionar cabeçalho, docstrings de construtor/métodos de rede e inline para retry/timeouts.
- shared/services/location_service_optimized.dart: docstrings de serviço e streams.
- core/storage/cache_service.dart: invariantes de TTL e comentários em invalidação.
- core/di/service_locator.dart: NOTE explicando trade-offs de Service Locator.
- features/.../widgets/*.dart: docstrings de props e ciclo de vida.
- test/unit/*: cabeçalhos, TEST e notas de setup/mocks.

---

Ao aplicar este guia, mantenha consistência e objetividade. Comentários devem agregar contexto e reduzir ambiguidade, sem introduzir ruído.
