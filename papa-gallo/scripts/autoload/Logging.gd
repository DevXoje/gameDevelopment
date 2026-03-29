## Logging.gd
## Autoload singleton de observabilidad local — escribe eventos en JSON-lines.
##
## Responsabilidad:
##   - Generar un session_id único por ejecución.
##   - Escribir eventos como líneas JSON en papa-gallo/logs/session_<id>.log.
##   - Auto-flush cada N eventos (default 20) o cada T segundos (default 10).
##   - Rotación simple: elimina los archivos de log más antiguos cuando se supera max_files.
##   - Seguro en builds de release: escrituras no bloqueantes (open/write/close por flush).
##   - Remote upload DESHABILITADO por defecto; sólo configura las variables, no sube datos.
##
## NOTA IMPORTANTE — conflicto con builtin GDScript:
##   GDScript tiene una función matemática builtin llamada `log(float)` (logaritmo natural).
##   Por esto, el método de registro se llama `write_event(entry: Dictionary)` en lugar de `log()`.
##   Llamar `log({...})` dentro de un script GDScript invoca el builtin matemático y causa
##   el error "Parse Error: Invalid argument for 'log()' function: argument 1 should be 'float'".
##
## API pública:
##   Logging.write_event(entry: Dictionary)  — registra un evento (único parámetro Dictionary)
##   Logging.flush()                          — escribe el buffer a disco inmediatamente
##   Logging.start_session(metadata)         — (re)inicia una sesión y devuelve el session_id
##
## Formato del Dictionary para Logging.write_event():
##   {
##     "ts":         String  — timestamp ISO-8601 (se añade automáticamente si falta)
##     "level":      String  — "info" | "warn" | "error" | "debug"
##     "event":      String  — nombre del evento (ej. "session_ended", "player_death")
##     "session_id": String  — ID de sesión (se añade automáticamente si falta)
##     "data":       Dictionary — datos del evento (opcional)
##     "version":    String  — versión del juego (se añade automáticamente si falta)
##   }
##
## Limitaciones conocidas:
##   - En modo headless sin SceneTree activo, el Timer no puede iniciarse; se usa flush
##     inmediato (auto_flush_count = 1) para que cada write_event() escriba a disco.
##   - Las escrituras son síncronas (FileAccess.open/store_line/close); para volúmenes altos
##     considera ThreadedFileAccess o reducir la frecuencia de eventos.
##   - Los archivos de log NO se encriptan — no guardes PII en los campos `data`.
##
## Opción B (integración remota) — documentada en docs/TDD_GODOT_4_6.md:
##   Activar enable_remote_upload = true y configurar remote_endpoint para habilitar
##   el envío (la implementación real debe añadirse en _upload_batch()).
##
## Uso rápido:
##   Logging.write_event({"level": "info", "event": "round_started", "data": {"round": 1, "spawn_count": 3}})
##   Logging.write_event({"level": "error", "event": "player_death", "data": {"pos": str(global_position)}})
##   Logging.flush()   # forzar escritura antes de salir

extends Node

# ---------------------------------------------------------------------------
# Configuración exportable
# ---------------------------------------------------------------------------

## Número de eventos en buffer antes de hacer flush automático.
@export var auto_flush_count: int = 20

## Segundos entre flushes automáticos por Timer (0 = deshabilitado).
@export var auto_flush_interval: float = 10.0

## Tamaño máximo de un archivo de log antes de rotar (bytes). Default: 2 MB.
@export var max_file_size_bytes: int = 2 * 1024 * 1024

## Número máximo de archivos de log en la carpeta antes de borrar los más antiguos.
@export var max_log_files: int = 10

## Activar upload remoto (Option B). Falso por defecto — no sube datos.
@export var enable_remote_upload: bool = false

## Endpoint remoto para upload (Option B). Sólo se usa si enable_remote_upload = true.
@export var remote_endpoint: String = ""

# ---------------------------------------------------------------------------
# Constantes
# ---------------------------------------------------------------------------

const LOG_DIR := "res://logs/"
const VERSION := "0.1.0"

# ---------------------------------------------------------------------------
# Estado interno
# ---------------------------------------------------------------------------

var _session_id: String = ""
var _log_path: String = ""
var _buffer: Array[String] = []
var _flush_timer: Timer = null
var _session_start_time: float = 0.0
var _is_headless: bool = false

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------

