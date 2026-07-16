# Examen HHA — 3 de febrero de 2026

Resolución paso a paso. Herramientas usadas: Octave (scripts de la carpeta
`Scripts/01_SCRIPTS/FGV_felo`, copiados y adaptados en `scripts/`) y, para el
Ejercicio 2, la planilla `Eventos extremos.xlsx`.

Los scripts de Octave del Ejercicio 1 deben ejecutarse en orden
(`ej1_parte1.m` genera `part1.mat`, que usan `ej1_parte2.m` y `ej1_plot.m`;
`ej1_parte2.m` genera `part2.mat`, que usa `ej1_plot.m`; `ej1_parte3.m` sólo
necesita `part1.mat`). Los archivos `.mat` intermedios no se versionan.

Hay solución oficial (manuscrita) para los Ejercicios 1 y 4 en
`EXAMENES/2026 Febrero/SolEjercicios1y4.pdf`, y soluciones separadas para el
Ejercicio 2 y 3 (`... - Ej2 - solucion.pdf`, `... - Ej3 - solucion.pdf`,
`... - Cuenca - Solucion.pdf`). Se citan diferencias cuando corresponde.

---

## EJERCICIO 1 — Canal trapezoidal entre un lago y una caída libre, con compuerta de fondo

**Datos:** b = 5.5 m, m = 1 (talud 1V:1H), n = 0.012, S₀ = 0.001, L = 4000 m,
h_LA = 1.5 m (nivel del Lago A sobre el fondo del canal en x=0). El canal
termina en una caída libre en x = L.

Teoría usada: clasificación de canales en FGV (Teórico HHA §2.5.2), perfiles
de flujo en FGV (§2.5.3), perfiles de flujo entre dos lagos (§2.5.4), perfil en
un canal entre dos lagos con compuerta de fondo (§2.5.5), energía específica
(§2.2), cantidad de movimiento y resalto hidráulico (§2.3.2–2.3.3).

### Parte 1) Caudal de descarga del lago, clasificación M/S y perfil

**Concepto.** El lago actúa como un embalse de nivel constante h_LA sobre el
fondo del canal. En una entrada ideal (sin pérdidas), la energía específica
del flujo justo aguas abajo de la entrada iguala el nivel del lago:
E(x=0) = h_LA. Como el canal es muy largo (4000 m) frente a la longitud típica
de las curvas de remanso/abatimiento de FGV, se supone —y luego se verifica
numéricamente— que el tirante en la entrada es aproximadamente el tirante
normal y_n (el canal "olvida" rápidamente la condición de entrada y se
acomoda al flujo uniforme). Esto da un sistema de 2 ecuaciones (energía +
Manning) con 2 incógnitas (Q, y_n):

```
h_LA = y_n + (Q/A(y_n))² / (2g)
Q = (1/n)·A(y_n)·R(y_n)^(2/3)·S₀^(1/2)
```

**Herramienta:** función `caudal_M_ini.m` (carpeta `FGV_felo`), que resuelve
exactamente este sistema con `fsolve` para sección trapezoidal, y
`tirantes_yn_yc.m` para obtener y_c. Se eligió esta función porque está
pensada específicamente para el caso "canal tipo M alimentado por un lago" y
evita tener que programar el sistema de ecuaciones a mano.

**Script:** `scripts/ej1_parte1.m`. Entradas: `b=5.5, m=1, n=0.012, S0=0.001,
hLA=1.5`.

**Resultado:**
```
Q  = 19.5941 m3/s
yn = 1.1924 m
yc = 1.0214 m
```
Como y_n > y_c ⇒ **el canal es de tipo M (mild / pendiente suave)**.

**Verificación numérica de la hipótesis "y(x=0) ≈ y_n":** se integró la
ecuación diferencial de FGV (función `rect.m`, que a pesar del nombre usa
`trap_geom.m` y por lo tanto sirve para sección trapezoidal) desde la caída
libre (x=4000, y=y_c, condición de control por caída libre) hacia aguas
arriba, usando `ode23` con el evento `critico.m` como resguardo. Resultado:
y(x=0) = 1.1923 m (diferencia relativa con y_n: **0.011 %**), y la energía
específica en x=0 resulta E = 1.4999 m ≈ h_LA = 1.5 m. Además, la curva sólo
se aparta más de 1 % de y_n a partir de x ≈ 3832 m, es decir el tramo de
abatimiento (curva M2) real tiene un largo de apenas ~170 m sobre los 4000 m
totales del canal. Esto confirma que la hipótesis usada por `caudal_M_ini.m`
es prácticamente exacta en este caso.

