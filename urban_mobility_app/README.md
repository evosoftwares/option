# 🚗 Urban Mobility App - InDriver Style

Um aplicativo de mobilidade urbana estilo InDriver desenvolvido em Flutter, onde os usuários podem **definir seu próprio preço** para corridas.

## ✨ Características Principais

- 🎯 **Defina seu preço**: Sistema de negociação de preços entre passageiros e motoristas
- 🗺️ **Mapas integrados**: Google Maps com localização em tempo real
- 🏗️ **Arquitetura Enterprise**: Clean Architecture com padrões de qualidade
- ⚡ **Performance otimizada**: Cache inteligente e rebuilds seletivos
- 🎨 **UI/UX moderna**: Material Design 3 com tema claro/escuro
- 🧪 **Testes abrangentes**: Cobertura de testes unitários e de widget

## 🏗️ Arquitetura

### Clean Architecture
```
lib/
├── core/                    # Funcionalidades centrais
│   ├── constants/          # Constantes da aplicação
│   ├── di/                 # Injeção de dependência
│   ├── network/            # Cliente HTTP otimizado
│   ├── storage/            # Sistema de cache
│   └── utils/              # Utilitários (logging, etc.)
├── features/               # Funcionalidades por domínio
│   ├── auth/              # Autenticação
│   ├── home/              # Tela inicial
│   ├── map/               # Mapas e navegação
│   ├── profile/           # Perfil do usuário
│   ├── rides/             # Gerenciamento de corridas
│   └── transport/         # Transporte público
└── shared/                # Serviços compartilhados
    └── services/          # LocationService, etc.
```

### Padrões Implementados
- **Service Locator**: Injeção de dependência com `get_it`
- **Provider Pattern**: Gerenciamento de estado reativo
- **Repository Pattern**: Abstração de dados
- **Cache Strategy**: Cache em memória + persistente
- **Error Handling**: Tratamento estruturado de erros

## 🚀 Tecnologias

### Core
- **Flutter 3.8+**: Framework multiplataforma
- **Dart 3.0+**: Linguagem de programação

### Dependências Principais
- `provider`: Gerenciamento de estado
- `go_router`: Navegação declarativa
- `google_maps_flutter`: Integração com Google Maps
- `geolocator`: Serviços de localização
- `get_it`: Injeção de dependência
- `shared_preferences`: Armazenamento local
- `http`: Cliente HTTP

### UI/UX
- `google_fonts`: Tipografia personalizada
- `lottie`: Animações
- `flutter_svg`: Ícones vetoriais

## 📱 Funcionalidades

### 🏠 Tela Inicial
- Localização atual do usuário
- Histórico de corridas recentes
- Acesso rápido para solicitar corrida

### 🗺️ Mapas
- Visualização em tempo real
- Marcadores de motoristas disponíveis
- Cálculo de rotas otimizadas

### 🚗 Corridas
- Solicitação de corrida com preço personalizado
- Acompanhamento em tempo real
- Histórico completo

### 👤 Perfil
- Informações do usuário
- Configurações da conta
- Histórico de avaliações

### 🚌 Transporte Público
- Informações de ônibus, metrô e bike
- Rotas e horários
- Integração com sistemas locais

## 🛠️ Configuração do Ambiente

### Pré-requisitos
- Flutter SDK 3.8+
- Dart SDK 3.0+
- Android Studio / VS Code
- Google Maps API Key

### Instalação
```bash
# Clone o repositório
git clone https://github.com/evosoftwares/option.git
cd option/urban_mobility_app

# Instale as dependências
flutter pub get

# Configure as chaves de API
# Adicione sua Google Maps API Key em:
# - android/app/src/main/AndroidManifest.xml
# - ios/Runner/AppDelegate.swift

# Execute o projeto
flutter run
```

### Configuração do Google Maps
1. Obtenha uma API Key no [Google Cloud Console](https://console.cloud.google.com/)
2. Ative as APIs: Maps SDK, Places API, Geocoding API
3. Configure as chaves nos arquivos de configuração

## 🧪 Testes

```bash
# Executar todos os testes
flutter test

# Testes com cobertura
flutter test --coverage

# Testes específicos
flutter test test/unit/cache_service_test.dart
```

## 📊 Performance

### Otimizações Implementadas
- **Selective Rebuilds**: Uso de `Selector` em vez de `Consumer`
- **Cache Strategy**: Cache em memória + disco com expiração
- **Lazy Loading**: Carregamento sob demanda
- **Image Optimization**: Cache de imagens de rede
- **Memory Management**: Dispose adequado de recursos

### Métricas
- **Hot Restart**: < 2s (otimizado)
- **Cold Start**: < 5s
- **Memory Usage**: < 100MB
- **APK Size**: < 50MB

## 🔧 Scripts Úteis

```bash
# Análise de código
flutter analyze

# Formatação
flutter format .

# Build para produção
flutter build apk --release
flutter build ios --release
flutter build web --release

# Atualizar dependências
flutter pub upgrade
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👥 Equipe

- **EvoSoftwares** - Desenvolvimento e arquitetura

## 🔗 Links Úteis

- [Documentação Flutter](https://docs.flutter.dev/)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- [Provider Pattern](https://pub.dev/packages/provider)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Desenvolvido com ❤️ pela EvoSoftwares**