func _ready() -> void:
	# Detectar modo headless para ajustar comportamiento del Timer.
	_is_headless = DisplayServer.get_name() == "headless"

	# Iniciar sesión automáticamente con metadatos del sistema.
	start_session({
		"platform": OS.get_name(),
		"version": VERSION,
		"debug": OS.is_debug_build(),
		"headless": _is_headless,
	})

	# Configurar flush por Timer (sólo si hay SceneTree y no es headless).
	if not _is_headless and auto_flush_interval > 0.0:
		_flush_timer = Timer.new()
		_flush_timer.wait_time = auto_flush_interval
		_flush_timer.one_shot = false
		_flush_timer.autostart = true
		_flush_timer.timeout.connect(flush)
		add_child(_flush_timer)
	elif _is_headless:
		# En headless: flush inmediato en cada llamada (sin Timer).
		auto_flush_count = 1
		print("[Logging] Modo headless detectado — flush inmediato activado.")


func _notification(what: int) -> void:
	# Garantizar flush al salir del árbol (cierre del juego).
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		# CHANGED_FOR_LOGGING: renombrado de log() → write_event() para evitar conflicto con builtin GDScript log(float)
		write_event({
			"level": "info",
			"event": "session_ended",
			"session_id": _session_id,
			"data": {
				"duration_s": _get_elapsed_seconds(),
			},
		})
		flush()


# ---------------------------------------------------------------------------
# API pública
# ---------------------------------------------------------------------------

## Inicia (o reinicia) la sesión de logging.
## @param metadata: Diccionario con datos extra para el evento session_started.
## @return: El session_id generado (string con timestamp + random).
func start_session(metadata: Dictionary = {}) -> String:
	# Flush y cierre de sesión anterior si existe.
	if _session_id != "":
		flush()

	_session_start_time = Time.get_unix_time_from_system()
	_session_id = _generate_session_id()
	_log_path = LOG_DIR + "session_" + _session_id + ".log"
	_buffer.clear()

	# Asegurar que el directorio de logs existe.
	_ensure_log_dir()

	# Rotar logs antiguos si es necesario.
	_rotate_logs()

	# Emitir evento de inicio de sesión.
	var session_data := {
		"session_id": _session_id,
		"log_path": _log_path,
		"version": VERSION,
		"platform": OS.get_name(),
	}
	session_data.merge(metadata)
	# CHANGED_FOR_LOGGING: renombrado de log() → write_event() para evitar conflicto con builtin GDScript log(float)
	write_event({
		"level": "info",
		"event": "session_started",
		"session_id": _session_id,
		"data": session_data,
	})

	print("[Logging] Sesión iniciada: %s → %s" % [_session_id, ProjectSettings.globalize_path(_log_path)])
	return _session_id


## Registra un evento en el buffer (y flushea si se supera auto_flush_count).
##
## NOTA: No se puede llamar a este método "log" porque GDScript tiene una función
## builtin log(float) para logaritmo natural que causaría un error de parse.
## Por eso se llama write_event().
##
## @param entry: Dictionary con los campos del evento:
##   - "level":      String  — "info" | "warn" | "error" | "debug"
##   - "event":      String  — nombre del evento
##   - "session_id": String  — (opcional) se añade automáticamente si falta
##   - "data":       Dictionary — datos del evento (opcional)
##   - "ts":         String  — (opcional) timestamp ISO-8601, se añade si falta
##   - "version":    String  — (opcional) versión, se añade si falta
func write_event(entry: Dictionary) -> void:
	if _session_id.is_empty():
		# Seguridad: si write_event() se llama antes de _ready(), iniciar sesión.
		start_session()

	# Normalizar campos obligatorios si no vienen en el entry.
	var normalized := {
		"ts": Time.get_datetime_string_from_system(true),
		"session_id": _session_id,
		"version": VERSION,
		"platform": OS.get_name(),
		"level": entry.get("level", "info"),
		"event": entry.get("event", "unknown"),
		"data": entry.get("data", {}),
	}
	# Sobreescribir con los valores que sí vienen en el entry (ts, session_id, version personalizados).
	if entry.has("ts"):
		normalized["ts"] = entry["ts"]
	if entry.has("session_id"):
		normalized["session_id"] = entry["session_id"]
	if entry.has("version"):
		normalized["version"] = entry["version"]

	var line := JSON.stringify(normalized)
	_buffer.append(line)

	# Auto-flush si se superó el umbral de eventos.
	if _buffer.size() >= auto_flush_count:
		flush()


