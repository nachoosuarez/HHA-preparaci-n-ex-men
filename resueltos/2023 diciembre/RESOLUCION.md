# Examen HHA — 11 de diciembre de 2023

Fuente: `EXAMENES/2023 diciembre.pdf` (8 páginas: letra + solución oficial
manuscrita completa, escaneada). Los 4 ejercicios (25 puntos c/u) son:
1) FGV en canal rectangular de DOS tramos con distinta pendiente, entre
dos lagos; 2) hidrología de una cuenca en Treinta y Tres — caudal de
diseño de una alcantarilla, período de retorno de un caudal límite, y
urbanización máxima admisible; 3) delimitación gráfica de una cuenca en
Florida (carta SGM) + abstracciones NRCS de un evento observado; 4)
sistema de bombeo de dos bombas iguales en paralelo (punto de
funcionamiento, potencia, cavitación, y planteo con succiones
independientes).

Este examen trae **solución oficial manuscrita completa** para los 4
ejercicios (páginas 4-6 y 8 del PDF) y el mapa de la cuenca ya delimitado
a mano (página 7), que se usan para comparar cada resultado.

---

## Ejercicio 1 — FGV en canal rectangular de dos tramos entre dos lagos

### Enunciado (resumen)

Un Lago A (nivel hLA=2.1 m sobre el fondo) descarga a un canal
RECTANGULAR (b=1.1 m, n=0.012) que a su vez descarga en un Lago B
(hLB=0.4 m sobre el fondo). El canal tiene DOS tramos de 100 m cada uno
con distinta pendiente de fondo S01, S02 (mismo b, n en todo el canal).
Para dos combinaciones de pendientes, se pide el caudal de descarga,
clasificar cada tramo en M o S, y dibujar la superficie libre completa
indicando tirantes relevantes y resaltos si los hubiera.
1) S01=0.01, S02=0.002.
2) S01=0.002, S02=0.01.

### Teoría (RESUMEN_TEORICO.md, sección A — FGV)

- **A1** Clasificación M/S: yn (Manning) vs. yc (Froude=1).
- **A4** Control de un canal alimentado por un lago: si el tramo de
  salida es **tipo S**, el lago descarga con **control crítico en la
  entrada** (y=yc en x=0, caudal máximo compatible con la energía del
  lago); si es **tipo M**, la entrada NO es control — el caudal lo fija
  un control aguas abajo (acá, el **cambio de pendiente** mild→steep, que
  sí es crítico) y hay que iterar Q para que la energía en la entrada
  cierre con hLago.
- **A3** Ubicación de un resalto: comparar, en la misma sección x, el
  conjugado (Mom_rect) de la rama supercrítica con el valor real de la
  rama subcrítica extendida con la pendiente del tramo donde se busca.

Cita: Teórico HHA §2.3.1-§2.3.3, §2.5.3-§2.5.6; Formulómetro "Flujo
Gradualmente Variado" / "Cantidad de Movimiento" / "Energía".

### Herramienta y por qué

Se usó Octave con el toolkit canónico `RESUMEN EXAMEN/Codigos/FGV_rectangular`
(`rect_geom`, `froude_rect`+`fsolve` —yc—, `manning_rect`+`fsolve` —yn—,
`Mom_rect` —conjugado/resalto—, `rect.m`+`ode23` —integración de las
curvas M2/S2—) porque el enunciado es un problema de FGV en canal
rectangular con controles en ambos extremos (dos lagos) y cambio de
pendiente intermedio — el caso de uso central de ese toolkit. No hizo
falta ninguna función nueva: la particularidad de este examen (dos
tramos, cada uno con su propio control aguas arriba/abajo, y localizar en
qué tramo cae el resalto) se resolvió **encadenando** llamadas a las
mismas funciones cerradas del toolkit con la pendiente de cada tramo, sin
tocar el toolkit en sí. Script adaptado a este examen (con la lógica de
control de entrada/salida y localización del resalto):
`resueltos/2023 diciembre/scripts/Ejercicio1_FGV_dostramos.m` (+ todo el
toolkit `FGV_rectangular` copiado al mismo directorio como dependencias,
+ `residuo_entrada.m`, función auxiliar nueva sólo para este ejercicio,
usada por `fzero` en la Parte 2 para iterar Q).

### Paso a paso

**Parte 1) S01=0.01 (tramo 1), S02=0.002 (tramo 2).**

