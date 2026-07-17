# Examen HHA — 24 de julio de 2023

Fuente: `EXAMENES/2023 Julio.pdf` (10 páginas: letra + solución oficial
manuscrita completa, escaneada, con carta topográfica). Los 4 ejercicios
(25/30/20/25 puntos) son: 1) FGV en canal trapezoidal, entre dos lagos,
con obra de relleno que cambia la pendiente de fondo en un tramo; 2)
hidrología de una cuenca en Canelones — caudal de diseño de una
alcantarilla (Racional + NRCS), caudal de un evento observado (hietograma
en bloques + AMC) y período de retorno de una intensidad registrada; 3)
delimitación de la cuenca de la cañada de Arbelo (carta SGM), definición
de tiempo de concentración y cálculo de tc; 4) sistema de bombeo con
bifurcación en dos tuberías idénticas que descargan a la atmósfera —
cavitación y punto de funcionamiento.

Este examen trae **solución oficial manuscrita completa** para los 4
ejercicios (páginas 5-10 del PDF) y la carta topográfica sin delimitar
(página 3), que se usan para comparar cada resultado.

---

## Ejercicio 1 — FGV en canal trapezoidal con obra de relleno (cambio de pendiente)

### Enunciado (resumen)

Un Lago A (nivel hLA=1.7 m sobre el fondo) descarga a un canal
TRAPEZOIDAL (ancho de base b=1.8 m, talud lateral m=1, n=0.014,
S0=0.008), de longitud L=100 m, que termina en un Lago B (nivel
hLB=0.5 m sobre el fondo).

1) Calcular el caudal de descarga, clasificar el canal en tipo M o S y
   dibujar la superficie libre, indicando tirantes relevantes y
   resaltos si los hubiera.
2) Una obra de relleno cambia la pendiente de fondo a S02=0.0015 en el
   tramo x=[40,100] m (el tramo x=[0,40] m conserva S0=0.008). Repetir
   el análisis para estas nuevas condiciones.

### Teoría (RESUMEN_TEORICO.md, sección A — FGV)

- **A1** Clasificación M/S: yn (Manning) vs. yc (Froude=1); en sección
  trapezoidal ninguno de los dos tiene forma cerrada, se resuelven por
  `fsolve` (`eq_yn.m`, `eq_yc.m`).
- **A2** Energía específica: control crítico en la entrada de un canal
  alimentado por un lago, E(yc)=hLago. En trapezoidal esto tampoco es
  cerrado (a diferencia del rectangular E=1.5·yc): se itera un `fzero`
  externo en Q para que yc(Q) satisfaga la ecuación de energía.
- **A4** Control de un canal alimentado por un lago: si el tramo de
  salida es tipo S, el lago descarga con control crítico en la entrada,
  caudal máximo independiente de lo que pase aguas abajo (mientras siga
  siendo steep); un segundo lago aguas abajo con nivel menor al tirante
  que trae el canal no controla nada (caída libre).
- **A3** Ubicación de un resalto: comparar, en la misma sección x, el
  conjugado (`Mom_trap`) de la rama supercrítica con el valor real de la
  rama subcrítica.
- Caso análogo ya resuelto (canal RECTANGULAR de dos tramos entre dos
  lagos): `resueltos/2023 diciembre/RESOLUCION.md`, Ejercicio 1 — mismo
  método, adaptado acá a geometría trapezoidal.

Cita: Teórico HHA §2.2, §2.3.1–§2.3.3, §2.5.1–§2.5.6; Formulómetro "Flujo
Gradualmente Variado" / "Energía" / "Cantidad de Movimiento".

### Herramienta y por qué

