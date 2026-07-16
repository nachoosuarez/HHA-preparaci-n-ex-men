# Examen HHA — 16 de diciembre de 2024

Resolución paso a paso. El PDF del examen (`EXAMENES/2024 diciembre.pdf`)
incluye, además de la letra (páginas 1-4), la solución oficial manuscrita
(páginas 5-9), que se usa para comparar cada resultado.

Herramientas: Octave (scripts de `Scripts/01_SCRIPTS/FGV_felo` y
`Scripts/01_SCRIPTS/bombas Pedro`, copiados y adaptados en `scripts/`) para
los Ejercicios 1 y 4; método Racional / NRCS (Teórico HHA §3.1) para los
Ejercicios 2 y 3.

Los scripts de Octave del Ejercicio 1 son independientes entre sí
(`ej1_parte1.m` resuelve la Parte 1 completa, `ej1_parte2.m` resuelve la
Parte 2 completa; ambos recalculan Q y las curvas de tramo 1 desde cero, ya
que Q no cambia entre partes). Ambos requieren en la misma carpeta:
`trap_geom.m`, `eq_yc.m`, `eq_yn.m`, `froude_trap.m`, `manning_trap.m`,
`critico.m`, `rect.m`, `tirantes_yn_yc.m`, `Mom_trap.m`.

---

## EJERCICIO 1 — Canal trapezoidal de dos tramos entre el Lago A y el Lago B

**Datos:** sección trapezoidal, ancho de fondo b=1.2 m (igual en ambos
tramos), n=0.012, S₀=0.01. Tramo 1 (x=0 a 300 m): talud m₁=1. Tramo 2 (x=300
a 600 m): talud m₂=0.5 (reducción de talud, cambio de sección "suave" sin
pérdidas de carga). Nivel del Lago A sobre el fondo del canal: h_LA=1.80 m.

**Teoría usada:** ecuación diferencial del flujo gradualmente variado
dy/dx=(S₀−S_f)/(1−Fr²) y clasificación de canales M (y_n>y_c) / S (y_n<y_c)
(Teórico HHA §2.5.1–§2.5.2), clasificación completa de perfiles M1-M3/S1-S3
(§2.5.3, implementada en `rect.m`/`trap_geom.m`), perfiles de flujo entre dos
lagos y control crítico en la entrada de un canal tipo S (§2.5.4–§2.5.5),
energía específica y tirante crítico (§2.2), cantidad de movimiento y
tirantes conjugados para el resalto hidráulico (§2.3.3 "Resalto hidráulico",
implementado en `Mom_trap.m`).

### Parte 1) h_LB = −0.50 m (nivel del Lago B por debajo del fondo del canal)

**Concepto.** Al ser h_LB negativo (por debajo del fondo del canal), el Lago
B no puede imponer ningún control hidráulico sobre el canal: la descarga es
en caída libre, cualquiera sea el tirante con que el canal llegue al final.
Por lo tanto el único control relevante es el de aguas arriba: el Lago A
alimenta el canal, y para un canal de pendiente fuerte (tipo S, hipótesis que
se verifica más abajo) el lago descarga estableciendo el **caudal máximo
compatible con su energía**, lo que ocurre con flujo **crítico en la sección
de entrada** (x=0): el tirante crítico es el que lleva el caudal máximo para
una energía específica dada (Teórico §2.2 y §2.5.4).

**Herramienta:** sistema de 2 ecuaciones no lineales con 2 incógnitas (Q,
y_c) resuelto con `fsolve` en Octave, usando `trap_geom.m` para la geometría
trapezoidal:

```
Fr² = Q²·B(y_c)/(g·A(y_c)³) = 1        (flujo crítico en x=0)
h_LA = y_c + Q²/(2g·A(y_c)²)            (conservación de energía Lago A → x=0)
```

Se eligió resolver este sistema directamente (en vez de usar
`caudal_M_ini.m`/`caudal_S_ini.m` del repositorio) porque esos scripts están
pensados para un único tramo con parámetros fijos; acá hace falta luego
empalmar dos tramos con taludes distintos, así que se arma el cálculo a
medida reutilizando las funciones geométricas base.

**Script:** `scripts/ej1_parte1.m`. Entradas: `b=1.2, n=0.012, S0=0.01,
m1=1, m2=0.5, L1=300, L2=300, hLA=1.80, hLB=-0.50`.