**Perfil de la superficie libre (x medido desde el lago):**
- x = 0 a x ≈ 3830 m: tirante prácticamente constante e igual a y_n = 1.19 m
  (flujo uniforme, subcrítico).
- x ≈ 3830 m a x = 4000 m: curva de descenso M2, el tirante decrece
  suavemente desde y_n hasta y_c = 1.02 m justo en el borde de la caída libre
  (sección de control por caída libre, Teórico §2.2.6).
- **No hay resaltos hidráulicos** en este perfil (todo el escurrimiento es
  subcrítico, sin transición a supercrítico).

**Resultado final Parte 1: Q = 19.59 m³/s, y_n = 1.19 m, y_c = 1.02 m, canal tipo M.**

**Comparación con solución oficial:** el manuscrito da Q=19,59 m³/s, y_n=1,18 m,
y_c=1,02 m, canal M, curva M2 hasta la caída — coincide con el cálculo (la
diferencia de 0.01 m en y_n es redondeo manual).

### Parte 2) Compuerta de fondo ideal en x = 3200 m (800 m antes de la caída), a = 0.8 m

**Concepto.** Con a < y_c la compuerta controla el escurrimiento (Teórico
§2.5.5, caso "abertura de compuerta menor al tirante crítico"). Al ser una
compuerta ideal (sin pérdida de energía ni contracción de vena), el tirante
inmediatamente aguas abajo es y_B = a, y por conservación de energía
específica el tirante inmediatamente aguas arriba y_A es el **tirante alterno**
de y_B para el mismo Q (rama subcrítica).

**Herramienta:** `Eesp_trap.m` (energía específica y alterno rectangular
como estimación inicial) + `alternos_trap.m` (alterno trapezoidal exacto vía
`fsolve`), y de nuevo `rect.m`/`ode23` para las curvas de FGV, y `Mom_trap.m`
(cantidad de movimiento y conjugado) para el chequeo de ahogamiento y la
ubicación del resalto. Se usan estas funciones porque calculan exactamente
las cantidades (alterno, conjugado) que la teoría del curso requiere para
este tipo de problema (§2.3.2, §2.3.3, §2.5.5).

**Script:** `scripts/ej1_parte2.m`.

**Aguas arriba de la compuerta:**
- y_B = a = 0.80 m ⇒ E_compuerta = 1.5711 m
- y_A (alterno subcrítico) = **1.3365 m**, y como y_A > y_n ⇒ se forma una
  **curva M1** (remanso) entre la compuerta y el Lago A.
- Se integró la M1 desde x=3200 (y=y_A) hacia x=0: y(x=0) = 1.1924 m
  ≈ y_n, con E(x=0) = 1.5000 m = h_LA. Es decir, al ser el tramo aguas
  arriba de la compuerta muy largo (3200 m), la curva M1 se relaja a y_n
  mucho antes de llegar al lago, por lo que **el caudal no cambia: Q = 19.59
  m³/s** (no hace falta iterar el caudal, a diferencia del procedimiento
  general del Teórico §2.5.5 para el caso de dos lagos).

**Chequeo de descarga libre vs. ahogada (Teórico §2.5.5):**
- Se calculó a* = conjugado de a=0.8 m (rama subcrítica del resalto) con
  `Mom_trap.m`: **a\* = 1.2748 m** (verificado a mano: M(0.8)=9.70 m³ =
  M(1.2748)).
- Se evaluó la curva M2 que llega desde la caída libre (calculada en la
  Parte 1) en x = 3200 m: **y_M2(3200) = 1.1925 m** (≈ y_n, consistente con
  que a 3200 m de la caída el perfil todavía no se apartó de y_n).
- Como a* (1.27 m) > y_M2(3200) (1.19 m) ⇒ **la descarga de la compuerta es
  LIBRE**.

**Curva M3 y resalto hidráulico:** con descarga libre se forma una curva M3
(supercrítica, creciente) aguas abajo de la compuerta, que debe compatibilizar
con la curva M2 que llega desde la caída mediante un resalto hidráulico. Se
integró la M3 desde x=3200 (y=a=0.80 m) hacia aguas abajo, y en cada punto se
calculó el conjugado (búsqueda por bisección sobre la función momentum,
`momentum_trap`) comparándolo con el valor de la curva M2 en el mismo x
(interpolando el perfil de la Parte 1). El cruce da la posición del resalto:

```
Resalto en x = 3225.3 m  (25.3 m aguas abajo de la compuerta)
y1 (antes del resalto, rama M3, supercrítico)  = 0.8662 m
y2 (después del resalto, rama M2, subcrítico)  = 1.1924 m  (≈ yn)
```

**Perfil completo con compuerta:**
- x=0 a x≈3200 m: tirante ≈ y_n = 1.19 m (uniforme), subiendo a curva M1 en
  el último tramo antes de la compuerta hasta y_A = 1.34 m justo aguas
  arriba de la compuerta.
- Compuerta en x=3200 m: caída brusca de tirante de 1.34 m a 0.80 m.
- x=3200 a x≈3225 m: curva M3 (supercrítica), tirante sube de 0.80 a 0.87 m.
- **Resalto hidráulico en x≈3225 m** (25 m aguas abajo de la compuerta):
  salto de 0.87 m a 1.19 m.
- x≈3225 a x≈3830 m: tirante ≈ y_n = 1.19 m (uniforme, subcrítico).
- x≈3830 a x=4000 m (caída libre): curva M2, tirante decrece de y_n a
  y_c = 1.02 m.

Gráfico de ambos perfiles (sin y con compuerta): `scripts/ej1_perfil.png`.

**Resultado final Parte 2: descarga LIBRE, Q = 19.59 m³/s (sin cambios),
resalto hidráulico ubicado 25 m aguas abajo de la compuerta, entre y=0.87 m
y y=1.19 m.**

**Comparación con solución oficial:** el manuscrito indica descarga libre,
resalto ubicado a x_rel=25,5 m de la compuerta con tirantes 0,86 m antes del
resalto y ~y_n después — **coincide muy bien** con los valores calculados
(25.3 m, 0.866 m). El valor manuscrito del conjugado de la compuerta (a*) es
difícil de leer con certeza en el escaneo; el valor obtenido y verificado a
mano (a*=1.27 m) es consistente con la conclusión de descarga libre en
cualquier caso.

### Parte 3) Mínima abertura de compuerta para que el tirante no supere 1.8 m a 500 m aguas arriba de la compuerta

**Concepto.** El punto de control está en x = 3200 − 500 = 2700 m. Cuanto
menor es la abertura a de la compuerta, mayor es el remanso (curva M1) aguas
arriba, y por lo tanto mayor el tirante en cualquier punto aguas arriba de
ella. Al aumentar a (siempre con a<y_c), el tirante alterno y_A en la
compuerta decrece monótonamente hacia y_c (caso límite a→y_c, donde la
compuerta deja de tener efecto). Se busca entonces la **mínima** abertura a
tal que el tirante en x=2700 m sea exactamente 1.8 m (condición límite); para
cualquier a mayor la condición se sigue cumpliendo con margen.

**Herramienta:** se reutilizan `Eesp_trap.m`, `alternos_trap.m` y la
integración de la curva M1 con `rect.m`/`ode23` del punto anterior, dentro de
una búsqueda de raíz (`fzero` de Octave) sobre la abertura a.

**Script:** `scripts/ej1_parte3.m`.

**Situación actual (a=0.8 m, Parte 2):** tirante en x=2700 m = **1.2009 m**,
que cumple holgadamente la condición (≤1.8 m).

**Búsqueda de la abertura mínima:** se definió f(a) = y_M1(x=2700; a) − 1.8 y
se resolvió f(a)=0 con `fzero` en el intervalo (0.05 m, y_c). Resultado:

```
a = 0.5478 m  ≈ 0.55 m
Tirante en la compuerta para este caso límite (alterno de a) = 2.2694 m
Verificación: tirante en x=2700 m = 1.8000 m  ✓
```

**Resultado final Parte 3: la mínima abertura de compuerta que evita superar
1.80 m a 500 m aguas arriba de la compuerta es a ≈ 0.55 m (0.5478 m).**

**Comparación con solución oficial:** el manuscrito da y en la compuerta =
2,27 m (caso límite) y a = 0,547 m ≈ 0,55 m — **coincide de forma casi
exacta** con el resultado obtenido (2.2694 m y 0.5478 m).

### Resumen Ejercicio 1