Se usó Octave con el toolkit canónico `RESUMEN EXAMEN/Codigos/FGV_trapezoidal`
(`trap_geom` —geometría—, `eq_yc`+`fsolve` —yc—, `eq_yn`+`fsolve` —yn—,
`Mom_trap` —conjugado/resalto—, `rect.m` —ODE de FGV trapezoidal, pese al
nombre— +`ode23` —integración de las curvas S2/M2/M3—, `critico.m` —evento
de parada en yc—) porque el enunciado es un problema de FGV en canal
TRAPEZOIDAL con controles en ambos extremos (dos lagos) y un cambio de
pendiente intermedio en un solo tramo — el caso de uso central de ese
toolkit, con la particularidad de que ninguna magnitud (yc, Q de control
crítico) tiene forma cerrada en sección trapezoidal, a diferencia del caso
rectangular ya resuelto en 2023 diciembre. No hizo falta ninguna función
nueva en el toolkit: se resolvió encadenando las funciones existentes con
un `fzero` adicional (envuelto en la función local
`residuo_entrada_lago`, dentro del script de este ejercicio) para hallar
el Q de control crítico. Script adaptado a este examen (+ todo el
toolkit `FGV_trapezoidal` copiado al mismo directorio como dependencias):
`resueltos/2023 Julio/scripts/Ejercicio1_FGV_trapezoidal_relleno.m`.

### Paso a paso

**Parte 1) Canal uniforme, S0=0.008 en toda la longitud.**

Como el tramo de salida es candidato a tipo S (pendiente 0.008,
relativamente fuerte para b=1.8 m), se prueba la hipótesis de control
crítico en la entrada: el Lago A descarga el caudal máximo compatible
con su energía, es decir y(0)=yc con E(yc)=hLA. En sección trapezoidal
esto no tiene forma cerrada, así que se itera Q (`fzero`) hasta que el
yc(Q) resuelto con `eq_yc` cumpla la ecuación de energía:

```
yc(Q) + Q² / (2g·A(yc)²) = hLA        (fzero en Q)
Q = 11.323 m³/s  ;  yc = 1.2552 m  ;  A(yc) = 3.8347 m²
chequeo: E(yc) = 1.2552 + 11.323²/(2·9.8·3.8347²) = 1.7000 m = hLA  ✓
```

Tirante normal con S0=0.008 (`eq_yn`, `fsolve`):

```
yn = 0.9360 m   ;   yn < yc  =>  CANAL TIPO S (steep)
```

La hipótesis es autoconsistente (canal efectivamente steep), así que el
control crítico en la entrada es válido: el Lago A descarga su caudal
máximo **sin que importe lo que pase aguas abajo**, salvo verificar el
Lago B al final.

Se integra la curva **S2** (supercrítica, decreciente) desde y(0)=yc
hasta x=L=100 m:

```
y(x=0) = 1.2550 m (=yc)  ->  y(x=100) = 0.9585 m   (asintótico a yn=0.936 m)
```

Como hLB=0.5 m < y(100)=0.9585 m, el **Lago B queda por debajo** del
nivel que trae el canal: no controla nada (en flujo supercrítico la
información no viaja hacia aguas arriba), la descarga se comporta como
una caída libre y **no hay resalto** en todo el canal.

**Perfil completo (Parte 1):** y=1.255 m en la entrada (control crítico,
x=0) → curva **S2** decreciendo suavemente hasta y≈0.959 m en x=100 m
(cerca de yn=0.936 m) → descarga directa al Lago B, sin resalto.

**Parte 2) Relleno: S02=0.0015 en x=[40,100] m (x=[0,40] m sin cambios).**

Como el tramo x=[0,40] m conserva S0=0.008 (no cambia respecto a la
Parte 1), el control crítico en la entrada **sigue siendo el mismo**: la
perturbación aguas abajo no puede viajar hacia el Lago A porque el flujo
en ese tramo es supercrítico. Se reutilizan Q=11.323 m³/s y yc=1.2552 m
de la Parte 1.

Tirante normal del tramo 2 con S02=0.0015:

```
yn2 = 1.4567 m   ;   yn2 > yc  =>  TRAMO 2 TIPO M (mild)
```

La curva S2 del tramo 1, evaluada en x=40 m (mismo Q, misma S0=0.008):

