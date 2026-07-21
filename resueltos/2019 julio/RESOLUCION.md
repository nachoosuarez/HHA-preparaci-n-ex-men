# Examen HHA — 22 de julio de 2019

Fuente: `EXAMENES/2019 julio.pdf` (8 páginas: letra, páginas 1-3, +
solución oficial manuscrita completa, páginas 4-8, escaneadas — PDF sin
texto, se leyó renderizando cada página a PNG con `pdftoppm`). Los 4
ejercicios son:
1) FGV en canal TRAPEZOIDAL de dos tramos (distinta pendiente Y
   rugosidad) entre dos lagos (25 pts);
2) infiltración de Horton y tiempo de encharcamiento de un evento (20 pts);
3) caudal de diseño NRCS de una cuenca en Florida con uso de suelo mixto,
   período de retorno de un evento observado y verificación con AMC (30 pts);
4) sistema de bombeo de dos bombas iguales en paralelo, con regulación
   por válvula (25 pts).

Este examen trae **solución oficial manuscrita completa** para los 4
ejercicios (páginas 4-8 del PDF), que se usa para comparar cada resultado.

---

## Ejercicio 1 — FGV en canal trapezoidal de dos tramos entre dos lagos

### Enunciado (resumen)

Dos lagos se conectan por un canal TRAPEZOIDAL (ancho de fondo b=3.8 m,
talud m=1H:1V) con dos tramos de distinta rugosidad y pendiente:
- Tramo 1: L1=35 m, S01=0.018, n1=0.017 (corto y empinado).
- Tramo 2: L2=1000 m, S02=0.0006, n2=0.01 (largo y suave).

El Lago A tiene nivel hLA=2.0 m sobre el fondo del canal (x=0).

1) Con hLB=2.6 m (Lago B, x=L1+L2): calcular el caudal de descarga,
   clasificar cada tramo en M/S y dibujar la superficie libre, ubicando
   tirantes relevantes y resaltos si los hubiera.
2) Con hLB variable: hallar el rango de niveles del Lago B para el cual
   ocurre un resalto hidráulico en el **tramo 2**.

### Teoría (RESUMEN_TEORICO.md, sección A — FGV)

- **A1** Clasificación M/S: yn (Manning) vs. yc (Froude=1).
- **A4** "Canal de dos tramos con distinta pendiente" (2023 dic, Ej.1):
  se prueba primero la hipótesis más simple (tramo de entrada steep ⇒
  control crítico directo en x=0, Q en forma cerrada/semi-cerrada) y se
  verifica que sea autoconsistente (yn1<yc con ese Q). Acá, además de la
  pendiente, cambia también la rugosidad de Manning entre tramos — el
  razonamiento es idéntico, sólo cambia qué par (S,n) se usa en cada
  tramo para yn y para integrar la EDO de FGV.
- **A4** "Control crítico en la entrada, sección trapezoidal (sin forma
  cerrada)" (2023 jul, Ej.1): en trapezoidal, yc(Q) no tiene forma
  cerrada — se anida `fsolve` (yc dado Q) dentro de un `fzero` externo en
  Q hasta que la energía en yc iguale hLA.
- **A3** Ubicación de un resalto: comparar, en la misma sección x, el
  conjugado (`Mom_trap`) de la rama supercrítica con el valor real de la
  rama subcrítica que llega desde aguas abajo, extendida (si hace falta)
  con la pendiente/rugosidad del tramo donde se busca el resalto.

Cita: Teórico HHA §2.3.1-§2.3.3, §2.5.3-§2.5.6; Formulómetro "Flujo
Gradualmente Variado" / "Cantidad de Movimiento" / "Energía".

### Herramienta y por qué

