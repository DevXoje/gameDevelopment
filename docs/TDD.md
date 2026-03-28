# 🛠️ Technical Design Document (TDD)

**Proyecto:** TODO: NOMBRE DEL JUEGO  
**Autor/es:** TODO: NOMBRE DEL EQUIPO TÉCNICO  
**Versión:** 0.1 — Borrador inicial  
**Fecha:** TODO: FECHA  
**Estado:** En elaboración  

---

## 1. Elección de Engine / Framework

**Engine seleccionado:** TODO: DECIDIR ENGINE (Godot 4 / Unity / Unreal / Phaser / custom)

| Opción evaluada | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| TODO: Godot 4 | Open source, GDScript sencillo, bueno para 2D | Menor ecosistema que Unity | TODO: Evaluar |
| TODO: Unity 6 | Gran ecosistema, multiplataforma | Licencias, rendimiento 2D inferior | TODO: Evaluar |
| TODO: Unreal 5 | Top en gráficos 3D, Blueprints | Curva de aprendizaje, overkill para 2D | TODO: Evaluar |
| TODO: Otra opción | TODO | TODO | TODO |

**Razón de la elección:** TODO: DECIDIR Y DOCUMENTAR AQUÍ

**Versión del engine:** TODO: versión exacta (ej. Godot 4.3, Unity 6.0 LTS)

---

## 2. Estructura del Proyecto

```
TODO: NOMBRE_PROYECTO/
├── docs/               # Documentación (GDD, TDD, ROADMAP, etc.)
├── art/                # Assets de arte (fuentes, sprites, UI, VFX)
│   ├── sprites/
│   ├── ui/
│   └── vfx/
├── audio/              # Assets de audio (música, SFX)
│   ├── music/
│   └── sfx/
├── tools/              # Scripts y herramientas de desarrollo/pipeline
├── src/                # TODO: DECIDIR — código fuente del juego
│   ├── scenes/         # Escenas o pantallas del juego
│   ├── scripts/        # Scripts/lógica del juego
│   ├── systems/        # Subsistemas (ver sección 3)
│   └── ui/             # Scripts de interfaz
└── exports/            # Builds exportados (no subir a git — en .gitignore)
```

**Notas de estructura:**
- TODO: Decidir si separar código por feature o por tipo de archivo
- TODO: Definir dónde van los tests si se implementan

---

## 3. Subsistemas

### 3.1 Input

**Descripción:** Sistema de captura y abstracción de entrada del jugador.

- **Fuente de input:** TODO: DECIDIR (Input Map nativo del engine, Rewired, New Input System, etc.)
- **Soporta remapping:** TODO: sí/no
- **Dispositivos soportados:** TODO: Teclado+Ratón, Gamepad Xbox/PS, Touch
- **Abstracción de input:** TODO: definir si se usa un action map o se lee directamente el hardware

**Archivos clave:** TODO: path/a/InputManager.gd o InputSystem.cs

### 3.2 Renderizado

**Descripción:** Pipeline de renderizado y configuración gráfica.

- **Renderer:** TODO: DECIDIR (Forward+, Compatibility, Deferred, 2D Renderer)
- **Resolución base:** TODO: ej. 1920×1080, 16:9, con escalado
- **Resolución de referencia para UI:** TODO: ej. 1280×720
- **Soporta HDR:** TODO: sí/no
- **Anti-aliasing:** TODO: ninguno / FXAA / MSAA
- **Cámara:** TODO: ortogonal / perspectiva, sistema de seguimiento al jugador

**Archivos clave:** TODO: path/a/CameraController

### 3.3 Audio

**Descripción:** Sistema de reproducción y gestión de audio.

- **Librería/motor de audio:** TODO: DECIDIR (FMOD, Wwise, motor nativo, Godot AudioStreamPlayer)
- **Buses de audio:** Máster, Música, SFX, UI, Voz
- **Música dinámica:** TODO: sí/no (adaptive music)
- **Formato de assets:** TODO: .ogg / .wav / .mp3 — ver sección de assets
- **Pooling de SFX:** TODO: sí/no

**Archivos clave:** TODO: path/a/AudioManager

### 3.4 Física

**Descripción:** Motor de física y configuración de colisiones.

- **Motor de física:** TODO: DECIDIR (nativo del engine, Box2D, Rapier, etc.)
- **Tipo de física:** TODO: 2D / 3D
- **Layers de colisión:**

| Layer | Nombre | Colisiona con |
|---|---|---|
| 1 | TODO: World/Terrain | TODO: Player, Enemies |
| 2 | TODO: Player | TODO: World, Enemies, Items |
| 3 | TODO: Enemies | TODO: World, Player, Projectiles |
| 4 | TODO: Items/Pickups | TODO: Player |

**Archivos clave:** TODO: Configuración de physics layers en el proyecto

### 3.5 Networking (si aplica)

TODO: Si el juego NO tiene multijugador online, eliminar esta sección o marcarla como "No aplica en v1".

- **Tipo:** TODO: P2P / Cliente-Servidor / sin networking
- **Librería:** TODO: DECIDIR (Netcode for GameObjects, ENet, Nakama, Photon, etc.)
- **Arquitectura:** TODO: authoritative server / lockstep / rollback netcode
- **Máx. jugadores simultáneos:** TODO

### 3.6 Save System (Sistema de Guardado)

**Descripción:** Cómo se guarda y carga el progreso del jugador.

