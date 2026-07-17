# Examen HHA — 5/6 de febrero de 2024 (2024 febrero)

Resolución paso a paso. El PDF del examen (`EXAMENES/2024 febrero.pdf`)
incluye, además de la letra (páginas 1-2) y la carta topográfica del
Ejercicio 3 (páginas 3, 8), la solución oficial manuscrita completa
(páginas 5-7, 9), que se usa para comparar cada resultado.

Herramientas: Octave (funciones de
`RESUMEN EXAMEN/Codigos/FGV_trapezoidal/`, copiadas y adaptadas en
`scripts/`) para el Ejercicio 1 (flujo gradualmente variado en canal
trapezoidal entre dos lagos, con escalón de fondo).

Los scripts del Ejercicio 1 deben ejecutarse en orden (`ej1_parte1.m`
genera `part1.mat`, usado por `ej1_parte2.m`; `ej1_parte2.m` genera
`part2.mat`, usado por `ej1_parte3.m`). Los archivos `.mat` intermedios no
se versionan.

---

## EJERCICIO 1 — Canal trapezoidal entre dos lagos, con escalón de fondo (25 puntos)

**Datos:** sección trapezoidal, b=5 m, talud m=2 (1V:2H), n=0.018
(Manning), S₀=0.002, L=1500 m. El canal nace en el Lago A (tirante sobre
el fondo del canal h_LA=1.10 m en x=0) y termina en el Lago B (tirante
h_LB=1.49 m en x=L=1500 m).

Teoría usada: caudal de un canal tipo M alimentado por un lago largo
(Teórico HHA §2.5.4, Resumen Teórico §A4), clasificación M/S (§2.5.1–2.5.2,
§A1), control de un segundo lago aguas abajo con curva de remanso M1
(§2.5.4, §A4), transición de fondo tipo escalón con posible ahogamiento y
remanso (§2.2, §A5), tirante conjugado y ubicación del resalto por
cantidad de movimiento (§2.3.2–2.3.3, §A3), y fuerza sobre un obstáculo de
fondo F=γ·(M1−M2) (§2.3.1, §A3).

### Parte 1) Caudal, clasificación M/S y perfil sin escalón

**Concepto.** El canal es largo (1500 m) y de tipo M (a verificar), por lo
que cerca de la entrada (Lago A) el tirante tiende al normal yn: se plantea
un sistema de 2 ecuaciones (conservación de energía entre la superficie del
lago y la sección de entrada + ecuación de Manning) en las 2 incógnitas
(Q, yn). Una vez hallado Q se calcula yc y se clasifica el canal. El
control aguas abajo es el Lago B: como su tirante h_LB=1.49 m es mayor que
yn, el Lago B impone una curva de remanso **M1** que sube desde x=L hacia
aguas arriba y se acerca asintóticamente a yn lejos del lago (canal
"infinito" en la práctica).

**Herramienta:** `caudal_M_ini.m` (sistema Q–yn para canal M alimentado por
un lago) + `tirantes_yn_yc.m`/`eq_yc.m` (yc) para clasificar, y luego
`rect.m` (EDO de FGV trapezoidal) integrada con `ode23` desde x=L (control,
y=h_LB) hacia x=0. Se usa `caudal_M_ini.m` — en vez de asumir Q como dato —
porque acá el caudal no se conoce de antemano, sólo los niveles de los dos
lagos.

**Script:** `scripts/ej1_parte1.m`. Entradas: `b=5, m=2, n=0.018,
S0=0.002, L=1500, hLA=1.10, hLB=1.49`.

**Resultado:**
```
Q  = 11.9754 m3/s
yn = 0.9101 m
yc = 0.7524 m
```
Como yn (0.9101 m) > yc (0.7524 m) ⇒ **canal tipo M**. Como h_LB=1.49 m >
yn=0.9101 m ⇒ el Lago B controla e impone una **curva M1** en todo el
canal.

**Perfil de la superficie libre (x desde el Lago A):**
- x=0 (Lago A): y=0.9102 m ≈ yn (el canal es lo bastante largo como para
  que la entrada ya esté prácticamente en régimen normal).
- x=700 m (punto donde después se instala el escalón, Parte 2): y=0.9100 m
  ≈ yn.