Se prueba primero la hipótesis "tramo 1 steep" (la más simple: control
crítico directo en la entrada, sin iterar):
```
yc = (2/3)·hLA = 1.400 m        (de E=1.5·yc=hLA en flujo crítico rectangular)
Q  = b·sqrt(g·yc³)              = 5.704 m³/s
yn1 (Manning, S01=0.01)  = 1.193 m  <  yc  =>  TRAMO 1 TIPO S  ✓ (consistente)
yn2 (Manning, S02=0.002) = 2.381 m  >  yc  =>  TRAMO 2 TIPO M
```
Como el tramo 1 resulta efectivamente steep, la hipótesis de control
crítico en la entrada es autoconsistente: el Lago A descarga el caudal
máximo compatible con su energía, **sin depender de lo que pase aguas
abajo** (mientras el tramo 1 sea steep).

Perfil: en tramo 1, curva **S2** desde y=yc=1.4 m (x=0) decreciendo hacia
yn1≈1.19 m (asintótico, ya casi alcanzado en x=100 m: y=1.196 m). En la
salida, hLB=0.4 m < yc=1.4 m, así que el Lago B **no controla** (queda
por debajo del crítico): la salida se comporta como una caída libre,
y(x=200)=yc=1.4 m, alimentando una curva **M2** en tramo 2 que, integrada
hacia atrás, da y=1.930 m en x=100 m (creciendo hacia yn2=2.38 m aguas
arriba).

En x=100 m se comparan las dos ramas: la supercrítica que llega de tramo
1 (y=1.196 m) contra la subcrítica que exige tramo 2 (y=1.930 m). El
conjugado de la rama supercrítica en ese punto (Mom_rect) da **1.626 m**,
que es **menor** que 1.930 m: la rama supercrítica todavía no tiene
momentum suficiente para "saltar" hasta el nivel que exige tramo 2, así
que el resalto **ya ocurrió antes**, dentro del tramo 1. Extendiendo la
rama subcrítica hacia atrás dentro de tramo 1 (misma pendiente S01) y
cruzándola contra el conjugado de la curva S2, se ubica:
```
RESALTO en x ≈ 74.5 m (dentro del tramo 1):  y = 1.20 m  ->  y = 1.62 m
```

**Perfil completo (Parte 1):** y=1.4 m en la entrada (control crítico) →
curva S2 decreciendo hasta y≈1.20 m en x≈74.5 m → **resalto** (1.20→1.62
m) → curva subcrítica corta hasta x=100 m (y=1.93 m) → curva M2 en tramo
2 decreciendo suavemente hasta y=yc=1.4 m justo en la caída libre al
Lago B (x=200 m).

**Parte 2) S01=0.002 (tramo 1), S02=0.01 (tramo 2).**

Se prueba la misma hipótesis de control crítico "ingenuo" en la entrada
con el Q de la parte 1 (yc=1.4, Q=5.7): da yn1=2.381 m > yc, es decir el
tramo 1 resultaría **mild**, contradiciendo la hipótesis (esa era la
hipótesis de tramo STEEP). Por lo tanto el control crítico en la entrada
**no es válido** acá: el Lago A no puede forzar más caudal que el que el
tramo 1 (mild) deja pasar aguas abajo. El control pasa a estar en el
**cambio de pendiente** (mild→steep, x=100 m), que sí es crítico
(análogo a una caída libre "interna"). Se itera Q (`fzero` sobre
`residuo_entrada.m`) para que, integrando la curva M2 de tramo 1 hacia
atrás desde (x=100, y=yc(Q)) hasta x=0, la energía en la entrada cierre
con hLA:
```
Q = 4.999 m³/s  ≈  5 m³/s   ;   yc = 1.282 m
yn1 (Manning, S01=0.002) = 2.119 m  >  yc  =>  TRAMO 1 TIPO M  ✓
yn2 (Manning, S02=0.01)  = 1.071 m  <  yc  =>  TRAMO 2 TIPO S  ✓
```
Tirante en la entrada (energía con el Lago A):
```
y0 + Q²/(2g(b·y0)²) = hLA  =>  y0 = 1.760 m
```
(chequeo: 1.760 + 5²/(2·9.8·(1.1·1.760)²) = 1.760 + 0.340 = 2.100 m = hLA ✓)

