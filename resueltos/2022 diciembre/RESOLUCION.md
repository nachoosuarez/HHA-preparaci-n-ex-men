# Examen HHA — 15 de diciembre de 2022

Fuente: `EXAMENES/2022 diciembre.pdf` (9 páginas: letra + carta topográfica
del Ejercicio 3 + solución oficial manuscrita completa de los 4
ejercicios, escaneada). Los 4 ejercicios son:
1) FGV en canal rectangular entre dos lagos (25 puntos); 2) hidrología de
una cuenca en Maldonado — caudal de diseño Tr=10 años, caudal de un
evento con hietograma dado y AMC, período de retorno de la intensidad
máxima del evento (30 puntos); 3) delimitación de una cuenca en Durazno +
coeficiente de escorrentía de un evento de intensidad constante (20
puntos); 4) sistema de bombeo para combate de incendios: punto de
funcionamiento, potencia, cavitación y cota máxima de elevación de la
tobera para un caudal mínimo (25 puntos).

Este examen trae **solución oficial manuscrita completa** para los 4
ejercicios (páginas 5-6, 8 y 9 del PDF), que se usa para comparar cada
resultado.

---

## Ejercicio 1 — FGV en canal rectangular entre dos lagos

### Enunciado (resumen)

Lago 1 descarga en un canal rectangular (b=1.5 m, n=0.011, S₀=0.009,
L=35 m) que a su vez descarga en el Lago 2.
1) hL1=1.35 m, hL2=-0.5 m (relativos al fondo del canal): calcular Q,
   clasificar el canal en M/S, dibujar el perfil con tirantes y resaltos
   si los hay.
2) Rango de hL2 (hL2min, hL2max) para que se dé un resalto en el canal.
3) hL2=1.5 m: calcular Q, clasificar y dibujar el perfil.

### Teoría (RESUMEN_TEORICO.md, sección A — FGV)

- **A1** Clasificación M/S del canal: yn (Manning, fsolve) vs. yc
  (Froude=1, forma cerrada en rectangular: yc=(Q²/(g·b²))^(1/3)).
- **A2** Energía específica: en rectangular, Ec=1.5·yc (forma cerrada) —
  clave para el control crítico de la entrada.
- **A3** Cantidad de movimiento y tirante conjugado (Mom_rect): para
  ubicar el resalto y sus límites de existencia.
- **A4** Control de un canal alimentado por lagos en ambos extremos: si
  el canal es tipo S, el Lago 1 impone control crítico en la entrada
  (Q máximo compatible con su energía) *mientras* el Lago 2 no lo
  "ahogue"; si el Lago 2 sube lo suficiente, controla él con una rama
  subcrítica que puede generar un resalto, o —si sube aún más— ahoga
  toda la entrada y cambia el propio Q (se itera, `fzero`).

**Precisión física necesaria para este ejercicio (no estaba explícita en
el resumen y se agregó): la transición del canal con cada lago no es
simétrica.** En la **entrada** (Lago 1 → canal) hay una **contracción**,
que no disipa energía: se conserva E, es decir E(y en x=0) = hL1. En la
**salida** (canal → Lago 2) hay una **expansión brusca** hacia el lago,
que sí disipa toda la energía cinética: el nivel del lago iguala
**directamente** el tirante en la última sección del canal, y(x=L)=hL2,
sin sumar el término V²/2g. Esta asimetría es la que permite resolver
las Partes 2 y 3 sin ambigüedad (ver Parte 2).

Cita: Teórico HHA §2.5.3-§2.5.4 (control por lago/embalse); Formulómetro
"Energía" / "Cantidad de Movimiento" / "Flujo Gradualmente Variado".

### Herramienta y por qué

