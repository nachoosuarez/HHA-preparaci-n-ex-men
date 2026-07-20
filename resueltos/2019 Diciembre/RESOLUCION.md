# Examen HHA — 16 de diciembre de 2019

Fuente: `EXAMENES/2019 Diciembre.pdf` (9 páginas). Trae **solución oficial
manuscrita** completa (páginas 5 a 9), que se usa acá para comparar cada
resultado.

---

## Ejercicio 1 (25 puntos) — FGV en canal trapezoidal entre dos lagos

### Enunciado (resumen)

Canal trapezoidal de largo **L=370 m**, ancho de fondo **b=1.5 m**, talud
lateral **m=2** (1V:2H), pendiente de fondo **S₀=0.0003**, Manning
**n=0.011**. El Lago A, en la entrada del canal, tiene su superficie libre
a **hLA=1.24 m** sobre el fondo (dato fijo en las 3 partes).

a) Si el nivel del Lago B (salida) es **hLB=1.3 m**: caudal de descarga,
   clasificación M/S, perfil de superficie libre con tirantes y resaltos.
b) Si hLB puede variar: ¿existe un rango de hLB para el cual Q deja de
   depender de hLB? En caso afirmativo, hallar ese rango y el caudal.
c) En las condiciones de b), ubicar las zonas del canal con riesgo de
   erosión si la tensión rasante máxima admisible es **τ_max=4 Pa**.

### Teoría

- **A1 (clasificación M/S) y A2 (energía específica/tirante crítico)**
  (`RESUMEN_TEORICO.md` §A1-A2): yn (Manning) vs yc (Fr=1); yn>yc ⇒ M.
- **A4 (perfiles controlados por lagos), caso "transición lago-canal
  ASIMÉTRICA"**: la **entrada** (lago→canal) es una **contracción sin
  pérdidas**, conserva energía específica: `E(y en x=0) = hLA`. La
  **salida** (canal→lago) es una **expansión brusca**, que disipa toda
  la energía cinética: el nivel del lago iguala directamente el tirante,
  `y(x=L) = hLB` (sin sumar Q²/2gA²). Esta es la misma asimetría que en
  2022 dic Ej.1, aplicada acá a un canal **tipo M** (no S) y de longitud
  finita (no "muy largo", por lo que no alcanza con yn≈y(0): hay que
  integrar el perfil completo entre los dos extremos).
- **A2 (tirante crítico maximiza Q para E dada)**: si el nivel de salida
  baja lo suficiente, el control migra a la **propia salida** del canal
  (como una caída libre interna): `y(x=L) = yc(Q)`. Por debajo de ese
  umbral, cualquier hLB menor no cambia nada aguas arriba (la información
  no viaja contra una sección crítica), así que Q queda fijo en su
  máximo compatible con la energía del Lago A.
- **A6 (tensión rasante en FGV)**: τ₀(y)=γ·Rh(y)·Sf(y) es **decreciente**
  con y — a menor tirante, mayor Sf y mayor τ₀. Se evalúa sobre el
  perfil y(x) ya resuelto para hallar dónde τ₀ supera τ_max.

### Práctica

