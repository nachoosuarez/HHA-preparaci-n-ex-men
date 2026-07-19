# Examen HHA — 22 de diciembre de 2020

Fuente: `EXAMENES/2020 Diciembre.pdf` (22 páginas). Este PDF trae **tres
variantes** del mismo examen (distinto Q, distinta proporción de suelos y
distinto kv de válvula por alumno), cada una con su solución oficial
manuscrita:

- **Variante A** (páginas 1-4 letra, 5-9 solución): Ejercicio 1 con
  Q=22 m³/s y a=0.85 m; Ejercicio 2 con Río Branco 85%/Andresito 15%;
  Ejercicio 3 con kv=20.
- **Variante B** (páginas 10-13 letra, 14-15 solución parcial):
  Q=20 m³/s y a=0.85 m; Río Branco 5%/Andresito 95%; kv=30.
- **Variante C** (páginas 16-19 letra, 20-22 solución): Q=18 m³/s y
  a=0.76 m; Río Branco 50%/Andresito 50%; kv=40.

Se resuelve acá la **Variante A** (la que trae la solución oficial más
completa y legible), comparando cada resultado contra esa manuscrita.

---

## Ejercicio 1 (35 puntos) — FGV en canal trapezoidal con compuerta de fondo

### Enunciado (resumen, Variante A)

Canal trapezoidal semi-infinito (ancho de fondo b=2.4 m, talud m=2H:1V,
pendiente S₀=0.0005, Manning n=0.016), Q=22 m³/s, que finaliza en una
**caída libre**.

1. Clasificar el canal en tipo M o S; dibujar la superficie libre sin
   compuerta, indicando tirantes y resaltos si los hubiere.
2. Con una **compuerta de fondo ideal** (abertura a=0.85 m) ubicada
   **500 m aguas arriba** de la caída libre: dibujar la superficie libre
   completa, tirantes y resaltos.
3. Calcular la fuerza sobre la compuerta y la potencia disipada en los
   resaltos.
4. Indicar el máximo valor de la abertura a para el cual la compuerta
   descarga libre.

### Teoría

- **Clasificación M/S** (RESUMEN_TEORICO.md §A1): se compara yn
  (Manning) con yc (crítico, independiente de la pendiente) — yn>yc ⇒
  canal tipo M (pendiente suave).
- **Caída libre** (§A4): control crítico y≈yc justo en el borde; canal M
  muy largo aguas arriba tiende asintóticamente a yn (curva M2).
- **Compuerta de fondo ideal** (§A5): se conserva la energía específica
  entre la sección inmediatamente aguas arriba (yA) y la vena contraída
  aguas abajo (yB=a) — yA es el **alterno** de a. El chequeo de descarga
  libre/ahogada compara el **conjugado** de a (a\*, por momentum) con el
  tirante que trae la curva de aguas abajo en esa sección (a\* > y(aguas
  abajo) ⇒ libre, con resalto más adelante).
- **Resalto hidráulico y fuerza sobre un obstáculo** (§A3): se ubica
  cruzando el conjugado de la rama supercrítica (M3, avanzando desde la
  compuerta) con la rama subcrítica impuesta desde aguas abajo (M2,
  retrocediendo desde la caída libre). La fuerza sobre la compuerta es
  F=γ(M1−M2) entre las dos secciones que la limitan (aguas arriba y vena
  contraída), y la potencia disipada en el resalto es Pdis=γQ(H1−H2)
  entre los tirantes conjugados del resalto (no los de la compuerta).

### Herramienta y por qué

Se usó **Octave** con el toolkit canónico
`RESUMEN EXAMEN/Codigos/FGV_trapezoidal/` (`trap_geom`, `froude_trap`,
`manning_trap` para yc/yn; `Eesp_trap` para el alterno de a; `Mom_trap`
para conjugados/momento; `rect.m`+`ode23`+`critico.m` para integrar las
curvas M3 y M2) porque la sección es trapezoidal (yc, yn y los
conjugados no tienen forma cerrada) y hay que ubicar un resalto móvil
entre dos ramas de FGV — exactamente el caso de uso de esta librería
(ver también `resueltos/2022 Julio/RESOLUCION.md` Ej.1 y
`resueltos/2024 marzo/RESOLUCION.md` Ej.1 para el mismo patrón en
trapezoidal/rectangular). Script adaptado a este examen:
`resueltos/2020 Diciembre/scripts/Ejercicio1_FGV_trapezoidal_compuerta.m`
(+ todo el toolkit `FGV_trapezoidal` copiado como dependencia, + función
auxiliar `conjugado_de_a.m`).

