## AudioManager.gd
## Autoload singleton que gestiona la reproducción de música y efectos de sonido (SFX).
## Controla los buses de audio de Godot para volumen y mezcla centralizada.
##
## Responsabilidad:
##   - Reproducir y detener pistas de música de fondo.
##   - Reproducir SFX por clave (nombre del recurso).
##   - Controlar el volumen maestro y por bus.
##
## Uso rápido:
##   AudioManager.play_music("mus_main_theme")
##   AudioManager.play_sfx("sfx_sword_swing")
##   AudioManager.set_master_volume(0.8)
##   AudioManager.stop_music()
##
## TODO: Implementar fade in/out para transiciones de música.
## TODO: Cargar volumen guardado desde SaveManager en _ready().

extends Node

# ---------------------------------------------------------------------------
# Constantes
# ---------------------------------------------------------------------------

## Ruta base donde se encuentran los archivos de música importados.
const MUSIC_PATH: String = "res://assets/audio/music/"

## Ruta base donde se encuentran los archivos de SFX importados.
const SFX_PATH: String = "res://assets/audio/sfx/"

## Nombre del bus maestro en el AudioServer de Godot.
const BUS_MASTER: String = "Master"

# ---------------------------------------------------------------------------
# Nodos internos (creados dinámicamente)
# ---------------------------------------------------------------------------

## Reproductor dedicado para música de fondo (streams largas).
var _music_player: AudioStreamPlayer

## Reproductor dedicado para SFX cortos.
var _sfx_player: AudioStreamPlayer

# ---------------------------------------------------------------------------
# Ciclo de vida (Godot)
# ---------------------------------------------------------------------------

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Music"  # TODO: Crear bus "Music" en el AudioServer del editor.
	add_child(_music_player)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFXPlayer"
	_sfx_player.bus = "SFX"  # TODO: Crear bus "SFX" en el AudioServer del editor.
	add_child(_sfx_player)

	print("[AudioManager] Listo. Buses: Music, SFX.")


# ---------------------------------------------------------------------------
# API pública — música
# ---------------------------------------------------------------------------

## Carga y reproduce una pista de música de fondo.
## @param track: Nombre del archivo sin extensión (ej. "mus_main_theme").
## El archivo debe existir en res://assets/audio/music/ como .ogg.
## Ejemplo:
##   AudioManager.play_music("mus_main_theme")
func play_music(track: String) -> void:
	var path := MUSIC_PATH + track + ".ogg"
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else null
	if stream == null:
		push_error("[AudioManager] Música no encontrada: %s" % path)
		return
	_music_player.stream = stream
	_music_player.play()
	print("[AudioManager] Reproduciendo música: %s" % track)


## Detiene la música de fondo que esté sonando.
## Ejemplo:
##   AudioManager.stop_music()
func stop_music() -> void:
	_music_player.stop()
	print("[AudioManager] Música detenida.")


# ---------------------------------------------------------------------------
# API pública — SFX
# ---------------------------------------------------------------------------

## Reproduce un efecto de sonido puntual.
## @param key: Nombre del archivo sin extensión (ej. "sfx_sword_swing").
## El archivo debe existir en res://assets/audio/sfx/ como .wav.
## Ejemplo:
##   AudioManager.play_sfx("sfx_sword_swing")
func play_sfx(key: String) -> void:
	var path := SFX_PATH + key + ".wav"
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else null
	if stream == null:
		# Intentar con .ogg como fallback
		path = SFX_PATH + key + ".ogg"
		stream = load(path) if ResourceLoader.exists(path) else null
	if stream == null:
		push_error("[AudioManager] SFX no encontrado: %s" % key)
		return
	_sfx_player.stream = stream
	_sfx_player.play()


# ---------------------------------------------------------------------------
# API pública — volumen
# ---------------------------------------------------------------------------

## Ajusta el volumen del bus maestro.
## @param vol: Valor entre 0.0 (silencio) y 1.0 (máximo). Se convierte a dB.
## Ejemplo:
##   AudioManager.set_master_volume(0.5)
func set_master_volume(vol: float) -> void:
	vol = clamp(vol, 0.0, 1.0)
	var db := linear_to_db(vol)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_MASTER), db)
	print("[AudioManager] Volumen maestro: %.2f (%.1f dB)" % [vol, db])


## Ajusta el volumen de un bus específico por nombre.
## @param bus_name: Nombre del bus (ej. "Music", "SFX").
## @param vol: Valor entre 0.0 y 1.0.
## Ejemplo:
##   AudioManager.set_bus_volume("Music", 0.7)
func set_bus_volume(bus_name: String, vol: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		push_error("[AudioManager] Bus no encontrado: %s" % bus_name)
		return
	vol = clamp(vol, 0.0, 1.0)
	AudioServer.set_bus_volume_db(idx, linear_to_db(vol))