## Escribe el buffer completo a disco y lo vacía.
## Seguro llamar desde cualquier contexto.
func flush() -> void:
	if _buffer.is_empty():
		return
	if _log_path.is_empty():
		return

	var abs_path := ProjectSettings.globalize_path(_log_path)
	_ensure_log_dir()

	# Verificar rotación por tamaño antes de escribir.
	var fa_check := FileAccess.open(_log_path, FileAccess.READ)
	if fa_check != null:
		var size := fa_check.get_length()
		fa_check.close()
		if size >= max_file_size_bytes:
			_rotate_current_log()

	# Escribir buffer en modo WRITE + APPEND
	var fa := FileAccess.open(_log_path, FileAccess.READ_WRITE)
	if fa == null:
		# El archivo aún no existe — crear nuevo.
		fa = FileAccess.open(_log_path, FileAccess.WRITE)

	if fa == null:
		push_warning("[Logging] No se pudo abrir el archivo de log: %s (error %d)" % [abs_path, FileAccess.get_open_error()])
		return

	# Mover al final del archivo para append.
	fa.seek_end()
	for line in _buffer:
		fa.store_line(line)
	fa.close()

	_buffer.clear()


## Devuelve el session_id actual.
func get_session_id() -> String:
	return _session_id


## Devuelve la ruta absoluta del log actual.
func get_log_path() -> String:
	return ProjectSettings.globalize_path(_log_path)


# ---------------------------------------------------------------------------
# Privado — generación de IDs y paths
# ---------------------------------------------------------------------------

func _generate_session_id() -> String:
	# Formato: YYYYMMDD_HHMMSS_RRRR (timestamp UTC + 4 dígitos random)
	var dt := Time.get_datetime_dict_from_system(true)
	var ts := "%04d%02d%02d_%02d%02d%02d" % [
		dt.year, dt.month, dt.day,
		dt.hour, dt.minute, dt.second
	]
	var rnd := randi() % 10000
	return "%s_%04d" % [ts, rnd]


func _get_elapsed_seconds() -> float:
	return Time.get_unix_time_from_system() - _session_start_time


# ---------------------------------------------------------------------------
# Privado — sistema de archivos y rotación
# ---------------------------------------------------------------------------

func _ensure_log_dir() -> void:
	var abs_dir := ProjectSettings.globalize_path(LOG_DIR)
	if not DirAccess.dir_exists_absolute(abs_dir):
		var err := DirAccess.make_dir_recursive_absolute(abs_dir)
		if err != OK:
			push_warning("[Logging] No se pudo crear la carpeta de logs: %s" % abs_dir)


func _rotate_logs() -> void:
	## Elimina los archivos de log más antiguos si se supera max_log_files.
	var abs_dir := ProjectSettings.globalize_path(LOG_DIR)
	var dir := DirAccess.open(abs_dir)
	if dir == null:
		return

	var log_files: Array[String] = []
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if fname.begins_with("session_") and fname.ends_with(".log"):
			log_files.append(abs_dir + fname)
		fname = dir.get_next()
	dir.list_dir_end()

	# Ordenar por nombre (el formato de timestamp garantiza orden cronológico).
	log_files.sort()

	# Eliminar los más antiguos hasta estar dentro del límite.
	while log_files.size() >= max_log_files:
		var oldest := log_files[0]
		log_files.remove_at(0)
		var err := OS.move_to_trash(oldest)
		if err != OK:
			# Fallback: borrar directamente.
			DirAccess.remove_absolute(oldest)


func _rotate_current_log() -> void:
	## Crea un nuevo log cuando el actual supera max_file_size_bytes.
	flush()
	_session_id = _generate_session_id()
	_log_path = LOG_DIR + "session_" + _session_id + ".log"
	_rotate_logs()
	# CHANGED_FOR_LOGGING: renombrado de log() → write_event() para evitar conflicto con builtin GDScript log(float)
	write_event({"level": "info", "event": "log_rotated", "data": {"new_log": _log_path}})
