## SaveManager.gd
## Autoload singleton que gestiona el guardado y carga de partidas y configuraciones.
## Usa ConfigFile de Godot para persistir datos en user:// (carpeta segura del usuario).
##
## Responsabilidad:
##   - Guardar el estado de la partida (puntuación, ronda, configuración) en slots numerados.
##   - Cargar el estado previo al iniciar el juego.
##   - Proveer helpers para verificar si existe un guardado.
##
## Uso rápido:
##   SaveManager.save_game(0)             # guarda en slot 0
##   var data = SaveManager.load_game(0)  # carga slot 0 (Dictionary o null)
##   SaveManager.has_save(0)              # true si el slot existe
##
## TODO: Implementar cifrado básico para saves en builds release.
## TODO: Integrar con GameManager para auto-guardar al terminar cada ronda.

extends Node

# ---------------------------------------------------------------------------
# Constantes
# ---------------------------------------------------------------------------

## Sección usada en el ConfigFile para datos de partida.
const SECTION_GAME: String = "game"

## Sección usada en el ConfigFile para configuración del jugador.
const SECTION_CONFIG: String = "config"

# ---------------------------------------------------------------------------
# Ciclo de vida (Godot)
# ---------------------------------------------------------------------------

func _ready() -> void:
	print("[SaveManager] Listo. Directorio user://: %s" % OS.get_user_data_dir())


# ---------------------------------------------------------------------------
# Helpers privados
# ---------------------------------------------------------------------------

## Construye la ruta completa del archivo de guardado para el slot dado.
## @param slot: Número de slot (0 = slot principal).
func _save_path(slot: int) -> String:
	return "user://save_%d.cfg" % slot


# ---------------------------------------------------------------------------
# API pública
# ---------------------------------------------------------------------------

## Guarda el estado actual del juego en el slot especificado.
## Lee los datos desde GameManager (puntos, ronda actual).
## @param slot: Número de slot donde guardar (por defecto 0).
## Ejemplo:
##   SaveManager.save_game()     # slot 0
##   SaveManager.save_game(1)    # slot 1
func save_game(slot: int = 0) -> void:
	var config := ConfigFile.new()
	# --- Datos del juego (desde GameManager) ---
	# TODO: Reemplazar acceso directo por señales o parámetros una vez que GameManager esté completo.
	if has_node("/root/GameManager"):
		var gm := get_node("/root/GameManager")
		config.set_value(SECTION_GAME, "current_round", gm.current_round)
		config.set_value(SECTION_GAME, "puntos", gm.puntos)
	else:
		config.set_value(SECTION_GAME, "current_round", 0)
		config.set_value(SECTION_GAME, "puntos", 0)

	# --- Timestamp de guardado ---
	config.set_value(SECTION_GAME, "saved_at", Time.get_datetime_string_from_system())

	var path := _save_path(slot)
	var err := config.save(path)
	if err != OK:
		push_error("[SaveManager] Error al guardar en slot %d: %s" % [slot, err])
	else:
		print("[SaveManager] Partida guardada en slot %d (%s)." % [slot, path])


## Carga el guardado del slot especificado.
## Devuelve un Dictionary con los datos, o null si el slot no existe o hay error.
## @param slot: Número de slot a cargar (por defecto 0).
## Ejemplo:
##   var data = SaveManager.load_game()
##   if data: print(data.get("puntos", 0))
func load_game(slot: int = 0) -> Dictionary:
	var path := _save_path(slot)
	var config := ConfigFile.new()
	var err := config.load(path)
	if err != OK:
		print("[SaveManager] No se encontró guardado en slot %d." % slot)
		return {}

	var data := {
		"current_round": config.get_value(SECTION_GAME, "current_round", 0),
		"puntos": config.get_value(SECTION_GAME, "puntos", 0),
		"saved_at": config.get_value(SECTION_GAME, "saved_at", ""),
	}
	print("[SaveManager] Partida cargada desde slot %d: %s" % [slot, data])
	return data


## Verifica si existe un archivo de guardado para el slot dado.
## @param slot: Número de slot a verificar.
## Ejemplo:
##   if SaveManager.has_save(0): mostrar_continuar()
func has_save(slot: int = 0) -> bool:
	return FileAccess.file_exists(_save_path(slot))


## Elimina el archivo de guardado del slot especificado.
## @param slot: Número de slot a borrar.
## Ejemplo:
##   SaveManager.delete_save(0)
func delete_save(slot: int = 0) -> void:
	var path := _save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("[SaveManager] Guardado eliminado: %s" % path)
	else:
		push_warning("[SaveManager] No existe guardado en slot %d." % slot)
