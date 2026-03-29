# CI Runbook — PapaGallo

**Proyecto:** PapaGallo
**Engine:** Godot 4.6 (GL Compatibility)
**Pipeline:** GitHub Actions
**Ultima actualizacion:** 2026-03-29 (limpieza logging legacy — step lint .log() removido)

> Guia operativa para entender, mantener y diagnosticar el pipeline de CI de PapaGallo.

---

## 1. Arquitectura del Pipeline

```
push/PR a main o develop
         |
         v
+------------------+
| 1. Checkout      |  actions/checkout@v4
+------------------+
         |
         v
+------------------+
| 2. Cache Godot   |  actions/cache@v4 (~/godot-bin)
+------------------+
         |
         v
+------------------+
| 3. Download      |  Godot 4.6-stable linux headless
|    Godot 4.6     |  (solo si cache miss)
+------------------+
         |
         v
+------------------+
| 4. Import        |  godot --headless --path papa-gallo --import
|    proyecto      |  (genera .godot/imported/)
+------------------+
         |
         v
+------------------+
| 5. Smoke tests   |  tools/run_all_tests.sh
|                  |  → papa-gallo/tools/smoke_test_*.gd
+------------------+
         |
         v
+------------------+
| 6. Upload logs   |  actions/upload-artifact@v4
|                  |  papa-gallo/logs/** → 14 dias retencion
+------------------+
```

### Triggers

| Evento | Branches | Descripcion |
|--------|----------|-------------|
| `push` | `main`, `develop` | Cada push directo (incluyendo merges) |
| `pull_request` | `main`, `develop` | Cada PR abierto o actualizado |

### Runner

- **OS:** `ubuntu-latest` (Ubuntu 22.04 LTS en GitHub-hosted runners)
- **Timeout:** 15 minutos maximo para todo el job

---

## 2. Steps en Detalle

### 2.1 Checkout

Usa `actions/checkout@v4`. Clona el repo completo con todo el historial necesario.

### 2.2 Cache de Godot

- **Cache key:** `godot-4.6-stable-linux-x86_64`
- **Ubicacion:** `~/godot-bin/godot`
- **Tamano estimado:** ~60 MB
- El cache persiste entre runs del mismo workflow. Solo se descarga Godot cuando:
  - Es la primera ejecucion
  - Se cambia la version de Godot (`GODOT_VERSION` en el workflow)
  - El cache fue evicted por GitHub (limite de 10 GB por repo)

### 2.3 Download de Godot 4.6

- Descarga el binario headless de Godot desde `github.com/godotengine/godot-builds`
- Lo instala en `~/godot-bin/godot`
- Lo hace ejecutable (`chmod +x`)
- Lo agrega al `PATH` via `GITHUB_PATH`

**URL de descarga:**
```
https://github.com/godotengine/godot-builds/releases/download/4.6-stable/Godot_v4.6-stable_linux.x86_64.zip
```

### 2.4 Import del proyecto

Godot necesita "importar" los assets la primera vez. Esto genera la carpeta `.godot/imported/`.

```bash
godot --headless --path papa-gallo --import
```

- Tiene un timeout de 120 segundos
- Si falla, se ignora el error (`|| true`) — algunos proyectos funcionan sin import explícito
- En runs subsiguientes con cache, este paso es mas rapido

### 2.5 Smoke Tests

Ejecuta `tools/run_all_tests.sh` que:

1. Descubre todos los archivos `papa-gallo/tools/smoke_test_*.gd`
2. Los ejecuta secuencialmente con `godot --headless --path papa-gallo --script <test>`
3. Cada test tiene timeout de 60 segundos
4. Si cualquier test falla (exit code != 0), el step falla

**Tests actuales:**

| Test | Archivo | Que verifica |
|------|---------|-------------|
| smoke_test_player | `papa-gallo/tools/smoke_test_player.gd` | Movimiento del jugador (Input simulado, desplazamiento > 1px) |
| smoke_test_enemy | `papa-gallo/tools/smoke_test_enemy.gd` | Sistema de oleadas (scripts existen, spawn funciona, enemigo persigue) |

### 2.6 Logging — API canónica `write_event()`

> **Migración completada (2026-03-29).** El step de lint legacy `.log()` fue removido del CI porque la migración está 100% completa.

La API canónica del Autoload `Logging` es:

```gdscript
Logging.write_event({"level": "info", "event": "round_started", "data": {"round": 1}})
```

No existen llamadas a `Logging.log()` ni `log()` en el código ejecutable. El reporte de auditoría está en `tools/logging_migration_report.md`.

### 2.7 Upload de Logs

- **Artifact name:** `papa-gallo-test-logs`
- **Contenido:** `papa-gallo/logs/**` (JSON-lines y logs de texto)
- **Retencion:** 14 dias
- **Condicion:** `if: always()` — se sube incluso si los tests fallan (para diagnostico)
- Si no hay archivos de log, muestra warning pero no falla

---

## 3. Como Actualizar la Version de Godot

Cuando el proyecto cambie de version de Godot:

1. Editar `.github/workflows/ci.yml`
2. Cambiar las variables `env:` al inicio del archivo:
   ```yaml
   env:
     GODOT_VERSION: "4.7-stable"  # nueva version
     GODOT_RELEASE_URL: "https://github.com/godotengine/godot-builds/releases/download/4.7-stable/Godot_v4.7-stable_linux.x86_64.zip"
   ```
3. Verificar que la URL existe visitandola en el navegador
4. El cache se invalidara automaticamente (nueva key)
5. Hacer commit y push — el CI descargara la nueva version

**Donde encontrar las URLs:**
- Pagina oficial: https://github.com/godotengine/godot-builds/releases
- Formato: `Godot_v{VERSION}_linux.x86_64.zip`

---

## 4. Como Agregar un Nuevo Test

1. Crear un nuevo script GDScript en `papa-gallo/tools/`:
   ```
   papa-gallo/tools/smoke_test_NOMBRE.gd
   ```
2. El script debe:
   - Extender `SceneTree`
   - Llamar `quit(0)` si pasa, `quit(1)` si falla
   - Imprimir mensajes con prefijo `[SmokeTest]`
3. `run_all_tests.sh` lo descubrira automaticamente por el patron `smoke_test_*.gd`
4. No es necesario modificar el workflow de CI

**Plantilla minima:**
```gdscript
extends SceneTree

func _initialize() -> void:
    print("[SmokeTest] Iniciando smoke test de NOMBRE...")
    
    # ... tu lógica de verificación ...
    
    var passed := true  # cambiar según resultado
    
    if passed:
        print("[SmokeTest] PASSED")
        quit(0)
    else:
        push_error("[SmokeTest] FAILED — descripción del fallo")
        quit(1)
```

---

## 5. Troubleshooting

### 5.1 El CI falla en "Import Godot project"

**Sintoma:** Timeout o errores de importacion de assets.

**Diagnostico:**
1. Descargar los logs del artifact `papa-gallo-test-logs`
2. Revisar la salida del step "Import Godot project"

**Soluciones comunes:**
- Asset corrupto: verificar que todos los `.import` estan en el repo
- Timeout: aumentar el timeout en el step (default: 120s)
- Version mismatch: verificar que `GODOT_VERSION` en el workflow coincide con `project.godot`

### 5.2 El CI falla en smoke tests pero pasan localmente

**Sintoma:** Tests pasan en macOS/Windows pero fallan en Linux CI.

**Posibles causas:**
- **Diferencias de plataforma:** Godot headless en Linux puede tener comportamiento diferente en physics
- **Timing:** Los smoke tests dependen de `process_frame()` / `physics_frame()` — en CI los frames pueden ser mas lentos
- **Paths:** Diferencias entre case-sensitive (Linux) y case-insensitive (macOS) en nombres de archivos
- **GPU:** El CI no tiene GPU — asegurar que el renderer sea `gl_compatibility` (ya configurado)

**Como reproducir en Linux:**
```bash
# Con Docker (simula el entorno de CI)
docker run --rm -v $(pwd):/game -w /game ubuntu:22.04 bash -c "
  apt-get update && apt-get install -y wget unzip
  wget -q https://github.com/godotengine/godot-builds/releases/download/4.6-stable/Godot_v4.6-stable_linux.x86_64.zip
  unzip Godot_*.zip -d /usr/local/bin/
  mv /usr/local/bin/Godot_* /usr/local/bin/godot
  chmod +x /usr/local/bin/godot
  GODOT_BIN=godot ./tools/run_all_tests.sh
"
```

### 5.3 ~~El CI falla en "Check for legacy .log( patterns"~~ (Eliminado)