- x=1500 m (Lago B): y=1.4900 m = h_LB.

No hay resaltos: todo el tramo es subcrítico (curva M1 monótona).
Gráfico: `scripts/ej1_perfil_parte1.png`.

**Resultado final Parte 1: Q ≈ 11.98 m³/s, canal tipo M (yn=0.91 m >
yc=0.75 m), curva M1 en todo el canal (remanso desde el Lago B), sin
resaltos.**

**Comparación con solución oficial:** el manuscrito da E₁=h_LA=1.10 m,
y₁=yn ⇒ Q=11.99 m³/s (yn≈0.91 m), yc=0.75 m ⇒ yn>yc canal M, h_LB>yn ⇒
curva M1 — **coincide** (diferencia de redondeo en Q: 11.9754 vs 11.99).

### Parte 2) Escalón de fondo Zesc=0.50 m en x=700 m

**Concepto.** La obra para instalar una tubería deja un escalón de fondo
de longitud despreciable en x=700 m (el fondo sube Zesc y vuelve a bajar
al nivel original en el mismo punto). Es la misma situación de §A5: se
compara la energía específica disponible sin escalón en ese punto (E₁, con
el y sin alterar de la Parte 1 ≈ yn) contra la energía mínima Ec
(crítica); si Zesc > Zmax=E₁−Ec el escalón "ahoga" la sección y aparece
remanso aguas arriba, el flujo pasa por crítico en la cresta, se acelera a
supercrítico aguas abajo (curva M3) y un resalto hidráulico reconecta esa
rama con la curva M1 original (que sigue vigente lejos del escalón, porque
el Lago B sigue siendo el control aguas abajo).

**Herramienta:** energía específica directa en la sección sin alterar
(con y≈yn de la Parte 1) y Ec=yc+U_c²/2g para Zmax; `alternos_trap.m` para
los tirantes alternos (subcrítico aguas arriba / supercrítico aguas abajo)
con la nueva energía E_A=Ec+Zesc; integración de la curva M3 con
`rect.m`/`ode23` desde x=700 m hacia aguas abajo; conjugado de cada punto
de M3 con `Mom_trap.m`; resalto por intersección entre ese conjugado y el
perfil M1 original de la Parte 1 (mismo procedimiento que
`encontrar_resalto.m`, adaptado). Es el mismo enfoque usado en el
Ejercicio 1 del examen 2025_FEBRERO 2 ya resuelto en este repositorio.

**Script:** `scripts/ej1_parte2.m` (carga `part1.mat`).

**Resultado:**
```
y(x=700, sin escalon) = 0.9101 m (~= yn)
E1_sin = 1.1000 m ; Ec = 1.0579 m
Zmax = E1_sin - Ec = 0.0421 m

Zesc = 0.50 m > Zmax = 0.0421 m  => el escalon AHOGA la seccion => HAY REMANSO

EA = Ec + Zesc = 1.5579 m
y1_new (subcritico, aguas arriba del escalon) = 1.5078 m
y3_new (supercritico, aguas abajo del escalon) = 0.4349 m

RESALTO HIDRAULICO:
  x_resalto = 732.20 m (desde el Lago A)
  distancia desde el escalon (x=700m) = 32.20 m
  y antes del resalto (curva M3, supercritico) = 0.6112 m
  y despues del resalto (conjugado, sobre M1)  = 0.9100 m
```

**Caudal de descarga:** en las condiciones con escalón el caudal sigue
siendo Q≈11.98 m³/s: lejos del escalón (cerca del Lago A) el flujo
recupera el tirante normal yn≈0.91 m —el mismo sistema Q–yn de la Parte
1—, y el escalón sólo modifica el perfil local (remanso + M3 + resalto)
sin cambiar el caudal aportado por el Lago A.

**Perfil completo de la superficie libre (x desde el Lago A):**
- x=0 a ≈690 m: curva M1 sin alterar, y≈0.91 m (≈yn, lejos del escalón).
- x=700 m⁻ (justo aguas arriba del escalón): y₁=1.5078 m (remanso).
- x=700 m (cresta del escalón): y=yc=0.7524 m (paso por crítico).
- x=700 m⁺ (justo aguas abajo, fondo ya en su nivel original): y₃=0.4349 m
  (curva M3, supercrítica).
