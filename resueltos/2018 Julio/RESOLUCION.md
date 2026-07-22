# Examen HHA — 23 de julio de 2018

Resolución paso a paso. Herramientas usadas: Octave (funciones de
`RESUMEN EXAMEN/Codigos/FGV_trapezoidal/`, copiadas a este directorio)
para el Ejercicio 1.

El PDF del examen (`EXAMENES/2018 Julio.pdf`) trae la letra completa en
las páginas 1-2 (texto legible, extraído con PyMuPDF) y una solución
oficial manuscrita en las páginas 3-7, mucho más degradada/con letra
difícil (fotos rotadas, texto cursivo). Se intenta comparar cuando se
puede reconocer algo con confianza; si no, se documenta la limitación.

---

## EJERCICIO 1 (25 puntos) — Canal trapezoidal de largo infinito, compuerta ideal, tensión rasante

**Enunciado (resumen):** canal trapezoidal (b=6 m, m=1H:1V) de largo
infinito, Q=10 m³/s, S0=0.0008, n=0.015.
1) Clasificar el canal.
2) Se coloca una compuerta de fondo ideal de abertura *a* en una sección
   cualquiera. Hallar la abertura mínima *a* tal que la tensión rasante
   (de corte de fondo) inmediatamente aguas abajo de la compuerta no
   supere 65 Pa.
3) Con la compuerta fija en esa abertura, dibujar el perfil de la
   superficie libre (tirantes de interés, resaltos si los hay).
4) Calcular la fuerza que ejerce el flujo sobre la compuerta.

Teoría usada: ecuación de Manning y tirante crítico para clasificar el
canal (§A1, §A2), tensión rasante de fondo en FGV τ0(y)=γ·Rh·Sf (§A6,
variante "abertura mínima de compuerta por tensión rasante admisible",
añadida a partir de este examen), compuerta de fondo ideal en canal
infinito con Q fijo (§A5, variante añadida a partir de este examen),
cantidad de movimiento y fuerza sobre una compuerta (§A3). Ver
`RESUMEN EXAMEN/Teorico/RESUMEN_TEORICO.md`.

### Parte 1) Clasificación del canal

**Concepto.** El canal es "de largo infinito" y transporta un caudal
Q=10 m³/s fijo (dato del problema, no depende de ningún control). Se
clasifica comparando el tirante normal yn (Manning, con la pendiente y
rugosidad reales del canal) contra el tirante crítico yc (geometría y Q,
independiente de la pendiente): yn>yc ⇒ pendiente suave (canal tipo M,
subcrítico en flujo uniforme); yn<yc ⇒ pendiente fuerte (tipo S).

**Por qué esta herramienta.** Es el caso base de §A1: sólo hace falta
resolver Manning (yn) y Froude=1 (yc) para un canal trapezoidal, sin
integrar ninguna EDO todavía.

**Script:** `Ejercicio1_canal_compuerta_rasante.m`, sección "PARTE 1"
(usa `tirantes_yn_yc.m`, que a su vez llama a `eq_yn.m`/`eq_yc.m` y
`trap_geom.m`). Entradas: Q=10, b=6, m=1, S0=0.0008, n=0.015.

**Resultado:**
```
yn = 0.9298 m
yc = 0.6333 m
```
Como yn > yc ⇒ **canal de pendiente suave (tipo M, flujo subcrítico en
régimen uniforme)**.

### Parte 2) Abertura mínima de la compuerta por tensión rasante ≤ 65 Pa

**Concepto.** Inmediatamente aguas abajo de una compuerta de fondo ideal
de abertura *a*, el tirante es yB=a (vena contraída, sin pérdida por
definición de "compuerta ideal"). En esa sección, aunque el flujo no sea
uniforme, la tensión de corte de fondo se calcula con la misma fórmula
de flujo gradualmente variado τ0(y)=γ·Rh(y)·Sf(y), con Sf(y) la pendiente
de energía de Manning evaluada con el Q real y la geometría de esa
sección (§A6). Como τ0 es **decreciente** en y (a menor tirante, mayor
velocidad, mayor Sf), existe una única abertura a_min para la cual
τ0(a_min)=65 Pa exactamente: cualquier abertura **menor** da más tensión
que la admisible (peligro de erosión del lecho/revestimiento aguas abajo
de la compuerta), así que la abertura mínima admisible es esa a_min.

