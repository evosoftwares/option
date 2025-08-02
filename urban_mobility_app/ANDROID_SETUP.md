# 📱 Configuração Android - Urban Mobility App

## 🚀 Execução no Emulador Android

### Pré-requisitos
- Android Studio instalado
- Android SDK configurado
- Emuladores Android criados

### 📋 Emuladores Disponíveis
```bash
flutter emulators
```

**Emuladores configurados:**
- `Pixel_6_API_34` - Google Pixel 6 (Android 14 - API 34) ✅ **Recomendado**
- `Medium_Phone_API_35` - Telefone Médio (Android 15 - API 35)
- `flutter_emulator` - Emulador Flutter genérico

### 🎯 Iniciando o Emulador

#### Opção 1: Iniciar emulador específico
```bash
# Iniciar Pixel 6 API 34 (recomendado)
flutter emulators --launch Pixel_6_API_34

# Verificar dispositivos conectados
flutter devices
```

#### Opção 2: Executar diretamente
```bash
# Executar no emulador específico
flutter run -d emulator-5554

# Ou deixar o Flutter escolher automaticamente
flutter run
```

### ⚙️ Configurações Aplicadas

#### Android NDK
- **Versão configurada**: `27.0.12077973`
- **Localização**: `android/app/build.gradle.kts`
- **Motivo**: Compatibilidade com plugins mais recentes

#### Configurações do Projeto
```kotlin
android {
    namespace = "com.urbanmobility.urban_mobility_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // ✅ Atualizado
    
    defaultConfig {
        applicationId = "com.urbanmobility.urban_mobility_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

### 🔧 Comandos Úteis Durante Desenvolvimento

#### Hot Reload e Hot Restart
```bash
# Durante a execução, use as teclas:
r  # Hot reload 🔥🔥🔥
R  # Hot restart
h  # Listar comandos disponíveis
d  # Detach (manter app rodando)
c  # Limpar tela
q  # Quit (fechar aplicação)
```

#### Debug e Logs
```bash
# Ver logs do dispositivo
flutter logs

# Análise de performance
flutter run --profile

# Build para release
flutter build apk --release
```

### 📊 Performance no Android

#### Métricas Esperadas
- **Tempo de build inicial**: ~15-20s
- **Hot reload**: <3s
- **Uso de memória**: <150MB
- **Tamanho do APK**: <50MB

#### Otimizações Aplicadas
- ✅ NDK atualizado para compatibilidade
- ✅ Configurações de build otimizadas
- ✅ Proguard habilitado para release
- ✅ Compressão de recursos

### 🐛 Troubleshooting

#### Problema: Emulador não inicia
```bash
# Verificar emuladores disponíveis
flutter emulators

# Criar novo emulador se necessário
flutter emulators --create --name pixel_6_new
```

#### Problema: Build falha
```bash
# Limpar cache
flutter clean
flutter pub get

# Rebuild completo
flutter build apk --debug
```

#### Problema: Hot reload não funciona
```bash
# Restart completo
R  # (durante execução)

# Ou parar e reiniciar
q  # Quit
flutter run -d emulator-5554
```

### 🔐 Configurações de Segurança

#### Permissões Necessárias
- `ACCESS_FINE_LOCATION` - Para localização GPS
- `ACCESS_COARSE_LOCATION` - Para localização de rede
- `INTERNET` - Para mapas e APIs
- `ACCESS_NETWORK_STATE` - Para verificar conectividade

#### Configuração de Release
```bash
# Build assinado para produção
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

### 📱 Testes em Dispositivos Físicos

#### Habilitar Debug USB
1. Configurações → Sobre o telefone
2. Toque 7x em "Número da versão"
3. Configurações → Opções do desenvolvedor
4. Ativar "Depuração USB"

#### Conectar dispositivo
```bash
# Verificar dispositivos
adb devices

# Executar no dispositivo
flutter run -d <device-id>
```

### 🚀 Deploy para Google Play Store

#### Preparação
1. Configurar assinatura de release
2. Atualizar `android/app/build.gradle.kts`
3. Gerar AAB (Android App Bundle)

```bash
# Build para produção
flutter build appbundle --release
```

---

**Status**: ✅ **Configurado e funcionando**  
**Última atualização**: $(date)  
**Emulador testado**: Pixel 6 API 34  
**Versão do Flutter**: $(flutter --version | head -1)