- x=700 a 732.2 m: curva M3 acelerando de 0.435 m a 0.611 m.
- x≈732.2 m: **resalto hidráulico**, de y=0.611 m a y=0.910 m.
- x=732.2 a 1500 m: curva M1 original de la Parte 1 (idéntica, sin
  alterar), subiendo de 0.910 m hasta h_LB=1.49 m en el Lago B.

Gráfico: `scripts/ej1_perfil_parte2.png`.

**Resultado final Parte 2: Q≈11.98 m³/s (no cambia), canal sigue siendo
tipo M; el escalón de 0.50 m ahoga la sección (Zmax=0.042 m << Zesc), se
forma remanso aguas arriba (y≈1.51 m en x=700 m⁻), el flujo pasa por
crítico en la cresta, se acelera a supercrítico (y≈0.43 m) y, tras
recorrer ≈32 m sobre la curva M3, un resalto hidráulico (de y≈0.61 m a
y≈0.91 m) reconecta con la curva M1 original hasta el Lago B.**

**Comparación con solución oficial:** el manuscrito da (interpretando la
digitalización, borrosa en esta parte) Zmax≈0.04–0.09 m, E_A=Ec+Zesc≈1.55
m, y₁≈1.51 m, y₃≈0.43 m y un resalto a ≈34 m del escalón con y antes del
resalto ≈0.61 m — **coincide** con los valores obtenidos (Zmax=0.042 m,
E_A=1.558 m, y₁=1.508 m, y₃=0.435 m, resalto a 32.2 m con y=0.611 m antes
del resalto); las pequeñas diferencias (≤2 m en la posición del resalto)
son consistentes con redondeo manual en la resolución original.

### Parte 3) Fuerza sobre el escalón

**Concepto.** Entre la sección justo aguas arriba del escalón
(y₁=1.5078 m, fondo a nivel original) y la sección justo aguas abajo
(y₃=0.4349 m, fondo también a nivel original, tras la subida y bajada del
escalón) no hay cambio de cota de fondo entre las dos secciones de
control: toda la fuerza horizontal neta que el escalón ejerce sobre el
fluido es R=γ·(M₁−M₃) (cantidad de movimiento, §A3); por reacción, el
fluido ejerce sobre el escalón una fuerza igual y opuesta, en el sentido
del flujo.

**Herramienta:** `Mom_trap.m` para M(y₁) y M(y₃) (función cantidad de
movimiento de la sección trapezoidal), con los tirantes y1_new/y3_new
calculados en la Parte 2.

**Script:** `scripts/ej1_parte3.m` (carga `part2.mat`).

**Resultado:**
```
M1 = M(y=1.5078 m) = 9.1782 m3
M3 = M(y=0.4349 m) = 6.2547 m3

F = gamma*(M1 - M3) = 9800*(9.1782 - 6.2547) = 28649 N = 28.6 kN
```

**Resultado final Parte 3: F ≈ 28.6 kN, en el sentido del flujo.**

**Comparación con solución oficial:** el manuscrito da
Π_A=9.2068 m³, Π_A'=6.3369 m³ ⇒ F=9800·(9.2068−6.3369)=28126 N ≈ 28.1 kN
— **coincide** con el resultado obtenido (28.6 kN), diferencia ≈2% por
redondeo manual de los tirantes alternos en la resolución original.

---

## EJERCICIO 2 — Alcantarilla en el norte de Artigas (25 puntos)

**Datos:** cuenca de drenaje Área=6.3 km², ΔH=180 m (cauce principal),
L=3750 m (cauce principal), pendiente **media de la cuenca** S=3.1%
(dato de tabla, ¡distinta de la pendiente del cauce principal que
alimenta Kirpich!), coordenadas del punto de cierre X=400 km, Y=6600 km.
Uso de suelo: pastizales, condición hidrológica mala. Suelos: Rivera 25%
(grupo hidrológico B) + Itapebí-Tres Árboles 75% (grupo hidrológico D).
Flujo concentrado.

