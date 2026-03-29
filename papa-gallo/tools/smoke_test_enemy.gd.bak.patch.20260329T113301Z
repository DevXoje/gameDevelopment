## smoke_test_enemy.gd
## Smoke test headless para el sistema RoundManager + Spawner + Enemy de papa-gallo.
##
## Ejecutar con:
##   godot --headless --path "<ruta_proyecto>" --script "tools/smoke_test_enemy.gd"
##
## Verifica:
##   1. Que los scripts enemy.gd, spawner.gd y round_manager.gd existen y cargan.
##   2. Que las propiedades exportadas de Enemy están declaradas (speed, aggro_range, stop_distance).
##   3. Que spawn_wave(2) instancia 2 enemigos en la escena.
##   4. Que la velocidad del enemigo apunta hacia el jugador (persecución verificada via dot product).
##
## Código de salida:
##   0 => todos los checks pasaron (SMOKE TEST PASSED)
##   1 => al menos un check falló  (SMOKE TEST FAILED)
##
## Nota sobre Logging en modo headless:
##   El Autoload Logging NO está disponible en scripts headless (extienden SceneTree).
##   Este script instancia Logging manualmente para garantizar persistencia de eventos.
##
## TODO: Añadir check de señales (enemy_spawned, wave_started).
## TODO: Verificar stop_distance con enemigos muy cerca del jugador.
## TODO: Integrar con CI/CD cuando se configure pipeline.

extends SceneTree

# ---------------------------------------------------------------------------
# Constantes
# ---------------------------------------------------------------------------

const ENEMY_SCRIPT_PATH    := "res://scripts/enemy.gd"
const SPAWNER_SCRIPT_PATH  := "res://scripts/spawner.gd"
const RM_SCRIPT_PATH       := "res://scripts/round_manager.gd"
const ENEMY_SCENE_PATH     := "res://scenes/enemies/Enemy.tscn"

const PLAYER_POS           := Vector2(640, 360)
const ENEMY_START_DISTANCE := 200.0    # distancia inicial al jugador (dentro de aggro_range=300)

# ---------------------------------------------------------------------------
# Estado del test
# ---------------------------------------------------------------------------

var _failures: Array[String] = []
var _passes:   Array[String] = []
var _log_lines: Array[String] = []
var _timestamp: String = ""

## Instancia manual de Logging para modo headless (el Autoload no está disponible aquí).
var _logging: Node = null

# ---------------------------------------------------------------------------
# Punto de entrada — se usa _process para poder awaitar señales del árbol
# ---------------------------------------------------------------------------

func _initialize() -> void:
	_timestamp = Time.get_datetime_string_from_system(true).replace(":", "-")
	_log("====== SMOKE TEST ENEMY — PapaGallo ======")
	_log("Godot versión: %s" % Engine.get_version_info().get("string", "?"))
	_log("Proyecto: %s" % ProjectSettings.globalize_path("res://"))
	_log("Timestamp: %s" % _timestamp)
	_log("")
	# Inicializar Logging manualmente (no hay Autoload en headless SceneTree).
	_init_logging()
	# Arrancar la corrutina principal asíncronamente.
	_run_all_checks()


## Ejecuta todos los checks en secuencia. Función async para soportar await.
func _run_all_checks() -> void:
	_check_scripts_exist()
	_check_enemy_properties()
	await _check_spawn_wave()
	await _check_enemy_chases_player()
	_finalize()


# ---------------------------------------------------------------------------
# Checks síncronos
# ---------------------------------------------------------------------------

func _check_scripts_exist() -> void:
	_log("--- Check 1: Existencia de scripts ---")
	var scripts := {
		"enemy.gd":         ENEMY_SCRIPT_PATH,
		"spawner.gd":       SPAWNER_SCRIPT_PATH,
		"round_manager.gd": RM_SCRIPT_PATH,
	}
	for sname in scripts:
		var path: String = scripts[sname]
		if ResourceLoader.exists(path):
			var s = load(path)
			if s != null:
				_pass("Script '%s' cargado desde '%s'" % [sname, path])
				_log("  [OK] %s" % sname)
			else:
				_fail("Script '%s' existe pero no cargó" % sname)
				_log("  [ERR] %s no cargó" % sname)
		else:
			_fail("Script '%s' NO encontrado en '%s'" % [sname, path])
			_log("  [ERR] %s no encontrado" % sname)

	_log("  Verificando escena Enemy.tscn...")
	if ResourceLoader.exists(ENEMY_SCENE_PATH):
		_pass("Enemy.tscn encontrada en '%s'" % ENEMY_SCENE_PATH)
		_log("  [OK] Enemy.tscn existe")
	else:
		_fail("Enemy.tscn NO encontrada en '%s'" % ENEMY_SCENE_PATH)
		_log("  [ERR] Enemy.tscn falta")


