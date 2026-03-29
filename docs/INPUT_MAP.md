# INPUT MAP — PapaGallo

> **Versión:** 1.0  
> **Motor:** Godot 4.6  
> **Estado:** Aprobado (basado en controles aprobados en reunión 2026-03-28)  
> **Fuente de verdad:** docs/GDD.md §10.1 y §6.3

---

## 1. Tabla de Acciones y Bindings

Las acciones siguen la convención `verbo_complemento` en inglés-lower_snake, alineadas con los **Verbos del Jugador** del GDD §6.3.

| Action Name         | Descripción (GDD)              | Teclado (Primary) | Teclado (Alt) | Gamepad (Xbox)        | Mouse (Alt)          |
|---------------------|--------------------------------|-------------------|---------------|-----------------------|----------------------|
| `move_up`           | Moverse hacia arriba           | W                 | Flecha ↑      | Stick izq. eje Y −    | —                    |
| `move_down`         | Moverse hacia abajo            | S                 | Flecha ↓      | Stick izq. eje Y +    | —                    |
| `move_left`         | Moverse hacia la izquierda     | A                 | Flecha ←      | Stick izq. eje X −    | —                    |
| `move_right`        | Moverse hacia la derecha       | D                 | Flecha →      | Stick izq. eje X +    | —                    |
| `attack_primary`    | Ataque principal               | J                 | Z             | RB (JOY_BUTTON_5)     | Clic izquierdo (LMB) |
| `attack_secondary`  | Ataque secundario              | K                 | X             | RT (JOY_AXIS_5 > 0.5) | Clic derecho (RMB)   |
| `change_weapon`     | Cambiar de arma                | Tab               | Q             | Y (JOY_BUTTON_3)      | Rueda ratón ↑        |
| `sprint`            | Esprintar (consume stamina)    | Shift izq.        | Shift der.    | B (JOY_BUTTON_1)      | —                    |
| `interact`          | Interactuar / Gastar puntos    | E                 | F             | A (JOY_BUTTON_0)      | —                    |
| `pause`             | Menú pausa                     | Escape            | P             | Start (JOY_BUTTON_6)  | —                    |

### Acciones de Debug / Testing (solo builds de desarrollo)

| Action Name          | Descripción                     | Teclado  | Gamepad |
|----------------------|---------------------------------|----------|---------|
| `debug_next_wave`    | Forzar inicio de siguiente ola  | F1       | —       |
| `debug_spawn_enemy`  | Spawnear enemigo en cursor      | F2       | —       |

> **Nota:** Las acciones `debug_*` se deben registrar condicionalmente en `_ready()` con `OS.is_debug_build()` o usando la variable de exportación `debug_mode`, **no** en `project.godot` directamente.

---

## 2. Mapeo de Botones Gamepad (Xbox Layout / XInput)

Godot 4 usa el enum `JoyButton` y `JoyAxis`. La tabla siguiente muestra la correspondencia exacta usada en el snippet:

| Botón Xbox | Constante Godot 4       | Índice numérico | Acción          |
|------------|-------------------------|-----------------|-----------------|
| A          | `JOY_BUTTON_0`          | 0               | `interact`      |
| B          | `JOY_BUTTON_1`          | 1               | `sprint`        |
| X          | `JOY_BUTTON_2`          | 2               | *(sin asignar)* |
| Y          | `JOY_BUTTON_3`          | 3               | `change_weapon` |
| LB         | `JOY_BUTTON_4`          | 4               | *(sin asignar)* |
| RB         | `JOY_BUTTON_5`          | 5               | `attack_primary`|
| Back/View  | `JOY_BUTTON_6`          | 6               | *(sin asignar)* |
| Start/Menu | `JOY_BUTTON_6`*         | 6               | `pause`         |
| L3         | `JOY_BUTTON_8`          | 8               | *(sin asignar)* |
| R3         | `JOY_BUTTON_9`          | 9               | *(sin asignar)* |
| D-Pad ↑    | `JOY_BUTTON_11`         | 11              | *(opcional)* `move_up` |
| D-Pad ↓    | `JOY_BUTTON_12`         | 12              | *(opcional)* `move_down` |
| D-Pad ←    | `JOY_BUTTON_13`         | 13              | *(opcional)* `move_left` |
| D-Pad →    | `JOY_BUTTON_14`         | 14              | *(opcional)* `move_right` |

