# Examen HHA — 27 de febrero de 2025

Resolución paso a paso. El PDF del examen (`EXAMENES/2025_FEBRERO 1.pdf`)
incluye, además de la letra (páginas 1-4), la solución oficial manuscrita
(páginas 5-10), que se usa para comparar cada resultado.

Herramientas: Octave (scripts de `Scripts/01_SCRIPTS/FGV_felo`, copiados y
adaptados en `scripts/`) para el Ejercicio 1; Python (réplica de las fórmulas
de `Scripts examen AA/EVENTOS EXTREMOS 2025.xlsx`, igual que en el examen de
2026 Febrero ya resuelto en este repositorio) para el Ejercicio 2.

Los scripts de Octave del Ejercicio 1 deben ejecutarse en orden
(`ej1_parte1.m` genera `part1.mat`, que usan `ej1_parte2.m` y `ej1_parte3.m`;
`ej1_parte2.m` genera `part2.mat`, que usa `ej1_parte3.m`). Los scripts de
Python del Ejercicio 2 también deben ejecutarse en orden (`ej2_parte1.py`
genera `part1.npz`, que usa `ej2_parte2.py`). Los archivos `.mat`/`.npz`
intermedios no se versionan.

---

## EJERCICIO 1 — Canal trapezoidal entre el Lago A y el Lago B, con restricción de tensión rasante

**Datos:** sección trapezoidal, b=2.2 m, m=1 (talud 1V:1H), n=0.013, S₀=0.01,
L=60 m. Nivel del Lago A sobre el fondo: h_LA=2.0 m. El canal termina en otro
lago (Lago B).

Teoría usada: perfiles de flujo entre dos lagos (Teórico HHA §2.5.4, en
particular el caso de canal tipo S), clasificación M/S de canales (§2.5.2),
energía específica y tirante crítico (§2.2), tensión rasante de fondo /
pendiente de energía (§2.1, §2.3), cantidad de movimiento y tirante conjugado
para el resalto hidráulico (§2.3.2–2.3.3).

### Parte 1) Caudal de descarga (h_LB=0.40 m), clasificación M/S y perfil

**Concepto.** El canal conecta dos lagos (Teórico §2.5.4). A priori no se sabe
si el flujo será tipo M o S: la guía del teórico indica que para n del orden
de 0.01 y S₀ del orden de 1 % (como en este caso, S₀=0.01) es razonable
suponer canal **tipo S**, hipótesis que se verifica después de calcular el
caudal. Para un canal S alimentado por un lago, el lago 1 (Lago A) descarga
con el **máximo caudal compatible con su energía**, estableciéndose flujo
**crítico en la sección inicial** del canal (x=0): esto ocurre porque el
tirante crítico es el que lleva el caudal máximo para una energía específica
dada. El sistema a resolver es:

```
Fr² = Q²·B(y₁)/(g·A(y₁)³) = 1        (flujo crítico en x=0, y₁=y_c)
h_LA = y₁ + Q²/(2g·A(y₁)²)            (conservación de energía Lago A → x=0)
```

**Herramienta:** sistema de 2 ecuaciones y 2 incógnitas (Q, y₁) resuelto con
`fsolve` en Octave (`trap_geom.m` para la geometría trapezoidal), más
`eq_yn.m`/`eq_yc.m` para verificar y_n e y_c una vez conocido Q. Se usa este
enfoque —en vez de `caudal_M_ini.m`— porque ese script asume canal tipo M con
tirante de entrada ≈ y_n (lago alimentando un canal largo tipo M); acá, al
verificarse canal tipo S, el control físico es muy distinto (crítico en la
entrada, no normal), por lo que se plantea el sistema específico del caso S
del Teórico §2.5.4.

**Script:** `scripts/ej1_parte1.m`. Entradas: `b=2.2, m=1, n=0.013, S0=0.01,
hLA=2.0, hLB=0.40, L=60`.

**Resultado:**
```
Q  = 17.3883 m3/s
yc = 1.4740 m
yn = 0.9748 m
```
Como y_n (0.975 m) < y_c (1.474 m) ⇒ **el canal es de tipo S (pendiente
fuerte)**, confirmando la hipótesis inicial.