Se usó Octave con el toolkit canónico `RESUMEN EXAMEN/Codigos/FGV_rectangular`
(`rect_geom`, `froude_rect`, `manning_rect` +`fsolve` —yn—, `Mom_rect`
—conjugado/resalto—, `rect.m`+`ode45` —integración de las curvas
S2/subcrítica—) porque es un problema estándar de FGV rectangular
controlado por lagos en ambos extremos. Se agregó sólo una función
auxiliar nueva, `residuo_entrada_lago.m`, para la iteración de Q de la
Parte 3 (mismo patrón que `residuo_entrada.m` de 2023 diciembre).
**Detalle numérico importante:** con la tolerancia por defecto de
`ode45`/`ode23`, el resultado de integrar desde muy cerca de yc (punto
casi singular de la EDO de FGV, 1-Fr²≈0) se aparta notoriamente del
valor correcto — hubo que ajustar `RelTol=1e-10, AbsTol=1e-12}` para
reproducir el resultado oficial (ver comparación abajo). Script completo:
`resueltos/2022 diciembre/scripts/Ejercicio1_FGV_doslagos.m` (+ todo el
toolkit `FGV_rectangular` copiado como dependencias + `residuo_entrada_lago.m`).

### Paso a paso

**Parte 1) hL1=1.35 m, hL2=-0.5 m.**

Se prueba la hipótesis "canal tipo S" (la más simple: control crítico
directo en la entrada, forma cerrada):
```
yc = hL1 / 1.5 = 0.9000 m            (E=1.5·yc=hL1, en flujo crítico rectangular)
Q  = b·sqrt(g·yc³)         = 4.0093 m³/s
yn (Manning, fsolve)       = 0.6324 m   <  yc  =>  TIPO S  ✓ (hipótesis consistente)
```
hL2=-0.5 m está por debajo del propio fondo del canal, muy por debajo de
yc: el Lago 2 no controla nada, la salida es una caída libre. Perfil:
curva **S2** decreciendo desde y=yc=0.900 m (x=0, control) hacia
yn=0.6324 m; integrando con `ode45` (tolerancia fina) hasta x=35 m:

**Resultado Parte 1: Q = 4.0093 m³/s ; canal tipo S ; y₁=yc=0.900 m ;
y₂(x=35 m)=0.6896 m** (no llega a alcanzar yn en los 35 m, sin resalto).

**Parte 2) Rango de hL2 para que exista un resalto.**

Mientras el Lago 2 no altere la entrada, Q se mantiene en 4.0093 m³/s
(fijado sólo por el Lago 1, control crítico en x=0). El resalto conecta
la rama supercrítica S2 (que llega desde la entrada) con una rama
subcrítica que exige el Lago 2; existe resalto si ese punto de cruce cae
**dentro** del canal (0<x<35 m):

- **hL2min:** el resalto ocurre justo en la salida (x=35 m). El tirante
  post-salto es el conjugado (Mom_rect) del tirante libre y₂=0.6896 m de
  la Parte 1; por la regla de la salida (sin V²/2g), ese conjugado ES
  directamente hL2min:
  ```
  conjugado(0.6896 m) = 1.1496 m  =>  hL2min = 1.1496 m
  ```
- **hL2max:** el resalto se corre hasta la propia entrada (x=0), es
  decir todo el canal queda subcrítico (curva creciendo desde yc). Se
  integra la rama subcrítica desde y(0)=yc=0.900 m hasta x=35 m:
  ```
  y(x=35 m, rama subcrítica desde yc) = 1.4251 m  =>  hL2max = 1.4251 m
  ```

**Resultado Parte 2: 1.15 m ≲ hL2 ≲ 1.43 m** (para que ocurra un resalto
en el canal; por debajo de hL2min el resalto queda "empujado" fuera del
canal —descarga libre, como en la Parte 1—, y por encima de hL2max el
Lago 2 ahoga la entrada y cambia el propio Q, como en la Parte 3).

**Parte 3) hL2=1.5 m.**