> **Este step fue removido del CI el 2026-03-29.** La migración de `Logging.log()` a `Logging.write_event()` está 100% completa. No existe ni existirá este error en el pipeline actual.
>
> Si necesitas verificar que no hay llamadas legacy localmente:
> ```bash
> # Debe devolver 0 resultados
> rg "Logging\.log\s*\(" --type gd papa-gallo/ tools/
> ```
>
> Ver `tools/logging_migration_report.md` para el historial de auditoría.

### 5.4 Los logs no se suben como artifacts

**Sintoma:** El artifact `papa-gallo-test-logs` aparece vacio o no existe.

**Posibles causas:**
- Los smoke tests no generaron logs (verificar que `_init_logging()` se llama)
- El directorio `papa-gallo/logs/` no fue creado (el step "Prepare logs directory" deberia crearlo)
- Los smoke tests crashearon antes de escribir a disco (verificar con `flush()`)

### 5.5 Godot download falla o cache no funciona

**Sintoma:** El step de descarga falla con 404 o timeout.

**Soluciones:**
- Verificar que la URL en `GODOT_RELEASE_URL` es valida
- Si GitHub releases esta caido, esperar y re-run el workflow
- Para invalidar cache manualmente: cambiar `GODOT_VERSION` y luego revertir

### 5.6 Timeout en smoke tests

**Sintoma:** Un test individual excede 60 segundos.

**Causa probable:** El test entra en un bucle infinito o espera un evento que no llega.

**Solucion:**
- Revisar el smoke test para asegurarse de que siempre llama a `quit()`
- En modo headless, `await` puede colgar si la senal nunca se emite
- Agregar guards de timeout dentro del script GDScript:
  ```gdscript
  var timeout_timer := Timer.new()
  timeout_timer.wait_time = 30.0
  timeout_timer.one_shot = true
  timeout_timer.timeout.connect(func(): quit(1))
  get_root().add_child(timeout_timer)
  timeout_timer.start()
  ```

---

## 6. Descargar y Analizar Artifacts

### Via GitHub UI

1. Ir a la pagina del workflow run en GitHub Actions
2. En la seccion "Artifacts", hacer click en `papa-gallo-test-logs`
3. Se descarga un `.zip` con los archivos de log

### Via CLI (gh)

```bash
# Listar artifacts del ultimo run
gh run list --limit 1
gh run download <RUN_ID> --name papa-gallo-test-logs

# Analizar logs con jq
jq 'select(.event | startswith("smoke_test"))' papa-gallo-test-logs/session_*.log
```

### Via API

```bash
# Listar artifacts
gh api repos/{owner}/{repo}/actions/artifacts --jq '.artifacts[] | {name, id, created_at}'

# Descargar artifact por ID
gh api repos/{owner}/{repo}/actions/artifacts/{ARTIFACT_ID}/zip > logs.zip
```

---

## 7. Metricas y Monitoreo

### Que monitorear

| Metrica | Donde | Alerta |
|---------|-------|--------|
| CI pass rate | GitHub Actions | < 90% en 7 dias |
| Duracion del pipeline | GitHub Actions | > 10 minutos |
| Tests descubiertos | Salida de `run_all_tests.sh` | Si baja de N esperado |
| Cache hit rate | Logs del step "Cache Godot binary" | < 80% |

### Badge en README (opcional)

Agregar al `README.md` del repo:
```markdown
![CI](https://github.com/{owner}/{repo}/actions/workflows/ci.yml/badge.svg?branch=develop)
```

---

## 8. Seguridad

- **Permisos del workflow:** `contents: read` — minimo necesario
- **No se usan secrets** en este pipeline
- **No se hacen push** desde CI — pipeline de solo lectura
- **Timeout global:** 15 minutos — protege contra runs colgados
- **Timeout por test:** 60 segundos en `run_all_tests.sh`

---

## 9. Costos (GitHub Actions)

- **Runners publicos:** 2,000 minutos gratis/mes (plan Free)
- **Duracion estimada por run:** 3-5 minutos (con cache hit)
- **Primera ejecucion:** ~8 minutos (descarga de Godot)
- **Cache storage:** ~60 MB (binario de Godot) — no consume quota significativo

---

_Documento creado el 2026-03-29. Actualizar cuando se modifique el pipeline._