Teoría usada: criterio de selección Racional/NRCS según tc (Resumen
Teórico §B4), Número de Curva ponderado por unidad de suelo (§B5),
condición de humedad antecedente AMC (§B6), volumen de escorrentía (§B7),
curvas IDF de Uruguay y coeficientes CD/CT/CA (§B3).

### Parte 1) Caudal de diseño Tr=10 años, volumen de escorrentía, hietograma e hidrograma

**Concepto.** Primero hay que decidir qué método corresponde según el
tiempo de concentración (§B4): se calcula tc por Kirpich con la pendiente
del **cauce principal** (ΔH/L/10 = 180/3.75km/10 = 4.8%, **no** la
pendiente media de la cuenca de la tabla, que sólo sirve para elegir el
coeficiente C del método Racional). Con 20 min < tc < 1 h el criterio
exige calcular **ambos** métodos (Racional y NRCS) y adoptar el **mayor**
caudal. Para el NC se pondera por área las dos unidades cartográficas de
suelo (§B5, NC ponderado). El volumen de escorrentía es la suma de la
precipitación efectiva de los 12 bloques de la tormenta de diseño,
multiplicada por el área (§B7).

**Herramienta:** Python replicando las fórmulas de la hoja `Cálculos
(grande)` de `Eventos extremos.xlsx` (ver
`RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md`) — en este entorno
no hay Excel interactivo, así que se reproducen las mismas fórmulas
celda por celda en Python (Kirpich, IDF Uruguay CD/CT/CA, método
Racional, bloque alterno + Número de Curva + hidrograma unitario
triangular SCS), igual que en los exámenes de hidrología ya resueltos en
este repositorio.

**Script:** `scripts/ej2_parte1.py`. Entradas: `Area=6.3 km2, dH=180m,
L=3750m, Tr=10, P310=98mm (isoyetas Fig. 3.1.10 en X=400km,Y=6600km), C=0.38
(Tabla 3.1.4, pastizales cond. mala, pendiente 2-7%), NC_Rivera=79 (grupo
B), NC_ItapebiTresArboles=89 (grupo D)`.

**Resultado:**
```
S canal principal (Kirpich) = 180/3.75/10 = 4.80 %   (<> S media cuenca=3.1%, usada solo para C)
tc = 0.4*L^0.77/S^0.385 = 0.6050 hs = 36.30 min       => 20min<tc<1h: calcular AMBOS metodos

NC ponderado = 0.25*79 + 0.75*89 = 86.50

--- METODO RACIONAL (duracion = tc) ---
CD(tc)=0.4924 ; CA(tc,A)=0.9842 ; P(area)=47.49mm ; i=78.50 mm/h
Q_racional = 0.38*78.50*630/360 = 52.20 m3/s

--- METODO NRCS (bloque alterno, dt=tc/7=5.19min) ---
S=39.64mm ; Ia=7.93mm
SUMA Pe corregido = 30.05 mm
Qmax NRCS = 72.08 m3/s en t=1.02 hs desde el inicio de la tormenta

Q racional=52.20 m3/s < Q NRCS=72.08 m3/s => se adopta el MAYOR: NRCS
Volumen de escorrentia = 30.05mm * 6.3km2 * 1000 = 189299 m3 = 0.189 hm3
```

Hietograma de diseño (bloque alterno) e hidrograma de crecida:
`scripts/ej2_hietograma_hidrograma_parte1.png`.

**Resultado final Parte 1: Q diseño (Tr=10 años) ≈ 72.1 m³/s (método
NRCS, mayor que el Racional=52.2 m³/s), volumen de escorrentía ≈0.189
hm³, tiempo de demora en alcanzar Qmax ≈1.0 h desde el inicio del
evento.**

**Comparación con solución oficial:** el manuscrito da P(3,10)=98mm,
tc=36min, C=0.38⇒Q_HR=52.2 m³/s, NC ponderado=86.5⇒Q_NRCS=71.7 m³/s
(adopta el mayor, NRCS), volumen de escorrentía V=0.189 hm³, tiempo al
pico t=1.04 h — **coincide** con los valores obtenidos (diferencias
≤0.5% en Q_NRCS y en t, por el detalle de discretización del bloque
alterno; volumen de escorrentía coincide exactamente).

### Parte 2) Período de retorno tras el aumento del 35% en tc

