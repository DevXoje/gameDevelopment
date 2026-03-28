# 🎮 Game Design Document (GDD)

> **Actualizado desde docs/NOSOTROS.md — revisar y validar (fecha: 2026-03-28, autor: integración automática desde NOSOTROS.md)**

**Título del Juego:** TODO: NOMBRE DEL JUEGO  
**Autor/es:** TODO: NOMBRE DEL EQUIPO  
**Versión:** 0.2 — Integración de contenido desde NOSOTROS.md  
**Fecha:** 2026-03-28  
**Estado:** En elaboración  

---

## 1. Resumen Ejecutivo

Juego de supervivencia por rondas con vista top-down 2D y combate cuerpo a cuerpo de estilo medieval. Cada ronda aparecen oleadas de enemigos que entran por puntos fijos del mapa y persiguen al jugador. Eliminar enemigos otorga puntos que se pueden gastar para desbloquear nuevas zonas del mapa (con más entradas de enemigos) o para adquirir armas mejores. Las rondas son infinitas y escalan en dificultad progresivamente (más enemigos, más resistentes). La propuesta de valor central es el loop "aguanta todo lo que puedas" con conocimiento creciente de las mecánicas para superar el récord propio.

---

## 2. Elevator Pitch

> Es como los Zombies de Call of Duty Black Ops 1 pero en 2D con vista top-down y con armas medievales (espadas, etc.) en vez de armas de fuego.

---

## 3. Plataformas Objetivo

| Plataforma | Prioridad | Notas |
|---|---|---|
| PC | Alta | Plataforma principal |
| TODO: Nintendo Switch | Baja | A evaluar post-lanzamiento |
| TODO: Mobile (iOS/Android) | Baja | A evaluar post-MVP |

---

## 4. Público Objetivo

- **Perfil:** Jugadores que disfrutan de superarse cada partida y llegar más lejos al conocer cada vez mejor las mecánicas del juego.
- **Edad:** TODO: rango de edad (ej. 16-50años)
- **Géneros de referencia:** Survival horde, roguelite, acción top-down
- **Juegos de referencia (competencia/inspiración):** Call of Duty Zombies (Black Ops 1), Enter the Gungeon, Nuclear Throne

---

## 5. Scope — MVP vs. Versión Completa

### 5.1 MVP (Producto Mínimo Viable)

El MVP debe ser jugable, autocontenido y representativo de la propuesta de valor central.

- [ ] Un mapa con dos o tres zonas desbloqueables
- [ ] Al menos tres o cuatro armas: dos con estilo de combate distinto y dos más potentes pero más caras
- [ ] Dos tipos de enemigos: uno normal (lento, tipo zombie) y uno más rápido que aparece ocasionalmente
- [ ] Sistema de vida: el jugador aguanta 3 golpes como máximo; al pasar 1 minuto sin recibir daño, se cura un punto de vida
- [ ] TODO: Sistema de puntos funcional (obtención al eliminar enemigos y gasto en zonas del mapa)

### 5.2 Versión Completa (Full Release)

- TODO: Más mapas y zonas desbloqueables
- TODO: Más tipos de enemigos y jefes de ronda
- TODO: Más variedad de armas y sistema de mejoras
- TODO: Tabla de puntuaciones / leaderboard

### 5.3 Fuera de Scope (explícitamente excluido)

- TODO: Multijugador online en v1
- TODO: Historia / narrativa extensa (el juego es arcade puro)

---

## 6. Mecánicas Principales

### 6.1 Mecánica Core (Loop Principal)

1. **Inicio de ronda:** Aparece una oleada de enemigos que entran por puntos fijos del mapa y persiguen al jugador.
2. **Combate:** El jugador elimina enemigos con armas cuerpo a cuerpo; cada muerte otorga puntos.
3. **Gasto de puntos:** Entre o durante rondas, el jugador puede desbloquear zonas del mapa o comprar armas mejores.
4. **Escalado:** Cada ronda aumenta el número de enemigos y su resistencia.
5. **Fin de partida:** El jugador pierde cuando recibe demasiado daño; el objetivo es sobrevivir el mayor número de rondas posible.

### 6.2 Mecánicas Secundarias

| Mecánica | Descripción | Prioridad |
|---|---|---|
| Zonas desbloqueables | Gastar puntos para abrir nuevas áreas del mapa (más espacio pero más entradas de enemigos) | Alta |
| Tipos de terreno | Distintos terrenos modifican la velocidad de movimiento del jugador y de los enemigos | Media |
| Curación por tiempo | Al pasar 1 minuto sin recibir daño, se recupera 1 punto de vida | Alta |
| Stamina | Atacar y esprintar consume estamina; gestión de recurso clave | Alta |
| Armas situacionales | Algunas armas son más eficaces en determinadas situaciones (rango, velocidad, daño en área) | Media |

