## DebugManager.gd
## Autoload singleton con herramientas de depuración activas SÓLO en builds de debug.
## En builds de release (export), todas las funciones retornan inmediatamente sin efecto.
##
## Responsabilidad:
##   - Proveer accesos rápidos a acciones de debug durante el desarrollo.
##   - Saltar rondas, spawnear enemigos manualmente, imprimir estado del juego.
##   - Garantizar que NINGÚN código de debug llegue a builds de release.
##
## Uso rápido:
##   DebugManager.debug_next_wave()       # avanza a la siguiente oleada
##   DebugManager.debug_spawn_enemy("zombie")  # spawnea un enemigo
##   DebugManager.print_state()           # imprime estado actual del GameManager
##
## TODO: Agregar overlay de debug en pantalla (FPS, posición del jugador, etc.).
## TODO: Conectar con cheats del teclado (ej. Ctrl+W → siguiente oleada).

extends Node

# ---------------------------------------------------------------------------
# Estado
# ---------------------------------------------------------------------------

## Indica si el DebugManager está activo (solo en builds de debug).
var _is_debug: bool = false

# ---------------------------------------------------------------------------
# Ciclo de vida (Godot)
# ---------------------------------------------------------------------------

func _ready() -> void:
	_is_debug = OS.is_debug_build()
	if _is_debug:
		print("[DebugManager] Modo DEBUG activo. Comandos de debug disponibles.")
		_register_debug_actions()
	else:
		print("[DebugManager] Build de release. Acciones de debug desactivadas.")


## Registra shortcuts de teclado para acciones de debug.
## SÓLO se llama en builds de debug.
func _register_debug_actions() -> void:
	# TODO: Registrar InputEventKey en InputMap para shortcuts de debug.
	# Ejemplo: Ctrl+W → debug_next_wave(), Ctrl+E → debug_spawn_enemy("zombie")
	print("[DebugManager] Acciones de debug registradas (TODO: shortcuts).")


# ---------------------------------------------------------------------------
# API pública — debug
# ---------------------------------------------------------------------------

## Fuerza el avance a la siguiente oleada llamando a GameManager.end_round() + start_round().
## No hace nada en builds de release.
## Ejemplo:
##   DebugManager.debug_next_wave()
func debug_next_wave() -> void:
	if not _is_debug:
		return
	print("[DebugManager] debug_next_wave() →")
	if has_node("/root/GameManager"):
		var gm := get_node("/root/GameManager")
		if gm.is_running:
			gm.end_round()
		gm.start_round()
	else:
		push_warning("[DebugManager] GameManager no disponible.")


## Instancia un enemigo de prueba en la posición del jugador (o en el centro de la escena).
## @param enemy_type: Tipo de enemigo (ej. "zombie", "fast"). Debe coincidir con una escena en res://scenes/enemies/.
## No hace nada en builds de release.
## Ejemplo:
##   DebugManager.debug_spawn_enemy("zombie")
func debug_spawn_enemy(enemy_type: String = "zombie") -> void:
	if not _is_debug:
		return
	# TODO: Cargar la escena del enemigo e instanciarla en la escena actual.
	# path = "res://scenes/enemies/enemy_%s.tscn" % enemy_type
	# var scene = load(path)
	# get_tree().current_scene.add_child(scene.instantiate())
	print("[DebugManager] debug_spawn_enemy('%s') → TODO: implementar spawn." % enemy_type)


## Imprime en consola el estado actual de GameManager.
## No hace nada en builds de release.
## Ejemplo:
##   DebugManager.print_state()
func print_state() -> void:
	if not _is_debug:
		return
	if has_node("/root/GameManager"):
		var gm := get_node("/root/GameManager")
		print("[DebugManager] Estado GameManager → ronda: %d | corriendo: %s | puntos: %d" % [
			gm.current_round, gm.is_running, gm.puntos
		])
	else:
		print("[DebugManager] GameManager no disponible.")


## Teleporta al jugador a una posición dada (útil para testing de zonas).
## @param pos: Posición destino en coordenadas globales.
## No hace nada en builds de release.
## Ejemplo:
##   DebugManager.debug_teleport_player(Vector2(500, 300))
func debug_teleport_player(pos: Vector2) -> void:
	if not _is_debug:
		return
	# TODO: Buscar nodo Player en la escena actual y mover su global_position.
	print("[DebugManager] debug_teleport_player(%s) → TODO: implementar." % pos)