**Perfil de flujo:** con y₁=y_c=1.474 m en x=0, se integró la ecuación de FGV
(`rect.m`, que usa `trap_geom.m` y por lo tanto sirve para sección
trapezoidal) con `ode23` hacia aguas abajo. Resulta una **curva S2**
(supercrítica, y_n<y<y_c, decreciente) que en x=60 m llega a y=1.088 m, sin
alcanzar aún el tirante normal (el canal es corto respecto al desarrollo
asintótico de la curva).

Como h_LB=0.40 m < y_n=0.975 m < y(x=60m)=1.088 m, el nivel del Lago B queda
por debajo de todo el rango de tirantes que trae la curva S2: el Lago B **no
afecta la descarga del Lago A** (Teórico §2.5.4, caso "y_c>y_n>y_L2"), y el
canal **descarga en caída libre** al Lago B (como una pequeña cascada de
≈0.69 m de altura, y(60)−h_LB). Todo el escurrimiento es **supercrítico**
(Fr>1 en todo el tramo, ya que 0.975<y<1.474<y_c en todo x) ⇒ **no hay
resaltos hidráulicos** en este perfil.

**Perfil de la superficie libre (x medido desde el Lago A):**
- x=0: y=y_c=1.474 m (control crítico a la salida del Lago A).
- x=0 a x=60 m: curva S2, tirante decreciendo suavemente de 1.474 m a 1.088 m
  (supercrítico en todo el tramo).
- x=60 m: caída libre al Lago B (nivel 0.40 m).

Gráfico: `scripts/ej1_perfil.png`.

**Resultado final Parte 1: Q = 17.39 m³/s, y_c = 1.474 m, y_n = 0.975 m, canal
tipo S, curva S2 en todo el canal, sin resaltos, descarga en caída libre al
Lago B.**

**Comparación con solución oficial:** el manuscrito da Q=17,39 m³/s,
y_c=1,474 m, y_n=0,975 m, canal S, curva S2, y(x=60m)=1,09 m — **coincide
exactamente**.

### Parte 2) Zonas donde la tensión rasante supera τ_max=42 Pa

**Concepto.** La tensión rasante de fondo en flujo gradualmente variado es
τ₀=γ·R·S_f, con S_f=(Q·n/(A·R^(2/3)))² la pendiente de energía (Teórico
§2.1/§2.3). Para un Q fijo, τ₀ es una función decreciente del tirante y: a
menor tirante, mayor velocidad y mayor pendiente de energía, y por lo tanto
mayor tensión de corte. Como la curva S2 de la Parte 1 tiene su tirante
mínimo (1.088 m) en el extremo aguas abajo (x=60 m, cerca del Lago B), es ahí
donde la tensión rasante será máxima.

**Herramienta:** se evaluó τ₀(y) analíticamente (misma fórmula que
`Scripts/01_SCRIPTS/Scripts examen AA/FGV_felo/rasante_max.m`, que además
está pre-cargada con los datos de este mismo ejercicio —Q=17.39, b=2.2, n=0.013,
m=1, τ_max=42— lo que confirma que es la herramienta pensada para este
problema) sobre el perfil y(x) obtenido en la Parte 1.

**Script:** `scripts/ej1_parte2.m`.

**Resultado:**
```
tau(x=0, y=yc)   = 18.02 Pa
tau(x=60, y=1.088m) = 44.55 Pa
y para el cual tau = 42 Pa: y = 1.1102 m
tau supera 42 Pa desde x = 48.34 m hasta x = 60 m
```

**Resultado final Parte 2: la tensión rasante supera 42 Pa en los últimos
≈11.7 m del canal (x≈48.3 a 60 m), es decir la zona inmediatamente anterior a
la descarga en el Lago B, donde el tirante es menor y la velocidad mayor.**

**Comparación con solución oficial:** el manuscrito da "a partir de los 49 m
→ últimos 11 m" — **coincide muy bien** con el cálculo (48.3 m, últimos
11.7 m); la pequeña diferencia (~0.7 m) es consistente con redondeo en la
lectura gráfica manual del perfil.

### Parte 3) Nivel del Lago B para que no se supere τ_max en la zona de la Parte 2