**Resultado del caudal y de los tirantes característicos:**
```
Q   = 10.224 m3/s
Tramo 1 (m=1.0):  y_c1 = 1.357 m ;  y_n1 = 0.911 m
Tramo 2 (m=0.5):  y_c2 = 1.560 m ;  y_n2 = 1.086 m
```
Como y_n < y_c en **ambos** tramos ⇒ **los dos tramos son canal tipo S
(pendiente fuerte)**, confirmando la hipótesis de control crítico en la
entrada.

**Perfil de flujo:**
- **Tramo 1 (x=0 a 300 m):** con y=y_c1=1.357 m en x=0 (control crítico), se
  integra la ecuación de FGV (`rect.m`) con `ode23` hacia aguas abajo.
  Resulta una **curva S2** (supercrítica, y_n<y<y_c, decreciente) que en
  x=300 m llega a y=0.915 m, muy cerca ya del tirante normal y_n1=0.911 m
  (flujo prácticamente uniforme al final del tramo).
- **Cambio de sección (x=300 m):** como el enunciado indica transición suave
  sin pérdidas de carga, se conserva la **energía específica** entre el
  tirante final del tramo 1 (con m₁) y el tirante inicial del tramo 2 (con
  m₂): y_end,1 + Q²/(2g·A₁²) = y₂,ini + Q²/(2g·A₂²). Resolviendo con
  `fsolve`: **y₂,ini = 1.203 m**.
- **Tramo 2 (x=300 a 600 m):** con y=1.203 m en el inicio del tramo (entre
  y_n2=1.086 y y_c2=1.560, o sea sigue siendo supercrítico), se integra
  nuevamente la ecuación de FGV con el talud m₂. Resulta otra **curva S2**
  que decrece asintóticamente hacia y_n2, llegando a y=1.088 m en x=600 m
  (prácticamente y_n2=1.086 m).
- **Descarga al Lago B:** como h_LB=−0.50 m está por debajo del fondo del
  canal, el nivel del lago no controla nada: el canal descarga **en caída
  libre** con y≈y_n2=1.086 m (una pequeña cascada de ≈1.59 m sobre el nivel
  del Lago B).

Todo el escurrimiento permanece **supercrítico** en ambos tramos (canal tipo
S alimentado por un lago con control crítico aguas arriba, sin control
subcrítico aguas abajo) ⇒ **no hay resaltos hidráulicos** en este perfil.

Gráfico: `scripts/ej1_perfil_parte1.png`.

**Resultado final Parte 1: Q = 10.22 m³/s. Tramo 1 y Tramo 2 ambos tipo S.
Perfil: y_c1=1.357 m en x=0 → curva S2 → y≈0.915 m en x=300 m → transición
(y=1.203 m) → curva S2 en tramo 2 → y≈1.086 m (≈y_n2) en x=600 m → caída
libre al Lago B. Sin resaltos.**

**Comparación con la solución oficial:** el manuscrito da Q=10.22 m³/s,
y_c1=1.36 m, el fin del tramo 1 en y=0.915 m (idéntico), la transición en
y=1.2 m (idéntico) e y_c2=1.56 m — **coincide exactamente**. El y_n1 oficial
(0.94 m) difiere levemente del calculado (0.911 m) y el y_n2 oficial (1.09 m)
prácticamente coincide con el calculado (1.086 m); la pequeña diferencia en
y_n1 es coherente con redondeo manual al resolver la ecuación de Manning.

### Parte 2) h_LB = 2.3 m (el Lago B sube por encima del tirante crítico del tramo 2)

**Concepto.** Ahora h_LB=2.3 m > y_c2=1.560 m: el Lago B impone un control
**subcrítico** en el extremo aguas abajo del tramo 2 (Teórico §2.5.4). Sin
embargo el Lago A sigue imponiendo control crítico en la entrada (x=0),
siempre que el remanso del Lago B no llegue a "ahogar" esa sección —lo cual
se verifica después viendo que el resalto se ubica muy cerca del Lago B, sin
afectar el tramo 1 ni el inicio del tramo 2—. Por lo tanto **Q no cambia**
respecto a la Parte 1, y aparece un **resalto hidráulico** en el tramo 2 que
conecta la rama supercrítica (que viene igual que en la Parte 1) con la rama
subcrítica que nace en el Lago B.