Perfil: tramo 1, curva **M2** desde y0=1.76 m (x=0) decreciendo hasta
y=yc=1.28 m en x=100 m (control, cambio de pendiente). Tramo 2, curva
**S2** desde y=yc=1.28 m (x=100 m) decreciendo hacia yn2≈1.07 m
(asintótico, y=1.074 m en x=200 m). Como hLB=0.4 m < yn2=1.07 m, el Lago
B queda por debajo del tirante normal del tramo steep: en flujo
supercrítico la información no viaja hacia aguas arriba, así que **el
Lago B no controla nada** — la curva S2 domina todo el tramo 2 sin
resalto, y el ajuste final al nivel del lago ocurre en una zona muy
localizada justo en el borde.

**Perfil completo (Parte 2):** y=1.76 m en la entrada → curva M2
decreciendo suavemente hasta y=yc=1.28 m en el cambio de pendiente
(x=100 m) → curva S2 decreciendo hacia yn2≈1.07 m → descarga al Lago B
sin resalto.

### Resultado final

| Ítem | Parte 1 (S01=0.01, S02=0.002) | Parte 2 (S01=0.002, S02=0.01) |
|---|---|---|
| Caudal Q | **5.70 m³/s** | **5.00 m³/s** |
| yc | 1.400 m | 1.282 m |
| Tramo 1 | **Tipo S**, yn1=1.193 m | **Tipo M**, yn1=2.119 m |
| Tramo 2 | **Tipo M**, yn2=2.381 m | **Tipo S**, yn2=1.071 m |
| Control de entrada | Crítico en x=0 (lago descarga máx.) | Energía con el lago, y0=1.760 m |
| Control de salida | Caída libre (hLB<yc) | — (Lago B no controla, hLB<yn2) |
| Resalto | **Sí, x≈74.5 m** (dentro del tramo 1), 1.20→1.62 m | **No hay resalto** |

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| Parte 1: yc, Q | 1.4 m, 5.7 m³/s | 1.400 m, 5.704 m³/s | ≈0 |
| Parte 1: yn1 (tramo 1, S) | 1.19 m | 1.193 m | ≈0 |
| Parte 1: yn2 (tramo 2, M) | 2.36 m | 2.381 m | 0.02 m |
| Parte 1: resalto, tramo | tramo 1 | tramo 1 | — |
| Parte 1: tirantes del resalto | y≈1.19 → y≈1.63 m (del dibujo) | y=1.20 → y=1.62 m | ≈0 |
| Parte 2: Q | 5 m³/s | 4.999 m³/s | ≈0 |
| Parte 2: y1 (entrada) | 1.76 m | 1.760 m | ≈0 |
| Parte 2: yc | 1.28 m | 1.282 m | ≈0 |
| Parte 2: yn1 (tramo 1, M) | 2.12 m | 2.119 m | ≈0 |
| Parte 2: yn2 (tramo 2, S) | 1.07 m | 1.071 m | ≈0 |
| Parte 2: resalto | no hay | no hay | — |

Coincidencia prácticamente exacta en todos los ítems. La solución oficial
no da la posición x exacta del resalto de la Parte 1 (sólo lo ubica
gráficamente dentro del tramo 1, con los tirantes 1.19→1.63 m leídos del
dibujo); el cálculo numérico (x≈74.5 m, 1.20→1.62 m) es consistente con
ese dibujo.

---

## Ejercicio 2 — Caudal de diseño de una alcantarilla, Tr límite y urbanización máxima

### Enunciado (resumen)

Cuenca en Treinta y Tres (punto de cierre X=625 km, Y=6350 km), uso de
suelo pastizales naturales, Grupo Hidrológico B, condición hidrológica
MALA, flujo concentrado. Área=4.75 km², ΔH=110 m, L (cauce ppal)=3100 m,
S (pendiente media de la cuenca)=3.7%.
a) Caudal de diseño de una alcantarilla en el punto de cierre, Tr=5 años.
   Justificar la metodología.
b) El sobrepasamiento de la rasante ocurre para Q>32 m³/s. Determinar el
   período de retorno de ese caudal límite.
c) Máxima superficie de la cuenca urbanizable (desarrollo en
   concreto/techo) para que el Qmax en ese escenario no supere en 15% el
   caudal de la parte (a), con tc invariante.

### Teoría (RESUMEN_TEORICO.md, sección B — Hidrología)