Se usó Octave con el toolkit canónico `RESUMEN EXAMEN/Codigos/FGV_trapezoidal`
(`trap_geom`, `eq_yc`+`fsolve` —yc—, `eq_yn`+`fsolve` —yn—, `Mom_trap`
—conjugado/resalto—, `rect.m`+`ode45` —integración de las curvas M/S,
pese al nombre "rect" es la EDO trapezoidal—, `critico.m` como evento de
parada, `control_critico_lago_trap.m` —control crítico en la entrada,
Q sin forma cerrada— ) porque el enunciado es un problema de FGV en canal
trapezoidal con controles en ambos extremos (dos lagos) y dos tramos de
distinta pendiente/rugosidad — exactamente el caso de uso de ese
toolkit; no hizo falta ninguna función nueva, sólo encadenar las
funciones existentes con cada tramo. Script completo:
`resueltos/2019 julio/scripts/Ejercicio1_dos_lagos_dostramos_trap.m` (+
todo el toolkit `FGV_trapezoidal` copiado al mismo directorio como
dependencias).

### Paso a paso

**Parte 1) hLB = 2.6 m.**

Se prueba la hipótesis más simple: tramo 1 steep ⇒ control crítico en la
entrada (x=0), con energía E(yc)=hLA (sección trapezoidal, sin forma
cerrada ⇒ `fzero` en Q anidando `fsolve` en yc):

```
yc(Q) tal que  Q²·(b+2m·yc) / (g·(yc·(b+m·yc))³) = 1        (eq_yc.m)
E(yc) = yc + Q² / (2g·A(yc)²) = hLA = 2.0 m                  (fzero en Q)

=>  Q = 25.00 m³/s  ;  yc = 1.436 m
```

Verificación de autoconsistencia (Manning en cada tramo, con ese Q):

```
yn1 (S01=0.018, n1=0.017) = 0.890 m   <  yc=1.436 m  =>  TRAMO 1 TIPO S  ✓ (consistente)
yn2 (S02=0.0006, n2=0.01) = 1.731 m   >  yc=1.436 m  =>  TRAMO 2 TIPO M
```

El lago A descarga entonces su caudal máximo **sin que importe** lo que
pase aguas abajo (salvo que el Lago B llegue a ahogar la entrada — se
verifica más abajo que no es el caso).

Se integra la curva supercrítica S2 en el tramo 1 (x: 0→35 m, desde yc):

```
y_S2(x=0) = yc = 1.436 m  ->  y_S2(x=35 m) = 1.021 m   (yn1=0.890 m, aún no lo alcanza en 35 m)
conjugado(y_S2 en x=35 m) = 1.935 m       (Mom_trap)
```

Se integra la curva subcrítica del tramo 2, hacia atrás desde el Lago B
(hLB=2.6 m > yc, controla la salida con y(x=1035)=hLB):

```
y_tramo2(x=1035 m) = 2.600 m (control)  ->  y_tramo2(x=35 m) = 2.112 m
```

Comparación en la unión de tramos (x=35 m): 2.112 m (subcrítico, tramo 2)
**>** 1.935 m (conjugado de S2) ⇒ el resalto está **dentro del tramo 1**
(la rama subcrítica "empuja" hacia atrás, más allá de la unión). Se
extiende la curva subcrítica hacia atrás dentro del tramo 1 (con S01,n1,
parando en yc por evento) y se cruza contra el conjugado de S2 en la
misma malla de x:

```
RESALTO en x = 26.0 m (medido desde el Lago A, dentro del tramo 1 de 35 m):
   y1 = 1.05 m  (supercrítico, antes)  ->  y2 = 1.89 m  (subcrítico, después)
```

**Resultado Parte 1: Q = 25.00 m³/s** · Tramo 1 tipo **S** (yn1=0.89 m) ·
Tramo 2 tipo **M** (yn2=1.73 m) · **resalto en el tramo 1**, en x≈26.0 m
desde el Lago A (y: 1.05 m → 1.89 m), seguido de una curva M1 casi
constante (≈1.9-2.1 m) hasta el Lago B. Gráfico:
`resueltos/2019 julio/scripts/perfil_parte1.png`.

**Comparación con la solución oficial:** coincide muy bien — Q=25 m³/s
(idéntico), yc≈1.43 m, yn1≈0.89 m, yn2≈1.73 m, y_S2(x=35m)≈1.02 m,
conjugado≈1.93 m, tirante en la unión con el tramo 2≈2.11 m, y_2 tras el
resalto≈1.89 m (todos coinciden a 2-3 cifras significativas); la posición
del resalto x≈26.0 m está muy cerca del x=26.15 m manuscrito (diferencia
<1%, atribuible a redondeo en la lectura gráfica de la solución oficial).

