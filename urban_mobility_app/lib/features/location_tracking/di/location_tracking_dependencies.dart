import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Data Layer
import '../data/data_sources/location_data_source.dart';
import '../data/repositories/location_repository_impl.dart';

// Domain Layer
import '../domain/repositories/location_repository.dart';
import '../domain/use_cases/get_current_location.dart';
import '../domain/use_cases/start_location_tracking.dart';
import '../domain/use_cases/stop_location_tracking.dart';

// Presentation Layer
import '../presentation/providers/location_tracking_provider.dart';

/// Configuração de dependências para o módulo de rastreamento de localização
/// 
/// Implementa o padrão de injeção de dependência usando Provider
/// para garantir baixo acoplamento e alta testabilidade.
class LocationTrackingDependencies {
  /// Configura todos os providers necessários para o módulo
  static List<SingleChildWidget> getProviders() {
    return [
      // Data Sources
      Provider<LocationDataSource>(
        create: (_) => GeolocatorLocationDataSource(),
      ),
      
      // Repositories
      ProxyProvider<LocationDataSource, LocationRepository>(
        update: (_, dataSource, __) => LocationRepositoryImpl(dataSource),
      ),
      
      // Use Cases
      ProxyProvider<LocationRepository, GetCurrentLocationUseCase>(
        update: (_, repository, __) => GetCurrentLocationUseCase(repository),
      ),
      
      ProxyProvider<LocationRepository, StartLocationTrackingUseCase>(
        update: (_, repository, __) => StartLocationTrackingUseCase(repository),
      ),
      
      ProxyProvider<LocationRepository, StopLocationTrackingUseCase>(
        update: (_, repository, __) => StopLocationTrackingUseCase(repository),
      ),
      
      // Providers (State Management)
      ChangeNotifierProxyProvider3<GetCurrentLocationUseCase, StartLocationTrackingUseCase,
          StopLocationTrackingUseCase, LocationTrackingProvider>(
        create: (_) => LocationTrackingProvider(
          GetCurrentLocationUseCase(LocationRepositoryImpl(GeolocatorLocationDataSource())),
          StartLocationTrackingUseCase(LocationRepositoryImpl(GeolocatorLocationDataSource())),
          StopLocationTrackingUseCase(LocationRepositoryImpl(GeolocatorLocationDataSource())),
        ),
        update: (_, getCurrentLocation, startTracking, stopTracking, previous) {
          // Reutilizar o provider anterior se existir, caso contrário criar novo
          return previous ?? LocationTrackingProvider(
            getCurrentLocation,
            startTracking,
            stopTracking,
          );
        },

      ),
    ];
  }
  
  /// Configura providers para testes com mocks
  static List<SingleChildWidget> getTestProviders({
    LocationDataSource? mockDataSource,
    LocationRepository? mockRepository,
    GetCurrentLocationUseCase? mockGetCurrentLocation,
    StartLocationTrackingUseCase? mockStartTracking,
    StopLocationTrackingUseCase? mockStopTracking,
  }) {
    return [
      // Data Sources
      Provider<LocationDataSource>(
        create: (_) => mockDataSource ?? GeolocatorLocationDataSource(),
      ),
      
      // Repositories
      Provider<LocationRepository>(
        create: (_) => mockRepository ?? LocationRepositoryImpl(
          mockDataSource ?? GeolocatorLocationDataSource(),
        ),
      ),
      
      // Use Cases
      Provider<GetCurrentLocationUseCase>(
        create: (context) => mockGetCurrentLocation ?? GetCurrentLocationUseCase(
          context.read<LocationRepository>(),
        ),
      ),
      
      Provider<StartLocationTrackingUseCase>(
        create: (context) => mockStartTracking ?? StartLocationTrackingUseCase(
          context.read<LocationRepository>(),
        ),
      ),
      
      Provider<StopLocationTrackingUseCase>(
        create: (context) => mockStopTracking ?? StopLocationTrackingUseCase(
          context.read<LocationRepository>(),
        ),
      ),
      
      // Providers (State Management)
      ChangeNotifierProxyProvider3<GetCurrentLocationUseCase, StartLocationTrackingUseCase,
          StopLocationTrackingUseCase, LocationTrackingProvider>(
        create: (_) => LocationTrackingProvider(
          mockGetCurrentLocation ?? GetCurrentLocationUseCase(LocationRepositoryImpl(GeolocatorLocationDataSource())),
          mockStartTracking ?? StartLocationTrackingUseCase(LocationRepositoryImpl(GeolocatorLocationDataSource())),
          mockStopTracking ?? StopLocationTrackingUseCase(LocationRepositoryImpl(GeolocatorLocationDataSource())),
        ),
        update: (_, getCurrentLocation, startTracking, stopTracking, previous) {
          return previous ?? LocationTrackingProvider(
            getCurrentLocation,
            startTracking,
            stopTracking,
          );
        },
      ),
    ];
  }
}

/// Extensão para facilitar o acesso aos providers
extension LocationTrackingContext on BuildContext {
  /// Obtém o provider de rastreamento de localização
  LocationTrackingProvider get locationTracking => read<LocationTrackingProvider>();
  
  /// Observa mudanças no provider de rastreamento de localização
  LocationTrackingProvider get watchLocationTracking => watch<LocationTrackingProvider>();
  
  /// Obtém o repositório de localização
  LocationRepository get locationRepository => read<LocationRepository>();
  
  /// Obtém o use case de localização atual
  GetCurrentLocationUseCase get getCurrentLocationUseCase => read<GetCurrentLocationUseCase>();
  
  /// Obtém o use case de iniciar rastreamento
  StartLocationTrackingUseCase get startLocationTrackingUseCase => read<StartLocationTrackingUseCase>();
  
  /// Obtém o use case de parar rastreamento
  StopLocationTrackingUseCase get stopLocationTrackingUseCase => read<StopLocationTrackingUseCase>();
}