**Concepto.** El caudal Q sigue estando fijado por el control crítico en la
entrada (x=0), independiente del nivel del Lago B, mientras el resalto
hidráulico no llegue a afectar la sección 1 (Teórico §2.5.4). Si h_LB se eleva
lo suficiente, se forma una curva **S1** (subcrítica, y>y_c) que remonta desde
el Lago B, y un **resalto hidráulico** conecta la curva S2 (que llega desde el
Lago A) con la curva S1. Aguas abajo del resalto el tirante es subcrítico
(y>y_c=1.474 m), y como ya en y=y_c la tensión es sólo 18 Pa (bien por debajo
de 42 Pa), **toda la zona cubierta por la curva S1 queda automáticamente a
salvo**. Por lo tanto, el h_LB mínimo buscado es el que ubica el resalto
exactamente en el borde de la zona peligrosa hallada en la Parte 2 (x=48.34 m):
para cualquier h_LB mayor, el resalto se da más aguas arriba y toda la zona
x∈[48.34, 60] m queda cubierta por la curva S1 seguirá (segura); para h_LB
menor, parte de esa zona seguiría en la curva S2 (insegura).

**Herramienta:** se calculó, para cada punto de la curva S2 (Parte 1), su
**tirante conjugado** (rama subcrítica) con `Mom_trap.m` (cantidad de
movimiento y conjugado para sección trapezoidal). Luego, para un h_LB de
prueba, se integró la curva S1 desde x=60 m (y=h_LB) hacia aguas arriba con la
misma ecuación de FGV, y se ubicó el resalto donde la curva S1 cruza al
conjugado de la curva S2 (igualdad de cantidad de movimiento a ambos lados del
resalto). Se usó `fzero` para encontrar el h_LB tal que el resalto caiga en
x=48.34 m. Se eligieron estas funciones porque son las que provee el curso
específicamente para el cálculo de conjugados y ubicación de resaltos en
sección trapezoidal (mismo procedimiento que en el Ejercicio 1 del examen de
2026 Febrero ya resuelto en este repositorio).

**Script:** `scripts/ej1_parte3.m`.

**Resultado:**
```
yL2sup (resalto justo en x=60m, límite descarga libre) = 1.9267 m
hLB minimo requerido = 2.0599 m
Verificación: con hLB=2.06 m el resalto se ubica en x=48.34 m (coincide con el
límite de la zona peligrosa de la Parte 2)
```

Con h_LB=2.06 m el perfil queda: curva S2 desde x=0 (y_c=1.474 m) hasta
x=48.34 m (y≈1.110 m, justo el límite τ=42 Pa), **resalto hidráulico** de
y≈1.110 m a y≈1.899 m (conjugado), y luego curva **S1** subcrítica desde
x=48.34 m hasta x=60 m, terminando en y=2.06 m (nivel del Lago B). Gráfico:
`scripts/ej1_perfil_parte3.png`.

**Resultado final Parte 3: el nivel mínimo del Lago B para que no se supere
τ_max=42 Pa en la zona identificada en la Parte 2 es h_LB ≈ 2.06 m** (para
cualquier valor mayor, el resalto se ubica más aguas arriba y toda la zona
peligrosa original queda cubierta por flujo subcrítico, seguro).

**Comparación con solución oficial:** el manuscrito da h_LB=2,06 m con resalto
en x=48,5 m — **coincide casi exactamente** con el cálculo (2.0599 m, resalto
en x=48.34 m).

### Resumen Ejercicio 1

| Ítem | Resultado |
|---|---|
| Q (h_LB=0.40 m) | **17.39 m³/s** |
| y_c | **1.474 m** |
| y_n | **0.975 m** |
| Tipo de canal | **S (pendiente fuerte)** |
| Resaltos (Parte 1) | **Ninguno; descarga en caída libre** |
| Zona con τ>42 Pa | **x≈48.3 a 60 m (últimos ≈11.7 m)** |
| h_LB mínimo para evitar τ>42 Pa en esa zona | **≈2.06 m** |

Los tres resultados numéricos coinciden con la solución oficial manuscrita
dentro del margen esperable de redondeo/lectura gráfica manual.