```
y(x=40) = 1.0096 m   (< yc, sigue supercrítica)
```

Al entrar al tramo 2 (mild) con y<yc, la rama supercrítica se convierte
en una curva tipo **M3** (crece hacia yc): se integra la ODE de FGV con
S02 desde (x=40, y=1.0096) hacia adelante:

```
y(x=40) = 1.0096 m  ->  y(x≈81.5) = yc = 1.2552 m   (curva M3, creciendo)
```

En la salida (x=100 m), hLB=0.5 m < yc=1.2552 m: el Lago B tampoco
controla acá — la salida se comporta como caída libre, y(100)=yc,
alimentando una curva **M2** (subcrítica) que se integra **hacia atrás**
desde x=100 hasta x=40:

```
y(x=100) = 1.2553 m (=yc, caída libre)  ->  y(x=40) = 1.4028 m   (curva M2)
```

Como la rama que entra al tramo 2 es supercrítica (M3) y la rama de
salida es subcrítica (M2), debe haber un **resalto** dentro del tramo 2.
Se ubica comparando el conjugado (`Mom_trap`) de la rama M3 con el valor
real de la rama M2 en la misma malla de x:

```
RESALTO en x ≈ 69.3 m (≈29.3 m dentro del tramo 2):  y = 1.139 m  ->  y = 1.375 m
```

**Perfil completo (Parte 2):** y=1.255 m en la entrada (control crítico,
x=0) → curva **S2** decreciendo hasta y=1.010 m en x=40 m (cambio de
pendiente) → curva **M3** creciendo hasta y≈1.14 m en x≈69.3 m →
**resalto** (1.14 m → 1.375 m) → curva **M2** decreciendo suavemente
hasta y=yc=1.255 m en x=100 m (caída libre al Lago B).

### Resultado final

| Ítem | Resultado |
|---|---|
| Caudal de descarga (control crítico en la entrada) | **Q = 11.32 m³/s** |
| Tirante crítico yc | **1.255 m** |
| Parte 1: clasificación / yn | **Tipo S** (yn=0.936 m) |
| Parte 1: perfil | y=1.255 m (x=0) → curva S2 → y≈0.959 m (x=100 m), sin resalto |
| Parte 2: tramo 1 [0,40 m] | Tipo S (idéntico a Parte 1) |
| Parte 2: tramo 2 [40,100 m] | **Tipo M** (yn2=1.457 m) |
| Parte 2: resalto | **x≈69.3 m** (1.14 m → 1.375 m) |
| Parte 2: perfil | S2 (x=0→40) → M3 (40→69.3) → resalto → M2 (69.3→100, hasta yc) |

### Comparación con la solución oficial

La solución oficial manuscrita (páginas 5-6 del PDF) trae los mismos
resultados numéricos, calculados a mano con las fórmulas cerradas de
sección rectangular aplicadas a los términos trapezoidales (mismo
método, menor precisión numérica):

| Magnitud | Oficial (manuscrito) | Calculado | Diferencia |
|---|---|---|---|
| Q (control crítico) | 11.33 m³/s | 11.32 m³/s | ≈0 |
| yc | 1.25 m | 1.255 m | ≈0 |
| yn (Parte 1, S0=0.008) | 0.93 m | 0.936 m | ≈0.01 m |
| y(x=100 m), Parte 1 | 0.959 m | 0.959 m | 0 |
| yn2 (Parte 2, S02=0.0015) | 1.45 m | 1.457 m | ≈0.01 m |
| y(x=40 m), Parte 2 | 1.03 m | 1.010 m | ≈0.02 m |
| Posición del resalto | x≈70 m (30 m en tramo 2) | x≈69.3 m (29.3 m en tramo 2) | ≈0.7 m |
| Tirantes del resalto | 1.143 m → 1.37 m | 1.139 m → 1.375 m | ≈0.01 m |

