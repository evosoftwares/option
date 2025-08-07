#!/bin/bash

# Script rápido para executar o Urban Mobility App no Android
# Uso: ./quick_run.sh

echo "🚀 Executando Urban Mobility App no Android..."

# Detectar o diretório do script e do projeto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/urban_mobility_app"

# Verificar se o diretório do projeto existe
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Diretório do projeto não encontrado: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

# Buscar dispositivo Android (emulador ou físico)
DEVICE_LINE=$(flutter devices | grep "android" | head -1)

if [ -z "$DEVICE_LINE" ]; then
    echo "❌ Nenhum dispositivo Android encontrado!"
    echo "📱 Dispositivos disponíveis:"
    flutter devices
    exit 1
fi

# Extrair o ID do dispositivo (segunda coluna após o •)
DEVICE=$(echo "$DEVICE_LINE" | sed 's/.*• \([^ ]*\) •.*/\1/')

echo "📱 Usando dispositivo: $DEVICE"
echo "🔄 Iniciando aplicativo..."

flutter run -d "$DEVICE"