/* [DI] Service Locator para injeção de dependências */
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../shared/services/location_service_optimized.dart';
import '../network/api_client.dart';
import '../storage/cache_service.dart';
import '../utils/logger.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Core services
  sl.registerLazySingleton<AppLogger>(() => AppLogger());
  sl.registerLazySingleton<CacheService>(() => CacheService(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl(), sl()));

  // Location services
  sl.registerLazySingleton<LocationServiceOptimized>(
    () => LocationServiceOptimized(),
  );

  // Initialize services that need setup
  await sl<CacheService>().init();
  sl<AppLogger>().info('Service Locator initialized successfully');
}

Future<void> resetServiceLocator() async {
  await sl.reset();
  await setupServiceLocator();
}