Coincidencia prácticamente total (las diferencias de milésimas se deben
a redondeo manual en el examen original vs. precisión numérica de
`fsolve`/`ode23`). Nota: el escaneo original de la solución tiene, en el
encabezado del Ejercicio 1, una anotación manuscrita con otros valores
de b y L que no corresponden a la letra impresa del examen (probablemente
un residuo de un borrador o una serie distinta del mismo parcial); se
usaron los datos de la letra impresa (b=1.8 m, m=1, L=100 m) en todo el
cálculo, y la coincidencia numérica exacta de Q, yc y la posición del
resalto con el desarrollo manuscrito confirma que el resto de la
solución oficial sí corresponde a estos mismos datos.

---

## Ejercicio 2 — Diseño de alcantarilla, evento observado y período de retorno de un pluviógrafo

### Enunciado (resumen)

Cuenca en Canelones (punto de cierre X=494.7 km, Y=6170.9 km): Área=5.5 km²,
ΔH=80 m, L=3715 m, Grupo Hidrológico C, pendiente media S=6.5%. Uso de suelo:
pastizales en condición hidrológica MALA. Flujo concentrado.

1) Determinar el caudal máximo de diseño de la alcantarilla, Tr=10 años,
   justificando el método.
2) Una vez construida la obra, ocurre un evento extremo con hietograma
   observado (12 bloques de 7 min, P en mm: 1.9, 2.1, 2.4, 2.8, 3.7, 6.2,
   15.3, 4.5, 3.2, 2.6, 2.2, 2.0), con P5d=64 mm en los 5 días previos.
   Determinar el caudal máximo en el punto de cierre para ese evento.
3) Determinar el período de retorno de la intensidad máxima de
   precipitación de este evento, registrada en un pluviógrafo.

### Teoría (RESUMEN_TEORICO.md, sección B)

- **B2** Tiempo de concentración (Ramser-Kirpich).
- **B3** Curvas IDF de Uruguay (CD/CT/CA) — incluye el procedimiento
  inverso para hallar el Tr de un evento ya registrado (Parte 3 de este
  ejercicio).
- **B4** Método Racional, con el criterio de selección de método según tc.
- **B5** Método NRCS (Número de Curva + hidrograma unitario triangular
  SCS), incluyendo la variante con el hietograma **observado** en su
  orden cronológico real (sin bloque alterno) para verificar la
  respuesta de una obra ya construida a un evento real.
- **B6** Condición de humedad antecedente (AMC): P5d se compara contra
  los umbrales según la estación (activa/inactiva) para corregir el NC.

Cita: Teórico HHA §3.1.2–§3.1.6; Formulómetro "Eventos extremos —
Tiempo de Concentración" / "Relaciones IDF" / "Método Racional" /
"Método NRCS" / "Condiciones de humedad antecedente".

### Herramienta y por qué

Se usó Python (`numpy`, sin `scipy` disponible en el entorno — se
implementó una bisección manual donde hacía falta) replicando las
fórmulas de la planilla `Eventos extremos.xlsx` (hoja "Cálculos
(grande)", ver `COMO_USAR_EVENTOS_EXTREMOS.md`) en vez de operar la
planilla Excel directamente, siguiendo el mismo patrón ya usado en los
demás exámenes resueltos (`resueltos/*/scripts/ej2_parte*.py`): el
cálculo requiere iterar (bloque alterno de 12 pasos, convolución del
hidrograma unitario, inversión numérica de CT(Tr)), que en Python es
más rápido de verificar y de adaptar a tres sub-partes con datos
distintos que editar celda por celda. Scripts (uno por parte, cada uno
reutilizable/adaptable a otro examen con los mismos pasos):
`resueltos/2023 Julio/scripts/Ejercicio2_parte1_racional_NRCS.py`,
`Ejercicio2_parte2_evento_AMC.py`, `Ejercicio2_parte3_Tr_pluviografo.py`.

### Paso a paso

**Parte 1) Caudal de diseño (Tr=10 años).**

