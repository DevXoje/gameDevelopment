# Technical Design Document — PapaGallo (Godot 4.6)

**Proyecto:** PapaGallo
**Autor/es:** Amader, Xoje, El Negro
**Versión:** 1.0 — Documento completo para Godot 4.6
**Fecha:** 2026-03-29
**Estado:** Borrador para revisión de equipo
**Engine:** Godot 4.6 — GL Compatibility Renderer

---

## 1. Eleccion de Engine

**Engine seleccionado:** Godot 4.6

| Opcion evaluada | Ventajas | Desventajas | Decision |
|---|---|---|---|
| Godot 4.6 | Open source, GDScript nativo, excelente para 2D pixel-art, export multiplataforma, liviano | Ecosistema de plugins menor que Unity | **Seleccionado** |
| Unity 6 | Gran ecosistema, asset store | Licencias restrictivas, rendimiento 2D inferior, overhead para proyecto 2D | Descartado |
| Unreal 5 | Top en 3D | Overkill absoluto para 2D top-down pixel-art | Descartado |

**Razon de la eleccion:** Godot 4.6 es ideal para un juego 2D top-down pixel-art. GDScript reduce la friccion de onboarding para el equipo, el renderer GL Compatibility es estable para 2D, y el motor es open-source sin costos de licencia (alineado con el modelo premium de PapaGallo).

**Version del engine:** Godot 4.6 estable

---

## 2. Estructura del Proyecto

```
gameDevelopment/
├── docs/                           # Documentacion (GDD, TDD, ROADMAP, etc.)
│   └── PLAYTESTS/                  # Reportes de playtests
├── art/                            # Assets de arte originales (PSD, Aseprite — NO van a Godot)
├── audio/                          # Assets de audio originales (DAW exports — NO van a Godot)
├── tools/                          # Scripts de pipeline y herramientas de desarrollo
├── snippets/                       # Fragmentos de referencia rapida
│
└── papa-gallo/                     # PROYECTO GODOT (project.godot vive aqui)
    ├── project.godot               # Configuracion principal del proyecto
    ├── icon.svg                    # Icono del proyecto
    │
    ├── src/                        # Codigo fuente (scripts GDScript)
    │   ├── autoloads/              # Singletons globales
    │   │   ├── game_manager.gd     # Estados de juego, rondas, puntuacion
    │   │   ├── input_manager.gd    # Abstraccion de input (teclado/gamepad)
    │   │   ├── audio_manager.gd    # Buses de audio, reproduccion de musica/SFX
    │   │   └── save_manager.gd     # Guardado/carga de configuracion y records
    │   │
    │   ├── player/                 # Logica del jugador
    │   │   ├── player.gd           # Script principal del CharacterBody2D del jugador
    │   │   ├── player_combat.gd    # Componente de combate (ataques, stamina)
    │   │   └── player_health.gd    # Componente de vida (dano, curacion por tiempo)
    │   │
    │   ├── enemies/                # Logica de enemigos
    │   │   ├── enemy_base.gd       # Clase base para todos los enemigos
    │   │   ├── enemy_zombie.gd     # Enemigo lento tipo zombie
    │   │   └── enemy_fast.gd       # Enemigo rapido ocasional
    │   │
    │   ├── systems/                # Subsistemas de gameplay
    │   │   ├── spawner.gd          # Spawner que usa PackedScene para instanciar enemigos
    │   │   ├── round_manager.gd    # Control de oleadas, escalado de dificultad
    │   │   ├── economy.gd          # Sistema de puntos (obtencion y gasto)
    │   │   └── zone_unlock.gd      # Logica de desbloqueo de zonas del mapa
    │   │
    │   ├── weapons/                # Sistema de armas
    │   │   ├── weapon_base.gd      # Clase base de arma
    │   │   └── weapon_data.gd      # Resource custom para definir stats de armas
    │   │
    │   └── ui/                     # Scripts de interfaz
    │       ├── hud.gd              # HUD en gameplay (vida, arma, ronda, puntos, stamina)
    │       ├── main_menu.gd        # Menu principal
    │       ├── pause_menu.gd       # Menu de pausa
    │       └── game_over.gd        # Pantalla de resultados
    │
    ├── scenes/                     # Escenas (.tscn)
    │   ├── main.tscn               # Escena raiz del juego
    │   ├── player/
    │   │   └── player.tscn         # Escena del jugador
    │   ├── enemies/
    │   │   ├── enemy_zombie.tscn   # Escena del enemigo zombie
    │   │   └── enemy_fast.tscn     # Escena del enemigo rapido
    │   ├── weapons/
    │   │   └── weapon.tscn         # Escena base de arma
    │   ├── levels/
    │   │   └── level_01_castle.tscn # Mapa MVP: El Castillo
    │   ├── ui/
    │   │   ├── hud.tscn            # HUD de gameplay
    │   │   ├── main_menu.tscn      # Menu principal
    │   │   ├── pause_menu.tscn     # Menu de pausa
    │   │   └── game_over.tscn      # Pantalla Game Over
    │   └── systems/
    │       └── spawner.tscn        # Punto de spawn de enemigos
    │
    ├── assets/                     # Assets importados y listos para el engine
    │   ├── sprites/                # Sprites (.png) para el engine
    │   │   ├── player/             # Sprites del jugador
    │   │   ├── enemies/            # Sprites de enemigos
    │   │   ├── weapons/            # Sprites de armas
    │   │   ├── tiles/              # Tilesets y tiles individuales
    │   │   ├── ui/                 # Elementos de UI
    │   │   └── vfx/                # Sprites de efectos visuales
    │   ├── audio/                  # Audio (.ogg, .wav) para el engine
    │   │   ├── music/              # Musica de fondo
    │   │   └── sfx/                # Efectos de sonido
    │   ├── fonts/                  # Fuentes tipograficas
    │   └── resources/              # Custom Resources (.tres)
    │       └── weapons/            # WeaponData resources por arma
    │
    ├── exports/                    # Builds exportados (en .gitignore)
    │   ├── windows/
    │   ├── linux/
    │   └── macos/
    │
    └── tests/                      # Tests y escenas de prueba
        ├── test_player.tscn        # Escena de prueba para el jugador
        └── test_combat.tscn        # Escena de prueba para combate
```