### 6.3 Verbos del Jugador

- **Moverse** (WASD / stick izquierdo)
- **Atacar** (ataque principal y ataque secundario)
- **Esprintar** (consume estamina)
- **Cambiar de arma**
- **Interactuar** (gastar puntos en zonas de compra/desbloqueo)

---

## 7. Reglas y Sistemas

### 7.1 Reglas Fundamentales

- El jugador puede recibir un máximo de 3 golpes antes de morir.
- Al transcurrir 1 minuto sin recibir daño, se recupera 1 punto de vida.
- Los enemigos siempre entran por puntos fijos del mapa y persiguen al jugador.
- Cada ronda aumenta el número de enemigos y su resistencia.
- Los puntos se obtienen al eliminar enemigos.

### 7.2 Condición de Victoria

El juego no tiene fin: el objetivo es sobrevivir el máximo número de rondas posible y superar el récord personal (y, en el futuro, el de otros jugadores).

### 7.3 Condición de Derrota

El jugador pierde cuando recibe el cuarto golpe (agota sus 3 puntos de vida). Se muestra la ronda alcanzada y los puntos obtenidos.

---

## 8. Progresión del Jugador

### 8.1 Estructura de Progresión

Progresión dentro de la partida: el jugador acumula puntos, desbloquea zonas y mejora su arsenal. No hay progresión persistente entre partidas en el MVP (cada partida empieza desde cero). 

### 8.2 Curva de Dificultad

Escalado lineal de dificultad por ronda: más enemigos y mayor resistencia en cada oleada sucesiva. El jugador compensa con mejores armas y conocimiento del mapa.

```
Dificultad
  ^
  |                          /-----
  |                    /----
  |              /----
  |         /---
  |    /----
  |---/
  +---------------------------------> Ronda
   R1   R3   R5   R7   R10  R15  ...
```

### 8.3 Sistemas de Recompensa

- **Puntos:** Moneda de progresión dentro de la partida.
- **Desbloqueo de zonas:** Amplía el mapa disponible.
- **Armas mejores:** Aumentan las opciones tácticas del jugador.

---

## 9. Economía del Juego

Los puntos son la única moneda del juego. Se obtienen exclusivamente eliminando enemigos y se gastan en zonas especiales del mapa para:

| Recurso | Cómo se obtiene | Cómo se gasta | Límite |
|---|---|---|---|
| Puntos | Eliminar enemigos | Desbloquear zonas / Comprar armas | Sin límite (acumulables) |

**Modelo de monetización:** Premium (pago único).

---

## 10. Controles y HUD

### 10.1 Esquema de Controles

#### Teclado
| Acción | Tecla |
|---|---|
| Moverse | WASD |
| Ataque principal | J | 
| Ataque secundario | K | 
| Cambiar de arma | Tab | 
| Esprintar | Shift | 
| Interactuar (zonas de compra) | E | 
| Menú pausa | Escape |

#### Mando (Gamepad) — Compatibilidad completa
| Acción | Botón |
|---|---|
| Moverse | Stick izquierdo |
| Ataque principal | RB | 
| Ataque secundario | RT |
| Cambiar de arma | Y |
| Esprintar | B |
| Interactuar | A |

### 10.2 HUD (Heads-Up Display)

Los siguientes elementos se muestran en pantalla durante el juego:

- **Vida del jugador:** Indicador de los puntos de vida actuales (máx. 3).
- **Arma equipada:** Nombre o icono del arma actualmente en uso.
- **Ronda actual:** Número de ronda en curso.
- **Indicador de puntos acumulados**.
- **Barra de estamina**.

---

## 11. UI/UX — Flujo de Pantallas

TODO: Describir el flujo de navegación de menús/pantallas. Puedes usar un diagrama de texto.

Descripción: Menú con botones jugar y salir. Jugar inicia la partida. El menu escape en partida solo tiene la opción de salir, y pausa la partida mientras está activo.

```
[Inicio/Splash] → [Menú Principal]
                        |
              ┌─────────┼─────────┐
           [Jugar]  [Opciones] [Créditos]
              |
          [Gameplay — Ronda activa]
              |
         [Pausa] → [Continuar / Menú Principal / Reiniciar]
              |
          [Game Over — Pantalla de resultados: ronda alcanzada + puntos]
```


---

## 12. Narrativa (si aplica)