**Por qué esta herramienta.** Es exactamente el caso de `rasante_max.m`
(ya usado en 2025 feb 1), aplicado aquí no sobre un perfil de FGV ya
calculado sino directamente sobre el tirante conocido yB=a de la vena
contraída — no hace falta integrar ninguna EDO para esta parte, porque
el canal es infinito y no hay ningún otro control que fije el punto
exacto donde τ0=65 Pa salvo la propia compuerta.

**Script:** `Ejercicio1_canal_compuerta_rasante.m`, sección "PARTE 2".

**Resultado:**
```
a_min = 0.3509 m
tau(a_min) = 65.000 Pa  (verificado)
a_min = 0.3509 m < yc = 0.6333 m  -> descarga supercrítica, consistente
```

**Verificación cruzada de la fórmula de τ0:** se comprobó que
τ0(yn)=5.854 Pa coincide exactamente con γ·Rh(yn)·S0=5.854 Pa (la
tensión de flujo uniforme, donde Sf=S0 por definición) — confirma que
`tau_fun` está bien planteada.

**Abertura mínima = 0.351 m.**

### Parte 3) Perfil de la superficie libre con la compuerta fija en a_min

**Concepto.** La compuerta ideal conserva la energía específica entre
la sección justo antes (yA) y justo después (yB=a_min): E(yA)=E(yB), con
yA la rama subcrítica (alterno de yB). Lejos de la compuerta, en ambos
sentidos, el canal (infinito) tiende al tirante normal yn (no hay lago
ni caída libre que impongan otro control, a diferencia de 2018 dic).

**Por qué esta herramienta.** Con el canal siendo infinito y sin ningún
otro control salvo la propia compuerta, no hace falta (ni es posible,
por falta de datos de distancia) ubicar la posición **exacta** x del
resalto: cualquier posición aguas abajo de la compuerta es compatible
con que el tramo subcrítico posterior se relaje asintóticamente a yn más
adelante. Alcanza con describir el perfil **cualitativamente** con los
tirantes de interés (§A5, variante "canal infinito con Q fijo").

**Script:** `Ejercicio1_canal_compuerta_rasante.m`, sección "PARTE 3"
(usa `Eesp_trap.m` para el alterno yA).

**Resultado:**
```
yB = a_min = 0.3509 m   (supercrítico, justo aguas abajo de la compuerta)
E(yB) = 1.3782 m
yA (alterno subcrítico, justo aguas arriba de la compuerta) = 1.3240 m
yn = 0.9298 m  (tirante lejos de la compuerta, aguas arriba y aguas abajo)
yc = 0.6333 m
```

**Descripción del perfil (x creciente en el sentido del flujo):**
- Lejos aguas arriba de la compuerta: y≈yn=0.930 m (flujo uniforme).
- Acercándose a la compuerta: curva **M1** (remanso, creciente) desde
  yn=0.930 m hasta yA=1.324 m justo antes de la compuerta.
- En la compuerta: salto de yA=1.324 m a yB=a_min=0.351 m.
- Justo después de la compuerta: curva **M3** (supercrítica, y<yc,
  creciente) que acelera el tirante desde 0.351 m.
- **Resalto hidráulico** en algún punto aguas abajo (posición exacta no
  determinada por falta de una longitud de referencia en el enunciado):
  conecta el tirante de la curva M3 con su conjugado (vía `Mom_trap`),
  ya en la rama subcrítica.
- Después del resalto: curva **M2** que se relaja asintóticamente hacia
  yn=0.930 m lejos aguas abajo.

### Parte 4) Fuerza sobre la compuerta

**Concepto.** Con la compuerta fija en a_min y descarga libre (no
ahogada, ya que a_min<yc), la fuerza que el flujo ejerce sobre la
compuerta es F=γ·(M1−M2) (cantidad de movimiento, §A3), con M1 el
momento en yA (justo aguas arriba, sección llena) y M2 el momento en
yB=a_min (justo aguas abajo, sección llena — no hace falta la fórmula
híbrida de descarga ahogada porque acá la descarga es libre).

**Herramienta:** `Mom_trap.m` (momento M(y) en forma cerrada, sección
trapezoidal).

**Script:** `Ejercicio1_canal_compuerta_rasante.m`, sección "PARTE 4".

**Resultado:**
```
M1 = 7.0835 m3   (y=yA=1.3240 m)
M2 = 4.9580 m3   (y=yB=a_min=0.3509 m)
F = gamma*(M1-M2) = 20 830 N = 20.83 kN   (empuja la compuerta hacia aguas abajo)
```

