#!/bin/bash
set -euo pipefail

# Urban Mobility App - Script único Android (diagnóstico, emulador e execução)
# Recursos:
# 1) Reseta ADB e trata unauthorized automaticamente (sem apagar chaves por padrão)
# 2) Lança AVD com cold boot e flags robustas se não houver device
# 3) Aguarda boot real via sys.boot_completed/bootanim
# 4) Seleciona device sem interação (suporta --avd/ANDROID_AVD)
# 5) Executa flutter run com --device-timeout 240
# 6) Flags: --clean, --avd=NOME, --reset-adb-keys (opcional)

# ==========================
# Configuração e Utilitários
# ==========================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
PROJECT_DIR="/Users/evosoftwares/option/urban_mobility_app"
ANDROID_SDK_ROOT_DEFAULT="/Users/evosoftwares/Library/Android/sdk"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_SDK_ROOT_DEFAULT}"

print_status()  { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ==========================
# Parsing de argumentos
# ==========================
ARG_CLEAN="false"
ARG_AVD="${ANDROID_AVD:-}"     # pode ser sobrescrito por --avd
ARG_RESET_KEYS="false"         # só apaga chaves ADB se explicitamente solicitado

for arg in "$@"; do
  case "$arg" in
    --clean) ARG_CLEAN="true" ;;
    --avd=*) ARG_AVD="${arg#*=}" ;;
    --reset-adb-keys) ARG_RESET_KEYS="true" ;;
    *) print_warning "Argumento desconhecido: $arg" ;;
  esac
done

echo "🚀 Urban Mobility App - Script Android (único)"
echo "=================================================="

# ==========================
# Pré-checagens
# ==========================
if [ ! -d "$PROJECT_DIR" ]; then
  print_error "Diretório do projeto não encontrado: $PROJECT_DIR"
  exit 1
fi
cd "$PROJECT_DIR"

if ! command -v flutter &>/dev/null; then
  print_error "Flutter não está no PATH"
  exit 1
fi
if ! command -v adb &>/dev/null; then
  print_error "ADB não encontrado no PATH. Instale Platform-Tools e garanta PATH correto."
  exit 1
fi

# ==========================
# Funções auxiliares
# ==========================
wait_for_emulator() {
  local device_id="$1"
  local max_attempts=120 # 240s
  local attempt=0
  print_status "Aguardando boot completo do emulador $device_id (até 240s)..."
  while [ $attempt -lt $max_attempts ]; do
    if adb -s "$device_id" shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; then
      if adb -s "$device_id" shell getprop init.svc.bootanim 2>/dev/null | grep -q "stopped"; then
        print_success "Emulador $device_id pronto."
        return 0
      fi
    fi
    echo -n "."
    sleep 2
    attempt=$((attempt+1))
  done
  print_error "Timeout aguardando boot do emulador"
  return 1
}

get_android_device_id() {
  # Primeiro tenta via ADB para pegar emulator-XXXX autorizado
  local adb_id
  adb_id=$(adb devices | awk '/^emulator-[0-9]+\s+device/ {print $1; exit}')
  if [ -n "${adb_id:-}" ]; then
    echo "$adb_id"; return 0
  fi
  # Fallback via flutter
  flutter devices | grep -E "(android|emulator)" | head -1 | sed -E 's/.*• ([^ ]+) •.*/\1/'
}

select_android_device() {
  # Se usuário pediu um AVD específico, vamos tentar garantir que ele esteja ativo
  if [ -n "${ARG_AVD:-}" ]; then
    print_status "Preferência de AVD recebida: $ARG_AVD"
    # Se ainda não há device, tentar lançar esse AVD
    if ! adb devices | awk '/^emulator-[0-9]+\s+device/ {found=1} END {exit found?0:1}'; then
      print_status "Lançando AVD preferido: $ARG_AVD"
      "$ANDROID_SDK_ROOT/emulator/emulator" -avd "$ARG_AVD" -no-snapshot-load -no-boot-anim -delay-adb -gpu host -accel on -netdelay none -netspeed full >/tmp/emulator.log 2>&1 &
      sleep 10
    fi
  fi

  # Device ativo e autorizado?
  local active_id
  active_id=$(adb devices | awk '/^emulator-[0-9]+\s+device/ {print $1; exit}')
  if [ -n "${active_id:-}" ]; then
    echo "$active_id"; return 0
  fi

  # Fallback via flutter
  local devices_output android_devices device_count
  devices_output=$(flutter devices)
  android_devices=$(echo "$devices_output" | grep -E "(android|emulator)")
  if [ -z "$android_devices" ]; then
    return 1
  fi
  device_count=$(echo "$android_devices" | wc -l | xargs)
  if [ "$device_count" -eq 1 ]; then
    echo "$android_devices" | sed -E 's/.*• ([^ ]+) •.*/\1/'
  else
    print_status "Múltiplos dispositivos Android encontrados; selecionando o primeiro."
    echo "$android_devices" | head -1 | sed -E 's/.*• ([^ ]+) •.*/\1/'
  fi
}

