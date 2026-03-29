## player.gd
## Script principal del jugador — vertical slice mínimo de movimiento.
##
## Responsabilidad:
##   - Leer input del Input Map (move_up/down/left/right, sprint).
##   - Mover el CharacterBody2D usando move_and_slide() (Godot 4).
##   - Sprint multiplicando la velocidad base al mantener la acción "sprint" (Shift / Botón B gamepad).
##   - Voltear el Sprite2D según la dirección horizontal.
##   - Cambiar el modulate del Sprite2D para indicar sprint visualmente (tint claro).
##   - Emitir señal player_died y registrar evento en Logging.
##
## TODO: Implementar sistema de stamina que consuma energía durante el sprint.
## TODO: Integrar con AnimationPlayer para animaciones de idle/walk/run.
## TODO: Conectar señales al GameManager (ej. jugador_muerto, jugador_dañado).
## TODO: Añadir knockback y lógica de daño cuando se integre combate.

extends CharacterBody2D

# ---------------------------------------------------------------------------
# Señales
# ---------------------------------------------------------------------------

## Emitida cuando el jugador muere.
signal player_died

# ---------------------------------------------------------------------------
# Parámetros exportados (editables desde el Inspector de Godot)
# ---------------------------------------------------------------------------

## Velocidad base de movimiento en píxeles por segundo.
@export var speed: float = 160.0

## Multiplicador de velocidad al hacer sprint (sin stamina aún).
@export var sprint_multiplier: float = 1.7

# ---------------------------------------------------------------------------
# Nodos hijos (tipados para autocompletado)
# ---------------------------------------------------------------------------

## Referencia al Sprite2D hijo para animaciones placeholder.
@onready var sprite: Sprite2D = $Sprite2D

# CHANGED: safe logging accessor — referencia cacheada al Autoload Logging (null si no disponible).
var _logger = null

## Color normal del sprite.
const COLOR_NORMAL := Color(1.0, 1.0, 1.0, 1.0)

## Color cuando está sprintando (más claro / amarillo tenue).
const COLOR_SPRINT := Color(1.2, 1.1, 0.8, 1.0)

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------

func _ready() -> void:
	print("[Player] Listo en posición: %s" % global_position)

	# CHANGED: safe logging accessor — cachear referencia al Autoload Logging en _ready.
	_logger = _get_logger()

	# Registrar evento de inicio del jugador en el log.
	if _logger:
		# CHANGED: safe logging accessor
		_logger.write_event({
			"level": "info",
			"event": "player_started",
			"session_id": _logger.get_session_id(),
			"data": {
				"position": str(global_position),
			},
		})


func _physics_process(_delta: float) -> void:
	_handle_movement()


# ---------------------------------------------------------------------------
# Movimiento
# ---------------------------------------------------------------------------

## Lee el input direccional, aplica velocidad (con sprint) y mueve el cuerpo.
func _handle_movement() -> void:
	# Leer el vector 2D de input normalizado usando las acciones del Input Map.
	# Orden: move_left, move_right, move_up, move_down (eje X y Y respectivamente).
	var input_dir: Vector2 = Input.get_vector(
		"move_left", "move_right",
		"move_up", "move_down"
	)

	# Determinar si el jugador está sprintando.
	var is_sprinting: bool = Input.is_action_pressed("sprint")

	# Calcular velocidad efectiva.
	var effective_speed: float = speed
	if is_sprinting:
		effective_speed *= sprint_multiplier

	# Asignar velocidad al CharacterBody2D.
	velocity = input_dir * effective_speed

	# Mover el cuerpo y resolver colisiones (Godot 4 API).
	move_and_slide()

	# Actualizar el flip del sprite según la dirección horizontal.
	_update_sprite(input_dir, is_sprinting)


# ---------------------------------------------------------------------------
# Animación placeholder
# ---------------------------------------------------------------------------

## Voltea el Sprite2D según la dirección X.
## Cambia el modulate para indicar sprint visualmente.
func _update_sprite(input_dir: Vector2, is_sprinting: bool) -> void:
	if not sprite:
		return

	# Voltear sprite según la dirección horizontal (sólo si nos estamos moviendo en X).
	if input_dir.x < 0:
		sprite.flip_h = true
	elif input_dir.x > 0:
		sprite.flip_h = false

	# Tint de sprint: más claro cuando está sprintando, normal en caso contrario.
	sprite.modulate = COLOR_SPRINT if is_sprinting else COLOR_NORMAL


# ---------------------------------------------------------------------------
# Muerte del jugador
# ---------------------------------------------------------------------------

## Llama a este método cuando el jugador muere (daño letal, trampa, etc.).
## Registra el evento en Logging y emite la señal player_died.
func die() -> void:
	# Registrar evento de muerte en el log.
	var logger := _get_logger()
	if logger:
		# CHANGED: safe logging accessor
		logger.write_event({
			"level": "info",
			"event": "player_death",
			"data": {
				"position": str(global_position),
			},
		})
	print("[Player] ☠ Muerte del jugador en %s" % global_position)
	player_died.emit()
	# TODO: reproducir animación de muerte, mostrar Game Over, etc.
	queue_free()


# ---------------------------------------------------------------------------
# Helpers privados
# ---------------------------------------------------------------------------

## Retorna la instancia del Autoload Logging de forma segura en runtime.
## Usa la referencia cacheada _logger si está disponible; si no, intenta obtenerla.
## CHANGED: safe logging accessor
func _get_logger() -> Object:
	if _logger != null:
		return _logger
	if has_node("/root/Logging"):
		return get_node("/root/Logging")
	return null
