# Especificación Técnica: debug-manager-mvp1

**Proyecto:** gameDevelopment / papa-gallo
**Autor:** sdd-spec sub-agent
**Fecha:** 2026-03-29

Esta especificación detalla la implementación del MVP para el `DebugManager`, alineado con la propuesta aprobada en `debug_mvp_proposal_20260329T120235Z.md`.

---

## 1. Requisitos Funcionales

El Autoload `DebugManager` servirá como el núcleo de las herramientas de desarrollo in-game, operando **únicamente** en builds de debug (`OS.is_debug_build()`). 

### Comportamiento de Hotkeys (Asignación en Runtime)
Las siguientes teclas deben registrarse dinámicamente en el `InputMap` a través de código y escuchar eventos en `_input()`. **No** deben añadirse al `project.godot`.

*   **F1 - Toggle HUD:**
    *   Muestra u oculta la capa del `DebugHUD` en pantalla.
    *   *Headless:* Inactivo.
*   **F2 - Next Wave:**
    *   Llama a `GameManager.end_round()` seguido por `GameManager.start_round()`.
    *   Avanza forzosamente la oleada actual en el flujo de juego.
    *   *Headless:* Activo (API callable sin input event).
*   **F3 - Spawn Enemy:**
    *   Instancia la escena por defecto `res://scenes/enemies/enemy.tscn` (o el fallback apropiado, e.g. `enemy_zombie.tscn`).
    *   El enemigo se ubica en la posición del jugador + `Vector2(50, 0)`. Si no hay jugador, lo ubica en `Vector2.ZERO`.
    *   *Headless:* Activo.
*   **F4 - Teleport Origin:**
    *   Localiza el primer nodo del grupo `"player"` (`get_tree().get_nodes_in_group("player")`).
    *   Si existe, setea su `global_position = Vector2.ZERO`.
    *   *Headless:* Activo.
*   **F5 - Verbose State:**
    *   Imprime en consola un dump detallado de los Autoloads: `GameManager`, `SaveManager`, `Logging`, y `DebugManager`.
    *   *Headless:* Activo (impresión en `stdout`).

### Comportamiento Headless (`DisplayServer.get_name() == "headless"`)
*   No se registra ninguna tecla en `InputMap`.
*   No se instancia ni se carga `debug_hud.tscn` para evitar errores gráficos en el servidor CI.
*   Las APIs públicas continúan funcionando sin errores.

---

## 2. Modelos de Datos y Esquema (Logging)

Todas las acciones del `DebugManager` emitirán eventos al sistema de telemetría unificado `Logging.write_event()`.

| Evento | Nivel | Data Payload (Ejemplo en JSON) | Descripción |
| :--- | :--- | :--- | :--- |
| `debug_hud_toggled` | `debug` | `{"visible": true}` | Emitido al presionar F1. Indica si el HUD se mostró u ocultó. |
| `debug_next_wave` | `debug` | `{"round": 3}` | Emitido al presionar F2. Refleja la nueva ronda del GameManager. |
| `debug_spawn_enemy` | `debug` | `{"enemy_type": "enemy", "position": "(50, 0)"}` | Emitido al presionar F3. Informa tipo de enemigo y posición de spawn. |
| `debug_teleport_player`| `debug` | `{"pos": "(0, 0)"}` | Emitido al presionar F4. Informa a dónde se movió el jugador. |
| `debug_verbose_state` | `debug` | `{"round": 3, "is_running": true, "puntos": 100, "session_id": "...", "has_save": true}` | Emitido al presionar F5 con el volcado completo. |

---

## 3. Requisitos No Funcionales

1.  **Rendimiento del HUD:** El `DebugHUD` debe actualizar sus etiquetas de texto (`FPS`, `Player Pos`, `Ronda`) **como máximo a 1Hz** (1 vez por segundo).
    *   *Restricción:* NO usar `_process(delta)` calculando strings en cada frame. Usar un nodo `Timer` interno que dispare la actualización.
2.  **Seguridad de Release:** En builds de exportación de Release, cualquier llamada a las funciones del `DebugManager` debe hacer un retorno anticipado inofensivo (`if not _is_debug: return`).
3.  **No Acoplamiento Duro:** `DebugManager` no debe presuponer referencias directas. Debe usar grupos (`"player"`) para buscar al jugador, y emitir un `push_warning` si las escenas/nodos no se encuentran.

---

## 4. Firmas de API y Archivos a Modificar

