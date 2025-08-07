#!/bin/bash

# Script de inicialização completa do Urban Mobility App
# Uso: ./start.sh

clear
echo "🚀 URBAN MOBILITY APP - INICIALIZAÇÃO AUTOMÁTICA"
echo "================================================"
echo ""

# Detectar o diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/urban_mobility_app"
QUICK_RUN_SCRIPT="$SCRIPT_DIR/quick_run.sh"

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado! Instale o Flutter primeiro."
    exit 1
fi

echo "✅ Flutter encontrado"

# Verificar se o diretório do projeto existe
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Diretório do projeto não encontrado: $PROJECT_DIR"
    exit 1
fi

# Ir para o diretório do projeto
cd "$PROJECT_DIR"

# Verificar se há dispositivos Android
ANDROID_DEVICES=$(flutter devices | grep "android")
if [ -z "$ANDROID_DEVICES" ]; then
    echo "⚠️  Nenhum dispositivo Android encontrado"
    echo "🔄 Tentando iniciar emulador..."
    
    # Tentar iniciar um emulador
    EMULATORS=$(flutter emulators | grep "android" | head -1)
    if [ ! -z "$EMULATORS" ]; then
        EMULATOR_ID=$(echo "$EMULATORS" | awk '{print $1}')
        echo "🚀 Iniciando emulador: $EMULATOR_ID"
        flutter emulators --launch "$EMULATOR_ID" &
        
        echo "⏳ Aguardando emulador inicializar (30 segundos)..."
        sleep 30
    else
        echo "❌ Nenhum emulador configurado!"
        echo "💡 Configure um emulador com: flutter emulators --create"
        exit 1
    fi
fi

echo "✅ Dispositivo Android disponível"

# Atualizar dependências
echo "🔄 Atualizando dependências..."
flutter pub get > /dev/null 2>&1

echo "✅ Dependências atualizadas"

# Executar o aplicativo
echo ""
echo "🎯 INICIANDO URBAN MOBILITY APP..."
echo "📱 Comandos disponíveis:"
echo "   r - Hot reload"
echo "   R - Hot restart" 
echo "   q - Sair"
echo ""

# Verificar se o script quick_run.sh existe
if [ ! -f "$QUICK_RUN_SCRIPT" ]; then
    echo "❌ Script quick_run.sh não encontrado: $QUICK_RUN_SCRIPT"
    exit 1
fi

# Usar o script rápido
exec "$QUICK_RUN_SCRIPT"