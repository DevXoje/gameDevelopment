# Agenda — Reunión de Validación GDD v0.2

> **Duración:** 45 minutos  
> **Objetivo:** Revisar y validar el GDD actualizado, confirmar las decisiones críticas y cerrar los TODOs prioritarios  
> **Resultado esperado:** GDD v0.3 marcado como "aprobado para implementar" o lista de cambios requeridos antes de aprobación

---

## Roles

| Rol | Responsabilidad | Persona asignada |
|---|---|---|
| **Moderador** | Conduce la agenda, gestiona tiempos, da la palabra | _A designar (sugerido: Director de Proyecto)_ |
| **Scribe** | Toma notas, registra decisiones y acuerdos | _A designar_ |
| **Decision Owner — Diseño** | Propietario de mecánicas, controles y flujo UX | _A designar_ |
| **Decision Owner — Arte** | Propietario de estilo visual, paleta, personajes, sonido | _A designar_ |
| **Decision Owner — Tech** | Propietario de plataformas, controles técnicos, scope técnico | _A designar_ |

---

## Pre-lectura Obligatoria (antes de la reunión)

Todos los participantes deben leer:
1. **`docs/GDD.md`** — Versión actual completa (~15 min de lectura)
2. **`docs/GDD_CHANGE_SUMMARY.md`** — Resumen de cambios respecto al backup (~5 min)
3. **`docs/GDD_ACCEPTANCE_CHECKLIST.md`** — Checklist de aceptación (~2 min)

---

## Agenda Detallada

### [00:00–05:00] Apertura y contexto (5 min)
- **Quién:** Moderador
- **Objetivo:** Alinear al equipo sobre el propósito de la reunión
- **Puntos:**
  - Qué es el GDD y por qué validarlo ahora
  - Reglas de la reunión (decisiones = registradas en el acta; TODO sin cierre queda como deuda)
  - Recordar formato: decidir o posponer con fecha

---

### [05:00–10:00] Identidad del proyecto (5 min)
- **Quién:** Moderador + equipo
- **Decision Owner:** Diseño
- **Decisiones a tomar:**
  - **D1:** ¿Cuál es el nombre definitivo del juego?
  - **D2:** ¿Cuáles son los autores/equipo oficiales?
  - **D3:** ¿El rango de edad objetivo es 16-35 o 16-50?

---

### [10:00–20:00] Mecánicas y controles (10 min)
- **Quién:** Moderador + Decision Owner Diseño + Tech
- **Decisiones a tomar:**
  - **D4:** ¿Se aprueban los controles de teclado definidos? (J/K/Tab/Shift/E)
  - **D5:** ¿Se aprueban los controles de mando definidos? (RB/RT/Y/B/A)
  - **D6:** ¿El indicador de puntos va en HUD permanente o solo en zonas de compra?
  - **D7:** ¿La barra de stamina va en HUD? ¿Qué formato? (barra, número, icono)

---

### [20:00–28:00] Arte, audio y mood (8 min)
- **Quién:** Moderador + Decision Owner Arte
- **Decisiones a tomar:**
  - **D8:** ¿Se confirma Pixel-art como estilo visual definitivo?
  - **D9:** ¿La paleta de 31 colores hex está aprobada? ¿Cómo se mapean a categorías (UI, fondo, personaje, enemigos)?
  - **D10:** ¿Se confirman Neon White (música) y Sangrientos (SFX) como referencias sonoras? ¿Por qué Sangrientos?

---

### [28:00–36:00] Scope, economía y modelo de negocio (8 min)
- **Quién:** Moderador + Decision Owner Diseño + Tech
- **Decisiones a tomar:**
  - **D11:** ¿El modelo de monetización es definitivamente Premium (pago único)?
  - **D12:** ¿El nombre del mapa "El Castillo" es definitivo? ¿Se aprueba el enfoque de terrenos (hierba alta, pasillos)?

---

### [36:00–43:00] Review del checklist de aceptación (7 min)
- **Quién:** Todos
- **Objetivo:** Recorrer el `GDD_ACCEPTANCE_CHECKLIST.md` ítem por ítem y marcar los que aplican
- **Resultado:** ¿El GDD está listo para implementar o requiere cambios?

---

### [43:00–45:00] Cierre y próximos pasos (2 min)
- **Quién:** Moderador + Scribe
- **Acciones:**
  - Scribe lee las decisiones registradas (checklist rápido)
  - Se asigna quién actualiza el GDD con las decisiones
  - Se define fecha de próxima revisión o próximo hito (TDD, prototipo)

---

## Decisiones Esperadas al Final de la Reunión

Al concluir, el equipo debe haber resuelto como mínimo:

- [ ] Nombre del juego definido: PapaGallo
- [ ] Nombre del equipo/autores definido: Amader y Xoje y El Negro
- [ ] Controles (teclado y mando) aprobados o modificados: Aprobados
- [ ] Modelo de monetización confirmado: Confirmado
- [ ] Estilo visual y paleta aprobados o con observaciones: Estilo visual y paleta aprobados, encaja los colores segun te parezca para los distintos elementos
- [ ] GDD marcado como: **Aprobado para implementar** / **Requiere revisión** / **En espera de información** Aprobado para implementar

---

## Materiales en la Reunión

- Pantalla compartida con `docs/GDD.md`
- Documento de acta (Google Docs / Notion / Markdown) para el Scribe
- `docs/GDD_ACCEPTANCE_CHECKLIST.md` abierto para marcar en tiempo real
