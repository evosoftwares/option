import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/data/repositories/supabase_location_repository.dart';
import '../../../../core/services/supabase_service.dart';
import 'hybrid_location_repository.dart';
import 'location_repository_impl.dart';
import '../data_sources/location_data_source.dart';
import '../../domain/repositories/location_repository.dart';

/// Configuração das dependências para o HybridLocationRepository
/// 
/// Este arquivo configura a integração entre o sistema de tracking local
/// e a sincronização com Supabase, criando um repositório híbrido que
/// combina o melhor dos dois mundos.
class HybridLocationDependencies {
  
  /// Configura as dependências para o HybridLocationRepository
  /// 
  /// [userId] - ID do usuário para sincronização com Supabase
  /// [supabaseService] - Instância do serviço Supabase
  static List<Provider> configure({
    required String userId,
    required SupabaseService supabaseService,
  }) {
    return [
      // Repositório Supabase
      Provider<SupabaseLocationRepository>(
        create: (_) => SupabaseLocationRepository(),
      ),
      
      // Data Source local (Geolocator)
      Provider<LocationDataSource>(
        create: (_) => GeolocatorLocationDataSource(),
      ),
      
      // Repositório local
      Provider<LocationRepositoryImpl>(
        create: (context) => LocationRepositoryImpl(
          context.read<LocationDataSource>(),
        ),
      ),
      
      // Repositório híbrido (principal)
      Provider<LocationRepository>(
        create: (context) => HybridLocationRepository(
          localRepository: context.read<LocationRepositoryImpl>(),
          supabaseRepository: context.read<SupabaseLocationRepository>(),
          userId: userId,
        ),
      ),
    ];
  }
  
  /// Configura as dependências para testes com mocks
  /// 
  /// [mockLocalRepository] - Mock do repositório local
  /// [mockSupabaseRepository] - Mock do repositório Supabase
  /// [userId] - ID do usuário para testes
  static List<Provider> configureForTesting({
    required LocationRepository mockLocalRepository,
    required SupabaseLocationRepository mockSupabaseRepository,
    required String userId,
  }) {
    return [
      Provider<SupabaseLocationRepository>.value(
        value: mockSupabaseRepository,
      ),
      Provider<LocationRepository>.value(
        value: HybridLocationRepository(
          localRepository: mockLocalRepository,
          supabaseRepository: mockSupabaseRepository,
          userId: userId,
        ),
      ),
    ];
  }
}

/// Extensão para facilitar o acesso ao HybridLocationRepository
extension HybridLocationContext on BuildContext {
  /// Obtém o repositório híbrido de localização
  LocationRepository get hybridLocationRepository => read<LocationRepository>();
  
  /// Obtém o repositório Supabase de localização
  SupabaseLocationRepository get supabaseLocationRepository => read<SupabaseLocationRepository>();
}