**Parte 2) Rango de hLB para el cual hay resalto en el tramo 2.**

Q, yc, yn1 y yn2 no cambian con hLB (el control de entrada sigue siendo
crítico en x=0 mientras el Lago B no ahogue esa sección). El resalto cae
en el tramo 2 si y sólo si el valor de la curva subcrítica del tramo 2 en
la unión (x=35 m) es **menor** que el conjugado de la curva S2 ahí mismo
(1.935 m, fijo); si fuera mayor, el resalto se corre al tramo 1 (caso de
la Parte 1). El caso límite es cuando ambos coinciden exactamente en
x=35 m: se integra la curva subcrítica del tramo 2 **hacia adelante**
desde ese valor límite (x=35 m) hasta el Lago B (x=1035 m) para hallar el
hLB umbral:

```
y(x=35 m) = conjugado(S2) = 1.935 m  ->  integrando hacia adelante (S02,n2) hasta x=1035 m:
hLB_umbral = 2.354 m
```

Chequeo adicional: si hLB baja hasta yc=1.436 m o menos, el Lago B deja de
controlar la salida (pasa a **caída libre**, y(x=1035)=yc); se verificó
que aún en ese caso el tirante que llega a la unión (1.723 m) sigue siendo
menor que el conjugado de S2 (1.935 m) — el resalto **permanece en el
tramo 2** para cualquier hLB por debajo del umbral, sin cota inferior.

**Resultado Parte 2: hay resalto hidráulico en el tramo 2 para
hLB < 2.35 m** (para 1.44 m < hLB < 2.35 m el Lago B controla la salida
directamente; para hLB ≤ 1.44 m la salida es caída libre, pero el resalto
sigue estando en el tramo 2 en ambos casos — recién por encima de
2.35 m el resalto se corre al tramo 1, como en la Parte 1).

**Comparación con la solución oficial:** coincide exactamente — el
manuscrito da como umbral hLB=2.35 m y concluye "RANGO → hLB < 2.35 m"
(sin cota inferior), igual que este cálculo.

---

## Ejercicio 2 — Infiltración de Horton y tiempo de encharcamiento

### Enunciado (resumen)

1) Definir qué se entiende por tiempo de encharcamiento de una cuenca.
2) Cuenca de Área=5.3 km², Lcp=2.3 km, ΔH=45 m, con un evento de
   precipitación en bloques de 30 min: P = 3, 5, 31, 6, 3, 1 mm (0-30,
   30-60, 60-90, 90-120, 120-150, 150-180 min). Modelo de Horton con
   f0=7.6 mm/h, fc=0.4 mm/h, k=0.5 1/h.
   a) Tiempo de encharcamiento del evento.
   b) Evolución temporal de la tasa de infiltración real (graficar).
   c) Volumen de escorrentía del evento (mm).

### Teoría (RESUMEN_TEORICO.md §B8 — Infiltración de Horton)

**Concepto (parte 1).** El tiempo de encharcamiento es el lapso entre el
inicio de la lluvia y el instante en que el agua empieza a encharcar en
la superficie del terreno — a partir de ahí la intensidad de
precipitación supera la tasa de infiltración potencial del suelo.

**Fórmulas (parte 2):**

```
f(t) = fc + (f0-fc)·e^(-k·t)                    (capacidad de infiltración de Horton)
Criterio: comparar, al inicio de cada bloque, I(bloque)=P/Δt contra f(t_inicio):
  I < f  =>  bloque lluvia-limitado (infiltra 100%, tasa real = I)
  I >= f =>  bloque capacidad-limitado (tasa real = f(t), integrada en el intervalo)
Vinf = Σ infiltración de cada bloque ; Vesc = P_total - Vinf
```

Cita: Teórico HHA §3.1.3 (infiltración, modelo de Horton); Formulómetro
"Agua en el Suelo — Curva de infiltración de Horton".

### Herramienta y por qué