hL2=1.5 m > hL2max=1.4251 m: el Lago 2 ahoga la entrada, ya no hay
control crítico en x=0. Se itera Q (`fzero`) para que, integrando la
rama subcrítica hacia atrás desde (x=35, y=hL2=1.5, sin V²/2g por la
regla de la salida) hasta x=0, la energía en la entrada (con V²/2g, por
ser una contracción sin pérdidas) cierre con hL1=1.35 m:
```
Q  = 3.5535 m³/s
y1 (x=0, con E(y1)=hL1) = 1.1229 m
y2 = hL2 = 1.5000 m
```
Verificación: E(1.1229)=1.1229+3.5535²/(2·9.8·(1.5·1.1229)²)=1.1229+0.227=1.350 m=hL1 ✓

**Resultado Parte 3: Q = 3.5535 m³/s ; y1(x=0)=1.1229 m ; y2=1.500 m**
(canal completamente subcrítico, remanso del Lago 2 llega hasta el Lago
1, sin resalto).

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| Parte 1: Q | 4.01 m³/s | 4.0093 m³/s | ≈0 |
| Parte 1: yn | 0.6325 m | 0.6324 m | ≈0 |
| Parte 1: y2 (x=35m) | 0.6896 m | 0.6896 m | 0 |
| Parte 2: hL2min | ≈1.15 m (oficial da 1.1598, redondea a 1.15) | 1.1496 m | 0.01 m |
| Parte 2: hL2max | 1.425 m | 1.4251 m | ≈0 |
| Parte 3: Q | 3.55 m³/s | 3.5535 m³/s | ≈0 |
| Parte 3: y1 | 1.1231 m | 1.1229 m | ≈0 |

Coincidencia prácticamente exacta en todas las partes. La única
diferencia algo mayor (hL2min: 1.1496 calculado vs. 1.1598 oficial,
~0.01 m) es atribuible a que la solución oficial iteró manualmente unos
pocos caudales de prueba (Q=3, 3.2, 3.5, 3.6...) con menos precisión que
la integración numérica fina usada acá; el valor de y2 del que sale el
conjugado (0.6896 m) coincide exactamente con el oficial, así que el
propio cálculo del conjugado (Mom_rect, forma cerrada) es exacto.

---

## Ejercicio 2 — Hidrología de una cuenca en Maldonado

### Enunciado (resumen)

Cuenca en Maldonado (punto de cierre X=552 km, Y=6150 km; Área=7.6 km²,
ΔH=130 m, L=3265 m, Grupo Hidrológico D, S media=5.9%, pastizales en
condición hidrológica MALA, flujo concentrado).
1) Caudal máximo de diseño para Tr=10 años y volumen de escorrentía del
   evento de diseño.
2) Se registra un evento con hietograma dado (12 bloques de 5 min, total
   54.3 mm). 2.1) Asumiendo P5d=25 mm en los 5 días previos (julio,
   estación inactiva), calcular el caudal máximo generado por ESE evento.
   2.2) Determinar el período de retorno asociado a la intensidad máxima
   registrada en el pluviógrafo.

### Teoría (RESUMEN_TEORICO.md, sección B — Hidrología)

- **B2** Tiempo de concentración (Ramser-Kirpich), con la pendiente del
  **cauce principal** (ΔH/L/10), no la pendiente media de la cuenca (esa
  se usa sólo para elegir C en la Tabla 3.1.4).
- **B4** Criterio de selección de método según tc: 20 min<tc<1h ⇒
  calcular Racional y NRCS, adoptar el mayor.
- **B5** Método NRCS completo: tormenta de diseño por bloque alterno +
  precipitación efectiva (Número de Curva) + hidrograma unitario
  triangular SCS, para la Parte 1; y el mismo método pero con el
  hietograma **observado en su orden cronológico real** (sin reordenar
  por bloque alterno) para la Parte 2.1.
- **B6** Condición de humedad antecedente (AMC): con P5d dado y la
  estación del año, se decide si corregir el NC antes de calcular Pe del
  evento observado.
- **B3** Inversión de CT(Tr) para hallar el Tr de una intensidad puntual
  ya registrada (Parte 2.2).
- **B7** Volumen de escorrentía = ΣPe·Área·1000.

### Herramienta y por qué

