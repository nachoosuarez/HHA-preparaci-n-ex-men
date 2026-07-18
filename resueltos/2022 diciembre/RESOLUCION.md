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