### Convenciones de nombrado de archivos

| Tipo | Patron | Ejemplo |
|---|---|---|
| Escenas | `snake_case.tscn` | `enemy_zombie.tscn` |
| Scripts GDScript | `snake_case.gd` | `player_combat.gd` |
| Sprites personaje | `char_{nombre}_{estado}.png` | `char_player_idle.png` |
| Sprites UI | `ui_{elemento}_{estado}.png` | `ui_button_hover.png` |
| Tiles | `tile_{nombre}.png` | `tile_castle_floor.png` |
| Musica | `mus_{nombre}.ogg` | `mus_main_theme.ogg` |
| SFX | `sfx_{accion}.wav` | `sfx_sword_swing.wav` |
| Custom Resources | `snake_case.tres` | `weapon_sword_basic.tres` |
| Niveles | `level_{nn}_{nombre}.tscn` | `level_01_castle.tscn` |

**Regla critica:** Todo en `snake_case`. Sin espacios, sin caracteres especiales, sin mayusculas en nombres de archivo. Las clases de GDScript usan `PascalCase` dentro del codigo (`class_name PlayerCombat`), pero el archivo es `player_combat.gd`.

---

## 3. Convenciones de Escena

### Node Types recomendados

| Entidad | Nodo raiz | Justificacion |
|---|---|---|
| Player | `CharacterBody2D` | Control total de movimiento con `move_and_slide()` |
| Enemigos | `CharacterBody2D` | Misma razon; pathfinding con NavigationAgent2D |
| Armas | `Node2D` (hijo del player) | Posicionamiento relativo al jugador |
| Spawner | `Marker2D` | Marca posicion sin logica visual |
| Zonas desbloqueables | `Area2D` + `CollisionShape2D` | Deteccion de interaccion del jugador |
| HUD | `CanvasLayer` > `Control` | UI siempre encima del juego |
| Nivel/Mapa | `Node2D` con `TileMapLayer` | Godot 4.6 usa `TileMapLayer` (no el viejo `TileMap`) |
| Camara | `Camera2D` (hijo del player) | Seguimiento automatico del jugador |

### Estructura tipica de una escena de jugador

```
player.tscn
└── Player (CharacterBody2D)
    ├── Sprite2D (o AnimatedSprite2D)
    ├── CollisionShape2D
    ├── WeaponPivot (Node2D)           # Punto de rotacion del arma
    │   └── Weapon (Node2D)
    ├── HurtBox (Area2D)               # Detecta dano recibido
    │   └── CollisionShape2D
    ├── Camera2D                       # Sigue al jugador
    ├── HealTimer (Timer)              # 60s para curacion pasiva
    └── AnimationPlayer                # Animaciones
```

### Estructura tipica de una escena de enemigo

```
enemy_zombie.tscn
└── EnemyZombie (CharacterBody2D)
    ├── AnimatedSprite2D
    ├── CollisionShape2D
    ├── NavigationAgent2D              # Pathfinding hacia el jugador
    ├── HitBox (Area2D)                # Aplica dano al jugador
    │   └── CollisionShape2D
    └── HurtBox (Area2D)               # Recibe dano de armas
        └── CollisionShape2D
```

---

## 4. Patrones de Diseno

### 4.1 Autoloads (Singletons)

Los Autoloads se registran en `Project > Project Settings > Autoload`. Son scripts que persisten entre escenas.

