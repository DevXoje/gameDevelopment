# Setup de Entorno de Desarrollo — PapaGallo

**Proyecto:** PapaGallo
**Engine:** Godot 4.6 (GL Compatibility)
**Ultima actualizacion:** 2026-03-29

> Guia paso a paso para que un nuevo desarrollador pueda clonar, configurar y ejecutar el proyecto en menos de 30 minutos.

---

## Checklist Rapido

- [ ] Instalar Godot 4.6
- [ ] Clonar el repositorio
- [ ] Abrir el proyecto en Godot
- [ ] Verificar que los import settings se aplicaron
- [ ] Ejecutar la primera escena
- [ ] Configurar tu editor de codigo (opcional)
- [ ] Leer la documentacion del proyecto
- [ ] Crear tu primer branch de trabajo

---

## 1. Instalar Godot 4.6

### Opcion A: Descarga directa (recomendada)

1. Ir a [godotengine.org/download](https://godotengine.org/download)
2. Descargar **Godot 4.6 Standard** para tu sistema operativo
   - Windows: `.exe` (portable, no necesita instalacion)
   - macOS: `.dmg` o `.app.zip`
   - Linux: `.x86_64` (AppImage o tarball)
3. **No instalar la version .NET** a menos que el equipo lo decida — usamos GDScript

### Opcion B: Desde el package manager de tu OS

```bash
# macOS con Homebrew
brew install --cask godot

# Linux (Flatpak)
flatpak install flathub org.godotengine.Godot

# Linux (Snap)
sudo snap install godot-4 --edge
```

### Verificar la instalacion

```bash
godot --version
# Debe mostrar: 4.6.stable o similar
```

> **Importante:** Todos los miembros del equipo deben usar la MISMA version de Godot (4.6.x). Versiones diferentes pueden causar cambios en archivos `.import` y `project.godot` que generan conflictos en git.

---

## 2. Clonar el Repositorio

```bash
# Clonar con HTTPS
git clone https://github.com/TU_ORG/gameDevelopment.git

# O con SSH
git clone git@github.com:TU_ORG/gameDevelopment.git

# Entrar al directorio
cd gameDevelopment
```

### Estructura que veras al clonar

```
gameDevelopment/
├── docs/           # Documentacion (GDD, TDD, ROADMAP, etc.)
├── art/            # Assets de arte originales (Aseprite, PSD)
├── audio/          # Assets de audio originales
├── tools/          # Scripts de pipeline
├── snippets/       # Fragmentos de referencia
└── papa-gallo/     # <-- PROYECTO GODOT (abrir este directorio en Godot)
    ├── project.godot
    ├── src/
    ├── scenes/
    ├── assets/
    └── ...
```

---

## 3. Abrir el Proyecto en Godot

### Desde el editor

1. Abrir Godot 4.6
2. En el Project Manager, click **Import**
3. Navegar hasta `gameDevelopment/papa-gallo/` y seleccionar `project.godot`
4. Click **Import & Edit**

### Desde la terminal

```bash
# Desde la raiz del repo
godot -e --path papa-gallo
```

### Primera vez: Reimportacion de assets

La primera vez que abras el proyecto, Godot reimportara todos los assets. Esto es normal y puede tardar unos segundos. Veras una barra de progreso en la parte inferior del editor.

**Si ves errores de importacion:** Cierra Godot, borra la carpeta `papa-gallo/.godot/imported/`, y vuelve a abrir el proyecto.

---

## 4. Verificar Import Settings

Despues de abrir el proyecto por primera vez:

1. Ir a `Project > Project Settings > General`
2. Verificar estos settings criticos:

| Setting | Ruta en Project Settings | Valor esperado |
|---|---|---|
| Viewport Width | `display/window/size/viewport_width` | `320` |
| Viewport Height | `display/window/size/viewport_height` | `180` |
| Window Width | `display/window/size/window_width_override` | `1920` |
| Window Height | `display/window/size/window_height_override` | `1080` |
| Stretch Mode | `display/window/stretch/mode` | `canvas_items` |
| Stretch Aspect | `display/window/stretch/aspect` | `keep` |
| Texture Filter | `rendering/textures/canvas_textures/default_texture_filter` | `Nearest (0)` |
| Renderer | `rendering/renderer/rendering_method` | `gl_compatibility` |

3. Verificar que los **Autoloads** estan registrados (Project Settings > Autoload):

| Nombre | Script |
|---|---|
| GameManager | `res://src/autoloads/game_manager.gd` |
| InputManager | `res://src/autoloads/input_manager.gd` |
| AudioManager | `res://src/autoloads/audio_manager.gd` |
| SaveManager | `res://src/autoloads/save_manager.gd` |

> **Nota:** Si los autoloads no existen todavia (proyecto en etapa temprana), no te preocupes — se crearan cuando el equipo implemente esos sistemas.

4. Verificar que los **Input Actions** estan definidos (Project Settings > Input Map):
   - `move_up`, `move_down`, `move_left`, `move_right`
   - `attack_primary`, `attack_secondary`
   - `change_weapon`, `sprint`, `interact`, `pause`

---

## 5. Ejecutar la Primera Escena

### Si el proyecto ya tiene escenas

1. En el FileSystem dock (abajo-izquierda), navegar a `scenes/`
2. Hacer doble-click en `main.tscn` (o la escena principal del proyecto)
3. Click en el boton **Play** (F5) o **Play Current Scene** (F6)

### Si el proyecto esta vacio (setup inicial)

Crear una escena de prueba para verificar que todo funciona:

1. `Scene > New Scene`
2. Elegir **2D Scene** como nodo raiz
3. Agregar un nodo `Sprite2D` como hijo
4. Asignarle el `icon.svg` como textura (arrastrar desde FileSystem)
5. Guardar como `scenes/test_setup.tscn`
6. Ejecutar con F5 — deberas ver el icono de Godot en pantalla

**Si la imagen se ve borrosa:** El filtro de texturas no es `Nearest`. Ir a Project Settings y cambiar `rendering/textures/canvas_textures/default_texture_filter` a `0 (Nearest)`.

---

## 6. Configurar tu Editor de Codigo (Opcional)

### Opcion A: Usar el editor integrado de Godot

Godot trae un editor de scripts integrado que es suficiente para la mayoria del trabajo. No necesitas nada extra.

### Opcion B: Editor externo

Si prefieres usar un editor externo:

1. En Godot: `Editor > Editor Settings > Text Editor > External`
2. Activar `Use External Editor`
3. Configurar la ruta al ejecutable:

| Editor | Exec Path (macOS) | Exec Flags |
|---|---|---|
| VS Code | `/usr/local/bin/code` | `{project} --goto {file}:{line}:{col}` |
| Cursor | Similar a VS Code | `{project} --goto {file}:{line}:{col}` |
| Vim/Neovim | `/usr/local/bin/nvim` | `{file}` |

### Extensiones recomendadas para VS Code / Cursor

- **godot-tools** — GDScript syntax highlighting, autocompletado, linting
- **EditorConfig for VS Code** — Respeta el `.editorconfig` del proyecto

---

## 7. Leer la Documentacion del Proyecto

Antes de empezar a trabajar, lee estos documentos en orden:

| Documento | Que encontraras | Prioridad |
|---|---|---|
| `docs/GDD.md` | Game Design Document — que es el juego, mecanicas, controles | **Obligatorio** |
| `docs/TDD_GODOT_4_6.md` | Technical Design Document — arquitectura, patrones, estructura | **Obligatorio** |
| `docs/CONVENTIONS.md` | Convenciones de codigo, assets, git, commits | **Obligatorio** |
| `docs/ROADMAP.md` | Hoja de ruta, milestones, tareas | Recomendado |
| `docs/GDD_ACCEPTANCE_CHECKLIST.md` | Criterios de aceptacion del GDD | Referencia |

---

## 8. Flujo de Trabajo Git

### 8.1 Crear tu branch de trabajo

```bash
# Asegurate de estar en develop (o main si no existe develop)
git checkout develop
git pull origin develop

# Crear tu branch
git checkout -b feature/tu-feature-aqui

# Ejemplos:
git checkout -b feature/player-movement
git checkout -b fix/enemy-collision-bug
git checkout -b docs/update-tdd
```

### 8.2 Convenciones de commit

Usamos Conventional Commits:

```bash
# Formato
git commit -m "tipo(ambito): descripcion corta en imperativo"

# Ejemplos
git commit -m "feat(player): add basic movement with WASD"
git commit -m "fix(spawner): fix enemy spawning outside map bounds"
git commit -m "art(player): add idle animation sprites"
git commit -m "docs(tdd): update export pipeline section"
```

**Tipos:** `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `chore`, `art`, `audio`

### 8.3 Antes de hacer push

```bash
# Traer cambios remotos
git pull --rebase origin develop

# Verificar que el proyecto abre sin errores
godot -e --path papa-gallo

# Push
git push origin feature/tu-feature-aqui

# Abrir PR en GitHub apuntando a develop
```

### 8.4 Archivos que SI van al repo

- Todo el contenido de `papa-gallo/` EXCEPTO `.godot/` y `exports/`
- Los archivos `.import` (generados por Godot, aseguran consistencia)
- `project.godot`
- Toda la documentacion en `docs/`

### 8.5 Archivos que NO van al repo (ya en .gitignore)

- `papa-gallo/.godot/` — cache del editor, se regenera automaticamente
- `papa-gallo/exports/` — builds exportados
- `.DS_Store`, `Thumbs.db` — archivos del sistema operativo

---

## 9. Tests Basicos

### 9.1 Test manual: verificar que el juego corre

1. Abrir el proyecto en Godot
2. Ejecutar la escena principal (F5)
3. Verificar: sin errores en la consola (Output dock)
4. Verificar: el juego se ve correcto (pixeles nitidos, sin blur)

### 9.2 Test manual: verificar controles

1. Ejecutar el juego
2. Verificar WASD para movimiento
3. Verificar J/K para ataques
4. Verificar Tab para cambiar arma
5. Verificar Shift para esprintar
6. Verificar E para interactuar
7. Si tienes gamepad: verificar todos los botones mapeados

### 9.3 Test manual: verificar export

```bash
# Exportar build de prueba
godot --headless --path papa-gallo --export-debug "Windows Desktop" exports/windows/PapaGallo_test.exe

# Ejecutar el build exportado y verificar que funciona igual que en el editor
```

### 9.4 Escenas de test (para desarrollo)

Crear escenas simples en `papa-gallo/tests/` para probar sistemas aislados:

- `test_player.tscn` — jugador solo en un mapa vacio, probar movimiento
- `test_combat.tscn` — jugador + enemigos, probar combate
- `test_spawner.tscn` — spawner generando enemigos, probar oleadas

Estas escenas NO son parte del juego final, son herramientas de desarrollo.

---

## 10. Troubleshooting

### El proyecto no abre / muestra errores

```bash
# Borrar cache y reimportar
rm -rf papa-gallo/.godot/imported/
godot -e --path papa-gallo
```

### Los sprites se ven borrosos

1. `Project Settings > Rendering > Textures > Canvas Textures > Default Texture Filter` = `Nearest`
2. En cada sprite individual: Import dock > Filter = `false` > Reimport

### Conflictos en archivos .import al hacer merge

Los archivos `.import` son generados. Si hay conflictos:
1. Aceptar cualquier version
2. Borrar `papa-gallo/.godot/imported/`
3. Reabrir Godot — reimportara todo

### Error "Export template not found"

1. `Editor > Manage Export Templates`
2. Click "Download and Install" para la version 4.6
3. Reintentar el export

### El juego corre lento

1. Abrir `Debugger > Monitors` — ver FPS y draw calls
2. Abrir `Debugger > Profiler` — identificar funciones lentas
3. Buscar en la consola warnings de nodos huerfanos o fugas de memoria

---

## 11. Contacto y Comunicacion del Equipo

| Quien | Rol principal |
|---|---|
| Amader | Arte, diseno visual |
| Xoje | Programacion, setup tecnico |
| El Negro | TODO: definir rol principal |

**Canal principal:** TODO: Discord / Slack / WhatsApp
**Gestion de tareas:** TODO: GitHub Issues / Trello / Notion
**Reuniones:** TODO: frecuencia y formato

---

_Documento creado el 2026-03-29. Actualizar cada vez que cambie el setup del proyecto._
