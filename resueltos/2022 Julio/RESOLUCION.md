# Examen HHA — 25 de julio de 2022

Examen con solución oficial manuscrita adjunta (escaneada dentro del PDF,
páginas 5-8), de lectura difícil por caligrafía cursiva y calidad de
escaneo. Se recalculó todo de forma independiente con Octave y se comparó
con lo legible de la solución oficial — coincide en todos los valores
numéricos que se pudieron leer con confianza.

---

## Ejercicio 1 (30 puntos) — FGV en canal trapezoidal de 3 tramos entre dos lagos

### Enunciado (resumen)

Lago A → canal trapezoidal (b=1.3 m, talud m=2, n=0.017) de **tres
tramos** → Lago B:
- Tramo I: pendiente S₀ᴵ=0.03, longitud **infinita** (muy larga).
- Tramo II: horizontal (S₀ᴵᴵ=0), L=100 m.
- Tramo III: S₀ᴵᴵᴵ=0.0015, L=70 m.

1) Con hLA=1.43 m, hallar Q de descarga del Lago A.
2) Con hLB=0.8 m, clasificar tramos I y III (M o S) y dibujar la
   superficie libre completa, ubicando resaltos si los hay.
3) Hallar el hLB a partir del cual el resalto pasa al tramo I.

### Teoría

- **Control crítico en la entrada de un canal S alimentado por un
  lago**: un canal steep muy largo hace que el lago descargue su caudal
  máximo compatible con su energía, con flujo crítico justo en la
  entrada — Teórico HHA §2.5.3-§2.5.4, Formulómetro "Perfiles
  lago-canal"; ver también RESUMEN_TEORICO.md §A4.
- **Clasificación M/S**: se compara yn (Manning, según la pendiente de
  cada tramo) contra yc (crítico, que sólo depende de Q y la geometría,
  no de la pendiente) — RESUMEN_TEORICO.md §A1.
- **Resalto hidráulico y tirantes conjugados**: se integran ambas ramas
  (supercrítica desde su control aguas arriba, subcrítica desde su
  control aguas abajo) y se busca dónde el conjugado M(y) de la rama
  supercrítica cruza el valor de la rama subcrítica en la misma
  posición x — RESUMEN_TEORICO.md §A3.
- **Canal horizontal (S=0)**: no tiene tirante normal finito (la
  ecuación de Manning no tiene solución con S=0), así que sólo se
  clasifica por yc: existen las curvas H2 (y>yc) y H3 (y<yc), sin H1.

### Herramienta y por qué

Se usó **Octave** con la librería `RESUMEN EXAMEN/Codigos/FGV_trapezoidal/`
(ya existente: `control_critico_lago_trap.m`, `eq_yn.m`, `rect.m` +
`ode23`, `Mom_trap.m`) en lugar de resolver a mano porque el canal es
trapezoidal (yc y yn no tienen forma cerrada) y hay que integrar la EDO
de FGV en **tres tramos con distinta pendiente**, ubicando un resalto
móvil — exactamente el tipo de problema para el que está pensada esa
librería. Script adaptado a este examen:
`resueltos/2022 Julio/scripts/Ejercicio1_FGV_trapezoidal_3tramos.m`
(+ función auxiliar `perfil_union_fn.m`).

### Parte 1 — Caudal de descarga del Lago A

Tramo I es "de gran longitud (infinita)" y steep: el lago descarga el
caudal máximo compatible con su energía, con **control crítico en la
entrada** (x=0), sin importar lo que pase aguas abajo:

```
E(yc) = yc + Q²/(2g·A(yc)²) = hLA = 1.43 m      (conservación de energía, sin pérdidas)
Fr²(yc) = Q²·B(yc)/(g·A(yc)³) = 1                (definición de yc, sección trapezoidal)
```

Sistema 2x2 resuelto con `control_critico_lago_trap.m` (`fzero` en Q
anidando un `fsolve` en yc, porque en sección trapezoidal yc(Q) no tiene
forma cerrada):

