# Resumen Teórico HHA — depurado a partir de los exámenes resueltos

Este resumen se construyó leyendo completos los exámenes ya resueltos en
`resueltos/` (2020 Diciembre, 2020 Julio, 2022 Julio, 2022 diciembre, 2024
diciembre, 2025 Febrero 1, 2025 Febrero 2, 2026 Febrero, 2024 Julio, 2024
marzo, 2024 febrero, 2023 diciembre, 2023 Julio, 2023 febrero_2 y 2023
Febrero) y extrayendo de ahí
**todos los temas y fórmulas que efectivamente fueron preguntados**,
fusionando los que se repiten entre exámenes en una sola sección
enriquecida. Las fórmulas se verificaron/precisaron contra `Teórico
HHA.pdf` y `01_Formulometro2025.pdf` (citados como "Formulómetro").
Objetivo: alcanzar para repasar sin releer todos los `RESOLUCION.md`
completos.

Convención de nombres cortos de examen: **2022 dic** = 2022 diciembre
(15/dic/2022); **2024 dic** = 2024 diciembre; **2025 feb 1** = 2025_FEBRERO 1
(27/feb/2025); **2025 feb 2** = 2025_FEBRERO 2 (5/feb/2025); **2026 feb** =
2026 Febrero (3/feb/2026); **2024 jul** = 2024 Julio; **2024 mar** = 2024
marzo (1/mar/2024); **2024 feb** = 2024 febrero (5-6/feb/2024); **2023 dic**
= 2023 diciembre (11/dic/2023); **2023 jul** = 2023 Julio (24/jul/2023);
**2023 feb 2** = 2023 febrero_2 (24/feb/2023, segunda llamada de
febrero); **2023 feb** = 2023 Febrero (9/feb/2023, primera llamada de
febrero — no confundir con 2023 feb 2); **2022 jul** = 2022 Julio
(25/jul/2022); **2020 dic** = 2020 Diciembre (22/dic/2020); **2020 jul** =
2020 Julio (7/jul/2020); **2020 feb** = 2020 febrero (28/feb/2020).

## Índice de temas

| Tema | Veces preguntado | Exámenes |
|---|---|---|
| A1. Ecuación de FGV y clasificación de canales M/S | 16 | 2020 feb, 2020 dic, 2020 jul, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb 2, 2023 feb |
| A2. Energía específica y tirante crítico | 16 | 2020 feb, 2020 dic, 2020 jul, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb 2, 2023 feb |
| A3. Cantidad de movimiento, tirante conjugado y resalto hidráulico | 16 | 2020 feb, 2020 dic, 2020 jul, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb 2, 2023 feb |
| A4. Perfiles de flujo controlados por lagos/embalses y por caída libre | 15 | 2020 feb, 2020 dic, 2020 jul, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb 2, 2023 feb |
| A5. Transiciones de fondo: cambio de sección, escalón y compuerta de fondo | 10 | 2020 dic, 2020 jul, 2024 dic, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 feb 2, 2023 feb |
| A6. Tensión rasante de fondo en FGV | 1 | 2025 feb 1 |
| B1. Delimitación de cuencas y divisoria de aguas | 14 | 2020 feb, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb 2, 2023 feb |
| B2. Tiempo de concentración (Ramser-Kirpich) | 15 | 2020 feb, 2020 dic, 2020 jul, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb |
| B3. Curvas IDF de Uruguay y coeficientes CD/CT/CA | 16 | 2020 feb, 2020 dic, 2020 jul, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb 2, 2023 feb |
| B4. Método Racional (y criterio de selección según tc) | 15 | 2020 dic, 2020 jul, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb 2, 2023 feb |
| B5. Método NRCS: Número de Curva + Hidrograma Unitario Triangular SCS | 15 | 2020 feb, 2020 dic, 2020 jul, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb 2 |
| B6. Condición de humedad antecedente (AMC) | 9 | 2020 feb, 2022 jul, 2022 dic, 2025 feb 1, 2026 feb, 2024 mar, 2024 feb, 2023 dic, 2023 jul |
| B7. Volumen de escorrentía y embalses de retención | 6 | 2022 jul, 2022 dic, 2024 dic, 2025 feb 2, 2024 feb, 2023 feb 2 |
| B8. Infiltración de Horton y tiempo de encharcamiento | 2 | 2025 feb 2, 2023 feb 2 |
| B9. Agua Disponible del suelo, ETc (Kc) y necesidad de riego | 2 | 2026 feb, 2023 feb |
| B10. Coeficiente de escorrentía por balance directo de abstracciones (infiltración + intercepción dadas) | 1 | 2022 dic |
| C1. Ecuación de la instalación de bombeo (Darcy-Weisbach + Colebrook-White) | 15 | 2020 dic, 2020 jul, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb 2, 2023 feb |
| C2. Curva de la bomba y punto de funcionamiento | 15 | 2020 dic, 2020 jul, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb 2, 2023 feb |
| C3. Potencia consumida por el sistema de bombeo | 14 | 2020 dic, 2020 jul, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb |
| C4. Cavitación: NPSH disponible vs. requerido | 15 | 2020 dic, 2020 jul, 2022 jul, 2022 dic, 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul, 2024 mar, 2024 feb, 2023 dic, 2023 jul, 2023 feb 2, 2023 feb |
| C5. Bombas en serie y en paralelo | 7 | 2020 jul, 2022 jul, 2025 feb 1, 2025 feb 2, 2024 mar, 2023 dic, 2023 feb |
| C6. Regulación de caudal por válvula (pérdida localizada variable) | 3 | 2020 dic, 2024 dic, 2023 feb 2 |

---

# A. Hidráulica de canales — Flujo Gradualmente Variado (FGV)

## A1. Ecuación de FGV y clasificación de canales M/S

**Concepto.** El tirante en flujo gradualmente variado varía a lo largo del
canal según una EDO de 1er orden que compara la pendiente de fondo S₀ con la
pendiente de la línea de energía Sf (fricción, vía Manning) y el número de
Froude. Antes de integrarla hay que **clasificar el canal** comparando el
tirante normal yn (Manning, flujo uniforme) con el tirante crítico yc (Fr=1):
si yn>yc el canal es **tipo M** (mild/suave, flujo normal subcrítico); si
yn<yc es **tipo S** (steep/fuerte, flujo normal supercrítico); yn=yc ⇒ tipo C;
S₀=0 ⇒ tipo H; S₀<0 ⇒ tipo A.

```
dy/dx = (S0 - Sf) / (1 - Fr²)                    (ecuación general de FGV)
Sf = n²·Q²·Pm^(4/3) / A^(10/3)                    (pendiente de energía, Manning)
Fr² = Q²·B / (g·A³)                               (número de Froude, sección genérica)

Tirante normal yn:   A(yn)·Rh(yn)^(2/3) = Q·n / S0^(1/2)      (fsolve)
Tirante crítico yc:  B(yc) / A(yc)³ = g / Q²                  (fsolve, Fr=1)

Clasificación: yn > yc -> M (mild)  |  yn < yc -> S (steep)  |  yn = yc -> C
               S0 = 0 -> H (horizontal)  |  S0 < 0 -> A (adversa)
```

**Cuándo se usa.** Siempre es el primer paso en cualquier problema de FGV:
con Q, n, S₀ y la geometría se calculan yn e yc (numéricamente, `fsolve`),
se clasifica el canal, y sólo después se decide el sentido de integración de
la EDO (hacia aguas abajo desde un control aguas arriba en canales S; hacia
aguas arriba desde un control aguas abajo —caída libre u otro lago— en
canales M).

Cita: Teórico HHA §2.5.1–§2.5.2; Formulómetro "Flujo Gradualmente Variado" /
"Flujo Uniforme" (Manning).

## A2. Energía específica y tirante crítico

**Concepto.** La energía específica E=y+Q²/(2gA²) mide la energía por unidad
de peso relativa al fondo del canal. El tirante crítico yc minimiza E para Q
dado (equivalentemente, maximiza Q para una E dada) y separa el flujo
subcrítico (Fr<1, y>yc) del supercrítico (Fr>1, y<yc). Dos tirantes distintos
con la misma E para el mismo Q se llaman **alternos**.

```
E = y + Q² / (2·g·A(y)²)                         (energía específica)
Canal rectangular: yc = (q²/g)^(1/3), q=Q/b  ;  Ec = 1.5·yc
Sección genérica:  B(yc)/A(yc)³ = g/Q²            (mismo criterio que yn/yc de A1)
Transición de fondo sin pérdidas (escalón D, o cambio de talud/ancho suave):
   E1 = E2 ± D
```

**Cuándo se usa.** (a) Control crítico en la entrada de un canal tipo S
alimentado por un lago (el lago descarga el caudal máximo compatible con su
energía ⇒ y=yc en x=0, ver A4); (b) condición de caída libre, y≈1.01·yc justo
en el borde (la EDO de FGV es singular exactamente en yc); (c) cálculo de
tirantes alternos en compuertas de fondo y escalones (A5); (d) cálculo del D
máximo de un obstáculo de fondo antes de que "ahogue" la sección
(Dmax=E1−Ec).

Cita: Teórico HHA §2.2; Formulómetro "Energía".

## A3. Cantidad de movimiento, tirante conjugado y resalto hidráulico

**Concepto.** A diferencia de la energía (que se disipa en el resalto), la
cantidad de movimiento (momentum) se conserva entre las dos secciones de un
resalto hidráulico. La función M(y) = y̅·A(y) + Q²/(g·A(y)) (y̅ = profundidad
del centro de gravedad de la sección bajo la superficie libre) toma el mismo
valor en ambos tirantes del resalto: los **tirantes conjugados** y1
(supercrítico, antes) e y2 (subcrítico, después) cumplen M(y1)=M(y2).

```
M(y) = y̅(y)·A(y) + Q²/(g·A(y))
Resalto hidráulico: M(y1) = M(y2)     con y1 < yc < y2
Fuerza sobre un obstáculo (dirección del flujo): F(agua→obstáculo) = γ·(M1 − M2)
Potencia disipada entre 2 secciones: Pdis = γ·Q·(H1 − H2)
```

**Cuándo se usa.** Para ubicar la **posición** de un resalto hidráulico: se
integran ambas ramas de la EDO de FGV (la supercrítica desde su control
aguas arriba, la subcrítica desde su control aguas abajo) y se calcula, para
cada punto de la rama supercrítica, su conjugado M(y1)=M(y2); el resalto
ocurre donde ese conjugado cruza el valor de la rama subcrítica en el mismo
x. Aparece siempre que una rama supercrítica debe empalmar con una
subcrítica impuesta por un control aguas abajo (lago con nivel alto,
compuerta ahogada, tramo M2 fijo, etc.).

