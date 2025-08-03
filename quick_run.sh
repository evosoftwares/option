#!/bin/bash

# Script rápido para executar o Urban Mobility App no Android
# Uso: ./quick_run.sh

echo "🚀 Executando Urban Mobility App no Android..."

cd /Users/evosoftwares/option/urban_mobility_app

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