Se usó **Python** (numpy, sin la planilla Excel manual) replicando
exactamente la lógica de `Eventos extremos.xlsx` / hoja `Cálculos
(grande)` (ver `RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md`),
porque el ejercicio necesita además dos variantes que la planilla no
resuelve de forma directa: (a) sustituir el hietograma de diseño por
bloque alterno por un hietograma **observado en orden cronológico** sin
reordenar (Parte 2.1); y (b) invertir numéricamente CT(Tr) para una
intensidad puntual dada (Parte 2.2, igual patrón que el ya usado en 2024
feb/2023 jul/2023 feb 2, ver B3). Los valores base P(3,10)=76 mm
(isoyeta), C=0.38 (Tabla 3.1.4) y NC=89 (Fig. 3.1.20, pastizales+condición
mala+Grupo D) se toman de la solución oficial manuscrita. Scripts:
`resueltos/2022 diciembre/scripts/ej2_parte1.py` (tormenta de diseño,
Racional+NRCS, volumen) y `ej2_parte2.py` (AMC, evento real, Tr inverso).

### Paso a paso

**Parte 1) Qmax (Tr=10) y volumen de escorrentía.**

```
S cauce principal = ΔH/L/10 = 130/3.265/10 = 3.98 %
tc (Ramser-Kirpich) = 0.4·L^0.77/S^0.385 = 0.5844 hs = 35.1 min
```
Como 20 min < tc=35.1 min < 1 h, corresponde calcular **ambos** métodos y
adoptar el mayor (B4):

```
MÉTODO RACIONAL:  d=tc, CD=0.4848, CA=0.9808, CT(10)=1
  P(d,10,A) = 36.14 mm  =>  i = 61.83 mm/h
  Qmax racional = C·i·A/360 = 0.38·61.83·760/360 = 49.60 m³/s

MÉTODO NRCS: dt=tc/7=5.01 min, 12 bloques (bloque alterno)
  S = 25.4·(1000/89-10) = 31.39 mm ; Ia=0.2S=6.28 mm
  Σ Pe (tormenta de diseño) = 22.30 mm
  Hidrograma unitario SCS: Tp=0.392 hs, Tb=1.047 hs, qp=4.03 m³/s/mm
  Qmax NRCS (convolución) = 66.76 m³/s
```
NRCS (66.76 m³/s) > Racional (49.60 m³/s) ⇒ se adopta **NRCS**.

**Resultado Parte 1: Qmax (Tr=10 años) = 66.76 m³/s** (método NRCS);
**Volumen de escorrentía = ΣPe·Área·1000 = 22.30 mm × 7.6 km² × 1000 ≈
169 500 m³**.

**Parte 2.1) Caudal generado por el evento REGISTRADO (P5d=25 mm, julio).**

Condición de humedad antecedente: estación inactiva (julio), umbrales
AMC (B6): AMC I <12.7 mm, AMC II 12.7–27.94 mm, AMC III >27.94 mm.
P5d=25 mm cae en el rango de **AMC II ⇒ NC se mantiene en 89** (sin
corregir).

Se sustituye la tormenta de diseño por el hietograma **observado**, en
su orden cronológico real (sin reordenar por bloque alterno):
```
P observado (12 x 5 min) = [2.1, 2.3, 2.7, 3.2, 4.2, 7.0, 16.5, 5.1, 3.6, 2.9, 2.5, 2.2] mm
Total = 54.30 mm ; Σ Pe (NRCS, mismo NC=89, mismo piso de infiltración) = 29.04 mm
Mismo hidrograma unitario de la Parte 1 (mismo tc ⇒ mismo Tp, Tb, qp)
Qmax (convolución con Pe del evento real) = 86.81 m³/s
```

**Resultado Parte 2.1: Qmax generado por el evento registrado = 86.81 m³/s.**

**Parte 2.2) Período de retorno de la intensidad máxima registrada.**