**Herramienta:** mismo sistema de la Parte 1 para (Q, y_c1); dos integraciones
de la ecuación de FGV en el tramo 2 (`ode23` con `rect.m`/`critico.m`): una
hacia aguas abajo desde la transición (rama supercrítica S2, igual a la
Parte 1) y otra hacia aguas arriba desde el Lago B con y(x=600m)=h_LB (rama
subcrítica S1, ya que y_c2<h_LB). La posición del resalto se determina
buscando la intersección entre el **tirante conjugado** (`Mom_trap.m`,
cantidad de movimiento) de la rama supercrítica y la rama subcrítica S1.

**Script:** `scripts/ej1_parte2.m`. Mismos datos que la Parte 1, cambiando
sólo `hLB=2.3`.

**Resultado:**
```
Q = 10.224 m3/s (igual que Parte 1)
Tramo 1: identico a la Parte 1 (S2, yc1=1.357 -> 0.915 m en x=300m)
Transicion a tramo 2: y = 1.203 m (identica a la Parte 1)
Rama S1 (remanso del Lago B) solo existe entre x=258.83 m y x=300 m
  (medido dentro del tramo 2) -> se agota (llega a yc2) a 41.17 m
  aguas arriba del Lago B
RESALTO en x=286.72 m (dentro del tramo2, x=586.72 m desde el Lago A):
  y1 (antes, supercritico) = 1.089 m
  y2 (despues, subcritico) = 2.130 m
```

**Perfil de flujo:** tramo 1 idéntico a la Parte 1 (curva S2, sin cambios).
En el tramo 2, la curva supercrítica S2 continúa descendiendo prácticamente
igual que en la Parte 1 (hacia y_n2≈1.086 m) durante casi todo el tramo; sólo
en los últimos ≈13 m antes del Lago B se produce el **resalto hidráulico**,
saltando de y≈1.089 m a y≈2.130 m, y a partir de ahí una breve curva S1
(remanso) que sube suavemente desde 2.130 m hasta el nivel del Lago B, 2.30
m, en x=600 m.

Gráfico: `scripts/ej1_perfil_parte2.png`.

**Resultado final Parte 2: Q = 10.22 m³/s (sin cambios respecto a la Parte
1). Tramo 1: idéntico a la Parte 1 (curva S2, sin resalto). Tramo 2: curva
S2 (igual que Parte 1) hasta x≈586.7 m (medido desde el Lago A), luego
**resalto hidráulico** de y=1.09 m a y=2.13 m, seguido de una curva S1
(remanso) hasta y=2.30 m en el Lago B.**

**Comparación con la solución oficial:** el manuscrito ubica la rama
subcrítica S1 "se agota a 41 m del Lago B" — **coincide exactamente** con los
41.17 m calculados—, y el resalto (por conjugación de la rama S2) en
x=286.75 m con y=2.13 m dentro del tramo 2 — **coincide casi exactamente**
con los x=286.72 m, y=2.13 m calculados. Todos los valores numéricos de esta
parte coinciden con la solución oficial dentro de un margen de precisión
numérica.

### Resumen Ejercicio 1

| Ítem | Parte 1 (h_LB=−0.50 m) | Parte 2 (h_LB=2.3 m) |
|---|---|---|
| Caudal Q | **10.22 m³/s** | **10.22 m³/s** (sin cambio) |
| Tramo 1 | tipo S, y_c1=1.357 m, y_n1=0.911 m, curva S2 | idéntico a Parte 1 |
| Tramo 2 | tipo S, y_c2=1.560 m, y_n2=1.086 m, curva S2 hasta el final | S2 hasta x≈586.7 m, luego **resalto** (1.09→2.13 m), luego S1 hasta 2.30 m |
| Resalto hidráulico | **no hay** (descarga libre) | **sí**, en x≈286.7 m del tramo 2 (≈13 m antes del Lago B) |

---

## EJERCICIO 2 — Cuenca en Tacuarembó, obra de alcantarillado y embalse de retención

**Datos:** cuenca de flujo concentrado, cierre en X=500.0 km, Y=6450.0 km
(Tacuarembó). Área=7.5 km², ΔH=90 m (cauce principal), L=3800 m (long. del
cauce principal), S=1.6 % (pendiente media de la cuenca). Uso del suelo:
pastizales en condición hidrológica buena. Unidad de suelos: Cuchilla de
Haedo–Paso de los Toros (CH-PT).