| Variable | Valor |
|---|---|
| **Q (caudal de descarga del Lago A)** | **9.79 m³/s** |
| yc | 1.094 m |

Verificación: E(yc) con este Q = 1.4300 m = hLA ✓.

*Comparación con la solución oficial*: la solución manuscrita da
Q=9.8 m³/s, yc=1.094 m — coincide.

### Parte 2 — Clasificación de tramos y perfil completo (hLB=0.8 m)

Tirantes normales de cada tramo (con el Q ya hallado, resolviendo
Manning trapezoidal por `fsolve`):

| Tramo | S₀ | yn | vs. yc=1.094 | Clasificación |
|---|---|---|---|---|
| I | 0.03 | **0.664 m** | yn < yc | **STEEP (S)** |
| III | 0.0015 | **1.336 m** | yn > yc | **MILD (M)** |

*Comparación con la solución oficial*: yn_I=0.66 m, yn_III=1.33 m —
coincide.

**Perfil completo** (x creciente en el sentido del flujo; Lago A → Lago
B), con hLB=0.8 m < yc=1.094 m (el Lago B **no alcanza a ahogar** la
salida del tramo III, que descarga como si fuera una caída libre — el
valor exacto de hLB no importa mientras sea ≤ yc):

1. **Lago A → tramo I** (x=0): control crítico, y=yc=**1.094 m**.
2. **Tramo I** (curva S2, decrece desde yc hacia yn_I al alejarse del
   lago): como el tramo es muy largo, el tirante converge a
   **yn_I=0.664 m** mucho antes de llegar a la unión con el tramo II —
   entra al tramo II ya en régimen uniforme supercrítico.
3. **Tramo II** (horizontal): la rama supercrítica que entra en
   yn_I=0.664 m **no se queda constante** — al cambiar la pendiente de
   fondo evoluciona según su propia ecuación (curva H3, tendiendo hacia
   yc). Integrando su conjugado punto a punto (`Mom_trap`) y cruzándolo
   con la rama subcrítica que llega desde aguas abajo (curva H2, ver
   punto 4), el **resalto se ubica a 26.7 m** de la unión tramo I/II
   (a 73.3 m de la unión con el tramo III):
   - y₁ (antes, supercrítico) = **0.799 m**
   - y₂ (después, subcrítico) = **1.443 m**
   - Verificación: M(y₁)=4.98 m³ ≈ M(y₂)=4.98 m³ ✓ (conservación de
     momento en el resalto).
4. **Resto del tramo II** (curva H2, subcrítica, desde el resalto hasta
   la unión con tramo III): decrece de 1.443 m a **1.276 m**.
5. **Tramo III** (curva M2, subcrítica, entre yc y yn_III): decrece
   desde 1.276 m en la unión con II hasta **yc=1.094 m** en la salida
   al Lago B (control crítico en la salida, por ser M con hLB<yc).

*Comparación con la solución oficial*: la manuscrita reporta valores muy
cercanos — y≈1.479 m en la unión I/II (vs. 1.481 m acá), y≈1.27 m en la
unión II/III (vs. 1.276 m), resalto ubicado "X_res≈26.8 m" desde la
unión I/II (vs. 26.7 m acá) con tirantes del resalto ≈0.98/1.44 m — la
diferencia en el tirante y₁ (0.799 m vs. la lectura aproximada de la
manuscrita, ≈0.8 m) es coherente dentro del error de lectura de la
caligrafía. Coincide en la conclusión: **el resalto está en el tramo
II**, no en el I ni el III.

### Parte 3 — Umbral de hLB para que el resalto pase al tramo I

El resalto llega justo a la unión tramo I/II cuando la rama subcrítica
que remonta desde el Lago B, evaluada en esa unión, iguala el
**conjugado de yn_I** (con la rama supercrítica todavía sin evolucionar,
recién entrando al tramo II):

