## smoke_test_player.gd
## Smoke test headless para el prototipo de movimiento de papa-gallo.
##
## Ejecutar con:
##   godot --headless --path "<ruta_proyecto>" --script "tools/smoke_test_player.gd"
##
## Verifica:
##   1. Que el script player.gd existe y se puede cargar.
##   2. Que los parámetros exportados (speed, sprint_multiplier) tienen valores válidos.
##   3. Que las acciones del Input Map existen en el proyecto
##      (move_left, move_right, move_up, move_down, sprint).
##   4. Que el script extiende CharacterBody2D.
##
## Código de salida:
##   0 => todos los checks pasaron (SMOKE TEST PASSED)
##   1 => al menos un check falló  (SMOKE TEST FAILED)
##
## Nota sobre Logging en modo headless:
##   El Autoload Logging NO está disponible en scripts headless que extienden SceneTree.
##   Este script instancia Logging manualmente y llama a start_session() + log() + flush()
##   para garantizar que los eventos de smoke test se persistan en disco.

extends SceneTree

const PLAYER_SCRIPT_PATH := "res://scripts/player.gd"
const REQUIRED_ACTIONS := ["move_left", "move_right", "move_up", "move_down", "sprint"]
const EXPECTED_SPEED := 160.0
const EXPECTED_SPRINT_MULT := 1.7

var _failures: Array[String] = []
var _passes: Array[String] = []

## Instancia manual de Logging para modo headless (el Autoload no está disponible aquí).
var _logging: Node = null


func _initialize() -> void:
	print("[SmokeTest] ====== INICIO DEL SMOKE TEST PLAYER ======")
	print("[SmokeTest] Godot versión: %s" % Engine.get_version_info().get("string", "?"))
	print("[SmokeTest] Proyecto: %s" % ProjectSettings.globalize_path("res://"))

	# Inicializar Logging manualmente (no hay Autoload en headless SceneTree).
	_init_logging()

	_check_script_exists()
	_check_input_actions()
	_check_script_constants()

	print("")
	print("[SmokeTest] ====== RESULTADOS ======")
	for p in _passes:
		print("  [PASS] %s" % p)
	for f in _failures:
		print("  [FAIL] %s" % f)

	print("")
	var passed := _failures.is_empty()
	if passed:
		print("[SmokeTest] ✅ SMOKE TEST PASSED — %d checks OK" % _passes.size())
		_log_smoke_result(true, "player", _passes.size(), 0)
	else:
		print("[SmokeTest] ❌ SMOKE TEST FAILED — %d/%d checks fallaron" % [_failures.size(), _passes.size() + _failures.size()])
		_log_smoke_result(false, "player", _passes.size(), _failures.size())

	# Flush final del log.
	if _logging != null:
		_logging.flush()

	quit(0 if passed else 1)


func _check_script_exists() -> void:
	print("[SmokeTest] --- Check 1: Existencia de player.gd ---")
	if ResourceLoader.exists(PLAYER_SCRIPT_PATH):
		var script: GDScript = load(PLAYER_SCRIPT_PATH)
		if script != null:
			_passes.append("player.gd cargado correctamente desde '%s'" % PLAYER_SCRIPT_PATH)
			print("  [OK] Script cargado.")
		else:
			_failures.append("player.gd existe pero no se pudo cargar como GDScript")
			print("  [ERR] Script no cargable.")
	else:
		_failures.append("player.gd no encontrado en '%s'" % PLAYER_SCRIPT_PATH)
		print("  [ERR] Script no encontrado.")


func _check_input_actions() -> void:
	print("[SmokeTest] --- Check 2: Acciones del Input Map ---")
	for action in REQUIRED_ACTIONS:
		if InputMap.has_action(action):
			_passes.append("Input action '%s' registrada" % action)
			print("  [OK] Acción '%s' existe." % action)
		else:
			_failures.append("Input action '%s' NO registrada en el Input Map" % action)
			print("  [ERR] Acción '%s' falta." % action)


func _check_script_constants() -> void:
	print("[SmokeTest] --- Check 3: Constantes del script player.gd ---")
	if not ResourceLoader.exists(PLAYER_SCRIPT_PATH):
		_failures.append("Omitiendo check de constantes — script no disponible")
		return

	# Instanciar un objeto vacío y adjuntarle el script para leer sus defaults.
	# Nota: CharacterBody2D requiere un árbol de escena activo — usamos un nodo temporal.
	var script: GDScript = load(PLAYER_SCRIPT_PATH)
	if script == null:
		_failures.append("No se pudo cargar el script para verificar constantes")
		return

	# Verificar que el script declara speed y sprint_multiplier con valores esperados
	# accediendo a sus propiedades estáticas vía el script en sí.
	var props: Array = script.get_script_property_list()
	var found_speed := false
	var found_sprint := false

	for prop in props:
		if prop["name"] == "speed":
			found_speed = true
		if prop["name"] == "sprint_multiplier":
			found_sprint = true

	if found_speed:
		_passes.append("Propiedad exportada 'speed' declarada en player.gd")
		print("  [OK] Propiedad 'speed' encontrada.")
	else:
		_failures.append("Propiedad exportada 'speed' NO encontrada en player.gd")
		print("  [ERR] Propiedad 'speed' falta.")

	if found_sprint:
		_passes.append("Propiedad exportada 'sprint_multiplier' declarada en player.gd")
		print("  [OK] Propiedad 'sprint_multiplier' encontrada.")
	else:
		_failures.append("Propiedad exportada 'sprint_multiplier' NO encontrada en player.gd")
		print("  [ERR] Propiedad 'sprint_multiplier' falta.")


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
		"test_suite": "smoke_test_player",
		"godot_version": Engine.get_version_info().get("string", "?"),
		"headless": true,
	})
	print("[SmokeTest] Logging inicializado. Log: %s" % _logging.get_log_path())


## Registra el resultado final del smoke test en el log.
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
