## GameManager.gd
## Autoload singleton que coordina el estado global del juego: rondas, puntuación y ciclo de vida.
##
## Responsabilidad:
##   - Controlar el inicio y fin de rondas.
##   - Mantener la puntuación acumulada del jugador.
##   - Emitir señales para que otros sistemas reaccionen sin acoplamiento directo.
##
## Uso rápido:
##   GameManager.start_round()           # inicia la ronda actual
##   GameManager.end_round()             # termina la ronda actual
##   GameManager.add_puntos(100)         # suma 100 puntos
##   GameManager.round_started.connect(_on_ronda_iniciada)
##
## TODO: Integrar con SaveManager para persistir la puntuación máxima.
## TODO: Implementar máquina de estados completa (MENU, PLAYING, PAUSED, GAME_OVER).

extends Node

# ---------------------------------------------------------------------------
# Señales
# ---------------------------------------------------------------------------

## Emitida cuando una ronda comienza. Incluye el número de ronda.
signal round_started(round: int)

## Emitida cuando una ronda termina. Incluye el número de ronda.
signal round_ended(round: int)

## Emitida cuando cambia la puntuación. Incluye el nuevo valor.
signal score_changed(new_score: int)

# ---------------------------------------------------------------------------
# Variables de estado
# ---------------------------------------------------------------------------

## Número de ronda actual (arranca en 0, sube con start_round).
var current_round: int = 0

## Indica si el juego está en ejecución activa (entre start_round y end_round).
var is_running: bool = false

## Puntuación acumulada del jugador en la sesión actual.
var puntos: int = 0

# ---------------------------------------------------------------------------
# Ciclo de vida (Godot)
# ---------------------------------------------------------------------------

func _ready() -> void:
	# TODO: Cargar estado previo desde SaveManager si existe.
	print("[GameManager] Listo. Ronda: %d | Puntos: %d" % [current_round, puntos])


# ---------------------------------------------------------------------------
# API pública
# ---------------------------------------------------------------------------

## Inicia una nueva ronda: incrementa el contador, activa is_running y emite la señal.
## Ejemplo:
##   GameManager.start_round()
func start_round() -> void:
	if is_running:
		push_warning("[GameManager] start_round() llamado con juego ya en marcha.")
		return
	current_round += 1
	is_running = true
	print("[GameManager] Ronda %d iniciada." % current_round)
	round_started.emit(current_round)


## Termina la ronda actual, desactiva is_running y emite la señal.
## Ejemplo:
##   GameManager.end_round()
func end_round() -> void:
	if not is_running:
		push_warning("[GameManager] end_round() llamado sin ronda activa.")
		return
	is_running = false
	print("[GameManager] Ronda %d terminada." % current_round)
	round_ended.emit(current_round)


## Suma puntos al marcador y emite score_changed.
## @param cantidad: Número de puntos a sumar (debe ser > 0).
## Ejemplo:
##   GameManager.add_puntos(50)
func add_puntos(cantidad: int) -> void:
	if cantidad <= 0:
		push_warning("[GameManager] add_puntos() recibió valor <= 0: %d" % cantidad)
		return
	puntos += cantidad
	score_changed.emit(puntos)


## Reinicia el estado de ronda y puntuación para una nueva partida.
## Ejemplo:
##   GameManager.reset()
func reset() -> void:
	current_round = 0
	is_running = false
	puntos = 0
	score_changed.emit(puntos)
	print("[GameManager] Estado reiniciado.")