### Parte 1 — Clasificación del canal (sin compuerta)

```
yc (froude_trap, fsolve)  = 1.4085 m
yn (manning_trap, fsolve) = 2.1188 m
```

yn > yc ⇒ **canal tipo M** (pendiente suave). Con la caída libre como
único control (control crítico, y=yc en el borde) y canal semi-infinito
aguas arriba, la superficie libre sigue una **curva M2**: crece
suavemente desde yc=1.41 m en la caída libre hasta acercarse
asintóticamente a yn=2.12 m muy aguas arriba.

*Comparación con la solución oficial*: yc=1.41 m, yn=2.12 m — coincide
exactamente.

### Parte 2 — Perfil completo con compuerta (a=0.85 m, a 500 m de la caída libre)

**Tirante aguas arriba de la compuerta** (energía conservada, compuerta
ideal): yA = alterno de a = **2.836 m** (usando `Eesp_trap(a,b,Q,m)`).

**Chequeo libre/ahogada**: se integra la curva M2 hacia atrás desde la
caída libre (y=yc en x=500 m) hasta la compuerta (x=0), obteniendo el
tirante que traería esa rama en la compuerta **si no hubiera resalto
antes**: y_M2(x=0)=1.958 m. El conjugado de a (momentum, `Mom_trap`) es
a\*=2.136 m > 1.958 m ⇒ **descarga LIBRE** (el resalto se forma aguas
abajo de la compuerta, no queda ahogado contra ella).

**Ubicación del resalto**: se integra la curva M3 (supercrítica) hacia
adelante desde la compuerta (y=a=0.85 m en x=0) y se cruza su conjugado
punto a punto con la curva M2 (subcrítica) que retrocede desde la caída
libre:

```
RESALTO a x ≈ 30.1 m aguas abajo de la compuerta (≈470 m antes de la caída libre)
y1 (antes, supercrítico) = 0.966 m
y2 (después, subcrítico) = 1.949 m
Verificación: M(y1)=M(y2) por construcción (intersección de la curva conjugado(M3) con M2)
```

**Perfil completo**: y=2.836 m aguas arriba de la compuerta (remanso M1)
→ **compuerta** → y=0.85 m (vena contraída, curva M3 creciente) →
**resalto en x≈30 m** (0.966 m → 1.949 m) → curva M2 decreciendo
suavemente hasta **yc=1.409 m** en la caída libre (≈470 m después del
resalto).

*Comparación con la solución oficial*: el sketch manuscrito ubica el
resalto a "30.3 m" de la compuerta con tirantes ≈0.85/0.97 m antes y
≈1.95 m después, y el tirante aguas arriba de la compuerta lo anota como
"y=a\*=2.84 m" — coincide con x≈30.1 m, yA=2.836 m e y2≈1.949 m
calculados acá (la diferencia y1: 0.966 m vs. la lectura aproximada
"0.85 m" del sketch es coherente con el error de lectura de un dibujo a
mano; el valor numérico correcto, verificado por conservación de
momento, es 0.966 m).

### Parte 3 — Fuerza sobre la compuerta y potencia disipada

**Fuerza sobre la compuerta** (F=γ(M1−M2) entre la sección aguas arriba
y la vena contraída, con `Mom_trap`):

```
M(yA=2.836 m) = 27.02 m³
M(a=0.85 m)   = 15.43 m³
F = ρg(M1−M2) = 9810·(27.02−15.43) = 113.6 kN
```

**Potencia disipada en el resalto** (Pdis=γQ(H1−H2), entre los tirantes
conjugados DEL RESALTO — 0.966/1.949 m — no entre yA y a):

```
E(y1=0.966 m) = 2.377 m
E(y2=1.949 m) = 2.113 m
Pdis = ρgQ(E1−E2) = 9810·22·(2.377−2.113) = 57.05 kW
```

