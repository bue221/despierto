---
version: 1
slug: "main-swift"
primary_target: "main.swift"
related_targets: []
---

Scope: el panel de la barra de menú de Despierto (main.swift). Mode: Operate.
Audience/job: alguien a mitad de una sesión con Claude Code que se va a por un café; mira el panel 2 segundos, elige cuánto tiempo y cierra la tapa.
Constraints: macOS 13+, cristal nativo (NSGlassEffectView en macOS 26, NSVisualEffectView antes); contraseña del sistema en cada cambio.

## Direction contract

THESIS: El cristal es el estado. Normal = cristal claro y casi invisible; activado = el mismo cristal se ahúma a negro ceniza. Rechaza la tarjeta-hero de color dentro de un panel blanco.
OWN-WORLD: Escala ceniza cálida (#141413 → #ECEAE6), sin acento saturado; verde y ámbar solo como semántica. SF del sistema, SF Rounded solo en título y cuenta atrás. Segmentado único en vez de chips sueltos; filas sin tarjetas, separadas por aire y una línea fina.
STORY: Veo si mi Mac aguantará la tapa cerrada, elijo el tiempo, sé si Claude Code sigue, y cómo seguir en el móvil.
FIRST VIEWPORT: Arriba, estado (icono 36 pt + título + subtítulo de 2 líneas máx.) y, con temporizador, cuenta atrás 40 pt con «hasta las HH:mm» y línea de progreso de 3 pt. Debajo, el segmentado de duración (acción principal). Después, «Volver a lo normal», filas de Claude Code y móvil, y pie con batería, inicio y salir.
FORM: Panel propio (NSPanel sin bordes) para controlar la transparencia; transición de tinte de 250 ms como interacción firma. Forma fijada en la petición, no por tirada. seed: none (dirección fijada en la petición)
FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