**Concepto.** La alcantarilla ya está construida con la capacidad fijada
en la Parte 1 (Q diseño≈72.1 m³/s). Una modificación del cauce aumenta
tc un 35%; con ese tc nuevo, se busca el período de retorno Tr cuyo
caudal NRCS iguala exactamente esa capacidad ya construida (iterando Tr,
"Buscar Objetivo", ver §6.9 del instructivo de la planilla).

**Herramienta:** mismo modelo NRCS de la Parte 1 (Python), pero con
tc_nuevo=1.35·tc y barriendo/biseccionando Tr hasta que Qmax_NRCS(Tr)
coincida con el caudal de diseño ya fijado.

**Script:** `scripts/ej2_parte2.py`.

**Resultado:**
```
tc_nuevo = 1.35 * 0.6050 hs = 0.8167 hs = 49.00 min

Tr=12 -> Qmax=70.04 m3/s
Tr=13 -> Qmax=71.68 m3/s   (el mas cercano por debajo)
Tr=14 -> Qmax=73.19 m3/s

Tr (interpolado) = 13.26 años
```

**Resultado final Parte 2: Tr ≈ 13 años** (con el tc aumentado, el
caudal que antes tenía un período de retorno de 10 años ahora se alcanza
con un período de retorno menor, ≈13 años en vez de un valor mayor,
porque una cuenca más lenta —tc mayor— concentra el mismo volumen de
lluvia en un pico más bajo, así que hace falta una lluvia algo más
intensa, de Tr apenas mayor a 10, para reproducir el mismo caudal pico
que antes daba exactamente Tr=10).

**Comparación con solución oficial:** el manuscrito da tc_nuevo=1.35·tc=
0.82 h=49 min ⇒ **Tr≈13 años** — **coincide exactamente**.

### Parte 3) Verificación de un evento extremo observado en julio

**Concepto.** Se evalúa si un evento de precipitación **ya observado**
(hietograma dado, no la tormenta de diseño por bloque alterno) —en las
condiciones modificadas de la cuenca (Parte 2)— genera un caudal mayor
al de diseño. Primero hay que fijar la condición de humedad antecedente
(§B6): P5d=15 mm en estación inactiva cae en el rango 12.7–27.94 mm ⇒
**AMC II**, el NC no se corrige (sigue siendo 86.5). Como el hietograma
observado viene en 12 bloques de 7 min y tc_nuevo/7=49/7=7 min
exactamente, se puede convolucionar directamente con el mismo hidrograma
unitario triangular de la Parte 2 (Tp, Tb con tc_nuevo), usando la
precipitación efectiva por Número de Curva **sin** el piso de
infiltración adicional (Hoja 4 de la planilla, ver
`COMO_USAR_EVENTOS_EXTREMOS.md` §4) porque acá ya no se arma una
tormenta de diseño por bloque alterno sino que se usa el hietograma real
en su orden cronológico.

**Herramienta:** Python, precipitación efectiva incremental por NC
(fórmula de Hoja 4) sobre el hietograma dado, convolucionada con el
hidrograma unitario triangular SCS de tc_nuevo (mismo Tp/Tb de la Parte
2).

**Script:** `scripts/ej2_parte3.py`.

**Resultado:**
```
P5d=15mm, estacion inactiva => AMC II => NC=86.5 (sin corregir)

Hietograma observado (12 bloques de 7 min), total = 59.0 mm
SUMA Pe = 28.75 mm

Qmax evento observado = 51.15 m3/s en t=1.37 hs
```

Gráfico: `scripts/ej2_hidrograma_parte3.png`.

**Resultado final Parte 3: Q evento ≈ 51.2 m³/s < Q diseño ≈ 72.1 m³/s
⇒ el evento de julio NO superó la capacidad de diseño de la
alcantarilla.**

**Comparación con solución oficial:** el manuscrito da NC(II)=86.5
(estación inactiva, P5d=15mm) y Q=50.86 m³/s < Q diseño ⇒ no se supera
— **coincide** con el resultado obtenido (51.15 m³/s), diferencia <1%
por redondeo en la discretización.

---

## ESTADO: EN CURSO (Ejercicios 1 y 2 completos; faltan Ejercicios 3 y 4)