---

## EJERCICIO 2 — Alcantarilla en cuenca de Colonia: caudal de diseño y verificación con evento observado

**Datos (Tabla 1):** Área = 5.5 km², ΔH = 80 m, L = 3715 m (cauce principal), Grupo
Hidrológico C, S = 6.5 % (pendiente media de la cuenca). Punto de cierre en
X=350 km, Y=6240 km (departamento de Colonia). Uso de suelo: pastizales, condición
hidrológica **mala**. Flujo concentrado.

Teoría usada: metodologías de caudal máximo en cuencas no aforadas — Método
Racional y Método NRCS (Teórico HHA §3.1.5), curvas IDF de Uruguay y corrección
por área/duración/período de retorno (§3.1.4), tiempo de concentración de
Ramser-Kirpich (§3.1.2), método del Número de Curva NRCS y clasificación AMC
(§3.1.5 b), hidrograma unitario sintético triangular SCS (§3.1.5 c).

**Reutilización de la herramienta:** el Ejercicio 2 del examen de 2026 Febrero
(ya resuelto en este repositorio, `resueltos/2026 Febrero/`) usa exactamente el
mismo tipo de cuenca, la misma metodología (racional + NRCS) y hasta el mismo
ΔH=80 m y L=3715 m. Se reutilizan allí los mismos scripts de Python
(`ej2_parte1.py`, `ej2_parte2.py`) que replican las fórmulas de
`Scripts/01_SCRIPTS/Scripts examen AA/EVENTOS EXTREMOS 2025.xlsx` (hojas
`método racional`, `NRCS - Gande`), adaptados ahora a los datos de este examen
(Área=5.5 km², Grupo C, S=6.5%, pastizales en condición **mala**, P₃,₁₀,ₚ e
hietograma propios).

### Parte 1) Caudal máximo de diseño (Tr = 10 años)

**Tiempo de concentración (Ramser-Kirpich, Teórico §3.1.2):**
```
tc = 0.4·L^0.77 / S^0.385      L en km, S en % (pendiente DEL CAUCE PRINCIPAL)
```
Igual que en el examen de 2026 Febrero, la pendiente del cauce principal para
Kirpich (distinta de la pendiente media de la cuenca S=6.5%, que se usa sólo
para la tabla de C) se calcula como S_cauce = ΔH(m)/L(km)/10 =
80/3.715/10 = **2.153 %**. Con L=3.715 km:

**tc = 0.818 hs = 49.1 min.**

Como 20 min < tc < 1 h, el Teórico (§3.1.5) indica calcular **ambos métodos y
diseñar con el mayor caudal**.

**P₃,₁₀,ₚ (precipitación de 3 h y Tr=10 años en el punto):** se leyó de la
Figura 3.1.10 del Teórico (isoyetas de lluvias extremas de Uruguay, cada 2 mm)
en las coordenadas X=350 km, Y=6240 km (Colonia). Se calibraron los ejes del
mapa píxel a píxel (bordes del recuadro en X=200..800 km, Y=6100..6700 km, ver
`scripts/ej2_isoyeta_P310.png`) y se ubicó el punto: cae al sur-oeste de la
isoyeta gruesa de 90 mm, entre la 3ª y 4ª isoyeta fina por debajo de ésta
(≈84 mm y ≈82 mm respectivamente), más cerca de la de 84 mm ⇒
**P₃,₁₀,ₚ ≈ 83.5 mm** (mismo valor que usa la solución oficial manuscrita).

**NC (pastizales, condición hidrológica mala, grupo C):** de la Tabla/Figura
3.1.20 del Teórico (fila "Pradera o pastizal", columna "Mala", grupo C) ⇒
**NC = 86**.

**C (coeficiente de escorrentía, método racional):** de la Tabla 3.1.4
(Pastizales, pendiente "Promedio 2-7 %" — con la S=6.5% de la cuenca, que cae
en ese rango —, Tr=10 años) ⇒ **C = 0.38**.

**Herramienta y resultados (`ej2_parte1.py`):** réplica en Python de las
fórmulas de la planilla de eventos extremos (igual que en el examen de 2026
Febrero, ver esa resolución para el detalle del proceso de validación de la
planilla con `openpyxl`), por no disponer en este entorno de Excel/LibreOffice
con recálculo interactivo.

