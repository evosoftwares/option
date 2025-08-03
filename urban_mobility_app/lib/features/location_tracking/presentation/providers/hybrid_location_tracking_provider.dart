import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/hybrid_location_dependencies.dart';
import '../../domain/use_cases/get_current_location.dart';
import '../../domain/use_cases/start_location_tracking.dart';
import '../../domain/use_cases/stop_location_tracking.dart';
import '../../domain/repositories/location_repository.dart';
import '../../../../core/services/supabase_service.dart';

/// Provider que configura o sistema híbrido de tracking de localização
/// 
/// Este provider integra o HybridLocationRepository com o sistema existente,
/// permitindo tracking local com sincronização automática no Supabase.
class HybridLocationTrackingProvider extends StatelessWidget {
  final String userId;
  final Widget child;

  const HybridLocationTrackingProvider({
    Key? key,
    required this.userId,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Configura as dependências híbridas
        ...HybridLocationDependencies.configure(
          userId: userId,
          supabaseService: SupabaseService.instance,
        ),
        
        // Casos de uso que usam o repositório híbrido
        Provider<GetCurrentLocationUseCase>(
          create: (context) => GetCurrentLocationUseCase(
            context.read<LocationRepository>(),
          ),
        ),
        
        Provider<StartLocationTrackingUseCase>(
          create: (context) => StartLocationTrackingUseCase(
            context.read<LocationRepository>(),
          ),
        ),
        
        Provider<StopLocationTrackingUseCase>(
          create: (context) => StopLocationTrackingUseCase(
            context.read<LocationRepository>(),
          ),
        ),
      ],
      child: child,
    );
  }
}

/// Extensão para facilitar o acesso aos recursos híbridos
extension HybridLocationTrackingContext on BuildContext {
  /// Obtém o caso de uso para obter localização atual
  GetCurrentLocationUseCase get getCurrentLocationUseCase => 
      read<GetCurrentLocationUseCase>();
  
  /// Obtém o caso de uso para iniciar tracking
  StartLocationTrackingUseCase get startLocationTrackingUseCase => 
      read<StartLocationTrackingUseCase>();
  
  /// Obtém o caso de uso para parar tracking
  StopLocationTrackingUseCase get stopLocationTrackingUseCase => 
      read<StopLocationTrackingUseCase>();
  
  /// Obtém o repositório híbrido diretamente
  LocationRepository get hybridLocationRepository => 
      read<LocationRepository>();
}

/// Exemplo de como usar o sistema híbrido
/// 
/// ```dart
/// // 1. Envolver a aplicação com o provider
/// HybridLocationTrackingProvider(
///   userId: 'user123',
///   child: MyApp(),
/// )
/// 
/// // 2. Usar os casos de uso em qualquer widget
/// class LocationScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return ElevatedButton(
///       onPressed: () async {
///         // Inicia tracking híbrido (local + Supabase)
///         final stream = await context.startLocationTrackingUseCase.execute(
///           TrackingConfig.defaultConfig(),
///         );
///         
///         // Escuta atualizações
///         stream.listen((location) {
///           print('Nova localização: ${location.latitude}, ${location.longitude}');
///           // A localização é automaticamente sincronizada com Supabase
///         });
///       },
///       child: Text('Iniciar Tracking Híbrido'),
///     );
///   }
/// }
/// ```