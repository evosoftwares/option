#!/bin/bash

# Script de inicialização completa do Urban Mobility App
# Uso: ./start.sh

clear
echo "🚀 URBAN MOBILITY APP - INICIALIZAÇÃO AUTOMÁTICA"
echo "================================================"
echo ""

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado! Instale o Flutter primeiro."
    exit 1
fi

echo "✅ Flutter encontrado"

# Ir para o diretório do projeto
cd /Users/evosoftwares/option/urban_mobility_app

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

# Usar o script rápido
exec ./quick_run.sh