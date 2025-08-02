# 🚗 Urban Mobility App - InDriver Style

Aplicativo de mobilidade urbana desenvolvido em Flutter onde usuários **definem seus próprios preços** para corridas, seguindo o modelo inovador do InDriver.

## ✨ Características Principais

- 🎯 **Defina seu preço**: Sistema de negociação entre passageiros e motoristas
- 🗺️ **Mapas integrados**: Google Maps com localização em tempo real
- 🏗️ **Arquitetura Enterprise**: Clean Architecture com padrões de qualidade
- ⚡ **Performance otimizada**: Cache inteligente e rebuilds seletivos
- 🎨 **UI/UX moderna**: Material Design 3 com tema claro/escuro

## 🚀 Quick Start

```bash
# Clone e configure
git clone https://github.com/evosoftwares/option.git
cd option/urban_mobility_app
flutter pub get

# Execute
flutter run
```

**⚠️ Configuração adicional necessária:** Veja [SETUP_GUIDE.md](SETUP_GUIDE.md) para configurar Google Maps API e permissões.

## 🏗️ Arquitetura

```
lib/
├── core/           # Funcionalidades centrais (DI, network, cache)
├── features/       # Módulos por domínio (auth, home, rides, profile)
└── shared/         # Serviços compartilhados (location, etc.)
```

**Padrões:** Service Locator, Provider Pattern, Repository Pattern, Clean Architecture

## 📱 Funcionalidades Core

- **🏠 Home**: Solicitação rápida de corridas com preço personalizado
- **🗺️ Mapas**: Visualização de motoristas próximos e rotas
- **🚗 Rides**: Sistema de ofertas, acompanhamento e histórico
- **👤 Perfil**: Configurações de usuário e motorista (taxas por km)

## 📊 Performance

- **Hot Restart**: < 2s | **Cold Start**: < 5s
- **Memory**: < 100MB | **APK Size**: < 50MB
- **Otimizações**: Selective rebuilds, cache inteligente, lazy loading

## 🛠️ Desenvolvimento

```bash
# Desenvolvimento
flutter analyze              # Análise de código
flutter test                 # Executar testes
flutter format .             # Formatação

# Build
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

**📖 Para padrões de código:** Veja [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)

## 🚀 Tecnologias

**Core:** Flutter 3.8+, Dart 3.0+  
**Estado:** Provider + get_it  
**Mapas:** google_maps_flutter + geolocator  
**UI:** Material Design 3 + google_fonts  

## 📚 Documentação

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Configuração completa Android/iOS
- **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** - Padrões de código e arquitetura

## 🎯 Contexto do Projeto

Este app foi refatorado de uma solução genérica de mobilidade urbana para implementar especificamente o modelo de negócio do InDriver, onde:
- Passageiros definem preços iniciais
- Motoristas fazem ofertas competitivas  
- Sistema promove negociação transparente

## 🤝 Contribuição

1. Fork → Branch → Commit → Push → Pull Request
2. Siga os padrões em [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)
3. Execute testes antes de enviar

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

---

**Desenvolvido com ❤️ pela EvoSoftwares**
