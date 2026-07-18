# Examen HHA — 24 de febrero de 2023 (2023 febrero_2 / 2023 feb 2)

Resolución paso a paso. El PDF del examen (`EXAMENES/2023 febrero_2.pdf`,
10 páginas) incluye la letra completa (páginas 1-3: Ejercicios 1-4), la
carta topográfica del Ejercicio 2 (página 4) y la solución oficial
manuscrita completa (páginas 5-10, con la cuenca ya delimitada en la
página 7), que se usa para comparar cada resultado.

No confundir con "2023 Febrero" (`EXAMENES/2023 Febrero.pdf`, 9/feb/2023),
la primera llamada de febrero de 2023, un examen distinto aún sin resolver
en este repo.

Herramientas: Octave (funciones canónicas de
`RESUMEN EXAMEN/Codigos/FGV_rectangular/`, copiadas sin modificar a
`scripts/` de este examen) para el Ejercicio 1.

---

## EJERCICIO 1 — Canal rectangular con compuerta de fondo, descarga a un lago cercano (25 puntos)

**Datos:** sección rectangular b=5 m, S₀=0.001, n=0.017 (Manning). El
canal desemboca en un lago cuyo nivel está a hL=0.8 m sobre el fondo del
canal. A Lgc=60 m antes del lago hay una compuerta de fondo ideal.

Teoría usada: ecuación de FGV y clasificación M/S (Resumen Teórico §A1),
energía específica y tirante alterno (§A2), cantidad de movimiento,
tirante conjugado, resalto hidráulico y fuerza sobre un obstáculo de fondo
(§A3), control por un lago a distancia finita (§A4/§A5, nuance agregada
en esta resolución) y compuerta de fondo ideal con chequeo libre/ahogada
(§A5).

### Parte 1) Apertura a=0.50 m descarga libre, v=4 m/s en la compuerta: Q, clasificación M/S y perfil completo

**Concepto.** El caudal se obtiene de la velocidad y el área mojada bajo
la compuerta (dato: descarga libre con v=4 m/s en a=0.50 m). Con Q se
calculan yc (crítico) e yn (normal, Manning) y se clasifica el canal.
Aguas arriba de la compuerta el tirante es el **alterno** de a (misma
energía específica, sin pérdidas). Aguas abajo de la compuerta arranca
una curva **M3** (supercrítica, creciente hacia yc). El lago, a 60 m,
tiene hL=0.8 m > yc: es subcrítico, así que allí también rige una curva
**M2**. Como el lago está a distancia **finita** (no "muy lejos" ni yn),
el tirante de referencia para ubicar el resalto no es yn: hay que integrar
la curva M2 **hacia atrás** desde el lago (control conocido) hasta la
compuerta, y por separado integrar la curva M3 **hacia adelante** desde la
compuerta; el resalto está donde el conjugado de M3 cruza el valor de M2
en el mismo x (mismo criterio de A3, aplicado con dos ramas que dependen
de x en vez de una referencia constante).

**Herramienta:** `froude_rect.m`/`manning_rect.m` (yc, yn), `Eesp_rect.m`
(alterno de a), `rect.m` integrado con `ode23` en ambos sentidos (M2 desde
el lago hacia la compuerta, M3 desde la compuerta hacia el lago) y
`Mom_rect.m` (conjugado de la rama M3) para hallar el resalto por
intersección.

**Script:** `scripts/ej1.m` (sección "PARTE 1"). Entradas: `b=5, S0=0.001,
n=0.017, hL=0.8, Lgc=60, a1=0.50, v1=4`.

**Resultado:**
```
Q = v*(b*a) = 10.0000 m3/s
yc = 0.7418 m ; yn = 1.2251 m  =>  yn > yc  =>  CANAL TIPO M
y aguas arriba de la compuerta (alterno de a=0.50) = 1.1663 m  (< yn => curva M2)
y = a = 0.50 m < yc  =>  aguas abajo arranca la curva M3
hL = 0.80 m > yc  =>  en el lago el flujo es subcritico (curva M2)

RESALTO a x = 7.2 m aguas abajo de la compuerta: y = 0.5462 m -> y = 0.9795 m
y(M2) justo en la compuerta (x=0) = 0.9907 m
```

