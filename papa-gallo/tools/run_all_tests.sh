#!/usr/bin/env bash
# run_all_tests.sh
# Script de ejecución de smoke tests headless para el proyecto papa-gallo.
#
# Uso:
#   ./tools/run_all_tests.sh [--headless] [--verbose] [--artifact <artifacts_dir>]
#
# Opciones:
#   --headless   Ejecuta en modo headless (default, siempre activo).
#   --verbose    Muestra la salida completa de cada test en stdout además del log.
#   --artifact <dir>  Copia el log generado al directorio <dir> al finalizar.
#
# Código de salida:
#   0  => Ambos smoke tests pasaron (SMOKE TEST PASSED en ambos).
#   1  => Al menos un smoke test falló o godot no está disponible.
#
# Log de ejecución:
#   papa-gallo/logs/run_all_tests_<timestamp>.log
#
# Requisitos:
#   - godot (o godot4) disponible en PATH o en rutas comunes de macOS/Linux/Windows.
#   - El proyecto papa-gallo en la misma carpeta que este script (un nivel arriba).

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuración base
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOGS_DIR="$PROJECT_DIR/logs"
TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
LOG_FILE="$LOGS_DIR/run_all_tests_${TIMESTAMP}.log"

VERBOSE=false
ARTIFACT_DIR=""

