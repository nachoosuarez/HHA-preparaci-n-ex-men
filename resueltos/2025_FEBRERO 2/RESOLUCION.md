# Examen HHA — 5 de febrero de 2025 (2025_FEBRERO 2)

Resolución paso a paso. El PDF del examen (`EXAMENES/2025_FEBRERO 2.pdf`)
incluye, además de la letra (páginas 1-3) y la carta topográfica del
Ejercicio 3 (página 4), la solución oficial manuscrita completa
(páginas 5-10), que se usa para comparar cada resultado.

Herramientas: Octave (scripts de `Scripts/01_SCRIPTS/FGV_felo`, copiados y
adaptados en `scripts/`) para el Ejercicio 1 (flujo gradualmente variado en
canal trapezoidal).

Los scripts de Octave del Ejercicio 1 deben ejecutarse en orden
(`ej1_parte1.m` genera `part1.mat`, usado por `ej1_parte2.m` y
`ej1_parte3.m`; `ej1_parte2.m` genera `part2.mat`, usado por
`ej1_parte3.m`). Los archivos `.mat` intermedios no se versionan.

---

## EJERCICIO 1 — Canal trapezoidal infinito con caída libre y transición de fondo (escalón)

**Datos:** sección trapezoidal, b=5 m, talud m=2 (1V:2H), n=0.017 (Manning),
S₀=0.001, Q=15 m³/s. El canal (considerado infinito aguas arriba) termina en
una caída libre.

Teoría usada: clasificación M/S de canales según y_c vs y_n (Teórico HHA
§2.5.1–2.5.2), condición de control en caída libre (y≈1.01·y_c, Teórico
§2.5.3), perfiles de flujo gradualmente variado (curvas M1/M2/M3, Teórico
§2.5.2), energía específica y transiciones de fondo suave —escalón—
(Teórico §2.2, caso de elevación local del fondo que puede ahogar/no ahogar
la sección), cantidad de movimiento y tirante conjugado para el resalto
hidráulico (Teórico §2.3.2–2.3.3).

### Parte 1) Clasificación M/S y perfil de la superficie libre

**Concepto.** El tipo de canal (M o S) se determina comparando el tirante
normal y_n (Manning, con S₀ y Q dados) con el tirante crítico y_c (Fr=1, con
Q dado), independientemente de la condición de borde. La caída libre al
final del canal impone un control aguas abajo: el tirante pasa por el
crítico muy cerca del borde (en la práctica y≈1.01·y_c, porque exactamente
en y_c la pendiente de la superficie libre es infinita para la ecuación de
FGV). A partir de ese control se integra la curva de FGV hacia aguas
arriba.

**Herramienta:** `eq_yc.m`/`eq_yn.m` con `fsolve` para y_c e y_n (geometría
trapezoidal en `trap_geom.m`), e integración de la ecuación de FGV
(`rect.m`, válida para trapezoidal porque usa `trap_geom.m`) con `ode23`
desde la caída libre hacia aguas arriba. Se usan estas funciones —en vez de
`caudal_M_ini.m`/`caudal_S_ini.m`— porque acá Q ya es dato (no hay que
inferirlo de un lago aguas arriba): sólo hace falta clasificar el canal e
integrar el perfil.

**Script:** `scripts/ej1_parte1.m`. Entradas: `Q=15, b=5, m=2, n=0.017,
S0=0.001`.

**Resultado:**
```
yc = 0.8610 m
yn = 1.2044 m
```
Como y_c (0.861 m) < y_n (1.204 m) ⇒ **el canal es de tipo M (pendiente
suave)**.

**Perfil de flujo:** con y(x=0)=1.01·y_c=0.870 m en la caída libre (x=0,
origen en la caída, x negativo hacia aguas arriba), se integró la ecuación
de FGV hacia aguas arriba. Resulta una curva **M2** (subcrítica, y_c<y<y_n,
creciendo hacia aguas arriba) que se aproxima asintóticamente a y_n a medida
que x se aleja de la caída (a x=−700 m, y=1.199 m, ya muy cerca de
y_n=1.204 m). Todo el tramo es subcrítico, por lo que **no hay resaltos
hidráulicos** en esta configuración.

**Perfil de la superficie libre (x medido desde la caída libre, negativo
hacia aguas arriba):**
- x→−∞ (aguas arriba, canal "infinito"): y→y_n=1.204 m.
- x=−300 m: y=1.1705 m.
- x=0 (caída libre): y=1.01·y_c=0.870 m.

