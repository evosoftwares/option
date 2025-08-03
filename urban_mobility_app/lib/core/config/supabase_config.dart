/// Configuração do Supabase para o Urban Mobility App
/// 
/// Este arquivo contém as configurações e credenciais necessárias
/// para conectar com o banco de dados Supabase.
class SupabaseConfig {
  /// URL do projeto Supabase
  static const String supabaseUrl = 'https://qlbwacmavngtonauxnte.supabase.co';
  
  /// Project ID do Supabase
  static const String projectId = 'qlbwacmavngtonauxnte';
  
  /// Chave anônima (pública) do Supabase
  /// Usada para operações que não requerem autenticação
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsYndhY21hdm5ndG9uYXV4bnRlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDg3MTYzMzIsImV4cCI6MjAyNDI5MjMzMn0.IPFL2f8dslKK-jU2lYGJJwHcL0ZqOVmTIiTQK5QzF2E';
  
  /// Token secreto do service role
  /// ⚠️ ATENÇÃO: Nunca usar em produção no cliente!
  /// Apenas para desenvolvimento e testes
  static const String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsYndhY21hdm5ndG9uYXV4bnRlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcwODcxNjMzMiwiZXhwIjoyMDI0MjkyMzMyfQ.F9hqR7khKEprPzy72MoipXfrq5tympkIHYkiuf8efNk';
  
  /// Chave pública para publicação
  static const String publishableKey = 'sb_publishable_Fitx3G3viosJqMng_VoiEA_hwBNRlVy';
  
  /// Chave secreta
  /// ⚠️ ATENÇÃO: Manter segura e não expor no cliente!
  static const String secretKey = 'sb_secret_rwlSM2QIeyFBYEQBebiOpw_MJn_QBw4';
  
  /// Configurações de timeout para conexões
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  /// Configurações de realtime
  static const Map<String, dynamic> realtimeConfig = {
    'heartbeatIntervalMs': 30000,
    'reconnectAfterMs': [1000, 2000, 5000, 10000],
    'timeout': 10000,
  };
  
  /// Headers padrão para requisições
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'apikey': anonKey,
    'Authorization': 'Bearer $anonKey',
  };
  
  /// Verifica se as configurações estão válidas
  static bool get isConfigValid {
    return supabaseUrl.isNotEmpty &&
           projectId.isNotEmpty &&
           anonKey.isNotEmpty;
  }
  
  /// Obtém a URL completa para uma tabela específica
  static String getTableUrl(String tableName) {
    return '$supabaseUrl/rest/v1/$tableName';
  }
  
  /// Obtém a URL para realtime
  static String get realtimeUrl {
    return supabaseUrl.replaceFirst('https://', 'wss://') + '/realtime/v1/websocket';
  }
}