El juego es arcade puro sin narrativa explícita en el MVP. Si se incorpora contexto narrativo (ambientación medieval, razón de los ataques, etc.) se documentará aquí en versiones futuras.



---

## 13. Level Design — Plantilla de Niveles

> El juego tiene un único mapa en el MVP con zonas desbloqueables. Usa esta plantilla para documentar cada zona/mapa adicional.

### Mapa 1 (MVP): El castillo 

- **Número de zonas desbloqueables:** 2 o 3
- **Bioma/Tema visual:** 
- **Puntos de entrada de enemigos:** Fijos por zona; se añaden al desbloquear nuevas zonas
- **Zonas de compra/interacción:** Puntos donde gastar puntos para armas o desbloquear zonas
- **Mecánicas introducidas:** Loop principal completo
- **Notas de diseño:**: Algunos terrenos hacen que ciertos tipos de arma sean más eficaces. POr ejemplo, hierba alta que no deja pasar flechas, pasillo estrecho que pone a los enemigos en fila para ser atravesados. 

---

## 14. Art Style y Referencias Visuales

### 14.1 Estilo Visual

2D top-down. Pixel-art 

**Paleta de colores principal:** A0DDD3,6FB0B7,577F9D,4A5786,3E3B66,2D1E2F,452E3F,5D4550,7B6268,9C807E,C3A79C,DBC9B4,FCECD1,AAD795,64B082,488885,3F5B74,EBC8A7,D3A084,B87E6C,8F5252,6A3948,C57F79,AB597D,7C3D64,4E2B45,7A3B4F,A94B54,D8725E,F09F71,F7CF91 

### 14.2 Referencias Visuales

| Referencia | Por qué la usamos |
|---|---|
| Call of Duty Zombies (Black Ops 1) | Referencia de gameplay y atmósfera de tensión creciente |

### 14.3 Personajes — Guía Visual

El personaje es un guerrero al que se le ve claramente que ha tenido días mejores, un ser cambiado por la guerra. Ahora sus amigos son zombies y los tiene que matar, pero es tan duro que lo puede hacer.

---

## 15. Sonido y Mood

### 15.1 Mood / Atmósfera

El jugador siente el poder del guerrero, pero a la vez, no es dificil deducir que en algun momento morira debido al limitado espacio y el numero creciente de enemigos

### 15.2 Referencias Sonoras

| Referencia | Tipo | Por qué |
|---|---|---|
| Neon White | Música | TODO |
| Sangrientos | Efectos SFX | TODO |

### 15.3 Diseño de Sonido

- **Música dinámica:** Sí, según la vida, y según la cantidad de enemigos. 
- **SFX principales:** Simples, prototipescos 

---

## 16. Métricas y KPIs

TODO: Define cómo medirás el éxito del juego. Aplica tanto en playtest como post-launch.

| Métrica | Objetivo | Cómo medirla |
|---|---|---|
| Ronda media alcanzada en playtest | TODO: definir baseline | Observación directa |
| Tiempo de sesión medio | TODO: >15 min | Analytics |
| Retención D1 / D7 | TODO: X% / Y% | Backend |
| TODO: Métrica adicional | TODO | TODO |

---

## 17. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Scope creep en tipos de enemigos y armas | Media | Alta | Mantener MVP estricto (2 enemigos, 3-4 armas); revisión semanal |
| Loop de rondas repetitivo y poco variado | Media | Crítica | Prototipo jugable temprano; playtest con jugadores externos |
| Desequilibrio en economía de puntos | Media | Alta | Ajuste numérico iterativo en playtests |
| Performance en mapas con muchos enemigos | Baja | Media | Profiling temprano; decidir límite de enemigos por ronda |
| TODO: Riesgo adicional | TODO | TODO | TODO |

---

## 18. MVP Checklist — Criterios de Aceptación

> El MVP está listo cuando todos estos ítems están marcados.

- [ ] Loop de rondas funcional (spawn de enemigos, persecución, escalado por ronda)
- [ ] Sistema de puntos funcional (obtención y gasto)
- [ ] Mapa con 2-3 zonas desbloqueables operativas
- [ ] Al menos 3-4 armas implementadas con comportamientos distintos
- [ ] 2 tipos de enemigos (lento/normal y rápido/ocasional)
- [ ] Sistema de vida (3 golpes máx., curación por tiempo)
- [ ] Stamina para ataques y esprint
- [ ] HUD con vida, arma equipada y ronda actual
- [ ] Controles con teclado y compatibilidad con mando
- [ ] Sin bugs bloqueantes durante 30 min de juego continuo
- [ ] Build exportable a PC
- [ ] Playtest con al menos 3 personas externas completado

---