Gráfico: `scripts/ej1_perfil_parte1.png`.

**Resultado final Parte 1: canal tipo M (y_c=0.861 m < y_n=1.204 m), curva
M2 en todo el canal, sin resaltos, tirante tendiendo a y_n aguas arriba y
cayendo hasta ≈1.01·y_c justo antes de la caída libre.**

**Comparación con solución oficial:** el manuscrito da y_c=0,86 m,
y_n=1,20 m, canal M, condición aa caída libre M2 con y_ini=1,01·y_c —
**coincide exactamente**.

### Parte 2) Altura máxima de la tubería (escalón a 300 m de la caída) que no altera el tirante aguas arriba

**Concepto.** A L=300 m antes de la caída se instala una tubería que actúa
como un escalón de fondo (elevación local D del lecho, de longitud
despreciable, sin pérdidas). Para una transición de fondo suave, se conserva
la energía entre la sección aguas arriba (1) y la cresta del escalón (2):
E₁=E₂+D. Si D es pequeño, el tirante y₁ aguas arriba no cambia (el flujo
"pasa por arriba" del escalón sin verse forzado). El D máximo que **no**
altera y₁ es aquel para el cual, justo en la cresta, la energía específica
disponible sea la mínima compatible con el caudal (E₂=E_c, es decir, el
flujo se pone crítico exactamente en la cresta): para D mayor que ese
Dmax, la sección ya no puede pasar el caudal con E₂=E_c y el escalón se
"ahoga", obligando a subir y₁ aguas arriba (remanso).

**Herramienta:** cálculo directo de energía específica en la sección 1 (con
y₁ tomado del perfil M2 de la Parte 1 en x=−300 m, sin alterar) y de la
energía crítica E_c=y_c+U_c²/(2g) (mismas funciones `trap_geom.m`, sin
necesidad de `Eesp_trap.m` porque no hace falta el tirante alterno en esta
parte). Se eligió este camino —evaluar E1 y Ec directamente— porque es
exactamente el razonamiento de energía específica mínima del Teórico §2.2
aplicado a un escalón, y es el mismo enfoque de la solución oficial.

**Script:** `scripts/ej1_parte2.m`.

**Resultado:**
```
y1 (x=-300m, sin alterar) = 1.1705 m
E1 = 1.3260 m
Ec = 1.2037 m
Dmax = E1 - Ec = 0.1223 m
```

**Resultado final Parte 2: la altura máxima de la tubería para no alterar el
tirante aguas arriba es Dmax ≈ 0.12 m.**

**Comparación con solución oficial:** el manuscrito da y₁(x=−300m)=1,17 m,
E₁=1,325 m, E_c=1,204 m, Dmax=0,12 m — **coincide exactamente**.

### Parte 3) Tubería de altura A=0.35 m: perfil completo con remanso y resalto

**Concepto.** Como A=0.35 m > Dmax=0.12 m (Parte 2), el escalón "ahoga" la
sección: para poder pasar el caudal por la cresta se necesita más energía
específica aguas arriba, y aparece **remanso** (el tirante y₁ sube por
encima del valor sin alterar). En la cresta el flujo pasa por crítico
(E₂=E_c), luego E₁=E_c+A (conservación de energía en el escalón, subiendo).
Con esa nueva E₁ hay dos tirantes posibles con la misma energía específica
(alternos): el subcrítico (y₁, aguas arriba de la tubería, sobre una curva
**M1** de remanso) y el supercrítico (y₃, alterno de y₁, que es el tirante
inmediatamente aguas abajo de la tubería una vez que el fondo vuelve a su
nivel original —el escalón es de longitud despreciable, con subida y
bajada en el mismo punto—, ya que ahí también se conserva la energía
específica: E₃=E₂+A=E₁, misma cota de fondo que en la sección 1). Aguas
abajo de la tubería el flujo es supercrítico y sigue una curva **M3** que
crece hacia aguas abajo; como el resto del canal (aguas abajo) debe
empalmar con el perfil M2 sin alterar de la Parte 1 (que llega intacto
hasta la caída libre, ya que esta permanece fija como control aguas abajo),
en algún punto entre la tubería y la caída se produce un **resalto
hidráulico** que conecta la curva M3 con la curva M2 original.