| Autoload | Script | Responsabilidad |
|---|---|---|
| `GameManager` | `src/autoloads/game_manager.gd` | Estado del juego (menu, jugando, pausa, game_over), ronda actual, puntuacion |
| `InputManager` | `src/autoloads/input_manager.gd` | Abstraccion de input, deteccion gamepad vs teclado |
| `AudioManager` | `src/autoloads/audio_manager.gd` | Reproduccion de musica/SFX, control de buses |
| `SaveManager` | `src/autoloads/save_manager.gd` | Guardar/cargar records y settings en `user://` |

**Ejemplo de GameManager:**

```gdscript
# src/autoloads/game_manager.gd
extends Node

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

signal state_changed(new_state: GameState)
signal round_changed(round_number: int)
signal score_changed(new_score: int)

var current_state: GameState = GameState.MENU
var current_round: int = 0
var score: int = 0

func change_state(new_state: GameState) -> void:
    current_state = new_state
    state_changed.emit(new_state)

func add_score(points: int) -> void:
    score += points
    score_changed.emit(score)

func start_new_round() -> void:
    current_round += 1
    round_changed.emit(current_round)
```

---

## 4.2 Logging y Observabilidad — Autoload `Logging` (2026-03-29)

> **Estado:** Implementado. Script en `scripts/autoload/Logging.gd`, registrado en `project.godot`.

El Autoload `Logging` provee observabilidad local robusta mediante escritura de eventos en formato **JSON-lines** en `papa-gallo/logs/session_<id>.log`.

### API pública

```gdscript
# Registrar cualquier evento desde cualquier script (API canónica)
Logging.write_event({"level": "info", "event": "my_event", "data": {"key": "value"}})

# Forzar escritura a disco (útil antes de operaciones críticas)
Logging.flush()

# Obtener el ID de sesión actual (para correlacionar eventos)
var sid := Logging.get_session_id()

# Obtener la ruta absoluta del log actual
var path := Logging.get_log_path()
```

### Parámetros configurables (export var)

| Variable | Tipo | Default | Descripción |
|---|---|---|---|
| `auto_flush_count` | int | 20 | Eventos en buffer antes de flush automático |
| `auto_flush_interval` | float | 10.0 | Segundos entre flushes por Timer |
| `max_file_size_bytes` | int | 2 MB | Tamaño máximo antes de rotar el log |
| `max_log_files` | int | 10 | Archivos máximos en `logs/` antes de purgar los más viejos |
| `enable_remote_upload` | bool | **false** | Activa upload remoto (Option B — no implementado) |
| `remote_endpoint` | String | `""` | Endpoint de la API remota (Option B) |

### Ejemplo de línea en el log

```json
{"ts":"2026-03-29T10:15:01Z","session_id":"20260329_101501_1234","version":"0.1.0","platform":"macOS","level":"info","event":"round_started","data":{"round":1,"spawn_count":3}}
```

### Limitaciones conocidas

- Las escrituras son **síncronas** (open/write/close por flush) — evitar `write_event()` en `_physics_process()`.
- En modo headless (scripts de smoke test), el Timer no está disponible; se usa `auto_flush_count = 1` para flush inmediato.
- Los archivos de log **no están encriptados** — no incluir PII en los campos `data`.

---

## 4.3 Option B — Integración Remota de Telemetría (Recomendada antes del lanzamiento)

> **Estado:** NO implementada. El Autoload `Logging` tiene los campos `enable_remote_upload` y `remote_endpoint` preparados, pero la lógica de upload queda pendiente. Esta sección documenta la arquitectura recomendada.

### Motivación

La observabilidad local (JSON-lines en disco) es suficiente durante el desarrollo y QA interno. Sin embargo, antes del lanzamiento público necesitamos:

1. **Errores en producción** — capturar crashes y excepciones de jugadores reales.
2. **Métricas de gameplay** — entender hasta qué ronda llegan los jugadores, dónde mueren, qué armas usan.
3. **Datos agregados** — sin acceso físico a la máquina del jugador, los logs locales son invisibles.

### Opción B.1 — Sentry (para errores y crashes)

**Propósito:** Capturar excepciones, crashes y errores en tiempo real desde builds de producción.

**Integración en Godot 4:**

```gdscript
# En Logging.gd — _upload_batch() (implementar cuando se active enable_remote_upload)
func _upload_batch(events: Array[String]) -> void:
    if not enable_remote_upload or remote_endpoint.is_empty():
        return
    var http := HTTPRequest.new()
    add_child(http)
    var payload := JSON.stringify({
        "dsn": remote_endpoint,   # DSN de Sentry
        "events": events,
    })
    http.request(remote_endpoint, ["Content-Type: application/json"], HTTPClient.METHOD_POST, payload)
    # Limpiar nodo al terminar
    await http.request_completed
    http.queue_free()
```