```
tc = 0.8178 hs = 49.07 min      CT(Tr=10) = 1.0000  (por definición, Tr=10 es la base)

MÉTODO RACIONAL:
  d = tc = 0.818 hs ; CD = 0.5634 ; CA = 0.9879
  P(d,10,p) = 46.47 mm ; i = 56.82 mm/h
  Qmax racional = 32.99 m³/s

MÉTODO NRCS:
  Tormenta de diseño (bloque alterno, Δt=tc/7=7.01 min, 12 bloques): pico
  central de 18.56 mm, total 59.17 mm en 84.1 min.
  S = 41.35 mm ; Ia = 8.27 mm (NC=86)
  Precipitación efectiva total (corregida) = 28.08 mm
  Hidrograma unitario triangular: tr=0.1168 hs, Tp=0.5491 hs, Tb=1.4645 hs,
  qp=20.83 m³/s/cm
  Qmax NRCS = 43.60 m³/s (en t=1.37 hs desde el inicio de la tormenta)
```

**Se adopta el mayor: caudal de diseño Q₁₀ = 43.6 m³/s (método NRCS).**

**Comparación con solución oficial:** el manuscrito da P(3,10)=83,5 mm, NC=86,
tc=0,818 hs=49 min, C=0,38, Qrac=33,0 m³/s, Qnrcs=43,4 m³/s — **coincide
prácticamente exacto** con todos los valores calculados (la mínima diferencia
en Qnrcs, 43.6 vs 43.4, es coherente con redondeos intermedios en el cálculo
manual del hidrograma unitario).

### Parte 2) Evento de precipitación observado

**Datos:** hietograma en bloques de 7 min (mismo Δt que el hidrograma unitario
de la Parte 1): P(mm) = 1.6, 3.2, 4.1, 5.8, 8.7, 12.2, 21.7, 10.5, 6.2, 4.6,
3.6, 2.0 (bloque máximo 21.7 mm entre minuto 42 y 49). Evento en verano
(estación de crecimiento), precipitación acumulada 5 días previos = 49 mm.

**Herramienta:** se reutilizan las mismas funciones IDF de la Parte 1
(`ej2_parte2.py`) para 2.1, y el mismo método NC + hidrograma unitario
triangular SCS de la Parte 1 para 2.2, aplicados ahora al hietograma
*observado* (en su orden cronológico real, sin reordenar por bloque alterno).

#### 2.1) Período de retorno de la intensidad máxima del evento

**Concepto:** igual que en el examen de 2026 Febrero, la intensidad promedio es
máxima para la menor duración posible que contenga el pico; con datos en
bloques fijos de 7 min, el bloque de 21.7 mm (42-49 min) da la mayor intensidad
media (186.0 mm/h) de cualquier ventana. Se usa CA=1 porque el dato es de un
pluviómetro puntual de la cuenca, no una lluvia de diseño de área.

**Desarrollo:** con d=7 min=0.1167 hs, CD(d)=0.2285, y P(d,Tr,p)=21.7 mm:
```
CT(Tr) = 21.7 / (83.5 · 0.2285 · 1) = 1.1374
```
Invirtiendo CT(Tr)=0.5786-0.4312·log₁₀(ln(Tr/(Tr-1))) numéricamente (bisección):

**Tr = 20.3 años ≈ 20 años.**

**Comparación con solución oficial:** el manuscrito da CT(Tr)=1,14 y Tr=20 años
— **coincide** con el cálculo (CT=1.1374, Tr≈20.3 años).

#### 2.2) Caudal máximo durante el evento

**Concepto — condición de humedad antecedente (AMC):** el NRCS clasifica la
humedad antecedente según la precipitación de los 5 días previos y la estación
(Teórico, Fig. 3.1.21). El evento es en verano, estación de crecimiento, donde
el rango de AMC II (condición media, sin corregir el NC) es 35.6–53.3 mm
(1.4–2.1 pulgadas). Como P₅d=49 mm cae dentro de ese rango ⇒ **AMC II ⇒ se usa
NC=86 sin corregir** (no hace falta aplicar las fórmulas de NC(I)/NC(III)).