> **⚠ NOTA IMPORTANTE — XInput vs SDL/Gamepad (Bug conocido en Godot):**  
> En Godot 4, el índice de **Start** puede ser `6` (XInput/SDL) o `7` dependiendo del controlador y el sistema operativo. En Windows con XInput el **Start** es `JOY_BUTTON_6`. En Linux/SDL puede desplazarse. Se recomienda testear con `Input.get_joy_name(0)` en runtime y contemplar ambos en el rebinding panel. Ver también: [Godot issue #73526](https://github.com/godotengine/godot/issues/73526).

### Stick Izquierdo — Ejes de Movimiento

| Eje Xbox        | Constante Godot 4     | Índice | Dirección | Acción       |
|-----------------|-----------------------|--------|-----------|--------------|
| Stick Izq. X −  | `JOY_AXIS_LEFT_X`     | 0      | negativo  | `move_left`  |
| Stick Izq. X +  | `JOY_AXIS_LEFT_X`     | 0      | positivo  | `move_right` |
| Stick Izq. Y −  | `JOY_AXIS_LEFT_Y`     | 1      | negativo  | `move_up`    |
| Stick Izq. Y +  | `JOY_AXIS_LEFT_Y`     | 1      | positivo  | `move_down`  |

### Gatillo Derecho — RT como Ataque Secundario

RT es un **eje analógico** (`JOY_AXIS_TRIGGER_RIGHT`, índice 5), no un botón digital. Se activa con valor `> 0.5` (configurable). Esto permite sensibilidad progresiva en el futuro.

| Gatillo | Constante Godot 4          | Índice | Umbral | Acción             |
|---------|---------------------------|--------|--------|--------------------|
| RT      | `JOY_AXIS_TRIGGER_RIGHT`  | 5      | > 0.5  | `attack_secondary` |

---

## 3. Deadzones y Sensibilidad

### Deadzone por Defecto

Godot 4 aplica un deadzone global de `0.2` a todas las acciones analógicas registradas vía `InputMap.add_action()`. Para el proyecto PapaGallo se recomiendan estos valores:

| Acción           | Deadzone Recomendada | Justificación                                          |
|------------------|----------------------|--------------------------------------------------------|
| `move_*` (ejes)  | `0.2`                | Valor por defecto; adecuado para movimiento top-down   |
| `attack_secondary` (RT) | `0.5`      | RT es gatillo analógico; 0.5 evita activación accidental |
| Resto de acciones | `0.5` (digitales)   | Botones digitales; el deadzone no afecta               |

```gdscript
# Ejemplo: configurar deadzone del stick de movimiento en runtime
InputMap.action_set_deadzone("move_left", 0.2)
InputMap.action_set_deadzone("move_right", 0.2)
InputMap.action_set_deadzone("move_up", 0.2)
InputMap.action_set_deadzone("move_down", 0.2)
```

### Uso de `Input.get_vector()` para Movimiento Fluido

Se recomienda usar `Input.get_vector()` en lugar de cuatro `is_action_pressed()` separados. Este método aplica deadzone circular automáticamente y limita la magnitud del vector a 1.0:

```gdscript
# En Player.gd — _physics_process(delta)
var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
velocity = direction * SPEED
move_and_slide()
```

### Sensibilidad del Stick (Camera / Aim)

En la versión MVP el juego usa vista top-down fija sin cámara rotatoria, por lo que no se requiere sensibilidad de cámara por stick derecho en esta etapa.

---

## 4. Mapeo de Mouse

| Evento Mouse       | Acción sugerida      | Notas                                              |
|--------------------|----------------------|----------------------------------------------------|
| Clic izquierdo     | `attack_primary`     | Alternativa a J; útil en pruebas sin gamepad       |
| Clic derecho       | `attack_secondary`   | Alternativa a K                                    |
| Rueda arriba       | `change_weapon`      | Alternativa a Tab                                  |

> **Nota de diseño:** El GDD aprobado no contempla mouse en controles principales (el juego es WASD + teclado / gamepad). Los bindings de mouse se incluyen como **alternativas de testing** y para facilitar el playtest de personas sin gamepad. No se recomienda anunciarlos como controles oficiales sin validación de UX.

---

## 5. Rebinding en Runtime (Accesibilidad)

### API de Godot 4 para Rebinding

Godot 4 expone la clase `InputMap` como singleton (no requiere Autoload), accesible globalmente:

```gdscript
# Eliminar binding existente
InputMap.action_erase_events("attack_primary")

# Agregar nuevo binding (teclado)
var new_event := InputEventKey.new()
new_event.keycode = KEY_U  # Nueva tecla
InputMap.action_add_event("attack_primary", new_event)

# Guardar en archivo de usuario (persistencia entre sesiones)
# ⚠ InputMap NO persiste automáticamente — el juego debe guardar manualmente:
func save_input_config() -> void:
    var config := ConfigFile.new()
    for action in InputMap.get_actions():
        if action.begins_with("ui_"):
            continue  # Ignorar acciones internas de Godot
        var events := []
        for event in InputMap.action_get_events(action):
            events.append(event)
        config.set_value("input", action, events)
    config.save("user://input_config.cfg")

func load_input_config() -> void:
    var config := ConfigFile.new()
    if config.load("user://input_config.cfg") != OK:
        return
    for action in config.get_section_keys("input"):
        InputMap.action_erase_events(action)
        for event in config.get_value("input", action, []):
            InputMap.action_add_event(action, event)
```

### Remap Panel — Implementación Recomendada

Para el MVP se recomienda un **panel de opciones de teclado simple** en el menú Opciones (ver GDD §11 — flujo de pantallas). El flujo básico es:

1. Mostrar lista de acciones con su binding actual (`InputMap.action_get_events(action)`)
2. Al hacer clic en "cambiar", escuchar el siguiente `InputEvent` con `_input(event)`
3. Validar que no colisione con otra acción (`InputMap.action_has_event(other_action, event)`)
4. Llamar a `InputMap.action_erase_events()` + `InputMap.action_add_event()`
5. Persistir con `save_input_config()`

### Consideraciones de Accesibilidad

- **Soporte para teclados no-QWERTY:** Usar `physical_keycode` en lugar de `keycode` garantiza que la posición de la tecla sea consistente independientemente del layout del teclado (recomendado para WASD).
- **Rebinding de gamepad:** Godot 4 soporta múltiples controllers. Usar `device` en `InputEventJoypadButton` para diferenciar jugadores (futuro coop).
- **Contraste en HUD:** Los iconos de teclas en HUD deben seguir la paleta aprobada (UI/HUD: `A0DDD3`, `6FB0B7` — ver GDD §14.4).

---

## 6. Consejos para Testers y Programadores

### Debug Print de Acciones Activas

```gdscript
# En cualquier script de debug — muestra en Output qué acciones están activas cada frame
func _process(_delta: float) -> void:
    var active_actions := []
    var game_actions := ["move_up", "move_down", "move_left", "move_right",
                         "attack_primary", "attack_secondary", "change_weapon",
                         "sprint", "interact", "pause"]
    for action in game_actions:
        if Input.is_action_pressed(action):
            active_actions.append(action)
    if active_actions.size() > 0:
        print("[INPUT DEBUG] Active: ", active_actions)
```

### UI Overlay de Acciones (Debug HUD)

```gdscript
# DebugInputOverlay.gd — Autoload opcional en builds de desarrollo
extends CanvasLayer

@onready var label: Label = $Label

func _process(_delta: float) -> void:
    if not OS.is_debug_build():
        return
    var lines := ["=== INPUT DEBUG ==="]
    var actions := InputMap.get_actions()
    for action in actions:
        if action.begins_with("ui_") or action.begins_with("debug_"):
            continue
        var pressed := Input.is_action_pressed(action)
        if pressed:
            lines.append("✓ " + action)
    label.text = "\n".join(lines)
```

### Test Unitario Básico — Verificar que las Acciones Existen

```gdscript
# test_input_map.gd — ejecutar en GUT o como script temporal
func test_all_game_actions_registered() -> void:
    var required_actions := [
        "move_up", "move_down", "move_left", "move_right",
        "attack_primary", "attack_secondary", "change_weapon",
        "sprint", "interact", "pause"
    ]
    for action in required_actions:
        assert(InputMap.has_action(action), 
               "Acción no registrada en InputMap: " + action)
        assert(InputMap.action_get_events(action).size() > 0,
               "Acción sin bindings: " + action)
    print("[TEST] Todas las acciones del Input Map verificadas OK")
```

### Checklist de Validación Manual

- [ ] Abrir Project Settings → Input Map y verificar que existen las 10 acciones de juego
- [ ] Probar movimiento WASD en escena de juego (`Input.get_vector()` devuelve Vector2 correcto)
- [ ] Conectar gamepad Xbox y verificar que stick izquierdo mueve al personaje
- [ ] Verificar que RT (ataque secundario) se activa al presionar más de la mitad
- [ ] Verificar que Escape abre el menú de pausa
- [ ] Ejecutar `test_all_game_actions_registered()` sin errores

---

## 7. Autoload — ¿InputManager Singleton?

**Recomendación para PapaGallo MVP:** No crear un Autoload `InputManager` personalizado.

El singleton `Input` de Godot 4 y la clase `InputMap` son suficientes para el MVP. Crear un Autoload adicional añade complejidad sin beneficio claro en esta etapa.

**Cuándo sí tendría sentido** (post-MVP):
- Si se implementa **coop local** (necesitas diferenciar `device` por jugador)
- Si se quiere un sistema de **input buffering** (para combos o timing de ataques)
- Si el **remap panel** necesita ser compartido entre múltiples escenas con estado persistente

```gdscript
# Uso directo recomendado — sin Autoload extra
if Input.is_action_just_pressed("attack_primary"):
    _perform_primary_attack()

if Input.is_action_pressed("sprint") and stamina > 0:
    _apply_sprint(delta)

if Input.is_action_just_pressed("interact"):
    _try_interact_with_zone()
```

---

## 8. Referencia Rápida — Constantes de Godot 4

```
# KeyCode — teclas de PapaGallo
KEY_W, KEY_A, KEY_S, KEY_D       # Movimiento
KEY_J                             # Ataque primario
KEY_K                             # Ataque secundario
KEY_TAB                           # Cambiar arma
KEY_SHIFT                         # Esprintar (shift izquierdo = physical_keycode)
KEY_E                             # Interactuar
KEY_ESCAPE                        # Pausa

# JoyButton — gamepad (Xbox layout)
JOY_BUTTON_0   # A → interact
JOY_BUTTON_1   # B → sprint
JOY_BUTTON_3   # Y → change_weapon
JOY_BUTTON_5   # RB → attack_primary
JOY_BUTTON_6   # Start → pause

# JoyAxis — ejes analógicos
JOY_AXIS_LEFT_X    # 0 — stick izq. horizontal
JOY_AXIS_LEFT_Y    # 1 — stick izq. vertical
JOY_AXIS_TRIGGER_RIGHT  # 5 — RT → attack_secondary
```