### Archivo: `papa-gallo/scripts/autoload/DebugManager.gd`

```gdscript
# Propiedades
var _is_debug: bool = OS.is_debug_build()
var _is_headless: bool = false
var _debug_hud: CanvasLayer = null

# Métodos Privados
func _ready() -> void: # Verifica headless, instancia HUD si aplica, invoca _register_debug_actions()
func _register_debug_actions() -> void: # Registra F1 a F5 dinámicamente si _is_debug y not _is_headless
func _input(event: InputEvent) -> void: # Captura y despacha llamadas

# Métodos Públicos (APIs)
func debug_next_wave() -> void: # Llama end/start round, loggea evento
func debug_spawn_enemy(enemy_type: String = "enemy") -> void: # Instancia escena, loggea evento
func debug_teleport_player(pos: Vector2 = Vector2.ZERO) -> void: # Busca grupo "player", mueve nodo, loggea evento
func print_verbose_state() -> void: # Extrae data, hace print, loggea evento
```

### Archivo (Nuevo): `papa-gallo/scenes/ui/debug_hud.tscn`
Escena con `CanvasLayer` (Layer=100) -> `PanelContainer` -> `VBoxContainer` con 4 `Label`. Debe incluir un `Timer` (wait_time=1.0, autostart).

### Archivo (Nuevo): `papa-gallo/scripts/ui/debug_hud.gd`

```gdscript
@onready var fps_label: Label
@onready var player_pos_label: Label
@onready var round_label: Label
@onready var session_label: Label

func _ready() -> void: # Configura el Timer y conecta timeout
func _on_timer_timeout() -> void: # Actualiza los valores de todos los labels buscando información en Autoloads/Grupos
```

---

## 5. Criterios de Aceptación y Pruebas Automatizadas (Smoke Tests)

Añadir las siguientes aserciones al conjunto de pruebas para garantizar el contrato.

### `tools/smoke_test_enemy.gd` o equivalente:
```gdscript
# Comprobar que en headless DebugManager está inicializado correctamente
assert(DebugManager != null, "DebugManager debe estar presente en el SceneTree")

# Verificar que HUD no se carga en headless
var hud_exists = DebugManager.get_node_or_null("DebugHUD") != null
assert(hud_exists == false, "DebugHUD no debe instanciarse en modo headless")

# Verificar invocación de spawn_enemy sin fallos de escena (testear la API)
DebugManager.debug_spawn_enemy("enemy")
var test_enemy_spawned = get_tree().get_node_count_in_group("enemy") > 0
# No bloquear el test si enemy_type falla, pero asegurar que DebugManager.debug_spawn_enemy() ejecute de forma robusta
```

---

## 6. Estimación de Esfuerzo y Orden Sugerido

| Sección / Tarea | Tamaño | Esfuerzo | Orden Sugerido |
| :--- | :---: | :--- | :--- |
| **Paso 0:** Consolidar tests duplicados (`smoke_test_player.gd`) | Small | 30 min | 1 (Deuda Técnica) |
| **Paso 1:** Detección Headless y flags base en `DebugManager` | Small | 30 min | 2 (Base) |
| **Paso 2:** Registro de Hotkeys (`_register_debug_actions`) | Small | 1 hora | 3 |
| **Paso 3:** Implementación acciones (`spawn`, `teleport`, `next_wave`) | Medium | 1.5 horas | 4 |
| **Paso 4:** Telemetría (`Logging.write_event`) en todas las APIs | Small | 30 min | 5 |
| **Paso 5:** Creación de la escena `debug_hud.tscn` y lógica (1Hz) | Medium | 1.5 horas | 6 (UI) |
| **Paso 6:** Integrar `print_verbose_state()` | Small | 1 hora | 7 |
| **Paso 7:** Documentación en `TDD_GODOT_4_6.md` | Small | 30 min | 8 |

---

## 7. Preguntas Abiertas / Bloqueantes (Atención al Implementador)

1.  **Nombre exacto de la escena enemigo:** La especificación actual asume `res://scenes/enemies/enemy.tscn` como base. *Si falla, emitirá un warning.* El implementador en `sdd-apply` debe confirmar el path real buscando en el disco antes de programar la ruta quemada en código.
2.  **Duplicación de `smoke_test_player.gd`:** Debe unificarse la versión del directorio raíz con la de `/papa-gallo/tools/` (como se detalla en el Paso 0) antes de añadir las aserciones de prueba sugeridas.