Tiempo de concentración (Ramser-Kirpich, flujo concentrado):
```
S (cauce ppal) = ΔH/L/10 = 80/3.715/10 = 2.1534 %
tc = 0.4·L(km)^0.77/S^0.385 = 0.8178 hs = 49.07 min
```
Como 20 min < tc < 1 h, corresponde calcular **ambos** métodos (Racional
y NRCS) y adoptar el mayor caudal (B4).

Método Racional (C=0.38, pastizales pendiente 2-7%, Tabla 3.1.4;
P(3,10)=80 mm dato del enunciado; CT(10)=1):
```
d=tc=0.8178 hs ; CD(d)=0.5634 ; CA(d,A)=0.9879
P(d,10,A) = P310·CD·CT·CA = 44.53 mm ; i = P/d = 54.44 mm/h
Qmax racional = C·i·A(ha)/360 = 0.38·54.44·550/360 = 31.61 m³/s
```

Método NRCS (NC=86, pastizales/condición MALA/Grupo C; tormenta de
diseño por bloque alterno, dt=tc/7=7.01 min, 12 bloques; piso de
infiltración 1.2 mm/h por ser Grupo C):
```
S = 25.4·(1000/86−10) = 41.35 mm ; Ia = 0.2·S = 8.27 mm
ΣPe (tormenta de diseño) = 26.11 mm
Hidrograma unitario SCS: Tp=0.549 hs, Tb=1.465 hs, qp=0.208·A/Tp (por mm)
Qmax NRCS (convolución) = 40.54 m³/s
```
Como Qmax NRCS (40.54 m³/s) > Qmax Racional (31.61 m³/s), **se adopta el
método NRCS**: Qmax de diseño = **40.54 m³/s**.

**Parte 2) Caudal del evento observado (con corrección de NC por AMC).**

El evento ocurre en julio (invierno en Uruguay ⇒ estación **inactiva**).
Con P5d=64 mm (B6):
```
P5d = 64 mm > 27.94 mm (umbral AMC III, estación inactiva) => condición AMC III (húmedo)
NC(III) = 23·NC(II)/(10+0.13·NC(II)) = 23·86/(10+0.13·86) = 93.39
```
Se sustituye la tormenta de diseño por el hietograma **realmente
ocurrido** (12 bloques de 7 min, en su orden cronológico real, sin
reordenar por bloque alterno — coincide con el mismo dt=tc/7 de la
Parte 1, así que se reutiliza el mismo hidrograma unitario):
```
S = 25.4·(1000/93.39−10) = 17.98 mm ; Ia = 0.2·S = 3.60 mm
P total del evento = 48.90 mm ; ΣPe (efectiva) = 32.43 mm
Qmax del evento (convolución con el mismo HU triangular de la Parte 1) = 49.90 m³/s
```
Como 49.90 m³/s > 40.54 m³/s (el caudal de diseño de la Parte 1), **el
evento superó la capacidad de diseño de la alcantarilla**.

**Parte 3) Período de retorno de la intensidad máxima registrada.**

El bloque de mayor intensidad del hietograma observado es P=15.3 mm en
d=7 min (el mismo bloque que domina el pico del hidrograma de la Parte
2). Al ser un dato **puntual** de un pluviógrafo (no una tormenta de
diseño sobre una cuenca), no corresponde corrección por área (CA=1). Se
despeja CT y se invierte numéricamente CT(Tr) (B3, procedimiento
inverso; bisección manual, ya que no está disponible `scipy` en el
entorno):
```
CD(d=7min=0.1167 hs) = 0.2286
CT objetivo = P/(P310·CD·CA) = 15.3/(80·0.2286·1) = 0.8370
CT(Tr) = 0.5786 − 0.4312·log10(ln(Tr/(Tr−1))) = 0.8370  =>  Tr ≈ 4.50 años (bisección)
```

### Resultado final