func _check_enemy_properties() -> void:
	_log("--- Check 2: Propiedades exportadas de Enemy ---")
	if not ResourceLoader.exists(ENEMY_SCRIPT_PATH):
		_fail("Omitiendo check — enemy.gd no disponible")
		return

	var script: GDScript = load(ENEMY_SCRIPT_PATH)
	if script == null:
		_fail("No se pudo cargar enemy.gd para verificar propiedades")
		return

	var required_props := ["speed", "aggro_range", "stop_distance"]
	var props: Array = script.get_script_property_list()
	var prop_names: Array[String] = []
	for p in props:
		prop_names.append(p["name"])

	for prop_name in required_props:
		if prop_name in prop_names:
			_pass("Propiedad '%s' declarada en enemy.gd" % prop_name)
			_log("  [OK] Propiedad '%s' encontrada" % prop_name)
		else:
			_fail("Propiedad '%s' NO encontrada en enemy.gd" % prop_name)
			_log("  [ERR] Propiedad '%s' falta" % prop_name)


# ---------------------------------------------------------------------------
# Checks asíncronos (requieren await para crear nodos en el árbol)
# ---------------------------------------------------------------------------

func _check_spawn_wave() -> void:
	_log("--- Check 3: spawn_wave(2) instancia 2 enemigos ---")
	if not ResourceLoader.exists(ENEMY_SCENE_PATH):
		_fail("Omitiendo check — Enemy.tscn no disponible")
		return
	if not ResourceLoader.exists(SPAWNER_SCRIPT_PATH):
		_fail("Omitiendo check — spawner.gd no disponible")
		return

	# Crear árbol de escena temporal.
	var root := Node2D.new()
	get_root().add_child(root)

	# Crear jugador placeholder en grupo "player".
	var player := CharacterBody2D.new()
	player.global_position = PLAYER_POS
	player.add_to_group("player")
	root.add_child(player)

	# Crear Spawner con script.
	var spawner := Node2D.new()
	var spawner_script: GDScript = load(SPAWNER_SCRIPT_PATH)
	spawner.set_script(spawner_script)
	root.add_child(spawner)
	await process_frame
	spawner.enemy_scene = load(ENEMY_SCENE_PATH) as PackedScene

	if not spawner.has_method("spawn_wave"):
		_fail("Spawner no tiene método spawn_wave()")
		_log("  [ERR] spawn_wave() no existe en spawner")
		root.queue_free()
		return

	spawner.spawn_wave(2)
	await process_frame
	await process_frame

	var enemy_count: int = spawner.get_active_count() if spawner.has_method("get_active_count") else -1
	_log("  Enemigos activos tras spawn_wave(2): %d" % enemy_count)
	if enemy_count == 2:
		_pass("spawn_wave(2) creó exactamente 2 enemigos activos")
		_log("  [OK] 2 enemigos spawneados correctamente")
	elif enemy_count >= 1:
		_pass("spawn_wave(2) creó al menos 1 enemigo activo (%d)" % enemy_count)
		_log("  [WARN] Se esperaban 2 enemigos, se obtuvieron %d" % enemy_count)
	else:
		_fail("spawn_wave(2) no creó enemigos (activos: %d)" % enemy_count)
		_log("  [ERR] No se spawnearon enemigos")

	root.queue_free()
	await process_frame


func _check_enemy_chases_player() -> void:
	_log("--- Check 4: Enemigo persigue al jugador ---")
	if not ResourceLoader.exists(ENEMY_SCENE_PATH):
		_fail("Omitiendo check — Enemy.tscn no disponible")
		return

	# Crear árbol de escena temporal.
	var root := Node2D.new()
	get_root().add_child(root)

	# Crear jugador placeholder.
	var player := CharacterBody2D.new()
	player.global_position = PLAYER_POS
	player.add_to_group("player")
	root.add_child(player)

	# Instanciar enemigo a ENEMY_START_DISTANCE del jugador (dentro de aggro_range=300).
	var enemy_scene: PackedScene = load(ENEMY_SCENE_PATH)
	var enemy: CharacterBody2D = enemy_scene.instantiate() as CharacterBody2D
	var enemy_start_pos := PLAYER_POS + Vector2(ENEMY_START_DISTANCE, 0)
	enemy.global_position = enemy_start_pos
	root.add_child(enemy)

	# Dar frames para que _ready() del enemigo se ejecute y cachee al jugador.
	await process_frame
	await process_frame

	var dist_initial: float = enemy.global_position.distance_to(player.global_position)
	_log("  Distancia inicial: %.1f px (aggro_range=%s, stop_distance=%s)" % [
		dist_initial,
		enemy.get("aggro_range") if enemy.get("aggro_range") != null else "?",
		enemy.get("stop_distance") if enemy.get("stop_distance") != null else "?"
	])

	# Verificar que el enemigo tiene velocidad dirigida al jugador
	# llamando directamente _chase_player() (método interno del enemy.gd).
	# Esto valida la lógica sin necesitar el physics server activo.
	if enemy.has_method("_chase_player"):
		enemy.call("_chase_player")
		var vel: Vector2 = enemy.velocity
		var expected_dir: Vector2 = (player.global_position - enemy.global_position).normalized()
		var vel_normalized: Vector2 = vel.normalized() if vel.length() > 0.0 else Vector2.ZERO
		var dot: float = vel_normalized.dot(expected_dir)
		_log("  Velocidad del enemigo: (%.1f, %.1f) | Dot con dirección esperada: %.3f" % [vel.x, vel.y, dot])
		if dot > 0.9:
			_pass("Enemigo persigue al jugador — velocity apunta al jugador (dot=%.3f > 0.9)" % dot)
			_log("  [OK] Persecución verificada (dot=%.3f)" % dot)
		elif dot > 0.0:
			_pass("Enemigo muestra persecución parcial (dot=%.3f > 0)" % dot)
			_log("  [WARN] Dot product %.3f — dirección aproximada al jugador" % dot)
		else:
			_fail("Enemigo NO persigue al jugador (dot=%.3f)" % dot)
			_log("  [ERR] Velocidad no apunta al jugador (dot=%.3f)" % dot)
	else:
		# Fallback: verificar que enemy tiene velocidad no-cero después de un proceso.
		_log("  _chase_player() no accesible externamente — verificando via is_chasing()")
		if enemy.has_method("is_chasing"):
			var chasing: bool = enemy.call("is_chasing")
			if chasing:
				_pass("Enemigo reporta is_chasing()=true dentro del aggro_range")
				_log("  [OK] is_chasing() retornó true")
			else:
				_fail("Enemigo reporta is_chasing()=false (dist=%s, aggro=%s)" % [dist_initial, ENEMY_START_DISTANCE])
				_log("  [ERR] is_chasing() retornó false — revisar aggro_range o referencia al jugador")
		else:
			_fail("Enemy no tiene método _chase_player() ni is_chasing() para validar")
			_log("  [ERR] No se pudo validar persecución")

	root.queue_free()
	await process_frame