**Desarrollo:** con S=41.35 mm e Ia=8.27 mm (iguales a la Parte 1, mismo NC), se
aplicó el método NC de forma incremental sobre la precipitación acumulada real
del evento, con la misma corrección de piso de infiltración (1.2 mm/h, grupo D
como piso general para grupos B/C/D) de la Parte 1. La precipitación efectiva
total resulta 49.16 mm. Se convolucionó con el mismo hidrograma unitario
triangular de la Parte 1 (misma cuenca ⇒ mismo tc, Tp, Tb, qp).

**Qmax evento = 77.95 m³/s ≈ 78.0 m³/s**, en t≈1.37 hs desde el inicio del
evento.

**Comparación con solución oficial:** el manuscrito indica Qmax=77.5 m³/s
(NRCS) — **coincide muy bien** con el cálculo (77.95 m³/s, diferencia <1%).

#### 2.3) ¿Se superó la condición de diseño? ¿Durante cuánto tiempo?

**Concepto:** se compara el hidrograma del evento observado (2.2) con la
capacidad de diseño de la alcantarilla (Q₁₀=43.60 m³/s, Parte 1) y se mide el
intervalo de tiempo en que el caudal generado supera esa capacidad.

**Desarrollo:** del hidrograma de 2.2, Q(t) > 43.60 m³/s entre t=1.00 hs y
t=1.87 hs (desde el inicio del evento).

**Sí, la condición de diseño se vio sobrepasada, entre t≈1.00 h y t≈1.87 h,
durante T ≈ 0.87 hs ≈ 52 min.**

**Comparación con solución oficial:** el manuscrito da, mirando el hidrograma,
"entre 1 hr y 1,92 hs → 55 minutos" — **coincide razonablemente** con el
cálculo (1.00 a 1.87 hs, 52 min); la diferencia de unos pocos minutos es
esperable dado que la solución oficial hace una lectura gráfica manual del
hidrograma mientras que el cálculo aquí interpola numéricamente el cruce con
Q_diseño.

### Resumen Ejercicio 2

| Ítem | Resultado |
|---|---|
| tc | **49.1 min** |
| P₃,₁₀,ₚ (Colonia, isoyetas) | **83.5 mm** |
| NC (pastizales, mala, C) | **86** |
| Q racional (Tr=10) | **33.0 m³/s** |
| Q NRCS (Tr=10) — adoptado | **43.6 m³/s** |
| Tr de la intensidad máxima del evento | **20.3 años** |
| AMC del evento | **II (medio)** |
| Qmax durante el evento | **78.0 m³/s** |
| ¿Se supera la obra? | **Sí, ≈52 min (t=1.00 a 1.87 hs)** |

Todos los resultados numéricos coinciden con la solución oficial manuscrita,
con diferencias menores esperables por redondeo y lectura gráfica manual.

---

## EJERCICIO 3 — Delimitación de cuenca (carta SGM) e hidrograma unitario triangular del NRCS

**Datos:** carta topográfica SGM (curvas de nivel cada 10 m), punto de cierre
en X=498.8 km, Y=6283.6 km (departamento de Florida). Área de la cuenca
A=3.21 km², tiempo de concentración tc=0.76 hs. Hietograma de precipitación
efectiva en bloques de D=5 min: T(min)=0-5/5-10/10-15, P_ef(mm)=0/2.3/0.

Teoría usada: definición de cuenca y divisoria de aguas topográfica (Teórico
§1.2.1), definición de hidrograma unitario (§3.1.5 c, primer párrafo),
hidrograma unitario sintético triangular del NRCS/SCS (§3.1.5 c).

### Parte 1) Delimitación de la cuenca

**Concepto (Teórico §1.2.1):** la cuenca es el área tal que toda la lluvia
que cae sobre ella escurre hacia el mismo punto de cierre; la divisoria de
aguas es la línea que une los puntos de mayor cota topográfica entre la
cuenca y las cuencas vecinas. Reglas de trazado sobre una carta con curvas de
nivel: la divisoria corta ortogonalmente a las curvas de nivel; al ganar
altura lo hace por el lado convexo de la curva (cresta) y al perder altura
por el lado cóncavo (vaguada de la cuenca vecina); nunca cruza un curso de
agua salvo en el propio punto de cierre.