ensure_device_or_launch_avd() {
  local device
  device=$(get_android_device_id || true)

  if [ -z "${device:-}" ]; then
    print_warning "Nenhum device Android autorizado. Reiniciando servidor ADB..."
    adb kill-server || true
    adb start-server || true

    if [ "$ARG_RESET_KEYS" = "true" ]; then
      print_warning "Apagando chaves ADB locais (por solicitação --reset-adb-keys)."
      rm -f ~/.android/adbkey ~/.android/adbkey.pub || true
      adb kill-server || true
      adb start-server || true
    fi

    # Tentar lançar um AVD
    local launch_name=""
    if [ -n "${ARG_AVD:-}" ]; then
      launch_name="$ARG_AVD"
    else
      # Tentar detectar pelo flutter emulators
      local emu_list
      emu_list=$(flutter emulators || true)
      launch_name=$(echo "$emu_list" | awk '/android/ {print $1; exit}')
    fi

    if [ -n "$launch_name" ]; then
      print_status "Lançando emulador: $launch_name"
      # Preferir binário do emulator para cold boot consistente
      if [ -x "$ANDROID_SDK_ROOT/emulator/emulator" ]; then
        "$ANDROID_SDK_ROOT/emulator/emulator" -avd "$launch_name" -no-snapshot-load -no-boot-anim -delay-adb -gpu host -accel on -netdelay none -netspeed full >/tmp/emulator.log 2>&1 &
      else
        flutter emulators --launch "$launch_name" &
      fi
      sleep 10
    else
      print_error "Nenhum AVD encontrado. Crie um com: flutter emulators --create"
      exit 1
    fi

    # Descobrir device após launch
    local attempts=0
    while [ $attempts -lt 60 ]; do
      device=$(get_android_device_id || true)
      [ -n "${device:-}" ] && break
      sleep 2
      attempts=$((attempts+1))
    done

    if [ -z "${device:-}" ]; then
      print_error "Não foi possível detectar um device após iniciar o AVD."
      exit 1
    fi

    wait_for_emulator "$device"

    # Verificar se ainda está unauthorized e instruir usuário a aceitar prompt
    if adb devices | awk -v id="$device" '$1==id && $2=="unauthorized"{found=1} END{exit found?0:1}'; then
      print_warning "Device $device está 'unauthorized'. Desbloqueie o AVD e aceite o prompt 'Allow USB debugging?'."
      print_status "Re-tentando conexão ADB em 10s..."
      sleep 10
    fi
  fi

  # Selecionar device final
  select_android_device
}

# ==========================
# Fluxo principal
# ==========================
print_status "Verificando dispositivos Android..."
flutter devices || true

ANDROID_DEVICE="$(ensure_device_or_launch_avd || true)"
if [ -z "${ANDROID_DEVICE:-}" ]; then
  print_error "Nenhum dispositivo Android disponível para execução."
  exit 1
fi

# Sanitizar device ID (emulators têm '-')
if ! [[ "$ANDROID_DEVICE" =~ ^[a-zA-Z0-9._:-]+$ ]]; then
  print_error "Device ID inválido: '$ANDROID_DEVICE'"
  exit 1
fi
print_success "Dispositivo Android selecionado: $ANDROID_DEVICE"

# Limpeza opcional
if [ "$ARG_CLEAN" = "true" ]; then
  print_status "Limpando cache do Flutter..."
  flutter clean
  flutter pub get
fi

# Dependências
print_status "Atualizando dependências..."
flutter pub get

# Validar disponibilidade
if ! flutter devices | grep -q "$ANDROID_DEVICE"; then
  print_error "Dispositivo $ANDROID_DEVICE não está mais disponível"
  flutter devices
  exit 1
fi

# Execução
print_status "Iniciando aplicativo no dispositivo: $ANDROID_DEVICE"
print_status "Comandos: r (reload), R (restart), q (sair), h (ajuda)"
echo ""
print_success "🎯 Executando Urban Mobility App no dispositivo: $ANDROID_DEVICE"
echo ""

if flutter run -d "$ANDROID_DEVICE" --device-timeout 240 --verbose; then
  print_success "Aplicativo executado com sucesso!"
else
  print_error "Falha na execução do aplicativo"
  exit 1
fi

print_status "Execução finalizada."