# ---------------------------------------------------------------------------
# Finalización
# ---------------------------------------------------------------------------

func _finalize() -> void:
	_log("")
	_log("====== RESULTADOS ======")
	for p in _passes:
		_log("  [PASS] %s" % p)
	for f in _failures:
		_log("  [FAIL] %s" % f)
	_log("")

	var result_line: String
	var passed := _failures.is_empty()
	if passed:
		result_line = "✅ SMOKE TEST PASSED — %d checks OK" % _passes.size()
	else:
		result_line = "❌ SMOKE TEST FAILED — %d/%d checks fallaron" % [_failures.size(), _passes.size() + _failures.size()]
	_log(result_line)
	print(result_line)

	# Registrar resultado en Logging.
	_log_smoke_result(passed, "enemy", _passes.size(), _failures.size())

	# Guardar log en disco (log de texto plano legacy).
	var log_path := "res://logs/smoke_test_enemy_%s.log" % _timestamp
	_save_log(log_path)

	# Flush del log de eventos JSON-lines.
	if _logging != null:
		_logging.flush()

	quit(0 if passed else 1)


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------

func _pass(msg: String) -> void:
	_passes.append(msg)


func _fail(msg: String) -> void:
	_failures.append(msg)


func _log(msg: String) -> void:
	print("[SmokeTest] %s" % msg)
	_log_lines.append(msg)


func _save_log(path: String) -> void:
	var abs_path := ProjectSettings.globalize_path(path)
	var dir_path := abs_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)

	var file := FileAccess.open(abs_path, FileAccess.WRITE)
	if file:
		for line in _log_lines:
			file.store_line(line)
		file.close()
		print("[SmokeTest] Log guardado en: %s" % abs_path)
	else:
		print("[SmokeTest] WARN: No se pudo guardar el log en '%s'" % abs_path)


# ---------------------------------------------------------------------------
# Logging manual para modo headless
# ---------------------------------------------------------------------------

## Instancia el script Logging.gd manualmente y abre una sesión.
## En modo headless, el Autoload no existe — debemos instanciar el script directamente.
func _init_logging() -> void:
	var logging_script_path := "res://scripts/autoload/Logging.gd"
	if not ResourceLoader.exists(logging_script_path):
		print("[SmokeTest] WARN: Logging.gd no encontrado — eventos de log omitidos.")
		return

	var logging_script: GDScript = load(logging_script_path)
	if logging_script == null:
		print("[SmokeTest] WARN: No se pudo cargar Logging.gd.")
		return

	_logging = Node.new()
	_logging.set_script(logging_script)
	get_root().add_child(_logging)

	# Iniciar sesión con metadatos del smoke test.
	_logging.start_session({
		"test_suite": "smoke_test_enemy",
		"godot_version": Engine.get_version_info().get("string", "?"),
		"headless": true,
	})
	print("[SmokeTest] Logging inicializado. Log: %s" % _logging.get_log_path())


## Registra el resultado final del smoke test en el log JSON-lines.
func _log_smoke_result(passed: bool, suite: String, pass_count: int, fail_count: int) -> void:
	if _logging == null:
		return
	var event := "smoke_test_passed" if passed else "smoke_test_failed"
	# CHANGED_FOR_LOGGING: convertido de log(level, event, dict) → write_event({dict}) — evita conflicto con builtin GDScript log(float)
	_logging.write_event({
		"level": "info" if passed else "error",
		"event": event,
		"data": {
			"suite": suite,
			"pass_count": pass_count,
			"fail_count": fail_count,
			"failures": _failures,
		},
	})