La misma fórmula F=γ·(M1−M2) sirve para **cualquier** obstáculo de fondo
entre dos secciones (no solo resaltos): p.ej. la fuerza sobre una compuerta
de fondo (M1=aguas arriba de la compuerta, M2=vena contraída) y, por
separado, la fuerza sobre un escalón de fondo (M1=antes del escalón,
M2=después) en el mismo canal — cada obstáculo es un control de volumen
independiente entre sus dos secciones inmediatas (2024 jul, Ej.1; 2024
feb, Ej.1 parte 3 — ahí ambas secciones están al mismo nivel de fondo, así
que basta M(y1_new) y M(y3_new) sin ningún término de peso adicional).

Cita: Teórico HHA §2.3.1–§2.3.3; Formulómetro "Cantidad de Movimiento".

## A4. Perfiles de flujo controlados por lagos/embalses y por caída libre

**Concepto.** El control (la sección que fija Q y/o el tirante) depende del
tipo de canal y de la condición de borde:

- **Canal tipo S alimentado por un lago:** el lago descarga el **caudal
  máximo compatible con su energía**, lo que ocurre con **flujo crítico en
  la entrada** del canal (x=0), independientemente de lo que pase aguas
  abajo — salvo que el remanso de un segundo lago (aguas abajo) llegue a
  "ahogar" esa sección de entrada (hay que verificarlo después de resolver).
- **Canal tipo M alimentado por un lago, muy largo:** el tirante de entrada
  tiende a yn (el canal "olvida" la condición de entrada); es un sistema de
  2 ecuaciones (energía + Manning) para (Q, yn).
- **Caída libre** al final de un canal: control crítico, y≈1.01·yc justo en
  el borde.
- **Segundo lago aguas abajo:** si su nivel es mayor al tirante que trae el
  perfil, impone una rama subcrítica remontando desde el lago (M1 o S1) que
  se conecta con la rama que viene de aguas arriba mediante un **resalto**
  (ver A3); si su nivel es menor, no controla nada y el canal descarga en
  caída libre.

```
Control crítico en la entrada de un canal S (lago 1 -> canal):
   Fr²(y1) = Q²·B(y1) / (g·A(y1)³) = 1        (y1 = yc en x=0)
   h_Lago  = y1 + Q² / (2g·A(y1)²)             (conservación de energía, sin pérdidas)

Canal tipo M alimentado por lago (aprox. y(0)≈yn si el canal es largo):
   h_Lago = yn + Q² / (2g·A(yn)²)
   Q = (1/n)·A(yn)·Rh(yn)^(2/3)·S0^(1/2)        (sistema 2x2 en (Q,yn), fsolve)

Control por caída libre: y(borde) ≈ 1.01 · yc
```

**Cuándo se usa.** Siempre que un canal conecte con uno o dos lagos/embalses
o termine en caída libre: primero se plantea el sistema del control aguas
arriba (según tipo M o S) para obtener Q; luego se integra la EDO de FGV; y
si hay un segundo lago aguas abajo se verifica si controla (remanso) o no
(caída libre), agregando un resalto si corresponde. En canales de dos tramos
con distinto talud/geometría, el empalme entre tramos se resuelve por
conservación de E si la transición es "suave" (sin pérdidas).

**Canal de dos tramos con distinta PENDIENTE (mismo b, n), entre dos lagos**
(2023 dic, Ej.1). El **cambio de pendiente** en sí mismo puede ser un
control crítico, igual que una caída libre, cuando el tramo aguas arriba
del cambio es mild y el de aguas abajo es steep. Para decidir dónde está
el control de todo el sistema (y por lo tanto cómo hallar Q), conviene
**probar primero la hipótesis más simple** (tramo 1 steep ⇒ control
crítico directo en la entrada, Q en forma cerrada) y verificar que sea
autoconsistente (yn1<yc con el Q hallado):
- Si **tramo 1 resulta steep**: la hipótesis es consistente, Q sale
  directo de la ecuación de energía del lago con y=yc en x=0 (A2). El
  lago descarga su caudal máximo **sin que importe lo que pase aguas
  abajo**, salvo verificar al final si un lago de salida bajo (hLB<yc)
  actúa como caída libre (no controla) o si hLB>yc y controla con una
  rama subcrítica que puede generar un **resalto** en el tramo 1 (A3).
- Si **tramo 1 resulta mild** con ese Q (contradicción): el control
  crítico de la entrada NO es válido — el lago no puede forzar más
  caudal que el que el tramo 1 deja pasar aguas abajo. El control pasa
  a estar en el **cambio de pendiente** (y=yc ahí, como una caída libre
  "interna"): se **itera Q** (`fzero`/shooting) integrando la curva M2
  del tramo 1 hacia atrás desde el cambio de pendiente hasta la entrada,
  hasta que la energía en la entrada cierre con h_Lago.
- Si el segundo tramo (tras el cambio de pendiente) es steep y el lago de
  salida queda por debajo de su tirante normal, ese lago **no controla
  nada**: en flujo supercrítico la información no viaja hacia aguas
  arriba, así que toda la rama de salida es una curva S2/S3 fija, sin
  resalto, con el ajuste final al nivel del lago concentrado en el borde.

Cita: Teórico HHA §2.5.3 (caída libre), §2.5.4 (perfiles entre dos lagos,
casos M y S), §2.5.5 (perfil con compuerta de fondo entre dos lagos), §2.5.6
(canal con cambio de pendiente/empalme de tramos).

**Canal de TRES tramos con un tramo HORIZONTAL intermedio (S=steep /
horizontal / mild), resalto de posición variable** (2022 jul, Ej.1). Con
un tramo de entrada steep muy largo (o "infinito"), un tramo horizontal y
un tramo mild que descarga en un segundo lago: el tramo horizontal
(S₀=0) **no tiene yn finito** (Manning no tiene solución con S=0), así
que se clasifica sólo por yc, con dos curvas posibles: **H2** (y>yc,
creciente yendo hacia aguas arriba) y **H3** (y<yc, evoluciona hacia yc
según Fr) — no existe H1. Para ubicar el resalto:
1. Se resuelve Q por control crítico en la entrada del tramo steep (como
   arriba), y se calcula yn de cada tramo con pendiente definida.
2. Si el lago de salida no ahoga el tramo mild (hLB≤yc), su salida tiene
   control crítico (y=yc), independientemente del valor exacto de hLB
   mientras sea ≤yc — se integra la curva subcrítica (M2/M1 según
   corresponda) hacia atrás por el tramo mild y luego por el horizontal
   (curva H2), hasta la unión con el tramo steep.
3. **Error a evitar**: al llegar a la unión con el tramo steep, la rama
   supercrítica que "trae" el tramo I **no se puede asumir constante en
   yn** dentro del tramo horizontal — al cambiar S₀ cambia la EDO de
   FGV, así que esa rama debe re-integrarse con la pendiente del nuevo
   tramo (curva H3, partiendo de yn del tramo anterior) antes de
   comparar su conjugado punto a punto con la curva subcrítica (H2) que
   viene de aguas abajo (mismo método general de A3). Comparar
   directamente el conjugado de yn (constante) contra el perfil
   subcrítico en la unión entre tramos da un resultado **cualitativamente
   equivocado** sobre en qué tramo cae el resalto.
4. El **hLB umbral** para que el resalto pase de un tramo a otro (p.ej.
   del tramo horizontal al steep) se halla con un `fzero` en hLB:
   propagando hacia atrás la rama subcrítica desde la salida hasta la
   unión entre tramos, se busca el hLB para el cual ese tirante iguala
   el conjugado de yn del tramo aguas arriba (resalto justo en la
   unión) — subir hLB por encima de ese umbral empuja el resalto hacia
   aguas arriba (al tramo siguiente); por debajo, el resalto queda en el
   tramo donde ya se ubicó.

**Transición lago-canal ASIMÉTRICA: entrada (contracción) vs. salida
(expansión)** (2022 dic, Ej.1). En un canal entre dos lagos, la
transición de energía en cada extremo es de naturaleza distinta:

- **Entrada** (lago → canal): es una **contracción**, que no disipa
  energía — se conserva E: E(y en x=0) = h_lago_entrada.
- **Salida** (canal → lago): es una **expansión brusca** hacia el
  volumen grande del lago, que sí disipa toda la energía cinética
  (pérdida tipo Borda) — el nivel del lago iguala **directamente** el
  tirante en la última sección del canal, y(x=L)=h_lago_salida, **sin**
  sumar el término V²/2g.

Esta asimetría es la que permite, en un canal tipo S con lagos en ambos
extremos, hallar en forma cerrada el **rango de niveles del lago de
salida** para el cual existe un resalto dentro del canal: hL2min es
directamente el conjugado (Mom_rect/momento) del tirante libre de salida
sin resalto (resalto justo en x=L), y hL2max es directamente el tirante
en x=L de la rama subcrítica que arranca en yc en la entrada (resalto
justo en x=0, empujado hasta la propia entrada) — en ambos casos sin
sumar V²/2g, porque el nivel del lago de salida se compara contra el
tirante, no contra la energía específica. Por debajo de hL2min el
resalto queda fuera del canal (descarga libre); por encima de hL2max el
lago de salida ahoga la entrada y el propio Q disminuye (se itera con
`fzero`, igual que el caso "cambio de pendiente" de más arriba, pero acá
el control que se pierde es el crítico de la entrada por remanso del
lago de salida, no un cambio de geometría interno).

**Control crítico en la entrada, sección TRAPEZOIDAL (sin forma cerrada)**
(2023 jul, Ej.1). En canal rectangular, el control crítico de un lago da Q
en forma cerrada (yc=(2/3)hLago, Q=b·sqrt(g·yc³)). En sección trapezoidal
yc(Q) no tiene forma cerrada (depende de `eq_yc`, fsolve), así que hay que
**anidar** un `fzero` externo en Q alrededor del `fsolve` interno en yc:
para cada Q de prueba se resuelve yc(Q) y se evalúa el residuo de energía;
se itera Q hasta que yc(Q)+Q²/(2g·A(yc)²)=hLago. Mismo patrón que la
sección "canal de dos tramos" de arriba, pero acá el `fzero` en Q aparece
ya en la Parte 1 (canal de un solo tramo), no sólo cuando hay cambio de
pendiente. Si además el canal tiene un tramo con cambio de pendiente
aguas abajo que NO altera el tramo de entrada (mismo S0 en el tramo que
sale del lago), el control crítico de la entrada y su Q **no cambian**
respecto al caso sin relleno — la perturbación aguas abajo no viaja
hacia el lago en flujo supercrítico — y sólo hay que recalcular yn del
tramo modificado y, si corresponde, ubicar un resalto dentro de ese
tramo (comparando conjugado de la rama M3/S2 entrante contra la rama M2
de salida, igual que en el caso de dos tramos completo).

