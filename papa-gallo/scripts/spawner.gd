## spawner.gd
## Spawner de enemigos — instancia oleadas de enemigos en puntos de spawn predefinidos.
##
## Responsabilidad:
##   - Mantener una lista de puntos de spawn (por defecto 4 esquinas alrededor del jugador).
##   - Instanciar enemigos según la PackedScene exportada.
##   - Distribuir enemigos en los puntos de spawn con round-robin.
##   - Mantener registro de enemigos activos.
##
## Decisión de diseño — Puntos de spawn:
##   Se eligieron 4 puntos por defecto en las esquinas de la pantalla relativas al jugador
##   (offsets ±400 en X, ±300 en Y), ya que el nivel es 1280×720 y los bordes están
##   fuera del campo de visión del jugador. Esto garantiza que los enemigos no aparecen
##   encima del jugador.
##   Si se desea personalizar, sobrescribir spawn_points antes de llamar spawn_wave().
##
## Uso rápido:
##   spawner.enemy_scene = preload("res://scenes/enemies/Enemy.tscn")
##   spawner.spawn_wave(3)
##
## TODO: Añadir spawn con animación de aparición (flash, fade-in).
## TODO: Soportar múltiples tipos de enemigos con pesos/probabilidades.
## TODO: Emitir señal cuando todos los enemigos de la oleada mueren (oleada completada).
## TODO: Integrar con NavigationRegion2D para spawn sólo en zonas navegables.

extends Node2D

# ---------------------------------------------------------------------------
# Señales
# ---------------------------------------------------------------------------

## Emitida al iniciar una oleada. Incluye la cantidad de enemigos spawneados.
signal wave_started(count: int)

## Emitida cuando un enemigo de esta oleada es eliminado.
signal enemy_removed(enemy: Node)

# ---------------------------------------------------------------------------
# Parámetros exportados
# ---------------------------------------------------------------------------

## Escena del enemigo a instanciar. Debe ser una PackedScene con script enemy.gd.
@export var enemy_scene: PackedScene

## Nodo padre donde se añadirán los enemigos (null = escena principal).
## Si es null, se usa get_tree().current_scene.
@export var enemies_parent: NodePath = NodePath("")

# ---------------------------------------------------------------------------
# Puntos de spawn
# ---------------------------------------------------------------------------

## Offsets relativos al centro del mundo (0,0) para los 4 puntos de spawn por defecto.
## Diseñados para aparecer fuera del campo visual del jugador en pantalla 1280×720.
## DECISIÓN: 4 esquinas a ±400 en X y ±300 en Y desde el origen de la escena.
## TODO: Reemplazar con nodos Marker2D reales en Main.tscn para mayor flexibilidad.
const DEFAULT_SPAWN_OFFSETS: Array[Vector2] = [
	Vector2(-400, -300),  # Esquina superior izquierda
	Vector2( 400, -300),  # Esquina superior derecha
	Vector2(-400,  300),  # Esquina inferior izquierda
	Vector2( 400,  300),  # Esquina inferior derecha
]

## Puntos de spawn efectivos. Si está vacío se generan los 4 por defecto.
var spawn_points: Array[Vector2] = []

# ---------------------------------------------------------------------------
# Variables internas
# ---------------------------------------------------------------------------

## Lista de enemigos activos spawnados por este Spawner.
var _active_enemies: Array[Node] = []

## Índice para round-robin de puntos de spawn.
var _spawn_index: int = 0

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------

func _ready() -> void:
	if spawn_points.is_empty():
		_init_default_spawn_points()
	print("[Spawner] Listo con %d puntos de spawn." % spawn_points.size())


# ---------------------------------------------------------------------------
# API pública
# ---------------------------------------------------------------------------

## Instancia 'count' enemigos en los puntos de spawn (round-robin).
## Requiere que enemy_scene esté asignado.
## @param count: Número de enemigos a spawnear.
func spawn_wave(count: int) -> void:
	if enemy_scene == null:
		push_error("[Spawner] spawn_wave() llamado sin enemy_scene asignado.")
		return
	if spawn_points.is_empty():
		push_error("[Spawner] spawn_wave() sin puntos de spawn.")
		return

	print("[Spawner] Spawneando oleada de %d enemigos..." % count)

	var parent: Node = _get_enemies_parent()

	for i in range(count):
		var spawn_pos: Vector2 = spawn_points[_spawn_index % spawn_points.size()]
		_spawn_index += 1

		var enemy: CharacterBody2D = enemy_scene.instantiate() as CharacterBody2D
		if enemy == null:
			push_error("[Spawner] enemy_scene no instanció un CharacterBody2D.")
			continue

		enemy.global_position = spawn_pos
		parent.add_child(enemy)
		_active_enemies.append(enemy)

		# Conectar limpieza automática al eliminar el nodo.
		enemy.tree_exited.connect(_on_enemy_removed.bind(enemy))

		print("[Spawner]   Enemigo %d spawneado en %s" % [i + 1, spawn_pos])

	wave_started.emit(count)
	print("[Spawner] Oleada de %d completada. Enemigos activos: %d" % [count, _active_enemies.size()])


## Retorna la cantidad de enemigos activos actualmente.
func get_active_count() -> int:
	return _active_enemies.size()


## Elimina todos los enemigos activos de la escena (útil para reinicio de ronda).
func clear_enemies() -> void:
	for enemy in _active_enemies.duplicate():
		if is_instance_valid(enemy):
			enemy.queue_free()
	_active_enemies.clear()
	print("[Spawner] Todos los enemigos eliminados.")


# ---------------------------------------------------------------------------
# Privado
# ---------------------------------------------------------------------------

## Inicializa los 4 puntos de spawn por defecto en las esquinas de la pantalla.
func _init_default_spawn_points() -> void:
	spawn_points.clear()
	for offset in DEFAULT_SPAWN_OFFSETS:
		spawn_points.append(global_position + offset)
	print("[Spawner] Puntos de spawn por defecto inicializados: %d puntos" % spawn_points.size())


## Retorna el nodo padre donde se añadirán los enemigos.
func _get_enemies_parent() -> Node:
	if enemies_parent != NodePath(""):
		var parent_node := get_node_or_null(enemies_parent)
		if parent_node != null:
			return parent_node
	# Fallback 1: usar la escena actual si está disponible.
	var current := get_tree().current_scene
	if current != null:
		return current
	# Fallback 2: usar el nodo raíz del árbol de la escena.
	return get_tree().root


## Callback cuando un enemigo sale del árbol de la escena.
func _on_enemy_removed(enemy: Node) -> void:
	_active_enemies.erase(enemy)
	enemy_removed.emit(enemy)
	print("[Spawner] Enemigo eliminado. Activos restantes: %d" % _active_enemies.size())