**Teoría usada:** método Racional y método NRCS del Número de Curva con
hidrograma unitario sintético triangular SCS, curvas IDF de Uruguay
(Rodríguez Fontal/Genta) y sus coeficientes de corrección por duración (CD),
recurrencia (CT) y área (CA), tiempo de concentración de Ramser-Kirpich, y el
criterio de cuándo usar cada método según t_c (Teórico HHA §3.1, en
particular §3.1.2 tiempo de concentración, §3.1.4 curvas IDF y coeficientes
CD/CT/CA, §3.1.5 método Racional/NRCS, hidrograma unitario y regla de
selección de método según t_c). Herramienta: réplica en Python de las
fórmulas de `Scripts examen AA/EVENTOS EXTREMOS 2025.xlsx` (hojas "método
racional" y "NRCS"), igual que en los exámenes de 2025 y 2026 ya resueltos en
este repositorio. Los valores base de lectura gráfica (P(3,10) del mapa de
isoyetas, C de la Tabla 3.1.4 y NC de la Fig. 3.1.20) se toman directamente
de la solución oficial manuscrita adjunta al examen, que ya trae esas
lecturas.

### Parte 1) Caudal máximo de diseño de la obra de alcantarillado, Tr=5 años

**Concepto.** Antes de elegir el método hay que calcular el tiempo de
concentración t_c con la fórmula de Ramser-Kirpich (Teórico §3.1.2), usando
la pendiente del cauce principal S=ΔH/L (no la pendiente media de la cuenca,
que en cambio se usa para leer el coeficiente C de la Tabla 3.1.4 del método
Racional). El Teórico (§3.1.5) indica: si t_c<20 min ⇒ sólo Racional; si
t_c>1 h ⇒ sólo NRCS; y si **20 min<t_c<1 h ⇒ calcular ambos métodos y
adoptar el mayor** de los dos caudales, por seguridad.

**Script:** `scripts/ej2_parte1.py`. Entradas: `Area=7.5 km2, dH=90 m,
L=3800 m, Tr=5, P310=90 mm (dato oficial), NC=80 (suelo D, dato oficial),
C_racional=0.28 (dato oficial)`.

**Desarrollo:**
```
S cauce principal = ΔH/L = 90/3.8/10 = 2.37 %
tc = 0.4·L^0.77/S^0.385 = 0.802 hs = 48.1 min   (20 min < tc < 1 h)
```
Como 20 min<t_c<1 h ⇒ se calculan ambos métodos:

- **Racional** (duración=t_c): P(t_c,5)=CD·CT(5)·CA·P(3,10)=42.49 mm ⇒
  i=52.96 mm/h ⇒ **Q_racional = C·i·A/360 = 30.9 m³/s**.
- **NRCS** (tormenta de diseño por bloque alterno, dt=t_c/7=6.9 min, 12
  bloques; precipitación efectiva por Número de Curva NC=80 con piso de
  infiltración 1.2 mm/h; convolución con el hidrograma unitario triangular
  SCS, T_p=0.539 h, T_b=1.437 h, q_p=28.96 m³/s/cm): **Q_NRCS = 35.3 m³/s**.

Como Q_NRCS>Q_racional ⇒ se adopta el mayor.

**Resultado final Parte 1: Qmax de diseño (Tr=5 años) = 35.3 m³/s (método
NRCS).**

**Comparación con la solución oficial:** el manuscrito da tc=0.8 h=48 min
(idéntico), Q_racional=30.84 m³/s (vs. 30.90 calculado) y Q_NRCS=35.22 m³/s
(vs. 35.29 calculado) — **coincide** dentro de un margen de redondeo gráfico
en la lectura de las curvas IDF.

### Parte 2) Período de retorno de inundación del camino y tiempo inundado

**2.1) Tr con que se inunda el camino (Q_inund=50 m³/s).**

**Concepto.** El caudal de diseño (método NRCS) crece con Tr a través del
coeficiente CT(Tr) de las curvas IDF. Se repite el cálculo de la Parte 1 para
distintos Tr hasta encontrar aquél cuyo caudal pico iguala Q_inund=50 m³/s.

**Script:** `scripts/ej2_parte2.py`, función `hidrograma_NRCS(Tr)`
(generaliza `ej2_parte1.py` a Tr arbitrario) + búsqueda por bisección de la
raíz de Qmax(Tr)−50=0.