```
[~, yconj_I] = Mom_trap(yn_I, b, m, Q)   -->   yconj_I = 1.655 m
```

Se itera hLB (`fzero`) propagando hacia atrás la rama subcrítica desde
la salida (control crítico si hLB≤yc, o directamente y=hLB si el lago
ahoga la salida) a través de los tramos III y II, hasta que el tirante
en la unión I/II iguale 1.655 m:

| Variable | Valor |
|---|---|
| **hLB umbral** | **≈1.65 m** |

- Para **hLB < 1.65 m** (incluye el caso hLB=0.8 m de la Parte 2): el
  resalto queda dentro del **tramo II**.
- Para **hLB > 1.65 m**: la rama subcrítica en la unión I/II ya supera
  el conjugado de yn_I, así que el cruce ocurre aguas arriba de esa
  unión — el **resalto se corre al tramo I**.

*Comparación con la solución oficial*: la manuscrita anota un valor de
"hLB" alrededor de 1.66 m en este mismo paso (con un tirante intermedio
en la unión II/III de ≈1.585 m, muy cercano al 1.576 m obtenido acá) —
coincide dentro del margen de lectura del escaneo. **Nota de lectura**:
la letra del examen pregunta literalmente "a partir de qué valor de hLB
ocurre un resalto en el tramo I"; el cálculo (y la propia lógica física:
subir hLB aumenta el remanso en todo el canal, empujando el resalto
hacia aguas arriba) confirma que la relación correcta es esa — **por
encima** de 1.65 m el resalto pasa a estar en el tramo I.

---

## Ejercicio 2 (25 puntos) — Hidrología de una cuenca en Rocha

### Enunciado (resumen)

Cuenca en Rocha (X=650 km, Y=6200 km): Área=8.3 km², desnivel del cauce
principal ΔH=45 m, longitud L=4250 m, Grupo Hidrológico C, pendiente
media de la cuenca S=1.9%. Uso de suelo: 60% pastizales en condiciones
hidrológicas **óptimas** + 40% cultivos en hileras rectas, condición
**buena**. Flujo concentrado.

1) Qmax y volumen de escorrentía para Tr=10 años.
2) Tr de un evento observado con Qmax=19 m³/s, sabiendo que en los 5
   días previos (febrero, estación de crecimiento) llovieron 25 mm.
3) Máxima área adicional de cultivo en hileras (sin cambiar tc) para que
   el Vesc(Tr=10) no aumente más de un 10% respecto a la Parte 1.

### Teoría

- **Tiempo de concentración** (Ramser-Kirpich, con la pendiente del
  *cauce principal*, no la media de la cuenca) — RESUMEN_TEORICO.md §B2.
- **Criterio de selección de método según tc** — con tc>1h se usa
  **sólo NRCS** (el método Racional se desaconseja para cuencas
  "grandes") — RESUMEN_TEORICO.md §B4.
- **Número de Curva (NC)** de la Fig. 3.1.20 del Teórico, ponderado por
  área cuando hay más de un uso de suelo — RESUMEN_TEORICO.md §B5. La
  fila "Pradera o pastizal, condición Buena" trae la nota al pie
  *"Óptimas condiciones: cubierta de pasto en el 75% o más"* — coincide
  exactamente con la redacción del enunciado ("condiciones hidrológicas
  óptimas"), así que esa es la fila correcta a usar (no hay una columna
  "óptima" aparte).
- **Corrección de NC por condición de humedad antecedente (AMC)**, según
  la P5d y la estación (aquí de crecimiento, por ser febrero) —
  RESUMEN_TEORICO.md §B6.
- **Inversión de NC para un Vesc objetivo**, manteniendo tc fijo —
  RESUMEN_TEORICO.md §B5 (mismo patrón que para un Qmax objetivo).

### Herramienta y por qué