**Perfil de la superficie libre** (x medido desde la compuerta, 0 a 60 m
hasta el lago):
- x=0⁻ (aguas arriba de la compuerta): y=1.1663 m (curva M2, aproximándose
  a yn=1.2251 m lejos de la compuerta).
- x=0⁺ (aguas abajo de la compuerta): y=a=0.50 m (arranque de la curva M3).
- x=7.2 m: **resalto hidráulico** (y sube de 0.5462 m a 0.9795 m).
- x=7.2 a 60 m: curva M2, tirante decreciendo suavemente de 0.98 m a
  hL=0.80 m en el lago.

**Resultado final Parte 1: Q = 10 m³/s, canal tipo M (yn=1.23 m > yc=0.74
m), descarga libre por la compuerta, con un resalto hidráulico a ≈7 m
aguas abajo de la compuerta que conecta la curva M3 con la M2 controlada
por el lago.**

**Comparación con solución oficial:** el manuscrito da Q=10 m³/s, yc=0.74
m, yn=1.22 m (coincide). Tirante aguas arriba de la compuerta y1=1.16 m
(coincide con 1.1663 m). Resalto ubicado en x≈8 m aguas abajo de la
compuerta con y≈0.55 m → y≈0.97-0.98 m (coincide con x=7.2 m, y: 0.5462
→ 0.9795 m — la pequeña diferencia en x es por precisión de lectura de
los valores intermedios manuscritos). y(M2) en la compuerta ≈0.99 m,
usado en la Parte 2 — **coincide exactamente**.

### Parte 2) Apertura a=0.65 m, mismo Q: ¿descarga libre o ahogada?

**Concepto.** Se compara el conjugado de la nueva apertura a* contra el
tirante que trae la curva M2 (desde el lago) evaluada en la sección de la
compuerta — **no yn**, porque el lago está a distancia finita (Parte 1).
Si a* > y(M2 en la compuerta) la descarga es libre; si a* < y(M2 en la
compuerta), es **ahogada** (flujo dividido inmediatamente aguas abajo de
la compuerta).

**Herramienta:** `Mom_rect.m` (conjugado de a=0.65 m) comparado contra
`y(M2, x=0)=0.9907 m` ya calculado en la Parte 1; si es ahogada, momentum
entre la vena contraída (2) y la sección aguas abajo controlada por el
lago (3, y3=y(M2,x=0)) para hallar y2, y energía entre (1) y (2) para
hallar y1 (fórmulas de §A5, "Compuerta con descarga AHOGADA").

**Script:** `scripts/ej1.m` (sección "PARTE 2").

**Resultado:**
```
a = 0.65 m ; a* (conjugado) = 0.8418 m
y(M2 en la compuerta, de la Parte 1) = 0.9907 m
a* = 0.8418 m < 0.9907 m  =>  DESCARGA AHOGADA (flujo dividido)

y3 = y(M2 en la compuerta) = 0.9907 m
y2 (vena contraida, aguas abajo de la compuerta) = 0.7413 m
E2 = 1.2244 m
y1 (aguas arriba de la compuerta) = 1.0332 m
```

**Resultado final Parte 2: la compuerta con a=0.65 m descarga AHOGADA
(a*=0.84 m < 0.99 m); y1≈1.03 m aguas arriba, y2≈0.74 m en la vena
contraída.**

**Comparación con solución oficial:** el manuscrito obtiene a*=0.8418 m
(coincide exactamente), y(aguas abajo de la compuerta, llamado yn2 en el
manuscrito)=0.99 m (coincide con 0.9907 m), a*<0.99 ⇒ ahogada (coincide),
y2=0.7414 m (coincide con 0.7413 m), E2=1.2244 m (coincide exactamente),
y1=1.03 m (coincide con 1.0332 m, diferencia de redondeo).

### Parte 3) Fuerza sobre la compuerta, en las condiciones de la Parte 2

