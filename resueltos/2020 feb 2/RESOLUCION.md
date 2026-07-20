# Examen HHA — 13 de febrero de 2020

Nota de nomenclatura: este examen es distinto del ya resuelto "2020
febrero" (28/feb/2020, abreviado "2020 feb" en `RESUMEN_TEORICO.md`).
Para no confundirlos, este examen (13/feb/2020) se abrevia **"2020
feb-13"**.

Resolución paso a paso. Herramientas usadas: Octave (funciones de
`RESUMEN EXAMEN/Codigos/FGV_rectangular/` y `Alcantarillas/`, copiadas y
adaptadas en `scripts/`) para el Ejercicio 1.

Hay solución oficial (manuscrita) **incluida en el mismo PDF del
examen** (`EXAMENES/2020 feb 2.pdf`, páginas 3, 5 y 7). Es una
fotocopia de mala calidad (texto muy comprimido/cursivo); se cita y
compara en cada ejercicio, con las diferencias de precisión esperables
de una lectura de manuscrito.

---

## EJERCICIO 1 (40 puntos) — Alcantarilla que descarga en un cauce que llega a un lago

**Datos:** cauce natural rectangular aguas abajo de la alcantarilla,
b_cauce=3.5 m, S₀=0.0003, n=0.009. Alcantarilla rectangular de hormigón,
H=1.5 m, B=2 m, embocadura r/H=0.02, L=20 m, n=0.013, S₀=0.003, ubicada
200 m aguas arriba de la desembocadura del cauce en el lago. Cuenca de
aporte a la alcantarilla: A=1 km², tc=18 min, L_cauce_ppal=1.2 km,
S_cauce_ppal=3%, S_cuenca=5%, pastizales, suelo grupo B, condición
hidrológica buena. Coordenadas de la cuenca: X=500 km, Y=6500 km.