**Mismo principio con cambio de SECCIÓN Y RUGOSIDAD (no de pendiente)**
(2020 feb, Ej.1). El razonamiento "el tramo de entrada supercrítico fija
Q, y el cambio aguas abajo no puede alterarlo" no depende de qué cambie
en el segundo tramo — vale igual si lo que cambia es la geometría de la
sección (p.ej. trapezoidal→rectangular) y/o el n de Manning, siempre que
la pendiente S0 y el tramo de entrada no se toquen. Procedimiento: (1)
resolver Q con las dos hipótesis de control (M vs. S) en el tramo de
entrada, igual que arriba, y quedarse con la consistente; (2) con ese
mismo Q, calcular yc y yn del tramo modificado (con su propia geometría)
y clasificarlo; (3) si el tramo de entrada era S (supercrítico en toda
su longitud) y el tramo nuevo resulta M con el tirante entrante por
debajo de su yc, hay un **resalto obligatorio** dentro del tramo nuevo
(curva M3 creciente hasta un resalto, luego uniforme a yn) — se ubica
con el mismo método de conjugado-vs-curva-de-cola de A3, integrando la
rama subcrítica hacia atrás desde muy lejos aguas abajo (donde y→yn del
tramo nuevo; el resultado es insensible a qué tan lejos se arranque esa
integración, conviene verificarlo probando 2-3 distancias distintas).
En sección rectangular el conjugado tiene fórmula cerrada (`Mom_rect.m`,
más simple/preciso que el trapezoidal iterativo `Mom_trap.m`).

## A5. Transiciones de fondo: cambio de sección, escalón y compuerta de fondo

**Concepto.** Una transición **suave** (sin pérdida de energía, longitud
despreciable) conserva la energía específica entre la sección antes y
después de la transición, aunque cambie la cota de fondo (escalón), el
talud/ancho (cambio de sección) o se interponga una compuerta de fondo.

- **Escalón de altura D:** E1 = E2 + D. Si D es pequeño, el tirante aguas
  arriba no cambia. El **D máximo** que no altera y1 es aquel para el que la
  energía en la cresta es exactamente la mínima (crítica): Dmax = E1 − Ec.
  Si D > Dmax, el escalón "ahoga" la sección: aparece **remanso** aguas
  arriba (curva M1, con E1_nuevo = Ec + D), el flujo pasa por crítico en la
  cresta y se acelera a supercrítico aguas abajo (curva M3, tirante y3 =
  alterno de y1 para E1_nuevo), hasta que un **resalto hidráulico** reconecta
  con el perfil fijo de aguas abajo (p.ej. una curva M2 que llega a una
  caída libre).
- **Compuerta de fondo ideal (abertura a, sin pérdida ni contracción):**
  tirante inmediatamente aguas abajo yB=a; tirante aguas arriba yA = alterno
  de yB (misma E, rama subcrítica). Se verifica **descarga libre vs.
  ahogada** comparando el conjugado de a (a\*, tal que M(a)=M(a\*)) con el
  tirante que trae el perfil de aguas abajo en esa sección:

```
Escalón:  Dmax = E1 − Ec ,  Ec = yc + Q²/(2g·A(yc)²)
Escalón con D > Dmax:  E1_nuevo = Ec + D  ->  y1(subcrítico, alterno) e y3(supercrítico, alterno de y1)

Compuerta ideal:  yB = a  ;  yA tal que E(yA) = E(yB)      (alterno)
Chequeo de ahogamiento:  a* = conjugado(a)  [M(a)=M(a*)]
   a* > y(aguas abajo en esa sección)  =>  descarga LIBRE  (curva M3 + resalto después)
   a* < y(aguas abajo en esa sección)  =>  descarga AHOGADA
```

**Cuándo se usa.** Para calcular la altura máxima de un obstáculo de fondo
que no altera el remanso aguas arriba; para diseñar/verificar compuertas de
fondo (abertura mínima para no superar un tirante límite aguas arriba,
posición del resalto aguas abajo); para empalmar tramos de un canal con
distinto talud/ancho sin pérdida de carga.

**Compuerta con descarga AHOGADA (a > conjugado de la condición de aguas
abajo).** Si el tirante que impone la condición de aguas abajo (y3, p.ej.
≈yn si el resalto queda lejos de cualquier otro control) es mayor que el
conjugado de la apertura a en descarga libre, el resalto queda "ahogado"
contra la compuerta: en la sección (2), inmediatamente aguas abajo, hay
**flujo dividido** — el agua fluye con velocidad sólo por la franja de
espesor a (área mojada de velocidad Am2=b·a), mientras que la porción de
sección entre a y el tirante real y2 está prácticamente en reposo (aporta
sólo hidrostática, con área completa A2=b·y2). Se resuelve en dos pasos:

```
1) Momentum entre (2) y (3):  yG2·A2 + Q²/(g·Am2) = yG3·A3 + Q²/(g·A3) = M(y3)
   Rectangular: b·y2²/2 + Q²/(g·b·a) = M(y3)          (fzero en y2)
2) Energía entre (1) y (2):   y1 + Q²/(2g·A1²) = y2 + Q²/(2g·Am2²)
   Rectangular: y1 + Q²/(2g·(b·y1)²) = y2 + Q²/(2g·(b·a)²)     (fzero en y1)
```

Chequeo previo (equivalente a comparar a* vs. y_aguas_abajo): **a >
conjugado(y3) ⟺ descarga ahogada**; si a < conjugado(y3), la descarga es
libre (ver fórmula de arriba). El caso frontera (a = conjugado(y3)) es el
resalto libre justo pegado a la compuerta (2024 mar, Ej.1, con y3≈yn).

**Cuándo se usa.** Para verificar si el resalto queda "ahogado" en la
compuerta (a>conjugado del tirante de aguas abajo) y, en ese caso, hallar
el tirante aguas arriba y1 sin necesidad de ubicar la posición del resalto
(que en descarga libre sí se busca integrando la rama supercrítica y
cruzando su conjugado con la rama subcrítica, como en A3).

**Control aguas abajo = lago a distancia FINITA (no yn ni caída libre)**
(2023 feb 2, Ej.1): si el canal descarga en un lago a una distancia L de la
compuerta (no "muy lejos"), el tirante de referencia para el chequeo
libre/ahogada **no es yn** — hay que integrar la curva M2 **hacia atrás**
desde el lago (control conocido, y=hLago en x=L) hasta la sección de la
compuerta (x=0) con la misma EDO de FGV, y usar ese valor y(M2, x=0) (que
en general es distinto de yn si L no es muy grande) como referencia para
comparar contra a* y contra el conjugado de la rama M3. La búsqueda del
resalto (si la descarga es libre) es la misma de A3: M3 hacia adelante
desde la compuerta, M2 hacia atrás desde el lago, cruce de conjugado(M3)
con M2 en la malla común de x.

**Trampa en la fuerza sobre una compuerta AHOGADA:** en el paso 3) de A3
(F=γ·(M1−M2)), si la compuerta descarga ahogada el "M2" a usar **no** es
`Mom_rect(y2,...)` con sección completa — es el momento **híbrido** de la
vena contraída, `yG(y2)·A(y2) + Q²/(g·A(a))` (presión con superficie y2,
velocidad con área contraída b·a), que por construcción coincide con
M(y3) (el valor usado para hallar y2 en el paso 1 de A3). Usar por error
`Mom_rect(y2,...)` con área completa subestima la fuerza. Además, F es una
**resta de dos números cercanos** (M1≈M2 en valor): redondear y1/y2 a 2
decimales antes de restar amplifica mucho el error relativo del resultado
final (en 2023 feb 2 la solución oficial, con y1 redondeado a 1.03 m, da
F=1172 N; con más decimales en y1 el resultado correcto es F≈1277 N) —
conviene **no redondear** hasta el final en este tipo de cuentas.

Cita: Teórico HHA §2.2 (transiciones de energía), §2.3.2–2.3.3
(conjugados/resalto), §2.3.4 "Descarga ahogada de una compuerta" (Fig.
2.3.7, momentum con flujo dividido), §2.5.5 (compuerta de fondo entre dos
lagos), §2.5.6 (cambio de pendiente/sección).

