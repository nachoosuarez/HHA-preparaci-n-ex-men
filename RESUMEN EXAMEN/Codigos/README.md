# RESUMEN EXAMEN — Códigos

Versiones limpias y canónicas (una sola por herramienta, no una por examen)
de los scripts de Octave/Matlab del curso, reorganizadas por categoría a
partir de `Scripts/01_SCRIPTS/` (que tiene carpetas redundantes: `FGV_felo`,
`bombas Pedro`, y copias parciales dentro de `Scripts examen AA/`).

Para elegir qué copia de cada script era la "canónica" cuando había
duplicados con leves diferencias, se compararon contra los scripts
efectivamente usados en los 4 exámenes ya resueltos
(`resueltos/*/scripts/` + `resueltos/*/RESOLUCION.md`): en todos los casos
coinciden byte a byte con los de `Scripts/01_SCRIPTS/FGV_felo/` (sección
trapezoidal) y `Scripts/01_SCRIPTS/bombas Pedro/` (bombas), que son las
fuentes usadas acá. Se ignoraron copias basura (`Bomba_sola - copiaaaaa.m`,
archivos `.asv` de autosave).

Cada script `.m` tiene, al principio, un encabezado en comentario que
explica qué hace, qué entradas pide y para qué tipo de ejercicio sirve.

## Categorías

| Carpeta | Contenido | Para qué sirve |
|---|---|---|
| `Bombas/` | `Bomba_sola.m`, `Bombas_serie.m`, `Bombas_paralelo.m`, `Bombas_LineasDeCarga.m`, `Bomba_curvaInstalacion.m`, `Bomba_manometros.m`, `Bomba_bifurcacion.m`, `colebrook.m` | Sistemas de bombeo (succión + impulsión): punto de funcionamiento de una bomba sola, dos bombas en serie o en paralelo, línea de carga/piezométrica de la instalación, gráfico comparativo curva de instalación vs. curva de catálogo, punto de funcionamiento/NPSH cuando el dato son lecturas directas de manómetros en las bridas de la bomba (`Bomba_manometros.m`, sin necesidad de calcular pérdidas de tubería), y una bomba única que alimenta una red que se bifurca en N ramas idénticas aguas abajo (`Bomba_bifurcacion.m`, cada rama con Q/N). |
| `FactorFriccion/` | `colebrook.m` | Factor de fricción de Darcy-Weisbach por la ecuación de Colebrook-White, para pérdidas distribuidas en cañerías a presión. Usado como dependencia por los scripts de `Bombas/`. |
| `FGV_trapezoidal/` | `trap_geom.m`, `eq_yc.m`, `eq_yn.m`, `froude_trap.m`, `manning_trap.m`, `critico.m`, `rect.m` (ODE dy/dx, mal nombrado por herencia del template), `Mom_trap.m`, `Eesp_trap.m`, `alternos_trap.m`, `conjugados_trap.m`, `encontrar_resalto.m`, `caudal_M_ini.m`, `caudal_S_ini.m`, `descarga_ahogada.m`, `fgv_trap.m`, `tirantes_yn_yc.m`, `rasante_max.m`, `control_critico_lago_trap.m` | Flujo Gradualmente Variado (FGV), tirante crítico/normal, energía específica y tirantes alternos, momento y tirantes conjugados, ubicación de resaltos hidráulicos, compuertas con descarga ahogada, tensión rasante máxima, y caudal de control crítico de un lago que alimenta un tramo steep (`control_critico_lago_trap.m`, fzero anidado porque yc(Q) no es cerrado en trapezoidal) — todo en canal **trapezoidal** (m=0 lo reduce a rectangular). |
| `FGV_rectangular/` | `rect_geom.m`, `Mom_rect.m`, `Eesp_rect.m`, `critico_rect.m`, `froude_rect.m`, `manning_rect.m`, `critico.m` (evento ODE), `rect.m` (ODE dy/dx), `fgv_rect.m`, `descarga_ahogada_rect.m` | Igual que `FGV_trapezoidal/` pero con fórmulas cerradas (sin iteración) para canal **rectangular**: tirante crítico, momento/conjugado y energía/alterno tienen solución analítica directa. |
| `FGV_circular/` | `circ_geom.m`, `manning_circ.m`, `circ.m`, `critico_lleno.m`, `froude_circ.m`, `fgv_circ.m` | FGV en conducto/canal **circular** parcialmente lleno (alcantarillas, caños pluviales/cloacales). Contempla la posibilidad de dos tirantes normales para un mismo caudal. |
| `EventosExtremos/` | `EVENTOS EXTREMOS 2025.xlsx` | Planilla Excel (no Octave) para hidrología de eventos extremos: método racional e hidrogramas NRCS (cuenca grande/chica). Ver `README.md` propio de esa carpeta para el criterio de selección entre las 3 copias que había en el repo. |
| `Optimizados/` | Ver `README.md` propio de esa carpeta | Versiones parametrizadas y consolidadas de los scripts de arriba, pensadas para editar sólo un bloque de datos y correr directo en el examen (menos scripts, cada uno resuelve varios sub-casos). |