| Ítem | Resultado |
|---|---|
| Fuerza sobre la compuerta | **F ≈ 113.6 kN** |
| Potencia disipada en el resalto | **Pdis ≈ 57.05 kW** |

*Comparación con la solución oficial*: F=114.8 kN (con M1=27.1 m³,
M2=15.4 m³ — a menos de 1% del valor calculado acá) y Pdis=53.96 kW (con
H3=2.36 m, H4=2.11 m). La pequeña diferencia en Pdis (57.05 vs. 53.96
kW, ≈6%) es consistente con que la manuscrita redondeó los tirantes del
resalto (≈0.97/1.95 m) antes de calcular la energía, mientras que acá se
usan los valores sin redondear (0.966/1.949 m) hallados por
intersección numérica — igual orden de magnitud y mismo procedimiento.

### Parte 4 — Abertura máxima para descarga libre

El límite libre/ahogada ocurre cuando el conjugado de a iguala al
tirante que trae la curva M2 en la compuerta (y_M2(x=0)=1.958 m,
independiente de a porque esa curva la fija sólo la caída libre a
500 m). Se resuelve a\_max tal que conjugado(a\_max) = 1.958 m
(`fsolve` sobre `Mom_trap`):

```
a_max = 0.9595 m ≈ 0.96 m
```

Para a > 0.96 m la compuerta pasaría a descarga **ahogada** (resalto
sumergido contra la compuerta).

*Comparación con la solución oficial*: a\_max=0.906 m (anotado en la
solución oficial de la Variante B, con Q=20 m³/s en vez de 22 — no es
directamente comparable número a número; la Variante A no trae este
valor final en la manuscrita, aunque sí anota "0,96 m" en el dibujo del
punto 4). **Coincide** con a\_max≈0.96 m calculado acá.

### Resultado final (Variante A)

| Ítem | Resultado |
|---|---|
| yc / yn (sin compuerta) | **1.409 m / 2.119 m** — canal tipo **M** |
| Perfil sin compuerta | curva M2 desde yc en la caída libre hasta yn aguas arriba |
| yA (aguas arriba de la compuerta) | **2.836 m** |
| Tipo de descarga (a=0.85 m) | **LIBRE** |
| Resalto | **x≈30.1 m** de la compuerta (0.966 m → 1.949 m) |
| Fuerza sobre la compuerta | **≈113.6 kN** |
| Potencia disipada en el resalto | **≈57.05 kW** |
| a máxima para descarga libre | **≈0.96 m** |

---

## Ejercicio 2 (35 puntos) — Alcantarilla: NRCS, cambio de tc, evento observado

### Enunciado (resumen, Variante A)

Alcantarilla en Ruta, Departamento de Rocha (X=650 km, Y=6200 km). Cuenca:
Área=8.3 km², ΔH=130 m (cauce principal), L=9850 m, S media cuenca=1.9%.
Suelo: Río Branco 85% + Andresito 15% (Unidades Cartográficas), uso
pastizales condición hidrológica mala, flujo concentrado.

1. Qmax de diseño (Tr=10 años), hietograma/hidrograma de diseño, volumen
   de escorrentía.
2. Una obra de regularización del cauce aumenta el tc un 40%: hallar para
   qué Tr (precisión de 1 año) se supera el Qmax de diseño de la Parte 1;
   comparar ambos hidrogramas.
3. Con la cuenca ya regularizada, ocurre el evento extremo registrado de
   la tabla (12 bloques de 25 min): hidrograma del evento y tiempo que
   supera el Qmax de diseño.

### Teoría

- **Tiempo de concentración** (RESUMEN_TEORICO.md §B2, Ramser-Kirpich,
  flujo concentrado): tc=0.4·L(km)^0.77/S(%)^0.385, con S=ΔH/L del cauce
  principal (≠ pendiente media de la cuenca, que no se usa acá porque no
  hace falta el coeficiente C del método Racional).
- **Curvas IDF de Uruguay** (§B3): CD/CT/CA aplicadas sobre P(3,10) leído
  de isoyetas.