**Escalón INTERIOR a un tramo largo entre dos lagos (ni a la entrada ni a
la salida)** (2020 jul, Ej.1: cañería que atraviesa el fondo de un canal
trapezoidal en un punto intermedio, a distancia finita de ambos lagos).
Es la combinación de A4 (dos lagos, canal muy largo ⇒ y≈yn lejos de los
extremos) con el mecanismo de escalón de A5, con una sutileza: **Dmax no
se calcula con E del lago sino con la energía específica LOCAL de
aproximación al escalón** (E_aprox = y(x_escalón)+Q²/(2gA²), que en un
canal muy largo es prácticamente En, no h_Lago, porque el perfil ya
"olvidó" la condición de entrada mucho antes de llegar al escalón):
Dmax = E_aprox − Ec. Si D>Dmax, el caudal en general **sí puede cambiar**
respecto al caso sin escalón (a diferencia de cuando el control crítico
ya estaba en la entrada, A4 "control crítico en la entrada, sección
trapezoidal", donde una perturbación aguas abajo no lo altera): hay que
iterar un `fzero` en Q tal que, con E1_nuevo=Ec(Q)+D fijando el tirante
y1 justo aguas arriba del escalón (rama subcrítica), la curva M1/M2
integrada desde ahí hacia atrás hasta el lago 1 cierre con E(x=0)=h_Lago1
— igual patrón que el `fzero` de "cambio de pendiente" de A4, pero acá el
nuevo control (crítico) está en medio del canal, no en un quiebre de
geometría. Aguas abajo del escalón, la rama supercrítica (M3, y3=alterno
de y1 para E1_nuevo) se integra hacia adelante hasta que su **conjugado**
cruza la curva M1/M2 que llega desde el lago 2 (recalculada con el mismo
Q nuevo) — resalto ahí, exactamente como en A3. En el caso numérico de
2020 jul (canal muy largo, escalón a mitad de camino) el Q resultó
prácticamente idéntico al del caso sin escalón (variación <0.1%), porque
tanto el tramo lago1→escalón como el tramo escalón→lago2 son varias veces
más largos que el desarrollo típico de una curva M1/M2 — pero **debe
verificarse en cada caso**, no asumirse: si el escalón estuviera cerca de
uno de los lagos el cambio de Q podría ser significativo.

## A6. Tensión rasante de fondo en FGV

**Concepto.** A diferencia del flujo uniforme (τ₀ constante), en FGV la
tensión de corte de fondo τ₀=γ·Rh·Sf varía punto a punto porque Sf depende
del tirante local. Para Q fijo, τ₀ es **decreciente** con y: a menor
tirante, mayor velocidad y mayor Sf, y por lo tanto mayor tensión.

```
τ0(y) = γ · Rh(y) · Sf(y) ,   Sf(y) = n²·Q² / (Rh(y)^(4/3)·A(y)²)
```

**Cuándo se usa.** Se evalúa τ₀(y) sobre el perfil y(x) ya calculado (de la
EDO de FGV) para hallar la zona donde τ₀ supera un valor admisible τmax
(riesgo de erosión del revestimiento). Si se pide evitarlo, se busca el
nivel de un lago aguas abajo que ubique un **resalto** justo en el límite de
esa zona: aguas abajo del resalto (y>yc, subcrítico) τ₀ es baja, por lo que
toda esa rama queda automáticamente segura.

Cita: Teórico HHA §2.1/§2.3 (tensión rasante, pendiente de energía);
Formulómetro "Flujo Uniforme" / "Flujo Gradualmente Variado".

---

# B. Hidrología de cuencas y crecidas

## B1. Delimitación de cuencas y divisoria de aguas

**Concepto.** La cuenca es el área tal que toda la lluvia caída sobre ella
escurre hacia un mismo punto de cierre. Se delimita trazando la **línea de
divorcio/divisoria de aguas** sobre una carta con curvas de nivel: la
divisoria corta **perpendicularmente** las curvas de nivel; al ganar altura
lo hace por el lado **convexo** de la curva (cresta/loma, hacia las
nacientes); al perder altura lo hace por el lado **cóncavo** (vaguada de la
cuenca vecina); y **nunca cruza un curso de agua** salvo en el propio punto
de cierre.

```
(procedimiento gráfico, sin fórmula cerrada)

Índice de compacidad:        Ic = [sqrt(π)/(2π)] · P/sqrt(A)     (P=perímetro divisoria, A=área)
Pendiente media de la cuenca: Pm = L·dh / A     (L=long. total curvas de nivel, dh=equidistancia)
Pendiente media del cauce ppal. (método Extremos): S = ΔH / L
Densidad de drenaje:          Dd = ΣLi / A       (long. acumulada de cauces / área)
```

**Cuándo se usa.** Primer paso de cualquier ejercicio de hidrología de
cuencas: a partir de la delimitación se miden el área A, la longitud L y el
desnivel ΔH del cauce principal (insumos directos del tiempo de
concentración, B2) y, si se pide, índices morfológicos (compacidad,
densidad de drenaje). Nota importante: la pendiente S usada en
Ramser-Kirpich es la del **cauce principal** (ΔH/L/10, en %), **no** la
pendiente media de la cuenca (que se usa para elegir el coeficiente C del
método Racional, B4).

Cita: Teórico HHA §1.2.1 "Cuenca como sistema hidrológico"; Formulómetro
"Morfología de Cuencas".

## B2. Tiempo de concentración (Ramser-Kirpich)

**Concepto.** tc es el tiempo de viaje de la partícula de agua que recorre
el trayecto hidráulicamente más largo hasta el punto de cierre; es el
instante en que **toda la cuenca empieza a aportar simultáneamente** al
caudal de salida.

```
Ramser-Kirpich:  tc = 0.4 · L^0.77 / S^0.385
   L = longitud del cauce principal (km)
   S = pendiente del cauce principal (%) = ΔH(m) / L(km) / 10
   tc en horas

(alternativa NRCS/velocidad de flujo, no usada en estos 4 exámenes):
   tc = 0.91134 · Σ( k·Li / sqrt(Si) )     (suma por tramos, k=coef. de cobertura del suelo)
```

**Cuándo se usa.** Siempre es el primer cálculo antes de elegir el método de
caudal de diseño: la pendiente S de Kirpich es la del **cauce principal**
(ΔH/L/10), distinta de la pendiente media S de la cuenca que aparece en la
tabla de datos del enunciado (esa se usa para el coeficiente C del método
Racional, no para tc).

Cita: Teórico HHA §3.1.2; Formulómetro "Eventos extremos — Tiempo de
Concentración".

## B3. Curvas IDF de Uruguay y coeficientes CD/CT/CA

**Concepto.** Relación Intensidad-Duración-Frecuencia (Rodríguez
Fontal/Genta) que permite estimar la precipitación de diseño P para
cualquier duración d, período de retorno Tr y área A, a partir de un valor
base puntual P(3h,10años) leído del mapa de isoyetas de Uruguay (Fig. 3.1.10
del Teórico).

```
P(Loc,d,Tr,A) = P(3,10)[punto, mapa isoyetas] · CT(Tr) · CD(d) · CA(A,d)

CT(Tr) = 0.5786 - 0.4312 · log10( ln( Tr/(Tr-1) ) )         (Tr=10 años => CT=1, caso base)

CD(d) = 0.6208·d / (d+0.0137)^0.5639         si d < 3 h
CD(d) = 1.0287·d / (d+1.0293)^0.8083         si d > 3 h      (d en horas)

CA(A,d) = 1.0 - (0.3549·d^(-0.4272)) · (1.0 - e^(-0.005792·A))    (A en km²)

i = P(Loc,d,Tr,A) / d       (intensidad media de diseño, mm/h)
```

**Cuándo se usa.** Para el método Racional, con d=tc. Para el método NRCS,
para construir la tormenta de diseño por **bloque alterno**: se divide tc en
12 intervalos Δt=tc/7, se calcula P(d,Tr,A) para cada duración acumulada
d=k·Δt (k=1..12), se obtienen los incrementos de lluvia por diferencia, y se
reordenan (bloque alterno: el mayor al centro, decreciendo hacia los
extremos) para formar el hietograma de diseño. Si en cambio el enunciado da
una **precipitación puntual** ya registrada (pluviómetro, hietograma
observado en bloques) en vez de pedir una tormenta de diseño sobre una
cuenca, se omite CA (no hay área que promediar) y la relación se reduce a
P=P(3,10)·CD(d)·CT(Tr).

**Encontrar el Tr de un evento observado (inverso).** Dado un P (o una
intensidad i=P/d) ya registrado con su duración d, se despeja CT=P/(P(3,10)·CD(d))
y se **invierte numéricamente** CT(Tr) (no tiene forma cerrada para Tr; se
resuelve por bisección/`fsolve`/Buscar Objetivo) para obtener el período de
retorno de ese evento. Es el mismo procedimiento usado para encontrar el Tr
que hace que un caudal de diseño alcance un valor crítico (ver B4), aplicado
directamente sobre la lámina/intensidad en vez de sobre el caudal (ejemplo
completo: 2024 feb, Ej.3 parte 2 — intensidad máxima de un evento registrado
en pluviógrafo, P=26mm en d=10min, P(3,10)=79mm ⇒ Tr≈30 años; otro ejemplo,
2023 jul Ej.2 parte 3 — P=15.3mm en d=7min, P(3,10)=80mm, CA=1 (dato
puntual, sin corrección por área) ⇒ CT=0.837 ⇒ Tr≈4.5 años; otro ejemplo,
2023 feb 2 Ej.2 parte 2.1 — Imax=98mm/h en d=0.3h (bloque más intenso del
hietograma), P(3,10)=81mm, CA=1 ⇒ CT≈1.01 ⇒ Tr≈10 años; otro ejemplo,
2022 dic Ej.2 parte 2.2 — P=16.5mm en d=5min, P(3,10)=76mm, CA=1 (dato
puntual) ⇒ CT≈1.126 ⇒ Tr≈19 años. **Nota:** cuando
CT objetivo sale muy cerca de 1 (=CT(10) por definición), la inversión es
muy sensible a redondeos de CD/CT — conviene reportar el **Tr tabulado**
más próximo (2, 5, 10, 25, 50, 100 años) en vez del valor "exacto" con
decimales, que puede variar varias décimas de año según la precisión
usada en los pasos intermedios).

Cita: Teórico HHA §3.1.4; Formulómetro "Eventos extremos — Relaciones
Intensidad Duración Frecuencia".

## B4. Método Racional (y criterio de selección según tc)

**Concepto.** Supone que el caudal máximo se produce cuando **toda la
cuenca aporta simultáneamente**, lo cual ocurre cuando la duración de la
tormenta iguala tc, bajo la hipótesis de una tormenta de **intensidad
constante en el tiempo y uniforme en toda el área** de la cuenca.

**Hipótesis del método (si se piden enunciar, 2024 mar Ej.3):**
- Intensidad de la tormenta **constante en el tiempo y uniforme en el
  espacio** (en toda la cuenca), con duración de la tormenta = tc.
- El caudal pico es función del caudal promedio durante tc (Qpico=f(Qprom)).
- Se usa tc porque es el tiempo necesario para que **toda la cuenca
  drene** simultáneamente hacia el punto de cierre.
- **No hay almacenamiento temporal** de agua en la cuenca (no hay
  atenuación, toda la lluvia efectiva llega al punto de cierre sin
  laminar).

```
Q = C · i · A / 360
   Q = caudal máximo (m³/s)
   C = coeficiente de escorrentía (Tabla de Chow, según uso de suelo/pendiente/Tr; ver tabla completa
       en el Formulómetro — pastizales "promedio 2-7%" es la fila más usada en los 4 exámenes)
   i = intensidad de precipitación de diseño (mm/h), con d=tc  (ver B3)
   A = área de la cuenca (ha)
```

**Criterio de selección de método según tc (Teórico §3.1.5):**

```
tc < 20 min           =>  sólo método Racional
20 min <= tc <= 1 h    =>  calcular AMBOS métodos (Racional y NRCS) y adoptar el MAYOR caudal
tc > 1 h               =>  sólo método NRCS (Racional se desaconseja para cuencas grandes)
```

**Cuándo se usa.** Es el primer método a evaluar siempre que tc<1h. En los 4
exámenes resueltos aparece en los 4 (en 2025 feb 2, con tc≈1.23h>1h, el
Racional se descarta explícitamente por el criterio de arriba, sin
calcularlo, y se usa sólo NRCS).

**Hallar el Tr de un caudal límite dado** (2023 dic, Ej.2 parte b). Si el
enunciado da un caudal límite (p.ej. el que empieza a sobrepasar una
rasante) y pide su período de retorno, hay que invertir Q=C·i·A/360 en Tr.
`CT(Tr)` es continua y se puede despejar/iterar, pero **C sale de una
tabla (Tabla 3.1.4) tabulada en columnas DISCRETAS de Tr** (típicamente
2, 5, 10, 25, 50, 100 años) — no es una función continua de Tr. La forma
práctica de resolverlo es **probar los Tr tabulados** (con su C
correspondiente) hasta encontrar el escalón donde Q cruza el valor límite,
y adoptar ese Tr tabulado como respuesta (no interpolar entre columnas).

**Coeficiente de escorrentía ponderado y área urbanizable máxima**
(2023 dic, Ej.2 parte c; 2020 jul, Ej.2 parte 2 — mismo cálculo con
Aₜ=7.3 km², C1=0.36 pastizal, C2=0.80 concreto/techo, x=15% ⇒
A2=0.896 km² ≈12.3% del área; ver también B5 para el NC ponderado análogo del
método NRCS). Si una fracción A₂ de la cuenca (área total Aₜ) se urbaniza
(desarrollo en concreto/techo, C₂≈0.8-0.95) y el resto (A₁=Aₜ-A₂) conserva
su C₁ original, el coeficiente de escorrentía efectivo de toda la cuenca es
el promedio ponderado por área:

```
C_ponderado = (C1·A1 + C2·A2) / AT = (C1·AT + A2·(C2-C1)) / AT
```

Si además **tc no cambia** (dato del enunciado, o supuesto porque la red de
drenaje no se modifica), entonces i y A permanecen fijos en Q=C·i·A/360, y
por lo tanto **Q es directamente proporcional a C**. Esto permite despejar
en forma cerrada el área urbanizable máxima A₂ que no exceda un incremento
admisible de caudal (p.ej. "que Qmax no supere en x% el caudal original"):

```
Q_admisible = (1+x)·Q_original  =>  C_target = (1+x)·C_original   (por proporcionalidad directa)
A2 = AT · (C_target − C1) / (C2 − C1)
```

**Verificar si un evento REAL sostenido (d>tc, intensidad constante dada)
supera la capacidad de diseño** (2020 jul, Ej.2 parte 3.1). El método
Racional para hallar el caudal de DISEÑO exige d=tc exactamente (Teórico
§3.1.5: con d<tc no aporta toda la cuenca; con d>tc la intensidad de
diseño, que decrece con la duración según la IDF, ya es menor que la de
tc). Pero para VERIFICAR si un evento ya ocurrido (con su propia
intensidad, no necesariamente la de diseño) superó una obra, si ese
evento tiene d≥tc la fórmula Q=C·i·A/360 sigue siendo válida usando la
intensidad REAL del evento (no hace falta reducirla por duración vía la
IDF): una vez transcurrido tc desde el inicio de la lluvia, toda la
cuenca aporta simultáneamente y el caudal alcanza (y sostiene, mientras
dure el exceso de lluvia por encima de tc) el valor C·i·A/360 con esa i.
Sirve para comparar contra la capacidad de diseño sin tener que armar el
hidrograma completo por NRCS.

Cita: Teórico HHA §3.1.5 "Metodologías para determinación del caudal de
diseño"; Formulómetro "Cálculo de Caudales Máximos — Método Racional".

## B5. Método NRCS: Número de Curva + Hidrograma Unitario Triangular SCS

**Concepto.** Método completo de transformación lluvia-caudal: (1) se
calcula la **precipitación efectiva** Pe (la que realmente escurre) a partir
de la lluvia total P y del **Número de Curva** NC (que resume el uso y tipo
de suelo, grupo hidrológico A/B/C/D); (2) se convoluciona Pe con un
**hidrograma unitario sintético triangular** (forma estándar del SCS,
función de A y tc) para obtener el hidrograma de crecida completo.

```
Precipitación efectiva (retención NRCS):
   S = 25.4 · (1000/NC - 10)                    (S = retención potencial máxima, mm)
   Ia = 0.2 · S                                  (abstracción inicial, mm)
   Pe = 0                          si P <= 0.2S
   Pe = (P - 0.2S)² / (P + 0.8S)   si P > 0.2S

Hidrograma unitario triangular SCS:
   tp = D/2 + 0.6·tc          (D = duración del pulso de lluvia efectiva, tc = tiempo de concentración)
   tb = (8/3)·tp
   Qp = 0.208 · A / tp         (Qp en m³/s por mm de Pe; A en km², tp en horas)
```

**Cuándo se usa.** (1) Se arma la tormenta de diseño por bloque alterno
(B3) en Δt=tc/7, 12 bloques; (2) se calcula Pe **incrementalmente** en cada
bloque con el NC de la cuenca (con un piso de infiltración mínimo, ~1.2 mm/h,
según el grupo hidrológico, para bloques con muy poca lluvia); (3) se
convoluciona cada pulso de Pe con el hidrograma unitario triangular
(escalado por el Pe de ese pulso, desplazado en el tiempo) y se suman los
aportes ⇒ hidrograma total, con su Qmax y tiempo al pico. Siempre se usa si
tc>1h (único método válido) o si 20min<tc<1h (junto con el Racional,
adoptando el mayor caudal). También se aplica igual, pero con el hietograma
**observado** en su orden cronológico real (sin reordenar por bloque
alterno), para verificar si un evento de lluvia real supera la capacidad de
diseño de una obra.

**Número de Curva ponderado (cuenca con usos de suelo mixtos).** Si la
cuenca tiene más de un uso de suelo (p.ej. una fracción se urbaniza, o hay
zonas de distinto uso desde el inicio), el NC efectivo de toda la cuenca es
el promedio ponderado por área de los NC de cada uso:

```
NC_ponderado = Σ (fracción de área_i · NC_i)
```

Es el mismo criterio de ponderación por área que se usa para el Agua
Disponible media de una cuenca con varias unidades de suelo (B9). Cuando un
desarrollo urbano reemplaza parte de un uso de suelo (p.ej. pastizal→urbano,
lotes chicos muy impermeables ⇒ NC más alto) y además reduce tc (por
canalización del cauce), **ambos efectos aumentan el Qmax de diseño**: el NC
más alto reduce la infiltración (más Pe, más volumen de escorrentía) y el tc
más chico concentra ese mayor volumen en un hidrograma más picudo (mayor Qp,
menor Tp/Tb) — ver ejemplo completo en `resueltos/2024 Julio/RESOLUCION.md`,
Ejercicio 3, Parte 3.

**Caso más simple: urbanización SIN cambio de tc** (2023 feb 2, Ej.3 parte
c). Si el enunciado aclara que el desarrollo urbano **no** altera el tiempo
de concentración (p.ej. no canaliza el cauce principal), el único efecto es
el aumento del NC ponderado — se puede **invertir** directamente: dado un
Qmax objetivo (p.ej. +15% del Qmax original), se itera el NC ponderado
(bisección, manteniendo tc fijo) hasta que el hidrograma NRCS dé ese Qmax,
y de ahí se despeja la fracción de área urbanizada x en
NC_ponderado=x·NC_urbano+(1-x)·NC_original (y el área urbanizable máxima
Área_urb=x·Área_total). Es la misma lógica de "hallar el Tr de un caudal
límite" (B4) pero iterando sobre NC en vez de sobre Tr, y con una relación
NC→Qmax monótona pero sin forma cerrada (no alcanza con una regla de tres).
La misma inversión sirve con **Vesc como objetivo en vez de Qmax** (2022
jul, Ej.2 parte 3): una cuenca con dos usos de suelo mixtos desde el
inicio (60% pastizal + 40% cultivo en hileras) aumenta la fracción de
cultivo (mayor NC) sin cambiar tc; se itera la fracción de cultivo x
(bisección) en NC_ponderado=(1-x)·NC_pastizal+x·NC_cultivo hasta que
Vesc(Tr=10, NC_ponderado) no supere 1.10·Vesc_original, y el área
cultivable máxima es x·Área_total (el aumento admisible de área es esa
menos el área de cultivo ya existente). Exactamente la misma mecánica
que con Qmax: Vesc y Qmax son ambos monótonos crecientes en NC, así que
cualquiera de los dos sirve como variable objetivo de la bisección
según lo que pida el enunciado.

**Hallar el NC a partir de un evento observado (inverso)** (2020 feb,
Ej.3 parte 2). Si el enunciado da el hietograma de un evento REAL con su
precipitación total P y su precipitación efectiva Pe (ya medidas, p.ej.
por diferencia entre pluviógrafo y aforo), se puede despejar el NC de la
propia cuenca sin conocer uso de suelo ni tabla: se invierte
Pe=(P−0.2S)²/(P+0.8S) en S (bisección) y NC=25400/(S+254). El NC así
obtenido corresponde a la condición de humedad *real* del suelo durante
ESE evento — antes de darlo por bueno como "el NC de la cuenca" (el de
tabla, AMC II) hay que revisar con la P de los 5 días previos y la
estación (B6) si ese evento cayó en AMC I/II/III: si cayó en AMC II, el
NC obtenido ya es directamente el de tabla; si hubiera caído en AMC I o
III, habría que aplicar la fórmula de corrección de B6 **en sentido
inverso** (despejar NC(II) a partir del NC(I) o NC(III) recién hallado)
antes de reportarlo como el NC representativo de la cuenca. Cuando
además el HU triangular ya viene dado con sus tres parámetros (tp/tb/qp,
en vez de pedir calcularlo con la fórmula SCS a partir de A y tc), la
convolución de la Parte 1 se reduce a identificar qué bloques de Pe son
significativos (descartando los que el enunciado marca como
despreciables) y sumar la respuesta triangular de cada uno, escalada por
su Pe y desplazada al inicio de su bloque.

Cita: Teórico HHA §3.1.5 b)/c) y §3.1.6 "Método del NRCS (ex SCS)";
Formulómetro "Cálculo de caudales máximos e hidrograma de crecida: Método
NRCS" / "Hidrograma Unitario".