**Concepto.** F=γ·(M1−M2) entre la sección (1) aguas arriba de la
compuerta (sección completa, área b·y1) y la sección (2) en la vena
contraída. **Trampa:** en (2) el flujo está dividido — la presión es
hidrostática hasta la superficie libre y2 (área completa b·y2) pero la
velocidad real corresponde al área contraída b·a: el M2 a usar es el
momento **híbrido** yG(y2)·A(y2) + Q²/(g·A(a)), que coincide (por
construcción, ver Parte 2) con M(y3). Usar `Mom_rect(y2,...)` con área
completa en el término de velocidad da un resultado incorrecto.

**Herramienta:** `Mom_rect.m` para M(y1) con sección completa; fórmula
híbrida manual para M2 (ya computada al resolver y2 en la Parte 2).

**Script:** `scripts/ej1.m` (sección "PARTE 3").

**Resultado:**
```
M(y1=1.0332 m, seccion completa) = 4.6440 m3
M2 hibrido (y2=0.7413 m, presion seccion completa + velocidad area a=0.65m) = 4.5137 m3
F = gamma*(M1 - M2_hib) = 1277.0 N   (gamma = 1000*9.8 N/m3)
```

**Resultado final Parte 3: F ≈ 1277 N (agua sobre la compuerta, sentido
del flujo).**

**Comparación con solución oficial:** el manuscrito da M(y1=1.03
m)=4.6336 m³, M2 híbrido=4.514 m³ (coincide con nuestro 4.5137), F=γ·[4.6336
− 4.514]=1172 N. La metodología es idéntica; la diferencia final (1172 N
vs. 1277 N) se debe a que F es una **resta de dos números muy cercanos**
(4.63 vs. 4.51): redondear y1 a 1.03 m (en vez de 1.0332 m, el valor
exacto de la Parte 2) desplaza M(y1) lo suficiente como para cambiar la
resta casi un 10%. Con más decimales en y1 el resultado correcto es
F≈1277 N (ver nota agregada en Resumen Teórico §A5).

---

## EJERCICIO 2 — Cuenca en Canelones: delimitación, Tr de un evento e infiltración de Horton (25 puntos)

**Datos:** cuenca de la cañada "Sin Nombre" en Canelones, punto de cierre
en la carta topográfica (SGM, curvas de nivel cada 5 m) en X=460 km,
Y=6195 km (página 4 del PDF del examen). Hietograma de precipitación
observado en un pluviógrafo (tabla de 10 intervalos, de 0 a 2.9 h).

Teoría usada: delimitación de cuencas y divisoria de aguas (Resumen
Teórico §B1), curvas IDF de Uruguay e inversión de CT(Tr) para un evento
observado (§B3) e infiltración de Horton (§B8).

### Parte 1) Delimitar la cuenca

**Concepto.** La divisoria de aguas se traza sobre la carta topográfica
siguiendo la línea que corta perpendicularmente las curvas de nivel: por
las lomas/crestas (lado convexo de la curva, ganando altura hacia las
nacientes) y por las vaguadas de las cuencas vecinas (lado cóncavo,
perdiendo altura), sin cruzar nunca un curso de agua salvo en el punto de
cierre (X=460, Y=6195).

**Herramienta:** lectura directa de la carta topográfica adjunta al
examen (`EXAMENES/2023 febrero_2.pdf`, página 4) — es un trazado gráfico,
sin fórmula ni script de cálculo.

**Resultado:** no reproducible en texto (requiere trazar sobre el mapa).
La solución oficial manuscrita (página 7 del PDF) muestra la cuenca ya
delimitada sobre la misma carta: la divisoria sale del punto de cierre,
sube por las lomas a ambos lados del curso principal siguiendo las curvas
de nivel de forma perpendicular, y cierra el contorno aguas arriba,
delimitando el área que efectivamente drena hacia (X=460, Y=6195). Para
repasar el procedimiento gráfico paso a paso ver Resumen Teórico §B1.

### Parte 2.1) Período de retorno de la intensidad máxima registrada

**Concepto.** El bloque de mayor intensidad del hietograma es el
intervalo 0.5-0.8 h, con I=98 mm/h (duración d=0.3 h). Es un dato **ya
registrado** en un punto (el pluviógrafo), no una tormenta de diseño
sobre un área ⇒ se usa CA=1 (sin corrección por área) y se **invierte
numéricamente** la relación IDF de Uruguay para hallar el CT(Tr) que
reproduce ese evento, y de ahí el Tr (mismo procedimiento que 2023 jul,
Ej.2 parte 3, ya resuelto en este repositorio).