- **Formato:** TODO: DECIDIR (.json / binario / SQLite / PlayerPrefs)
- **Datos que se guardan:** TODO: lista (progresión, configuración, estadísticas)
- **Dónde se guarda:** TODO: carpeta del sistema (user://saves/ en Godot, Application.persistentDataPath en Unity)
- **Slots de guardado:** TODO: 1 slot automático / múltiples slots / cloud save
- **Encriptación:** TODO: sí/no (para anti-cheat o datos sensibles)

**Archivos clave:** TODO: path/a/SaveManager

---

## 4. Pipeline de Builds

### 4.1 Configuraciones de Build

| Config | Plataforma | Propósito |
|---|---|---|
| Debug | TODO: PC | Desarrollo local, logs activados |
| QA/Staging | TODO: PC | Testing interno, sin cheat codes en prod |
| Release | TODO: PC, Switch, etc. | Build de producción |

### 4.2 Proceso de Export/Build

TODO: Describe los pasos para generar un build exportable.

```bash
# TODO: Documenta el comando o proceso de build aquí
# Ejemplo para Godot:
# godot --export-release "Windows Desktop" exports/game_windows.exe

# Ejemplo para Unity (línea de comandos):
# unity -batchmode -quit -buildTarget StandaloneWindows64 -buildPath exports/
```

### 4.3 Carpeta de exports

La carpeta `/exports/` debe estar en `.gitignore`. Los builds se distribuyen por TODO: DECIDIR (GitHub Releases, itch.io, Butler, etc.).

---

## 5. Dependencias y Librerías Externas

| Librería / Plugin | Versión | Propósito | Fuente |
|---|---|---|---|
| TODO: Nombre | TODO: versión | TODO: para qué sirve | TODO: URL/Asset Store |
| TODO: Nombre | TODO: versión | TODO: | TODO: |

**Nota:** Mantener esta tabla actualizada. Antes de añadir una dependencia nueva, documentarla aquí.

---

## 6. Formato de Assets y Convenciones

### 6.1 Sprites / Imágenes

- **Formato:** TODO: DECIDIR (.png preferido, .svg para UI escalable)
- **Resolución base de sprites:** TODO: ej. 16×16px, 32×32px, 64×64px
- **DPI/PPU (Pixels Per Unit):** TODO: ej. 32 PPU
- **Transparencia:** Siempre usar canal alfa (.png). Sin JPG para sprites.
- **Carpeta:** `art/sprites/`

### 6.2 Audio

- **Música:** TODO: .ogg (preferido para bucles), stereo, 44.1kHz, 192kbps
- **SFX:** TODO: .wav o .ogg, mono cuando sea posible, 44.1kHz
- **Carpeta:** `audio/music/` y `audio/sfx/`

### 6.3 Naming Conventions (Nomenclatura de Assets)

> Consistencia es más importante que el estilo elegido. Elige uno y mantenlo.

**Estilo elegido:** TODO: DECIDIR — snake_case recomendado para assets

| Tipo | Formato | Ejemplo |
|---|---|---|
| Sprites de personaje | `char_{nombre}_{estado}` | `char_player_idle.png` |
| Sprites de UI | `ui_{elemento}_{estado}` | `ui_button_hover.png` |
| Música | `mus_{nombre_pista}` | `mus_main_theme.ogg` |
| SFX | `sfx_{acción}` | `sfx_jump.wav` |
| Escenas/Niveles | `level_{número}_{nombre}` | `level_01_tutorial.tscn` |
| Scripts | PascalCase para clases | `PlayerController.cs` |

### 6.4 Archivos .meta / Import Settings

TODO: Si usas Unity, los .meta van a git. Si usas Godot, los .import van a git. Definir política aquí.

- **¿.meta / .import al repo?** TODO: DECIDIR — sí (recomendado para trabajo en equipo)

---

## 7. CI / Automatización Sugerida

TODO: Implementar cuando el equipo crezca o cuando haya builds frecuentes.

### 7.1 GitHub Actions / CI Pipeline (sugerido)

```yaml
# TODO: Ejemplo base — adaptar al engine elegido
# .github/workflows/build.yml
name: Build & Test
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # TODO: añadir steps de setup del engine
      # TODO: añadir step de build
      # TODO: añadir step de tests (si aplica)
      # TODO: añadir step de export del artefacto
```

### 7.2 Hooks de Pre-commit (recomendados)

- [ ] TODO: Linter de scripts (ej. gdtoolkit para GDScript, ESLint para TS)
- [ ] TODO: Verificar que no se suben assets en formato incorrecto
- [ ] TODO: Formato de commits validado (Conventional Commits)

---

## 8. Performance Targets (Objetivos de Rendimiento)

| Plataforma | FPS objetivo | FPS mínimo aceptable | RAM objetivo | Notas |
|---|---|---|---|---|
| PC (gama media) | 60 FPS estable | 45 FPS | <2 GB | Referencia: i5 2020, GTX 1060 |
| TODO: Nintendo Switch | 60 FPS | 30 FPS | <4 GB | Modo portátil y TV |
| TODO: Mobile | 60 FPS | 30 FPS | <500 MB | iOS/Android gama media |

**Herramientas de profiling:**
- TODO: DECIDIR — Godot Profiler / Unity Profiler / external profiler
- TODO: Objetivo de draw calls por frame: TODO
- TODO: Objetivo de polígonos/sprites en pantalla simultáneos: TODO

---

## 9. Notas Técnicas y Pendientes

> Sección libre para decisiones técnicas pendientes y deuda técnica conocida.

- TODO: Decisión técnica pendiente 1
- TODO: Decisión técnica pendiente 2
- TODO: Deuda técnica a resolver en milestone X

---

_Documento generado automáticamente como plantilla. Versión: 0.1 — Rellenar con el equipo técnico._