**Resultado:**
```
Tr=10 anios -> Qmax = 47.75 m3/s  (< 50, no inunda)
Tr=12 anios -> Qmax = 51.14 m3/s  (> 50, inunda)
Tr exacto (interpolado) = 11.29 anios
```
Como el período de retorno de diseño debe ser un valor entero (o el próximo
de la tabla de recurrencias que efectivamente supera el caudal crítico), el
camino queda fuera de servicio **a partir de Tr=12 años**.

**Comparación con la solución oficial:** el manuscrito prueba exactamente los
mismos dos valores, Tr=10 (Q=47.71 m³/s) y Tr=12 (Q=51.08 m³/s) — **coincide
casi exactamente** — concluyendo también **Tr=12 años**.

**2.2) Tiempo que permanece inundado el camino con un evento de Tr=25 años.**

**Concepto.** Se calcula el hidrograma de crecida NRCS completo para Tr=25 y
se mide gráficamente el intervalo de tiempo en que el caudal supera
Q_inund=50 m³/s.

**Resultado:** Qmax(Tr=25)=65.15 m³/s en t=1.35 h. El hidrograma supera los
50 m³/s entre t=1.127 h y t=1.737 h ⇒ **tiempo inundado ≈ 0.610 h = 36.6
min**.

Gráfico (respuesta gráfica pedida por el enunciado): `scripts/ej2_hidrograma_Tr25.png`,
mostrando el hidrograma, la recta Q_inund=50 m³/s y el área/intervalo
sombreado donde el camino queda inundado.

**Comparación con la solución oficial:** el manuscrito da Qmax=65 m³/s y
tiempo inundado=36.6 min — **coincide exactamente**.

### Parte 3) Volumen mínimo del embalse de retención

**Concepto.** El embalse debe acumular *todo* el volumen de escorrentía del
evento de diseño (Tr=25 años) para que, en el caso más exigente, el camino no
llegue a inundarse; el volumen de escorrentía total es la lámina de
precipitación efectiva acumulada (Σ Pe, calculada con el método del Número de
Curva) multiplicada por el área de la cuenca.

**Resultado:**
```
Sigma Pe (Tr=25) = 30.25 mm
Vesc = Sigma Pe * Area = 30.25 mm * 7.5 km2 = 226 896 m3
```

**Resultado final: Volumen mínimo del embalse de retención ≈ 226 900 m³.**

**Comparación con la solución oficial:** el manuscrito da Vesc=227 521 m³ —
**coincide** dentro de un margen de 0.3 %, coherente con el redondeo en la
lectura gráfica de P(3,10) y en la tormenta de diseño.

### Resumen Ejercicio 2

| Ítem | Resultado |
|---|---|
| tc (Ramser-Kirpich) | **48.1 min** |
| Qmax diseño (Tr=5, método NRCS) | **35.3 m³/s** |
| Tr al que se inunda el camino (Q=50 m³/s) | **12 años** |
| Tiempo inundado (evento Tr=25) | **36.6 min** |
| Volumen mínimo del embalse (Tr=25) | **≈226 900 m³** |

---

## EJERCICIO 3 — Cuenca en Artigas, delimitación y caudal de diseño (método Racional)

**Datos:** carta topográfica del SGM (curvas de nivel cada 10 m), punto de
cierre en X=456.7 km, Y=6600.0 km. Cuenca trazada en la Parte 1: Área=8.94
km², pendiente media=3.6 %, tiempo de concentración t_c=17 min, cubierta
mayoritariamente por pastizal.

**Teoría usada:** delimitación de cuencas por líneas de divorcio de aguas
perpendiculares a las curvas de nivel (Teórico HHA §1.2.1), hipótesis de la
tormenta de diseño del método Racional (§3.1.5 a), curvas IDF de Uruguay y
coeficientes CD/CT/CA (§3.1.4), criterio de selección de método según t_c
(§3.1.5): con t_c=17 min<20 min corresponde **únicamente el método
Racional** (no el NRCS).

### Parte 1) Delimitación de la cuenca

**Concepto (Teórico §1.2.1).** La cuenca es el área de aporte tal que toda
la lluvia caída dentro de ella escurre hacia el punto de cierre. Se delimita
trazando la **línea de divorcio de aguas** (divisoria topográfica): una
línea cerrada que pasa por los puntos más altos alrededor del punto de
cierre y que es siempre **perpendicular a las curvas de nivel**, cruzándolas
en los puntos donde éstas cambian de forma convexa (hacia aguas abajo, en
las nacientes/lomas) a cóncava (en los valles/vaguadas), de modo que encierra
exactamente la superficie que drena naturalmente hacia el punto de cierre
marcado en la carta.