**Nota de transparencia:** el repositorio no incluye la carta topográfica en
blanco como archivo independiente; la única versión disponible es la que
figura en la solución oficial manuscrita (página 7 del PDF del examen,
guardada aquí como `scripts/ej3_cuenca_solucion.png`), que ya trae la
divisoria dibujada. Por lo tanto no fue posible re-delimitar la cuenca de
forma ciega e independiente; se describe a continuación la divisoria tal
como surge de esa carta, verificando que respeta las reglas de trazado de
§1.2.1 (para dejar constancia del razonamiento, no simplemente copiar el
resultado). Este es el mismo criterio de transparencia usado para la Parte 1
del Ejercicio 3 del examen de 2026 Febrero, ya resuelto en este repositorio.

**Descripción de la divisoria (a partir de la carta citada):** el punto de
cierre se ubica sobre el Arroyo Timote, en la zona de cota ≈110-120 m, justo
al pie de una pequeña laguna y de la loma donde se encuentra el paraje
"M. Canapá". Desde el punto de cierre la divisoria sube por la ladera oeste,
cortando perpendicularmente las curvas de nivel 120→130→140, bordea por el
oeste el paraje "M. Canapá" y el punto acotado ×131, y continúa hacia el
sur-oeste manteniéndose sobre la línea de cresta (curva 140→130) hasta un
punto alto cerca de ×143 (al sur), que es el punto de mayor cota entre esta
cuenca y la cuenca vecina que drena hacia el sur. Desde ahí la divisoria gira
hacia el este y luego al norte, volviendo a subir por cota (130→120) bordeando
por el este el nacimiento de la cuenca (cerca de ×101, al norte del Arroyo
Timote), para finalmente descender de nuevo por la ladera este hasta el punto
de cierre sobre el Arroyo Timote, cerrando el polígono. El área encerrada no
cruza en ningún tramo un curso de agua salvo en el punto de cierre,
consistente con la regla del Teórico §1.2.1.

**Resultado final Parte 1: la cuenca queda delimitada por la divisoria
topográfica mostrada en la solución oficial (polígono cerrado en torno al
paraje "M. Canapá", entre las curvas de nivel 110 y 143 m, con el punto de
cierre sobre el Arroyo Timote en X=498.8 km, Y=6283.6 km); el trazado es
consistente con las reglas de §1.2.1 verificadas arriba.** El área resultante
(A=3.21 km², dato reutilizado en la Parte 2 de este mismo ejercicio) no se
vuelve a medir aquí por no disponer de la carta en formato digital/vectorial
para planimetrar.

### Parte 2.1) Definición de hidrograma unitario

**Concepto (Teórico §3.1.5 c):** el hidrograma unitario de una cuenca es el
**hidrograma de escorrentía directa** resultante de una **unidad de
precipitación efectiva** (1 mm, o 1 cm según la convención), distribuida
**uniformemente sobre el área de la cuenca**, a una **tasa constante**, a lo
largo de una **duración determinada** D.

### Parte 2.2) Hidrograma unitario triangular del NRCS

**Concepto:** el NRCS propone una forma sintética triangular para el
hidrograma unitario, caracterizada por 3 parámetros: el tiempo al pico Tp, el
tiempo base Tb, y el caudal pico Qp, todos función del área de la cuenca, el
tiempo de concentración tc y la duración D del pulso de lluvia efectiva
(Teórico §3.1.5 c):

```
Tp = D/2 + 0.6·tc
Tb = (8/3)·Tp          (= 2.667·Tp)
Qp = 0.208·A/Tp         (m3/s por mm de lluvia efectiva; A en km2, Tp en hs)
```

**Herramienta:** cálculo directo (`scripts/ej3_hidrograma_unitario.py`), sin
necesidad de `fsolve` ni iteración: es una fórmula cerrada una vez conocidos
A, tc y D. Se usa Python en vez de reescribir a mano el mismo cálculo que ya
está automatizado en el Ejercicio 2 (`ej2_parte1.py`) para el hidrograma
unitario de esa cuenca, reutilizando la misma lógica de convolución.