## Resaltos hidráulicos — sin carpeta propia

No se creó una carpeta `Resaltos/` separada: el cálculo de resaltos
(conservación de cantidad de movimiento entre tirantes conjugados) ya está
totalmente integrado dentro de cada categoría de FGV, para evitar
duplicar archivos:

- **Trapezoidal**: `FGV_trapezoidal/Mom_trap.m` (momento + conjugado dado
  un tirante), `FGV_trapezoidal/conjugados_trap.m` (los dos conjugados
  dado el momento), `FGV_trapezoidal/encontrar_resalto.m` (ubica
  automáticamente la posición x del resalto por intersección de curvas
  FGV), `FGV_trapezoidal/descarga_ahogada.m` (resalto/descarga ahogada
  bajo compuerta).
- **Rectangular**: `FGV_rectangular/Mom_rect.m` (momento + conjugado,
  fórmula cerrada), `FGV_rectangular/descarga_ahogada_rect.m` (resalto/
  descarga ahogada bajo compuerta, análogo al de trapezoidal — agregado
  al resolver 2024 marzo Ej.1, primer examen con compuerta ahogada en
  sección rectangular).

## Canales de dos tramos con cambio de pendiente entre dos lagos

No se agregó ninguna función nueva al toolkit `FGV_rectangular/` para este
caso (2023 dic, Ej.1): se resuelve **encadenando** las mismas funciones
cerradas (`froude_rect`, `manning_rect`, `Mom_rect`, `rect.m`+`ode23`) una
vez con la pendiente de cada tramo, más una función auxiliar exam-specific
de "shooting" (`residuo_entrada.m`, en `resueltos/2023 diciembre/scripts/`,
no en el toolkit canónico porque su firma depende del layout particular del
problema) para iterar Q cuando el control no está en la entrada sino en el
cambio de pendiente. Ver el método completo en
`RESUMEN EXAMEN/Teorico/RESUMEN_TEORICO.md` §A4 y el script comentado
`resueltos/2023 diciembre/scripts/Ejercicio1_FGV_dostramos.m`.

## Notas de limpieza aplicadas

- Se corrigió un typo de índice en `FGV_trapezoidal/caudal_S_ini.m`
  (`m = par(1)` duplicaba el valor de `n`; debía ser `m = par(2)`, según
  el orden `par=[n,m,b,S,yl1]` usado en el resto del script y en su
  análogo `caudal_M_ini.m`).
- Se corrigió un bug de NPSH disponible en `Bombas/Bomba_sola.m`,
  `Bombas/Bombas_serie.m` y `Bombas/Bombas_paralelo.m` (detectado y
  verificado resolviendo 2023 dic Ej.4 contra la solución oficial): las
  tres calculaban `NPSHdisp = 10.1 + HA - zB` reutilizando la `HA` de la
  ecuación de instalación, que ya es carga TOTAL (piezométrica+cinética,
  con su término `vs²/(2g)`). Ese término cinético se vuelve a sumar en
  la propia definición de NPSH (`NPSH=p/γ+v²/2g-pvap/γ`) y por Bernoulli
  se **cancela algebraicamente** contra el que ya trae `HA` — sumarlo dos
  veces daba un NPSHdisp ≈0.4 m más alto que el real (en 2023 dic Ej.4,
  2.73 m calculado vs. 2.34 m oficial). Se corrigió restando
  `vs^2/(2*g)` en la línea de `NPSHdisp`, dejando `HA` intacta (sigue
  haciendo falta completa, con el término cinético, para `Hm=HB-HA` de
  la curva de instalación). `Bombas/Bomba_curvaInstalacion.m` y
  `Bombas/Bomba_manometros.m` no tenían este bug (ya usaban una carga de
  succión sin el término cinético, o lo sumaban una sola vez a partir de
  una lectura directa de manómetro).
  Estos son los únicos cambios de lógica realizados; el resto de los
  scripts se dejó tal cual (no se "arregla" lo que ya funciona, sólo se
  documenta).
- Se ignoraron copias basura (`Bomba_sola - copiaaaaa.m`) y archivos de
  autosave (`froude_circ.asv`).
- Varios scripts tienen nombres de archivo engañosos por haber sido
  adaptados de un template (p.ej. `FGV_trapezoidal/rect.m` es en
  realidad la ecuación diferencial *trapezoidal*, y el título de
  `FGV_rectangular/fgv_rect.m` decía "Canal Trapezoidal" por
  copiar/pegar) — se aclaró esto en el encabezado de cada archivo sin
  tocar el nombre ni la lógica, porque los demás scripts los invocan por
  ese nombre exacto.