**Herramienta:** tirantes alternos con `alternos_trap.m` (calcula y₁ y su
alterno y₃ para una energía específica dada, sección trapezoidal);
integración de la curva M3 con `rect.m`/`ode23` desde x=−300 m (y=y₃) hacia
aguas abajo; conjugado de cada punto de la curva M3 con `Mom_trap.m`
(cantidad de movimiento); ubicación del resalto por intersección entre el
conjugado de M3 y la curva M2 de la Parte 1 (mismo procedimiento que
`encontrar_resalto.m`, adaptado para comparar contra el perfil M2 ya
calculado en vez de una segunda curva analítica). Se eligieron estas
funciones porque son las provistas por el curso específicamente para
tirantes alternos y conjugados en sección trapezoidal, y el procedimiento
de ubicar el resalto por intersección de conjugados es el mismo usado en el
Ejercicio 1 del examen 2025_FEBRERO 1 ya resuelto en este repositorio.

**Script:** `scripts/ej1_parte3.m`.

**Resultado:**
```
E1_new = Ec + A = 1.5537 m
y1_new (subcritico, aguas arriba tuberia)            = 1.4693 m
y3_new (supercritico, alterno = aguas abajo tuberia) = 0.5549 m

Como A=0.35m > Dmax=0.1223m => y1_new > y1 sin alterar => HAY REMANSO

Curva M3: desde x=-300m (y=0.5549 m) hasta x=-257.03m (y=0.8610 m = yc,
   límite superior de la rama supercrítica)

RESALTO HIDRAULICO:
  x_resalto = -289.27 m (medido desde la caida libre)
  Distancia desde la tuberia (x=-300m) hasta el resalto = 10.73 m
  y antes del resalto (rama M3)                = 0.6067 m
  y despues del resalto (conjugado, sobre M2)  = 1.1682 m
```

**Perfil completo de la superficie libre (x medido desde la caída libre):**
- x→−∞: y→y_n=1.204 m (curva M1 aún no perturbada, muy lejos de la
  tubería).
- x=−300 m⁻ (justo aguas arriba de la tubería): y₁=1.469 m (remanso, curva
  M1).
- x=−300 m (cresta de la tubería): y=y_c=0.861 m (paso por crítico).
- x=−300 m⁺ (justo aguas abajo de la tubería): y₃=0.555 m (curva M3,
  supercrítica).
- x=−300 a −289.3 m: curva M3 creciendo de 0.555 m a 0.607 m.
- x≈−289.3 m: **resalto hidráulico**, de y=0.607 m a y=1.168 m.
- x=−289.3 a 0 m: curva M2 (idéntica a la de la Parte 1, sin alterar),
  decreciendo de 1.168 m hasta y=1.01·y_c=0.870 m en la caída libre.

Gráfico: `scripts/ej1_perfil_parte3.png`.

**Resultado final Parte 3: con la tubería de A=0.35 m se forma un remanso
aguas arriba (y₁≈1.47 m en x=−300 m), el flujo pasa por crítico en la
cresta y se acelera a supercrítico (y₃≈0.55 m) aguas abajo de la tubería;
tras recorrer sólo ≈10.7 m sobre la curva M3 se produce un resalto
hidráulico (de y≈0.61 m a y≈1.17 m), y de ahí en más el perfil vuelve a
coincidir con la curva M2 original de la Parte 1 hasta la caída libre.**

**Comparación con solución oficial:** el manuscrito da E₁=1,55 m,
y₁=1,47 m, y₃=y₁_alt=0,55 m, "M3 se agota en 43 m" (desde la cresta hasta
y_c, 300−257=43 m, coincide con el cálculo), x_resalto=11 m desde la
tubería (cálculo: 10.73 m) e y_resalto=1,17 m — **coincide muy
estrechamente** con el cálculo (diferencias <3% atribuibles a redondeo
gráfico manual).

### Resumen Ejercicio 1

| Ítem | Resultado |
|---|---|
| y_c | **0.861 m** |
| y_n | **1.204 m** |
| Clasificación | **Canal tipo M** |
| Perfil sin tubería | **M2, sin resaltos, y→y_n aguas arriba, y≈1.01·y_c en la caída** |
| Dmax (tubería sin alterar y₁) | **0.122 m** |
| Con A=0.35 m | **Remanso: y₁=1.47 m; y₃=0.55 m; resalto a 10.7 m de la tubería (y: 0.61→1.17 m); luego M2 original hasta la caída** |

---

## EJERCICIO 2 — Alcantarilla en cuenca de Río Negro: caudal de diseño, hidrograma y desarrollo forestal