| Ítem | Resultado |
|---|---|
| Q (sin compuerta) | **19.59 m³/s** |
| y_n | **1.19 m** |
| y_c | **1.02 m** |
| Tipo de canal | **M (mild)** |
| Descarga de la compuerta (a=0.8 m) | **Libre** |
| Posición del resalto | **25 m aguas abajo de la compuerta** |
| Tirantes del resalto | **0.87 m → 1.19 m** |
| Abertura mínima para y≤1.8 m a 500 m antes de la compuerta | **a ≈ 0.55 m** |

Los tres resultados numéricos coinciden con la solución oficial manuscrita
dentro del margen esperable de redondeo manual.

---

## EJERCICIO 2 — Alcantarilla en cuenca de Artigas: caudal de diseño y verificación con evento observado

**Datos (Tabla 1):** Área = 8.9 km², ΔH = 80 m, L = 3715 m (cauce principal), Grupo
Hidrológico D, S = 5.7 % (pendiente media de la cuenca). Punto de cierre en
X=460 km, Y=6620 km (departamento de Artigas). Uso de suelo: pastizales, condición
hidrológica buena. Flujo concentrado.

Teoría usada: metodologías de caudal máximo en cuencas no aforadas — Método
Racional y Método NRCS (Teórico HHA §3.1.5), curvas IDF de Uruguay y corrección
por área/duración/período de retorno (§3.1.4), tiempo de concentración de
Ramser-Kirpich (§3.1.2), método del Número de Curva NRCS y clasificación AMC
(§3.1.5 b), hidrograma unitario sintético triangular SCS (§3.1.5 c).

**Aprendizaje previo de la herramienta:** antes de resolver, se abrió
`Scripts/01_SCRIPTS/Scripts examen AA/EVENTOS EXTREMOS 2025.xlsx` con
`openpyxl` (Python) para relevar sus hojas y fórmulas: `método racional` (fórmulas
IDF de Uruguay CT/CD/CA y Q=C·i·A/360), `NRCS - Gande`/`NRCS - Chica` (tormenta de
diseño por bloque alterno + precipitación efectiva por Número de Curva +
hidrograma unitario triangular SCS) y `EJ 2` (el mismo método NC aplicado a un
hietograma observado). Se replicaron exactamente estas fórmulas en Python
(`ej2_parte1.py`, `ej2_parte2.py`) porque en este entorno no se dispone de
Excel/LibreOffice con recálculo interactivo (se probó `soffice --headless`, pero
falla en este sandbox); la planilla original con los datos de este examen cargados
se guarda de todas formas como referencia en
`scripts/ej2_EventosExtremos_datos.xlsx`. Los resultados de Python se
verificaron contra la solución oficial manuscrita y coinciden en todos los
valores (ver comparaciones al final de cada parte).

### Parte 1) Caudal máximo de diseño (Tr = 10 años)

**Tiempo de concentración (Ramser-Kirpich, Teórico §3.1.2):**
```
tc = 0.4·L^0.77 / S^0.385      L en km, S en % (pendiente DEL CAUCE PRINCIPAL)
```
**Concepto clave:** la tabla del enunciado da dos pendientes distintas con
propósitos distintos: S=5.7 % es la *pendiente media de la cuenca* (se usa para
elegir la fila de la tabla de coeficientes de escorrentía del método racional),
mientras que Kirpich necesita la *pendiente del cauce principal*, que se calcula
con los otros dos datos de la tabla: S_cauce = ΔH(m)/L(km)/10 = 80/3.715/10 =
**2.153 %**. Con L=3.715 km:

**tc = 0.818 hs = 49.1 min.**

Como 20 min < tc < 1 h, el Teórico (§3.1.5) indica que ninguno de los dos métodos
es claramente el adecuado y recomienda **calcular ambos y diseñar con el mayor
caudal**.

**Herramienta:** se implementó en Python (`scripts/ej2_parte1.py`) la réplica
exacta de las hojas `método racional` y `NRCS - Gande` de la planilla de eventos
extremos: (a) fórmulas IDF de Uruguay P(d,Tr,p)=P₃,₁₀,ₚ·CT(Tr)·CD(d)·CA(d,Ac); (b)
método racional Q=C·i·A/360; (c) método NRCS completo (tormenta de diseño por
bloque alterno con Δt=tc/7 en 12 bloques, precipitación efectiva por Número de
Curva con corrección de piso de infiltración según grupo hidrológico, e
hidrograma unitario triangular sintético SCS con Tp=tr/2+0.6tc,
Tb=2.667Tp, qp=2.08·A/Tp, convolucionado con los 12 pulsos de lluvia efectiva).
Se usó esta herramienta (en vez de programar todo a mano) porque es exactamente
la que provee el curso para este tipo de problema y automatiza correctamente el
bloque alterno y la convolución, que son tediosos y propensos a error a mano.

