#!/bin/bash

# Script para executar o Urban Mobility App no Android
# Autor: Desenvolvedor Sênior
# Data: $(date +%Y-%m-%d)

echo "🚀 Urban Mobility App - Script de Execução Android"
echo "=================================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Diretório do projeto
PROJECT_DIR="/Users/evosoftwares/option/urban_mobility_app"

# Função para imprimir mensagens coloridas
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se estamos no diretório correto
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Diretório do projeto não encontrado: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    print_error "Flutter não está instalado ou não está no PATH"
    exit 1
fi

print_status "Verificando dispositivos Android disponíveis..."

# Verificar dispositivos disponíveis
DEVICES=$(flutter devices | grep "android")
if [ -z "$DEVICES" ]; then
    print_warning "Nenhum dispositivo Android encontrado. Tentando iniciar emulador..."
    
    # Listar emuladores disponíveis
    EMULATORS=$(flutter emulators | grep "android")
    if [ -z "$EMULATORS" ]; then
        print_error "Nenhum emulador Android configurado."
        print_status "Para configurar um emulador, execute: flutter emulators --create"
        exit 1
    fi
    
    # Tentar iniciar o primeiro emulador disponível
    FIRST_EMULATOR=$(flutter emulators | grep "android" | head -1 | awk '{print $1}')
    if [ ! -z "$FIRST_EMULATOR" ]; then
        print_status "Iniciando emulador: $FIRST_EMULATOR"
        flutter emulators --launch "$FIRST_EMULATOR"
        
        # Aguardar o emulador inicializar
        print_status "Aguardando emulador inicializar..."
        sleep 10
    fi
fi

# Verificar novamente os dispositivos
print_status "Verificando dispositivos Android..."
flutter devices

# Limpar cache se necessário (opcional)
if [ "$1" == "--clean" ]; then
    print_status "Limpando cache do Flutter..."
    flutter clean
    flutter pub get
fi

# Atualizar dependências
print_status "Atualizando dependências..."
flutter pub get

# Verificar se há dispositivo Android disponível
ANDROID_DEVICE=$(flutter devices | grep "android" | head -1 | awk '{print $4}')

if [ -z "$ANDROID_DEVICE" ]; then
    print_error "Nenhum dispositivo Android disponível para execução"
    print_status "Dispositivos disponíveis:"
    flutter devices
    exit 1
fi

# Remover caracteres especiais do device ID
ANDROID_DEVICE=$(echo "$ANDROID_DEVICE" | tr -d '•')
ANDROID_DEVICE=$(echo "$ANDROID_DEVICE" | xargs)

print_success "Dispositivo Android encontrado: $ANDROID_DEVICE"

# Executar o aplicativo
print_status "Iniciando aplicativo no dispositivo Android..."
print_status "Comandos disponíveis durante a execução:"
print_status "  r - Hot reload"
print_status "  R - Hot restart"
print_status "  q - Sair"
print_status "  h - Ajuda"

echo ""
print_success "🎯 Executando Urban Mobility App..."
echo ""

# Executar com verbose para melhor debugging
flutter run -d "$ANDROID_DEVICE" --verbose

print_status "Execução finalizada."