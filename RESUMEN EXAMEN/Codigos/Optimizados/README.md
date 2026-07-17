# Optimizados — versiones para usar directo en el examen

Versiones mejoradas de los scripts canónicos de `RESUMEN EXAMEN/Codigos/`,
pensadas para **editar sólo un bloque de datos marcado arriba** y correr,
sin tener que ir a buscar/combinar varios archivos sueltos. Antes de darse
por buenos se verificaron contra un ejercicio ya resuelto y confirmado
contra la solución oficial (ver comentario "Verificado contra..." al
principio de cada script).

## Convención

- Bloque `%% ==== EDITAR ACÁ ====` ... `%% =====================` al
  principio de cada script: ahí van TODOS los valores de entrada del
  enunciado. El resto del script no hace falta tocarlo.
- Cada script trae en su encabezado qué resuelve, qué pide como entrada, y
  contra qué ejercicio ya resuelto se verificó.
- Se prioriza **menos scripts que resuelvan más casos** (p.ej. un único
  script de FGV rectangular que resuelve clasificación + compuerta
  libre/ahogada + resalto, en vez de tres scripts separados).

## Contenido

| Script | Qué resuelve | Verificado contra |
|---|---|---|
| `FGV_rectangular_optimizado.m` | Canal rectangular: yc/yn y clasificación M/S, y (opcional) compuerta de fondo ideal con chequeo automático libre/ahogada, tirante aguas arriba, y ubicación del resalto hidráulico si es libre. Requiere en la misma carpeta: `rect_geom.m`, `froude_rect.m`, `manning_rect.m`, `Mom_rect.m`, `Eesp_rect.m`, `rect.m` (copias sin modificar de `FGV_rectangular/`). | `resueltos/2024 marzo/RESOLUCION.md` Ejercicio 1 (yc=1.008, yn=1.836, canal M; a=0.35→libre, resalto x=19.7m; a=0.6→ahogada, y1=2.367/y2=1.037) |

## Notas

- Octave (al menos la versión 8.4 usada en este repo) **no soporta
  funciones locales al final de un script `.m`** (a diferencia de MATLAB
  moderno) — por eso estos scripts optimizados siguen requiriendo los
  archivos de función auxiliares (`rect_geom.m`, etc.) como archivos
  separados en la misma carpeta, en vez de un único archivo 100%
  autocontenido. "Consolidado" acá significa que el *driver* principal
  (clasificación + compuerta + resalto) está en un solo script en vez de
  tener que correr `fgv_rect.m`, `Mom_rect.m` y `Eesp_rect.m` por
  separado a mano.
- Antes de dar por bueno un script optimizado nuevo, correrlo en Octave y
  comparar contra un ejercicio ya resuelto con solución oficial conocida
  (no alcanza con que "compile").