**P₃,₁₀,ₚ (precipitación de 3 h y Tr=10 años en el punto):** se leyó de la
Figura 3.1.10 del Teórico (isoyetas de lluvias extremas de Uruguay, líneas cada
2 mm) en las coordenadas X=460 km, Y=6620 km. Se calibraron los ejes del mapa
píxel a píxel (bordes del recuadro en X=200..800 km, Y=6100..6700 km) y se contó
el número de isoyetas entre la curva "90" (que pasa cerca de la frontera con
Brasil, más al sur) y el punto pedido: el punto cae prácticamente sobre la 4ª
isoyeta por encima de la de 90 mm ⇒ **P₃,₁₀,ₚ ≈ 98 mm** (imagen guardada en
`scripts/ej2_isoyeta_P310.png`).

**NC (pastizales, condición hidrológica buena, grupo D):** de la Tabla/Figura
3.1.20 del Teórico (fila "Pradera o pastizal", columna "Buena", grupo D) ⇒
**NC = 80**.

**C (coeficiente de escorrentía, método racional):** de la Tabla 3.1.4
(Pastizales, pendiente "Promedio 2-7 %" — con la S=5.7% de la cuenca —, Tr=10
años) ⇒ **C = 0.38**.

**Resultados (`ej2_parte1.py`):**
```
tc = 0.8178 hs = 49.07 min      CT(Tr=10) = 1.0000  (por definición, Tr=10 es la base)

MÉTODO RACIONAL:
  d = tc = 0.818 hs ; CD = 0.5634 ; CA = 0.9806
  P(d,10,p) = 54.14 mm ; i = 66.20 mm/h
  Qmax racional = 62.19 m³/s

MÉTODO NRCS:
  Tormenta de diseño (bloque alterno, Δt=tc/7=7.01 min, 12 bloques): pico
  central de 21.41 mm, total 69.03 mm en 84.1 min.
  S = 63.5 mm ; Ia = 12.7 mm (NC=80)
  Precipitación efectiva total (corregida) = 26.48 mm
  Hidrograma unitario triangular: tr=0.1168 hs, Tp=0.5491 hs, Tb=1.4645 hs,
  qp=33.71 m³/s/cm
  Qmax NRCS = 66.28 m³/s (en t=1.37 hs desde el inicio de la tormenta)
```

**Se adopta el mayor: caudal de diseño Q₁₀ = 66.3 m³/s (método NRCS).**

**Comparación con solución oficial:** el manuscrito da P(3,10)=98 mm, NC=80,
Tc=0.82 hs=49 min, C=0.38, Qrac=62.2 m³/s, Qnrcs=66.3 m³/s ("me quedo nrcs") —
**coincide exactamente** con todos los valores calculados.

### Parte 2) Evento de precipitación observado

**Datos:** hietograma en bloques de 7 min (mismo Δt que el hidrograma unitario
de la Parte 1): P(mm) = 1,3,7,10,12,24,10,8,5,3,1,1 (bloque máximo 24 mm entre
minuto 35 y 42). Evento en enero (estación de crecimiento), precipitación
acumulada 5 días previos = 38 mm.

**Herramienta:** se reutilizan las mismas funciones IDF de la Parte 1
(`ej2_parte2.py`) para 2.1, y el mismo método NC + hidrograma unitario
triangular SCS de la Parte 1 para 2.2, aplicados ahora al hietograma
*observado* (en su orden cronológico real, sin reordenar por bloque alterno,
ya que ésa es la tormenta efectivamente ocurrida).

#### 2.1) Período de retorno de la intensidad máxima del evento

**Concepto:** la intensidad promedio es máxima para la menor duración posible
que contenga el pico; con datos en bloques fijos de 7 min, el bloque de 24 mm
(35-42 min) da la mayor intensidad media (205.7 mm/h) de cualquier ventana
(ventanas más largas diluyen el promedio). Se usa CA=1 porque el dato es de un
pluviómetro puntual de la cuenca, no una lluvia de diseño de área.