Se usó Python (sin ningún toolkit de Octave — es álgebra cerrada de
Horton, sin geometría de canal ni de cuenca de por medio), replicando el
patrón ya usado en `resueltos/2023 febrero_2/scripts/ej2.py` (parte 2.2,
mismo modelo de Horton): se tabula f(t) en el inicio de cada bloque, se
compara contra la intensidad I=P/Δt de ese bloque para hallar el primer
cruce (tiempo de encharcamiento), y se integra analíticamente f(t) en
los bloques capacidad-limitados (en vez de aproximar el área con la
regla del trapecio sobre los valores redondeados de la tabla, como hace
a mano la solución oficial) para un volumen infiltrado más preciso.
Script: `resueltos/2019 julio/scripts/Ejercicio2_Horton.py` (incluye
también el gráfico de la tasa de infiltración real, parte b).

### Paso a paso

**Parte 1)** Definición de tiempo de encharcamiento (ver Teoría arriba).

**Parte 2.a) Tiempo de encharcamiento.**

```
t(h)  f(t) mm/h   bloque      I=P/0.5h mm/h   ¿I>=f(t_ini)?
0.0     7.60      0.0-0.5 h        6.0         no  (lluvia-limitado)
0.5     6.01      0.5-1.0 h       10.0         SI  -> ENCHARCA en t=0.5 h
1.0     4.77      1.0-1.5 h       62.0         SI
1.5     3.80      1.5-2.0 h       12.0         SI
2.0     3.05      2.0-2.5 h        6.0         SI
2.5     2.46      2.5-3.0 h        2.0         (ya encharcado, sigue capacidad-limitado)
```

**Resultado 2.a): t_enc = 0.5 h.**

**Parte 2.b) Evolución de la tasa de infiltración real.**

Bloque 0-0.5h (lluvia-limitado): tasa real = I = 6.0 mm/h (constante).
Desde t=0.5h en adelante (capacidad-limitado, se mantiene así el resto
del evento aunque I vuelva a caer por debajo de f en el último bloque —
ya hay agua encharcada infiltrando a la capacidad del suelo): tasa real
= f(t), decreciente: 6.01, 4.77, 3.80, 3.05, 2.46 mm/h en t=0.5, 1, 1.5,
2, 2.5 h. Gráfico: `resueltos/2019 julio/scripts/infiltracion_real.png`.

**Parte 2.c) Volumen de escorrentía.**

```
Bloque         tipo                 Infiltración (mm)
0.0-0.5 h      lluvia-limitado           3.00   (=I·Δt=P)
0.5-1.0 h      capacidad-limitado        2.68   (integral de f(t))
1.0-1.5 h      capacidad-limitado        2.13
1.5-2.0 h      capacidad-limitado        1.71
2.0-2.5 h      capacidad-limitado        1.37
2.5-3.0 h      capacidad-limitado        1.11
                                   -----------
                       Infiltración total = 12.00 mm

P_total = 3+5+31+6+3+1 = 49 mm
Vesc = P_total - Inf_total = 49 - 12 = 37 mm
```

**Resultado 2.c): Vesc = 37 mm.**

**Comparación con la solución oficial:** coincide exactamente —
t_enc=0.5h (idéntico); f(t) tabulado idéntico (7.6, 6, 4.76, 3.81, 3.05,
2.46, 2.00 mm/h en t=0,0.5,...,3h); infiltración total=12mm/Vesc=37mm
(idénticos). La solución oficial integra f(t) con la regla del trapecio
sobre los valores redondeados de la tabla (3+2.69+2.14+1.715+1.4+1.1=12mm),
mientras que este cálculo integra f(t) analíticamente en cada bloque
(2.68, 2.13, 1.71, 1.37, 1.11 mm) — la diferencia es de milésimas de mm
por bloque y ambos redondean al mismo total de 12mm.

---

## Ejercicio 3 — Caudal de diseño NRCS con NC ponderado, Tr de un evento y AMC

### Enunciado (resumen)

Cuenca en Florida (X=480000 m, Y=6250000 m), Área=75 km², Lcp=12500 m,
ΔH=70 m, S media=1.8%. Uso de suelo: 75% pastizales + 25% cultivo en
hileras rectas, ambos en condición hidrológica **buena**; suelo
predominante **Cerro Chato**; flujo concentrado.