**Herramienta:** script Python con bisección (`brentq` casero, sin
depender de la planilla de Eventos Extremos — el `CT(Tr)` no tiene forma
cerrada) — igual que `resueltos/2023 Julio/scripts/Ejercicio2_parte3_Tr_pluviografo.py`,
adaptado a estos datos.

**Script:** `scripts/ej2.py` (sección "2.1"). Entradas: `P310=81 mm`
(leído del mapa de isoyetas para Canelones, dato de la solución oficial),
`Imax=98 mm/h`, `d=0.3 h`, `CA=1`.

**Resultado:**
```
CD(d=0.3h) = 0.3581
CT objetivo = Imax*d/(P310*CD*CA) = 1.0136
Tr (inversion numerica de CT(Tr)) = 10.71 anios  ->  se adopta el Tr TABULADO mas cercano: 10 anios
```

**Resultado final Parte 2.1: Tr ≈ 10 años** (CT objetivo ≈ 1.01, muy
cercano a CT(10)=1 por definición de la curva IDF de Uruguay).

**Comparación con solución oficial:** el manuscrito usa CD(d)≈0.36
(redondeado) y obtiene CT=0.3×98/(81×0.36)=1.0082 ⇒ Tr≈10 años, acotado
"9≤Tr≤10 años". Con CD sin redondear (0.3581) el CT objetivo resulta
1.0136 y el Tr exacto (inversión de CT(Tr), sin restringir a valores
tabulados) da 10.71 años — la conclusión práctica es la misma (**Tr=10
años**, el valor tabulado estándar más cercano): la inversión de CT(Tr)
es muy sensible cerca de CT≈1 (ver Resumen Teórico §B3), por lo que
pequeñas diferencias de redondeo en CD desplazan el Tr "exacto" varias
décimas de año sin cambiar la conclusión de qué Tr tabulado adoptar.

### Parte 2.2) Tiempo de encharcamiento (modelo de Horton)

**Concepto.** Con f₀=112 mm/h, fc=0.18 mm/h y K=2.5 1/h, la capacidad de
infiltración decae según f(t)=fc+(f₀-fc)·e^(-Kt). El tiempo de
encharcamiento es el instante en que la intensidad del hietograma supera
esa capacidad: se evalúa f(t) al inicio de cada bloque y se compara con
la intensidad de ese bloque.

**Herramienta:** fórmula de Horton evaluada bloque a bloque (Resumen
Teórico §B8) — no requiere la planilla de Eventos Extremos (la hoja
`Horton` de esa planilla está vacía, ver `COMO_USAR_EVENTOS_EXTREMOS.md`
§0).

**Script:** `scripts/ej2.py` (sección "2.2").

**Resultado:**
```
f(t) = 0.18 + 111.82*exp(-2.5*t)
t=0.0h: I=15 mm/h  vs f=112.00 mm/h  -> no encharca
t=0.2h: I=68 mm/h  vs f= 68.02 mm/h  -> encharca (practicamente igual)
t=0.5h: I=98 mm/h  vs f= 32.22 mm/h  -> encharca
...(I>f en todos los bloques siguientes)

Tiempo de encharcamiento = 0.20 hs
```

**Resultado final Parte 2.2: tiempo de encharcamiento ≈ 0.20 h** (12
minutos) — justo cuando arranca el bloque más intenso del hietograma
(0.2-0.5 h, I=68 mm/h), cuya intensidad iguala la capacidad de
infiltración remanente en ese instante.

**Comparación con solución oficial:** coincide exactamente (t_enc=0.2 h,
f(0.2)≈68 mm/h ≈ I=68 mm/h).

---

## EJERCICIO 3 — Cuenca en Cerro Largo: caudal de diseño, volumen de escorrentía y área urbanizable máxima (25 puntos)