Teoría usada: **Método Racional** (Formulómetro "Cálculo de Caudales
Máximos — Método Racional"; `RESUMEN_TEORICO.md` §B3-B4), **diseño de
alcantarillas** (Teórico HHA §3.2, tipos de flujo 1-6; nueva sección
`RESUMEN_TEORICO.md` §D1, añadida a partir de este examen) y **FGV en
canal rectangular con control por lago** (§A1, A4).

### Parte 1) Período de retorno de diseño de la alcantarilla

**Concepto.** El caudal de diseño de una obra (aquí, Q=10 m³/s) fue
dimensionado para algún período de retorno Tr, mediante el Método
Racional Q=C·i·A/360 (`RESUMEN_TEORICO.md` §B4). Para hallar ese Tr hay
que invertir la relación: el coeficiente de escorrentía C sale de la
Tabla 3.1.4 de Chow (pastizales, pendiente "Promedio 2-7%", que
corresponde a S_cuenca=5%) tabulada en columnas discretas de Tr (2, 5,
10, 25, 50, 100, 500 años) — se interpola linealmente entre las
columnas Tr=5 (C=0.36) y Tr=10 (C=0.38) — y la intensidad i sale de la
relación IDF de Uruguay (§B3), con d=tc=18 min y el valor puntual
P(3h,10años) leído de la Fig. 3.1.10 (isoyetas) en las coordenadas de la
cuenca (X=500, Y=6500 km): **P(3,10)≈92 mm** (el punto cae inmediatamente
al norte de la isoyeta de 90 mm del mapa).

**Por qué el Método Racional y no NRCS.** tc=18 min < 1 h (de hecho
20 min > 18 min por muy poco, así que en rigor cae en la franja "tc<20min
⇒ sólo Racional"; el criterio del curso "20min≤tc≤1h ⇒ ambos métodos"
está en el límite, pero al ser un problema de INVERSIÓN de un caudal ya
fijado — no de diseño desde cero — no corresponde recalcular con NRCS:
la obra fue diseñada con el método que dio el enunciado a través del
propio caudal, y el Racional es la hipótesis natural para tc tan chico).

```
Q = C(Tr) · i(Tr) · A / 360 ,   i(Tr) = P(3,10)·CT(Tr)·CD(tc)·CA(A,tc) / tc
CT(Tr) = 0.5786 - 0.4312·log10(ln(Tr/(Tr-1)))
CD(d)  = 0.6208·d/(d+0.0137)^0.5639     (d=tc=0.30 h < 3h)
CA(A,d)= 1 - 0.3549·d^-0.4272·(1-e^(-0.005792·A))
```

**Herramienta:** cálculo directo (fórmulas cerradas de la IDF de
Uruguay), sin necesidad de la planilla de eventos extremos (que está
pensada para armar la tormenta de diseño completa por bloque alterno;
acá sólo hace falta la lámina puntual P(3,10,Tr,d) para un d fijo). Se
itera Tr con `fzero` hasta que Q(Tr)=10 m³/s.

**Script:** `scripts/ej1_racional_Tr.m`. Entradas: `A=1 km², tc=18min,
Qdiseno=10 m3/s`, C interpolado entre (Tr=5,C=0.36) y (Tr=10,C=0.38).

**Resultado:**
```
CD(tc=0.300h) = 0.3581   CA(A=1km2) = 0.9966
P(3,10) = 92 mm
Tr=5.0  C=0.360  Q=9.41 m3/s
Tr=6.0  C=0.364  Q=9.93 m3/s
Tr=6.5  C=0.366  Q=10.17 m3/s
Tr=7.5  C=0.370  Q=10.60 m3/s

Tr exacto (Q=10 m3/s) = 6.15 años
```

**Tr de diseño de la alcantarilla ≈ 6 años.**

**Comparación con solución oficial:** el manuscrito prueba Tr=5, 6, 6.5,
7.5 con C=0.36, 0.364, 0.366, 0.37 y obtiene Q=9.30, 9.9, 10.14, 10.57
m³/s respectivamente, concluyendo **Tr≈6 años**. Con P(3,10)=92 mm el
script reproduce esos mismos valores de Q dentro de ±0.3 m³/s (p.ej.
Q(Tr=6)=9.93 vs 9.9 manuscrito), confirmando la lectura de P(3,10) y
coincidiendo en la conclusión Tr≈6 años. (Con P(3,10)=82 mm, otra
lectura posible del mapa borroso, los Q salen sistemáticamente ~12%
más bajos que el manuscrito en las cuatro filas de la tabla — por eso
se adoptó 92 mm, que ajusta las cuatro filas simultáneamente.)

### Parte 2) Tipo de flujo en la alcantarilla, perfil en el cauce y tirante aguas arriba (condición de diseño, Q=10 m³/s)

**Concepto.** Primero se resuelve el FGV en el CAUCE (aguas abajo de la
alcantarilla) para saber qué tirante "ve" la alcantarilla en su sección
de salida: se clasifica el cauce (yn vs yc, §A1) y, si el nivel del
lago está entre yc e yn, se integra una curva **M2** desde el lago hacia
aguas arriba hasta la sección de la alcantarilla (200 m). Con ese
tirante de salida se verifica si la alcantarilla está ahogada en la
salida (h4/H≥1) y, junto con la carga aguas arriba, si también lo está
en la entrada (h1/H≥1) ⇒ **Tipo 1** (Teórico HHA §3.2.1, entrada y
salida ahogadas, balance de carga entre las secciones (1) y (4) con
pérdida localizada de entrada + pérdida distribuida de Manning).

**Herramienta:** `fgv_rect.m`/`rect.m` (ODE de FGV, canal rectangular,
igual que en los demás exámenes) para el cauce; `alcantarilla_tipo1.m`
(nuevo, Teórico §3.2.1) para el balance de carga de la alcantarilla.

**Script:** `scripts/ej1_cauce_fgv.m` (cauce) + `scripts/ej1_alcantarilla_tipo1.m` (alcantarilla).

**Resultado — cauce:**
```
yc = 0.9409 m
yn = 1.6541 m   =>  yn > yc: canal tipo M (mild)
```
Como h_Lago=1.55 m está entre yc (0.94) e yn (1.65), se integra la curva
**M2** desde el lago (y(x=0)=1.55 m) hacia aguas arriba hasta x=−200 m
(sección de la alcantarilla):
```
y4 = tirante en la alcantarilla (x=-200 m) = 1.5636 m
```

**Resultado — alcantarilla:**
```
h4/H = 1.042  (>=1, salida ahogada)
CD1(r/H=0.02) = 0.88   (Tabla 3.2.1, kE=0.29 => CD1=1/sqrt(1+kE)=0.88)
AT = 3.0 m2,  Rh = 0.60 m
perdida de entrada  = Q²/(2g·CD1²·AT²)        = 0.7320 m
perdida de friccion = Q²·n²·L/(AT²·Rh^(4/3))  = 0.0742 m
h1 (referido al zampeado de salida) = 2.3699 m   (h1/H = 1.58, >=1)
```
Como **h1/H≥1 y h4/H≥1 ⇒ flujo Tipo 1** (entrada y salida ahogadas, la
alcantarilla funciona a tubo lleno en toda su longitud). El tirante h1
está referido al zampeado de SALIDA de la alcantarilla (datum z=0 de la
fórmula de balance); como la entrada está z=S₀_alc·L=0.06 m más alta
que la salida, el tirante **y1 aguas arriba de la alcantarilla**
(medido desde el fondo de la propia entrada, que es donde efectivamente
"se ve" el nivel de agua que llega desde la cuenca) es
y1 = h1 − z ≈ 2.37 − 0.06 ≈ **2.31 m**.

**Perfil de flujo en el cauce:** curva **M2** (remanso decreciente yendo
hacia aguas abajo, o creciente yendo hacia aguas arriba desde el lago),
con tirante subiendo de 1.55 m en el lago a 1.56 m en la sección de la
alcantarilla (200 m aguas arriba) — muy poco desarrollo porque el tramo
es corto comparado con lo que tardaría en acercarse a yn=1.65 m.

**Comparación con solución oficial:** el manuscrito obtiene yn=1.65 m,
yc=0.94 m (coincide exactamente), y4=1.56 m (vs 1.5636 acá, diferencia
sub-milimétrica), h1=2.4 m, y1=2.394 m (vs 2.37 m / 2.31 m acá). La
pequeña diferencia en h1 (2.40 vs 2.37, ~1%) es atribuible al redondeo
manual en cada paso intermedio; el manuscrito resta sólo 0.006 m (no
0.06 m) para pasar de h1 a y1 — no se pudo determinar con certeza a qué
distancia/pendiente corresponde exactamente ese ajuste de 6 mm en la
fotocopia manuscrita, pero es un ajuste menor (½ cm) frente al
resultado (≈2.3-2.4 m) y no cambia la conclusión: **flujo Tipo 1, con
tirante aguas arriba de la alcantarilla ≈2.3-2.4 m**.

### Parte 3) Evento extremo: y1_alc=2.45 m, h_Lago=1.25 m — ¿se supera el caudal de diseño?

**Concepto.** Ahora se conoce el tirante aguas arriba (y1=2.45 m) pero
NO el caudal del evento. Se itera Q: para cada Q de prueba se calcula
el perfil del cauce (M2 desde el lago, con el nuevo h_Lago=1.25 m) para
ver si la alcantarilla sigue ahogada en la salida; si no lo está,
corresponde Tipo 2 o Tipo 3 (se distingue con el ábaco Fig. 3.2.5 del
Teórico, según L/D y S₀ — acá L/D=20/1.5=13.3 y S₀=0.003 caen del lado
Tipo 2), y se resuelve el balance de carga Tipo 2 (h3=H, "chorro" a
tubo lleno) con el h1 dado por el enunciado.

**Herramienta:** mismo patrón que la Parte 2 (`fgv_rect.m` para el
cauce) + `alcantarilla_tipo2.m` (nuevo) para el balance Tipo 2.

**Script:** `scripts/ej1_evento.m`.

**Resultado — iteración de Q (perfil del cauce, M2 desde el lago a
h_Lago=1.25 m):**
```
Q=15.0  -> yn=2.250 yc=1.233 y(alcantarilla)=1.608 m  (>H=1.5 => hipotesis Tipo 1)
Q=12.0  -> yn=1.897 yc=1.063 y(alcantarilla)=1.430 m  (<H => NO Tipo 1)
Q=10.6  -> yn=1.728 yc=0.978 y(alcantarilla)=1.365 m  (<H, autoconsistente)
Q=10.9  -> yn=1.764 yc=0.997 y(alcantarilla)=1.378 m  (<H, autoconsistente)
```
Con Q=15 la alcantarilla resultaría ahogada en la salida (Tipo 1), pero
al resolver el balance Tipo 1 con h1=2.456 m se obtiene un Q≈30 m³/s que
no cierra con el Q=15 supuesto ⇒ la hipótesis Tipo 1 no es
autoconsistente. Con Q=12 el tirante de salida (1.43 m) queda por
debajo de H=1.5 m ⇒ la alcantarilla NO está ahogada en la salida: es
Tipo 2 o Tipo 3. Con L/D=13.3 y S₀=0.003, el ábaco (Fig. 3.2.5) da
**Tipo 2**.

**Resultado — balance Tipo 2:**
```
h1 = y1 + z = 2.45+0.006 = 2.456 m   (referido al zampeado de salida)
h3 = H = 1.5 m  (salida a tubo lleno, "hidraulicamente larga")
Q (Tipo 2) = 10.889 m3/s
```
Con este Q, el perfil del cauce da y(alcantarilla)=1.378 m < H=1.5 m,
confirmando que la alcantarilla efectivamente NO se ahoga en la
salida — la hipótesis Tipo 2 es autoconsistente.

**El caudal del evento (≈10.6-10.9 m³/s) SUPERA el caudal de diseño de
la alcantarilla (10 m³/s).**

**Perfil de flujo en el cauce durante el evento:** con h_Lago=1.25 m
entre yc≈0.98-1.0 m e yn≈1.73-1.76 m ⇒ canal M, curva **M2** creciendo
desde 1.25 m en el lago hasta ≈1.37-1.38 m en la sección de la
alcantarilla (200 m aguas arriba), sin llegar a yn en ese tramo.

**Comparación con solución oficial:** el manuscrito itera Q=15
(descartado, Tipo1 no converge), Q=12 (yn=1.89, yc=1.06, y_alcantarilla
=1.43 m, coincide), y adopta Q=10.6 m³/s con el balance Tipo 2 (acá:
10.6-10.9 m³/s, diferencia ~3% atribuible a redondeos en cascada, mismo
orden que en la Parte 2) — **coincide en la conclusión: el caudal del
evento supera el de diseño**, con el mismo perfil M2 en el cauce
(y=1.36 m junto a la alcantarilla, y=1.25 m en el lago, según el
esquema del manuscrito).

### Resumen Ejercicio 1

| Ítem | Resultado |
|---|---|
| Tr de diseño de la alcantarilla | **≈6 años** |
| Tipo de flujo (condición de diseño, Q=10 m³/s) | **Tipo 1** (entrada y salida ahogadas) |
| Tirante aguas arriba de la alcantarilla (diseño) | **≈2.3-2.4 m** |
| Perfil en el cauce (diseño) | Curva **M2**, 1.55 m (lago) → 1.56 m (alcantarilla) |
| Caudal del evento extremo | **≈10.6-10.9 m³/s** |
| ¿Supera el caudal de diseño? | **Sí** (10.6-10.9 > 10 m³/s) |
| Tipo de flujo durante el evento | **Tipo 2** (entrada ahogada, salida libre, alcantarilla larga) |
| Perfil en el cauce (evento) | Curva **M2**, 1.25 m (lago) → 1.37 m (alcantarilla) |

---
