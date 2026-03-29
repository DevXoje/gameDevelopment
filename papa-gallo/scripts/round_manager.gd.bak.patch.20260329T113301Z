## round_manager.gd
## Gestor de rondas — controla el ciclo de oleadas de enemigos y la dificultad escalada.
##
## Responsabilidad:
##   - Llevar el contador de ronda actual.
##   - Calcular cuántos enemigos spawnear según la ronda (base + escala).
##   - Llamar al Spawner para iniciar oleadas.
##   - Coordinarse con GameManager para sincronizar el estado global.
##   - Emitir señales para que el HUD y otros sistemas reaccionen.
##
## Fórmula de dificultad (simple):
##   enemies_count = base_count + (current_round - 1) * growth_per_round
##   Ejemplo: ronda 1→3, ronda 2→4, ronda 3→5, etc.
##
## Uso rápido:
##   round_manager.start_round()   # inicia la siguiente ronda
##   round_manager.stop_round()    # detiene la ronda activa
##
## TODO: Implementar condición de "fin de oleada" cuando todos los enemigos mueren.
## TODO: Añadir cooldown entre oleadas (pausa antes del siguiente spawn).
## TODO: Soportar múltiples tipos de enemigos con rondas de "jefes".
## TODO: Integrar con SaveManager para persistir el progreso de rondas.
## TODO: Conectar señal round_completed al GameManager para sumar puntos.

extends Node

# ---------------------------------------------------------------------------
# Señales
# ---------------------------------------------------------------------------

## Emitida al iniciar una ronda. Incluye el número de ronda y enemigos spawneados.
signal round_started(round_number: int, enemy_count: int)

## Emitida al detener la ronda activa.
signal round_stopped(round_number: int)

## Emitida cuando todos los enemigos de la oleada han muerto.
## TODO: Implementar en versión futura cuando el Spawner rastree muertes.
signal round_completed(round_number: int)

# ---------------------------------------------------------------------------
# Parámetros exportados
# ---------------------------------------------------------------------------

## Número de enemigos base en la primera ronda.
@export var base_count: int = 3

## Enemigos adicionales por ronda (escala lineal).
@export var growth_per_round: int = 1

## Referencia al Spawner hijo o sibling (asignar en el inspector).
@export var spawner_path: NodePath = NodePath("../Spawner")

# ---------------------------------------------------------------------------
# Estado
# ---------------------------------------------------------------------------

## Número de ronda actual (0 = sin iniciar).
var current_round: int = 0

## Indica si hay una ronda activa en este momento.
var is_round_active: bool = false

# ---------------------------------------------------------------------------
# Variables internas
# ---------------------------------------------------------------------------

var _spawner: Node = null
var _round_start_time: float = 0.0
# CHANGED: safe logging accessor — referencia cacheada al Autoload Logging (null si no disponible).
var _logger = null

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------

func _ready() -> void:
	_spawner = get_node_or_null(spawner_path)
	if _spawner == null:
		push_warning("[RoundManager] Spawner no encontrado en '%s'. Asignar spawner_path en el Inspector." % spawner_path)
	# CHANGED: safe logging accessor — cachear referencia al Autoload Logging en _ready.
	_logger = _get_logger()
	print("[RoundManager] Listo. base_count=%d growth=%d" % [base_count, growth_per_round])


func _unhandled_input(event: InputEvent) -> void:
	# Tecla de debug F5 para avanzar a la siguiente ronda en el editor / builds de debug.
	if event.is_action_pressed("debug_next_wave"):
		print("[RoundManager] [DEBUG] Tecla debug_next_wave detectada — iniciando siguiente ronda.")
		start_round()


# ---------------------------------------------------------------------------
# API pública
# ---------------------------------------------------------------------------

## Inicia la siguiente ronda. Incrementa current_round, calcula enemigos y llama al Spawner.
## Si ya hay una ronda activa, emite un warning y no hace nada.
func start_round() -> void:
	if is_round_active:
		push_warning("[RoundManager] start_round() llamado con ronda ya activa (ronda %d)." % current_round)
		return

	current_round += 1
	is_round_active = true
	_round_start_time = Time.get_unix_time_from_system()

	var enemy_count: int = _calculate_enemy_count()
	print("[RoundManager] ▶ Iniciando ronda %d con %d enemigos." % [current_round, enemy_count])

	# Registrar evento de inicio de ronda.
	if has_node("/root/Logging"):
		# CHANGED: safe logging accessor
		var logger := _get_logger()
		if logger:
			logger.write_event({
				"level": "info",
				"event": "round_started",
				"data": {
					"round": current_round,
					"spawn_count": enemy_count,
				},
			})

	# Sincronizar con GameManager si está disponible.
	if Engine.has_singleton("GameManager") or has_node("/root/GameManager"):
		var gm := get_node_or_null("/root/GameManager")
		if gm and not gm.is_running:
			gm.start_round()

	# Disparar oleada en el Spawner.
	if _spawner != null and _spawner.has_method("spawn_wave"):
		_spawner.spawn_wave(enemy_count)
	else:
		push_warning("[RoundManager] Spawner no disponible — no se spawnearon enemigos.")

	round_started.emit(current_round, enemy_count)


## Detiene la ronda activa sin limpiar los enemigos.
## Útil para pausar el juego o en secuencias de cutscene.
func stop_round() -> void:
	if not is_round_active:
		push_warning("[RoundManager] stop_round() llamado sin ronda activa.")
		return

	var duration: float = Time.get_unix_time_from_system() - _round_start_time
	is_round_active = false
	print("[RoundManager] ⏸ Ronda %d detenida." % current_round)

	# Registrar evento de fin de ronda.
	if has_node("/root/Logging"):
		# CHANGED: safe logging accessor
		var logger := _get_logger()
		if logger:
			logger.write_event({
				"level": "info",
				"event": "round_ended",
				"data": {
					"round": current_round,
					"duration_s": snappedf(duration, 0.01),
					"enemies_remaining": _spawner.get_active_count() if (_spawner != null and _spawner.has_method("get_active_count")) else -1,
				},
			})

	round_stopped.emit(current_round)


## Reinicia el estado completo (ronda 0, sin activos).
func reset() -> void:
	current_round = 0
	is_round_active = false
	if _spawner != null and _spawner.has_method("clear_enemies"):
		_spawner.clear_enemies()
	print("[RoundManager] Estado reiniciado.")


## Retorna el número de enemigos para la ronda dada (o la actual si round == 0).
func get_enemy_count_for_round(round_number: int = 0) -> int:
	if round_number == 0:
		round_number = current_round
	return base_count + max(0, round_number - 1) * growth_per_round


# ---------------------------------------------------------------------------
# Privado
# ---------------------------------------------------------------------------

## Calcula los enemigos para la ronda actual.
func _calculate_enemy_count() -> int:
	return base_count + (current_round - 1) * growth_per_round


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