**Datos:** cuenca con punto de cierre en Cerro Largo (X=650 km, Y=6400
km), Área=5.10 km², ΔH=120 m, L=3600 m (cauce principal), S=3.8%
(pendiente **media de la cuenca**, dato directo del enunciado). Uso de
suelo pastizales naturales en condición hidrológica **mala**, unidad de
suelos **Risso**, flujo concentrado.

Teoría usada: tiempo de concentración de Ramser-Kirpich (Resumen Teórico
§B2), curvas IDF de Uruguay (§B3), método Racional (§B4), método NRCS
—Número de Curva + hidrograma unitario triangular SCS— (§B5), volumen de
escorrentía (§B7).

**Grupo Hidrológico e insumos de tabla:** la unidad de suelos **Risso**
corresponde a Grupo Hidrológico **D** (verificado extrayendo el texto de
`Teórico HHA.pdf` con `pdftotext`: tabla "Unidad de suelo — Grupo
hidrológico", fila "Risso ... D"). Con pastizales/condición mala/Grupo D,
la Fig. 3.1.20 del Teórico da **NC=89** (coincide con la solución
oficial). El coeficiente de escorrentía del método Racional, para
pastizales en condición mala y S=3.8%, es **C=0.36** (Tabla 3.1.4, dato de
la solución oficial).

### Parte a) Caudal máximo de diseño (Tr=5 años)

**Concepto.** Se calcula tc por Ramser-Kirpich con la pendiente del
**cauce principal** (ΔH/L/10=3.33%, distinta de la pendiente media de la
cuenca S=3.8% dada, que solo se usa para elegir C). Con 20 min<tc<1 h
corresponde calcular **ambos métodos** (Racional y NRCS) y adoptar el
caudal mayor.

**Herramienta:** réplica en Python de las fórmulas de
`EVENTOS EXTREMOS 2025.xlsx` (hoja "Cálculos (grande)": IDF Uruguay,
método Racional, tormenta de diseño por bloque alterno, NC, hidrograma
unitario triangular SCS) — mismo patrón que
`resueltos/2024 diciembre/scripts/ej2_parte1.py`, adaptado a estos datos.
Se elige replicar en Python (en vez de abrir la planilla real) porque
además se necesita, en la Parte c), **iterar sobre el NC** dentro del
mismo cálculo del hidrograma — más simple de automatizar en código que
editando celdas de Excel a mano repetidamente.

**Script:** `scripts/ej3.py`. Entradas: `Area=5.10, dH=120, L=3600,
Tr=5, P310=80, NC=89, C_racional=0.36`.

**Resultado:**
```
S cauce principal (Kirpich) = 3.3333 %
tc = 0.6747 hs = 40.48 min   =>  20 min < tc < 1 h  =>  AMBOS metodos

--- METODO RACIONAL ---
d=tc=0.6747 hs, CD=0.5170, CA=0.9878
Qmax racional = 26.54 m3/s

--- METODO NRCS ---
S=31.393 mm ; SUMA Pe = 21.178 mm
Qmax NRCS = 36.93 m3/s en t_pico=1.13 hs, t_base~2.34 hs

=> Qmax de diseno (Tr=5) = 36.93 m3/s (NRCS, MAYOR que el Racional)
```

**Resultado final Parte a): Qmax = 36.93 m³/s** (método NRCS, con tiempo
pico ≈1.13 h y tiempo base ≈2.34 h del hidrograma de crecida triangular).

**Comparación con solución oficial:** el manuscrito da tc=0.6738 h (40.43
min) — coincide (diferencia de redondeo en la pendiente del cauce).
Qmax Racional=26.56 m³/s (coincide con 26.54). Qmax NRCS=36.75 m³/s
(coincide con 36.93, diferencia <0.5%, por redondeos intermedios en la
tormenta de diseño). Tiempo pico=1.16 h, tiempo base=2.31 h (coinciden
con 1.13 h / 2.34 h). Se adopta NRCS por ser el mayor — **coincide**.

### Parte b) Volumen de escorrentía

**Concepto.** Vesc=ΣPe(mm)·Área(km²)·1000, con la ΣPe ya calculada para
la tormenta de diseño de la Parte a) (Tr=5, NC=89).

**Script:** `scripts/ej3.py` (parte b, reutiliza `Pe_corr_a` de la parte
a).