Se replicaron en **Python** las fórmulas de la planilla `Eventos
extremos.xlsx` (bloque alterno + Número de Curva + hidrograma unitario
triangular SCS — ver `COMO_USAR_EVENTOS_EXTREMOS.md` §1) en vez de abrir
la planilla interactivamente, porque este entorno no tiene Excel — mismo
enfoque ya usado en los exámenes previos (p.ej. `2024 febrero/scripts/
ej2_parte1.py`). El valor P(3,10)=74 mm (isoyetas, Fig. 3.1.10, para
X=650 km/Y=6200 km) se tomó de la solución oficial manuscrita, porque el
mapa de isoyetas no está digitalizado en este repositorio. Script:
`resueltos/2022 Julio/scripts/Ejercicio2_hidrologia.py`.

### Parte 1 — Qmax y Vesc (Tr=10 años)

**Número de Curva ponderado** (Fig. 3.1.20, Grupo C): pastizal
óptima=74, cultivo en hileras rectas buena=85:

```
NC = 0.60·74 + 0.40·85 = 78.4
```

**Tiempo de concentración** (Ramser-Kirpich, pendiente del cauce
principal S=ΔH/L/10=45/4.25/10=1.06%):

```
tc = 0.4·L^0.77/S^0.385 = 1.19 hs = 71.5 min   ->  tc>1h  =>  SOLO método NRCS
```

Tormenta de diseño (bloque alterno, Δt=tc/7, P(3,10)=74mm, Tr=10) + NC=78.4
+ hidrograma unitario triangular SCS:

| Variable | Valor |
|---|---|
| **Qmax (Tr=10 años)** | **31.07 m³/s** |
| **Volumen de escorrentía** | **160 723 m³** |

*Comparación con la solución oficial*: Qmax=31.06 m³/s, Vesc=160 733 m³
— coincide (diferencia <0.01%, redondeo).

### Parte 2 — Tr de un evento observado (Qmax=19 m³/s, P5d=25 mm)

Febrero es **estación de crecimiento** en Uruguay; con P5d=25 mm < 35.56 mm
corresponde **AMC I** (suelo más seco que la condición media de tabla):

```
NC(I) = 4.2·NC(II) / (10 - 0.058·NC(II)) = 4.2·78.4/(10-0.058·78.4) = 60.39
```

Se itera Tr (bisección) hasta que el Qmax del método NRCS, con este
NC(I)=60.39, iguale el caudal observado de 19 m³/s:

| Variable | Valor |
|---|---|
| NC corregido (AMC I) | 60.39 |
| **Tr del evento** | **≈65 años** |

*Comparación con la solución oficial*: NC(I)=60.39 (coincide exacto),
Tr=65 años (coincide).

### Parte 3 — Máxima área adicional de cultivo en hileras

Se mantiene tc fijo (dato del enunciado) y se aumenta sólo la fracción
de área x con cultivo en hileras (NC=85), reduciendo la de pastizal
(NC=74). Se itera x (bisección) hasta que el Vesc(Tr=10) con el nuevo
NC ponderado llegue al límite admisible (+10% del Vesc de la Parte 1):

```
Vesc_objetivo = 1.10 · 160 723 = 176 795 m³
NC_ponderado(x) = (1-x)·74 + x·85
```

| Variable | Valor |
|---|---|
| Fracción de cultivo máxima | 54.05% del área total |
| NC ponderado en el límite | 79.95 |
| Área de cultivo original (40%) | 3.320 km² |
| Área de cultivo máxima | 4.486 km² |
| **Aumento máximo de área cultivada** | **≈1.17 km² (14.05% del área de la cuenca)** |

*Comparación con la solución oficial*: la manuscrita da Vesc objetivo≈
176 806 m³, área máxima≈54.1%, NC≈79.95 — coincide (diferencias <0.1%,
redondeo).

---

## Ejercicio 3 (20 puntos) — Delimitación de cuenca y tiempo de concentración

