# Setup de Entorno de Desarrollo — PapaGallo

**Proyecto:** PapaGallo
**Engine:** Godot 4.6 (GL Compatibility)
**Ultima actualizacion:** 2026-03-29

> Guia paso a paso para que un nuevo desarrollador pueda clonar, configurar y ejecutar el proyecto en menos de 30 minutos.

---

## Checklist Rapido

- [ ] Instalar Godot 4.6
- [ ] Clonar el repositorio
- [ ] Abrir el proyecto en Godot
- [ ] Verificar que los import settings se aplicaron
- [ ] Ejecutar la primera escena
- [ ] Configurar tu editor de codigo (opcional)
- [ ] Leer la documentacion del proyecto
- [ ] Crear tu primer branch de trabajo

---

## 1. Instalar Godot 4.6

### Opcion A: Descarga directa (recomendada)

1. Ir a [godotengine.org/download](https://godotengine.org/download)
2. Descargar **Godot 4.6 Standard** para tu sistema operativo
   - Windows: `.exe` (portable, no necesita instalacion)
   - macOS: `.dmg` o `.app.zip`
   - Linux: `.x86_64` (AppImage o tarball)
3. **No instalar la version .NET** a menos que el equipo lo decida — usamos GDScript

### Opcion B: Desde el package manager de tu OS

```bash
# macOS con Homebrew
brew install --cask godot

# Linux (Flatpak)
flatpak install flathub org.godotengine.Godot

# Linux (Snap)
sudo snap install godot-4 --edge
```

### Verificar la instalacion

```bash
godot --version
# Debe mostrar: 4.6.stable o similar
```

> **Importante:** Todos los miembros del equipo deben usar la MISMA version de Godot (4.6.x). Versiones diferentes pueden causar cambios en archivos `.import` y `project.godot` que generan conflictos en git.

---

## 2. Clonar el Repositorio

```bash
# Clonar con HTTPS
git clone https://github.com/TU_ORG/gameDevelopment.git

# O con SSH
git clone git@github.com:TU_ORG/gameDevelopment.git

# Entrar al directorio
cd gameDevelopment
```

### Estructura que veras al clonar

```
gameDevelopment/
├── docs/           # Documentacion (GDD, TDD, ROADMAP, etc.)
├── art/            # Assets de arte originales (Aseprite, PSD)
├── audio/          # Assets de audio originales
├── tools/          # Scripts de pipeline
├── snippets/       # Fragmentos de referencia
└── papa-gallo/     # <-- PROYECTO GODOT (abrir este directorio en Godot)
    ├── project.godot
    ├── src/
    ├── scenes/
    ├── assets/
    └── ...
```

---

## 3. Abrir el Proyecto en Godot

### Desde el editor

1. Abrir Godot 4.6
2. En el Project Manager, click **Import**
3. Navegar hasta `gameDevelopment/papa-gallo/` y seleccionar `project.godot`
4. Click **Import & Edit**

### Desde la terminal

```bash
# Desde la raiz del repo
godot -e --path papa-gallo
```

### Primera vez: Reimportacion de assets

La primera vez que abras el proyecto, Godot reimportara todos los assets. Esto es normal y puede tardar unos segundos. Veras una barra de progreso en la parte inferior del editor.

**Si ves errores de importacion:** Cierra Godot, borra la carpeta `papa-gallo/.godot/imported/`, y vuelve a abrir el proyecto.

---

## 4. Verificar Import Settings

Despues de abrir el proyecto por primera vez:

1. Ir a `Project > Project Settings > General`
2. Verificar estos settings criticos:

| Setting | Ruta en Project Settings | Valor esperado |
|---|---|---|
| Viewport Width | `display/window/size/viewport_width` | `320` |
| Viewport Height | `display/window/size/viewport_height` | `180` |
| Window Width | `display/window/size/window_width_override` | `1920` |
| Window Height | `display/window/size/window_height_override` | `1080` |
| Stretch Mode | `display/window/stretch/mode` | `canvas_items` |
| Stretch Aspect | `display/window/stretch/aspect` | `keep` |
| Texture Filter | `rendering/textures/canvas_textures/default_texture_filter` | `Nearest (0)` |
| Renderer | `rendering/renderer/rendering_method` | `gl_compatibility` |

3. Verificar que los **Autoloads** estan registrados (Project Settings > Autoload):

| Nombre | Script |
|---|---|
| GameManager | `res://src/autoloads/game_manager.gd` |
| InputManager | `res://src/autoloads/input_manager.gd` |
| AudioManager | `res://src/autoloads/audio_manager.gd` |
| SaveManager | `res://src/autoloads/save_manager.gd` |

> **Nota:** Si los autoloads no existen todavia (proyecto en etapa temprana), no te preocupes — se crearan cuando el equipo implemente esos sistemas.

4. Verificar que los **Input Actions** estan definidos (Project Settings > Input Map):
   - `move_up`, `move_down`, `move_left`, `move_right`
   - `attack_primary`, `attack_secondary`
   - `change_weapon`, `sprint`, `interact`, `pause`

---

## 5. Ejecutar la Primera Escena

### Si el proyecto ya tiene escenas

1. En el FileSystem dock (abajo-izquierda), navegar a `scenes/`
2. Hacer doble-click en `main.tscn` (o la escena principal del proyecto)
3. Click en el boton **Play** (F5) o **Play Current Scene** (F6)

### Si el proyecto esta vacio (setup inicial)

Crear una escena de prueba para verificar que todo funciona:

1. `Scene > New Scene`
2. Elegir **2D Scene** como nodo raiz
3. Agregar un nodo `Sprite2D` como hijo
4. Asignarle el `icon.svg` como textura (arrastrar desde FileSystem)
5. Guardar como `scenes/test_setup.tscn`
6. Ejecutar con F5 — deberas ver el icono de Godot en pantalla

**Si la imagen se ve borrosa:** El filtro de texturas no es `Nearest`. Ir a Project Settings y cambiar `rendering/textures/canvas_textures/default_texture_filter` a `0 (Nearest)`.

---

## 6. Configurar tu Editor de Codigo (Opcional)

### Opcion A: Usar el editor integrado de Godot

Godot trae un editor de scripts integrado que es suficiente para la mayoria del trabajo. No necesitas nada extra.

### Opcion B: Editor externo

Si prefieres usar un editor externo:

1. En Godot: `Editor > Editor Settings > Text Editor > External`
2. Activar `Use External Editor`
3. Configurar la ruta al ejecutable:

| Editor | Exec Path (macOS) | Exec Flags |
|---|---|---|
| VS Code | `/usr/local/bin/code` | `{project} --goto {file}:{line}:{col}` |
| Cursor | Similar a VS Code | `{project} --goto {file}:{line}:{col}` |
| Vim/Neovim | `/usr/local/bin/nvim` | `{file}` |

### Extensiones recomendadas para VS Code / Cursor

- **godot-tools** — GDScript syntax highlighting, autocompletado, linting
- **EditorConfig for VS Code** — Respeta el `.editorconfig` del proyecto

---

## 7. Leer la Documentacion del Proyecto

Antes de empezar a trabajar, lee estos documentos en orden:

| Documento | Que encontraras | Prioridad |
|---|---|---|
| `docs/GDD.md` | Game Design Document — que es el juego, mecanicas, controles | **Obligatorio** |
| `docs/TDD_GODOT_4_6.md` | Technical Design Document — arquitectura, patrones, estructura | **Obligatorio** |
| `docs/CONVENTIONS.md` | Convenciones de codigo, assets, git, commits | **Obligatorio** |
| `docs/ROADMAP.md` | Hoja de ruta, milestones, tareas | Recomendado |
| `docs/GDD_ACCEPTANCE_CHECKLIST.md` | Criterios de aceptacion del GDD | Referencia |

---

## 8. Flujo de Trabajo Git

### 8.1 Crear tu branch de trabajo

```bash
# Asegurate de estar en develop (o main si no existe develop)
git checkout develop
git pull origin develop

# Crear tu branch
git checkout -b feature/tu-feature-aqui

# Ejemplos:
git checkout -b feature/player-movement
git checkout -b fix/enemy-collision-bug
git checkout -b docs/update-tdd
```

### 8.2 Convenciones de commit

Usamos Conventional Commits:

```bash
# Formato
git commit -m "tipo(ambito): descripcion corta en imperativo"

# Ejemplos
git commit -m "feat(player): add basic movement with WASD"
git commit -m "fix(spawner): fix enemy spawning outside map bounds"
git commit -m "art(player): add idle animation sprites"
git commit -m "docs(tdd): update export pipeline section"
```

**Tipos:** `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `chore`, `art`, `audio`

### 8.3 Antes de hacer push

```bash
# Traer cambios remotos
git pull --rebase origin develop

# Verificar que el proyecto abre sin errores
godot -e --path papa-gallo

# Push
git push origin feature/tu-feature-aqui

# Abrir PR en GitHub apuntando a develop
```

### 8.4 Archivos que SI van al repo

- Todo el contenido de `papa-gallo/` EXCEPTO `.godot/` y `exports/`
- Los archivos `.import` (generados por Godot, aseguran consistencia)
- `project.godot`
- Toda la documentacion en `docs/`

### 8.5 Archivos que NO van al repo (ya en .gitignore)

- `papa-gallo/.godot/` — cache del editor, se regenera automaticamente
- `papa-gallo/exports/` — builds exportados
- `.DS_Store`, `Thumbs.db` — archivos del sistema operativo

---

## 9. Tests Basicos

### 9.1 Test manual: verificar que el juego corre

1. Abrir el proyecto en Godot
2. Ejecutar la escena principal (F5)
3. Verificar: sin errores en la consola (Output dock)
4. Verificar: el juego se ve correcto (pixeles nitidos, sin blur)

### 9.2 Test manual: verificar controles

1. Ejecutar el juego
2. Verificar WASD para movimiento
3. Verificar J/K para ataques
4. Verificar Tab para cambiar arma
5. Verificar Shift para esprintar
6. Verificar E para interactuar
7. Si tienes gamepad: verificar todos los botones mapeados

### 9.3 Test manual: verificar export

```bash
# Exportar build de prueba
godot --headless --path papa-gallo --export-debug "Windows Desktop" exports/windows/PapaGallo_test.exe

# Ejecutar el build exportado y verificar que funciona igual que en el editor
```

### 9.4 Escenas de test (para desarrollo)

Crear escenas simples en `papa-gallo/tests/` para probar sistemas aislados:

- `test_player.tscn` — jugador solo en un mapa vacio, probar movimiento
- `test_combat.tscn` — jugador + enemigos, probar combate
- `test_spawner.tscn` — spawner generando enemigos, probar oleadas

Estas escenas NO son parte del juego final, son herramientas de desarrollo.

---

## 10. Cómo Probar el Prototipo de Movimiento

> Disponible desde el vertical slice MVP (2026-03-29). Requiere Godot 4.6.

### 10.1 Escena y script principales

| Artefacto | Ruta |
|---|---|
| Escena principal (entry point) | `papa-gallo/scenes/Main.tscn` |
| Escena del jugador | `papa-gallo/scenes/Player.tscn` |
| Script de movimiento | `papa-gallo/scripts/player.gd` |
| HUD placeholder | `papa-gallo/scenes/HUD.tscn` |

### 10.2 Abrir y ejecutar desde el editor

1. Abrir Godot 4.6 con el proyecto:
   ```bash
   godot -e --path papa-gallo
   ```
2. En el FileSystem dock, navegar a `scenes/` y abrir `Main.tscn`.
3. Presionar **F5** (Play Project) — Godot usará `Main.tscn` como escena principal automáticamente.

### 10.3 Verificación manual de movimiento

Con el juego ejecutándose:

| Acción | Tecla | Resultado esperado |
|---|---|---|
| Mover arriba | W / ↑ | El jugador sube en pantalla |
| Mover abajo | S / ↓ | El jugador baja en pantalla |
| Mover izquierda | A / ← | El jugador se mueve a la izquierda, sprite voltea |
| Mover derecha | D / → | El jugador se mueve a la derecha |
| Sprint | Shift (izq. o der.) | El jugador se mueve más rápido, sprite se pone más claro |
| Gamepad | Stick izquierdo + B | Misma lógica con mando |

### 10.4 Smoke test automatizado (headless)

```bash
# Desde la raíz del repositorio (gameDevelopment/)
godot --headless --path papa-gallo --script tools/smoke_test_player.gd
```

**Resultado esperado:**
```
[SmokeTest] Iniciando smoke test de movimiento del jugador...
[SmokeTest] Posición inicial del jugador: (640, 360)
[SmokeTest] Posición final del jugador: (660.x, 340.x)
[SmokeTest] Desplazamiento total: XX.XX px
[SmokeTest] ✅ PASÓ — El jugador se movió correctamente.
```

Si el smoke test **falla**, verificar:
- Que `scenes/Main.tscn` existe y tiene un nodo hijo llamado `Player`.
- Que `scripts/player.gd` está asignado al nodo `Player` en `Player.tscn`.
- Que el Input Map tiene las acciones `move_right` y `move_up` definidas.

---

## 11. Sistema de Oleadas — RoundManager + Spawner + Enemy

> Disponible desde el vertical slice de enemigos (2026-03-29). Requiere Godot 4.6.

### 11.1 Archivos del sistema de oleadas

| Artefacto | Ruta |
|---|---|
| Script del enemigo | `papa-gallo/scripts/enemy.gd` |
| Escena del enemigo | `papa-gallo/scenes/enemies/Enemy.tscn` |
| Script del Spawner | `papa-gallo/scripts/spawner.gd` |
| Escena del Spawner | `papa-gallo/scenes/Spawner.tscn` |
| Script del RoundManager | `papa-gallo/scripts/round_manager.gd` |
| Smoke test de enemigos | `papa-gallo/tools/smoke_test_enemy.gd` |

### 11.2 Cómo iniciar una ronda en el editor

1. Abre `scenes/Main.tscn` en Godot.
2. Presiona **F5** (Play Project).
3. Presiona **F5 in-game** (`debug_next_wave` input action) para iniciar la primera ronda.
   - Se spawneará 3 enemigos (base_count) alrededor del jugador.
   - Cada F5 adicional incrementa la ronda: ronda 2 → 4 enemigos, ronda 3 → 5, etc.
4. Los enemigos (cuadrados rojos 32×32) perseguirán al jugador automáticamente.

> **Nota:** El input action `debug_next_wave` está mapeado a la tecla **F5** (keycode 4194330).
> Solo disponible en builds de debug — a futuro se puede deshabilitar con `OS.is_debug_build()`.

### 11.3 Smoke test automatizado de enemigos (headless)

```bash
# Desde la raíz del repositorio (gameDevelopment/)
godot --headless --path papa-gallo --script tools/smoke_test_enemy.gd
```

**Resultado esperado:**
```
[SmokeTest] ====== SMOKE TEST ENEMY — PapaGallo ======
[SmokeTest] --- Check 1: Existencia de scripts ---
[SmokeTest]   [OK] enemy.gd
[SmokeTest]   [OK] spawner.gd
[SmokeTest]   [OK] round_manager.gd
[SmokeTest]   [OK] Enemy.tscn existe
[SmokeTest] --- Check 2: Propiedades exportadas de Enemy ---
[SmokeTest]   [OK] Propiedad 'speed' encontrada
[SmokeTest]   [OK] Propiedad 'aggro_range' encontrada
[SmokeTest]   [OK] Propiedad 'stop_distance' encontrada
[SmokeTest] --- Check 3: spawn_wave(2) instancia 2 enemigos ---
[SmokeTest]   [OK] 2 enemigos spawneados correctamente
[SmokeTest] --- Check 4: Enemigo persigue al jugador ---
[SmokeTest]   [OK] Enemigo persigue al jugador correctamente
[SmokeTest] ✅ SMOKE TEST PASSED — N checks OK
```

El log se guarda automáticamente en `papa-gallo/logs/smoke_test_enemy_<timestamp>.log`.

Si el smoke test **falla**, verificar:
- Que `scenes/enemies/Enemy.tscn` existe y tiene el script `scripts/enemy.gd` asignado.
- Que el nodo `Player` en `Main.tscn` está en el grupo **"player"** (el enemigo busca por este grupo).
- Que `scripts/spawner.gd` tiene el campo `enemy_scene` asignado (ver Inspector de `Spawner` en `Main.tscn`).
- Que `scripts/round_manager.gd` tiene `spawner_path` apuntando a `../Spawner`.

### 11.4 Añadir al jugador el grupo "player" (requerido por enemy.gd)

El script `enemy.gd` busca al jugador usando `get_tree().get_nodes_in_group("player")`.

Para que el jugador sea detectado:
1. Abre `scenes/Player.tscn` en Godot.
2. Selecciona el nodo raíz `Player`.
3. En el panel **Node** (derecha) → pestaña **Groups** → escribe `player` → click **Add**.
4. Guarda la escena.

**Alternativa por código** (ya incluido en versiones futuras del player.gd):
```gdscript
func _ready() -> void:
    add_to_group("player")
```

> **Nota:** Sin este paso, los enemigos no detectarán al jugador y no se moverán.

---

## 12. CI & Como Ejecutar Tests Localmente

> El proyecto tiene un pipeline de CI en GitHub Actions que ejecuta los smoke tests automaticamente en cada push/PR a `main` o `develop`. Esta seccion explica como replicar lo que hace el CI en tu maquina local.

### 12.1 Ejecutar todos los smoke tests

```bash
# Desde la raiz del repositorio (gameDevelopment/)
./tools/run_all_tests.sh
```

El script descubre automaticamente todos los archivos `smoke_test_*.gd` en `papa-gallo/tools/` y los ejecuta secuencialmente en modo headless.

**Requisitos:**
- Godot 4.6 instalado y accesible como `godot` en el PATH
- Si tu binario de Godot tiene otro nombre o ruta:
  ```bash
  GODOT_BIN=/ruta/a/tu/godot ./tools/run_all_tests.sh
  ```

**Resultado esperado:**
```
============================================
 PapaGallo — Test Runner
 2026-03-29 12:00:00 UTC
============================================

--- [1] smoke_test_player ---
  [SmokeTest] Iniciando smoke test de movimiento del jugador...
  [SmokeTest] PASSED

--- [2] smoke_test_enemy ---
  [SmokeTest] ====== SMOKE TEST ENEMY — PapaGallo ======
  [SmokeTest] PASSED

============================================
 RESUMEN
============================================
  Tests encontrados: 2
  Tests pasados:     2
============================================
RESULTADO: ALL PASSED
```

### 12.2 Ejecutar un smoke test individual

```bash
# Smoke test de movimiento del jugador
godot --headless --path papa-gallo --script tools/smoke_test_player.gd

# Smoke test del sistema de enemigos
godot --headless --path papa-gallo --script tools/smoke_test_enemy.gd
```

### 12.3 API canónica de Logging — `write_event()`

> **Migración completada (2026-03-29).** No hay llamadas legacy `Logging.log()` en el codebase. El CI ya no tiene un step de lint para patrones obsoletos.

La API correcta es:

```gdscript
Logging.write_event({"level": "info", "event": "round_started", "data": {"round": 1}})
```

Para confirmar que no hay regresiones localmente:
```bash
# Debe devolver 0 resultados
rg "Logging\.log\s*\(" --type gd papa-gallo/ tools/
```

Ver `tools/logging_migration_report.md` para el historial de auditoría.

### 12.4 Que hace el CI

El pipeline de GitHub Actions (`.github/workflows/ci.yml`) ejecuta en `ubuntu-latest`:

1. **Checkout** del repositorio
2. **Download** de Godot 4.6 headless para Linux (con cache)
3. **Import** del proyecto Godot (genera `.godot/imported/`)
4. **Smoke tests** via `tools/run_all_tests.sh`
5. **Upload** de logs (`papa-gallo/logs/**`) como artifacts (14 dias de retencion)

Para mas detalles, ver `docs/CI_RUNBOOK.md`.

### 12.5 Como agregar un nuevo test

1. Crear `papa-gallo/tools/smoke_test_NOMBRE.gd` que extienda `SceneTree`
2. Llamar `quit(0)` si pasa, `quit(1)` si falla
3. El test sera descubierto automaticamente por `run_all_tests.sh` y el CI

---

## 13. Troubleshooting

### El proyecto no abre / muestra errores

```bash
# Borrar cache y reimportar
rm -rf papa-gallo/.godot/imported/
godot -e --path papa-gallo
```

### Los sprites se ven borrosos

1. `Project Settings > Rendering > Textures > Canvas Textures > Default Texture Filter` = `Nearest`
2. En cada sprite individual: Import dock > Filter = `false` > Reimport

### Conflictos en archivos .import al hacer merge

Los archivos `.import` son generados. Si hay conflictos:
1. Aceptar cualquier version
2. Borrar `papa-gallo/.godot/imported/`
3. Reabrir Godot — reimportara todo

### Error "Export template not found"

1. `Editor > Manage Export Templates`
2. Click "Download and Install" para la version 4.6
3. Reintentar el export

### El juego corre lento

1. Abrir `Debugger > Monitors` — ver FPS y draw calls
2. Abrir `Debugger > Profiler` — identificar funciones lentas
3. Buscar en la consola warnings de nodos huerfanos o fugas de memoria

---

## 11. Contacto y Comunicacion del Equipo

| Quien | Rol principal |
|---|---|
| Amader | Arte, diseno visual |
| Xoje | Programacion, setup tecnico |
| El Negro | TODO: definir rol principal |

**Canal principal:** TODO: Discord / Slack / WhatsApp
**Gestion de tareas:** TODO: GitHub Issues / Trello / Notion
**Reuniones:** TODO: frecuencia y formato

---

## 13. Observabilidad y Logs

> Disponible desde el vertical slice de Logging (2026-03-29). Requiere Godot 4.6.

El Autoload `Logging` proporciona observabilidad local robusta: escribe eventos estructurados en formato **JSON-lines** para que puedan ser procesados con cualquier herramienta de análisis de texto (`jq`, Python, Excel, etc.).

### 13.1 Cómo se escriben los logs

- Cada sesión de juego genera un archivo independiente en `papa-gallo/logs/session_<session_id>.log`.
- El `session_id` tiene el formato `YYYYMMDD_HHMMSS_RRRR` (timestamp UTC + 4 dígitos aleatorios).
- Cada línea del archivo es un objeto JSON independiente (formato **JSON-lines / ndjson**).
- El buffer se escribe a disco automáticamente cada **20 eventos** o cada **10 segundos** (configurable).
- Al cerrar el juego (`NOTIFICATION_WM_CLOSE_REQUEST`) se hace un flush final.

### 13.2 Ruta de los logs

```
papa-gallo/
└── logs/
    ├── session_20260329_101500_4231.log   ← sesión de juego normal
    ├── session_20260329_112045_0017.log   ← sesión de smoke test
    └── smoke_test_enemy_2026-03-29T10-08-13.log  ← log de texto plano (legacy)
```

> **Nota:** Los archivos `logs/` están listados en `.gitignore` (no se suben al repo).
> La retención local es: máximo **10 archivos** de log y **2 MB** por archivo antes de rotar.

### 13.3 Cómo leer los logs

Cada línea es un JSON con este esquema:

```json
{"ts":"2026-03-29T10:15:00Z","session_id":"20260329_101500_4231","version":"0.1.0","platform":"macOS","level":"info","event":"round_started","data":{"round":1,"spawn_count":3}}
```

**Con `jq` (recomendado):**

```bash
# Ver todos los eventos de una sesión
jq . papa-gallo/logs/session_*.log | less

# Filtrar sólo eventos de inicio de ronda
jq 'select(.event == "round_started")' papa-gallo/logs/session_*.log

# Ver todos los enemigos spawneados
jq 'select(.event == "enemy_spawned") | .data' papa-gallo/logs/session_*.log

# Historial de muertes del jugador
jq 'select(.event == "player_death") | {ts, data}' papa-gallo/logs/session_*.log

# Ver resultados de smoke tests
jq 'select(.event | startswith("smoke_test"))' papa-gallo/logs/session_*.log
```

**Sin `jq` (Python):**

```python
import json, pathlib

for line in pathlib.Path("papa-gallo/logs").glob("session_*.log"):
    for raw in line.read_text().splitlines():
        evt = json.loads(raw)
        print(evt["ts"], evt["event"], evt.get("data", {}))
```

### 13.4 Eventos instrumentados

| Evento | Script origen | Datos incluidos |
|---|---|---|
| `session_started` | `Logging._ready()` | session_id, platform, version, debug |
| `session_ended` | `Logging._notification()` | session_id, duration_s |
| `round_started` | `round_manager.gd` | round, spawn_count |
| `round_ended` | `round_manager.gd` | round, duration_s, enemies_remaining |
| `enemy_spawned` | `enemy.gd` | enemy_type, pos |
| `enemy_died` | `enemy.gd` | enemy_type, pos, killer |
| `player_started` | `player.gd` | session_id, position |
| `player_death` | `player.gd` | position |
| `smoke_test_passed` | `smoke_test_*.gd` | suite, pass_count, fail_count |
| `smoke_test_failed` | `smoke_test_*.gd` | suite, pass_count, fail_count, failures |

### 13.5 Política de retención

| Parámetro | Valor por defecto | Variable en Logging.gd |
|---|---|---|
| Eventos por flush | 20 | `auto_flush_count` |
| Intervalo de flush | 10 s | `auto_flush_interval` |
| Tamaño máximo de archivo | 2 MB | `max_file_size_bytes` |
| Archivos máximos en `logs/` | 10 | `max_log_files` |

Los parámetros son `@export var` — se pueden cambiar desde el Inspector si el nodo Logging se instancia en una escena, o modificando los defaults en el script.

### 13.6 Verificación manual (Godot)

#### GUI (editor de Godot)

1. Abre el proyecto en Godot 4.6: `godot -e --path papa-gallo`
2. Verifica que `Logging` aparece en **Project > Project Settings > Autoload** con la ruta `res://scripts/autoload/Logging.gd`.
3. Ejecuta el juego con **F5**.
4. Inicia una ronda presionando **F5 in-game** (acción `debug_next_wave`).
5. Cierra el juego.
6. Abre la carpeta `papa-gallo/logs/` — debe existir un archivo `session_<id>.log`.
7. Abre el archivo y verifica que hay líneas JSON con los eventos:
   - `session_started`
   - `round_started` con `"round":1` y `"spawn_count":3`
   - `enemy_spawned` (una por cada enemigo spawnado)
   - `session_ended`

**Ejemplo de línea esperada:**
```json
{"ts":"2026-03-29T10:15:01Z","session_id":"20260329_101501_1234","version":"0.1.0","platform":"macOS","level":"info","event":"round_started","data":{"round":1,"spawn_count":3}}
```

#### CLI (headless, sin GUI)

```bash
# Desde la raíz del repositorio (gameDevelopment/)
godot --headless --path papa-gallo --script tools/smoke_test_player.gd
godot --headless --path papa-gallo --script tools/smoke_test_enemy.gd

# Verificar que se crearon archivos de log JSON-lines
ls papa-gallo/logs/session_*.log

# Verificar eventos de smoke test
jq 'select(.event | startswith("smoke_test"))' papa-gallo/logs/session_*.log
```

**Resultado esperado en `logs/session_*.log` tras smoke test:**
```json
{"ts":"...","session_id":"...","level":"info","event":"session_started","data":{"test_suite":"smoke_test_enemy",...}}
{"ts":"...","session_id":"...","level":"info","event":"smoke_test_passed","data":{"suite":"enemy","pass_count":7,"fail_count":0,"failures":[]}}
```

Si el archivo de log NO se crea, verificar:
- Que el directorio `papa-gallo/logs/` existe (se crea automáticamente, pero requiere permisos de escritura).
- Que el script `scripts/autoload/Logging.gd` carga sin errores (revisar la consola de Godot).
- En modo headless, que el smoke test llama a `_init_logging()` (ver código de `tools/smoke_test_*.gd`).

---

_Documento actualizado el 2026-03-29._
