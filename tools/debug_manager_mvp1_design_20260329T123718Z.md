# Diseño mínimo — debug-manager-mvp1

## Objetivo

Definir el wiring mínimo para implementar MVP-1 de `DebugManager` sin leer más código del repo: autoload seguro en headless, hotkeys F1-F5 en runtime, HUD oculto por defecto, integración con `Logging.write_event()` y actualización de smoke tests.

## Decisiones de diseño

1. **Headless-first**
   - `papa-gallo/scripts/autoload/DebugManager.gd` debe calcular `_is_headless` en `_ready()` con un helper sugerido:
     - `func _detect_headless() -> bool: return OS.has_feature("headless") or not DisplayServer.has_screen()`
     - fallback aceptable: `DisplayServer.get_name() == "headless"` si el proyecto ya usa ese patrón en `Logging.gd`.
   - Si `_is_headless == true`, **no** instanciar `CanvasLayer`, `Control`, `Window` ni registrar hotkeys visuales. Las APIs públicas siguen funcionando para smoke tests.

2. **Hotkeys runtime-only**
   - Registrar acciones en `_register_debug_actions()` sin tocar `project.godot`:
     - `debug_toggle_hud` → `KEY_F1`
     - `debug_next_wave` → `KEY_F2`
     - `debug_spawn_enemy` → `KEY_F3`
     - `debug_teleport_player` → `KEY_F4`
     - `debug_toggle_console` → `KEY_F5`
   - `_input(event: InputEvent)` despacha a:
     - `_toggle_debug_hud()`
     - `debug_next_wave()`
     - `debug_spawn_enemy(enemy_scene_path := "res://scenes/enemies/Enemy.tscn")`
     - `debug_teleport_player(target_position := Vector2.ZERO)`
     - `_toggle_dev_console()`

3. **HUD de depuración**
   - Crear `papa-gallo/scenes/ui/DebugHUD.tscn` y `papa-gallo/scripts/ui/DebugHUD.gd`.
   - `DebugManager` lo instancia solo en GUI debug builds.
   - El HUD empieza con `visible = false` y F1 alterna visibilidad.
   - Campos mínimos: FPS, `player.global_position`, ronda actual y `Logging.session_id`.
   - Refresco sugerido: 1 Hz.

4. **Consola de desarrollo**
   - F5 debe llamar `_toggle_dev_console()`.
   - Si ya existe una consola (por nombre/grupo, por ejemplo `DevConsole`), alternar `visible`.
   - Si no existe todavía, mantener un stub seguro que haga `push_warning("Dev console not found")` y registre evento igualmente; esto deja el hotkey implementado sin bloquear MVP-1.

## Contrato de eventos Logging

Usar la forma actual de `Logging.write_event()` del proyecto y garantizar estos nombres/payloads:

| Trigger | Evento | Payload mínimo |
|---|---|---|
| F1 / `_toggle_debug_hud()` | `debug_hud_toggle` | `{ "visible": true|false, "source": "F1", "headless": bool, "timestamp": Time.get_unix_time_from_system() }` |
| F2 / `debug_next_wave()` | `debug_next_wave` | `{ "source": "F2", "round_before": int, "round_after": int, "timestamp": ... }` |
| F3 / `debug_spawn_enemy()` | `debug_spawn` | `{ "source": "F3", "who": "player", "scene": "res://scenes/enemies/Enemy.tscn", "spawn_position": [x, y], "timestamp": ... }` |
| F4 / `debug_teleport_player()` | `debug_teleport` | `{ "source": "F4", "who": "player", "from": [x, y], "to": [x, y], "timestamp": ... }` |
| F5 / `_toggle_dev_console()` | `debug_console_toggle` | `{ "source": "F5", "visible": true|false, "headless": bool, "timestamp": ... }` |

## Archivos previstos

- `papa-gallo/scripts/autoload/DebugManager.gd`
- `papa-gallo/scenes/ui/DebugHUD.tscn`
- `papa-gallo/scripts/ui/DebugHUD.gd`
- `papa-gallo/tools/smoke_test_enemy.gd`
- `papa-gallo/tools/smoke_test_player.gd`
- `tools/run_all_tests.sh`

## Estrategia de pruebas

1. **Headless smoke**: confirmar que `DebugManager` carga sin nodos visuales en headless.
2. **Eventos**: tras invocar APIs de debug, buscar en el log JSON strings exactos como:
   - `"event":"debug_next_wave"`
   - `"event":"debug_spawn"`
   - `"scene":"res://scenes/enemies/Enemy.tscn"`
   - `"event":"debug_teleport"`
   - `"event":"debug_console_toggle"`
3. **Consolidación de smoke tests**: tratar `papa-gallo/tools/smoke_test_player.gd` como canónico y migrar/eliminar el duplicado `tools/smoke_test_player.gd` en una PR separada o en el cleanup final del MVP.

## Riesgos conocidos

- El path real del enemigo puede diferir de `res://scenes/enemies/Enemy.tscn`; la tarea de implementación debe verificarlo antes de codificar.
- Si no existe todavía una UI de consola, F5 quedará como stub observable por logs, no como consola visual completa.
- La consolidación de smoke tests puede requerir ajustar rutas del runner antes de tocar assertions.
