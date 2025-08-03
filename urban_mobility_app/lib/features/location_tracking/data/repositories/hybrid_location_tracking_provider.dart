import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_sources/location_data_source.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/use_cases/get_current_location.dart';
import '../../domain/use_cases/start_location_tracking.dart';
import '../../domain/use_cases/stop_location_tracking.dart';
import 'location_repository_impl.dart';
import '../../../../core/data/repositories/supabase_location_repository.dart';
import 'hybrid_location_repository.dart';

/// Provider para configurar as dependências do sistema híbrido de localização
class HybridLocationTrackingProvider extends StatelessWidget {
  const HybridLocationTrackingProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Data Source Local (Geolocator)
        Provider<LocationDataSource>(
          create: (_) => GeolocatorLocationDataSource(),
        ),
        
        // Repositório Local
        ProxyProvider<LocationDataSource, LocationRepository>(
          update: (_, dataSource, __) => LocationRepositoryImpl(dataSource),
        ),
        
        // Repositório Supabase
        Provider<SupabaseLocationRepository>(
          create: (_) => SupabaseLocationRepository(),
        ),
        
        // Repositório Híbrido Principal
        ProxyProvider2<LocationRepository, SupabaseLocationRepository, HybridLocationRepository>(
          update: (_, localRepo, supabaseRepo, __) => HybridLocationRepository(
            localRepository: localRepo,
            supabaseRepository: supabaseRepo,
            userId: 'user_id_placeholder', // TODO: Obter do contexto de autenticação
          ),
        ),
        
        // Casos de Uso
        ProxyProvider<HybridLocationRepository, GetCurrentLocationUseCase>(
          update: (_, repository, __) => GetCurrentLocationUseCase(repository),
        ),
        
        ProxyProvider<HybridLocationRepository, StartLocationTrackingUseCase>(
          update: (_, repository, __) => StartLocationTrackingUseCase(repository),
        ),
        
        ProxyProvider<HybridLocationRepository, StopLocationTrackingUseCase>(
          update: (_, repository, __) => StopLocationTrackingUseCase(repository),
        ),
      ],
      child: child,
    );
  }
}

/// Extensão para facilitar o acesso aos repositórios e casos de uso
extension HybridLocationTrackingContext on BuildContext {
  /// Repositório híbrido de localização
  HybridLocationRepository get hybridLocationRepository =>
      read<HybridLocationRepository>();
  
  /// Repositório local de localização
  LocationRepository get localLocationRepository =>
      read<LocationRepository>();
  
  /// Repositório Supabase de localização
  SupabaseLocationRepository get supabaseLocationRepository =>
      read<SupabaseLocationRepository>();
  
  /// Caso de uso para obter localização atual
  GetCurrentLocationUseCase get getCurrentLocationUseCase =>
      read<GetCurrentLocationUseCase>();
  
  /// Caso de uso para iniciar rastreamento
  StartLocationTrackingUseCase get startLocationTrackingUseCase =>
      read<StartLocationTrackingUseCase>();
  
  /// Caso de uso para parar rastreamento
  StopLocationTrackingUseCase get stopLocationTrackingUseCase =>
      read<StopLocationTrackingUseCase>();
}