## B6. Condición de humedad antecedente (AMC)

**Concepto.** El NC "de tabla" corresponde a una condición de humedad media
del suelo (AMC II). Si el suelo está más seco (AMC I) o más húmedo (AMC III)
que esa condición media, hay que corregir el NC. La condición se determina
según la precipitación acumulada en los 5 días previos al evento y la
estación (activa/inactiva).

```
AMC I   (seco):   P5d < 12.7 mm (estación inactiva)  |  P5d < 35.56 mm (estación de crecimiento)
AMC II  (medio):  12.7-27.94 mm (inactiva)            |  35.56-53.34 mm (crecimiento)  -> NC sin corregir
AMC III (húmedo): P5d > 27.94 mm (inactiva)           |  P5d > 53.34 mm (crecimiento)

Corrección de NC si AMC I o III (a partir de NC(II) de tabla):
   NC(III) = 23.0·NC(II) / (10 + 0.13·NC(II))
   NC(I)   = 4.2·NC(II) / (10 - 0.058·NC(II))
```

**Cuándo se usa.** Al calcular el caudal generado por un **evento observado**
(no la tormenta de diseño): se ubica la estación del año (activa/inactiva en
Uruguay: la estación de crecimiento es aprox. primavera-verano) y se compara
la P5d dada con los umbrales de la tabla para decidir si corresponde AMC
I/II/III, y corregir el NC antes de calcular Pe (B5). En 4 de los 5 exámenes
donde aparece, el evento cayó en AMC II (no hizo falta corregir NC) — p.ej.
2024 feb, Ej.2 parte 3: P5d=15mm en estación inactiva, dentro del rango
12.7–27.94mm. **Primer caso con corrección efectiva (2023 dic, Ej.3 parte
2):** evento en julio (estación inactiva), P5d=62mm > 27.94mm ⇒ **AMC III**;
NC(II)=69 (tabla) se corrige a NC(III)=23·69/(10+0.13·69)=83.7, lo que
**reduce** la retención potencial S (de 25.4·(1000/69−10)=113.9mm a
25.4·(1000/83.7−10)=49.6mm) y por lo tanto **aumenta** fuertemente la
precipitación efectiva Pe para la misma lluvia total — el efecto físico
esperado de un suelo ya húmedo por lluvias previas: infiltra menos y
escurre más. **Primer caso con AMC I (2022 jul, Ej.2 parte 2):** evento
en febrero (estación de crecimiento), P5d=25mm < 35.56mm ⇒ **AMC I**;
NC(II)=78.4 (ponderado de tabla) se corrige a
NC(I)=4.2·78.4/(10−0.058·78.4)=**60.39** — un NC bastante más bajo, el
efecto opuesto al AMC III: suelo seco de antemano ⇒ infiltra más para la
misma lluvia total, y por lo tanto hace falta una tormenta bastante más
intensa (mayor Tr) para generar el mismo caudal pico que con NC de
tabla.

