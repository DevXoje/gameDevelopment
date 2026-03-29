# Audio Assets — PapaGallo

Esta carpeta contiene todos los archivos de audio listos para importar en Godot 4.6.

---

## Estructura de carpetas

```
assets/audio/
├── music/        # Música de fondo (loops de gameplay, menú, boss)
├── sfx/          # Efectos de sonido (ataques, pasos, UI, ambiente)
├── stems/        # Stems individuales de la música (capas separadas para música dinámica)
└── processed/    # Exports procesados del DAW — archivos listos para entrega
```

---

## Convenciones de naming

| Tipo        | Patrón                          | Ejemplo                        |
|-------------|----------------------------------|--------------------------------|
| Música      | `mus_{nombre}.ogg`              | `mus_main_theme.ogg`           |
| SFX         | `sfx_{accion}.wav`              | `sfx_sword_swing.wav`          |
| SFX (loop)  | `sfx_{accion}_loop.wav`         | `sfx_wind_loop.wav`            |
| Stem        | `stem_{track}_{capa}.wav`       | `stem_main_theme_drums.wav`    |
| Procesado   | `{nombre}_{version}_{fecha}.ogg`| `main_theme_v2_20260329.ogg`   |

**Regla:** Todo en `snake_case`. Sin espacios, sin mayúsculas, sin caracteres especiales.

---

## Formatos maestros (archivos de trabajo — DAW)

| Tipo       | Formato         | Sample Rate | Bit Depth | Canales |
|------------|-----------------|-------------|-----------|---------|
| Música     | WAV             | 48 kHz      | 24-bit    | Stereo  |
| SFX        | WAV             | 48 kHz      | 24-bit    | Mono    |
| Stems      | WAV             | 48 kHz      | 24-bit    | Stereo  |

> Los archivos maestros **NO van en esta carpeta**. Viven en `audio/` (raíz del repo, fuera del proyecto Godot).

---

## Formatos de entrega (archivos en esta carpeta — para Godot)

| Tipo       | Formato          | Sample Rate | Calidad   | Loop     | Bus Godot |
|------------|-----------------|-------------|-----------|----------|-----------|
| Música     | OGG Vorbis (.ogg)| 44.1 kHz    | Quality 6 | `true`   | `Music`   |
| SFX        | WAV (.wav)       | 44.1 kHz    | Sin comprimir | `false` | `SFX` |
| SFX grande | OGG Vorbis (.ogg)| 44.1 kHz    | Quality 5 | `false`  | `SFX`    |

### Cuándo usar OGG vs WAV para SFX

- **WAV**: SFX cortos (< 2 segundos) — carga completa en RAM, latencia mínima. Ideal para golpes, pasos, UI.
- **OGG**: SFX largos o con loop (> 2 segundos) — streaming, menor RAM. Ideal para ambiente, viento, loops.

---

## Configuración de importación en Godot (.import)

### Música (.ogg)
```
loop=true
loop_offset=0.0
bpm=0
beat_count=0
```

### SFX (.wav)
```
force/8_bit=false
force/mono=true      # Cuando sea posible — ahorra 50% de RAM
force/max_rate=false
```

> Los archivos `.import` generados por Godot **sí van al repositorio git** para garantizar consistencia entre miembros del equipo.

---

## Buses de audio (Godot)

Los buses están configurados en `project.godot` (sección `[audio_buses]`):

| Bus    | Índice | Envía a  | Uso                                      |
|--------|--------|----------|------------------------------------------|
| Master | 0      | Master   | Bus raíz — control de volumen global     |
| Music  | 1      | Master   | Música de fondo — `AudioManager` lo usa con `play_music()` |
| SFX    | 2      | Master   | Efectos de sonido — `AudioManager` lo usa con `play_sfx()` |

El `AudioManager` (autoload) accede a los buses por nombre exacto:
- Bus de música: `"Music"`
- Bus de SFX: `"SFX"`

Ejemplo de uso desde otros scripts:
```gdscript
AudioManager.play_music("mus_main_theme")  # Reproduce en bus Music
AudioManager.play_sfx("sfx_sword_swing")   # Reproduce en bus SFX
AudioManager.set_music_volume(0.8)         # Volumen del bus Music
AudioManager.set_sfx_volume(1.0)           # Volumen del bus SFX
```

---

## LOD de audio (Level of Detail)

Para optimizar rendimiento en rondas con muchos enemigos simultáneos:

1. **SFX de distancia**: Usar `AudioStreamPlayer2D` con `max_distance` configurado. Sonidos fuera del rango no se reproducen.
2. **Pool de AudioStreamPlayer**: El `AudioManager` mantiene un pool fijo (8 instancias) para SFX. Evita crear/destruir nodos en tiempo de ejecución.
3. **Prioridad de SFX**: Si el pool está lleno, los SFX de menor prioridad (ambiente) se descartan en favor de SFX de alta prioridad (golpes, muerte).

---

## Workflow de audio

```
DAW (FL Studio / Reaper)
  └── Exportar WAV 48kHz 24-bit
		└── audio/ (raíz del repo — archivos maestros)
			  └── Procesar / Convertir
					└── papa-gallo/assets/audio/processed/  (exports intermedios)
						  └── papa-gallo/assets/audio/music/ o sfx/  (listos para Godot)
```

---

_Última actualización: 2026-03-29_
