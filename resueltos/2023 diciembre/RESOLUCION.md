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

## ESTADO: EN CURSO (falta Ejercicio 2, 3, 4)
