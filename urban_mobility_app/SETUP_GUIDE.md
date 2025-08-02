# 🛠️ Setup Guide - Urban Mobility App

Guia completo de configuração do ambiente de desenvolvimento para Android e iOS.

## 📋 Pré-requisitos

### Essenciais
- **Flutter SDK 3.8+** - [Instalação oficial](https://docs.flutter.dev/get-started/install)
- **Dart SDK 3.0+** - Incluído com Flutter
- **Android Studio** - Para desenvolvimento Android
- **VS Code** - Editor recomendado

### Plataforma Específica
- **Android**: Android SDK, NDK
- **iOS**: Xcode 14+ (macOS apenas)
- **Google Maps API Key** - [Google Cloud Console](https://console.cloud.google.com/)

## 🗺️ Configuração do Google Maps

### 1. Obter API Key
1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Crie um projeto ou selecione existente
3. Ative as APIs:
   - Maps SDK for Android
   - Maps SDK for iOS  
   - Places API
   - Geocoding API
4. Crie credenciais → API Key
5. Configure restrições de segurança

### 2. Configurar no Android
Edite `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
    <meta-data 
        android:name="com.google.android.geo.API_KEY"
        android:value="SUA_API_KEY_AQUI"/>
</application>
```

### 3. Configurar no iOS
Edite `ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("SUA_API_KEY_AQUI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 📱 Setup Android

### Configuração do Projeto
- **NDK Version**: 27.0.12077973 (configurado)
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Compile SDK**: 34

### Permissões de Localização ✅
Já configurado em `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Permissões obrigatórias -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Permissões opcionais -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### Emuladores Disponíveis
```bash
# Listar emuladores
flutter emulators

# Iniciar emulador específico
flutter emulators --launch Pixel_6_API_34

# Executar no emulador
flutter run -d emulator-5554
```

**Recomendado**: Pixel 6 API 34 (Android 14)

### Comandos de Desenvolvimento
```bash
# Hot reload durante desenvolvimento
r     # Hot reload
R     # Hot restart
h     # Listar comandos
q     # Quit

# Debug e análise
flutter logs
flutter run --profile
flutter build apk --debug
```

## 🍎 Setup iOS

### Pré-requisitos
- **macOS** (obrigatório)
- **Xcode 14+**
- **CocoaPods** instalado

### Configuração
```bash
# Navegar para iOS
cd ios

# Instalar dependências
pod install

# Abrir projeto no Xcode
open Runner.xcworkspace
```

### Configurações no Xcode
1. **Bundle Identifier**: `com.urbanmobility.urban_mobility_app`
2. **Team**: Selecionar team de desenvolvimento
3. **Deployment Target**: iOS 12.0+

### Permissões de Localização
Edite `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Este app precisa de acesso à localização para mostrar sua posição no mapa e encontrar corridas próximas.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Este app precisa de acesso à localização para rastrear corridas em andamento e otimizar a experiência.</string>
```

## 🔧 Verificação e Testes

### Teste de Localização
```dart
// Código para testar em debug
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Verificar serviços de localização
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  print('Localização habilitada: $serviceEnabled');
  
  // Verificar permissões
  final permission = await Geolocator.checkPermission();
  print('Permissão atual: $permission');
  
  runApp(MyApp());
}
```

### Testes no Dispositivo Físico

#### Android
```bash
# Habilitar modo desenvolvedor
# Configurações → Sobre o telefone → Tocar 7x em "Número da versão"

# Habilitar depuração USB
# Configurações → Opções do desenvolvedor → Depuração USB

# Conectar via USB e executar
adb devices
flutter run -d <device-id>
```

#### iOS
```bash
# Conectar iPhone via USB
# Confiar no computador quando solicitado

# Executar no dispositivo
flutter run -d <device-id>
```

## 🐛 Troubleshooting

### Problemas Comuns Android

#### "No location permissions are defined"
✅ **Resolvido** - Permissões já configuradas no AndroidManifest.xml

#### Build falha
```bash
# Limpar cache
flutter clean
flutter pub get

# Rebuild
flutter build apk --debug
```

#### Emulador não inicia
```bash
# Verificar emuladores
flutter emulators

# Criar novo se necessário
flutter emulators --create --name novo_emulador
```

### Problemas Comuns iOS

#### CocoaPods errors
```bash
cd ios
pod deintegrate
pod install
```

#### Certificado inválido
1. Xcode → Preferences → Accounts
2. Adicionar Apple ID
3. Selecionar team no projeto

### Problemas de Localização

#### Serviços desabilitados
**Sintoma**: "Serviços de localização estão desabilitados"
**Solução**: Configurações → Localização → Ativar

#### Permissões negadas
**Sintoma**: "Permissões de localização foram negadas"
**Solução**: Configurações → Apps → Urban Mobility → Permissões → Localização

#### Permissões permanentemente negadas
**Solução**: Reinstalar o app ou configurar manualmente nas permissões

## 📊 Performance e Otimização

### Configurações Recomendadas
```dart
// Configuração de localização otimizada
final position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
  timeLimit: Duration(seconds: 10),
);

// Configuração de cache
final cacheOptions = CacheOptions(
  maxAge: Duration(minutes: 5),
  maxStale: Duration(minutes: 15),
);
```

### Métricas Esperadas
- **Tempo de build inicial**: 15-20s
- **Hot reload**: <3s
- **Uso de memória**: <150MB (Android), <100MB (iOS)
- **Tamanho do app**: <50MB

## 🚀 Build para Produção

### Android
```bash
# Build release
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Build para Play Store (AAB)
flutter build appbundle --release
```

### iOS
```bash
# Build release
flutter build ios --release

# Archive no Xcode para App Store
# Product → Archive no Xcode
```

## 🔐 Considerações de Segurança

### API Keys
- ❌ **Nunca committar** API keys no código
- ✅ **Usar** environment variables ou arquivos de configuração locais
- ✅ **Configurar** restrições no Google Cloud Console

### Permissões
- ✅ Solicitar permissões contextualizadas
- ✅ Explicar por que são necessárias
- ✅ Implementar fallbacks graciais

### Build Release
- ✅ Habilitar ofuscação de código
- ✅ Remover logs de debug
- ✅ Validar certificados de assinatura

---

## 📞 Suporte

**Problemas de configuração?**
1. Verificar este guia
2. Consultar logs: `flutter logs`
3. Testar em dispositivo físico
4. Verificar versões: `flutter doctor`

**Status**: ✅ Configurado e funcionando