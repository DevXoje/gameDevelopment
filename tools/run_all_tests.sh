#!/usr/bin/env bash
## run_all_tests.sh — Ejecuta todos los smoke tests headless de PapaGallo.
##
## Uso:
##   ./tools/run_all_tests.sh              # usa 'godot' del PATH
##   GODOT_BIN=/ruta/a/godot ./tools/run_all_tests.sh   # binario específico
##
## Código de salida:
##   0 => todos los tests pasaron
##   1 => al menos un test falló
##
## El script descubre automáticamente todos los archivos smoke_test_*.gd
## dentro de papa-gallo/tools/ y los ejecuta secuencialmente en modo --headless.

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuración
# ---------------------------------------------------------------------------

GODOT_BIN="${GODOT_BIN:-godot}"
PROJECT_PATH="papa-gallo"
TOOLS_DIR="${PROJECT_PATH}/tools"
LOG_DIR="${PROJECT_PATH}/logs"

# Colores (desactivados si no hay tty)
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  NC=''
fi

# ---------------------------------------------------------------------------
# Verificaciones previas
# ---------------------------------------------------------------------------

echo "============================================"
echo " PapaGallo — Test Runner"
echo " $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "============================================"
echo ""

# Verificar que el binario de Godot existe
if ! command -v "${GODOT_BIN}" &>/dev/null; then
  echo -e "${RED}ERROR: Godot no encontrado en PATH ('${GODOT_BIN}').${NC}"
  echo "  Instala Godot 4.6 o configura GODOT_BIN=/ruta/al/binario"
  exit 1
fi

GODOT_VERSION=$("${GODOT_BIN}" --version 2>/dev/null || echo "desconocida")
echo "Godot: ${GODOT_BIN} (version: ${GODOT_VERSION})"

# Verificar que el directorio del proyecto existe
if [ ! -f "${PROJECT_PATH}/project.godot" ]; then
  echo -e "${RED}ERROR: No se encontró ${PROJECT_PATH}/project.godot${NC}"
  echo "  Ejecuta este script desde la raíz del repositorio (gameDevelopment/)"
  exit 1
fi

# Asegurar que el directorio de logs existe
mkdir -p "${LOG_DIR}"

# ---------------------------------------------------------------------------
# Descubrir y ejecutar smoke tests
# ---------------------------------------------------------------------------

TESTS_FOUND=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Buscar todos los smoke_test_*.gd en papa-gallo/tools/
# Ignorar archivos .uid (metadatos de Godot)
for test_script in "${TOOLS_DIR}"/smoke_test_*.gd; do
  # Verificar que el glob encontró archivos reales
  [ -f "${test_script}" ] || continue

  TESTS_FOUND=$((TESTS_FOUND + 1))
  test_name=$(basename "${test_script}" .gd)
  # El path del script es relativo al proyecto: tools/smoke_test_*.gd
  relative_script="tools/$(basename "${test_script}")"

  echo ""
  echo "--- [${TESTS_FOUND}] ${test_name} ---"
  echo "  Ejecutando: ${GODOT_BIN} --headless --path ${PROJECT_PATH} --script ${relative_script}"

  # Ejecutar el test con timeout de 60 segundos
  set +e
  timeout 60 "${GODOT_BIN}" --headless --path "${PROJECT_PATH}" --script "${relative_script}" 2>&1
  exit_code=$?
  set -e

  if [ ${exit_code} -eq 0 ]; then
    echo -e "  ${GREEN}PASSED${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  elif [ ${exit_code} -eq 124 ]; then
    echo -e "  ${RED}TIMEOUT (60s)${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_TESTS+=("${test_name} (TIMEOUT)")
  else
    echo -e "  ${RED}FAILED (exit code: ${exit_code})${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_TESTS+=("${test_name} (exit: ${exit_code})")
  fi
done

# ---------------------------------------------------------------------------
# Resumen
# ---------------------------------------------------------------------------

echo ""
echo "============================================"
echo " RESUMEN"
echo "============================================"
echo "  Tests encontrados: ${TESTS_FOUND}"
echo -e "  Tests pasados:     ${GREEN}${TESTS_PASSED}${NC}"

if [ ${TESTS_FAILED} -gt 0 ]; then
  echo -e "  Tests fallidos:    ${RED}${TESTS_FAILED}${NC}"
  echo ""
  echo "  Tests que fallaron:"
  for failed in "${FAILED_TESTS[@]}"; do
    echo -e "    ${RED}- ${failed}${NC}"
  done
fi

if [ ${TESTS_FOUND} -eq 0 ]; then
  echo -e "  ${YELLOW}ADVERTENCIA: No se encontraron smoke tests en ${TOOLS_DIR}/${NC}"
  exit 0
fi

echo "============================================"

if [ ${TESTS_FAILED} -gt 0 ]; then
  echo -e "${RED}RESULTADO: FAILED${NC}"
  exit 1
else
  echo -e "${GREEN}RESULTADO: ALL PASSED${NC}"
  exit 0
fi