**Datos (Tabla del enunciado):** Área = 8.0 km², ΔH = 90 m, L = 5500 m (cauce
principal), Grupo Hidrológico B, S = 3.2 % (pendiente media de la cuenca).
Punto de cierre en X=382.5 km, Y=6408.5 km (departamento de Río Negro). Uso
de suelo actual: pastizales, condición hidrológica regular. Flujo
concentrado.

Teoría usada: metodologías de caudal máximo en cuencas no aforadas — Método
Racional y Método NRCS y su rango de aplicabilidad según t_c (Teórico HHA
§3.1.5, en particular la recomendación de no usar el método Racional para
t_c>1 hora), curvas IDF de Uruguay y corrección por área/duración/período de
retorno (§3.1.4), tiempo de concentración de Ramser-Kirpich (§3.1.2), método
del Número de Curva NRCS (§3.1.5 b, Fig. 3.1.20), hidrograma unitario
sintético triangular SCS (§3.1.5 c).

**Aprendizaje previo de la herramienta:** se reutilizó el enfoque ya validado
en el Ejercicio 2 del examen "2026 Febrero" (ya resuelto en este repositorio),
que replica en Python (`ej2_parte1.py` etc.) las fórmulas de
`Scripts/01_SCRIPTS/Scripts examen AA/EVENTOS EXTREMOS 2025.xlsx` (hojas
`método racional` y `NRCS - Gande`): IDF de Uruguay (CT/CD/CA), tormenta de
diseño por bloque alterno, precipitación efectiva por Número de Curva con
piso de infiltración, e hidrograma unitario triangular sintético SCS
convolucionado. Se usa Python en vez de la planilla Excel/LibreOffice
porque este entorno no dispone de una hoja de cálculo con recálculo
interactivo (confirmado nuevamente en esta corrida).

**P₃,₁₀,ₚ (Río Negro, X=382.5 km, Y=6408.5 km):** se leyó directamente de la
Figura 3.1.10 del Teórico (isoyetas de lluvias extremas de Uruguay, líneas
cada 2 mm, extraída a `scripts/ej2_isoyeta_P310.png`): el punto de cierre
cae casi exactamente sobre la isoyeta gruesa marcada "90" que cruza el
departamento de Río Negro en esa zona ⇒ **P₃,₁₀,ₚ ≈ 90 mm**.

**NC (pastizales, condición hidrológica regular, grupo B):** de la Figura
3.1.20 del Teórico (fila "Pradera o pastizal", columna "Regular", grupo B)
⇒ **NC = 69**.

### Parte 1) Caudal máximo de diseño (Tr = 10 años) y justificación del método

**Tiempo de concentración (Ramser-Kirpich, Teórico §3.1.2):**
```
tc = 0.4·L^0.77 / S^0.385      L en km, S en % (pendiente DEL CAUCE PRINCIPAL)
```
**Concepto clave (igual que en el examen 2026 Febrero):** la tabla del
enunciado da dos pendientes con propósitos distintos: S=3.2 % es la
*pendiente media de la cuenca* (usada en el método Racional para elegir el
coeficiente de escorrentía C, que aquí termina no siendo necesario — ver
más abajo), mientras que Kirpich necesita la *pendiente del cauce
principal*: S_cauce = ΔH(m)/L(km)/10 = 90/5.5/10 = **1.636 %**. Con
L=5.5 km:

**tc = 1.2297 hs ≈ 1 h 14 min (73.8 min).**

**Justificación del método:** el Teórico HHA (§3.1.5, "Método Racional")
indica textualmente que el método Racional se recomienda para cuencas con
t_c≤20 min y se **desaconseja para t_c>1 hora** (entre 20 min y 1 h se
recomienda calcular ambos métodos y adoptar el mayor). Como t_c=1.23 h > 1 h,
**el método Racional no corresponde en este caso: se utiliza únicamente el
método NRCS** (tormenta de diseño de intensidad variable + Número de Curva +
hidrograma unitario sintético SCS), que no tiene esa limitación de tamaño de
cuenca.

**Herramienta:** `scripts/ej2_parte1.py` (réplica en Python de las hojas
`método racional`/`NRCS - Gande` de la planilla de eventos extremos, ya
usada y validada en el examen 2026 Febrero): (a) fórmulas IDF de Uruguay
P(d,Tr,p)=P₃,₁₀,ₚ·CT(Tr)·CD(d)·CA(d,Ac); (b) tormenta de diseño por bloque
alterno con Δt=tc/7 en 12 bloques; (c) precipitación efectiva por Número de
Curva con corrección de piso de infiltración (grupo B ⇒ 1.2 mm/h); (d)
hidrograma unitario triangular sintético SCS (Tp=tr/2+0.6tc, Tb=2.667Tp,
qp=2.08·A/Tp), convolucionado con los 12 pulsos de lluvia efectiva.

