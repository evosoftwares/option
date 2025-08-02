 // Arquivo: lib/core/di/service_locator.dart
 // Propósito: Compor e expor o Service Locator (GetIt) para injeção de dependências.
 // Camadas/Dependências: core/di; integra com core/network, core/storage, core/utils e shared/services.
 // Responsabilidades: Registrar singletons/lazy singletons e inicializar serviços que requerem setup.
 // Pontos de extensão: Adicionar módulos de features e alternar implementações (ex.: mocks em testes).
 
 import 'package:get_it/get_it.dart';
 import 'package:shared_preferences/shared_preferences.dart';
 import 'package:http/http.dart' as http;
 
 import '../../shared/services/location_service_optimized.dart';
 import '../network/api_client.dart';
 import '../storage/cache_service.dart';
 import '../utils/logger.dart';
 
 /// Instância global do Service Locator utilizada em todo o app.
 final GetIt sl = GetIt.instance;
 
 /// Registra dependências do app.
 ///
 /// - Usa lazy singletons para evitar custo de construção antecipado.
 /// - Inicializa serviços que precisam de setup explícito (ex.: cache).
 Future<void> setupServiceLocator() async {
   // Dependências externas (SDKs/Plugins)
   final sharedPreferences = await SharedPreferences.getInstance();
   sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
   sl.registerLazySingleton<http.Client>(() => http.Client());
 
   // Serviços centrais
   sl.registerLazySingleton<AppLogger>(() => AppLogger());
   sl.registerLazySingleton<CacheService>(() => CacheService(sl()));
   sl.registerLazySingleton<ApiClient>(() => ApiClient(sl(), sl()));
 
   // Serviços de localização
   sl.registerLazySingleton<LocationServiceOptimized>(
     () => LocationServiceOptimized(),
   );
 
   // Inicializa serviços que exigem preparação.
   await sl<CacheService>().init();
   sl<AppLogger>().info('Service Locator initialized successfully');
 }
 
 /// Reinicia o Service Locator limpando registros e configurando novamente.
 ///
 /// Efeitos colaterais: descarta instâncias anteriores. Útil para testes ou logout.
 Future<void> resetServiceLocator() async {
   await sl.reset();
   await setupServiceLocator();
 }