- **B2** Tiempo de concentración (Ramser-Kirpich), flujo concentrado.
- **B3** Curvas IDF de Uruguay, coeficientes CD/CT/CA.
- **B4** Método Racional, criterio de selección según tc, **búsqueda de Tr
  a partir de un caudal límite** (C tabulado en columnas discretas de Tr),
  y **coeficiente de escorrentía ponderado / área urbanizable máxima**
  (ampliados en esta corrida con el caso concreto de este examen).
- **B5** Método NRCS (Número de Curva + Hidrograma Unitario Triangular SCS).

Cita: Teórico HHA §3.1.5, §3.1.6; Formulómetro "Tiempo de Concentración" /
"Curvas IDF" / "Método Racional" / "Método NRCS".

### Herramienta y por qué

Se usó Python (replicando exactamente las fórmulas de la planilla
`Eventos extremos.xlsx`, documentadas en
`RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md`) en vez de operar
la planilla Excel directamente, porque el ejercicio pide además **invertir**
la fórmula del método Racional para hallar un Tr (parte b) y despejar un
área urbanizable a partir de un incremento de caudal admisible (parte c) —
cálculos que la planilla no arma como celdas propias y que conviene
programar para iterar/despejar con precisión, verificando cada paso contra
la solución oficial. Es el mismo enfoque que los demás exámenes con
Ejercicio de hidrología estadística (`ej2_parte1.py`, etc.). Script
adaptado a este examen:
`resueltos/2023 diciembre/scripts/Ejercicio2_racional_NRCS.py`.

Lecturas gráficas/tabulares externas (no las calcula ninguna herramienta,
hay que leerlas de las figuras/tablas del Teórico — se usaron los valores
de la solución oficial, verificados por ser consistentes con los
resultados finales): P(3,10)=80 mm (Fig. 3.1.10, isoyetas), NC=79
(Fig. 3.1.20, pastizales naturales/condición mala/grupo B), C=0.36 para
Tr=5 y C=0.38 para Tr=10 (Tabla 3.1.4, misma combinación de uso de
suelo/pendiente).

### Paso a paso

**a) Caudal de diseño, Tr=5 años.**

Tiempo de concentración (Kirpich, flujo concentrado; S del cauce
principal, distinta de la pendiente media 3.7% de la cuenca):
```
S_cauce = ΔH/L/10 = 110/3.1/10 = 3.548 %
tc = 0.4·L^0.77/S_cauce^0.385 = 0.587 hs = 35.2 min
```
Con 20 min < tc < 1 h (B4), corresponde calcular **ambos** métodos y
adoptar el mayor caudal:
```
Método Racional: CT(5)=0.860, CD(tc)=0.486, CA(tc)=0.988
  P máx. en el área = P310·CD·CT·CA = 33.0 mm ; i = 56.2 mm/h
  QMR(Tr=5) = C·i·A/360 = 0.36·56.2·475/360 = 26.70 m³/s

Método NRCS: S=25.4(1000/79-10)=67.5 mm ; Ia=13.5 mm
  Tormenta de diseño (bloque alterno, Δt=tc/7) + Pe por bloque (NC, con
  piso de infiltración 1.2 mm/h) + convolución con hidrograma unitario
  triangular SCS (Tp=0.372 h, qp=2.66 m³/s/mm)
  QNRCS(Tr=5) = 15.93 m³/s
```
Se adopta el mayor: **Qdiseño = QMR(Tr=5) = 26.70 m³/s** (método
Racional).

**b) Tr del caudal límite (Q=32 m³/s).**

Como la Tabla 3.1.4 tabula C en columnas discretas de Tr (2, 5, 10, 25,
50, 100 años), se prueba el siguiente escalón tabulado, Tr=10 (C=0.38):
```
QMR(Tr=10) = 0.38·i(Tr=10)·475/360 = 32.79 m³/s
```
Como QMR(Tr=5)=26.70 m³/s < 32 m³/s < QMR(Tr=10)=32.79 m³/s, y el
enunciado da un caudal límite puntual (no pide interpolar la tabla), el
caudal de sobrepasamiento cae dentro del escalón de **Tr=10 años**: ese
es el período de retorno del caudal límite.

**c) Área urbanizable máxima (concreto/techo), Δh≤15%.**