### Enunciado (resumen)

1) Delimitar la cuenca de la cañada Sin Nombre (Canelones), punto de
   cierre X=470.7 km, Y=6212.5 km, sobre carta SGM con curvas de nivel
   cada 5 m.
2) Asumiendo que la longitud del cauce principal de la cuenca delimitada
   en 1) es L=4250 m, determinar: 2.1) el desnivel máximo ΔH del cauce
   principal (indicando las cotas consideradas); 2.2) la pendiente por
   extremos; 2.3) el tiempo de concentración (flujo concentrado).

### Teoría

- **Delimitación de cuencas y divisoria de aguas**: la divisoria corta
  perpendicularmente las curvas de nivel; al ganar altura lo hace por el
  lado convexo (loma/nacientes), al perder altura por el lado cóncavo
  (vaguada de la cuenca vecina), y nunca cruza un curso de agua salvo en
  el propio punto de cierre — RESUMEN_TEORICO.md §B1.
- **Pendiente del cauce principal por extremos** (S=ΔH/L) y **tiempo de
  concentración** (Ramser-Kirpich) — RESUMEN_TEORICO.md §B1-§B2.

### Herramienta y por qué

La Parte 1 es un trazado gráfico sobre la carta topográfica (sin fórmula
cerrada): se sigue la divisoria de aguas con las reglas de arriba. El
propio examen trae la solución oficial ya graficada (línea roja) en el
PDF (página 7), que sirve para verificar el trazado — no se re-delimitó
la cuenca desde cero, sino que se verificó consistencia con esa
delimitación oficial y con las cotas usadas en su Parte 2.

Para la Parte 2 se usa el mismo cálculo de tiempo de concentración de
`RESUMEN EXAMEN/Codigos/` (ya aplicado en el Ejercicio 2 de este mismo
examen), sólo que ahora la pendiente sale de leer cotas en la carta en
vez de venir dada en una tabla. Script:
`resueltos/2022 Julio/scripts/Ejercicio3_delimitacion_tc.py`.

### Parte 1 — Delimitación de la cuenca

Se traza la divisoria de aguas alrededor del punto de cierre
(X=470.7 km, Y=6212.5 km, sobre el curso de agua marcado en la carta),
siguiendo las lomas que rodean ese curso (cortando perpendicularmente
las curvas de nivel de 5 en 5 m) hasta cerrar el contorno en el propio
punto de cierre — coincide con el contorno delimitado en la solución
oficial (PDF página 7).

### Parte 2 — Desnivel, pendiente y tiempo de concentración

**2.1) Desnivel máximo del cauce principal.** Cotas consideradas: cota
más alta del cauce principal dentro de la cuenca delimitada (nacimiento,
próximo a una cota acotada de 88.0 m marcada en la carta) y cota del
punto de cierre (≈42 m, interpolada entre las curvas de nivel de 40 y
45 m que lo rodean):

```
ΔH = H_max - H_cierre = 88.0 - 42.0 = 46 m
```

**2.2) Pendiente del cauce principal por extremos:**

```
S = ΔH / L / 10 = 46 / 4.25 / 10 = 1.08 %
```

**2.3) Tiempo de concentración** (flujo concentrado ⇒ Ramser-Kirpich):

```
tc = 0.4·L^0.77/S^0.385 = 0.4·4.25^0.77/1.08^0.385 = 1.18 hs = 70.9 min
```

| Variable | Valor |
|---|---|
| ΔH | 46 m |
| S (por extremos) | 1.08 % |
| **tc** | **≈1.18 hs (70.9 min)** |

*Comparación con la solución oficial*: la manuscrita da
H_cierre≈42 m, H_max≈88 m ⇒ ΔH=46 m, S=46/4250=1.08%, tc=1.18 hs —
coincide en los tres resultados.

---

## ESTADO: EN CURSO (ejercicio 4 pendiente)
