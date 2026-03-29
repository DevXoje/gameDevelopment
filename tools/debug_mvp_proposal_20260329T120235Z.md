# Propuesta MVP — Debug Autoload & In-Game Tooling

**Proyecto:** gameDevelopment / papa-gallo  
**Fecha:** 2026-03-29  
**Autor:** sdd-explore sub-agent  
**Versión:** 1.0 — Borrador para revisión del equipo  
**Artefacto relacionado:** `tools/debug_todos_findings_20260329T120235Z.json`

---

## Contexto y Estado Actual

El `DebugManager.gd` es un Autoload registrado en Godot con una estructura sólida:
- Guarda correctamente en `_is_debug = OS.is_debug_build()` y usa guards `if not _is_debug: return`
- Tiene el esqueleto de 4 funciones: `debug_next_wave()`, `debug_spawn_enemy()`, `debug_teleport_player()`, `print_state()`
- **Pero todas las funciones están vacías o solo imprimen "TODO: implementar"**

El `Logging.gd` está completamente implementado y ofrece `write_event()` para persistir eventos en JSON-lines. El CI ejecuta smoke tests headless con Godot 4.6. La integración entre DebugManager y Logging no existe aún.

---

## Hallazgos Clasificados por Categoría

### Categoría 1: Autoload DebugManager (9 findings)

| ID | TODO | Prioridad | Esfuerzo |
|---|---|---|---|
| DM-001 | Debug HUD overlay (FPS, posición, ronda) | Alta | 2-3h |
| DM-002 | Hotkeys de teclado (F1-F5) | Alta | 1-2h |
| DM-003 | Registro de InputEventKey en InputMap | Alta | 1h |
| DM-004 | Implementar debug_spawn_enemy() real | Alta | 30min-1h |
| DM-005 | Implementar debug_teleport_player() | Media | 30min |
| DM-006 | Decisión: HUD togglable vs siempre visible | Alta | 5min decisión |
| DM-007 | Integrar Logging.write_event() en todas las acciones | Media | 30min |
| DM-008 | Toggle flags headless vs GUI | Media | 30min |
| DM-009 | print_verbose_state() — inspector de sesión | Baja | 1h |

### Categoría 2: tools/smoke_tests (4 findings)

| ID | TODO | Prioridad | Esfuerzo |
|---|---|---|---|
| SE-001 | Check de señales enemy_spawned/wave_started | Media | 1-2h |
| SE-002 | Check de stop_distance con enemigo muy cerca | Baja | 45min |
| SE-003 | Integrar con CI/CD (posiblemente ya resuelto) | Baja | 30min |
| SP-001 | Verificación de colisión en smoke_test_player | Baja | 3-5h |
| SP-002 | Integrar smoke_test_player en CI headless | Baja | 30min |

### Categoría 3: CI (3 findings)

| ID | TODO | Prioridad | Esfuerzo |
|---|---|---|---|
| CI-001 | Test que valide _is_debug==false en release | Baja | 1-2h |
| SP-002 | Consolidar archivos duplicados smoke_test_player | Baja | 30min |
| SE-003 | Verificar que run_all_tests.sh incluye ambos tests | Baja | 30min |

### Categoría 4: docs (2 findings)

| ID | TODO | Prioridad | Esfuerzo |
|---|---|---|---|
| DOC-001 | Actualizar sección DebugManager en TDD_GODOT_4_6.md | Baja | 30min |
| DOC-002 | Añadir columna Estado en tabla de Autoloads | Baja | 15min |

---

## Propuesta MVP por Categoría

### MVP-1: DebugManager Funcional con Hotkeys (Prioridad Alta)

**Alcance:**
- Implementar `_register_debug_actions()` con 5 hotkeys (F1-F5)
- Implementar `debug_spawn_enemy()` con carga real de escena
- Implementar `debug_teleport_player()` usando grupo 'player'
- Añadir detección headless (`_is_headless`) para saltear GUI-only features
- Añadir `Logging.write_event()` en cada acción de debug

**Criterios de aceptación:**
- [ ] Presionar F2 en una escena de juego avanza a la siguiente oleada (GameManager.end_round() + start_round())
- [ ] Presionar F3 instancia un Enemy.tscn en la posición actual del jugador
- [ ] Presionar F4 teletransporta al jugador a Vector2(0,0)
- [ ] En builds de release, ninguna de las acciones anteriores tiene efecto ni están registradas en el InputMap
- [ ] En modo headless (smoke tests), DebugManager no genera errores al cargar
- [ ] Cada acción de debug genera un evento en el log JSON-lines de Logging

**Archivos a modificar:**
- `papa-gallo/scripts/autoload/DebugManager.gd`

**Tests a añadir:**
- Smoke test inline que verifique que en headless, `debug_next_wave()` no lanza errores
- Verificar en CI que DebugManager carga correctamente en headless

**Esfuerzo estimado:** 4-6 horas (1 sesión de trabajo)

---

### MVP-2: Debug HUD Overlay (Prioridad Media)