1) Caudal de diseño de una obra de drenaje (pequeño puente) para
   Tr=100 años. Justificar la metodología.
2) Ocurre un evento registrado (hietograma de 12 bloques de 0.5 h: P=3,
   5, 8, 10, 13, 21, 49, 16, 9, 7, 5, 3 mm):
   a) Período de retorno de la intensidad máxima del evento.
   b) Caudal máximo en el punto de cierre para ese evento, sabiendo que
      la precipitación acumulada en los 5 días previos (junio) fue de
      62 mm. Verificar si se sobrepasó la condición de diseño.

### Teoría (RESUMEN_TEORICO.md §B1-B6)

- **B1** "Cerro Chato" → Grupo Hidrológico **B** (Tabla 3.1.5 del
  Teórico, verificado con `pdftotext` sobre `Teórico HHA.pdf`).
- **B2** Kirpich: tc = 0.4·L^0.77/S^0.385, con S=ΔH/L/10 del cauce
  principal (no la pendiente media de la cuenca, que es sólo un dato
  extra sin uso en este ejercicio, ya que no se pide el método
  Racional — ver B4 criterio de selección).
- **B4** Criterio de selección de método: tc>1h ⇒ **sólo NRCS**.
- **B5** Número de Curva **ponderado** por uso de suelo mixto
  (NC_ponderado = Σ fracción·NC_i, Fig. 3.1.20 del Teórico según uso,
  tratamiento, condición hidrológica y grupo B).
- **B3** Inversión de Tr de un evento observado: CT=P/(P310·CD·CA),
  invertir CT(Tr) numéricamente. Con **CA incluido** (a diferencia de
  un dato puntual de pluviógrafo) porque este evento está registrado
  sobre **toda la cuenca de aporte** (el mismo que genera el caudal en
  el punto de cierre en la parte b), no es una lectura puntual.
- **B6** AMC: con P5d y estación (activa/inactiva) se determina AMC
  I/II/III y se corrige el NC de tabla.

Cita: Teórico HHA §3.1.2, §3.1.4, §3.1.5, §3.1.6, Tabla 3.1.5 (grupos
hidrológicos de suelos), Fig. 3.1.20 (Número de Curva); Formulómetro
"Eventos extremos".

### Herramienta y por qué

Se usó Python (replicando la lógica de la hoja **"Cálculos (chica)"**
de `Eventos extremos.xlsx` — la hoja indicada para NC ponderado por uso
de suelo mixto, ver `COMO_USAR_EVENTOS_EXTREMOS.md` §0 y §2.b — y el
mismo patrón de tormenta de diseño por bloque alterno + hidrograma
unitario SCS ya usado en `resueltos/2024 diciembre/scripts/ej2_parte1.py`)
porque es más rápido de verificar con precisión numérica (bisección
exacta para invertir Tr, integración exacta del bloque alterno) que
operar la planilla real celda por celda para un examen ya resuelto; en
el examen real se completaría directamente `Cálculos (chica)` con
`M2=0.25` (%cultivo), `M3=78`, `M4=61` (NC ponderado automático en
`M5`), más la corrección de AMC a mano en `J7` para la parte 2.b (la
planilla no tiene una celda que la calcule sola, ver §2.e del
instructivo). Script:
`resueltos/2019 julio/scripts/Ejercicio3_NRCS_cuenca.py`.

### Paso a paso

**Datos base:**

```
Grupo hidrologico: Cerro Chato -> B  (Tabla 3.1.5)
NC pastizal, cond. Buena, grupo B (sin tratamiento, SR)      = 61
NC cultivo en hileras rectas (SR), cond. Buena, grupo B      = 78
NC ponderado = 0.75*61 + 0.25*78 = 65.25

S cauce principal = dH/L/10 = 70/12.5/10 = 0.56 %
tc (Kirpich) = 0.4*12.5^0.77/0.56^0.385 = 3.50 hs   (> 1 h => SOLO metodo NRCS)
```

**Parte 1) Caudal de diseño, Tr=100 años.**

Tormenta de diseño por bloque alterno (Δt=tc/7=0.4995 h≈30 min, 12
bloques), con P310=82 mm (isoyeta en Florida), CT(100)=1.4401:

```
Tormenta de diseño total = 141.9 mm
S(NC=65.25) = 135.27 mm ; Ia=0.2S = 27.05 mm
Pe total (con piso de infiltracion 1.2 mm/h, grupo B) = 52.72 mm
Hidrograma unitario SCS: Tp=2.35 hs, Tb=6.26 hs, qp=66.45 m3/s/cm
```

**Resultado Parte 1: Qmax diseño (NRCS, Tr=100) = 266.0 m³/s.**

**Comparación con la solución oficial:** coincide muy bien — el
manuscrito da NC=65.25 (idéntico) y **Qmax=265 m³/s** (diferencia
<0.4%, atribuible a redondeos intermedios del cálculo manual).

**Parte 2.a) Tr de la intensidad máxima registrada.**

El bloque más intenso del hietograma es P=49 mm en d=0.5 h:

```
CD(0.5h) = 0.4519 ; CA(0.5h, 75 km2) = 0.8319   (CA incluido: evento sobre toda la cuenca)
CT objetivo = 49 / (82*0.4519*0.8319) = 1.5896
Invirtiendo CT(Tr) (biseccion) => Tr = 221.6 años
```

**Resultado Parte 2.a: Tr ≈ 220-225 años** (se adopta el tabulado más
cercano, 200 o 250 años según la tabla disponible).

**Comparación con la solución oficial:** coincide casi exactamente — el
manuscrito da CD=0.45, CA=0.83, CTr=1.5895 y **Tr≈225 años** (idéntico
al cálculo, con la mínima diferencia esperable por redondeo de CD/CA
leídos vs. calculados con la fórmula cerrada).

**Parte 2.b) Caudal máximo del evento, con corrección de NC por AMC.**

```
P5d = 62 mm, junio (estacion INACTIVA) > 27.94 mm => AMC III
NC(III) = 23*NC(II)/(10+0.13*NC(II)) = 23*65.25/(10+0.13*65.25) = 81.20
S(NC=III) = 58.81 mm ; Ia = 11.76 mm
```

Se aplica el hietograma **registrado**, en su orden cronológico real
(sin reordenar por bloque alterno), con el mismo hidrograma unitario ya
calculado (mismo tc, y el ancho de bloque del hietograma observado,
0.5h, coincide con Δt=tc/7 de la Parte 1 — no es casualidad, así se
arma la tormenta de diseño):

```
Pe total (evento registrado, NC=III=81.2) = 95.62 mm
Qmax evento = 496.8 m3/s
```

**Resultado Parte 2.b: Qmax evento ≈ 497 m³/s > Qmax diseño (266 m³/s,
Tr=100) ⇒ la condición de diseño de la obra fue SOBREPASADA.**

**Comparación con la solución oficial:** coincide — NC(III)=81.2
(idéntico) y **Qmax=495 m³/s** (diferencia <0.4%), con la misma
conclusión: "se sobrepasa la obra".

---

## Ejercicio 4 — Bombas en paralelo con regulación por válvula

### Enunciado (resumen)

Dos bombas idénticas en paralelo (curva de catálogo dada) elevan agua de
un río hacia un tanque elevado (zT=20 m). Succión compartida:
Ls=10 m, Ds=300 mm, εs=0.04 mm, ks=1. Impulsión compartida:
Li=100 m, Di=250 mm, εi=0.04 mm, ki=2, con una válvula de compuerta
(kv_abierta=0). Cota del eje de las bombas zB=1 m. Agua a 20°C, 1 atm.

Curva de catálogo (c/u de las 2 bombas, idénticas):

```
Q (L/s)     0    25    50    75   100   125   150
H (m.c.a.) 38    37    35    31    26    19    12
rend (%)    0    45    70    76    71    56    30
NPSHr (m) 3.1   3.5   4.3  5.20   7.1   9.2    13
```

1) Con válvula abierta y nivel del río zR=0 m:
   a) Punto de funcionamiento del sistema y de cada bomba.
   b) Potencia consumida por el sistema.
   c) Verificar que las bombas no cavitan.
