# INPUT README — Guía de Aplicación del Input Map

> **Para:** Equipo de desarrollo — Amader, Xoje, El Negro  
> **Motor:** Godot 4.6  
> **Snippet fuente:** `snippets/godot/input_project_snippet.txt`  
> **Referencia técnica completa:** `docs/INPUT_MAP.md`

---

## Paso 1 — Aplicar el Snippet a `project.godot`

### Método A: Pegar manualmente (recomendado para el MVP)

1. Abrir el archivo `papa-gallo/project.godot` en cualquier editor de texto.
2. Verificar que el archivo termina con la última sección existente (actualmente `[rendering]`).
3. Abrir `snippets/godot/input_project_snippet.txt`.
4. Copiar **todo el contenido entre las líneas `[input]` y el primer bloque de comentarios `; NOTA:`** (es decir, desde `[input]` hasta la línea que dice `pause={...}`).
5. Pegar al **final** del archivo `project.godot`, después de la última línea existente.
6. Guardar el archivo.

El resultado final de `project.godot` debe quedar así:

```ini
config_version=5

[application]
config/name="PapaGallo"
config/features=PackedStringArray("4.6", "GL Compatibility")
config/icon="res://icon.svg"

[physics]
3d/physics_engine="Jolt Physics"

[rendering]
rendering_device/driver.windows="d3d12"
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"

[input]
move_up={ ... }
move_down={ ... }
... (resto de acciones)
```

### Método B: Desde el Editor Godot (alternativa visual)

Si prefieres configurar los controles desde la interfaz gráfica:

1. Abrir el proyecto en el editor Godot 4.6.
2. Ir a **Project → Project Settings → Input Map**.
3. Activar la pestaña **Input Map** (no "General").
4. Para cada acción de la tabla en `docs/INPUT_MAP.md §1`:
   a. Escribir el nombre de la acción en el campo superior (ej. `move_up`) y presionar **Add**.
   b. Hacer clic en el botón **+** a la derecha de la acción recién creada.
   c. Seleccionar el tipo de evento (Key, Joypad Button, Joypad Motion).
   d. Presionar la tecla/botón deseado o seleccionar el eje del joystick.
   e. Confirmar con **OK**.
5. Repetir para los 10 acciones de juego.
6. **Close** — Godot guardará automáticamente en `project.godot`.

> **Nota:** El Método B es equivalente al Método A. Godot genera el mismo formato INI. Si ya pegaste el snippet (Método A), el editor lo mostrará correctamente al abrirlo.

---

## Paso 2 — Validar que el Input Map Funciona

### 2.1 Verificación Visual en el Editor

1. Abrir el proyecto en Godot 4.6.
2. Ir a **Project → Project Settings → Input Map**.
3. Confirmar que aparecen exactamente estas 10 acciones:
   - `move_up`, `move_down`, `move_left`, `move_right`
   - `attack_primary`, `attack_secondary`
   - `change_weapon`, `sprint`, `interact`, `pause`
4. Cada acción debe mostrar sus bindings (mínimo 1 teclado + 1 gamepad para las acciones principales).

### 2.2 Script de Verificación Automática

Crear un archivo temporal `test_input.gd` y ejecutarlo como **Script** en cualquier nodo de la escena de prueba:

```gdscript
extends Node

func _ready() -> void:
    _verify_input_map()

func _verify_input_map() -> void:
    var required := [
        "move_up", "move_down", "move_left", "move_right",
        "attack_primary", "attack_secondary",
        "change_weapon", "sprint", "interact", "pause"
    ]
    var errors := 0
    for action in required:
        if not InputMap.has_action(action):
            push_error("[INPUT] Acción FALTANTE: " + action)
            errors += 1
        elif InputMap.action_get_events(action).size() == 0:
            push_warning("[INPUT] Acción sin bindings: " + action)
            errors += 1
        else:
            print("[INPUT] ✓ ", action, " — ", 
                  InputMap.action_get_events(action).size(), " binding(s)")
    
    if errors == 0:
        print("\n[INPUT] ✅ Todas las acciones verificadas correctamente.")
    else:
        push_error("\n[INPUT] ❌ " + str(errors) + " problema(s) encontrado(s).")
```

**Salida esperada en Output:**
```
[INPUT] ✓ move_up — 3 binding(s)
[INPUT] ✓ move_down — 3 binding(s)
[INPUT] ✓ move_left — 3 binding(s)
[INPUT] ✓ move_right — 3 binding(s)
[INPUT] ✓ attack_primary — 4 binding(s)
[INPUT] ✓ attack_secondary — 4 binding(s)
[INPUT] ✓ change_weapon — 4 binding(s)
[INPUT] ✓ sprint — 3 binding(s)
[INPUT] ✓ interact — 3 binding(s)
[INPUT] ✓ pause — 3 binding(s)

[INPUT] ✅ Todas las acciones verificadas correctamente.
```

