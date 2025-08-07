// Arquivo: lib/core/constants/app_constants.dart
 // Propósito: Centralizar constantes de configuração, chaves, limites e recursos do app.
 // Camadas/Dependências: core/constants; consumido por core e features; sem dependências externas.
 // Responsabilidades: Oferecer fonte única de verdade para valores estáticos e padronizações.
 // Pontos de extensão: Segregar por domínio (ex.: API, UI, Assets) e permitir override por ambiente se necessário.
 
 /// Constantes gerais da aplicação (UI, tempos, API e validações).
 class AppConstants {
   // Dimensões
   static const double defaultPadding = 16.0;
   static const double smallPadding = 8.0;
   static const double largePadding = 24.0;
   static const double borderRadius = 16.0;
   static const double smallBorderRadius = 8.0;
   static const double iconSize = 24.0;
   static const double smallIconSize = 16.0;
 
   // Durations
   static const Duration animationDuration = Duration(milliseconds: 300);
   static const Duration debounceDelay = Duration(milliseconds: 500);
   static const Duration locationCacheTimeout = Duration(minutes: 5);
   static const Duration networkTimeout = Duration(seconds: 30);
 
   // Limits
   static const int maxRetries = 3;
   static const int maxAddressLines = 2;
   static const int searchResultsLimit = 10;
 
   // Keys
   static const String locationCacheKey = 'cached_location';
   static const String userPreferencesKey = 'user_preferences';
   static const String themeKey = 'theme_mode';
 
   // API
   static const String baseUrl = 'https://api.indriver.com';
   static const String apiVersion = 'v1';
   static const String googleMapsApiKey = 'AIzaSyCoZBZ6RHxpq0EeKa4-UCkwSQrymtRacms';
 
   // Validation
   static const int minPasswordLength = 6;
   static const int maxNameLength = 50;
   static const double minRating = 1.0;
   static const double maxRating = 5.0;
 }
 
 /// Strings estáticas exibidas na UI.
 ///
 /// Dica: se houver internacionalização, migrar estas constantes para ARB.
 class AppStrings {
   // App
   static const String appName = 'InDriver';
   static const String appSlogan = 'Defina seu preço!';
 
   // Navigation
   static const String homeTab = 'Início';
   static const String ridesTab = 'Corridas';
   static const String profileTab = 'Perfil';
 
   // Location
   static const String yourLocation = 'Sua Localização';
   static const String gettingLocation = 'Obtendo localização...';
   static const String locationNotAvailable = 'Localização não disponível';
   static const String locationServicesDisabled =
       'Serviços de localização estão desabilitados.';
   static const String locationPermissionDenied =
       'Permissões de localização foram negadas.';
   static const String locationPermissionDeniedForever =
       'Permissões de localização foram negadas permanentemente.';
 
   // Actions
   static const String tryAgain = 'Tentar Novamente';
   static const String cancel = 'Cancelar';
   static const String confirm = 'Confirmar';
   static const String save = 'Salvar';
   static const String delete = 'Excluir';
 
   // Errors
   static const String genericError = 'Ocorreu um erro inesperado';
   static const String networkError = 'Erro de conexão. Verifique sua internet.';
   static const String timeoutError = 'Tempo limite excedido. Tente novamente.';
 
   // Empty States
   static const String noDataAvailable = 'Nenhum dado disponível';
   static const String noRecentTrips = 'Nenhuma corrida recente';
   static const String noFavorites = 'Nenhum favorito adicionado';
 }
 
 /// Referências de caminhos de assets (ícones, imagens e animações).
 class AppAssets {
   // Icons
   static const String iconPath = 'assets/icons/';
   static const String logoIcon = '${iconPath}logo.svg';
   static const String carIcon = '${iconPath}car.svg';
   static const String mapIcon = '${iconPath}map.svg';
 
   // Images
   static const String imagePath = 'assets/images/';
   static const String emptyStateImage = '${imagePath}empty_state.svg';
   static const String errorImage = '${imagePath}error.svg';
 
   // Animations
   static const String animationPath = 'assets/animations/';
   static const String loadingAnimation = '${animationPath}loading.json';
   static const String successAnimation = '${animationPath}success.json';
 }