Con tc invariante (dato del enunciado), Q es directamente proporcional a
C (A, i fijos). El coeficiente de escorrentía ponderado de una cuenca con
área A₂ urbanizada (C₂=0.80, concreto/techo) y el resto (A₁=Aₜ-A₂) con el
C original (C₁=0.36, Tr=5, el de la parte a) es:
```
C_ponderado = (C1·A1 + C2·A2)/AT
Qtarget = 1.15·Qa = 30.70 m³/s  =>  C_target = 1.15·C1 = 0.414
A2 = AT·(C_target - C1)/(C2 - C1) = 4.75·(0.414-0.36)/(0.80-0.36) = 0.583 km²
```

### Resultado final

| Ítem | Resultado |
|---|---|
| tc (Kirpich) | 35.2 min (20min<tc<1h ⇒ calcular Racional y NRCS) |
| QMR(Tr=5) | 26.70 m³/s |
| QNRCS(Tr=5) | 15.93 m³/s |
| **Qdiseño (parte a)** | **26.70 m³/s** (método Racional) |
| **Tr del caudal límite (parte b)** | **10 años** |
| **Área urbanizable máxima (parte c)** | **0.58 km²** |

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| tc | 0.58 hs = 35 min | 0.587 hs = 35.2 min | ≈0 |
| QMR(Tr=5) | 26.7 m³/s | 26.70 m³/s | ≈0 |
| QNRCS(Tr=5) | 15.8 m³/s | 15.93 m³/s | 0.13 m³/s |
| QMR(Tr=10) | 32.8 m³/s | 32.79 m³/s | ≈0 |
| Tr límite | 10 años | 10 años | — |
| Área urbanizable máxima | 0.58 km² | 0.583 km² | ≈0 |

Coincidencia prácticamente exacta en todos los ítems (la única diferencia
menor, en QNRCS, es atribuible a la discretización numérica del
hidrograma unitario/tormenta de diseño y no afecta ningún resultado
final, ya que el método adoptado en la parte a es el Racional).

---

---

## Ejercicio 3 — Delimitación de cuenca (Florida) + evento extremo observado

### Enunciado (resumen)

1) Delimitar la cuenca de la cañada Sin Nombre (departamento de Florida),
punto de cierre X=447.3 km, Y=6199.7 km, sobre la carta topográfica SGM
adjunta (curvas de nivel cada 5 m).
2) El mes anterior ocurrió un evento extremo con precipitación acumulada
total de 185 mm; en los 5 días previos al evento llovió 62 mm. El suelo
de la cuenca es la unidad cartográfica "Cerro Chato", cobertura pasturas
naturales en condición hidrológica REGULAR. Determinar: 3.1) el volumen
de escorrentía total (mm) asociado al evento; 3.2) el coeficiente de
escorrentía asociado a todo el evento.

### Teoría (RESUMEN_TEORICO.md)

- **B1** Delimitación de cuencas y divisoria de aguas (perpendicular a
  curvas de nivel, convexo=cresta/cóncavo=vaguada, nunca cruza el cauce
  salvo en el cierre).
- **B6** Condición de humedad antecedente (AMC): P5d se compara contra
  umbrales según la estación (activa/inactiva) para decidir si corregir
  el NC de tabla (AMC II) a AMC I (seco) o AMC III (húmedo).
- **B5** Precipitación efectiva por el método del Número de Curva (NRCS).

Cita: Teórico HHA §1.2.1 (morfología de cuencas), §3.1.5 b) / Fig. 3.1.21
(AMC), §3.1.6 (Número de Curva); Formulómetro "Morfología de Cuencas" /
"Condiciones de humedad antecedente".

### Herramienta y por qué

**Parte 1:** delimitación gráfica manual sobre la carta (Teórico §1.2.1,
sin fórmula cerrada) — se extrajeron a imagen la página en blanco
(`scripts/ej3_carta_sin_delimitar.png`) y la página con la solución
oficial (`scripts/ej3_cuenca_solucion_oficial.png`, ambas de
`EXAMENES/2023 diciembre.pdf`).

**Parte 2:** Python replicando la fórmula NRCS de precipitación efectiva y
la corrección de NC por AMC (B5/B6), en vez de la planilla de eventos
extremos, porque acá el dato es un evento **ya observado** con P total y
Pe pedidas directamente (no hay que armar la tormenta de diseño por
bloque alterno — ver COMO_USAR_EVENTOS_EXTREMOS.md, "Hoja 4" es para
hietogramas por bloques, pero acá alcanza con la lámina total del
evento). Script: `resueltos/2023 diciembre/scripts/Ejercicio3_parte2_AMC.py`.