El bloque más intenso del hietograma es P=16.5 mm en d=5 min (bloque
30-35 min). Es una intensidad **puntual** (lectura de pluviógrafo, no una
lámina de diseño sobre el área) ⇒ se omite CA (B3):
```
CD(d=5min=0.0833h) = 0.1928
CT objetivo = P/(P310·CD) = 16.5/(76·0.1928) = 1.1262
Inversión numérica de CT(Tr) (bisección): Tr ≈ 19.1 años
```

**Resultado Parte 2.2: Tr ≈ 19 años** (de la intensidad máxima del evento
registrado).

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| Parte 1: tc | 35 min (0.5836h) | 35.1 min (0.5844h) | ≈0 |
| Parte 1: Qmax NRCS | 66.44 m³/s | 66.76 m³/s | 0.32 m³/s |
| Parte 1: Vesc | ≈169 480-169 980 m³ | 169 501 m³ | pequeña |
| Parte 1: Qmax Racional | 59.64 m³/s (según lectura de la manuscrita) | 49.60 m³/s | ver nota |
| Parte 2.1: Qmax evento | 86.44 m³/s | 86.81 m³/s | 0.37 m³/s |
| Parte 2.2: Tr | ≈19-20 años (19.285 en la manuscrita) | 19.1 años | ≈0 |

Coincidencia muy buena en todos los ítems que determinan las respuestas
finales (NRCS de diseño, volumen, caudal del evento real, Tr). La única
diferencia notoria es el caudal del **método Racional** de la Parte 1
(49.60 calculado vs. 59.64 leído de la manuscrita), pero **no afecta la
respuesta final** porque en ambos casos el NRCS resulta mayor y es el que
se adopta (B4): con C=0.38 e i=61.83 mm/h (que sí coincide con el i=61.878
oficial), Q=C·i·A/360 da 49.60 m³/s de forma consistente — la cifra
oficial de 59.64 no cierra con su propio i y A salvo que haya usado un C
distinto no completamente legible en la manuscrita; se documenta la
discrepancia sin perseguirla más, dado que es irrelevante para el
resultado final.

---

## Ejercicio 3 — Delimitación de cuenca (Durazno) + coeficiente de escorrentía

### Enunciado (resumen)

1) Delimitar la cuenca de la cañada afluente al arroyo del Tala, en el
departamento de Durazno, punto de cierre X=426.5 km, Y=6348.8 km, sobre
la carta topográfica SGM adjunta (curvas de nivel cada 10 m).
2) Se registra un evento de precipitación de intensidad **constante**
130 mm/h y 30 min de duración. La infiltración total durante el evento
fue de 15 mm y la intercepción de 5 mm. Calcular el coeficiente de
escorrentía del evento.

### Teoría (RESUMEN_TEORICO.md)

- **B1** Delimitación de cuencas y divisoria de aguas (perpendicular a
  curvas de nivel; convexo=cresta/nacientes, cóncavo=vaguada; nunca cruza
  el cauce salvo en el punto de cierre).
- **B10** (nuevo) Coeficiente de escorrentía por balance directo de
  abstracciones dadas (sin NC ni Horton): Esc=Prec−Abstracciones,
  C=Esc/Prec.

Cita: Teórico HHA §1.2.1 (morfología de cuencas); §3.1.1 (precipitación
efectiva/abstracciones); Formulómetro "Morfología de Cuencas" /
"Precipitación Efectiva".

### Herramienta y por qué

**Parte 1:** delimitación gráfica manual sobre la carta (sin fórmula
cerrada, Teórico §1.2.1) — se extrajeron a imagen las dos copias de la
carta topográfica de `EXAMENES/2022 diciembre.pdf` (páginas 4 y 7, esta
última en fotocopia/escala de grises), ambas **sin ninguna delimitación
dibujada** (a diferencia de otros exámenes, acá la solución oficial no
trae el polígono de la cuenca resuelto, sólo el cálculo numérico de la
Parte 2): `scripts/ej3_carta_pag4.png`, `scripts/ej3_carta_pag7.png`.