Cita: Teórico HHA §3.1.5 b) / Fig. 3.1.21; Formulómetro "Condiciones de
humedad antecedente".

## B7. Volumen de escorrentía y embalses de retención

**Concepto.** El volumen de escorrentía de un evento es la lámina de
precipitación efectiva total (ΣPe, del método NC) multiplicada por el área
de la cuenca; equivale también a la integral en el tiempo del hidrograma de
crecida (Q(t)), ambos caminos deben coincidir por ser la misma cantidad
física. Un embalse de retención dimensionado para "no inundar" debe poder
almacenar como mínimo ese volumen completo del evento de diseño.

```
Vesc = Σ Pe (mm) · Área (km²) · 1000      (1 mm sobre 1 km² = 1000 m³)
Verificación cruzada: Vesc ≈ ∫ Q(t) dt   (regla del trapecio sobre el hidrograma)
```

**Cuándo se usa.** Para dimensionar el volumen mínimo de un embalse de
retención que debe absorber toda la escorrentía del evento de diseño (Tr
dado) sin que aguas abajo se supere una restricción (p.ej. un camino que se
inunda a partir de cierto caudal); o simplemente para reportar el volumen de
escorrentía de un hidrograma ya calculado (con su verificación cruzada
integrando Q(t)).

Cita: se deriva directamente del balance del método NRCS (Teórico §3.1.5
c); no tiene sección propia — es una aplicación de B5.

## B8. Infiltración de Horton y tiempo de encharcamiento

**Concepto.** El modelo de Horton describe la capacidad de infiltración del
suelo f(t) decayendo exponencialmente desde un valor inicial f₀ (suelo seco)
hasta un valor asintótico fc (suelo saturado). El **tiempo de encharcamiento**
("ponding time") es el instante en que la intensidad de lluvia i(t) supera
la capacidad de infiltración f(t): antes de él, toda la lluvia infiltra; a
partir de él, el exceso escurre.

```
f(t) = fc + (f0 - fc) · e^(-K·t)
   f0 = capacidad de infiltración inicial/máxima (mm/h)
   fc = capacidad de infiltración básica/mínima (mm/h)
   K  = constante de decaimiento (1/h)
   t  = tiempo desde el inicio del ensayo/evento (h)

Criterio práctico con lluvia en bloques: comparar, al inicio de cada bloque,
la intensidad media del bloque i (mm/h) con f(t) evaluada en ese instante.
Mientras i(t) > f(t): infiltración real = f(t) (bloque "capacidad-limitado"),
el resto escurre. Si i(t) < f(t) (y no hay déficit acumulado pendiente):
infiltra el 100% de la lluvia de ese bloque ("lluvia-limitado").

Vinf = Σ (lluvia infiltrada, bloque a bloque; integral de f(t) en los bloques capacidad-limitados)
Vesc = P_total - Vinf                    (balance simple)
```

**Cuándo se usa.** Con un hietograma en bloques y parámetros de Horton
(f₀, fc, K) dados: (1) se halla el tiempo de encharcamiento comparando i vs.
f(t) al inicio de cada bloque; (2) se separan los bloques en
"capacidad-limitados" (encharcados, infiltran a tasa f(t), integrando
analíticamente) y "lluvia-limitados" (infiltran el 100%, antes del
encharcamiento o cuando i vuelve a caer por debajo de fc); (3) se suma el
volumen infiltrado total y, por balance, el volumen de escorrentía.

Ejemplo (2023 feb 2, Ej.2 parte 2.2): f₀=112 mm/h, fc=0.18 mm/h, K=2.5
1/h, hietograma en bloques de 0.3h. El bloque 0.2-0.5h (I=68 mm/h) da
f(0.2h)=68.0 mm/h — prácticamente igual a la intensidad: es el punto de
encharcamiento (t_enc=0.2h), aunque calculado con más precisión f(0.2h)
sale 68.02 mm/h (una diferencia de 0.03%, producto del redondeo con que
se armó el enunciado) — no vale la pena perseguir esa diferencia de
milésimas, el bloque marcado es el de encharcamiento.

Cita: Teórico HHA §3.1.3 (infiltración, modelo de Horton); Formulómetro
"Agua en el Suelo — Curva de infiltración de Horton".

## B9. Agua Disponible del suelo, ETc (Kc) y necesidad de riego

**Concepto.** El Agua Disponible (AD) de un suelo es el agua utilizable por
las plantas: diferencia entre la Capacidad de Campo y el Punto de
Marchitez Permanente (tabulada por unidad cartográfica de suelos del
Uruguay). Si la cuenca tiene varias unidades de suelo, el AD media se
pondera por fracción de área. La evapotranspiración del cultivo ETc se
estima con un coeficiente de cultivo Kc (que depende de la etapa
fenológica) sobre la evapotranspiración de referencia ETP/ET0. La necesidad
de riego surge de un balance mensual simple: si lo que demanda el cultivo
(ETc) supera lo que aporta la lluvia más la reserva de humedad del suelo, la
diferencia debe regarse.

```
AD_media = Σ (fracción de área_i · AD_i)              (ponderado por unidad de suelo, Tabla 1.4.2)

ETc = Kc · ET0                                          (Kc de Tabla 1.3.3 según cultivo y etapa)

Balance mensual (extensión estándar, no formalizado explícitamente en el Teórico):
   Hi-1 = reserva de humedad inicial del suelo (p.ej., dato o fracción del AD media)
   ETR  = P + Hi-1                                      (agua disponible para evapotranspirar)
   R (necesidad de riego) = ETC - ETR    si ETC > ETR ; si no, R=0
```

**Cuándo se usa.** Para estimar cuánta agua adicional (riego) necesita un
cultivo en un mes dado, conocidas la lluvia del mes, la ETP, el Kc de la
etapa fenológica, y el Agua Disponible del suelo de la cuenca (que fija
cuánta reserva de humedad puede aportar el suelo).

Cita: Teórico HHA §1.4 "Agua en el suelo" (Tabla 1.4.2, Agua Disponible,
Molfino y Califra 2001), §1.3 "Precipitación/Evapotranspiración" (Tabla
1.3.3, coeficiente Kc); Formulómetro "Agua en la Atmósfera" (ETc=Kc·ET0) y
tabla "Agua Disponible (mm) y Grupo hidrológico según Unidad Cartográfica".

## B10. Coeficiente de escorrentía por balance directo de abstracciones

**Concepto.** Cuando el enunciado da **directamente** las abstracciones
del evento (infiltración total y/o intercepción, en mm) en vez de pedir
que se calculen con un modelo (NC, Horton), el coeficiente de
escorrentía del evento sale de un balance de lámina simple, sin ningún
modelo de infiltración: la precipitación total se reparte entre lo que
se pierde (abstracciones) y lo que escurre.

```
Prec = i · d                              (si la intensidad es constante; i en mm/h, d en h)
Abstracciones = Infiltración total + Intercepción + ... (todo lo que da el enunciado, mm)
Esc = Prec − Abstracciones
C = Esc / Prec
```

**Cuándo se usa.** Sólo cuando el propio enunciado da las abstracciones
ya calculadas o medidas (no hay que estimarlas con NC/Horton) — es el
caso más simple de "coeficiente de escorrentía de un evento": alcanza
con restar y dividir, sin resolver ninguna ecuación. Distinto de B5 (NC,
donde Pe sale de la fórmula NRCS a partir del Número de Curso) y de B8
(Horton, donde la infiltración se integra de un modelo exponencial en el
tiempo) — acá la infiltración y la intercepción son datos directos del
enunciado. Ejemplo (2022 dic, Ej.3 parte 2): intensidad constante
i=130 mm/h, duración d=30 min ⇒ Prec=65 mm; infiltración total=15 mm,
intercepción=5 mm ⇒ Abstracciones=20 mm ⇒ Esc=45 mm ⇒ C=45/65=0.69.

Cita: Teórico HHA §3.1.1 "Precipitación efectiva/abstracciones"
(concepto general P=Pe+abstracciones); Formulómetro "Precipitación
Efectiva".

---

# C. Sistemas de bombeo

## C1. Ecuación de la instalación de bombeo (Darcy-Weisbach + Colebrook-White)

**Concepto.** La carga que debe entregar la bomba Hm es la diferencia de
carga hidráulica total entre el punto de descarga (B/D) y el de succión
(A/S), sumando las pérdidas de carga distribuidas (fricción, Darcy-Weisbach)
y localizadas (accesorios, válvulas, entradas/salidas) de ambos tramos. El
factor de fricción f se resuelve con Colebrook-White (equivalente numérico
del ábaco de Moody), función de Re y de la rugosidad relativa.

```
H = p/γ + z + Q²/(2gA²)                          (carga hidráulica en una sección)
Hm = HB - HA = (H_descarga - H_succión) + ΔH(succión) + ΔH(impulsión)

ΔH(succión)  = Σks·Q²/(2gAs²) + Σfs·(Ls/Ds)·Q²/(2gAs²)
ΔH(impulsión)= Σkd·Q²/(2gAd²) + Σfd·(Ld/Dd)·Q²/(2gAd²)

Colebrook-White (flujo turbulento de transición, caso general):
   1/sqrt(f) = -2·log10( k/(14.83·Rh) + 2.52/(Re·sqrt(f)) )     (iterativo; Rh=D/4 en tuberías circulares)
```

Si la descarga es **libre** (a la atmósfera, sin depósito grande aguas
abajo), la energía cinética de salida V²/(2g) **no se recupera** y debe
incluirse como parte de la carga exigida por la instalación. Si ambos
extremos son superficies libres de grandes depósitos (v≈0), esos términos
cinéticos se anulan en la ecuación de instalación.