### Paso a paso

**Parte 1) Delimitación de la cuenca.**

En la carta se ubicó el punto de cierre (marcador rojo, sobre la cañada
Sin Nombre, cerca de la localidad de Independencia — departamento de
Florida, consistente con el enunciado) inmediatamente aguas abajo de la
confluencia de dos brazos del curso de agua: uno que baja de norte a sur
paralelo a la ruta/"Cuchilla del Pintado", y un tributario que se une
desde el oeste. La solución oficial resalta en la carta justamente ese
curso principal y su confluencia (imagen `ej3_cuenca_solucion_oficial.png`)
como paso previo a trazar la divisoria.

A partir de esa red de drenaje, la divisoria se traza perpendicular a las
curvas de nivel, por las lomas que rodean el valle de ambos brazos:
ganando altura hacia las nacientes de cada brazo (lado convexo de las
curvas) y cerrando en el punto de cierre. La cuenca resultante es un
polígono que engloba ambos brazos del curso de agua, apoyado al norte y
al oeste en las lomas que la separan de las cuencas vecinas (visibles en
la carta como las cabeceras de los demás cursos de agua que no confluyen
hacia el punto de cierre), y cerrando al sureste en el punto de cierre
mismo.

**Nota de precisión:** el manuscrito de la solución oficial resalta el
curso de agua y su confluencia pero no dibuja explícitamente el polígono
completo de la divisoria (o no es legible en el escaneo disponible); la
descripción de arriba es una lectura manual sobre la carta siguiendo el
procedimiento del Teórico §1.2.1, con la misma precisión con la que se
traza a mano en el examen real, pero sin verificación numérica cruzada
de área/perímetro contra un polígono oficial (misma limitación señalada
en `resueltos/2024 febrero/RESOLUCION.md`, Ejercicio 3 Parte 1, para un
caso similar).

**Parte 2) Volumen de escorrentía y coeficiente de escorrentía del evento.**

El evento ocurrió en julio (invierno en Uruguay ⇒ estación **inactiva**).
Con P5d=62 mm, se compara contra los umbrales de AMC para estación
inactiva (B6):
```
P5d = 62 mm > 27.94 mm (umbral AMC III, estación inactiva)  =>  condición AMC III (suelo húmedo)
```
Se corrige el NC de tabla (NC(II)=69, Cerro Chato/pasturas naturales
condición regular/Grupo B) a AMC III:
```
NC(III) = 23·NC(II) / (10 + 0.13·NC(II)) = 83.66 ≈ 83.7
```
Retención potencial máxima y abstracción inicial:
```
S = 25.4·(1000/NC(III) − 10) = 49.62 mm  <  P=185 mm  =>  hay escorrentía
Ia = 0.2·S = 9.92 mm
```
Precipitación efectiva (volumen de escorrentía total, en lámina):
```
Pe = (P − Ia)² / (P + 0.8S) = (185−9.92)² / (185+0.8·49.62) = 136.42 mm
```
Coeficiente de escorrentía de todo el evento:
```
C = Pe / P = 136.42 / 185 = 0.74
```

### Resultado final

| Ítem | Resultado |
|---|---|
| Parte 1: cuenca delimitada | Polígono que engloba los dos brazos del curso de agua, cerrando en el punto de cierre (X=447.3, Y=6199.7), ver `ej3_cuenca_solucion_oficial.png` |
| AMC del evento | **AMC III** (P5d=62 mm > 27.94 mm, estación inactiva) |
| NC corregido | **83.7** (de NC(II)=69) |
| **Parte 3.1: volumen de escorrentía (lámina)** | **136.4 mm** |
| **Parte 3.2: coeficiente de escorrentía del evento** | **0.74** |

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| NC(III) | 83.7 | 83.66 | ≈0 |
| S | 49.6 mm | 49.62 mm | ≈0 |
| Pe (volumen de escorrentía) | 136.4 mm | 136.42 mm | ≈0 |
| C (coeficiente de escorrentía) | 0.74 | 0.74 | ≈0 |

Coincidencia exacta en la Parte 2. La Parte 1 (delimitación gráfica) no
tiene forma de verificarse numéricamente contra la solución oficial por
las razones explicadas arriba (nota de precisión).

---

## ESTADO: EN CURSO (falta Ejercicio 4)
