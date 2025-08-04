import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Serviço responsável pela inicialização e gerenciamento do Supabase
/// 
/// Este serviço centraliza todas as operações relacionadas ao Supabase,
/// incluindo inicialização, autenticação e acesso ao cliente.
class SupabaseService {
  
  SupabaseService._();
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  /// Cliente do Supabase
  SupabaseClient get client => Supabase.instance.client;
  
  /// Verifica se o Supabase foi inicializado
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  /// Inicializa o Supabase com as configurações
  /// 
  /// Deve ser chamado no início da aplicação, preferencialmente no main()
  Future<void> initialize() async {
    try {
      if (!SupabaseConfig.isConfigValid) {
        throw Exception('Configurações do Supabase inválidas');
      }
      
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.anonKey,
        debug: true, // Habilitar logs em desenvolvimento
      );
      
      _isInitialized = true;
      
      print('✅ Supabase inicializado com sucesso');
      print('📍 URL: ${SupabaseConfig.supabaseUrl}');
      print('🆔 Project ID: ${SupabaseConfig.projectId}');
      
    } catch (e) {
      print('❌ Erro ao inicializar Supabase: $e');
      rethrow;
    }
  }
  
  /// Obtém o usuário atual autenticado
  User? get currentUser => client.auth.currentUser;
  
  /// Verifica se há um usuário autenticado
  bool get isAuthenticated => currentUser != null;
  
  /// Stream de mudanças no estado de autenticação
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  /// Realiza login com email e senha
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        print('✅ Login realizado com sucesso: ${response.user!.email}');
      }
      
      return response;
    } catch (e) {
      print('❌ Erro no login: $e');
      rethrow;
    }
  }
  
  /// Realiza cadastro com email e senha
  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      
      if (response.user != null) {
        print('✅ Cadastro realizado com sucesso: ${response.user!.email}');
      }
      
      return response;
    } catch (e) {
      print('❌ Erro no cadastro: $e');
      rethrow;
    }
  }
  
  /// Realiza logout
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      print('✅ Logout realizado com sucesso');
    } catch (e) {
      print('❌ Erro no logout: $e');
      rethrow;
    }
  }
  
  /// Obtém uma referência para uma tabela específica
  SupabaseQueryBuilder from(String table) {
    return client.from(table);
  }
  
  /// Obtém o canal de realtime para uma tabela
  RealtimeChannel channel(String channelName) {
    return client.channel(channelName);
  }
  
  /// Testa a conexão com o Supabase
  Future<bool> testConnection() async {
    try {
      // Tenta fazer uma query simples para testar a conexão
      await client.from('_health_check').select('*').limit(1);
      return true;
    } catch (e) {
      print('❌ Teste de conexão falhou: $e');
      return false;
    }
  }
  
  /// Obtém informações sobre o projeto
  Future<Map<String, dynamic>?> getProjectInfo() async {
    try {
      final response = await client.rpc('get_project_info');
      return response as Map<String, dynamic>?;
    } catch (e) {
      print('❌ Erro ao obter informações do projeto: $e');
      return null;
    }
  }
  
  /// Limpa todos os dados locais e reinicializa
  Future<void> reset() async {
    try {
      await signOut();
      // Aqui você pode adicionar limpeza de cache local se necessário
      print('✅ Reset do Supabase realizado com sucesso');
    } catch (e) {
      print('❌ Erro no reset: $e');
      rethrow;
    }
  }
}