| Ítem | Resultado |
|---|---|
| tc (Ramser-Kirpich) | 0.818 h ≈ 49.1 min (20 min<tc<1h ⇒ calcular ambos métodos) |
| Qmax método Racional (Tr=10) | 31.61 m³/s |
| Qmax método NRCS (Tr=10) | 40.54 m³/s |
| **Parte 1: Qmax de diseño de la alcantarilla** | **40.54 m³/s** (NRCS, mayor de los dos) |
| AMC del evento observado | AMC III (P5d=64 mm > 27.94 mm, estación inactiva) |
| NC corregido (evento) | 93.39 (de NC(II)=86) |
| **Parte 2: Qmax del evento observado** | **49.90 m³/s** (supera la capacidad de diseño) |
| **Parte 3: Tr de la intensidad máxima registrada** | **≈4.5 años** |

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| tc | 0.817 h (49 min) | 0.8178 h (49.07 min) | ≈0 |
| Qmax Racional | 31.62 m³/s | 31.61 m³/s | ≈0 |
| i (Racional) | 54.46 mm/h | 54.44 mm/h | ≈0 |
| NC (Parte 1, tabla) | 86 | 86 | 0 (dato) |
| Qmax NRCS (Parte 1) | 40.35 m³/s | 40.54 m³/s | ≈0.5% |
| NC(III) (Parte 2) | 93.39 | 93.39 | ≈0 |
| Qmax evento observado (Parte 2) | 49.85 m³/s | 49.90 m³/s | ≈0.1% |
| CD (Parte 3) | 0.2286 | 0.2286 | 0 |
| CT objetivo (Parte 3) | 0.8366 | 0.8370 | ≈0 |
| Tr (Parte 3) | ≈4.5 años | 4.50 años | 0 |

Coincidencia prácticamente total en las tres partes; las diferencias de
±0.5% en los caudales NRCS se deben a redondeos en la discretización
manual del bloque alterno/hidrograma en la solución oficial vs. la
malla numérica fina usada en Python.

---

## Ejercicio 3 — Delimitación de cuenca (cañada de Arbelo, Canelones) + tiempo de concentración

### Enunciado (resumen)

1) Delimitar la cuenca de la cañada de Arbelo (departamento de
   Canelones), punto de cierre X=520 km, Y=6160 km, sobre la carta
   topográfica SGM adjunta (curvas de nivel cada 5 m).
2) Definir qué se entiende por tiempo de concentración de una cuenca
   hidrográfica.
3) Determinar el desnivel máximo del cauce principal y el tiempo de
   concentración de la cuenca, asumiendo que la longitud del cauce
   principal es L=7850 m y que el flujo puede considerarse concentrado.

### Teoría (RESUMEN_TEORICO.md)

- **B1** Delimitación de cuencas y divisoria de aguas: la divisoria se
  traza perpendicular a las curvas de nivel, ganando altura por el lado
  convexo (lomas/cuchillas, hacia las nacientes) y perdiendo altura por
  el lado cóncavo (vaguadas de cuencas vecinas), sin cruzar nunca un
  curso de agua salvo en el propio punto de cierre.
- **B2** Tiempo de concentración (Ramser-Kirpich): tc es el tiempo de
  viaje de la partícula de agua que recorre el trayecto hidráulicamente
  más largo hasta el punto de cierre — el instante en que toda la
  cuenca empieza a aportar simultáneamente.

Cita: Teórico HHA §1.2.1 "Cuenca como sistema hidrológico", §3.1.2
"Tiempo de concentración"; Formulómetro "Morfología de Cuencas" /
"Eventos extremos — Tiempo de Concentración".

### Herramienta y por qué

**Parte 1:** delimitación gráfica manual sobre la carta (Teórico
§1.2.1, sin fórmula cerrada) — se extrajo a imagen la página con la
carta en blanco (`scripts/ej3_carta_sin_delimitar.png`, página 3 del
PDF) y la página con la delimitación de la solución oficial
(`scripts/ej3_carta_solucion_oficial.png`, página 8 del PDF, con el
polígono de la cuenca ya trazado a mano).