**Resultado:**
```
Vesc = 5.10 * 1000 * 21.178 = 108010 m3
```

**Resultado final Parte b): Vesc ≈ 108 010 m³** (≈108 000 m³).

**Comparación con solución oficial:** el manuscrito da ΣPe=21.2 mm (redondeado,
coincide con 21.178) y Vesc=108 120 m³ — **coincide** (diferencia de
redondeo de 0.1% por el ΣPe con más decimales).

### Parte c) Área máxima transformable a urbana (lotes de 0.03 ha) sin superar +15% del Qmax de diseño

**Concepto.** Los nuevos lotes urbanos (0.03 ha < 0.05 ha) caen en la
categoría "Residencial, <0.05 Ha, 65% impermeable" de la Fig. 3.1.20, que
para Grupo Hidrológico D da **NC=92**. El enunciado aclara que la
urbanización **no cambia tc** (a diferencia del caso más general de §B5,
donde también se canaliza el cauce): el único efecto es que el NC
ponderado de la cuenca (mezcla pastizal/urbano) sube, lo que aumenta Pe y
por lo tanto Qmax. Se itera el NC ponderado (con tc fijo en 0.6747 h)
hasta que el hidrograma NRCS dé exactamente 1.15×Qmax(a), y de ahí se
despeja la fracción de área urbanizada x.

**Herramienta:** bisección en NC ponderado sobre la misma función
`NRCS_hidrograma` de la Parte a) (no tiene forma cerrada NC→Qmax).

**Script:** `scripts/ej3.py` (parte c).

**Resultado:**
```
Qmax objetivo = 1.15*36.93 = 42.47 m3/s
NC ponderado necesario = 91.033
NC* = x*92(urbano) + (1-x)*89(pastizal) = 91.033  =>  x = 0.6778
Area urbanizable maxima = x*Area = 0.6778*5.10 = 3.457 km2
```

**Resultado final Parte c): Área urbanizable máxima ≈ 3.46 km²** (≈68% de
la cuenca).

**Comparación con solución oficial:** el manuscrito da NC*=91.03
(coincide exactamente), x=0.6766 (coincide con 0.6778) y área máxima
"hasta 3.45 km²" (coincide con 3.457 km²) — **coincide**.

---

## EJERCICIO 4 — Instalación de bombeo que recircula agua en un tanque abierto (25 puntos)

**Datos:** succión desde el nivel del tanque z1=1.5 m (L1=3 m, D1=25 mm,
ε1=0.007 mm, k1=0.8); impulsión que descarga **libremente** (no
recuperable la energía cinética) a z2=3 m (L2=35 m, D2=32 mm, ε2=0.007
mm, k2=1.5 sin la válvula), con una **válvula de globo** (coeficiente kv)
en la impulsión. Manómetros pA (succión) y pB (impulsión) a cota zA=0.3
m, justo antes/después de la bomba. Curva de catálogo de la bomba dada
en tabla (Q, H, η, NPSHreq).

Teoría usada: ecuación de la instalación de bombeo (Resumen Teórico §C1,
caso particular "manómetros en las bridas de la bomba"), curva de la
bomba y punto de funcionamiento (§C2), potencia consumida (§C3) y
cavitación NPSH disponible/requerido (§C4).

### Parte 1) Q=1 l/s: hallar kv y las presiones pA, pB

**Concepto.** Con Q dado, se calculan directamente v1, v2, Re1, Re2 y los
factores de fricción f1, f2 (Colebrook-White). La ecuación de la
instalación (balance de energía en todo el lazo, de la superficie libre
del tanque de vuelta a la descarga, pasando por la bomba) es
Hb=(H2−H1)+ΔH_succ+ΔH_imp(kv), con H1=z1 (superficie libre) y
H2=z2+v2²/2g (descarga libre, no se recupera la cinética). Con Hb leído
de la tabla de catálogo en Q=1 l/s (exactamente Hb=8.5 m, sin
interpolar) se despeja kv de ΔH_imp. Luego H_A=H1−ΔH_succ y H_B=H_A+Hb
dan las presiones manométricas en las bridas (H=zA+p/γ+v²/2g).