**Comparación con la solución oficial:** las páginas de solución oficial
(3-7 del PDF) son manuscritas, con letra cursiva difícil y fotografiadas
con rotación/perspectiva; no se pudo extraer con confianza suficiente
los valores numéricos finales de esta parte para comparar directamente.
El planteo (clasificación M, compuerta ideal con alterno, tensión
rasante, cantidad de movimiento) es coherente con el tipo de ejercicio y
con los demás exámenes ya resueltos del curso que usan exactamente las
mismas herramientas.

---

## EJERCICIO 2 (25 puntos) — Hietograma observado, período de retorno, infiltración NRCS y tiempo de encharcamiento

**Enunciado (resumen):** el 12 de diciembre se registró en un pluviógrafo
de Canelones (X=480 km, Y=6200 km) el hietograma en bloques de 10 min:
P=3, 6, 12, 26, 9, 4 mm (P_total=60 mm).
a) Calcular el período de retorno asociado a la intensidad máxima de
   todo el evento.
b) Con el modelo NRCS, estimar el volumen infiltrado (mm) en una cuenca
   de tc=1.42 h, suelo grupo hidrológico C, cobertura "hierbas poco
   densas y arbustos". Precipitación de los 5 días previos: 58 mm.
c) Definir tiempo de encharcamiento y estimarlo para este evento.

Teoría usada: curvas IDF de Uruguay e inversión de CT para hallar el Tr
de un evento observado (§B3), Número de Curva NRCS y condición de
humedad antecedente AMC (§B5, §B6), tiempo de encharcamiento con el
modelo NRCS quando no se dan parámetros de Horton (§B8, variante añadida
a partir de este examen). Ver `RESUMEN EXAMEN/Teorico/RESUMEN_TEORICO.md`.

### Parte a) Período de retorno de la intensidad máxima del evento

**Concepto.** El bloque más intenso del hietograma (26 mm en 10 min) es
un dato **puntual** de pluviógrafo (no una lluvia sobre una cuenca), así
que se relaciona con las curvas IDF de Uruguay sin corrección por área
(CA=1): P=P(3,10)·CT(Tr)·CD(d). Conocidos P, d y P(3,10) (isoyetas), se
despeja CT=P/(P(3,10)·CD(d)) y se invierte numéricamente CT(Tr) para
obtener el Tr del evento (§B3, "Encontrar el Tr de un evento observado").

**Por qué esta herramienta.** Es exactamente el caso de inversión de CT
ya usado en varios exámenes anteriores (2024 feb, 2023 jul, 2019 dic,
etc.), aplicado aquí al bloque de mayor intensidad de un hietograma en
vez de a un único valor de lluvia-duración.

**Lectura de P(3,10) en isoyetas (Fig. 3.1.10 del Teórico) para
X=480 km, Y=6200 km:** se renderizó la figura a 300/600 dpi con PyMuPDF
y se calibraron los ejes en píxeles (recuadro X: 200–800 km en píxeles
523.5–2263.5; Y: 6100–6700 km en píxeles 2117–533.5). El punto cae
prácticamente **sobre la isoyeta gruesa "90"** (desplazamiento
perpendicular estimado de sólo ≈6 km hacia el lado de mayor
precipitación, muy por debajo de la resolución/grosor de la línea
dibujada a mano) ⇒ **P(3,10) ≈ 90 mm** (imagen: `ej2_isoyeta_P310.png`,
punto marcado en rojo). Nota: un punto cercano (X=494.4 km, Y=6171.8 km,
~30 km al SE) usado en `resueltos/2024 febrero/` leyó P310=79 mm — la
diferencia es coherente con que en esta zona las isoyetas 90 y 80 están
muy próximas entre sí (gradiente local empinado, visible en la propia
figura), no con un error de lectura.

**Script:** `Ejercicio2_hietograma_NRCS_encharcamiento.py`, sección
"PARTE a)". Entradas: P_obs=26 mm, d=10 min=1/6 h, P310=90 mm, CA=1.

**Resultado:**
```
CD(10 min) = 0.2718
CT objetivo = 26/(90*0.2718) = 1.0629
Tr = 13.78 anios
```

**Tr ≈ 13.8 años.**

### Parte b) Volumen infiltrado (modelo NRCS)

