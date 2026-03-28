# 🎯 Guía de Playtests

Este directorio contiene toda la documentación relacionada con los playtests del proyecto **TODO: NOMBRE DEL JUEGO**.

---

## ¿Qué es un Playtest?

Un playtest es una sesión estructurada en la que personas —internas al equipo o externas— juegan una versión del juego con el objetivo de validar hipótesis de diseño, identificar problemas de usabilidad y recoger métricas de experiencia.

**Regla de oro:** Durante un playtest externo, los desarrolladores **no intervienen ni explican**. El objetivo es observar qué hace el jugador de forma natural.

---

## Cuándo hacer un Playtest

| Momento | Tipo | Objetivo |
|---|---|---|
| Post-MVP | Interno (equipo) | Validar que la mecánica core es divertida |
| Post-MVP + 1 semana | Externo (3-5 personas) | Detectar problemas de onboarding |
| Alpha | Externo (10+ personas) | Balance de dificultad y progresión |
| Beta | Abierto o semi-abierto | Bug hunting y polish final |

---

## Cómo Ejecutar un Playtest

### Antes del Playtest (Preparación)

1. **Definir el objetivo:** ¿Qué queremos aprender de esta sesión? (ej. "¿Entienden los jugadores la mecánica de gravedad en el primer nivel?")
2. **Preparar el build:** Exportar una build estable específicamente para el playtest. Etiquetar con versión (ej. `v0.3-playtest`).
3. **Preparar el entorno:** PC/consola lista, grabación de pantalla activada (con permiso del tester), formulario de feedback listo.
4. **Briefing mínimo al tester:** Solo decir el género del juego y darles el control. No explicar mecánicas a menos que sea un test de tutorial.
5. **Preparar el formulario de observación** (usar `playtest-template.md` como base).

### Durante el Playtest

1. **Observar en silencio.** Anotar todo lo que el jugador hace y dice.
2. **Usar el protocolo "Think Aloud"** si el tester lo acepta: pedirle que verbalice sus pensamientos en voz alta.
3. **No intervenir** si el jugador se atasca — anotar dónde y cuánto tiempo tardó.
4. **Registrar métricas clave:** tiempo en cada sección, muertes, puntos de abandono.

### Después del Playtest

1. **Entrevista post-sesión (5-10 min):** Preguntar al tester sobre su experiencia general, qué le gustó y qué no.
2. **Rellenar el informe** usando `playtest-template.md` dentro de las 24h de la sesión.
3. **Compartir con el equipo** en la próxima reunión.
4. **Priorizar hallazgos** y añadir tickets/tareas a la lista de pendientes.

---

## Estructura de Archivos de este Directorio

```
docs/PLAYTESTS/
├── README.md                    ← Este archivo (guía general)
├── playtest-template.md         ← Plantilla base para cada sesión
├── YYYY-MM-DD-playtest-N.md     ← Informe de playtest (usar la plantilla)
└── assets/                      ← Capturas, grabaciones, datos exportados
```

**Nombrado de archivos:** `YYYY-MM-DD-playtest-N.md` donde N es el número secuencial.  
_Ejemplo: `2025-03-15-playtest-01.md`_

---

## Métricas Estándar a Recoger

En cada playtest, intentar registrar al menos:

- **Tiempo hasta primera muerte** (si aplica)
- **Tiempo total de sesión**
- **Número de muertes / reinicios**
- **Niveles completados vs. abandonados**
- **Puntos de confusión / atasco** (dónde se detiene el jugador)
- **Rating de diversión (1-10)** reportado por el tester
- **Rating de dificultad (1-10)** reportado por el tester

---

## Criterios de Severidad de Hallazgos

| Severidad | Descripción | Acción |
|---|---|---|
| 🔴 Crítico | El jugador no puede avanzar / crash | Fix antes del próximo playtest |
| 🟠 Alto | El jugador se atasca >2 min o quiere abandonar | Fix en el milestone actual |
| 🟡 Medio | Fricción notable pero superable | Planificar fix en siguiente milestone |
| 🟢 Bajo | Sugerencia de mejora o polish | Backlog / post-launch |

---

_Actualizar este README si cambia el proceso de playtests._
