# 📐 Convenciones del Proyecto

**Proyecto:** TODO: NOMBRE DEL JUEGO  
**Última actualización:** TODO: FECHA  
**Versión:** 0.1  

> Este documento define las convenciones mínimas que todo el equipo debe seguir. Su objetivo es mantener coherencia, facilitar la colaboración y reducir la fricción en el flujo de trabajo.

---

## 1. Nomenclatura de Assets (Naming Conventions)

### Regla general

**Formato elegido:** TODO: DECIDIR — Se recomienda `snake_case` para assets y `PascalCase` para clases/scripts.

> La consistencia es más importante que el estilo. Una vez elegido, **todos** deben seguirlo.

### Assets de Arte

| Tipo | Patrón | Ejemplo |
|---|---|---|
| Sprites de personaje | `char_{nombre}_{estado}` | `char_player_idle.png` |
| Sprites de fondo / tileset | `bg_{nombre}` o `tile_{nombre}` | `bg_forest_layer1.png` |
| Elementos de UI | `ui_{elemento}_{estado}` | `ui_button_normal.png`, `ui_button_hover.png` |
| Iconos | `icon_{nombre}` | `icon_heart.png` |
| VFX / partículas | `vfx_{efecto}` | `vfx_explosion.png` |
| Fuentes | `font_{nombre}_{variante}` | `font_main_bold.ttf` |

### Assets de Audio

| Tipo | Patrón | Ejemplo |
|---|---|---|
| Música | `mus_{nombre_pista}` | `mus_main_theme.ogg` |
| SFX — acciones | `sfx_{acción}` | `sfx_jump.wav` |
| SFX — UI | `sfx_ui_{elemento}` | `sfx_ui_click.wav` |
| Voz / Diálogos | `vo_{personaje}_{id}` | `vo_player_hurt_01.wav` |

### Escenas / Niveles

| Tipo | Patrón | Ejemplo |
|---|---|---|
| Niveles de juego | `level_{número}_{nombre}` | `level_01_tutorial` |
| Pantallas de UI | `screen_{nombre}` | `screen_main_menu` |
| Prefabs / Objetos reutilizables | `{nombre_descriptivo}` | `enemy_slime`, `pickup_coin` |

### Scripts / Código

| Tipo | Patrón | Ejemplo |
|---|---|---|
| Clases | `PascalCase` | `PlayerController.cs` |
| Métodos / funciones | `camelCase` o `snake_case` (TODO: DECIDIR) | `getPlayerSpeed()` / `get_player_speed()` |
| Variables | `camelCase` o `snake_case` (consistente con métodos) | `playerSpeed` / `player_speed` |
| Constantes | `UPPER_SNAKE_CASE` | `MAX_PLAYER_SPEED` |
| Archivos de configuración | `snake_case` | `game_config.json` |

---

## 2. Code Style (Estilo de Código)

### Reglas generales

- **Indentación:** TODO: DECIDIR — Tabs o espacios (recomendado: 4 espacios o tab = 4)
- **Longitud máxima de línea:** TODO: DECIDIR — 120 caracteres recomendado
- **Idioma del código:** TODO: DECIDIR — Inglés (recomendado para código, variables, comentarios técnicos)
- **Idioma de los comentarios:** TODO: DECIDIR — Español o Inglés (mantener coherencia)

### Comentarios

- Cada clase/script debe tener un comentario de cabecera que explique su propósito.
- Los métodos públicos deben tener docstring/comentario si su comportamiento no es evidente.
- Evitar comentarios que expliquen QUÉ hace el código (el código mismo debe ser claro). Comentar el POR QUÉ.

```
# ✅ Buen comentario: explica el POR QUÉ
# Usamos un delay de 0.1s aquí porque el motor de física necesita un frame
# para estabilizarse antes de aplicar la fuerza de salto.

# ❌ Mal comentario: explica el QUÉ (obvio)
# Sumamos 1 al contador
counter += 1
```

### Organización de un script

Orden sugerido dentro de un script/clase:

1. Imports / dependencias
2. Constantes de clase
3. Variables exportadas / públicas
4. Variables privadas
5. Métodos del ciclo de vida (_ready, _process, Start, Update, etc.)
6. Métodos públicos
7. Métodos privados

---

## 3. Git — Branching Model

### Branches principales

| Branch | Propósito |
|---|---|
| `main` | Código estable y testeado. Solo merge via PR aprobado. |
| `develop` | Integración de features en desarrollo. Base para trabajo diario. |

### Branches de trabajo

