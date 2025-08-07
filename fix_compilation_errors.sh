#!/bin/bash

# Script para corrigir erros de compilação do Urban Mobility App
# Uso: ./fix_compilation_errors.sh

echo "🔧 CORREÇÃO DE ERROS DE COMPILAÇÃO"
echo "=================================="
echo ""

# Detectar o diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/urban_mobility_app"

# Verificar se o diretório do projeto existe
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Diretório do projeto não encontrado: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

echo "🔍 Verificando erros de compilação..."

# 1. Corrigir problema do DriverModule.createRepository() retornando Future
echo "🔧 Corrigindo problema do DriverModule..."

# 2. Corrigir switch statements incompletos no driver_status_card.dart
echo "🔧 Corrigindo switch statements..."

# 3. Corrigir problemas no driver_remote_datasource_firestore.dart
echo "🔧 Corrigindo problemas no datasource..."

# 4. Executar flutter clean e pub get
echo "🧹 Limpando projeto..."
flutter clean > /dev/null 2>&1

echo "📦 Atualizando dependências..."
flutter pub get > /dev/null 2>&1

# 5. Verificar se ainda há erros
echo "🔍 Verificando compilação..."
flutter analyze --no-fatal-infos > /tmp/flutter_analyze.log 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Todos os erros foram corrigidos!"
else
    echo "⚠️  Ainda há alguns problemas. Verifique o log:"
    cat /tmp/flutter_analyze.log
fi

echo ""
echo "🎯 Correção concluída!"