**Herramienta:** Octave, con un método de disparo ("shooting"): para
Q de prueba se calculan yn/yc (`tirantes_yn_yc.m`), se fija la condición
de borde de **salida** (y(L)=hLB en a, o y(L)=yc(Q) en b), se integra la
EDO de FGV (`rect.m`+`critico.m`, `ode45`) **hacia aguas arriba** hasta
x=0, y se itera Q (`fzero`) hasta que la energía específica resultante
en la entrada cierre con hLA=1.24 m. Se armó un script **canónico nuevo**
`dos_lagos_trap.m` (no existía en el repo un caso de "canal corto entre
dos lagos con ambos niveles conocidos, tipo M") en
`RESUMEN EXAMEN/Codigos/FGV_trapezoidal/`, con dos modos (`'hLB_dado'`
y `'critico_salida'`), reutilizado también para la parte c. Copia
adaptada al examen: `scripts/Ejercicio1_dos_lagos_trapezoidal.m`.

#### a) hLB = 1.30 m

Entradas: hLA=1.24, hLB=1.30, b=1.5, m=2, S0=0.0003, n=0.011, L=370.

Resultado del shooting (`dos_lagos_trap(hLA,1.30,...,'hLB_dado')`):

| Q (m³/s) | yn (m) | yc (m) | y(x=0), entrada (m) | y(x=L), salida (m) |
|---|---|---|---|---|
| 3.332 | 0.9327 | 0.6062 | 1.2152 | 1.3000 (=hLB) |

- yn=0.933 > yc=0.606 ⇒ **canal tipo M (mild)**.
- Fr(entrada)=0.257, Fr(salida)=0.224 ⇒ subcrítico en toda la longitud.
- Perfil: tirante crece monótonamente de 1.215 m (entrada) a 1.300 m
  (salida) ⇒ curva **M1** (remanso), **sin resalto** (todo subcrítico).

**Q = 3.33 m³/s, canal tipo M, curva M1 sin resaltos.**

Comparación con solución oficial (manuscrita, p.5): Q=3.3 m³/s (coincide),
yc≈0.60-0.66 (coincide con yc=0.606), y(entrada)≈1.21-1.24 m (coincide
con 1.215 m calculado). Diferencias de milésimas atribuibles a redondeo
manual en la iteración.

#### b) Rango de hLB con Q independiente de hLB

Se plantea el control crítico en la salida (`dos_lagos_trap(hLA,[],...,
'critico_salida')`, y(L)=yc(Q)):

| Qmax (m³/s) | yn (m) | yc (m) | y(x=0), entrada (m) | y(x=L)=yc, salida (m) |
|---|---|---|---|---|
| 6.204 | 1.2469 | 0.8403 | 1.1317 | 0.8408 |

- Para **hLB > 0.840 m**: la salida sigue controlada por el Lago B (igual
  mecanismo que en a), y Q depende de hLB (decrece al aumentar hLB: a
  mayor tirante en la salida, el perfil completo tiene tirantes más
  altos, la entrada necesita menos velocidad —menos Q— para llegar a
  hLA=1.24 m).
- Para **0 < hLB ≤ 0.840 m** (=yc del caudal máximo): la salida pasa a
  ser una sección **crítica** (como una caída libre "interna"); aguas
  abajo de ahí el flujo es supercrítico hasta el Lago B, que ya no
  puede influir en lo que pasa aguas arriba (la perturbación no viaja
  contra flujo supercrítico). El caudal queda fijo en su valor máximo.

**Rango: 0 < hLB ≤ 0.84 m ⇒ Q = 6.20 m³/s, constante (independiente de
hLB).** Canal sigue siendo tipo M (yn=1.247>yc=0.840); perfil subcrítico
en toda la longitud, tirante decreciendo de 1.132 m (entrada) a 0.840 m
(salida, =yc) ⇒ curva **M2** (aceleración hacia el control crítico de
salida), sin resalto.

Comparación con solución oficial (p.5): Qmax=6.2 m³/s (coincide), yc=0.84
(coincide exacto), y(entrada)=1.131 m (coincide con 1.132 m).

#### c) Zonas de erosión (τ_max = 4 Pa) sobre el perfil de b)

Se evalúa τ₀(y)=γ·Rh(y)·Sf(y) a lo largo del perfil M2 de la parte b)
(el más exigente, con los tirantes más bajos):

| Sección | y (m) | τ₀ (Pa) |
|---|---|---|
| Salida (Lago B), y=yc | 0.841 | 7.99 (**> 4 Pa, erosiona**) |
| Umbral τ₀=4 Pa | 1.032 | 4.00 |
| Entrada (Lago A) | 1.132 | 2.91 (< 4 Pa, seguro) |

τ₀ es decreciente con y (A6), así que el riesgo se concentra donde el
tirante es más bajo, es decir cerca de la salida. El cruce con τ_max=4 Pa
ocurre a x≈263 m (medido desde la entrada), es decir a **≈107 m de la
salida**.

**Riesgo de erosión en los últimos ≈107 m del canal, contados desde el
Lago B (salida), donde y < 1.03 m.** El resto del canal (los ≈263 m
desde el Lago A) tiene τ₀<4 Pa y no erosiona.

Comparación con solución oficial (p.5): "y=1.03 m en la zona n2 → L≈105 m
desde el final del canal, se deben proteger los últimos 105 m". Coincide
con el resultado calculado (≈107 m vs 105 m, diferencia atribuible a la
precisión de la lectura gráfica manuscrita).

---

**ESTADO: EN CURSO** (falta Ejercicio 2, 3 y 4)