| Tipo | Patrón | Ejemplo |
|---|---|---|
| Feature nueva | `feature/{descripción-corta}` | `feature/double-jump` |
| Bug fix | `fix/{descripción-corta}` | `fix/player-fall-through-floor` |
| Documentación | `docs/{descripción-corta}` | `docs/update-gdd-narrative` |
| Refactoring | `refactor/{descripción-corta}` | `refactor/audio-manager` |
| Release / tag | `release/v{versión}` | `release/v0.3-alpha` |

### Reglas de merging

- **NUNCA hacer push directamente a `main`.**
- Los merges a `main` requieren Pull Request con al menos **1 aprobación** (TODO: ajustar según tamaño del equipo).
- Los merges a `develop` pueden hacerse directamente o via PR (TODO: DECIDIR política del equipo).
- Hacer `git pull --rebase` antes de mergear para mantener historial limpio.

### Formato de mensajes de commit

**Estilo:** TODO: DECIDIR — Se recomienda [Conventional Commits](https://www.conventionalcommits.org/).

```
<tipo>(<ámbito>): <descripción corta en imperativo>

[cuerpo opcional: explica el POR QUÉ, no el QUÉ]

[footer opcional: referencias a issues, breaking changes]
```

**Tipos permitidos:**

| Tipo | Cuándo usarlo |
|---|---|
| `feat` | Nueva feature o mecánica |
| `fix` | Corrección de bug |
| `docs` | Cambios en documentación |
| `refactor` | Refactoring sin cambio de comportamiento |
| `perf` | Mejora de rendimiento |
| `test` | Añadir o corregir tests |
| `chore` | Tareas de mantenimiento (build, deps, etc.) |
| `art` | Añadir o actualizar assets de arte |
| `audio` | Añadir o actualizar assets de audio |

**Ejemplos:**
```
feat(player): add double jump mechanic
fix(audio): fix music loop gap at end of track
docs(gdd): update level design section with level 3
art(player): add walk animation sprites
```

---

## 4. PR Checklist (Pull Request)

Antes de abrir un PR, el autor debe verificar:

### Código
- [ ] El código compila sin errores
- [ ] No hay warnings nuevos introducidos por este PR (o están justificados)
- [ ] El código sigue las convenciones de estilo de este documento
- [ ] No hay código comentado sin explicación, ni `console.log` / `print` de debug sin eliminar
- [ ] TODO: Tests añadidos o actualizados (si el proyecto tiene tests)

### Assets
- [ ] Los assets siguen las convenciones de naming definidas en este documento
- [ ] Los assets están en el directorio correcto
- [ ] No se incluyen assets en formato incorrecto (ej. .jpg para sprites con transparencia)
- [ ] Los archivos de import / .meta están incluidos si aplica

### Documentación
- [ ] Si la feature cambia el GDD o TDD, esos documentos están actualizados
- [ ] El mensaje de commit sigue el formato de Conventional Commits

### Revisión
- [ ] El PR tiene una descripción clara de qué hace y por qué
- [ ] El PR está enlazado al issue o tarea correspondiente (si existe)
- [ ] El PR apunta a la branch correcta (`develop` o `main` según corresponda)

---

## 5. Organización del Repositorio

### Lo que VA al repositorio (git)

- Código fuente
- Assets de arte y audio en sus formatos finales
- Archivos de configuración del proyecto (escenas, prefabs, etc.)
- Archivos .meta / .import (si aplica para el engine)
- Documentación (`/docs/`)
- Scripts de herramientas (`/tools/`)

### Lo que NO va al repositorio (`.gitignore`)

- Carpeta `/exports/` o `/builds/` — los builds se distribuyen por otro canal
- Archivos temporales del sistema (`.DS_Store`, `Thumbs.db`)
- Logs del engine
- Archivos de configuración local del IDE/editor (`.vscode/settings.json` si son personales)
- TODO: otros archivos específicos del engine elegido

---

## 6. Comunicación del Equipo

TODO: Completar con las herramientas elegidas.

| Canal | Herramienta | Propósito |
|---|---|---|
| Chat diario | TODO: Discord / Slack | Comunicación rápida |
| Gestión de tareas | TODO: Trello / Notion / GitHub Issues | Tracking de tareas |
| Reuniones | TODO: frecuencia y formato | Sincronización del equipo |
| Documentación | TODO: este repo / Notion | Docs y decisiones |

---

_Documento generado automáticamente como plantilla. Versión: 0.1 — Revisar y aprobar en equipo antes de empezar producción._