**Desarrollo:** con d=7 min=0.1167 hs, CD(d)=0.2285, y P(d,Tr,p)=24 mm:
```
CT(Tr) = 24 / (98 · 0.2285 · 1) = 1.0718
```
Invirtiendo CT(Tr)=0.5786-0.4312·log₁₀(ln(Tr/(Tr-1))) numéricamente (bisección):

**Tr = 14.4 años.** (Verificación: Tr=14 años → P=23.87 mm; Tr=15 años →
P=24.17 mm, consistente con interpolar a Tr≈14.4 para P=24 mm.)

**Comparación con solución oficial:** el manuscrito itera entre Tr=14 años
(P=23.9 mm) y Tr=15 años (P=24.2 mm) — **coincide** con el cálculo (Tr≈14.4 años
cae exactamente en ese rango).

#### 2.2) Caudal máximo durante el evento

**Concepto — condición de humedad antecedente (AMC):** el NRCS clasifica la
humedad antecedente según la precipitación de los 5 días previos y la estación
(Teórico, Fig. 3.1.21). Enero es estación de crecimiento en Uruguay, donde el
rango de AMC II (condición media, sin corregir el NC) es 35.6–53.3 mm (1.4–2.1
pulgadas). Como P₅d=38 mm cae dentro de ese rango ⇒ **AMC II ⇒ se usa NC=80 sin
corregir** (no hace falta aplicar las fórmulas de NC(I)/NC(III)).

**Desarrollo:** con S=63.5 mm e Ia=12.7 mm (iguales a la Parte 1, mismo NC), se
aplicó el método NC de forma incremental sobre la precipitación acumulada real
del evento, con la misma corrección de piso de infiltración (1.2 mm/h, grupo D)
de la Parte 1. La precipitación efectiva total resulta 38.49 mm (bloque pico:
13.29 mm efectivos en el intervalo de 24 mm). Se convolucionó con el mismo
hidrograma unitario triangular de la Parte 1 (misma cuenca ⇒ mismo tc, Tp, Tb,
qp).

**Qmax evento = 99.95 m³/s ≈ 100 m³/s**, en t≈1.26 hs desde el inicio del
evento.

**Comparación con solución oficial:** el manuscrito indica "condiciones medias"
(AMC II) y Qmax=100 m³/s (NRCS) — **coincide** con el cálculo (99.95 m³/s).

#### 2.3) ¿Se superó la condición de diseño? ¿Durante cuánto tiempo?

**Concepto:** se compara el hidrograma del evento observado (2.2) con la
capacidad de diseño de la alcantarilla (Q₁₀=66.28 m³/s, Parte 1) y se mide el
intervalo de tiempo en que el caudal generado supera esa capacidad.

**Desarrollo:** del hidrograma de 2.2, Q(t) > 66.28 m³/s entre t=0.99 hs y
t=1.69 hs (desde el inicio del evento).

**Sí, la condición de diseño se vio sobrepasada, entre t≈0.99 h y t≈1.69 h,
durante T ≈ 0.70 hs ≈ 42 min.**

**Comparación con solución oficial:** el manuscrito da Tini=0.98 hs,
Tfin=1.70 hs, T=0.72 hs=43 min — **coincide muy bien** con el cálculo (0.99 h,
1.69 h, 42.1 min); la pequeña diferencia (~1 min) es esperable por redondeo
manual e interpolación gráfica en el hidrograma.

### Resumen Ejercicio 2

| Ítem | Resultado |
|---|---|
| tc | **49.1 min** |
| P₃,₁₀,ₚ (Artigas, isoyetas) | **98 mm** |
| NC (pastizales, buena, D) | **80** |
| Q racional (Tr=10) | **62.2 m³/s** |
| Q NRCS (Tr=10) — adoptado | **66.3 m³/s** |
| Tr de la intensidad máxima del evento | **14.4 años** |
| AMC del evento | **II (medio)** |
| Qmax durante el evento | **100 m³/s** |
| ¿Se supera la obra? | **Sí, ≈42 min (t=0.99 a 1.69 hs)** |

Todos los resultados numéricos coinciden con la solución oficial manuscrita.

---

*(Ejercicios 3 y 4 pendientes — se continuará en la próxima corrida.)*

ESTADO: EN CURSO