**Resultados (`ej2_parte1.py`):**
```
tc = 1.2297 hs = 73.78 min ; S_cauce = 1.636 %
CT(Tr=10) = 1.0000

Tormenta de diseño (bloque alterno, Δt=tc/7=10.54 min, 12 bloques):
  pico central de 24.24 mm, total 76.17 mm en 126.5 min.
S = 114.12 mm ; Ia = 22.82 mm (NC=69)
Precipitación efectiva total (corregida) = 16.99 mm
Hidrograma unitario triangular: tr=0.1757 hs, Tp=0.8256 hs, Tb=2.2020 hs,
  qp=20.15 m3/s/cm

Qmax NRCS = 25.60 m3/s (en t=2.24 hs desde el inicio de la tormenta)
```

**Resultado final Parte 1: caudal de diseño Q₁₀ = 25.6 m³/s (único método
válido: NRCS, ya que t_c>1 h descarta el método Racional).**

**Comparación con solución oficial:** el manuscrito da P(3,10,P)=90 mm,
tc=1.23 hs=1h14min, NC=69, Qmax=25.5 m³/s (método NRCS, sin calcular el
Racional) — **coincide prácticamente exacto** con el cálculo (25.60 m³/s).

### Parte 2) Volumen de escorrentía y gráfico del hidrograma de diseño

**Concepto.** El volumen de escorrentía del evento es la integral en el
tiempo del hidrograma de caudales (equivalente a la precipitación efectiva
total convertida a volumen: 1 mm sobre 1 km² = 1000 m³). El caudal máximo y
el tiempo al pico ya quedaron determinados en la Parte 1 a partir del mismo
hidrograma.

**Herramienta:** `scripts/ej2_parte2.py`, que reutiliza los arreglos
guardados por `ej2_parte1.py` (`part1.npz`): calcula el volumen como
Pe_total(mm)·1000·Área(km²), lo verifica integrando numéricamente Q(t) con
la regla del trapecio (ambos caminos deben coincidir, ya que son la misma
cantidad física expresada de dos formas), y grafica el hidrograma completo.

**Resultado:**
```
Volumen de escorrentia = 135 932 m3
Qmax = 25.60 m3/s ; tp = 2.24 hs desde el inicio de la tormenta

Verificacion cruzada: volumen integrado de Q(t) = 135 875 m3
(diferencia -0.04% respecto al volumen por precipitacion efectiva)
```

Gráfico: `scripts/ej2_hidrograma_parte2.png`.

**Resultado final Parte 2: volumen de escorrentía ≈ 135 900 m³, con
Qmax=25.6 m³/s en tp≈2.24 h desde el inicio de la tormenta de diseño.**

**Comparación con solución oficial:** el manuscrito da Vesc=135 968 m³,
Tp=2.20 hs (tiempo al pico del hidrograma total, coincide con el tp=2.24 hs
calculado) y Qp=25.5 m³/s — **coincide casi exactamente** (diferencia
<0.1% en volumen). Nota: el manuscrito también anota "Tb=0.825 hs", que en
realidad corresponde al Tp del hidrograma unitario triangular (0.8256 hs
calculado), no al tiempo base del hidrograma total; es un rótulo cruzado en
los apuntes manuscritos, no una discrepancia real.

### Parte 3) Desarrollo Forestal (25% del área): recálculo de Qmax, volumen e hidrograma

**Concepto.** El desarrollo Forestal cubre el 25% del área de la cuenca y
produce dos efectos sobre el modelo NRCS: (i) reduce el tiempo de
concentración de **toda la cuenca** en un 10% (dato del enunciado, no sólo
del área forestada), por lo que tc_nuevo=0.90·tc; (ii) cambia el Número de
Curva de la superficie forestada a NC=82 (dato del enunciado), por lo que el
NC representativo de toda la cuenca pasa a ser un **promedio ponderado por
área** entre el uso actual (75% del área, NC=69) y el forestal (25% del
área, NC=82): NC_nuevo=0.75·69+0.25·82=72.25. Como tc_nuevo sigue siendo
mayor a 1 hora, el método Racional sigue sin corresponder y se mantiene el
método NRCS.