**Concepto.** El volumen infiltrado (junto con la abstracción inicial)
es la diferencia entre la precipitación total del evento y la
precipitación efectiva (escorrentía) que predice el modelo NRCS:
Vinf=P−Pe, con Pe=(P−Ia)²/(P−Ia+S), Ia=0.2S, S=25400/NC−254 (§B5). El NC
de tabla (condición media, AMC II) se corrige según la humedad
antecedente real del evento (§B6): con P5d=58 mm y el evento en
diciembre (estación de crecimiento, umbral 53.34 mm) ⇒ **AMC III**
(suelo húmedo) ⇒ NC(III) > NC(II).

**Por qué esta herramienta.** El enunciado pide explícitamente asumir
el modelo NRCS (no Horton) y da exactamente los datos que ese modelo
necesita: NC de tabla + P5d para la corrección por AMC.

**NC de tabla (Fig./Tabla 3.1.20 del Teórico):** "Hierba con baja
densidad y arbustos" (coincide literalmente con la cobertura del
enunciado), Grupo Hidrológico C ⇒ **NC(II)=71** (fila sin variantes de
condición hidrológica, a diferencia de las filas de "Pradera o
pastizal").

**Script:** `Ejercicio2_hietograma_NRCS_encharcamiento.py`, sección
"PARTE b)". Entradas: NC(II)=71, P5d=58 mm, P_total=60 mm.

**Resultado:**
```
P5d=58 mm > 53.34 mm (estacion de crecimiento) => AMC III
NC(III) = 23*71/(10+0.13*71) = 84.92
S = 25400/84.92 - 254 = 45.11 mm ; Ia = 0.2*S = 9.02 mm
Pe(P_total=60mm) = (60-9.02)^2/(60-9.02+45.11) = 27.05 mm
```

**Volumen infiltrado = P_total − Pe = 60 − 27.05 = 32.95 mm.**

### Parte c) Tiempo de encharcamiento (definición y estimación con NRCS)

**Concepto.** El tiempo de encharcamiento es el instante en que la
lluvia acumulada empieza a exceder la capacidad de abstracción del
suelo y comienza a generarse escorrentía en superficie. Con el modelo
de Horton esto se ve comparando intensidad i(t) contra f(t) (§B8); acá
no hay parámetros de Horton, pero el modelo NRCS tiene un análogo
directo: mientras la precipitación acumulada P(t) no supera la
abstracción inicial Ia=0.2S, el modelo predice Pe=0 (nada escurre,
"lluvia-limitado" en la terminología de Horton). En cuanto P(t) supera
Ia, Pe crece de inmediato (dPe/dP=0 en P=Ia y >0 para P>Ia, sin
"retraso" adicional) — así que el tiempo de encharcamiento es
simplemente el instante en que la curva acumulada del hietograma cruza
Ia.

**Por qué esta herramienta.** Es la extensión natural del concepto de
tiempo de encharcamiento (§B8) al modelo NRCS ya usado en la parte b),
sin necesitar datos adicionales de Horton que el enunciado no da.

**Script:** `Ejercicio2_hietograma_NRCS_encharcamiento.py`, sección
"PARTE c)".

**Resultado:**
```
Ia = 9.02 mm
P_acum(20 min) = 9.0 mm   (justo por debajo de Ia)
P_acum(30 min) = 21.0 mm  (bloque 20-30 min, intensidad 72 mm/h)
t_enc = 20 + (9.02-9.0)/1.2 = 20.02 min ~ 20 min
```

**t_enc ≈ 20 min** (prácticamente en el borde entre el 2º y 3er bloque
del hietograma — el hecho de que P_acum(20min)=9.0mm caiga tan cerca de
Ia=9.02mm sugiere que el enunciado fue diseñado para que el
encharcamiento ocurra justo ahí, confirmando que NC=71 es el valor de
tabla correcto).

**Comparación con la solución oficial:** el manuscrito de las páginas
3-7 del PDF es difícil de leer con confianza (letra cursiva,
fotografías rotadas); no se pudo extraer un valor numérico claro para
comparar. El planteo (inversión de CT, corrección de NC por AMC,
extensión del concepto de tiempo de encharcamiento al modelo NRCS) es
consistente con la teoría del curso y con los demás exámenes ya
resueltos.

---

## Pendiente para próximas corridas

- Ejercicio 3 (alcantarilla, Racional/NRCS según tc, % de urbanización
  máximo admitido).
- Ejercicio 4 (dos bombas en paralelo, coeficientes de pérdida de carga
  Kgs/Kgi, potencia y cavitación).

## ESTADO: EN CURSO (Ejercicios 1 y 2 de 4 completos)