2) Nivel mínimo al que puede descender el río sin que exista cavitación.
3) Con zR=0 m, cerrar parcialmente la válvula para reducir el caudal
   del sistema a Q=150 L/s:
   a) Valor de kv correspondiente.
   b) Nuevo punto de funcionamiento del sistema y de cada bomba.
   c) Potencia consumida.
   d) Verificar que las bombas no cavitan.

### Teoría (RESUMEN_TEORICO.md §C1-C6)

- **C1** Ecuación de la instalación: Hm=HB-HA con pérdidas
  distribuidas (Colebrook-White) y localizadas en succión e impulsión.
  **Nota importante para este ejercicio** (añadida al resumen): con
  Ds≠Di y **ambos extremos siendo superficies libres de grandes
  depósitos** (río y tanque), la ecuación de instalación **no lleva
  ningún término cinético suelto** fuera de las pérdidas — los `ks`,
  `ki` del enunciado ya incluyen todas las pérdidas localizadas
  (entrada, salida, accesorios). La plantilla genérica de
  `Bomba_sola.m`/`Bombas_paralelo.m` (que sí suma `+v²/2g` en HA y HB)
  sólo da el mismo resultado si Ds=Di o si hay una descarga libre real
  (chorro) — no es el caso acá, hay que usar la forma reducida
  `Hm=(zT-zR)+(ks+fs·Ls/Ds)·Us²/2g+(ki+kv+fi·Li/Di)·Ui²/2g` (la misma
  que trae la solución oficial manuscrita).
- **C2** Dos bombas idénticas en paralelo: curva equivalente H(Q_total)
  = H_catálogo(Q_total/2); punto de funcionamiento = intersección con
  la curva de instalación.
- **C3** Potencia consumida: Pc=γ·Q_sistema·H_sistema/η(Q_bomba).
- **C4** NPSH disponible = HA - zB + 10.1 m, con HA **sin** término
  cinético (se cancela, ver nota de la sección — misma lógica que la
  ecuación de instalación cuando el origen es una superficie libre).
- **C6** Caso inverso "hallar kv dado Q objetivo": con Q conocido, el
  problema es directo (sin iterar), se despeja kv de la ecuación de la
  instalación evaluada en ese Q.

Cita: Teórico HHA §3.3 (bombas, instalación, cavitación, bombas en
paralelo); Formulómetro "Bombas — Ecuación de la instalación /
Cavitación / Bombas en paralelo".

### Herramienta y por qué

Se usó Octave (`colebrook.m` para el factor de fricción; sin más
dependencias, ya que la forma reducida de Hm de este ejercicio es
autocontenida) porque es un problema estándar de bombeo con pérdidas
Darcy-Weisbach/Colebrook y una válvula reguladora — el caso de uso
central de `RESUMEN EXAMEN/Codigos/Bombas`. Se adaptó (no copió tal
cual) `Bombas_paralelo.m`, corrigiendo la ecuación de instalación a la
forma reducida sin términos cinéticos sueltos (ver Teoría arriba) tras
detectar, comparando contra la solución oficial, que la plantilla
genérica con `+v²/2g` da un ≈6% de error en Q cuando Ds≠Di. Para la
Parte 2 (zR mínimo) se usó `fzero` sobre zR, buscando el cero de
NPSHdisp(zR)-NPSHreq(Q(zR)) (el punto de funcionamiento cambia con zR,
así que hay que resolverlo autoconsistentemente). Para la Parte 3.a
(hallar kv) se despejó algebraicamente en un solo paso (C6, caso
inverso, sin iterar). Script completo:
`resueltos/2019 julio/scripts/Ejercicio4_bombas_paralelo_valvula.m`
(+ `colebrook.m`).

### Paso a paso

**Parte 1) zR=0, válvula abierta.**

```
Curva equivalente: H_eq(Q) = H_catalogo(Q/2)   (2 bombas identicas en paralelo)
Curva instalacion: Hm(Q) = (zT-zR) + (ks+fs*Ls/Ds)*Us^2/2g + (ki+fi*Li/Di)*Ui^2/2g

Interseccion: Qsistema = 193.9 L/s ; Hsistema = 26.69 m
Qbomba = 96.9 L/s (=Qsistema/2) ; Hbomba = 26.69 m
```