**Checklist para Sentry:**
- [ ] Crear cuenta en [sentry.io](https://sentry.io) (plan free disponible)
- [ ] Crear proyecto tipo "Other" (Godot no tiene SDK nativo oficial)
- [ ] Copiar el DSN del proyecto y guardarlo en variable de entorno (no en el código)
- [ ] Configurar `remote_endpoint` en el Inspector del nodo Logging
- [ ] Activar `enable_remote_upload = true` en builds de release únicamente
- [ ] Filtrar eventos: sólo enviar `level == "error"` para no saturar la cuota gratuita
- [ ] Verificar que **ningún dato de usuario (PII)** se incluye en `data` (ver nota de privacidad)

### Opción B.2 — GameAnalytics (para métricas de gameplay)

**Propósito:** Análisis de comportamiento de jugadores: sesiones, eventos de progresión, retención, funnel de rondas.

**Integración:** GameAnalytics ofrece un SDK para Unity pero no para Godot oficialmente. Alternativas:
1. **HTTP REST API directa** — enviar eventos POST al endpoint de GameAnalytics desde `_upload_batch()`.
2. **Colector propio** — servidor simple (Node.js / Python FastAPI) que recibe los JSON-lines y los reenvía a GameAnalytics o los almacena en una base de datos propia.

**Checklist para GameAnalytics:**
- [ ] Crear cuenta en [gameanalytics.com](https://gameanalytics.com) (plan free: hasta 100k MAU)
- [ ] Obtener `game_key` y `secret_key` del proyecto
- [ ] Implementar autenticación HMAC-SHA256 requerida por la API
- [ ] Mapear eventos del juego a los tipos de GA: `progression`, `design`, `resource`, `error`
- [ ] Decidir batching: enviar cada N minutos o al cerrar la sesión
- [ ] Añadir consentimiento del usuario si el juego se distribuye en la UE (GDPR)

### Opción B.3 — Colector propio mínimo (recomendada para indie)

Para un equipo pequeño, una opción más económica y con control total de los datos:

```
[Godot] --HTTP POST JSON-lines--> [servidor simple] --INSERT--> [PostgreSQL / SQLite]
                                         |
                                  [Metabase / Grafana]  ← dashboards
```

**Stack sugerido:**
- Backend: **FastAPI** (Python) + **SQLite** (MVP) o **PostgreSQL** (producción)
- Dashboard: **Metabase** (gratis, self-hosted) para consultas SQL sin código
- Hosting: **Railway.app** o **Render.com** (gratis en tier básico)

**Costo estimado:** $0–$7/mes para un juego indie con <10k jugadores activos.

### Nota de privacidad

> **IMPORTANTE:** Antes de activar cualquier telemetría remota, se debe:
> 1. Añadir una pantalla de **consentimiento** en el primer arranque del juego.
> 2. Garantizar que **ningún PII** (nombre, email, IP, hardware ID) se incluye en los eventos.
> 3. Documentar la política de privacidad y retención de datos.
> 4. Si el juego se vende en la UE: cumplir con **GDPR** (derecho al olvido, minimización de datos).
>
> El campo `data` de los eventos de `Logging` debe contener **sólo datos de gameplay** (números de ronda, posiciones de juego, tipos de enemigos). **Nunca incluir** usernames, IPs, device IDs o cualquier dato que permita identificar a una persona.

### Resumen de opciones

| Opción | Errores | Gameplay | Costo | Privacidad | Recomendado para |
|---|---|---|---|---|---|
| Local (actual) | ❌ No visible | ❌ No visible | $0 | ✅ Total control | Desarrollo / QA |
| Sentry | ✅ Excelente | ❌ No aplica | $0–$26/mes | ⚠️ Requiere DSN seguro | Pre-launch crashes |
| GameAnalytics | ❌ Básico | ✅ Excelente | $0 (free tier) | ⚠️ GDPR si EU | Launch / retención |
| Colector propio | ✅ Custom | ✅ Total control | $0–$7/mes | ✅ Total control | Indie con recursos |

---

### 4.1 Autoloads implementados — Skeletons (2026-03-29)

> **Estado:** Skeletons creados y registrados en `project.godot`. Lógica completa pendiente de implementación (marcada con `TODO`).
> **Ruta de scripts:** `papa-gallo/scripts/autoload/`
> **Registro en project.godot:** sección `[autoload]`, prefijo `*` (singleton habilitado).

| Autoload | Archivo | Responsabilidad | Señales expuestas |
|---|---|---|---|
| `Logging` | `scripts/autoload/Logging.gd` | Escribe eventos JSON-lines en `logs/session_<id>.log`, buffer/flush/rotation | — |
| `GameManager` | `scripts/autoload/GameManager.gd` | Coordina rondas, puntuación y ciclo de vida de la partida | `round_started(round)`, `round_ended(round)`, `score_changed(new_score)` |
| `InputManager` | `scripts/autoload/InputManager.gd` | Abstrae Input Map, wrappers de consulta y rebinding con persistencia | `input_rebound(action)` |
| `AudioManager` | `scripts/autoload/AudioManager.gd` | Reproduce música y SFX, controla volumen por bus (`"Music"` y `"SFX"`) | — |
| `SaveManager` | `scripts/autoload/SaveManager.gd` | Guarda y carga partidas por slot en `user://save_{slot}.cfg` | — |
| `DebugManager` | `scripts/autoload/DebugManager.gd` | Herramientas de debug activas sólo en `OS.is_debug_build()` | — |

#### Ejemplos de llamadas rápidas

**GameManager:**
```gdscript
GameManager.start_round()                      # Inicia ronda, emite round_started
GameManager.add_puntos(100)                    # Suma 100 pts, emite score_changed
GameManager.round_ended.connect(_on_ronda_fin) # Suscribirse a fin de ronda
GameManager.reset()                            # Reinicia estado para nueva partida
```

**InputManager:**
```gdscript
if InputManager.is_action_just_pressed("attack_primary"): atacar()
InputManager.rebind_action("sprint", nuevo_evento)      # Reasigna tecla y guarda
InputManager.input_rebound.connect(_on_input_rebound)   # Escuchar cambios de binding
```

**AudioManager:**
```gdscript
AudioManager.play_music("mus_main_theme")  # Reproduce música de fondo
AudioManager.play_sfx("sfx_sword_swing")  # Reproduce SFX puntual
AudioManager.set_master_volume(0.7)       # Volumen maestro al 70 %
AudioManager.stop_music()                 # Detiene la música
```

#### 4.1.2 Buses de audio — Estado actual (2026-03-29)

> **Estado:** Buses `Music` y `SFX` creados y configurados en `project.godot` (sección `[audio_buses]`).

Los buses se configuraron directamente en `project.godot` con índices fijos:

| Índice | Nombre   | Envía a  | Volumen por defecto | Mute  |
|--------|----------|----------|---------------------|-------|
| 0      | `Master` | `Master` | 0.0 dB              | false |
| 1      | `Music`  | `Master` | 0.0 dB              | false |
| 2      | `SFX`    | `Master` | 0.0 dB              | false |

**Cómo el AudioManager usa los buses:**

El `AudioManager` referencia los buses **por nombre exacto** (no por índice) para mayor robustez:

```gdscript
# En AudioManager.gd — asignación de bus a un AudioStreamPlayer:
$MusicPlayer.bus = "Music"    # Bus de música (índice 1)
$SFXPlayer.bus = "SFX"        # Bus de SFX (índice 2)

# Control de volumen por bus (en dB):
AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(0.8))
AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(1.0))

# Mute/unmute de un bus:
AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
```

**Assets de audio:** Las carpetas de assets están en `papa-gallo/assets/audio/` con la siguiente estructura:
- `assets/audio/music/` — Música en formato OGG 44.1 kHz, loop habilitado
- `assets/audio/sfx/` — SFX en formato WAV 44.1 kHz, mono cuando sea posible
- `assets/audio/stems/` — Stems para música dinámica (capas separadas)
- `assets/audio/processed/` — Exports intermedios del DAW

Ver `papa-gallo/assets/audio/README.md` para convenciones completas de naming, formatos y pipeline.

**SaveManager:**
```gdscript
SaveManager.save_game(0)                  # Guarda en slot 0
var data = SaveManager.load_game(0)       # Carga slot 0 → Dictionary
if SaveManager.has_save(0): continuar()   # Verifica si existe guardado
```

**DebugManager:** *(sólo activo en builds de debug)*
```gdscript
DebugManager.debug_next_wave()            # Avanza a la siguiente oleada
DebugManager.debug_spawn_enemy("zombie")  # Instancia enemigo de prueba
DebugManager.print_state()               # Imprime estado de GameManager en consola
```

---

### 4.2 Comunicacion por Signals (Patron Observer)

**Regla: Los nodos emiten senales, nunca llaman directamente a otros nodos que no son sus hijos.**

```
                    GameManager (Autoload)
                   /          |            \
         round_changed   score_changed   state_changed
              |               |               |
         RoundManager       HUD          PauseMenu
              |
        enemy_killed (signal del Enemy)
              |
         Spawner ── spawn_enemy()
```

**Conexion de signals en codigo:**

```gdscript
# En _ready() del HUD:
func _ready() -> void:
    GameManager.score_changed.connect(_on_score_changed)
    GameManager.round_changed.connect(_on_round_changed)
    GameManager.state_changed.connect(_on_state_changed)
```

**Signals custom del Player emitidos hacia arriba:**

```gdscript
# player.gd
signal died
signal took_damage(remaining_hp: int)

# En el nivel (level_01_castle.gd), conectar:
func _ready() -> void:
    $Player.died.connect(_on_player_died)
```

### 4.3 Spawner con PackedScene

```gdscript
# src/systems/spawner.gd
extends Marker2D

@export var enemy_scene: PackedScene  # Se asigna en el Inspector
@export var spawn_interval: float = 1.0

func spawn_enemy() -> void:
    var enemy = enemy_scene.instantiate()
    enemy.global_position = global_position
    get_tree().current_scene.add_child(enemy)
```

**Uso:** Colocar nodos `Spawner` en los puntos de entrada de enemigos del mapa. El `RoundManager` le dice a cada Spawner cuantos enemigos generar por oleada.

### 4.4 Scripts Desacoplados (Composicion)

Separar la logica del jugador en scripts que se comunican por signals internos:

```gdscript
# player_health.gd — componente de vida
extends Node

signal health_changed(current: int, max: int)
signal died

@export var max_health: int = 3
var current_health: int

func take_damage(amount: int) -> void:
    current_health -= amount
    health_changed.emit(current_health, max_health)
    if current_health <= 0:
        died.emit()
```

El Player principal (`player.gd`) delega a sus componentes hijos:

```gdscript
# player.gd
extends CharacterBody2D

@onready var health_component: Node = $PlayerHealth
@onready var combat_component: Node = $PlayerCombat

func _ready() -> void:
    health_component.died.connect(_on_died)
```

### 4.5 Custom Resources para datos de armas

```gdscript
# src/weapons/weapon_data.gd
class_name WeaponData
extends Resource

@export var weapon_name: String
@export var damage: int
@export var attack_speed: float
@export var range_pixels: float
@export var stamina_cost: float
@export var cost: int  # Precio en puntos
@export var icon: Texture2D
```

Crear archivos `.tres` por arma (ej: `assets/resources/weapons/weapon_sword_basic.tres`) y asignarlos en el Inspector. Esto permite iterar stats sin tocar codigo.

---

## 5. Subsistemas

### 5.1 Input

- **Sistema:** Input Map nativo de Godot (Project Settings > Input Map)
- **Abstraccion:** `InputManager` autoload detecta si hay gamepad conectado y puede mostrar iconos correspondientes
- **Remapping:** No en MVP
- **Dispositivos:** Teclado (WASD + J/K/Tab/Shift/E/Escape) y Gamepad (stick izq + RB/RT/Y/B/A)

**Input Actions a definir en project.godot:**

| Action | Teclado | Gamepad |
|---|---|---|
| `move_up` | W | Stick izq arriba |
| `move_down` | S | Stick izq abajo |
| `move_left` | A | Stick izq izquierda |
| `move_right` | D | Stick izq derecha |
| `attack_primary` | J | RB |
| `attack_secondary` | K | RT |
| `change_weapon` | Tab | Y |
| `sprint` | Shift | B |
| `interact` | E | A |
| `pause` | Escape | Start |

### 5.2 Renderizado

- **Renderer:** GL Compatibility (ya configurado en project.godot)
- **Resolucion base:** 320x180 (pixel-art escalado x6 a 1920x1080)
- **Stretch mode:** `canvas_items` — escala la ventana manteniendo pixeles nitidos
- **Stretch aspect:** `keep` — mantiene relacion de aspecto
- **Filtro de texturas:** `Nearest` (obligatorio para pixel-art)
- **Camara:** Ortogonal (`Camera2D`), seguimiento del jugador con smoothing

**Settings en project.godot:**

```ini
[display]
window/size/viewport_width=320
window/size/viewport_height=180
window/size/window_width_override=1920
window/size/window_height_override=1080
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"

[rendering]
textures/canvas_textures/default_texture_filter=0  # Nearest
```

### 5.3 Audio

- **Motor:** AudioStreamPlayer / AudioStreamPlayer2D nativo de Godot
- **Buses de audio:** Master, Music, SFX, UI
- **Musica dinamica:** Si — segun vida del jugador y cantidad de enemigos
- **Formatos:**
  - Musica: `.ogg` (OGG Vorbis) — streaming, loop habilitado
  - SFX: `.wav` — carga completa en memoria, baja latencia
- **Pooling de SFX:** Si — usar un pool de `AudioStreamPlayer` para evitar crear/destruir nodos

### 5.4 Fisica

- **Motor:** Godot Physics 2D nativo (el Jolt Physics 3D configurado en project.godot NO se usa — es para 3D)
- **Layers de colision:**

| Layer | Nombre | Colisiona con |
|---|---|---|
| 1 | World | Player, Enemies |
| 2 | Player | World, EnemyHitBox |
| 3 | Enemies | World, PlayerWeapon |
| 4 | PlayerWeapon | Enemies |
| 5 | EnemyHitBox | Player |
| 6 | Interactables | Player |

### 5.5 Save System

- **Formato:** JSON (legible para debug en MVP)
- **Datos guardados:** Record de rondas, configuracion de audio/video
- **Ubicacion:** `user://save_data.json`
- **Slots:** 1 auto-save
- **Encriptacion:** No en MVP

---

## 6. Import Settings (.import)

### Politica general

**Los archivos `.import` SI van al repositorio git.** Esto garantiza que todos los miembros del equipo tengan la misma configuracion de importacion.

### 6.1 Texturas / Sprites

| Setting | Valor | Razon |
|---|---|---|
| `filter` | `false` (Nearest) | Pixel-art NO debe tener filtro bilinear |
| `repeat` | `disabled` | No repetir texturas de sprites |
| `mipmaps` | `false` | No necesario en 2D pixel-art |
| `compress/mode` | `0` (Lossless) | Preservar calidad pixel-perfect |
| `process/fix_alpha_border` | `false` | No modificar bordes de alfa |
| `process/premult_alpha` | `false` | Mantener alfa estandar |
| `svg/scale` | `1.0` | Solo si usas SVG (UI) |

**Preset de importacion recomendado:** Crear un preset "Pixel Art" en Godot (Import dock > Preset > Save) con estos valores y aplicarlo a todas las texturas del proyecto.

### 6.2 Audio

| Tipo | Formato | Import como | Loop | Razon |
|---|---|---|---|---|
| Musica | `.ogg` | `AudioStreamOGGVorbis` (stream) | `true` (configurar loop en el .import) | Streaming ahorra RAM; OGG comprime bien |
| SFX | `.wav` | `AudioStreamWAV` (sample) | `false` | Carga completa en memoria = baja latencia |

**Settings de audio en import:**

- Musica `.ogg`: `loop=true`, `loop_offset=0.0`, `bpm=0`, `beat_count=0`
- SFX `.wav`: `force/8_bit=false`, `force/mono=true` (cuando sea posible — ahorra 50% de memoria), `force/max_rate=false`

### 6.3 Atlas de texturas

Para rendimiento, agrupar sprites relacionados en atlas:

1. **Sprites del jugador:** Agrupar todas las animaciones en un spritesheet unico
2. **Sprites de enemigos:** Un spritesheet por tipo de enemigo
3. **Tiles:** Usar TileSetAtlasSource dentro del editor de TileSet (no TextureAtlas importer)

**Configuracion de atlas:** `editor/import/atlas_max_width = 2048` (default, suficiente para pixel-art).

**Nota:** En pixel-art a 16x16 o 32x32, los atlas no son criticos para rendimiento. Priorizarlos cuando se detecten problemas de draw calls en profiling.

---

## 7. Pipeline de Export a PC

### 7.1 Preparacion

1. **Descargar Export Templates:** En Godot: `Editor > Manage Export Templates > Download` (o descargar manualmente para la version 4.6)
2. **Crear presets de export:** `Project > Export > Add...`

### 7.2 Presets de Export

| Preset | Plataforma | Uso |
|---|---|---|
| `Windows Desktop` | Windows x86_64 | Build principal para PC |
| `Linux` | Linux x86_64 | Build secundaria |
| `macOS` | macOS universal | Build para Mac |

### 7.3 Configuracion de Export (Windows como ejemplo)

**Settings del preset:**

| Setting | Valor recomendado | Razon |
|---|---|---|
| Architecture | `x86_64` | PCs modernos, 64-bit |
| Embed PCK | `true` | Un solo ejecutable, facil distribucion |
| Texture Format > VRAM Compress > S3TC/BPTC | `true` | Compresion GPU estandar para PC |
| Binary Format > Convert text resources | `true` | Menor tamano de build, carga mas rapida |
| Application > Product Name | `PapaGallo` | Nombre del ejecutable |
| Application > File Version | `0.1.0.0` | Versionado del build |

**Custom features (para debug vs release):**

```ini
# Para Debug build:
export_filter="all_resources"

# Para Release build:
export_filter="all_resources"
# Excluir: tests/*, *.md
```

### 7.4 Comandos de Export por CLI

```bash
# Abrir el editor del proyecto
godot -e --path papa-gallo

# Exportar build de release para Windows
godot --headless --path papa-gallo --export-release "Windows Desktop" exports/windows/PapaGallo.exe

# Exportar build de release para Linux
godot --headless --path papa-gallo --export-release "Linux" exports/linux/PapaGallo.x86_64

# Exportar build de release para macOS
godot --headless --path papa-gallo --export-release "macOS" exports/macos/PapaGallo.app

# Exportar build de debug (incluye consola de depuracion)
godot --headless --path papa-gallo --export-debug "Windows Desktop" exports/windows/PapaGallo_debug.exe

# Exportar solo el PCK (sin ejecutable — util para patching)
godot --headless --path papa-gallo --export-pack "Windows Desktop" exports/windows/PapaGallo.pck
```

### 7.5 Carpeta de exports

```
papa-gallo/exports/     # EN .gitignore — no subir builds al repo
├── windows/
│   └── PapaGallo.exe
├── linux/
│   └── PapaGallo.x86_64
└── macos/
    └── PapaGallo.app
```

**Distribucion:** Subir builds a itch.io via Butler o como GitHub Releases.

### 7.6 Settings de compresion para export

| Recurso | Compresion recomendada | Notas |
|---|---|---|
| Texturas | Lossless (PNG) | Pixel-art no tolera compresion con perdida |
| Escenas/Resources | Binary (auto en export) | `convert_text_resources_to_binary = true` |
| Audio musica | OGG Vorbis, quality 6 | Buen balance tamano/calidad |
| Audio SFX | WAV sin comprimir | Latencia minima |

---

## 8. Performance Targets

| Plataforma | FPS objetivo | FPS minimo | RAM objetivo | Notas |
|---|---|---|---|---|
| PC (gama media) | 60 FPS estable | 45 FPS | <500 MB | i5 2020+, GPU integrada |

**Objetivos especificos:**

- Draw calls por frame: <100 (pixel-art 2D tiene bajo overhead)
- Enemigos simultaneos en pantalla: hasta 50 en rondas altas
- Tiempo de carga de escena: <2 segundos

**Herramientas de profiling:**

- Godot Profiler integrado (Debugger > Profiler)
- Godot Monitor (Debugger > Monitors) — FPS, draw calls, physics time
- `OS.get_static_memory_usage()` para trackear memoria en runtime

---

## 9. Mini-Glosario de Comandos Utiles

| Comando | Descripcion |
|---|---|
| `godot -e` | Abrir el editor de Godot en el proyecto actual |
| `godot -e --path papa-gallo` | Abrir el editor apuntando al directorio del proyecto |
| `godot --path papa-gallo` | Ejecutar el juego directamente (sin editor) |
| `godot --headless --path papa-gallo --export-release "Preset" output` | Exportar build sin GUI |
| `godot --headless --path papa-gallo --export-debug "Preset" output` | Exportar build de debug sin GUI |
| `godot --headless --path papa-gallo --export-pack "Preset" output.pck` | Exportar solo el PCK |
| `godot --headless --script res://tools/mi_script.gd` | Ejecutar un script sin abrir el editor |
| `godot --version` | Ver la version instalada de Godot |
| `godot --help` | Ver todos los flags disponibles |
| `godot --verbose` | Ejecutar con logs detallados |
| `godot --debug-collisions` | Ejecutar mostrando shapes de colision |
| `godot --debug-navigation` | Ejecutar mostrando meshes de navegacion |

---

## 10. Dependencias y Librerias Externas

| Libreria / Plugin | Version | Proposito | Fuente |
|---|---|---|---|
| (ninguna por ahora) | — | El MVP usa solo funcionalidad nativa de Godot 4.6 | — |

**Nota:** Evitar dependencias externas en el MVP. Si se necesita un plugin (ej: para gamepad icons), documentarlo aqui antes de integrarlo.

---

## 11. CI / Automatizacion Sugerida

### 11.1 GitHub Actions (para cuando el equipo crezca)

```yaml
# .github/workflows/build.yml
name: Build PapaGallo
on:
  push:
    tags: ['v*']

jobs:
  export:
    runs-on: ubuntu-latest
    container:
      image: barichello/godot-ci:4.6
    steps:
      - uses: actions/checkout@v4
      - name: Export Windows
        run: godot --headless --path papa-gallo --export-release "Windows Desktop" ../exports/PapaGallo.exe
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: PapaGallo-Windows
          path: exports/PapaGallo.exe
```

### 11.2 Pre-commit hooks recomendados

- [ ] gdtoolkit (gdlint + gdformat) para linting de GDScript
- [ ] Verificar naming conventions de assets
- [ ] Conventional Commits (commitlint)

---

## 12. Notas Tecnicas y Decisiones Pendientes

- **TileMap vs TileMapLayer:** Godot 4.6 depreco `TileMap` en favor de `TileMapLayer`. Usar `TileMapLayer` para cada capa del mapa (suelo, muros, decoracion).
- **NavigationAgent2D:** Evaluar si usar Navigation nativa de Godot o pathfinding simplificado (perseguir al jugador en linea recta con raycast para esquivar obstaculos) dado que el mapa es sencillo.
- **Jolt Physics 3D:** Esta configurado en project.godot pero NO se usa (es para 3D). Considerar removerlo para evitar confusion.
- **Resolucion base:** La propuesta 320x180 escalada a 1920x1080 requiere validacion con el artista (Amader). Si los sprites se disenan a 32x32, podria ser 384x216 u otra resolucion que sea multiplo limpio.

---

_Documento creado el 2026-03-29. Version 1.0 — Pendiente de revision y aprobacion del equipo tecnico._