**Herramienta:** `scripts/ej2_parte3.py`, que repite exactamente el mismo
procedimiento de `ej2_parte1.py`/`ej2_parte2.py` (tormenta de diseño +
precipitación efectiva + hidrograma unitario SCS) con tc_nuevo y NC_nuevo,
y compara contra los resultados de la condición actual (Partes 1-2,
cargados desde `part1.npz`).

**Resultados (`ej2_parte3.py`):**
```
tc_nuevo = 0.90 * 1.2297 = 1.1067 hs = 66.40 min
NC_nuevo = 0.75*69 + 0.25*82 = 72.25

Tormenta de diseño total = 72.68 mm (duracion 113.8 min)
S = 97.56 mm ; Ia = 19.51 mm
Precipitacion efectiva total = 18.75 mm

Volumen de escorrentia = 150 022 m3
Hidrograma unitario: Tp=0.7431 hs, Tb=1.9818 hs, qp=22.39 m3/s/cm

Qmax = 31.34 m3/s en t=2.00 hs
```

i) **Qmax (Tr=10, con desarrollo Forestal) = 31.3 m³/s** (vs. 25.6 m³/s
actual).

ii) **Volumen de escorrentía = 150 022 m³**, con **tp = 2.00 hs** desde el
inicio de la tormenta (vs. 135 932 m³ y tp=2.24 hs en la condición actual).
Gráfico comparativo: `scripts/ej2_hidrograma_parte3.png`.

iii) **Comparación y discusión:** el desarrollo Forestal **aumenta el
caudal pico** (25.6→31.3 m³/s, +22%) y lo **adelanta en el tiempo**
(tp: 2.24→2.00 h). El mecanismo es doble: por un lado, al reducirse tc un
10%, la cuenca concentra su respuesta más rápido (hidrograma unitario más
angosto y de mayor qp); por otro, el NC ponderado sube de 69 a 72.25 (el
uso forestal es, contraintuitivamente en este modelo, algo más
impermeable/escurridor que el pastizal en condición regular con este NC de
82 dado), lo que también incrementa levemente el volumen de escorrentía
(135 932→150 022 m³, +10%). Ambos efectos —mayor volumen concentrado en
menos tiempo— se combinan para producir un pico sensiblemente mayor y más
temprano.

**Resultado final Parte 3: Q_NRCS(forestal)=31.3 m³/s, Vesc=150 022 m³,
tp=2.00 hs; el caudal pico aumenta ≈22% y se adelanta ≈14 min respecto a la
condición actual.**

**Comparación con solución oficial:** el manuscrito da tc_nuevo=1.1 hs
(66.4 min), NC=72.25, Q_NRCS=31.24 m³/s, Vesc=150.022 m³ (¡coincide con el
número exacto!), Tp=1.98 hs, y concluye "Q pico mayor en menor tiempo pico;
Vesc aumenta a tasa del descenso de tc, Q aumenta a mayor tasa" — **coincide
exactamente** con el cálculo y la discusión.

### Resumen Ejercicio 2

| Ítem | Condición actual | Con desarrollo Forestal (25%) |
|---|---|---|
| tc | **73.8 min** | **66.4 min** |
| NC | **69** | **72.25** |
| Método válido (tc>1h) | NRCS (Racional descartado) | NRCS (Racional descartado) |
| Qmax (Tr=10) | **25.6 m³/s** | **31.3 m³/s** |
| Volumen de escorrentía | **135 932 m³** | **150 022 m³** |
| Tiempo al pico | **2.24 hs** | **2.00 hs** |

Todos los resultados numéricos coinciden con la solución oficial manuscrita.

---

---

## EJERCICIO 3 — Delimitación de cuenca (carta SGM), desnivel, tiempo de concentración y tiempo de encharcamiento (Horton)

**Datos:** carta topográfica SGM (curvas de nivel cada 10 m), punto de
cierre en el departamento de Durazno, X=477.0 km, Y=6332.0 km. Longitud del
cauce principal L=4530 m (dato del enunciado). Hietograma observado en un
pluviógrafo dentro de la cuenca: P(mm)=2.2, 6.0, 11.1, 4.6, 3.3, 1.8 en
bloques de 10 min (0-60 min). Parámetros de Horton: f₀=44 mm/h, f_c=11 mm/h,
K=2.55 h⁻¹.

