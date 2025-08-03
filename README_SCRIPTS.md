# 🚀 Scripts de Execução - Urban Mobility App

Este diretório contém scripts automatizados para facilitar a execução do Urban Mobility App no Android.

## 📱 Scripts Disponíveis

### 1. `quick_run.sh` - Execução Rápida
**Uso recomendado para desenvolvimento diário**

```bash
./quick_run.sh
```

**Características:**
- ✅ Execução rápida e direta
- ✅ Detecta automaticamente dispositivos Android
- ✅ Prioriza emuladores
- ✅ Interface simples e limpa

### 2. `run_android.sh` - Execução Completa
**Uso recomendado para debugging e análise detalhada**

```bash
./run_android.sh
```

**Características:**
- ✅ Verificações completas do ambiente
- ✅ Logs detalhados e coloridos
- ✅ Gerenciamento automático de emuladores
- ✅ Opção de limpeza de cache
- ✅ Mensagens de status informativas

**Opções adicionais:**
```bash
./run_android.sh --clean  # Limpa cache antes de executar
```

## 🔧 Pré-requisitos

1. **Flutter instalado** e configurado no PATH
2. **Emulador Android** configurado ou dispositivo físico conectado
3. **Permissões de execução** nos scripts (já configuradas)

## 📋 Como Usar

### Primeira Execução
```bash
cd /Users/evosoftwares/option
./quick_run.sh
```

### Para Debugging
```bash
cd /Users/evosoftwares/option
./run_android.sh --clean
```

## 🎯 Comandos Durante a Execução

Quando o aplicativo estiver rodando, você pode usar:

- `r` - Hot reload (recarregar mudanças)
- `R` - Hot restart (reiniciar aplicativo)
- `q` - Sair da execução
- `h` - Mostrar ajuda
- `c` - Limpar console

## 🐛 Solução de Problemas

### Nenhum dispositivo encontrado
```bash
# Verificar dispositivos disponíveis
flutter devices

# Listar emuladores
flutter emulators

# Iniciar emulador específico
flutter emulators --launch <nome_do_emulador>
```

### Problemas de dependências
```bash
cd urban_mobility_app
flutter clean
flutter pub get
```

### Problemas de cache
```bash
./run_android.sh --clean
```

## 📁 Estrutura do Projeto

```
/Users/evosoftwares/option/
├── quick_run.sh          # Script rápido
├── run_android.sh        # Script completo
├── README_SCRIPTS.md     # Este arquivo
└── urban_mobility_app/   # Projeto Flutter
    ├── lib/
    ├── android/
    └── pubspec.yaml
```

## 🎓 Dicas de Desenvolvimento

1. **Use `quick_run.sh`** para desenvolvimento diário
2. **Use `run_android.sh --clean`** quando houver problemas
3. **Mantenha o emulador aberto** para execuções mais rápidas
4. **Use hot reload (`r`)** para ver mudanças instantaneamente

## 🔄 Atualizações

Para atualizar os scripts ou o projeto:

```bash
cd /Users/evosoftwares/option/urban_mobility_app
flutter pub upgrade
```

---

**Desenvolvido por:** Equipe de Desenvolvimento Sênior  
**Data:** $(date +%Y-%m-%d)  
**Versão:** 1.0.0