### 2.3 Test de Gameplay Manual

Una vez aplicado el snippet, ejecutar la escena principal y verificar:

- [ ] **WASD** mueve al personaje en las 4 direcciones
- [ ] **J** activa ataque primario
- [ ] **K** activa ataque secundario  
- [ ] **Tab** cambia de arma
- [ ] **Shift** activa sprint (la barra de stamina del HUD disminuye)
- [ ] **E** activa interacción con zona de compra
- [ ] **Escape** abre menú de pausa
- [ ] (Con gamepad) **Stick izquierdo** mueve al personaje
- [ ] (Con gamepad) **RB** activa ataque primario
- [ ] (Con gamepad) **RT** activa ataque secundario
- [ ] (Con gamepad) **Y** cambia de arma
- [ ] (Con gamepad) **B** activa sprint
- [ ] (Con gamepad) **A** activa interacción
- [ ] (Con gamepad) **Start** abre menú de pausa

---

## Paso 3 — Usar las Acciones en Scripts GDScript

### Patrón Básico (sin Autoload extra)

```gdscript
# Player.gd
extends CharacterBody2D

const SPEED := 200.0
const SPRINT_MULTIPLIER := 1.6

func _physics_process(delta: float) -> void:
    # Movimiento — usa get_vector() para deadzone circular automática
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    var current_speed := SPEED
    if Input.is_action_pressed("sprint") and stamina > 0:
        current_speed *= SPRINT_MULTIPLIER
        stamina -= STAMINA_DRAIN_RATE * delta
    
    velocity = direction * current_speed
    move_and_slide()

func _input(event: InputEvent) -> void:
    # Acciones que responden al momento exacto de la pulsación (just_pressed)
    if Input.is_action_just_pressed("attack_primary"):
        _perform_primary_attack()
    
    if Input.is_action_just_pressed("attack_secondary"):
        _perform_secondary_attack()
    
    if Input.is_action_just_pressed("change_weapon"):
        _cycle_weapon()
    
    if Input.is_action_just_pressed("interact"):
        _try_interact()

func _unhandled_input(event: InputEvent) -> void:
    # Pausa — mejor en _unhandled_input para no interferir con UI
    if Input.is_action_just_pressed("pause"):
        get_tree().paused = not get_tree().paused
        $PauseMenu.visible = get_tree().paused
```

### Diferencia entre `_input()` y `_unhandled_input()`

| Método | Cuándo usarlo |
|--------|---------------|
| `_input(event)` | Acciones de gameplay que siempre deben responder |
| `_unhandled_input(event)` | Acciones de UI/pausa que no deben activarse si la UI consume el evento |
| `_process(delta)` + `is_action_pressed()` | Acciones continuas (movimiento, sprint) |

### Exponer Acciones para UI (Botones de Acción en HUD)

Para mostrar en el HUD qué tecla corresponde a cada acción:

```gdscript
# HUDController.gd
func get_binding_label(action: String) -> String:
    var events := InputMap.action_get_events(action)
    for event in events:
        if event is InputEventKey:
            # Mostrar nombre de tecla legible
            return OS.get_keycode_string(event.physical_keycode)
        elif event is InputEventJoypadButton:
            # Mostrar nombre del botón según layout detectado
            return _get_gamepad_label(event.button_index)
    return "?"

func _get_gamepad_label(button_index: int) -> String:
    # Adaptar según Input.get_joy_name(0) si se detecta PS vs Xbox
    match button_index:
        0: return "A"
        1: return "B"
        3: return "Y"
        5: return "RB"
        6: return "Start"
        _: return "BTN" + str(button_index)

# Ejemplo de uso en HUD:
# $InteractLabel.text = "[" + get_binding_label("interact") + "] Interactuar"
```

---

## Paso 4 — Registrar Acciones de Debug (solo builds de desarrollo)

Las acciones `debug_next_wave` y `debug_spawn_enemy` **no** están en `project.godot`. Registrarlas en código:

```gdscript
# DebugManager.gd (Autoload o nodo en escena de desarrollo)
extends Node

func _ready() -> void:
    if not OS.is_debug_build():
        return  # No registrar en builds de release
    
    _register_debug_actions()

func _register_debug_actions() -> void:
    # debug_next_wave → F1
    if not InputMap.has_action("debug_next_wave"):
        InputMap.add_action("debug_next_wave")
        var f1 := InputEventKey.new()
        f1.physical_keycode = KEY_F1
        InputMap.action_add_event("debug_next_wave", f1)
    
    # debug_spawn_enemy → F2
    if not InputMap.has_action("debug_spawn_enemy"):
        InputMap.add_action("debug_spawn_enemy")
        var f2 := InputEventKey.new()
        f2.physical_keycode = KEY_F2
        InputMap.action_add_event("debug_spawn_enemy", f2)

func _input(event: InputEvent) -> void:
    if not OS.is_debug_build():
        return
    
    if Input.is_action_just_pressed("debug_next_wave"):
        print("[DEBUG] Forzando siguiente oleada...")
        GameManager.force_next_wave()
    
    if Input.is_action_just_pressed("debug_spawn_enemy"):
        print("[DEBUG] Spawneando enemigo en posición del cursor...")
        GameManager.spawn_enemy_at(get_global_mouse_position())
```

---

## Paso 5 — Rebinding en Runtime (Panel de Opciones)

Si el equipo decide implementar rebinding en el menú de Opciones (recomendado para post-MVP):

```gdscript
# RebindButton.gd — Botón en el panel de opciones
extends Button

var action_name: String = ""
var is_listening: bool = false

func _ready() -> void:
    pressed.connect(_start_listening)
    _update_label()

func _start_listening() -> void:
    is_listening = true
    text = "Presiona una tecla..."
    set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
    if not is_listening:
        return
    
    # Solo aceptar Key o JoypadButton
    if not (event is InputEventKey or event is InputEventJoypadButton):
        return
    
    # Verificar colisión con otras acciones
    for other_action in InputMap.get_actions():
        if other_action == action_name:
            continue
        if InputMap.action_has_event(other_action, event):
            push_warning("Tecla ya usada en: " + other_action)
            _cancel_listen()
            return
    
    # Aplicar nuevo binding
    InputMap.action_erase_events(action_name)
    InputMap.action_add_event(action_name, event)
    is_listening = false
    _update_label()
    _save_config()
    get_viewport().set_input_as_handled()

func _update_label() -> void:
    var events := InputMap.action_get_events(action_name)
    text = events[0].as_text() if events.size() > 0 else "Sin asignar"

func _cancel_listen() -> void:
    is_listening = false
    _update_label()

func _save_config() -> void:
    var config := ConfigFile.new()
    for action in InputMap.get_actions():
        if action.begins_with("ui_"):
            continue
        config.set_value("input", action, InputMap.action_get_events(action))
    config.save("user://input_config.cfg")
```

**Cargar la config al iniciar el juego** (en el Autoload principal o en `_ready()` de la escena raíz):

```gdscript
func _load_input_config() -> void:
    var config := ConfigFile.new()
    if config.load("user://input_config.cfg") != OK:
        return  # Usar defaults de project.godot
    for action in config.get_section_keys("input"):
        if not InputMap.has_action(action):
            continue
        InputMap.action_erase_events(action)
        for event in config.get_value("input", action, []):
            InputMap.action_add_event(action, event)
    print("[INPUT] Configuración de controles cargada desde archivo de usuario.")
```

---

---

## Verificación Aplicada

> **Fecha de aplicación:** 2026-03-29  
> **Aplicado por:** Agente SDD (sdd-apply)  
> **Motor verificado:** Godot Engine v4.6.1.stable.official

### Backup creado

Se creó copia de seguridad antes de modificar el archivo:

```
papa-gallo/project.godot.bak.2026-03-29T08:38:15Z
```

### Sección `[input]` actualizada

La sección `[input]` fue añadida al final de `papa-gallo/project.godot` con las 10 acciones del GDD.  
No existía sección `[input]` previa — se insertó sin conflictos.

**Acciones aplicadas:**
- `move_up`, `move_down`, `move_left`, `move_right` → deadzone 0.2 (WASD + flechas + stick izquierdo)
- `attack_primary`, `attack_secondary` → deadzone 0.5 (J/Z + click + RB/RT gamepad)
- `change_weapon`, `sprint`, `interact`, `pause` → deadzone 0.5 (teclado + gamepad)
- `debug_next_wave`, `debug_spawn_enemy` → **NO** en project.godot (se registran en código, ver Paso 4)

### Script de verificación

Ruta: `tools/check_input_map.gd`

**Comando para ejecutar desde línea de comandos** (desde la carpeta `papa-gallo/`):

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --script ../tools/check_input_map.gd
# En Linux/Windows con Godot en PATH:
# godot --headless --script ../tools/check_input_map.gd
```

**Instrucciones desde el editor Godot:**
1. Abrir el proyecto en Godot 4.6
2. Abrir el Script Editor: `Script → File → Open...` → seleccionar `tools/check_input_map.gd`
3. Presionar el botón **Run** (ícono ▶) o `Ctrl+Shift+X`
4. La salida aparece en la pestaña **Output** (panel inferior)

### Salida de verificación (ejecutada 2026-03-29)

```
Godot Engine v4.6.1.stable.official.14d19694e - https://godotengine.org

