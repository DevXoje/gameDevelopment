## enemy.gd
## Script de comportamiento del enemigo básico — vertical slice de persecución.
##
## Responsabilidad:
##   - Detectar al jugador dentro del rango de aggro.
##   - Moverse en línea recta hacia el jugador (pathfinding simple/directo).
##   - Detenerse cuando está suficientemente cerca (stop_distance).
##   - Emitir señal enemy_spawned en _ready() para que el Spawner pueda rastrear.
##
## Uso rápido:
##   El enemigo busca automáticamente al jugador en el grupo "player".
##   Asegúrate de que el nodo Player esté en el grupo "player".
##
## TODO: Implementar estados de IA más complejos (patrulla, ataque, huida).
## TODO: Añadir animaciones de idle / walk / attack.
## TODO: Integrar sistema de salud (recibir daño del jugador).
## TODO: Reemplazar movimiento directo con NavigationAgent2D para pathfinding real.
## TODO: Variar velocidad y aggro_range por tipo de enemigo.

extends CharacterBody2D

# ---------------------------------------------------------------------------
# Señales
# ---------------------------------------------------------------------------

## Emitida en _ready() para que el Spawner/RoundManager rastreen enemigos vivos.
signal enemy_spawned(enemy: Node)

## Emitida cuando el enemigo muere (pendiente implementación de salud).
signal enemy_died(enemy: Node)

# ---------------------------------------------------------------------------
# Parámetros exportados (editables desde el Inspector de Godot)
# ---------------------------------------------------------------------------

## Velocidad de desplazamiento en píxeles por segundo.
@export var speed: float = 80.0

## Distancia máxima a la que el enemigo detecta y persigue al jugador.
@export var aggro_range: float = 300.0

## Distancia mínima al jugador antes de detenerse (evita jitter).
@export var stop_distance: float = 16.0

# ---------------------------------------------------------------------------
# Variables internas
# ---------------------------------------------------------------------------

## Referencia cacheada al jugador (se busca en _ready via grupo "player").
var _player: Node2D = null

## Posición inicial al spawnear — útil para debug y estadísticas.
var _spawn_position: Vector2 = Vector2.ZERO

# CHANGED: safe logging accessor — referencia cacheada al Autoload Logging (null si no disponible).
var _logger = null

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------

func _ready() -> void:
	_spawn_position = global_position
	# Buscar jugador por grupo para desacoplamiento.
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0] as Node2D
	print("[Enemy] Spawneado en %s — player: %s" % [global_position, _player])

	# CHANGED: safe logging accessor — obtener Logging en runtime sin depender del identificador global.
	_logger = _get_logger()

	# Registrar evento de spawn en el log.
	if _logger:
		# CHANGED: safe logging accessor
		_logger.write_event({
			"level": "info",
			"event": "enemy_spawned",
			"data": {
				"enemy_type": get_script().resource_path.get_file(),
				"pos": str(global_position),
			},
		})

	enemy_spawned.emit(self)


func _physics_process(_delta: float) -> void:
	if _player == null:
		# Intentar encontrar al jugador nuevamente si aún no está disponible.
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			_player = players[0] as Node2D
		return

	_chase_player()


# ---------------------------------------------------------------------------
# IA de persecución
# ---------------------------------------------------------------------------

## Lógica principal de persecución: mueve al enemigo hacia el jugador
## si está dentro del aggro_range y lejos del stop_distance.
func _chase_player() -> void:
	var dist: float = global_position.distance_to(_player.global_position)

	if dist > aggro_range:
		# Fuera de rango: detenerse.
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if dist <= stop_distance:
		# Muy cerca: detenerse para evitar superposición / jitter.
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Dentro del rango: moverse en línea recta hacia el jugador.
	var direction: Vector2 = (_player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()


# ---------------------------------------------------------------------------
# API pública
# ---------------------------------------------------------------------------

## Retorna la distancia actual al jugador. -1 si no hay jugador referenciado.
func get_distance_to_player() -> float:
	if _player == null:
		return -1.0
	return global_position.distance_to(_player.global_position)


## Retorna true si el enemigo está persiguiendo activamente al jugador.
func is_chasing() -> bool:
	if _player == null:
		return false
	var dist := get_distance_to_player()
	return dist > stop_distance and dist <= aggro_range


## Mata al enemigo: emite enemy_died, registra el evento y elimina el nodo.
## @param killer: Identificador del causante ("player", "trap", "other", etc.).
func die(killer: String = "other") -> void:
	# Registrar evento de muerte en el log.
	var logger := _get_logger()
	if logger:
		# CHANGED: safe logging accessor
		logger.write_event({
			"level": "info",
			"event": "enemy_died",
			"data": {
				"enemy_type": get_script().resource_path.get_file(),
				"pos": str(global_position),
				"killer": killer,
			},
		})
	enemy_died.emit(self)
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