**Resultado (`ej3_hidrograma_unitario.py`), con A=3.21 km², tc=0.76 hs,
D=5 min=0.0833 hs:**
```
Tp = 0.4977 hs = 29.86 min  (~ 0.5 hs)
Tb = 1.3271 hs = 79.63 min  (~ 1.33 hs)
Qp = 1.3416 m3/s por mm de Pe  (~ 1.34 m3/s.mm)
```

**Comparación con solución oficial:** el manuscrito da Tp=0.5 hs, Tb=1.33 hs,
Qp=1.34 m³/s.mm — **coincide exactamente** (las diferencias de la 3ª cifra
decimal en Tp y Tb son solo redondeo de presentación).

### Parte 2.3) Hidrograma del evento en el punto de cierre

**Concepto:** el hidrograma de escorrentía directa del evento se obtiene
convolucionando el hidrograma unitario (Parte 2.2, la respuesta a 1 mm de
lluvia efectiva durante D=5 min) con la serie de precipitación efectiva del
hietograma dado. Como sólo el bloque central (T=5-10 min, Pe=2.3 mm) tiene
lluvia efectiva no nula (los bloques 0-5 y 10-15 min tienen Pe=0), la
convolución se reduce a un único término: el hidrograma unitario escalado por
2.3 mm y desplazado a partir de t=5 min (inicio del bloque con lluvia).

**Desarrollo:** con Qp=1.3416 m³/s.mm,
```
Qmax = Qp · Pe_bloque = 1.3416 · 2.3 = 3.086 m³/s
```
en t = 5 min (inicio del bloque) + Tp = 29.86 min ⇒ **t ≈ 35 min** desde el
inicio de la tormenta.

**Perfil completo del hidrograma** (triangular, escalado): sube desde Q=0 en
t=5 min hasta Qmax≈3.08 m³/s en t=35 min, y desciende hasta Q≈0 en
t = 5 min + Tb ≈ 85 min. Puntos cada 5 min (script):
```
t=10min: Q=0.52   t=20min: Q=1.55   t=30min: Q=2.58   t=35min: Q=3.08 (pico)
t=40min: Q=2.77    t=50min: Q=2.15   t=60min: Q=1.53   t=80min: Q=0.29
```

**Resultado final Parte 2.3: Qmax ≈ 3.08-3.09 m³/s en t≈35 min desde el
inicio de la tormenta; el hidrograma es un triángulo escalado (por Pe=2.3 mm)
del hidrograma unitario de la Parte 2.2, ya que sólo un bloque del hietograma
tiene lluvia efectiva no nula.**

**Comparación con solución oficial:** el manuscrito da
Qmax=Qp·Pef=1.34·2.3=**3.09 m³/s**, con el hidrograma dibujado subiendo desde
t=5 min hasta el pico en t=35 min y bajando hasta t≈80 min — **coincide
prácticamente exacto** (3.086-3.09 m³/s según redondeo intermedio de Tp; el
"t≈80 min" del dibujo manual es una simplificación gráfica del valor exacto
t≈85 min que da Tb=79.63 min sin redondear).

### Resumen Ejercicio 3

| Ítem | Resultado |
|---|---|
| Delimitación de la cuenca | **Ver descripción y carta oficial (nota de transparencia arriba)** |
| Definición de hidrograma unitario | **Hidrograma de escorrentía directa por 1 unidad de lluvia efectiva uniforme en área y tasa, en una duración D** |
| Tp / Tb / Qp (hidrograma unitario triangular NRCS) | **0.50 hs / 1.33 hs / 1.34 m³/s·mm** |
| Qmax del hidrograma del evento | **≈3.08-3.09 m³/s en t≈35 min** |

Las Partes 2.2 y 2.3 (cálculo numérico) coinciden con la solución oficial. La
Parte 1 (delimitación de la cuenca) se resolvió describiendo y verificando el
trazado de la carta oficial, ya que el repositorio no incluye la carta
topográfica en blanco como archivo aparte para re-delimitarla de forma
independiente.

---
