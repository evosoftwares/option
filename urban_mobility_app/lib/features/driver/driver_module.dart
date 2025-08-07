import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/repositories/driver_repository_impl.dart';
import 'domain/repositories/driver_repository.dart';
import 'presentation/providers/driver_main_provider.dart';
import 'data/datasources/driver_local_datasource_impl.dart';
import 'data/datasources/driver_remote_datasource_firestore.dart';

/// Módulo de configuração para a feature do motorista
class DriverModule {
  /// Configura os providers necessários para a feature do motorista
  static void configureProviders() {
    // Este método pode ser usado para configurar dependências se necessário
  }

  /// Cria uma instância do repository de forma assíncrona
  static Future<DriverRepository> createRepository() async {
    final prefs = await SharedPreferences.getInstance();
    
    return DriverRepositoryImpl(
      remoteDatasource: DriverRemoteDatasourceFirestore(),
      localDatasource: DriverLocalDatasourceImpl(prefs),
    );
  }

  /// Cria uma instância do repository de forma assíncrona (para casos que precisam)
  static Future<DriverRepository> createRepositoryAsync() async {
    final prefs = await SharedPreferences.getInstance();
    
    return DriverRepositoryImpl(
      remoteDatasource: DriverRemoteDatasourceFirestore(),
      localDatasource: DriverLocalDatasourceImpl(prefs),
    );
  }

  /// Cria uma instância do provider principal
  static DriverMainProvider createMainProvider(DriverRepository repository) {
    return DriverMainProvider(driverRepository: repository);
  }
}