**Herramienta:** `colebrook.m` (factor de fricción) + álgebra directa —
no requiere iterar, es un problema "directo" (Q dado, se despeja kv).

**Script:** `scripts/ej4.m` (sección "PARTE 1"). Entradas: geometría de
la figura, `Q=1 l/s`, `Hb(Q=1l/s)=8.5 m` (tabla).

**Resultado:**
```
v1=2.037 m/s ; Re1=5.09e4 ; eps/D1=2.80e-4 ; f1=0.0218
v2=1.243 m/s ; Re2=3.98e4 ; eps/D2=2.19e-4 ; f2=0.0227
H1=1.500 m ; H2=3.079 m ; dHsucc=0.723 m ; Hb=8.500 m

kv = 52.28

H_A = 0.777 m ; H_B = 9.277 m
p_A = 2600 Pa (2.60 kPa) ; p_B = 87203 Pa (87.20 kPa)
```

**Resultado final Parte 1: kv ≈ 52.3, p_A ≈ 2.60 kPa, p_B ≈ 87.2 kPa.**

**Comparación con solución oficial:** el manuscrito da f1=0.0218,
f2=0.0227, H2=3.08 m, kv≈52, H_A=0.777 m, H_B=9.277 m, p_A=2.6 kPa,
p_B=87.2 kPa — **coincide en todos los valores**.

### Parte 2) Válvula totalmente abierta (kv=5): punto de funcionamiento

**Concepto.** Con kv=5 fijo, se recalcula Hm(Q) de la instalación para
un barrido de Q (iterando f1(Q), f2(Q) con Colebrook) y se busca la
intersección con la curva de catálogo de la bomba (interpolación
`pchip`) — el punto de funcionamiento (C2).

**Herramienta:** `colebrook.m` + barrido numérico e intersección de
curvas (mismo patrón que `Bomba_sola.m`/`Bomba_manometros.m` de
`RESUMEN EXAMEN/Codigos/Bombas/`, adaptado a la descarga libre y a la
válvula en la impulsión).

**Script:** `scripts/ej4.m` (sección "PARTE 2"). Gráfico:
`scripts/ej4_parte2.png`.

**Resultado:**
```
Qpf = 1.455 l/s ; Hpf = 8.049 m
v1=2.964 m/s, f1=0.0204 (succion)
v2=1.809 m/s, f2=0.0211 (impulsion)
eta(Qpf) = 89.0 %
```

**Resultado final Parte 2: Qpf ≈ 1.46 l/s, Hpf ≈ 8.05 m.**

**Comparación con solución oficial:** el manuscrito da Qpf=1.46 l/s,
Hpf=8.09 m, v1=2.96 m/s (f1=0.0204), v2=1.81 m/s (f2=0.0211) —
**coincide** (v1, f1, v2, f2 exactos; Qpf/Hpf con diferencia de
redondeo <1%, típica de la resolución gráfica manual vs. la numérica).

### Parte 3) Cavitación (NPSH disponible vs. requerido)

**Concepto.** NPSH_disp depende sólo del tramo de succión: se calcula
H_A en el punto de funcionamiento de la Parte 2 (misma fórmula que la
Parte 1, con el nuevo Q) y NPSH_disp=(H_A−zA)+patm/γ−pvap/γ. NPSH_req se
interpola de la tabla de catálogo en Qpf.

**Herramienta:** álgebra directa + interpolación `pchip` de NPSHreq.

**Script:** `scripts/ej4.m` (sección "PARTE 3").

**Resultado:**
```
H_A(Qpf) = 0.047 m
NPSHdisp = 9.837 m ; NPSHreq = 4.944 m  =>  NO CAVITA (margen 4.89 m)
```

**Resultado final Parte 3: NPSHdisp ≈ 9.84 m > NPSHreq ≈ 4.94 m ⇒ la
bomba NO cavita**, con un margen amplio (≈4.9 m).

**Comparación con solución oficial:** el manuscrito da NPSHdisp=9.85 m,
NPSHreq=4.91 m, no cavita — **coincide** (diferencia mínima en NPSHreq
por el método de interpolación entre los puntos de tabla).

---

## ESTADO: COMPLETO