- **Criterio de selección de método según tc** (§B4): tc≈2.09 h > 1 hora
  ⇒ corresponde **sólo el método NRCS** (el Racional se descarta sin
  calcularlo, mismo criterio aplicado en 2025 feb 2).
- **Método NRCS: NC ponderado + tormenta de diseño por bloque alterno +
  hidrograma unitario triangular SCS** (§B5): acá el NC se pondera por
  **dos Unidades Cartográficas de suelo con distinto Grupo Hidrológico**
  (Río Branco=D, Andresito=B), no por distintos usos de suelo — mismo
  promedio ponderado por área (NC=Σ fracción·NC_i) documentado en §B5 y
  en `COMO_USAR_EVENTOS_EXTREMOS.md` §2.b (ampliada en esta corrida con
  esta variante del caso).
- **Inversión de Tr dado un caudal objetivo** (§B4 "Hallar el Tr de un
  caudal límite dado", extendido acá al método NRCS en vez del Racional):
  se itera/tantea Tr hasta que Qmax(Tr) iguale el caudal buscado (acá el
  caudal de diseño de la Parte 1, no un caudal límite estructural).
- **Hietograma observado vs. tormenta de diseño por bloque alterno**
  (§B5, ejemplo 2022 dic): con un evento ya registrado se aplica la misma
  cadena NC→Pe→convolución con el hidrograma unitario, pero usando el
  hietograma **en su orden cronológico real**, sin reordenar por bloque
  alterno.

### Herramienta y por qué

Se usó **Python** (numpy) replicando exactamente las fórmulas de la
planilla `Eventos extremos.xlsx` (documentadas en
`COMO_USAR_EVENTOS_EXTREMOS.md`) — el mismo enfoque ya usado y verificado
en los exámenes de hidrología anteriores (p.ej.
`resueltos/2026 Febrero/scripts/ej2_parte1.py`,
`resueltos/2024 diciembre/scripts/ej2_parte2.py`) — porque el ejercicio
necesita: (a) la tormenta de diseño de 12 bloques con reordenamiento por
bloque alterno y convolución con un hidrograma unitario triangular en una
malla temporal fina (impracticable a mano con precisión), (b) una
búsqueda iterativa de Tr (Parte 2) y (c) repetir toda la cadena con un
hietograma observado distinto (Parte 3) — tres corridas del mismo motor
de cálculo con parámetros distintos, ideal para automatizar y verificar
contra la solución oficial manuscrita. Scripts adaptados a este examen:
`resueltos/2020 Diciembre/scripts/ej2_parte1.py` (Parte 1, con la función
`hidrograma_NRCS()` reutilizada por los otros dos), `ej2_parte2.py`
(Parte 2) y `ej2_parte3.py` (Parte 3).

### Parte 1 — Caudal de diseño (Tr=10 años)

```
S cauce principal = ΔH/L = 130 m / 9.85 km / 10 = 1.32 %
tc (Ramser-Kirpich) = 0.4·9.85^0.77/1.32^0.385 = 2.092 hs = 125.5 min   (> 1 h => sólo NRCS)
NC = 0.85·89 (Río Branco, GH D) + 0.15·79 (Andresito, GH B) = 87.5
S(NC) = 25.4·(1000/87.5-10) = 36.29 mm ; Ia = 0.2S = 7.26 mm
```

Tormenta de diseño (bloque alterno, Δt=tc/7=0.299 hs=17.9 min, P(3,10)=74 mm):

| Bloque | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| N (mm) | 2.57 | 3.34 | 3.82 | 4.56 | 5.91 | 9.77 | **25.72** | 7.19 | 5.11 | 4.14 | 3.55 | 2.87 |
| Pe (mm) | 0 | 0 | 0.16 | 0.98 | 2.26 | 5.34 | **18.94** | 5.97 | 4.36 | 3.59 | 3.11 | 2.52 |

Hidrograma unitario SCS: Tp=1.405 hs, Tb=3.747 hs.

| Variable | Valor |
|---|---|
| **Qmax de diseño (Tr=10)** | **43.43 m³/s** (en t≈3.48 hs) |
| **Volumen de escorrentía** | Pe_total=47.21 mm × 8.3 km² = **391 874 m³** |

*Comparación con la solución oficial*: tc=2.09 hs, NC=87.5, bloque
central=25.7 mm, bloque 1=2.57 mm — coinciden exactamente. Qmax=43.52
m³/s y Vesc=3.9×10⁵ m³ oficiales — coinciden (43.43 vs 43.52 m³/s, <0.3%
de diferencia, atribuible a redondeo intermedio en la manuscrita).

### Parte 2 — Tr para el cual se supera el Qmax de diseño (tc aumentado 40%)

```
tc_new = 1.4 × 2.092 = 2.929 hs
```

Se tantea Qmax(Tr, tc_new) hasta igualar 43.43 m³/s:

| Tr (años) | Qmax NRCS (tc_new) |
|---|---|
| 15 | 41.53 |
| 17 | 42.82 |
| 18 | 43.40 |
| **≈18.05 (interpolado)** | **43.43** |
| 19 | 43.97 |
| 20 | 44.50 |

Con precisión de 1 año: en Tr=18 el caudal de diseño **todavía no** se
supera (43.40<43.43); recién en **Tr=19 años** queda superado
(43.97>43.43 m³/s).

**Comparación de hidrogramas**: el de la Parte 1 (tc=2.09 hs, Tr=10)
alcanza su pico en t≈3.48 hs con Tb≈3.75 hs; el de esta parte (tc=2.93
hs, Tr≈18) alcanza el mismo caudal pico (43.43 m³/s) pero en t≈4.86 hs
con Tb≈5.25 hs. Al aumentar tc el hidrograma se **ensancha** (Tp y Tb
mayores, la cuenca demora más en concentrar la escorrentía) y el pico
llega **más tarde**; para generar el mismo caudal de diseño con una
cuenca "más lenta" hace falta una tormenta más rara (Tr mayor).

*Comparación con la solución oficial*: tc_new=2.926 hs — coincide. La
manuscrita ubica el umbral en Tr≈18.5 años (con Qmax=43.73 m³/s en su
tabla, contra un Qmax de diseño oficial de 43.52 m³/s) — el valor acá
(≈18.05, redondeado a 19 con precisión de 1 año) es consistente, la
pequeña diferencia viene de la pequeña diferencia ya señalada en Qmax de
diseño de la Parte 1. Coincide en la discusión cualitativa: hidrograma
más ancho, mayor "retraso" de Qmax y Tr mayor necesario para igual Qmax.

### Parte 3 — Evento registrado (hietograma observado, 12 bloques de 25 min)

El ancho de bloque del evento observado (25 min) coincide con
Δt=tc_new/7=25.1 min — no es casualidad, así se arma la malla de la
tormenta de diseño; se aplica la misma cadena NC→Pe→convolución pero con
el hietograma en su **orden cronológico real** (sin reordenar):

```
Hietograma observado: 3, 4, 5, 7, 9, 15, 39, 11, 8, 6, 5, 4 mm  (total=116 mm)
Pe total (evento) = 81.08 mm
```

| Variable | Valor |
|---|---|
| **Qmax del evento registrado** | **53.82 m³/s** (en t≈4.50 hs) |
| **Tiempo que supera el Qmax de diseño (43.43 m³/s)** | entre t=4.01 hs y t=5.88 hs ⇒ **1.88 hs** (113 min) |

*Comparación con la solución oficial*: Qmax=53.9 m³/s y "supera 1.88 hs"
— coinciden prácticamente exactos.

### Resultado final

| Ítem | Resultado |
|---|---|
| tc (Parte 1) | **2.09 hs** — sólo método NRCS |
| NC ponderado | **87.5** |
| Qmax de diseño (Tr=10) | **43.43 m³/s** |
| Volumen de escorrentía (evento de diseño) | **391 874 m³** |
| tc_new (obra de regularización, +40%) | **2.93 hs** |
| Tr para superar el Qmax de diseño (precisión 1 año) | **19 años** (umbral exacto interpolado ≈18.05) |
| Qmax del evento registrado (con tc_new) | **53.82 m³/s** |
| Tiempo que supera el Qmax de diseño | **1.88 hs** |

---

## ESTADO: EN CURSO (falta Ejercicio 3 — bombeo)