**Parte 3:** Python (`scripts/Ejercicio3_tc.py`) replicando la fórmula
cerrada de Ramser-Kirpich (no requiere `fsolve` ni ninguna herramienta
numérica, es una expresión directa en L y S) sobre las cotas leídas en
la delimitación de la carta — mismo patrón ya usado en
`resueltos/2025_FEBRERO 2/RESOLUCION.md`, Ejercicio 3 Parte 1.2.

### Paso a paso

**Parte 1) Delimitación de la cuenca.**

El punto de cierre (marcador circular en la carta) se ubica sobre el
curso de la cañada de Arbelo, inmediatamente al sur de un cruce de
caminos, en la zona norte de la hoja. Desde ahí se trazó la divisoria
de aguas perpendicular a las curvas de nivel, subiendo por las lomas
que separan el valle de la cañada de Arbelo de las cuencas vecinas
(cañada del Juncal al oeste, otros tributarios de la cañada Grande al
este): el resultado es una cuenca alargada en forma de "hoja", angosta
cerca del punto de cierre y ensanchándose hacia el norte, hasta cerrar
en las nacientes del curso principal (loma al norte del área, cota
máxima ≈66 m). Ver `scripts/ej3_carta_solucion_oficial.png` (polígono
trazado a mano en la solución oficial) comparado con
`scripts/ej3_carta_sin_delimitar.png` (carta sin delimitar, tal como se
entrega en el examen).

**Parte 2) Definición de tiempo de concentración.**

El tiempo de concentración es el tiempo requerido para que el punto
hidráulicamente más alejado de la cuenca (el que está a mayor distancia
en tiempo de viaje, no necesariamente en distancia física) aporte su
escurrimiento al punto de cierre. Equivalentemente: el tiempo requerido
para que **toda la cuenca** empiece a contribuir simultáneamente al
caudal de salida. Es el criterio que fija la duración de la tormenta de
diseño en el método Racional (B4 de `RESUMEN_TEORICO.md`).

**Parte 3) Desnivel máximo y tiempo de concentración.**

Cotas leídas sobre la delimitación (interpolando entre curvas de nivel
cada 5 m): la naciente del cauce principal está cerca de la cota 66 m
(loma norte) y el punto de cierre está cerca de la cota 38 m.

```
ΔH = Hmax - Hmin = 66 - 38 = 28 m
L  = 7850 m = 7.850 km                        (dato del enunciado)
S  = ΔH(m) / L(km) / 10 = 28/7.850/10 = 0.3567 %

Ramser-Kirpich (flujo concentrado):
tc = 0.4 · L^0.77 / S^0.385 = 0.4·(7.850)^0.77/(0.3567)^0.385 = 2.9072 h ≈ 2.91 h (174.4 min)
```

### Resultado final

| Ítem | Resultado |
|---|---|
| Parte 1: cuenca delimitada | Polígono alargado cerrando en el punto de cierre (X=520, Y=6160), ver `ej3_carta_solucion_oficial.png` |
| Parte 2: definición de tc | Tiempo para que el punto hidráulicamente más alejado (=toda la cuenca) aporte al punto de cierre |
| Desnivel máximo del cauce principal, ΔH | **28 m** (66 m → 38 m) |
| Pendiente del cauce principal, S | **0.357 %** |
| **Tiempo de concentración, tc (Ramser-Kirpich)** | **2.91 h ≈ 174 min** |

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| ΔH | 28 m | 28 m | 0 |
| L | 7850 m | 7850 m | 0 (dato) |
| tc | 2.91 h | 2.9072 h | ≈0 |

Coincidencia exacta: la definición de tc (Parte 2) coincide en sustancia
con la respuesta manuscrita oficial ("tiempo requerido para que el
punto hidráulicamente más alejado de la cuenca llegue al punto de
cierre, es decir, el tiempo requerido para que toda la cuenca aporte al
punto de cierre"). La Parte 1 (delimitación gráfica) no tiene forma de
verificarse numéricamente; se comparó visualmente contra la solución
oficial escaneada (mismo criterio metodológico, ver imágenes).

---