Teoría usada: delimitación de cuencas y divisoria de aguas sobre carta
topográfica (Teórico HHA §3.1.1), tiempo de concentración de Ramser-Kirpich
(§3.1.2), infiltración según el modelo de Horton y tiempo de encharcamiento
—"ponding time"— (§3.1.3), balance de precipitación en infiltración +
escorrentía.

### Parte 1.1) Delimitación de la cuenca

**Concepto.** La divisoria de aguas (línea de cumbre) se traza sobre la
carta siguiendo la dirección perpendicular a las curvas de nivel, uniendo
los puntos altos que separan el área que efectivamente drena hacia el punto
de cierre del resto del terreno. Se identificaron dos lomas que flanquean
el valle que desemboca en el punto de cierre (al oeste, cota ≈120-125 m
cerca de la cota acotada "125.0"; al sur, una loma que alcanza ≈145 m entre
las curvas 140 y 150) y se trazó la divisoria conectándolas, cerrando el
polígono en el punto de cierre.

**Herramienta:** delimitación gráfica manual sobre la carta (no requiere
script; es un procedimiento de lectura/dibujo de mapa según el método del
Teórico §3.1.1). La carta sin delimitar se guarda en
`scripts/ej3_carta_sin_delimitar.png`; la cuenca delimitada (verificada
contra la solución oficial del examen, que trae el mismo mapa con la
divisoria ya trazada en la página 8 del PDF) se guarda en
`scripts/ej3_cuenca_delimitada.png`.

**Resultado: la cuenca delimitada es un polígono alargado norte-sur,
apoyado sobre el arroyo que llega al punto de cierre (X=477.0, Y=6332.0),
limitado al oeste y al sur por la línea de cumbre que pasa cerca de las
cotas acotadas "119.0" y "125.0".**

### Parte 1.2) Desnivel máximo del cauce principal y tiempo de concentración

**Concepto.** El desnivel máximo del cauce principal es la diferencia entre
la cota más alta del divisorio en el nacimiento del cauce principal (dentro
de la cuenca delimitada en 1.1) y la cota del punto de cierre. Con ese
desnivel, la longitud L=4530 m dada, y asumiendo flujo concentrado (dato
del enunciado), se calcula el tiempo de concentración con la fórmula de
Ramser-Kirpich (igual que en el Ejercicio 2 y en los exámenes ya resueltos
en este repositorio).

**Herramienta:** `scripts/ej3_parte1_tc.py`. Cotas leídas sobre la carta
delimitada (interpolando entre curvas de nivel cada 10 m): cota máxima
≈145 m (loma sur del divisorio), cota mínima (punto de cierre) ≈105 m
(entre las curvas 100 y 110, más cerca de la de 110).

**Resultado:**
```
Hmax = 145.0 m ; Hmin = 105.0 m ; dH = 40.0 m
L = 4530 m = 4.530 km
S (cauce principal) = dH/L/10 = 0.8830 %

tc = 0.4*L_km^0.77/S^0.385 = 1.3430 hs = 80.58 min
```

**Resultado final Parte 1.2: desnivel máximo del cauce principal ΔH=40 m
(cota máxima 145 m, cota mínima 105 m), tiempo de concentración tc≈1.34 hs
(80.6 min).**

**Comparación con solución oficial:** el manuscrito da Hmax=145 m,
Hmin=105 m, ΔH=40 m, tc=1.34 hs — **coincide exactamente**.

### Parte 2.1) Tiempo de encharcamiento (infiltración de Horton)

**Concepto.** El tiempo de encharcamiento ("ponding time") es el instante a
partir del cual la intensidad de la lluvia supera la capacidad de
infiltración del suelo: antes de ese instante toda la lluvia infiltra (no
hay exceso de precipitación); a partir de él, el suelo se satura
superficialmente y comienza a generarse escorrentía. Con datos de lluvia en
bloques (no continuos), el criterio práctico es comparar, al inicio de cada
bloque, la intensidad media del bloque i (mm/h) con la capacidad de Horton
f(t)=f_c+(f₀-f_c)·e^(-Kt) evaluada en el tiempo transcurrido desde el
inicio del evento (aproximación válida aquí porque el encharcamiento se da
apenas comienza el segundo bloque, sin que haya "tiempo perdido" apreciable
que requiera corregir el origen de tiempos de la curva de Horton).

**Herramienta:** `scripts/ej3_parte2_horton.py`: evalúa f(t) de Horton al
inicio de cada bloque de 10 min y la compara con la intensidad de ese
bloque.

