## InputManager.gd
## Autoload singleton que abstrae el acceso al sistema de input de Godot.
## Ofrece wrappers de Input, soporte para rebinding de acciones y persistencia de bindings.
##
## Responsabilidad:
##   - Centralizar la consulta de acciones de input (teclado y gamepad).
##   - Proveer rebinding de acciones en tiempo de ejecución.
##   - Guardar y cargar los bindings personalizados desde disco (user://).
##
## Uso rápido:
##   if InputManager.is_action_pressed("attack_primary"): atacar()
##   InputManager.rebind_action("move_up", nuevo_evento)
##   InputManager.input_rebound.connect(_on_input_rebound)
##
## TODO: Implementar UI de remapping para el MVP 2.
## TODO: Detectar si hay gamepad conectado y actualizar iconos en HUD.

extends Node

# ---------------------------------------------------------------------------
# Señales
# ---------------------------------------------------------------------------

## Emitida cuando se reasigna un binding. Incluye el nombre de la acción.
signal input_rebound(action: String)

# ---------------------------------------------------------------------------
# Constantes
# ---------------------------------------------------------------------------

## Ruta del archivo de configuración de bindings en disco.
const BINDINGS_PATH: String = "user://input_bindings.cfg"

# ---------------------------------------------------------------------------
# Ciclo de vida (Godot)
# ---------------------------------------------------------------------------

func _ready() -> void:
	load_bindings()
	print("[InputManager] Listo. Bindings cargados desde: %s" % BINDINGS_PATH)


# ---------------------------------------------------------------------------
# API pública — consulta de input
# ---------------------------------------------------------------------------

## Wrapper de Input.is_action_pressed(). Devuelve true si la acción está presionada.
## @param action: Nombre de la acción del Input Map (ej. "attack_primary").
## Ejemplo:
##   if InputManager.is_action_pressed("sprint"): aplicar_sprint()
func is_action_pressed(action: String) -> bool:
	return Input.is_action_pressed(action)


## Wrapper de Input.is_action_just_pressed(). Devuelve true solo en el primer frame.
## @param action: Nombre de la acción del Input Map.
## Ejemplo:
##   if InputManager.is_action_just_pressed("interact"): interactuar()
func is_action_just_pressed(action: String) -> bool:
	return Input.is_action_just_pressed(action)


## Wrapper de Input.is_action_just_released(). Devuelve true al soltar la acción.
## @param action: Nombre de la acción del Input Map.
func is_action_just_released(action: String) -> bool:
	return Input.is_action_just_released(action)


# ---------------------------------------------------------------------------
# API pública — rebinding
# ---------------------------------------------------------------------------

## Reasigna el primer evento de una acción. Emite input_rebound al completar.
## @param action: Nombre de la acción a modificar.
## @param new_event: Nuevo InputEvent a asignar (InputEventKey, InputEventJoypadButton, etc.).
## Ejemplo:
##   var ev = InputEventKey.new()
##   ev.physical_keycode = KEY_SPACE
##   InputManager.rebind_action("attack_primary", ev)
func rebind_action(action: String, new_event: InputEvent) -> void:
	if not InputMap.has_action(action):
		push_error("[InputManager] Acción no encontrada en Input Map: %s" % action)
		return
	# Eliminar eventos existentes y agregar el nuevo
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, new_event)
	print("[InputManager] Acción '%s' reasignada." % action)
	input_rebound.emit(action)
	save_bindings()


# ---------------------------------------------------------------------------
# API pública — persistencia
# ---------------------------------------------------------------------------

## Carga los bindings personalizados desde user://input_bindings.cfg.
## Si no existe el archivo, se usan los bindings por defecto del Input Map.
## Ejemplo:
##   InputManager.load_bindings()
func load_bindings() -> void:
	var config := ConfigFile.new()
	var err := config.load(BINDINGS_PATH)
	if err != OK:
		# Archivo no existe aún — usar defaults del Input Map
		print("[InputManager] No hay bindings guardados. Usando defaults.")
		return
	# TODO: Iterar sobre secciones/claves del ConfigFile y reconstruir InputEvents.
	# Implementación completa pendiente (MVP 2).
	print("[InputManager] Bindings cargados.")


## Guarda los bindings actuales en user://input_bindings.cfg.
## Ejemplo:
##   InputManager.save_bindings()
func save_bindings() -> void:
	var config := ConfigFile.new()
	# TODO: Serializar todos los InputEvents del InputMap a config.
	# Implementación completa pendiente (MVP 2).
	var err := config.save(BINDINGS_PATH)
	if err != OK:
		push_error("[InputManager] No se pudieron guardar los bindings: %s" % err)
	else:
		print("[InputManager] Bindings guardados en: %s" % BINDINGS_PATH)