# ---------------------------------------------------------------------------
# Parseo de argumentos
# ---------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        --headless)
            # --headless es siempre el modo de operación; se acepta pero no cambia nada.
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --artifact)
            if [[ $# -lt 2 ]]; then
                echo "[run_all_tests] ERROR: --artifact requiere un directorio como argumento." >&2
                exit 1
            fi
            ARTIFACT_DIR="$2"
            shift 2
            ;;
        *)
            echo "[run_all_tests] WARN: Argumento desconocido ignorado: '$1'" >&2
            shift
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Funciones utilitarias
# ---------------------------------------------------------------------------

log() {
    local msg="$1"
    local ts
    ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo "[$ts] $msg" | tee -a "$LOG_FILE"
}

log_raw() {
    # Escribe al log sin timestamp (para volcar stdout/stderr de subprocesos)
    echo "$1" | tee -a "$LOG_FILE"
}

# ---------------------------------------------------------------------------
# Preparar directorio de logs
# ---------------------------------------------------------------------------

mkdir -p "$LOGS_DIR"
# Crear archivo de log vacío (tee lo irá llenando)
: > "$LOG_FILE"

log "====== run_all_tests.sh — papa-gallo CI Smoke Runner ======"
log "Proyecto:  $PROJECT_DIR"
log "Log:       $LOG_FILE"
log "Timestamp: $TIMESTAMP"
log "Verbose:   $VERBOSE"
[[ -n "$ARTIFACT_DIR" ]] && log "Artifact:  $ARTIFACT_DIR"
log ""

# ---------------------------------------------------------------------------
# Buscar ejecutable de Godot
# ---------------------------------------------------------------------------

find_godot() {
    # Rutas donde buscar, en orden de prioridad.
    local candidates=(
        "godot"
        "godot4"
        "/usr/local/bin/godot"
        "/usr/local/bin/godot4"
        "/opt/homebrew/bin/godot"
        "/opt/homebrew/bin/godot4"
        "/Applications/Godot.app/Contents/MacOS/Godot"
        "/Applications/Godot_v4.app/Contents/MacOS/Godot"
        "/Applications/Godot 4.app/Contents/MacOS/Godot"
        "$HOME/Applications/Godot.app/Contents/MacOS/Godot"
        "$HOME/Applications/Godot_v4.app/Contents/MacOS/Godot"
        "/snap/godot-4/current/godot"
        "/usr/bin/godot"
        "/usr/bin/godot4"
    )

    for candidate in "${candidates[@]}"; do
        if command -v "$candidate" &>/dev/null 2>&1; then
            echo "$candidate"
            return 0
        fi
        if [[ -x "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

GODOT_BIN=""
if GODOT_BIN="$(find_godot)"; then
    GODOT_VERSION="$("$GODOT_BIN" --version 2>&1 | head -1 || echo "desconocida")"
    log "Godot encontrado: $GODOT_BIN (versión: $GODOT_VERSION)"
else
    log "ERROR: godot no encontrado en PATH ni en rutas comunes."
    log "  Instala Godot 4.x y asegúrate de que esté en PATH, o proporciona"
    log "  el binario en una de las rutas estándar:"
    log "    - /usr/local/bin/godot"
    log "    - /Applications/Godot.app/Contents/MacOS/Godot"
    log "    - o ajusta la variable de entorno PATH antes de ejecutar este script."
    log ""
    log "  Instrucciones para ejecutar manualmente:"
    log "    godot --headless --path \"$PROJECT_DIR\" --script \"tools/smoke_test_player.gd\""
    log "    godot --headless --path \"$PROJECT_DIR\" --script \"tools/smoke_test_enemy.gd\""
    echo "[run_all_tests] FATAL: Godot no disponible. Ver log: $LOG_FILE" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Función para ejecutar un smoke test
# ---------------------------------------------------------------------------

# run_test <nombre> <ruta_script>
# Retorna: 0 si el test pasó, 1 si falló.
run_test() {
    local test_name="$1"
    local script_path="$2"
    local exit_code=0

    log ""
    log "--- Iniciando: $test_name ---"
    log "Script: $script_path"

    local output
    local tmp_out
    tmp_out="$(mktemp)"

    # Ejecutar Godot headless y capturar stdout+stderr
    set +e
    "$GODOT_BIN" --headless --path "$PROJECT_DIR" --script "$script_path" \
        > "$tmp_out" 2>&1
    exit_code=$?
    set -e

    # Leer salida capturada
    output="$(cat "$tmp_out")"
    rm -f "$tmp_out"

    # Escribir salida al log siempre
    log "--- Salida de $test_name (exit_code=$exit_code) ---"
    while IFS= read -r line; do
        echo "  $line" >> "$LOG_FILE"
        if [[ "$VERBOSE" == true ]]; then
            echo "  $line"
        fi
    done <<< "$output"
    log "--- Fin salida de $test_name ---"

    if [[ $exit_code -eq 0 ]]; then
        log "✅ $test_name PASÓ (exit_code=0)"
    else
        log "❌ $test_name FALLÓ (exit_code=$exit_code)"
    fi

    return $exit_code
}

# ---------------------------------------------------------------------------
# Ejecutar los smoke tests
# ---------------------------------------------------------------------------

PLAYER_EXIT=0
ENEMY_EXIT=0

run_test "smoke_test_player" "tools/smoke_test_player.gd" || PLAYER_EXIT=$?
run_test "smoke_test_enemy" "tools/smoke_test_enemy.gd"   || ENEMY_EXIT=$?

# ---------------------------------------------------------------------------
# Resumen final
# ---------------------------------------------------------------------------

log ""
log "====== RESUMEN ======"
log "smoke_test_player: $([ $PLAYER_EXIT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
log "smoke_test_enemy:  $([ $ENEMY_EXIT  -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
log ""

FINAL_EXIT=0
if [[ $PLAYER_EXIT -ne 0 || $ENEMY_EXIT -ne 0 ]]; then
    FINAL_EXIT=1
    log "🔴 RESULTADO FINAL: FAILED — al menos un smoke test falló."
    log "   Log completo en: $LOG_FILE"
    log ""
    log "   Para reproducir localmente:"
    log "     godot --headless --path \"$PROJECT_DIR\" --script \"tools/smoke_test_player.gd\""
    log "     godot --headless --path \"$PROJECT_DIR\" --script \"tools/smoke_test_enemy.gd\""
else
    log "🟢 RESULTADO FINAL: PASSED — ambos smoke tests pasaron."
    log "   Log completo en: $LOG_FILE"
fi

# ---------------------------------------------------------------------------
# Copiar log al directorio de artifacts si se especificó
# ---------------------------------------------------------------------------

if [[ -n "$ARTIFACT_DIR" ]]; then
    mkdir -p "$ARTIFACT_DIR"
    cp "$LOG_FILE" "$ARTIFACT_DIR/"
    log "Artifact copiado a: $ARTIFACT_DIR/$(basename "$LOG_FILE")"
fi

log ""
log "====== FIN run_all_tests.sh (exit=$FINAL_EXIT) ======"

exit $FINAL_EXIT
