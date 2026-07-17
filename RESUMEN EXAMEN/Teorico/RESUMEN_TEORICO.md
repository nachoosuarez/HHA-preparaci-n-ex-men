# Resumen Teórico HHA — depurado a partir de los 4 exámenes resueltos

Este resumen se construyó leyendo completos los 4 exámenes ya resueltos en
`resueltos/` (2024 diciembre, 2025 Febrero 1, 2025 Febrero 2 y 2026 Febrero,
todos con `ESTADO: COMPLETO`) y extrayendo de ahí **todos los temas y
fórmulas que efectivamente fueron preguntados**, fusionando los que se
repiten entre exámenes en una sola sección enriquecida. Las fórmulas se
verificaron/precisaron contra `Teórico HHA.pdf` y `01_Formulometro2025.pdf`
(citados como "Formulómetro"). Objetivo: alcanzar para repasar sin releer
los 4 `RESOLUCION.md` completos.

Convención de nombres cortos de examen: **2024 dic** = 2024 diciembre;
**2025 feb 1** = 2025_FEBRERO 1 (27/feb/2025); **2025 feb 2** = 2025_FEBRERO 2
(5/feb/2025); **2026 feb** = 2026 Febrero (3/feb/2026); **2024 jul** = 2024
Julio.

## Índice de temas

| Tema | Veces preguntado | Exámenes |
|---|---|---|
| A1. Ecuación de FGV y clasificación de canales M/S | 5 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul |
| A2. Energía específica y tirante crítico | 5 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul |
| A3. Cantidad de movimiento, tirante conjugado y resalto hidráulico | 5 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul |
| A4. Perfiles de flujo controlados por lagos/embalses y por caída libre | 4 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb |
| A5. Transiciones de fondo: cambio de sección, escalón y compuerta de fondo | 4 | 2024 dic, 2025 feb 2, 2026 feb, 2024 jul |
| A6. Tensión rasante de fondo en FGV | 1 | 2025 feb 1 |
| B1. Delimitación de cuencas y divisoria de aguas | 5 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul |
| B2. Tiempo de concentración (Ramser-Kirpich) | 5 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul |
| B3. Curvas IDF de Uruguay y coeficientes CD/CT/CA | 5 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul |
| B4. Método Racional (y criterio de selección según tc) | 5 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul |
| B5. Método NRCS: Número de Curva + Hidrograma Unitario Triangular SCS | 5 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb, 2024 jul |
| B6. Condición de humedad antecedente (AMC) | 2 | 2025 feb 1, 2026 feb |
| B7. Volumen de escorrentía y embalses de retención | 2 | 2024 dic, 2025 feb 2 |
| B8. Infiltración de Horton y tiempo de encharcamiento | 1 | 2025 feb 2 |
| B9. Agua Disponible del suelo, ETc (Kc) y necesidad de riego | 1 | 2026 feb |
| C1. Ecuación de la instalación de bombeo (Darcy-Weisbach + Colebrook-White) | 4 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb |
| C2. Curva de la bomba y punto de funcionamiento | 4 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb |
| C3. Potencia consumida por el sistema de bombeo | 4 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb |
| C4. Cavitación: NPSH disponible vs. requerido | 4 | 2024 dic, 2025 feb 1, 2025 feb 2, 2026 feb |
| C5. Bombas en serie y en paralelo | 2 | 2025 feb 1, 2025 feb 2 |
| C6. Regulación de caudal por válvula (pérdida localizada variable) | 1 | 2024 dic |

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
independiente entre sus dos secciones inmediatas (2024 jul, Ej.1).

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

Cita: Teórico HHA §2.5.3 (caída libre), §2.5.4 (perfiles entre dos lagos,
casos M y S), §2.5.5 (perfil con compuerta de fondo entre dos lagos), §2.5.6
(canal con cambio de pendiente/empalme de tramos).

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

Cita: Teórico HHA §2.2 (transiciones de energía), §2.3.2–2.3.3
(conjugados/resalto), §2.5.5 (compuerta de fondo entre dos lagos), §2.5.6
(cambio de pendiente/sección).

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
directamente sobre la lámina/intensidad en vez de sobre el caudal.

Cita: Teórico HHA §3.1.4; Formulómetro "Eventos extremos — Relaciones
Intensidad Duración Frecuencia".

## B4. Método Racional (y criterio de selección según tc)

**Concepto.** Supone que el caudal máximo se produce cuando **toda la
cuenca aporta simultáneamente**, lo cual ocurre cuando la duración de la
tormenta iguala tc, bajo la hipótesis de una tormenta de **intensidad
constante en el tiempo y uniforme en toda el área** de la cuenca.

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
I/II/III, y corregir el NC antes de calcular Pe (B5). En los 2 exámenes donde
aparece, el evento cayó siempre en AMC II (no hizo falta corregir NC).

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

Cita: Teórico HHA §3.3.10 "Curva de la instalación" (Ec. 15, 18, 19);
Formulómetro "Bombas — Carga hidráulica" / "Curva de la Instalación".

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

---

## ESTADO: COMPLETO (compilado retroactivamente a partir de los 4 exámenes resueltos)
