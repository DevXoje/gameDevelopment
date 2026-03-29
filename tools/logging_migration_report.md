# Reporte de Migración de Logging — papa-gallo

**Fecha:** 2026-03-29  
**Alcance:** `papa-gallo/**/*.gd` — búsqueda recursiva de patrones de logging obsoleto  
**Patrones buscados (case-sensitive):**
- `Logging.log(`
- `_logging.log(`
- `.log("` (llamada `.log(` seguida de `"`)
- `.log((` (llamada `.log(` seguida de `(`)

---

## 1. Resumen Ejecutivo

| Patrón | Ocurrencias encontradas |
|--------|------------------------|
| `Logging.log(` | **0** |
| `_logging.log(` | **0** |
| `.log("` | **0** |
| `.log((` | **0** |
| **Total patrones críticos** | **0** |

> ✅ **No se encontraron llamadas antiguas `log()` en código ejecutable.** La migración a `write_event({...})` fue aplicada previamente en todos los scripts de la base de código.

Sin embargo, la búsqueda exhaustiva identificó **5 hallazgos secundarios** (no críticos) que se documentan a continuación: comentarios de doc obsoletos y un patrón de doble-guard redundante en `round_manager.gd`.

---

## 2. Archivos escaneados

| Archivo | Líneas | Patrones críticos | Hallazgos secundarios |
|---------|--------|-------------------|-----------------------|
| `scripts/autoload/AudioManager.gd` | 139 | 0 | 0 |
| `scripts/autoload/DebugManager.gd` | 109 | 0 | 0 |
| `scripts/autoload/GameManager.gd` | 104 | 0 | 0 |
| `scripts/autoload/InputManager.gd` | — | 0 | 0 |
| `scripts/autoload/Logging.gd` | 338 | 0 | 0 |
| `scripts/autoload/SaveManager.gd` | — | 0 | 0 |
| `scripts/enemy.gd` | 177 | 0 | 1 (tipado débil `_logger`) |
| `scripts/player.gd` | 166 | 0 | 1 (tipado débil `_logger`) |
| `scripts/round_manager.gd` | 206 | 0 | 2 (doble-guard + tipado débil) |
| `scripts/spawner.gd` | 172 | 0 | 0 |
| `tools/smoke_test_enemy.gd` | 379 | 0 | 1 (docstring menciona `log()`) |
| `tools/smoke_test_player.gd` | 183 | 0 | 1 (docstring menciona `log()`) |

---

## 3. Hallazgos secundarios (no críticos)

### Hallazgo A — `tools/smoke_test_player.gd` línea 20

**Tipo:** Comentario de docstring obsoleto  
**Severidad:** 🟡 Baja — no afecta comportamiento, pero confunde a futuros lectores

```
Contexto (líneas 18-22):
─────────────────────────────────────────────────────────────────────────────
 18: ## Nota sobre Logging en modo headless:
 19: ##   El Autoload Logging NO está disponible en scripts headless que extienden SceneTree.
►20: ##   Este script instancia Logging manualmente y llama a start_session() + log() + flush()
 21: ##   para garantizar que los eventos de smoke test se persistan en disco.
 22:
─────────────────────────────────────────────────────────────────────────────

Línea 20 actual:
  ##   Este script instancia Logging manualmente y llama a start_session() + log() + flush()

Reemplazo sugerido:
  ##   Este script instancia Logging manualmente y llama a start_session() + write_event() + flush()
```

---

### Hallazgo B — `tools/smoke_test_enemy.gd` línea 20

**Tipo:** Comentario de docstring obsoleto  
**Severidad:** 🟡 Baja

```
Contexto (líneas 17-21):
─────────────────────────────────────────────────────────────────────────────
 17: ## Nota sobre Logging en modo headless:
 18: ##   El Autoload Logging NO está disponible en scripts headless (extienden SceneTree).
►19: ##   Este script instancia Logging manualmente para garantizar persistencia de eventos.
 20: ##
 21: ## TODO: Añadir check de señales (enemy_spawned, wave_started).
─────────────────────────────────────────────────────────────────────────────
```

> Nota: La línea 19 de `smoke_test_enemy.gd` no menciona `log()` explícitamente, pero la descripción queda incompleta. La referencia a `log()` en este archivo aparece SÓLO en la marca `CHANGED_FOR_LOGGING` (línea 369, comentario interno) que ya es parte de la documentación de migración.