**Cuándo se usa.** Es la base de todo problema de bombeo: para cada Q de
prueba se calcula Hm(Q) de la instalación (iterando f con Colebrook-White,
ya que f depende de Re que depende de Q) y se compara con la curva H-Q de la
bomba (C2) para hallar el punto de funcionamiento.

**Caso particular: manómetros en las bridas de la bomba (entrada/salida).**
Si el enunciado da directamente las lecturas p_A (succión) y p_B
(impulsión) de dos manómetros ubicados justo antes y después de la bomba, a
la **misma cota** z_A, no hace falta calcular ninguna pérdida de carga de
tubería para obtener Hm: alcanza con H_A=z_A+p_A/γ+V_succión²/2g y
H_B=z_A+p_B/γ+V_impulsión²/2g (mismo z_A en ambas), por lo que
Hm=H_B−H_A=(p_B−p_A)/γ+(V_impulsión²−V_succión²)/2g, función de Q sólo a
través de las velocidades (áreas de succión/impulsión, que pueden tener
distinto diámetro). Se interseca igual con la curva H-Q de la bomba (C2)
para hallar (Qpf,Hpf) (2024 feb, Ej.4 parte 1).

**Caso particular: UN solo manómetro (aguas abajo de la bomba), con el
extremo de aguas ARRIBA siendo un lago/depósito por tubería, y el
extremo final de aguas abajo (tanque) de cota DESCONOCIDA** (2022 jul,
Ej.4). Distinto del caso anterior (dos manómetros, misma cota): acá el
manómetro reemplaza sólo a UNO de los dos extremos de la ecuación de
instalación, y por eso el problema se separa en dos balances de energía
independientes y sucesivos:
1. **Lago → manómetro** (usa la tubería de succión completa, con sus
   pérdidas Darcy-Weisbach+Colebrook, hasta la bomba, y después la
   propia lectura del manómetro para la sección de aguas abajo): esto
   alcanza para hallar Q **sin conocer la cota del tanque final** —
   Hbomba(Q)=zA−z_lago+p_manómetro+V²/2g+ΔH(succión). Se itera Q
   (bisección/`fzero`) hasta que la curva H-Q de la bomba cierre esta
   ecuación.
2. **Manómetro → tanque** (recién acá se usa la tubería de impulsión
   completa, con Q ya conocido del paso 1): z_tanque=zA+p_manómetro+
   V²/2g−ΔH(impulsión).
Si además hay **dos bombas iguales en paralelo** compartiendo la misma
succión y la misma impulsión (con pérdidas de acople despreciables),
Q del paso 1 es el caudal TOTAL de la instalación, pero la curva H-Q a
usar en el balance es la de **una sola bomba** evaluada en Q/2 (cada
bomba entrega la mitad del caudal a la misma H).

Cita: Teórico HHA §3.3.10 "Curva de la instalación" (Ec. 15, 18, 19);
Formulómetro "Bombas — Carga hidráulica" / "Curva de la Instalación".

**Instalación con bifurcación en ramas idénticas (una sola bomba, red
ramificada)** (2023 jul, Ej.4). No confundir con C5 (bombas en
serie/paralelo, donde hay más de una bomba): acá hay **una sola bomba**
que alimenta, después de un nodo de bifurcación, dos (o más) tuberías
IDÉNTICAS que descargan por separado (p.ej. a la atmósfera, con
tobera). Por simetría, cada rama transporta la MITAD del caudal total
que pasa por la bomba (si son N ramas idénticas, cada una lleva Q/N).
La ecuación de la instalación se arma encadenando dos tramos con
caudales distintos: succión+impulsión con el caudal TOTAL Q (hasta el
nodo), y nodo→salida de una rama con el caudal Q/N:

```
Hm(Q) = H_salida − H_entrada + Σ(succión+impulsión, con Q) + Σ(una rama, con Q/N)
H_salida = v_salida²/2g + z_salida     (si descarga libre, ver arriba)
v(succión/impulsión) = Q/A    ;    v(una rama) = (Q/N)/A_rama
```

Se itera igual que cualquier curva de instalación (C2), pero cuidando
de **no** usar el caudal total en las velocidades de las ramas — es un
error común (detectado en la propia solución oficial manuscrita de este
examen: reportaron correctamente la fórmula v_rama=(Q/2)·4/(πD²) pero
al reemplazar usaron el Q total en vez de Q/2, dando una v_rama al
doble de la real, aunque el resto del desarrollo —Qpf, Hpf— sí usó la
fórmula correcta).

## C2. Curva de la bomba y punto de funcionamiento

**Concepto.** La bomba tiene una curva característica H(Q) (decreciente,
dada por tabla/fabricante) y una curva de rendimiento η(Q). El **punto de
funcionamiento** es la intersección entre la curva de la bomba H_bomba(Q) y
la curva de la instalación H_inst(Q) (C1): el único (Q,H) en el que ambas
exigencias se satisfacen simultáneamente.

```
Punto de funcionamiento: H_bomba(Q) = H_instalación(Q)     (búsqueda de raíz / intersección gráfica)
```

**Cuándo se usa.** Para cualquier condición de operación (válvula en
distinta posición, distinta presión de descarga, ampliación con más bombas,
etc.) se recalcula la curva de instalación correspondiente y se busca su
nuevo cruce con la curva de la bomba (interpolando la tabla dada, p.ej. con
`pchip`). Cambios que desplazan la curva de instalación hacia arriba
(mayor carga estática, más pérdida) mueven el punto de funcionamiento a
menor Q y mayor H (porque la curva de la bomba es decreciente).

Cita: Teórico HHA §3.3.8 "Curvas características de una bomba", §3.3.11
"Punto de funcionamiento de una bomba".

## C3. Potencia consumida por el sistema de bombeo

**Concepto.** La potencia consumida por la bomba es la potencia hidráulica
entregada al fluido (γ·Q·H) dividida entre el rendimiento η de la bomba en
ese punto de funcionamiento (el rendimiento no es 100%: hay pérdidas
mecánicas/hidráulicas internas de la bomba).

```
Pcons = γ · Q · H / η        (η interpolado de la tabla de la bomba en el Q del punto de funcionamiento)
```

**Cuándo se usa.** Siempre después de hallar el punto de funcionamiento
(C2): se interpola η(Q_PF) de la tabla de la bomba y se calcula Pcons. Con
varias bombas (serie o paralelo), la potencia total es la suma de la
potencia de cada bomba (cada una con su propio Q y η, aunque compartan H en
paralelo, o compartan Q en serie).

Cita: Teórico HHA §3.3.6 "Potencia consumida"; Formulómetro "Bombas —
Potencia Consumida".

## C4. Cavitación: NPSH disponible vs. requerido

**Concepto.** La cavitación ocurre si la presión en algún punto de la bomba
(típicamente la entrada del rodete) cae por debajo de la presión de vapor
del líquido. Se verifica comparando el **NPSH disponible** (margen de
presión que ofrece la instalación de succión, por encima de la presión de
vapor) contra el **NPSH requerido** (el que exige la bomba en ese Q, dato de
tabla/fabricante). El NPSH disponible depende **únicamente del tramo de
succión** (no de lo que pase en la impulsión ni de la presión de descarga).

```
No hay cavitación si  NPSH_disp > NPSH_req

NPSH_disp = HA - zA + patm/γ - pvapor/γ
   HA = carga (piezométrica + cinética) en la brida de succión de la bomba
   zA = cota de la bomba
   patm/γ = 10.33 m.c.a. (nivel del mar)
   pvapor/γ = 0.24 m.c.a. (agua a 20°C; aumenta con la temperatura, reduciendo NPSH_disp)
```

**Cuándo se usa.** Después de cada punto de funcionamiento, se calcula HA
(carga en la succión, con sus pérdidas ΔH(succión) de C1) y se compara
NPSH_disp con NPSH_req (interpolado de la tabla en el Q de ese punto). Con
varias bombas en paralelo compartiendo la succión, NPSH_disp se calcula con
el caudal **total** que pasa por la succión común, pero NPSH_req se
interpola con el caudal **individual** de cada bomba. A mayor temperatura
del agua, pvapor/γ sube y NPSH_disp baja ⇒ mayor riesgo de cavitación (la
condición más exigente es siempre la de mayor temperatura, aunque el punto
de funcionamiento no cambie con la temperatura, ya que se desprecian los
cambios de viscosidad/densidad).

**Trampa común: el término cinético de HA se CANCELA, no se suma de
nuevo.** Si se calcula HA por Bernoulli desde la superficie libre del
tanque/lago de origen (cota z0, presión atmosférica, v≈0) hasta la brida
de succión: `HA = z0 - ΔH(succión)` (en presión manométrica, **sin**
sumar ningún término `v²/(2g)` de la succión). Es un error común agregar
el término cinético de la succión a HA y usarlo así en la fórmula de
NPSH_disp de arriba: por la propia definición de NPSH (que ya incluye
`+v²/(2g)` explícitamente), ese término se cancela algebraicamente contra
el que traería HA si se calculara con velocidad — sumarlo en ambos lados
lo cuenta dos veces y da un NPSH_disp mayor al real (se detectó y corrigió
este bug en `RESUMEN EXAMEN/Codigos/Bombas/Bomba_sola.m`,
`Bombas_serie.m` y `Bombas_paralelo.m` resolviendo 2023 dic Ej.4: con el
término duplicado el NPSH_disp daba ≈0.4 m más alto que el oficial). Ojo:
esa HA "sin velocidad" es sólo para NPSH — la HA que sí necesita el
término cinético (`z0+p0/γ+v²/2g-ΔH`) es la que entra en la ecuación de
la **instalación** Hm=HB-HA (C1), que es un cálculo distinto.