**Herramienta:** delimitación gráfica manual sobre la carta topográfica
provista con el examen (SGM, curvas de nivel cada 10 m). El repositorio no
incluye la carta en blanco como archivo geográfico editable de forma
independiente (sólo el PDF escaneado del examen), por lo que —siguiendo el
mismo criterio ya usado en `resueltos/2026 Febrero` para una situación
idéntica— se describe y verifica el trazado siguiendo las reglas de
divisoria de aguas de §1.2.1, comparándolo con la delimitación de la
solución oficial adjunta al examen.

**Verificación:** la carta en blanco con el punto de cierre marcado se
guardó en `scripts/ej3_carta_sin_delimitar.png`, y la delimitación de la
solución oficial en `scripts/ej3_cuenca_solucion_oficial.png`. La divisoria
oficial sigue las lomas altas al norte y al este del arroyo que pasa por el
punto de cierre (entre las curvas de nivel de 190-200 m arriba y bajando
hacia los ~150 m en el entorno del punto de cierre), consistente con las
reglas de §1.2.1, y su área resultante es la que se usa como dato de entrada
en las Partes 2 y 3: **Área=8.94 km²**.

**Resultado final Parte 1: cuenca delimitada según divisoria de aguas
topográfica (ver `scripts/ej3_cuenca_solucion_oficial.png`), Área=8.94 km².**

### Parte 2) Tormenta de diseño del método Racional

**Concepto (Teórico §3.1.5 a).** El método Racional supone que el caudal
máximo se produce cuando toda la cuenca aporta simultáneamente, lo cual
ocurre cuando la duración de la tormenta iguala el tiempo de concentración
(momento en que la gota más alejada llega al punto de cierre) y bajo la
hipótesis simplificadora de que la tormenta tiene intensidad constante en el
tiempo y uniforme en toda el área de la cuenca.

**Resultado final Parte 2: la tormenta de diseño del método Racional es una
tormenta de intensidad constante, uniforme en toda el área de la cuenca, de
duración igual al tiempo de concentración de la cuenca.**

**Comparación con la solución oficial:** coincide textualmente con la
respuesta del manuscrito ("Tormenta de intensidad constante, uniforme en el
área de la cuenca, de duración igual a su tiempo de concentración").

### Parte 3) Caudal máximo, Tr=5 años

**Concepto.** Como t_c=17 min<20 min, el Teórico (§3.1.5) indica usar
únicamente el método Racional: Q=C·i·A/360, con la intensidad i obtenida de
las curvas IDF de Uruguay (P=CD·CT·CA·P(3,10), i=P/t_c) para duración d=t_c y
Tr=5 años. El coeficiente C (pastizal, S=3.6 %) y el valor base P(3,10)=98 mm
(isoyeta en el punto de cierre) se toman de la lectura gráfica de la
solución oficial.

**Script:** `scripts/ej3_racional.py`. Entradas: `Area=8.94 km2, tc=17 min,
Tr=5, P310=98 mm (dato oficial), C_racional=0.36 (dato oficial)`.

**Resultado:**
```
tc = 0.283 hs = 17 min  (< 20 min => solo metodo Racional)
CT(Tr=5) = 0.860 ; CD(tc) = 0.349 ; CA(tc,A) = 0.969
P = CT*CD*CA*P310 = 28.48 mm
i = P/tc = 100.50 mm/h
Q = C*i*A_ha/360 = 89.85 m3/s
```

**Resultado final Parte 3: Qmax de diseño (Tr=5 años, método Racional) =
89.85 m³/s.**

**Comparación con la solución oficial:** el manuscrito da CT=0.86, CD=0.35,
CA=0.97, P=28.47 mm, i=100.50 mm/h, Q=89.85 m³/s — **coincide exactamente**
en todos los valores.

### Resumen Ejercicio 3

| Ítem | Resultado |
|---|---|
| Delimitación de la cuenca | Ver `scripts/ej3_cuenca_solucion_oficial.png` (Área=**8.94 km²**) |
| Tormenta de diseño (método Racional) | Intensidad constante, uniforme en el área, duración=t_c |
| Qmax (Tr=5 años, método Racional) | **89.85 m³/s** |
