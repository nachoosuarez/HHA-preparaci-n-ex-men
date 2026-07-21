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
| `FGV_trapezoidal_optimizado.m` | Canal trapezoidal: yc/yn y clasificación M/S, y (opcional) compuerta de fondo ideal con chequeo libre/ahogada, tirante aguas arriba, ubicación del resalto (integrando la rama M3 y cruzándola con la rama de aguas abajo — control a elegir con `CONTROL_AGUASABAJO`: `'yn'` si el canal es muy largo, `'lago'` o `'caida'` si el control aguas abajo está a una distancia finita dada), fuerza sobre la compuerta y potencia disipada en el resalto, y la apertura máxima de la compuerta para descarga libre. Requiere en la misma carpeta: `trap_geom.m`, `froude_trap.m`, `manning_trap.m`, `Mom_trap.m`, `Eesp_trap.m`, `critico.m`, `conjugado_de_a.m` (copias sin modificar de `FGV_trapezoidal/`), y `rect_trap.m` (copia **renombrada** del `rect.m` de `FGV_trapezoidal/` — con el nombre original chocaría con el `rect.m`, distinto, que ya usa `FGV_rectangular_optimizado.m` en esta misma carpeta: ver Nota de abajo). | `resueltos/2020 Diciembre/RESOLUCION.md` Ejercicio 1 (yc=1.4085, yn=2.1188, canal M; compuerta a=0.85 a 500 m de una caída libre → descarga LIBRE, y1=2.836 m, resalto x=30.1 m [0.966→1.949 m], F=113.6 kN, Pdis=57.05 kW, a_max=0.9595 m) |
| `Alcantarillas_optimizado.m` | Alcantarilla circular o rectangular, uno o varios tubos en paralelo: clasificación automática Tipo 1 (h4/D≥1) vs Tipo 2 (h4/D<1, h3=D), balance de carga h1(Q), para una lista de caudales (p.ej. diseño + evento). El tirante aguas abajo h4 se puede tomar directo (`CANAL='directo'`) o calcular como yn de un canal trapezoidal/rectangular aguas abajo (`CANAL='trapezoidal'`/`'rectangular'`, también clasifica M/S con yc). Requiere en la misma carpeta: `trap_geom.m`, `eq_yn.m`, `eq_yc.m` (si `CANAL='trapezoidal'`, copias de `FGV_trapezoidal/`) y/o `rect_geom.m`, `manning_rect.m` (si `CANAL='rectangular'`, copias de `FGV_rectangular/`, ya presentes en esta carpeta). | `resueltos/2019 febrero/RESOLUCION.md` Ejercicio 1 (canal trapezoidal b=4.5,m=2.5,n=0.02,S0=0.0007; alcantarilla 3×D=1m,n=0.013,L=15m,r/D=0.02; Q=10→Tipo1,y1=2.64m; Q=6→Tipo2,y1=1.52m) |
| `Bombas_optimizado.m` | Sistema de bombeo (succión+impulsión en serie, con N bombas IDÉNTICAS en `MODO='serie'`, `'paralelo'` o `'una'`): curva de instalación (Colebrook-White) vs. curva equivalente, punto de funcionamiento, potencia por bomba y del sistema, NPSHdisp vs NPSHr (la más comprometida en serie es la primera; en paralelo todas ven el mismo NPSHdisp con el caudal total en la succión común). Requiere `colebrook.m` en la misma carpeta. | `resueltos/2019 febrero/RESOLUCION.md` Ejercicio 4 (succión D=100mm L=2m ks=1, impulsión D=75mm L=60m ki=3, ε=0.05mm, z1=-1m, z2=+50m, 2 bombas en serie: Q=9.17 L/s, H=55.5m, 27.76m/bomba, η=68.4%, P=7.30 kW, no cavita) |

## Notas

- **Colisión de nombres `rect.m` entre rectangular y trapezoidal.** Los
  toolkits canónicos `FGV_rectangular/` y `FGV_trapezoidal/` tienen cada
  uno un archivo `rect.m` **distinto** (la ecuación diferencial dy/dx del
  FGV de su propia sección — el de `FGV_trapezoidal/` se llama así por
  herencia de una plantilla, pese a ser en realidad la versión
  trapezoidal, ver el aviso en ese mismo archivo). Como esta carpeta
  `Optimizados/` junta scripts de ambas familias, **no se puede copiar el
  `rect.m` de `FGV_trapezoidal/` con su nombre original** sin pisar el
  `rect.m` rectangular que ya necesita `FGV_rectangular_optimizado.m` —
  por eso la copia trapezoidal se guardó acá como `rect_trap.m`. Si se
  agrega en el futuro otro script optimizado que dependa de algún archivo
  con nombre repetido entre carpetas canónicas distintas, renombrar la
  copia (no el original) y dejarlo documentado acá.

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