a) **Qsistema ≈ 194 L/s, Hsistema ≈ 26.7 m** (Qbomba≈97 L/s cada una).

b) Potencia: η(Qbomba=97 L/s)≈71.9% (interpolado de la curva de
rendimiento) ⇒ **Pc = γ·Qsist·Hsist/η = 9800×0.1939×26.69/0.719 ≈
70.6 kW**.

c) NPSH: NPSHdisp=8.54 m > NPSHreq(97 L/s)=6.85 m ⇒ **las bombas NO
cavitan**.

**Comparación con la solución oficial:** coincide muy bien en todos los
valores — Qsistema=193 L/s (≈194, <0.5%), Hsistema=Hbomba=26.7 m
(idéntico), Qbomba=96.5 L/s (≈97, <0.5%), Pc≈70.1 kW (calculado con los
mismos redondeos que el manuscrito, ≈9800×0.193×26.7/0.72), NPSHdisp=
8.55 m (≈8.54, idéntico) y NPSHreq=6.8 m (≈6.85, idéntico). (Nota:
Qsistema en el manuscrito se leyó inicialmente como "183 L/s" por la
calidad del escaneo; una inspección más cercana confirma que dice
**193** L/s, consistente con Qbomba×2=96.5×2=193.)

**Parte 2) Nivel mínimo del río sin cavitación.**

Al bajar zR, el punto de funcionamiento se desplaza (mayor desnivel a
vencer ⇒ menor Q) y el NPSHdisp baja (menor carga de aproximación en la
succión) — hay que resolver ambos efectos a la vez con `fzero`:

```
zR_min tal que NPSHdisp(zR_min) = NPSHreq(Qbomba(zR_min))
=> zR_min = -2.34 m ; con Qbomba=90.1 L/s ; Hbomba=28.14 m en ese punto
```

**Resultado Parte 2: zR_min ≈ -2.3 m.**

**Comparación con la solución oficial:** coincide razonablemente —
manuscrito: zR_min=-2.3 m (idéntico), Qbomba=88.7 L/s (vs. 90.1 L/s,
≈1.6% de diferencia), Hbomba=28.0 m (vs. 28.14 m, ≈0.5%) — diferencias
menores atribuibles a la precisión de la resolución gráfica/iterativa
manual de este punto (a diferencia de las Partes 1 y 3, acá no hay
forma cerrada y el manuscrito no expone los pasos intermedios de su
iteración para comparar más en detalle).

**Parte 3) Cerrar la válvula para Qsistema=150 L/s (zR=0).**

Con Q=150 L/s conocido (75 L/s por bomba), el problema es directo (C6,
caso inverso): se lee Hbomba=31.0 m de la curva de catálogo en 75 L/s y
se despeja kv de la ecuación de instalación evaluada en Q=150 L/s:

```
31.0 = (20-0) + (1+fs*10/0.3)*Us^2/2g + (2+kv+fi*100/0.25)*Ui^2/2g
=> kv = 14.57
```

a) **kv ≈ 14.6.**

b) Nuevo punto de funcionamiento (por construcción, ya que kv se eligió
para esto): **Qsistema=150 L/s, Hsistema=Hbomba=31.0 m, Qbomba=75 L/s.**

c) Potencia: η(75 L/s)=76% ⇒ **Pc = 9800×0.150×31.0/0.76 ≈ 60.0 kW**.

d) NPSH: NPSHdisp=8.76 m > NPSHreq(75 L/s)=5.20 m ⇒ **NO cavitan**
(cerrar la válvula reduce Q, lo que reduce el NPSHreq más de lo que
cambia el NPSHdisp — coherente con la nota de C6 del resumen teórico:
el riesgo de cavitación generalmente disminuye al cerrar la válvula).

**Comparación con la solución oficial:** coincide exactamente — kv=14.5
(≈14.57), Qsistema=150 L/s y Hsistema=Hbomba=31.0 m (idénticos),
Pc≈9800×0.150×31/0.76≈60.0 kW (idéntico), NPSHdisp=8.76 m (idéntico) y
NPSHreq=5.2 m (idéntico), con la misma conclusión "NO CAVITA".

---

ESTADO: COMPLETO