**Línea 369 — sólo informativo:**
```
 368: 	var event := "smoke_test_passed" if passed else "smoke_test_failed"
►369: 	# CHANGED_FOR_LOGGING: convertido de log(level, event, dict) → write_event({dict}) — evita conflicto con builtin GDScript log(float)
 370: 	_logging.write_event({
 371: 		"level": "info" if passed else "error",
```
> Este comentario es útil como registro histórico de migración — se puede preservar o eliminar según la política del equipo.

---

### Hallazgo C — `scripts/round_manager.gd` líneas 112 y 152 — Doble-guard redundante

**Tipo:** Anti-patrón de código (verificación redundante)  
**Severidad:** 🟡 Media — no causa bugs, pero crea inconsistencia con el resto del código

```
Contexto (líneas 110-123 — función start_round()):
─────────────────────────────────────────────────────────────────────────────
 110:
 111: 	# Registrar evento de inicio de ronda.
►112: 	if has_node("/root/Logging"):
►113: 		# CHANGED: safe logging accessor
►114: 		var logger := _get_logger()
►115: 		if logger:
 116: 			logger.write_event({
 117: 				"level": "info",
 118: 				"event": "round_started",
 119: 				"data": {
 120: 					"round": current_round,
 121: 					"spawn_count": enemy_count,
 122: 				},
 123: 			})
─────────────────────────────────────────────────────────────────────────────

Reemplazo sugerido (eliminar doble-guard, usar sólo _get_logger()):
─────────────────────────────────────────────────────────────────────────────
 110:
 111: 	# Registrar evento de inicio de ronda.
►112: 	var logger := _get_logger()
►113: 	if logger:
 114: 		logger.write_event({
 115: 			"level": "info",
 116: 			"event": "round_started",
 117: 			"data": {
 118: 				"round": current_round,
 119: 				"spawn_count": enemy_count,
 120: 			},
 121: 		})
─────────────────────────────────────────────────────────────────────────────
```

**Ocurre también en líneas 150-165 — función stop_round():**
```
Contexto (líneas 150-165):
─────────────────────────────────────────────────────────────────────────────
 150:
 151: 	# Registrar evento de fin de ronda.
►152: 	if has_node("/root/Logging"):
►153: 		# CHANGED: safe logging accessor
►154: 		var logger := _get_logger()
►155: 		if logger:
 156: 			logger.write_event({
 157: 				"level": "info",
 158: 				"event": "round_ended",
 159: 				"data": {
 160: 					"round": current_round,
 161: 					"duration_s": snappedf(duration, 0.01),
 162: 					"enemies_remaining": _spawner.get_active_count() if (...) else -1,
 163: 				},
 164: 			})
─────────────────────────────────────────────────────────────────────────────

Reemplazo sugerido:
─────────────────────────────────────────────────────────────────────────────
 150:
 151: 	# Registrar evento de fin de ronda.
►152: 	var logger := _get_logger()
►153: 	if logger:
 154: 		logger.write_event({
 155: 			"level": "info",
 156: 			"event": "round_ended",
 157: 			"data": {
 158: 				"round": current_round,
 159: 				"duration_s": snappedf(duration, 0.01),
 160: 				"enemies_remaining": _spawner.get_active_count() if (...) else -1,
 161: 			},
 162: 		})
─────────────────────────────────────────────────────────────────────────────
```

---

### Hallazgo D — Tipado débil de `_logger` en tres scripts

**Tipo:** Calidad de código — tipado débil  
**Severidad:** 🟢 Baja — funciona correctamente, pero GDScript no puede hacer autocomplete/type checking

| Archivo | Línea | Código actual | Código sugerido |
|---------|-------|---------------|-----------------|
| `scripts/enemy.gd` | 56 | `var _logger = null` | `var _logger: Node = null` |
| `scripts/player.gd` | 44 | `var _logger = null` | `var _logger: Node = null` |
| `scripts/round_manager.gd` | 71 | `var _logger = null` | `var _logger: Node = null` |

---

## 4. Conclusión

El codebase de `papa-gallo` **no contiene ninguna llamada ejecutable al patrón legacy `log()`** para logging. Todos los puntos de registro ya usan la API correcta:

```gdscript
# ✅ Patrón correcto en uso — todos los scripts
_logger.write_event({"level": "info", "event": "...", "data": {...}})
Logging.write_event({"level": "info", "event": "...", "data": {...}})
_logging.write_event({"level": "info", "event": "...", "data": {...}})
```

Los 5 hallazgos identificados son mejoras de calidad opcionales. Ver `tools/logging_migration_patch.diff` para el parche sugerido.

---

*Generado por: análisis estático exhaustivo — sin modificaciones aplicadas*