**Distinguir la "trampa" de arriba de un manómetro dentro de la propia
cañería (no la cancelar de más).** La cancelación del término cinético de
arriba aplica sólo cuando el punto de referencia z0/H1 es una superficie
libre grande (v≈0 real, pero la fórmula de HA le agrega igual v²/2g "de
más" por comodidad de notación). Si en cambio el enunciado da un
**manómetro ubicado dentro de la propia tubería de succión** (con una
velocidad real Vs≠0 en ese punto, no una superficie libre), entonces
`H1=z1+p1/(ρg)+Vs²/2g` representa la energía en ese punto **una sola
vez, correctamente** — no hay nada que cancelar, y NPSH_disp=HA−zA+(patm
−pvap)/γ se calcula directo, **sin** restar Vs²/2g de nuevo. Aplicar por
inercia la resta de la "trampa" en este caso da un NPSH_disp **más bajo**
que el real (2022 dic, Ej.4: con la resta de más da 9.05 m; sin
restarla, 9.80 m, que es el que coincide con la solución oficial). Antes
de aplicar la corrección, preguntarse: **¿el punto de referencia es una
superficie libre (v≈0, hay que cancelar) o un punto real de la tubería
con velocidad de flujo (no hay que cancelar)?**

**Bomba en aspiración (succión negativa).** Si la bomba está instalada por
encima del nivel del tanque de succión (z_bomba>z_tanque), ese desnivel
**resta** al NPSH disponible (hay que "levantar" el agua además de vencer
la pérdida de carga): NPSH_disp = (Patm−Pvap)/γ − (z_bomba−z_tanque) −
h_succión(Q). Es el mismo caso límite que cuando el enunciado da directamente
z_bomba por encima de z_tanque (en vez de una carga de succión positiva).

**Cota máxima de la bomba sin cavitar.** Para un Q y unas longitudes de
tubería fijas, se despeja la cota de la bomba que hace NPSH_disp=NPSH_req
(límite de cavitación): z_bomba,max = z_tanque + (Patm−Pvap)/γ −
h_succión(Q) − NPSH_req(Q) (2024 jul, Ej.4).

**Con manómetro de succión dado directamente.** Si se conoce p_A (lectura
del manómetro en la brida de succión, ver C1) en vez de tener que calcular
la carga de succión con pérdidas de tubería, NPSH_disp se obtiene
directamente de la presión **absoluta** en ese punto:
NPSH_disp=(Patm+p_A−Pvap)/γ+V_succión²/2g (p_A entra con su signo, típicamente
negativo si la bomba aspira) — mismo resultado que la fórmula general de
arriba, sólo que p_A ya incorpora todas las pérdidas de succión sin
necesidad de calcularlas por separado (2024 feb, Ej.4 parte 2).

**Nivel mínimo del tanque de succión sin cavitar, CON punto de
funcionamiento autoconsistente** (2020 jul, Ej.3 parte 4). Distinto del
caso "cota máxima de la bomba" de arriba (ahí Q quedaba fijo y sólo se
despejaba una cota en forma cerrada): si lo que baja es el **nivel del
tanque de succión** (z_tanque), el punto de funcionamiento **también se
mueve**, porque la ecuación de la instalación Hm=(z2−z1)+ΔH(succión)+
ΔH(impulsión) depende de z1 — al bajar z1 aumenta el desnivel estático a
vencer, sube toda la curva de instalación, y el PF se corre a **menor Q**
(sobre la curva de la bomba, decreciente). Ese menor Q a su vez baja
ΔH(succión) (mejora NPSH_disp) pero también baja NPSH_req (la curva del
catálogo también decrece con Q) — ambos efectos van en sentidos
opuestos y no hay forma cerrada. Se resuelve con un `fzero` **anidado**:
para cada z_tanque de prueba, (a) se resuelve el PF completo (intersección
curva bomba vs. instalación, como en C2), (b) con el Q de ese PF se
calculan NPSH_disp(z_tanque,Q) y NPSH_req(Q), y (c) se itera z_tanque
hasta que NPSH_disp=NPSH_req. El resultado final se redondea **hacia el
lado seguro** (hacia 0, no hacia más profundidad) a la precisión pedida
por el enunciado. Con succión compartida por varias bombas en paralelo,
NPSH_disp usa el Q **total** (C4) mientras que NPSH_req usa el Q
**individual** (=Q_total/n_bombas si son idénticas) en cada iteración.

Cita: Teórico HHA §3.3.14 "Cavitación"; Formulómetro "Bombas — Cavitación".

## C5. Bombas en serie y en paralelo

**Concepto.** Al acoplar dos bombas: en **paralelo**, ambas ven la misma H y
sus caudales se suman (Q_eq(H)=Q1(H)+Q2(H)); en **serie**, ambas ven el
mismo Q y sus cargas se suman (H_eq(Q)=H1(Q)+H2(Q)). Cuál acople conviene
depende de la forma relativa de las curvas: si la curva de la instalación es
relativamente plana (domina la carga estática frente a pérdidas) y la curva
de la bomba es empinada, el acople en **paralelo** desplaza mucho más el
punto de funcionamiento en caudal que el acople en serie (para una misma
instalación "poco sensible a H pero sensible a Q").

```
Paralelo (2 bombas iguales o distintas): curva equivalente H(Q1+Q2) = H1(Q1) = H2(Q2)
Serie:                                   curva equivalente H1(Q)+H2(Q) para el mismo Q
```

**Cuándo se usa.** Para decidir/verificar cómo ampliar la capacidad de un
sistema de bombeo agregando una segunda bomba: se construye la curva
equivalente (paralelo o serie, según el enunciado o según cuál convenga) y
se recalcula el punto de funcionamiento con la curva de instalación (C2).
Con bombas en paralelo compartiendo succión/impulsión, esos tramos ahora
transportan el caudal **total**, lo que aumenta sus pérdidas y reduce el
NPSH disponible común (C4), aunque cada bomba individualmente trabaje a
menor Q que si operara sola.

**N bombas IDÉNTICAS en paralelo (N>2)** (2020 jul, Ej.3: 3 bombas
idénticas, succión e impulsión comunes). Se generaliza igual que el caso
de 2 bombas: todas ven el mismo H, los caudales se suman, así que la
curva equivalente es simplemente la curva de catálogo de UNA bomba con el
eje de caudal escalado por N (H_eq(N·Q₁)=H₁(Q₁)). En el punto de
funcionamiento, cada bomba entrega exactamente Q_total/N (por simetría,
todas ven el mismo H y tienen la misma curva). La potencia total del
sistema es N veces la potencia de una bomba individual (todas trabajan en
el mismo punto de su propia curva, misma eficiencia).

**Criterio rápido para elegir serie vs. paralelo (número mínimo de bombas).**
En **paralelo**, el H entregado nunca supera el H máximo de la curva de UNA
sola bomba (todas ven la misma H, sólo se suma Q): si la carga estática a
vencer (Hm en Q≈0, p.ej. z2−z1+p2/γ) ya supera el máximo de la curva H(Q) de
una bomba, ningún número de bombas en paralelo puede elevar el agua —hace
falta **serie** (que sí suma cargas). Se verifica comparando
max(H_bomba(Q)) contra la carga estática de la instalación **antes** de
resolver el punto de funcionamiento completo (2024 mar, Ej.4).

**Bombas en paralelo con succiones INDEPENDIENTES** (2023 dic, Ej.4 parte
4; se pide sólo plantear las ecuaciones, sin resolver numéricamente). Si
cada bomba tiene su propio tramo de succión (en vez de una succión única
compartida), ya no existe una "bomba equivalente" simple — hay que
plantear un sistema con el nodo donde se juntan las dos impulsiones
individuales antes de la impulsión común (si la hay), o directamente en
la brida de descarga de cada bomba si la impulsión también es
independiente hasta destino:

```
Qtotal = Q1 + Q2
H1(Q1) = HN + ΔH(impulsión común, con Qtotal)     (bomba 1 hasta el nodo N + tramo común)
HN = H0 + ΔH(succión 1, con Q1) − HB1(Q1)          (carga en N por el camino de la bomba 1; HB1 = curva de catálogo)
HN = H0 + ΔH(succión 2, con Q2) − HB2(Q2)          (mismo nodo N, por el camino de la bomba 2 — debe dar igual)
```

4 incógnitas (Q1, Q2, HN, Qtotal), a resolver con `fsolve` (no hay forma
cerrada ni intersección directa de curvas H-Q como en el caso de succión
única). El NPSHdisp de cada bomba también se calcula por separado, con
la ΔH(succión) de su propio tramo y su propio caudal individual (a
diferencia del caso de succión compartida, donde NPSHdisp es común a
ambas bombas y se calcula con el caudal total, ver C4).

Cita: Teórico HHA §3.3.13 "Acoplamiento de bombas".

## C6. Regulación de caudal por válvula (pérdida localizada variable)

**Concepto.** Una válvula reguladora (p.ej. de esclusa) agrega una pérdida
localizada k_v(posición) a la impulsión, que se suma al resto de las
pérdidas: k_total = k_base + k_v. Cerrar la válvula aumenta k_v, lo que
desplaza la curva de instalación hacia arriba y reduce el caudal del punto
de funcionamiento. Sirve para limitar la velocidad de salida (o cualquier
otra restricción de Q) sin cambiar la bomba ni la tubería.

```
k_impulsión(posición) = k_base + k_v(posición)      (k_v crece fuertemente al cerrar la válvula)
Se recalcula el punto de funcionamiento (C1+C2) para cada posición de la tabla
hasta encontrar la primera que cumple la restricción (p.ej. V_salida < V_max)
```

**Cuándo se usa.** Cuando se pide encontrar la posición de una válvula que
cumpla una restricción de velocidad/caudal: se prueban las posiciones dadas
(de más abierta a más cerrada) y se toma la **primera que cumple**, ya que
es la que permite el mayor caudal posible cumpliendo la restricción. Nota:
cerrar la válvula reduce Q, lo que además reduce el NPSH requerido más de lo
que empeora (o incluso mejora) el NPSH disponible en la succión (que no
depende de la válvula, situada en la impulsión) ⇒ el riesgo de cavitación
generalmente **disminuye** al cerrar la válvula.

Cita: Teórico HHA §3.3.10 (pérdidas localizadas variables); Formulómetro
"Coeficiente de pérdida de carga en válvulas".

**Caso inverso: hallar kv dado un Q objetivo** (2023 feb 2, Ej.4 parte
1). Si el enunciado da directamente el caudal que debe circular (en vez
de pedir el punto de funcionamiento), el problema es **directo, no
iterativo**: con Q conocido se calculan v1, v2, Re, f1, f2 sin
iteración, se lee Hb de la curva de catálogo en ese Q, y se **despeja
kv** de la ecuación de la instalación (Hb=(H2−H1)+ΔH_succ+ΔH_imp(kv),
con ΔH_imp=(f2·L2/D2+kv+k2)·v2²/2g) — un único paso algebraico, sin
`fsolve` ni barrido de curvas. Distinto del caso "usual" de este mismo
tema (kv dado, hallar Q) que sí requiere iterar/interpolar la
intersección de curvas (C2).

**Instalación que recircula en un ÚNICO tanque, con descarga libre**
(2023 feb 2, Ej.4). La succión y la impulsión salen/vuelven al MISMO
tanque abierto (no hay "tanque 1" y "tanque 2" distintos): la succión
parte del nivel del agua (H1=z1, superficie libre, v≈0) y la impulsión
descarga de vuelta al tanque desde una cota más alta, en el aire, antes
de caer al agua — una **descarga libre** (C1): H2=z2+v2²/2g, sin
recuperar la cinética. La ecuación de la instalación es la misma de
siempre (Hb=(H2−H1)+ΔH_succ+ΔH_imp), sólo que z1 y z2 son dos alturas
del mismo tanque en vez de dos tanques separados.

---

## ESTADO: COMPLETO (compilado retroactivamente a partir de los 4 exámenes resueltos)