**Parte 2:** cálculo directo a mano (B10), sin necesidad de Octave ni de
la planilla de eventos extremos: las abstracciones (infiltración total e
intercepción) ya vienen dadas explícitamente en el enunciado, no hay
Número de Curva que estimar ni modelo de Horton que integrar — el
ejercicio se reduce a una resta y un cociente.

### Paso a paso

**Parte 1) Delimitación de la cuenca.**

El punto de cierre (marcador rojo en la carta, ver imágenes) se ubica al
este del corredor de la ruta sobre la "Cuchilla Grande del..." (que corre
de norte a sur por el borde occidental del mapa), en una zona de cotas
moderadas (curvas de nivel entre 90 y 110 m alrededor del punto,
subiendo hacia 120-125 m hacia el norte/noreste). El punto está
inmediatamente aguas abajo de la confluencia de varios cursos de agua
menores (visibles como líneas azules convergiendo justo al oeste/
noroeste del marcador) que forman la cañada afluente al arroyo del Tala
(el propio "Tala" aparece rotulado más al sur/sureste del punto, entre
las cotas "100" y "121").

A partir de esa red de drenaje, la divisoria se traza perpendicular a
las curvas de nivel: ganando altura hacia las lomas que separan esta
pequeña subcuenca de las cuencas vecinas (lado convexo de las curvas,
hacia el norte y el este, donde las cotas suben por encima de 100-110 m)
y bajando por el lado cóncavo hacia el propio cauce en el punto de
cierre. El polígono resultante es una subcuenca chica, apoyada en las
lomas circundantes visibles en la carta (curvas cerradas/cúspides al
norte y al este del punto) y cerrando al suroeste en el punto de cierre,
donde la cañada se une al arroyo del Tala.

**Nota de precisión (misma limitación señalada en `resueltos/2023
diciembre/RESOLUCION.md`, Ej.3, y en `resueltos/2024 febrero/RESOLUCION.md`,
Ej.3):** este examen no trae una solución oficial con el polígono de la
divisoria ya dibujado (las dos copias de la carta disponibles están en
blanco) — la descripción de arriba es una lectura manual de la carta
siguiendo el procedimiento del Teórico §1.2.1, con la misma precisión
con la que se traza a mano en el examen real, pero sin verificación
numérica cruzada de área/perímetro contra un polígono oficial.

**Parte 2) Coeficiente de escorrentía del evento.**

Intensidad constante ⇒ precipitación total del evento:
```
Prec = i · d = 130 mm/h · 0.5 h = 65 mm
```
Abstracciones totales (dato directo del enunciado, sin NC ni Horton):
```
Abstracciones = Infiltración total + Intercepción = 15 mm + 5 mm = 20 mm
```
Escorrentía y coeficiente de escorrentía:
```
Esc = Prec − Abstracciones = 65 − 20 = 45 mm
C = Esc / Prec = 45 / 65 = 0.6923
```

**Resultado Parte 2: C ≈ 0.692** (coeficiente de escorrentía del evento).

### Resultado final

| Ítem | Resultado |
|---|---|
| Parte 1: cuenca delimitada | Subcuenca chica que engloba la confluencia de cursos de agua inmediatamente aguas arriba del punto de cierre (X=426.5, Y=6348.8), cerrando al suroeste en la unión con el arroyo del Tala (ver `scripts/ej3_carta_pag4.png`) |
| Prec (evento) | 65 mm |
| Abstracciones (infiltración + intercepción) | 20 mm |
| Esc (evento) | 45 mm |
| **Parte 2: coeficiente de escorrentía** | **0.692** |

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| Prec | 65 mm | 65 mm | 0 |
| Abstracciones | 20 mm | 20 mm | 0 |
| Esc | 45 mm | 45 mm | 0 |
| C | 0.692 | 0.6923 | ≈0 |

Coincidencia exacta en la Parte 2 (cálculo directo, sin margen de
interpretación). La Parte 1 (delimitación gráfica) no tiene forma de
verificarse numéricamente por las razones explicadas arriba (nota de
precisión) — este examen no trae, a diferencia de otros, un polígono
oficial dibujado para comparar.

---