=== VERIFICACIÓN INPUT MAP — PapaGallo ===
    Motor: Godot 4.6 | Fecha: 2026-03-29
==========================================

[INPUT] ✓ move_up              — 3 binding(s): Key(W), Key(Up), JoyAxis(-StickIz-Y)
[INPUT] ✓ move_down            — 3 binding(s): Key(S), Key(Down), JoyAxis(+StickIz-Y)
[INPUT] ✓ move_left            — 3 binding(s): Key(A), Key(Left), JoyAxis(-StickIz-X)
[INPUT] ✓ move_right           — 3 binding(s): Key(D), Key(Right), JoyAxis(+StickIz-X)
[INPUT] ✓ attack_primary       — 4 binding(s): Key(J), Key(Z), Mouse(Click-Izq), Joy(RB)
[INPUT] ✓ attack_secondary     — 4 binding(s): Key(K), Key(X), Mouse(Click-Der), JoyAxis(+RT)
[INPUT] ✓ change_weapon        — 4 binding(s): Key(Tab), Key(Q), Mouse(Wheel-Up), Joy(Y)
[INPUT] ✓ sprint               — 3 binding(s): Key(Shift-L), Key(Shift-R), Joy(B)
[INPUT] ✓ interact             — 3 binding(s): Key(E), Key(F), Joy(A)
[INPUT] ✓ pause                — 3 binding(s): Key(Escape), Key(P), Joy(Start)

--- Acciones de Debug (solo modo desarrollo) ---
[DEBUG] ℹ debug_next_wave        — No registrada (esperado: se añade en código vía DebugManager.gd)
[DEBUG] ℹ debug_spawn_enemy      — No registrada (esperado: se añade en código vía DebugManager.gd)

==========================================
    RESUMEN:
    ✓ OK:          10 / 10 acciones

    ✅ Todas las acciones verificadas correctamente.
       El Input Map está listo para usar en PapaGallo.
==========================================
```

### Hallazgos y notas

- **Sin conflictos**: No había sección `[input]` previa en `project.godot` — inserción limpia.
- **`physical_keycode` verificados**: Godot 4.6.1 resolvió todos los valores correctamente (W=87, S=83, A=65, D=68, Escape=4194305, Tab=4194306, Shift=4194325, flechas=4194319–4194322).
- **`attack_secondary` con RT (axis 5)**: Godot reconoció `JoyAxis(+RT)` — funciona como evento digital con deadzone 0.5.
- **Acciones debug**: No registradas en `project.godot` por diseño (solo debug builds via `DebugManager.gd`).
- **Gamepad**: No se pudo probar físicamente (entorno headless sin dispositivo). Los índices de botones siguen el estándar SDL2/Xbox que Godot usa internamente.

---

## Resumen de Archivos Relacionados

| Archivo | Propósito |
|---------|-----------|
| `papa-gallo/project.godot` | Configuración del proyecto — aquí van las acciones del Input Map |
| `docs/INPUT_MAP.md` | Referencia técnica completa: tabla de acciones, deadzones, gamepad, accesibilidad |
| `docs/INPUT_README.md` | Este archivo — guía de aplicación paso a paso |
| `snippets/godot/input_project_snippet.txt` | Snippet listo para pegar + versión JSON de referencia |

---

## Preguntas Frecuentes

**¿Por qué `physical_keycode` en lugar de `keycode`?**  
`physical_keycode` garantiza que la tecla W siempre sea "la tecla en la posición W del teclado QWERTY", independientemente del layout del sistema operativo. Esto es especialmente importante para WASD con jugadores con teclados en español, francés (AZERTY) o alemán (QWERTZ).

**¿El snippet de RT (ataque secundario) funciona igual que un botón?**  
Sí. Godot trata `InputEventJoypadMotion` con `axis_value: 1.0` y `deadzone: 0.5` como un evento digital: se activa cuando el gatillo supera el 50%. `is_action_just_pressed("attack_secondary")` devuelve `true` en el momento de cruzar ese umbral.

**¿Qué pasa si el jugador conecta un mando PlayStation?**  
Los índices de botones son los mismos en SDL (que Godot usa internamente). La diferencia es cosmética: el botón 0 en PS es "Cruz" en lugar de "A". Para PS cosmetics, detectar el nombre del mando con `Input.get_joy_name(0)` y cambiar las etiquetas del HUD.

**¿Necesito reiniciar el editor después de pegar el snippet?**  
No. Godot 4 recarga `project.godot` automáticamente cuando detecta cambios externos. Si el editor está abierto, puede pedir confirmación para recargar — acepta.
