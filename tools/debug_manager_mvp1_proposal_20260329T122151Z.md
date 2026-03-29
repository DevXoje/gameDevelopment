# Propuesta de Cambio: debug-manager-mvp1

## Propósito
El objetivo de esta propuesta es unificar y refinar las herramientas de depuración dispersas actualmente en el proyecto, resolviendo los TODOs críticos del `DebugManager`. Esto incluye consolidar el Debug HUD, la consola de desarrollo, las hotkeys de debug, y utilidades clave como spawn/next-wave y headless detection. Además, se integrará completamente con el sistema `Logging.write_event` para garantizar trazabilidad.

## Alcance
La propuesta abarca:
1.  **Debug HUD**: Creación de un overlay para información crítica en tiempo real, oculto por defecto.
2.  **Consola de Desarrollo (Dev Console)**: Integración para comandos de prueba.
3.  **Configuración de Hotkeys**: Implementación de las siguientes teclas predeterminadas (acordadas):
    *   `F1`: Activar/Desactivar HUD (Toggle HUD)
    *   `F2`: Forzar siguiente oleada (Next Wave)
    *   `F3`: Generar enemigo (Spawn Enemy)
    *   `F4`: Teletransportar jugador (Teleport Player)
    *   `F5`: Abrir consola de desarrollo (Open Dev Console)
4.  **Headless Detection**: Detección del modo "sin interfaz gráfica" para pruebas automatizadas.
5.  **Logging**: Todo evento de debug debe quedar registrado a través de `Logging.write_event()`.

### Fuera de Alcance
*   Sistemas de profiling avanzado o análisis de memoria profunda (reservado para futuras iteraciones).
*   Herramientas de edición visual de niveles en tiempo real.

## Requisitos Funcionales
1.  **Activación Centralizada**: El sistema de depuración no interferirá con la jugabilidad si no es activado explícitamente (vía `F1` o `F5`).
2.  **Mapeo de Teclas**: Las acciones deben poder ejecutarse sin colisionar con los inputs de gameplay normales.
3.  **Spawn y Wave Control**: Capacidad de saltar oleadas y generar entidades instantáneamente para probar lógicas sin esperar progresos.
4.  **Telemetría de Debug**: Todo uso de herramientas (como teletransportes, saltos de oleada o spawns) enviará un log estandarizado utilizando el sistema `Logging`.
5.  **Protección de Entorno**: En builds de producción reales, los inputs de debug deben estar desactivados (a menos que se active mediante un flag o cheat code).

## Criterios de Aceptación
*   [ ] Presionar `F1` muestra y oculta el Debug HUD sin romper el layout del UI principal.
*   [ ] Presionar `F2` adelanta la oleada, disparando el evento correspondiente en el `LevelManager`/`WaveManager`.
*   [ ] Presionar `F3` y `F4` manipulan exitosamente entidades y la posición del jugador sin crasheos.
*   [ ] Presionar `F5` abre la interfaz de consola para ingresar comandos.
*   [ ] Cada vez que se usa una hotkey de debug, se registra correctamente un mensaje en los logs a través de `Logging.write_event`.
*   [ ] El sistema detecta correctamente si el juego corre en modo "headless" (por ejemplo, en tests CI) y desactiva las actualizaciones visuales del HUD.

## Riesgos y Mitigaciones
*   **Colisión de Inputs**: Riesgo de que F1-F5 colisionen con atajos del SO o del sistema de ventanas.
    *   *Mitigación*: Permitir remapeo si el motor o entorno del usuario tiene conflictos, mantenerlo configurable.
*   **Fugas de rendimiento**: El Debug HUD podría ser pesado de calcular en cada frame.
    *   *Mitigación*: Solo actualizar el HUD si está visible; usar un timer de actualización (ej. 0.1s a 0.5s) en lugar de `_process(delta)` puro en cada frame para UI.
*   **Dependencia Circular**: Que `DebugManager` dependa de managers que a su vez dependen de él.
    *   *Mitigación*: Uso de Señales (Signals) y `Logging.write_event` para comunicación débilmente acoplada.

## Plan de Rollout y Estimaciones

### MVP-1 (Esfuerzo estimado: 3-5 días)
*   Integrar hotkeys base (`F1`-`F5`) utilizando el sistema de inputs de Godot.
*   Implementar el Toggle del Debug HUD con estado guardado.
*   Conectar `F5` a un log básico indicando que "la consola fue llamada".
*   Loggear cada evento usando `Logging.write_event`.
*   Validar la detección Headless.

### MVP-2 (Esfuerzo estimado: 5-8 días)
*   Conectar comandos de `F2`, `F3` y `F4` con la lógica real del juego (Player/Enemy/Wave Managers).
*   Implementación completa de la UI para la consola `F5` con autocompletado básico.
*   Añadir variables de monitoreo de rendimiento y gameplay (FPS, HP, Entidades Activas) en el Debug HUD.

---
**Referencias:**
*   `tools/debug_todos_findings_20260329T120235Z.json`
*   `tools/debug_mvp_proposal_20260329T120235Z.md`
*   `tools/debug_tasks_20260329T120235Z.yaml`