**Resultado:**
```
Bloque  t(min)   P(mm)   i(mm/h)   f(t_ini)(mm/h)
  1        0     2.2     13.20      44.00
  2       10     6.0     36.00      32.57   <- i > f: comienza a encharcar
  3       20    11.1     66.60      25.10
  4       30     4.6     27.60      20.22
  5       40     3.3     19.80      17.03
  6       50     1.8     10.80      14.94

Tiempo de encharcamiento t_ench = 10 min (i=36.00 mm/h > f=32.57 mm/h)
```

**Resultado final Parte 2.1: el tiempo de encharcamiento es t_ench=10 min
(justo al comenzar el segundo bloque de lluvia), con i=36.0 mm/h >
f(10min)=32.6 mm/h.**

**Comparación con solución oficial:** el manuscrito da t_ench=10 min
(i=36 mm/h, f=32.6 mm/h) — **coincide exactamente**.

### Parte 2.2) Esquema tasa de infiltración/intensidad vs. tiempo; volúmenes de infiltración acumulada y de escurrimiento

**Concepto.** Antes del encharcamiento (bloque 1, 0-10 min) toda la lluvia
infiltra (la intensidad nunca supera f₀). A partir de t_ench=10 min, en
cada bloque se compara la intensidad de lluvia con f(t): mientras i(t)>f(t)
el suelo sigue encharcado y la infiltración real ocurre a la tasa de
capacidad f(t) (se integra la curva de Horton); en cuanto i(t) cae por
debajo de f(t) (lo que ocurre en el bloque 6, ya que f(t) nunca baja de
f_c=11 mm/h y la intensidad del bloque 6 es 10.8 mm/h < f_c), el suelo deja
de estar limitado por capacidad y vuelve a infiltrar el 100% de la lluvia
de ese bloque. El volumen de escorrentía es, por balance, la precipitación
total menos el volumen infiltrado.

**Herramienta:** `scripts/ej3_parte2_horton.py` (continuación): identifica
los bloques capacidad-limitados (2 a 5, entre t=10 y t=50 min) e integra
analíticamente f(t) en ese tramo; suma los bloques 1 y 6 completos (lluvia-
limitados); grafica intensidad de lluvia (barras) y capacidad de Horton
(curva) vs. tiempo.

**Resultado:**
```
Bloques capacidad-limitados (encharcados): [2, 3, 4, 5]
Bloques limitados por la lluvia (infiltran completo): [1, 6]

V_infiltrado bloque 1 (0-10min)                    = 2.200 mm
V_infiltrado capacidad (10-50min, integral Horton) = 14.248 mm
V_infiltrado bloque 6 (50-60min)                   = 1.800 mm

VOLUMEN DE INFILTRACION ACUMULADA Vinf = 18.248 mm
Precipitación total del evento          = 29.000 mm
VOLUMEN DE ESCORRENTIA Vesc = 29.0 - 18.25 = 10.752 mm
```

Gráfico: `scripts/ej3_horton_infiltracion.png` (intensidad de lluvia en
barras, capacidad de infiltración de Horton en curva roja, tiempo de
encharcamiento marcado en verde; el área de las barras por debajo de la
curva roja es el volumen infiltrado, y el área de las barras por encima de
la curva roja —sólo entre t=10 y 30 min, donde las barras superan la curva—
es el volumen de escorrentía).

**Resultado final Parte 2.2: volumen de infiltración acumulada
Vinf≈18.25 mm; volumen de escorrentía Vesc≈10.75 mm (29.0 mm de lluvia
total − 18.25 mm infiltrados).**

**Comparación con solución oficial:** el manuscrito da Vinf=18,25 mm y
Vesc=10,75 mm (29 mm−18,25 mm) — **coincide exactamente**.

### Resumen Ejercicio 3

| Ítem | Resultado |
|---|---|
| Cuenca delimitada | Polígono N-S apoyado en el arroyo del punto de cierre (X=477.0, Y=6332.0) |
| Cota máxima / mínima del cauce | **145 m / 105 m** |
| Desnivel máximo ΔH | **40 m** |
| Tiempo de concentración tc | **1.34 hs (80.6 min)** |
| Tiempo de encharcamiento | **10 min** (i=36.0 mm/h > f=32.6 mm/h) |
| Volumen de infiltración acumulada | **18.25 mm** |
| Volumen de escorrentía | **10.75 mm** |

Todos los resultados numéricos coinciden con la solución oficial manuscrita.

---

ESTADO: EN CURSO (falta Ejercicio 4)