**Alcance:**
- Crear escena `papa-gallo/scenes/ui/debug_hud.tscn` (CanvasLayer > VBoxContainer > Labels)
- Instanciar dinámicamente desde DebugManager._ready() si _is_debug == true y no headless
- Toggle con F1: mostrar/ocultar
- Mostrar: FPS, posición del jugador (si está en escena), ronda actual, session_id del Logging

**Criterios de aceptación:**
- [ ] Presionar F1 muestra/oculta el debug HUD en pantalla
- [ ] El HUD muestra FPS actualizado en tiempo real (cada segundo)
- [ ] El HUD muestra la posición global del primer nodo en el grupo 'player' (o "N/A" si no existe)
- [ ] El HUD muestra el número de ronda actual desde GameManager
- [ ] El HUD muestra el session_id de Logging para correlacionar con logs
- [ ] El HUD NO aparece en builds de release (OS.is_debug_build() == false)
- [ ] El HUD NO interfiere con el input de juego normal

**Archivos a crear/modificar:**
- `papa-gallo/scenes/ui/debug_hud.tscn` (nuevo)
- `papa-gallo/scripts/ui/debug_hud.gd` (nuevo)
- `papa-gallo/scripts/autoload/DebugManager.gd` (añadir instanciación del HUD)

**Tests a añadir:**
- Verificar que debug_hud.tscn existe como recurso (puede añadirse a smoke tests)

**Esfuerzo estimado:** 2-3 horas

---

### MVP-3: Verbose Session Inspector (Prioridad Baja)

**Alcance:**
- Añadir función `print_verbose_state()` en DebugManager
- Dump completo de todos los autoloads en consola y en Logging
- Hotkey F5 para trigger

**Criterios de aceptación:**
- [ ] Presionar F5 imprime en consola el estado de GameManager, Logging, SaveManager
- [ ] El dump incluye: round, is_running, puntos, session_id, log_path, has_save(0)
- [ ] El evento se registra en Logging con event='debug_verbose_state'
- [ ] En headless, print_verbose_state() funciona (solo print, sin GUI)

**Archivos a modificar:**
- `papa-gallo/scripts/autoload/DebugManager.gd`

**Esfuerzo estimado:** 1 hora

---

### MVP-4: Consolidar y Verificar CI/Smoke Tests (Prioridad Baja)

**Alcance:**
- Verificar que `tools/run_all_tests.sh` incluye ambos smoke tests
- Consolidar duplicado de `smoke_test_player.gd` (en raíz vs. en papa-gallo/tools/)
- Marcar SE-003 como DONE si ya está integrado

**Criterios de aceptación:**
- [ ] `tools/run_all_tests.sh` ejecuta smoke_test_player.gd y smoke_test_enemy.gd
- [ ] No hay archivos smoke_test duplicados (uno en /tools/, otro en /papa-gallo/tools/)
- [ ] El CI verifica ambos tests y sube los logs

**Esfuerzo estimado:** 1 hora

---

## Preguntas Abiertas para el Equipo (Ambiguities)

> Estas preguntas deben resolverse ANTES de comenzar la implementación. Ver finding DM-006.

1. **¿Qué hotkeys usar para los debug actions?**
   - Propuesta: F1=HUD toggle, F2=next wave, F3=spawn enemy, F4=teleport to (0,0), F5=verbose dump
   - Alternativa: Ctrl+D combo en lugar de F-keys (menos probable de colisionar con otras apps)
   - **Decisión necesaria:** ¿F-keys o Ctrl+combos?

2. **¿El debug HUD debe ser visible por defecto al iniciar en modo debug o solo al presionar F1?**
   - Propuesta: oculto por defecto, visible al presionar F1
   - Alternativa: visible siempre en debug builds
   - **Decisión necesaria:** ¿visible por defecto o togglable?

3. **¿Qué tipo de enemigo spawneará F3 por defecto?**
   - El código tiene `enemy_type: String = "zombie"` como default
   - Requiere que exista `res://scenes/enemies/enemy_zombie.tscn` o similar
   - **Decisión necesaria:** ¿Nombre exacto de la escena del enemigo (Enemy.tscn, enemy_zombie.tscn, enemy.tscn)?

4. **¿Las acciones de debug (F-keys) deben registrarse en project.godot o solo en runtime?**
   - Propuesta: solo en runtime via `InputMap.add_action()` en DebugManager._register_debug_actions()
   - Esto garantiza que NO aparecen en el InputMap de release builds
   - **Decisión necesaria:** ¿Confirmar enfoque runtime vs. project.godot?

---

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Enemy.tscn no existe con el path esperado | Media | Alto | Verificar path exacto antes de implementar DM-004 |
| Hotkeys F1-F5 colisionan con shortcuts del editor Godot | Baja | Bajo | Solo activas en game runtime, no en editor |
| DebugManager HUD impacta performance en builds debug | Baja | Bajo | Actualizar HUD solo cada segundo con Timer, no cada frame |
| Código de debug llega a build de release por error | Muy baja | Alto | El guard `if not _is_debug: return` ya existe; añadir CI test |
| Duplicación de smoke_test_player.gd causa confusión de cuál es el canónico | Media | Medio | Consolidar en una PR dedicada como primero de los fixes |

