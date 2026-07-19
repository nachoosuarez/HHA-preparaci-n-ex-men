# Cómo usar la planilla "Eventos extremos.xlsx" en el examen

Instructivo para operar a mano, en Excel/LibreOffice real durante el examen,
la planilla `Scripts/01_SCRIPTS/Eventos extremos.xlsx`. Se usa para todo
ejercicio de **hidrología de crecidas**: tiempo de concentración, curvas IDF
(coeficientes CD/CT/CA), método Racional, método NRCS del Número de Curva
(tormenta de diseño por bloque alterno + precipitación efectiva + hidrograma
unitario triangular SCS).

Este documento se construyó recorriendo el archivo real con `openpyxl`
(celda por celda, con sus fórmulas) — no son suposiciones — y cruzando esas
celdas con los 4 exámenes ya resueltos en `resueltos/` que usaron esta misma
lógica: `resueltos/2024 diciembre/`, `resueltos/2025_FEBRERO 1/`,
`resueltos/2025_FEBRERO 2/` y `resueltos/2026 Febrero/` (todos, Ejercicio 2 —
y en 2025_FEBRERO 2 también parte del Ejercicio 3).

**Antes de nada:** en el archivo hay **4 hojas**: `Cálculos (grande)`,
`Cálculos (chica)`, `Horton` y `Hoja 4`. Ver más abajo cuál corresponde a
cada tipo de ejercicio (sección "Qué hoja usar").

---

## 0) Qué hoja usar para cada tipo de ejercicio

| Situación en el enunciado | Hoja a usar |
|---|---|
| Un solo caudal/cuenca a calcular (Racional y/o NRCS), tiempo de concentración por Kirpich (flujo concentrado) | **`Cálculos (grande)`** |
| Dos cuencas a comparar en simultáneo (p.ej. "cuenca grande" y "cuenca chica" del mismo enunciado), o una cuenca con **uso de suelo mixto** (% cultivo / % pastizal → NC ponderado) | **`Cálculos (chica)`** (trae también las columnas de la cuenca grande al lado, para comparar) |
| Infiltración por el modelo de **Horton** (f₀, f_c, K, tiempo de encharcamiento) | **Ninguna** — la hoja `Horton` está **vacía** (ver sección 3). Se resuelve a mano/Python con la fórmula de Horton, no con esta planilla. |
| Te dan un **hietograma de lluvia ya observado** (bloques de P en mm) y pedís la precipitación efectiva por Número de Curva (sin construir la tormenta de diseño por bloque alterno) | **`Hoja 4`** |

Las hojas `Cálculos (grande)` y `Cálculos (chica)` resuelven **de punta a
punta**: tiempo de concentración → curvas IDF → método Racional → método
NRCS (tormenta de diseño + precipitación efectiva + hidrograma unitario
triangular SCS). `Hoja 4` es una calculadora chica y aislada, solo para la
parte de precipitación efectiva por NC a partir de un hietograma que ya te
dan.

---

## 1) Hoja "Cálculos (grande)"

### 1.a) Datos de entrada (bloque INPUT, columnas H–K, filas 2–8)

Esta es la zona a llenar **primero**, es la que alimenta todo lo demás:

| Celda | Qué es | Unidad | De dónde sale |
|---|---|---|---|
| `J2` | Área de la cuenca (= `C3`, no hace falta tocarla si ya cargaste `C3`) | km² (la etiqueta dice "km", es un typo — es km²) | dato del enunciado |
| `J3` | Coeficiente de escorrentía **c** (método Racional) | adimensional | Tabla 3.1.4 del Teórico (según uso de suelo y pendiente **media** de la cuenca) |
| `J4` | Tiempo de concentración Tc final que usa TODA la planilla | horas | ⚠️ ver advertencia en 1.e — por defecto trae `=C7*1.15`, revisar |
| `J5` | Período de retorno Tr | años | dato del enunciado |
| `J6` | Precipitación P(3,10) | mm | Figura 3.1.10 del Teórico (isoyetas), lectura gráfica en el punto de cierre |
| `J7` | Número de Curva NC | adimensional | Figura/Tabla 3.1.20 del Teórico (uso de suelo × condición hidrológica × grupo hidrológico) |
| `J8` | Grupo Hidrológico (A/B/C/D), texto libre | — | dato del enunciado o tabla de suelos |

Columna `K` trae notas del tipo "Tabla 3.1.4" / "Figura 3.1.10" al lado de
`J3` y `J6` — son recordatorios de dónde buscar el dato, no fórmulas.

### 1.b) Tiempo de concentración (bloque B1:E9)

Hay **dos métodos** en paralelo, uno al lado del otro:

- **Columna B/C — Kirpich/Ramser (flujo concentrado), el que se usa en la práctica:**
  - `C3` = Área (km²) — dato
  - `C4` = Largo del cauce principal L (km) — dato
  - `C5` = Pendiente del cauce principal S (%) — dato. **Ojo:** NO es la
    pendiente media de la cuenca, es `ΔH(m)/L(km)/10` calculada con el
    desnivel del cauce principal. La pendiente media de la cuenca (si la da
    el enunciado por separado) es otro dato, solo se usa para elegir `C`
    (coef. de escorrentía) en la Tabla 3.1.4.
  - `C7` = `=0.4*C4^0.77/(C5^0.385)` → Tc de Kirpich en horas. **Este es el
    valor que hay que usar** (ver 1.e).
- **Columna E — método NRCS para flujo NO concentrado (rara vez necesario):**
  - `E4`=largo, `E5`=pendiente, `E6`=coeficiente de rugosidad **k** (hay que
    completarlo a mano según tabla de cobertura del suelo — la planilla NO
    lo trae, y si `E6` queda vacío la fórmula `E7` da 0).
  - `E7` = `=0.91134*E6*E4/SQRT(E5)`. Solo usar esta rama si el enunciado
    dice explícitamente que el flujo es NO concentrado (flujo en manto);
    en los 4 exámenes resueltos siempre fue flujo concentrado ⇒ siempre se
    usó la rama de Kirpich (`C7`).
- `J4` = combina ambas ramas (ver advertencia 1.e) y es la celda que
  **alimenta todo el resto de la hoja** (curvas IDF, método Racional,
  bloque alterno, hidrograma unitario).

### 1.c) Método Racional (bloque B11:F22)

Orden de lectura/llenado (todo son fórmulas ya armadas, solo hay que mirar
el resultado):

1. `D13:E15` es una tabla-recordatorio del criterio de selección de método
   según Tc (no una fórmula): Tc<20 min → solo Racional; 20 min<Tc<1 h →
   ambos métodos, quedarse con el mayor caudal; Tc>1 h → solo NRCS
   (Teórico §3.1.5).
2. `J13` (`CT`, corrección por Tr) = `=0.5786-0.4312*LOG(LN(J5/(J5-1)))`
3. `J14` (`CD`, corrección por duración) — usa `E20` (=`J4`, la duración
   se toma igual al Tc) con la fórmula IDF de Uruguay a tramos.
4. `J15` (`CA`, corrección por área) — usa `E20` y `J2`.
5. `J16` = precipitación máxima **en un punto** = `J6*J13*J14` (mm).
6. `J17` = precipitación máxima **en el área** = `J6*J13*J14*J15` (mm) — es
   la que se usa para el método Racional.
7. `E19` (intensidad, mm/h) = `J17/E20`.
8. `E21` (área en Ha) = `J2*100`.
9. **`E22` = Qmax método Racional (m³/s)** = `E18*E19*E21/360`, con
   `E18=J3` (coeficiente c). **Esta es la celda de resultado final del
   método Racional.**

### 1.d) Método NRCS — tormenta de diseño + Número de Curva (bloque B24:P43)

1. `E26` = intervalo Δt = `J4/7` (horas) — el bloque alterno usa **12
   intervalos** de este ancho.
2. `E27` = retención potencial máxima **S** (mm) = `25.4*(1000/J7-10)`
   (fórmula estándar SCS, usa el NC de `J7`).
3. `I26` = grupo hidrológico (= `J8`); `I27` = piso de infiltración mínima
   (mm/h) = `IF(I26="A", 2.4, 1.2)` — o sea 2.4 mm/h solo para grupo A, y
   1.2 mm/h para B, C **y también D** (no hay un valor distinto para D,
   usa el mismo piso que B/C).
4. **Tabla de la tormenta de diseño, filas 32 a 43 (12 bloques), columnas B a P:**

   | Col | Contenido | Fórmula (fila 32 de ejemplo) |
   |---|---|---|
   | B | nº de bloque (1..12) | dato fijo |
   | C | duración acumulada (hs) | `=B32*$E$26` |
   | D | P(3,10) constante | `=$J$6` |
   | E | CD(duración) | fórmula IDF por tramos |
   | F | CT(Tr) constante | igual que `J13` |
   | G | CA(duración, área) | fórmula IDF |
   | H | P máxima acumulada (mm) para esa duración | `=D*E*F*G` |
   | I | incremento de P (mm) respecto al bloque anterior | `=H(n)-H(n-1)` |
   | J | **"Tormenta" — el incremento I reordenado como bloque alterno**, con el mayor incremento en el bloque central (posición 7 de 12) y los siguientes decrecientes alternando antes/después | referencia cruzada a la columna I (p.ej. `J38=I32`, el mayor incremento va al bloque 7) |
   | K | P (tormenta) acumulada (mm) | suma corrida de J |
   | L | escurrimiento acumulado Pe(K) por fórmula NRCS | `=IF(K<=0.2*S,0,(K-0.2*S)^2/(K+0.8*S))` |
   | M | incremento de escurrimiento | `=L(n)-L(n-1)` |
   | N | "déficit inicial" = tormenta del bloque − M | `=J-M` |
   | O | tasa de déficit (mm/h) | `=N/Δt` |
   | P | **Pe corregida (mm) — la precipitación efectiva final de ese bloque**, aplicando el piso de infiltración: si la tasa de déficit `O` ≥ piso `I27`, se usa M tal cual; si no, se limita la infiltración al piso y `Pe = J - piso*Δt` | `=IF(O>=$I$27, M, J-$I$27*$C$32)` |

   **La columna P32:P43 es la serie de precipitación efectiva del evento de
   diseño** — es la que se convoluciona más abajo con el hidrograma
   unitario. El volumen total de escorrentía es `SUMA(P32:P43) * Área
   (km²) * 1000` (mm·km² → m³); en la hoja `Cálculos (grande)` esa suma NO
   está armada como celda (sí lo está en `Cálculos (chica)`, ver 2.c) —
   hay que sumarla a mano o agregar `=SUM(P32:P43)`.

### 1.e) ⚠️ Advertencia importante: el factor ×1.15 en `J4`

`J4 = C7*1.15`, es decir, la celda que fija el Tc para **toda** la planilla
(curvas IDF, tabla de la tormenta, hidrograma unitario) trae el Tc de
Kirpich (`C7`) multiplicado por 1.15. **Ese factor NO se usó en ninguno de
los 4 exámenes ya resueltos** — en los 4 casos el tc adoptado coincide
exactamente con `C7` (Kirpich puro), no con `J4`. Por ejemplo, con los
valores que trae la propia planilla precargados (L=5.5 km, S=1.636%,
idénticos a `resueltos/2025_FEBRERO 2` Ejercicio 2 — cuenca de Río Negro):
`C7 = 1.2297 hs` (= 73.8 min, el valor oficial del examen) mientras que
`J4 = 1.4143 hs` (= 84.9 min, **no** coincide con ningún examen resuelto).

**Qué hacer en el examen:** antes de dar por buenos los resultados,
reemplazá la fórmula de `J4` por `=C7` (borrando el `*1.15`), salvo que el
enunciado pida explícitamente algún ajuste de ese tipo. Si no querés tocar
`J4`, como mínimo revisá que todas las celdas que dependen de él (`E20`,
`B14`, `E26`, `D61`) terminen usando el Tc correcto.

En la hoja **`Cálculos (chica)`**, en cambio, `J4=D6` usa el Tc de Kirpich
sin ningún factor adicional — ahí no hace falta corregir nada.

### 1.f) Hidrograma unitario triangular SCS (bloque B58:H68)

1. `D61` (Tp, tiempo al pico) = `=J4/14+0.6*J4` — equivalente a
   `Tp = Δt/2 + 0.6·Tc` con `Δt=Tc/7` (el Δt del bloque alterno).
2. `D62` (Tb, tiempo base) = `=2.667*D61`.
3. `D63` (qp, caudal pico) = `=0.208*J2/D61` — **en m³/s por cada mm** de
   precipitación efectiva (toda la planilla trabaja las láminas en mm, no
   en cm; si comparás con apuntes que usan la constante "2.08" en vez de
   "0.208", es la misma fórmula pensada para cm en vez de mm — no mezcles
   ambas convenciones).
4. `F61:G63` arman las 3 coordenadas del triángulo (0,0) → (Tp, qp) → (Tb,
   0); `G67`/`G68`/`H68` son la pendiente de subida, la pendiente de
   bajada y la ordenada al origen de la rama de bajada, usadas después
   para generar la forma del hidrograma unitario en cualquier instante t.

### 1.g) Hietograma / hidrograma de crecida final (bloque B71:R172)

- Fila 73 (`E73:P73`) trae los 12 valores de Pe corregida (`=P32`...`=P43`)
  como cabecera de cada uno de los 12 pulsos de lluvia efectiva.
- Filas 74 a 172, columna `C`, son instantes de tiempo cada `Δt/4` horas
  (paso fino para dibujar la curva).
- Columna `D` (por fila) es la ordenada del hidrograma unitario en ese
  instante (triángulo de la sección 1.f).
- Columnas `E` a `P` (una por cada uno de los 12 pulsos) van la
  convolución: cada pulso escala y desplaza en el tiempo la misma curva
  triangular unitaria, multiplicada por su Pe (fila 73).
- Columna `Q` = suma de esas 12 contribuciones en cada instante = caudal
  total del hidrograma de crecida (m³/s) en ese instante.
- **`R74` = `MAX(Q74:Q172)` = el caudal máximo NRCS del evento (Qmax
  NRCS).** Esta es la celda de resultado final del método NRCS.

### 1.h) Cuál caudal adoptar

La hoja `Cálculos (grande)` **no arma automáticamente** una comparación
final entre métodos (a diferencia de la hoja `chica`, ver 2.d). Hay que
mirar a mano:
- **`E22`** = Qmax método Racional.
- **`R74`** = Qmax método NRCS.

y aplicar el criterio del Teórico según el Tc ya corregido (sección 1.e):
Tc<20 min → usar solo `E22`; Tc>1 h → usar solo `R74`; 20 min<Tc<1 h →
calcular ambos y quedarse con el mayor. **Importante:** la planilla calcula
igual ambas celdas aunque el método no corresponda (p.ej. si Tc>1 h igual
calcula `E22`) — el criterio de cuál usar lo tenés que aplicar vos, no la
planilla.

---

## 2) Hoja "Cálculos (chica)"

Misma lógica y misma disposición de filas que `Cálculos (grande)` (filas
1–172 corresponden 1 a 1: fila 4=Tc, fila 27=S(NC), filas 32–43=tormenta de
diseño, fila 61–63=hidrograma unitario, fila 74–172=hidrograma final,
`R74`=Qmax NRCS), con estas diferencias:

### 2.a) Doble columna de datos (comparar dos cuencas)

- Columna **C** (filas 3–7) = datos de la **cuenca grande** (Área, L,
  pendiente, Tc) — es una copia/comparación, no alimenta el resto de la
  hoja.
- Columna **D** (filas 3–7) = datos de la **cuenca chica**, y es la que sí
  alimenta el resto (`J2=D3`, `J4=D6`, etc.). **Si tu ejercicio es de una
  sola cuenca, cargá los datos en la columna D**, no en la C.
- `D5` puede ser un dato directo o `=N9`, que la calcula a partir de un
  desnivel y una longitud cargados en el bloque auxiliar `L11:N15`:
  `M13`=longitud (m), `M15`=`ΔH` (podés escribir directamente
  `=cota_max-cota_min`, p.ej. `=88-43`), `M14`=`M15/M13*100` (pendiente %),
  `N9`=`(M15/M13)*100` (mismo resultado, celda final). Es útil cuando el
  enunciado da dos cotas en vez de la pendiente ya calculada.

### 2.b) Número de Curva ponderado por uso de suelo mixto (bloque L1:N5)

Solo en esta hoja hay un bloque para **NC ponderado** cuando la cuenca
tiene mezcla de usos de suelo (p.ej. % cultivo + % pastizal):

| Celda | Contenido |
|---|---|
| `M2` | % de área con uso "cultivo" (fracción 0–1) |
| `N2` | % de área con uso "pastizal" = `=1-M2` |
| `M3` | NC del uso "cultivo" (tabla NRCS) |
| `M4` | NC del uso "pastizal" (tabla NRCS) |
| `M5` | **NC ponderado a usar** = `=M4*N2+M2*M3` (ojo con el orden: es NC_pastizal×%pastizal + %cultivo×NC_cultivo) |
| `J7` | = `M5` (se conecta automáticamente al resto de la hoja) |

Si tu cuenca es de un solo uso de suelo, cargá el NC directo en `J7` (como
en la hoja grande) y no toques este bloque.

**Ojo:** el NC ponderado no aparece sólo por mezcla de **usos de suelo**
(cultivo/pastizal). También aparece cuando la cuenca tiene un único uso de
suelo pero está repartida entre **dos Unidades Cartográficas de suelo con
distinto Grupo Hidrológico** (p.ej. "Río Branco 85% Grupo D + Andresito
15% Grupo B", ambas en pastizales condición mala — 2020 dic, Ej.2). El
bloque `M2:M5` sirve igual: `M3`/`M4` pasan a ser el NC de cada unidad de
suelo (mismo uso, distinto GH, leído dos veces de la Fig 3.1.20 con el GH
de cada unidad) en vez de el NC de dos usos distintos; la fórmula
`M5=M4*N2+M2*M3` es la misma.

### 2.c) Volumen de escorrentía (bloque L19:O47)

A diferencia de la hoja grande, acá **sí** está armada la suma:
- `P44` = `=SUM(P32:P43)` → precipitación efectiva total del evento (mm).
- `O46` ("Vol Escorrentia") = `=P44*J2*1000` → **volumen de escorrentía en
  m³** (mm·km²×1000 = m³). Esta es la celda a mirar cuando el ejercicio
  pide el volumen que debe contener un embalse de retención o similar.

### 2.d) Comparación final de métodos (bloque H19:J22)

A diferencia de la hoja grande, acá sí hay una cajita de comparación
armada:
- `I19`/`J19` = etiquetas "Metodo NRCS" / "Metodo Racional".
- `I20` = `=R74` (Qmax NRCS).
- `J20` = `=E22` (Qmax Racional).

Mirá estas dos celdas juntas y aplicá igual el criterio según Tc (la
planilla tampoco decide sola cuál adoptar).

### 2.e) Notas de AMC / condición de humedad antecedente (bloque P1:Q7)

Hay un bloque de **texto libre** (no fórmulas) en `P1:Q7` con recordatorios
del propio autor de la planilla sobre el flujo de trabajo para estimar Tr a
partir de un evento extremo observado y sobre la corrección de NC por
condición de humedad antecedente (AMC I/AMC III). **No es una calculadora
funcional** — son notas para acordarse del procedimiento, no hay celdas que
calculen NC(I) o NC(III) automáticamente. Si el ejercicio pide corregir el
NC por AMC seco/húmedo, hay que aplicar las fórmulas de conversión de NC a
mano (Teórico §3.1.5 b) y escribir el NC corregido directamente en `J7`
(pisando la fórmula `=M5` si estaba puesta).

---

## 3) Hoja "Horton" — vacía, no usar

La hoja `Horton` está completamente vacía (una sola celda `A1` sin
contenido, sin fórmulas). Es un placeholder que nunca se desarrolló. **Los
ejercicios de infiltración por el modelo de Horton NO se resuelven con esta
planilla**: hay que aplicar la fórmula a mano/calculadora,
`f(t) = f_c + (f₀ - f_c)·e^(-K·t)`, comparando en cada bloque de lluvia la
intensidad del bloque contra `f(t)` evaluada en el tiempo transcurrido
desde el inicio del evento, para encontrar el tiempo de encharcamiento e
integrar el volumen infiltrado (ver ejemplo completo en
`resueltos/2025_FEBRERO 2/RESOLUCION.md`, Ejercicio 3, Partes 2.1–2.2, y el
script `resueltos/2025_FEBRERO 2/scripts/ej3_parte2_horton.py`).

---

## 4) Hoja "Hoja 4" — precipitación efectiva de un hietograma dado

Se usa cuando el enunciado **ya da un hietograma observado** en bloques
(no hay que construir la tormenta de diseño por bloque alterno) y pide la
precipitación efectiva por el método del Número de Curva.

| Celda(s) | Contenido |
|---|---|
| `A1`, fila 1 (`B1:G1`, ejemplo con 6 bloques) | tiempos en **minutos** de cada bloque (10, 20, 30...) |
| `A2`, fila 2 (`B2:G2`) | precipitación de cada bloque (mm) — **dato de entrada**, cargar acá el hietograma del enunciado (agregar más columnas a la derecha si hay más bloques) |
| `A3`, fila 3 (`B3:K3`) | precipitación acumulada: `B3=B2`, luego cada celda = `celda_anterior + P del bloque` |
| `M2` | Número de Curva NC — **dato de entrada** |
| `M3`/`N3` | `S` = `=25.4*(1000/N2-10)` (retención potencial máxima, mm) |
| `A4`, fila 4 (`B4:K4`) | escurrimiento acumulado (Pe acumulada) por bloque: `=IF(P_acum<=0.2*S, 0, (P_acum-0.2*S)^2/(P_acum+0.8*S))` |
| `A5`, fila 5 (`B5:K5`) | **Pe de cada bloque (mm) — el resultado final**: `B5=B4`, luego `=Pe_acum(n)-Pe_acum(n-1)` |

Notar que **esta hoja no aplica el piso de infiltración** (columna O/piso
mínimo mm/h) que sí tienen las hojas grande/chica — es el método NC "puro",
sin la corrección adicional. Si el ejercicio pide esa corrección, hay que
agregarla a mano después de leer la fila 5, o replicar las columnas N/O/P
de la hoja grande (sección 1.d) a mano al lado.

---

## 5) Mini-ejemplo de referencia (resuelto y verificado)

Uso este ejemplo porque **los valores que trae precargados la propia hoja
`Cálculos (grande)`** (`C3=8`, `C4=5.5`, `C5=1.636`, `J3=0.38`, `J5=10`,
`J6=90`, `J7=69`, `J8="B"`) **coinciden exactamente** con los datos del
Ejercicio 2 de `resueltos/2025_FEBRERO 2/RESOLUCION.md` (cuenca del Río
Negro): Área=8 km², ΔH=90 m, L=5500 m, Grupo Hidrológico B, Tr=10 años,
P(3,10)=90 mm, NC=69, c=0.38. Esto permite verificar la planilla contra un
resultado oficial ya confirmado.

**Paso a paso:**

1. Cargar en `Cálculos (grande)`: `C3=8` (Área km²), `C4=5.5` (L cauce
   ppal, km), `C5=1.636` (S cauce ppal, %, = 90/5.5/10), `J3=0.38` (c),
   `J5=10` (Tr), `J6=90` (P3,10), `J7=69` (NC), `J8="B"` (grupo hidrológico).
2. Mirar `C7` (Tc de Kirpich) → **1.2297 hs = 73.8 min**. **Usar este
   valor**, no `J4` (recordar la advertencia 1.e: `J4=1.4143 hs` está
   mal). En el examen conviene directamente sobreescribir `J4` con `=C7`
   antes de seguir.
3. Con Tc=73.8 min (>1 h... en rigor 73.8 min>60 min), el criterio del
   Teórico dice: **usar solo el método NRCS** (Racional no corresponde
   para Tc>1 h). La hoja igual calcula ambos:
   - `E22` (Racional, calculado igual aunque no corresponda) ≈ 38 m³/s
     (no es la respuesta del examen, se descarta por Tc>1h).
   - `R74` (NRCS) — con `J4` corregido a `=C7`, debería dar **≈25.6 m³/s**
     (valor oficial del examen; el valor que trae cacheado la planilla,
     ≈25.7 m³/s, corresponde al `J4` sin corregir y por eso difiere
     levemente).
4. Resultado final adoptado: **Qmax de diseño (Tr=10 años) ≈ 25.6 m³/s**,
   método NRCS, con tiempo al pico ≈2.24 h desde el inicio de la tormenta
   de diseño (comparar contra `resueltos/2025_FEBRERO 2/RESOLUCION.md`,
   Ejercicio 2, Parte 1).
5. Volumen de escorrentía de ese evento: sumar `P32:P43` (o pasar los
   datos a la hoja `chica` para usar `O46` directo) → Pe total ≈17.0 mm →
   `Vesc = 17.0 mm × 8 km² × 1000 ≈ 135 900 m³` (coincide con
   `resueltos/2025_FEBRERO 2/RESOLUCION.md`, Ejercicio 2, Parte 2:
   135 932 m³).

Otro ejemplo de referencia útil, con números distintos y **cuenca chica**
de dos usos de suelo, es el Ejercicio 2 de `resueltos/2024 diciembre/RESOLUCION.md`
(Tacuarembó: Área=7.5 km², ΔH=90 m, L=3800 m, S cauce=2.37%, Tr=5,
P310=90 mm, NC=80 (suelo D), c=0.28; tc=48.1 min ⇒ 20 min<tc<1h ⇒ calcular
Racional y NRCS y quedarse con el mayor: Qmax NRCS=35.3 m³/s > Qmax
racional=30.9 m³/s).

**Ejemplo con hietograma OBSERVADO (reemplaza la tormenta de bloque
alterno, manteniendo el piso de infiltración de la hoja grande) +
inversión de Tr**, Ejercicio 2 de `resueltos/2022 diciembre/RESOLUCION.md`
(Maldonado: Área=7.6 km², ΔH=130 m, L=3265 m, Grupo D, pastizales
condición mala, tc=35.1 min, P310=76 mm, NC=89, C=0.38). Parte 1: igual
que el flujo estándar de la sección 1 (tormenta de diseño por bloque
alterno, Tr=10) ⇒ Qmax NRCS=66.76 m³/s > Racional=49.60 m³/s ⇒ se adopta
NRCS; Vesc=169 501 m³. Parte 2.1: con P5d=25 mm en julio (estación
inactiva), AMC cae en el rango II (12.7–27.94 mm) ⇒ NC se mantiene sin
corregir; se **sustituye la columna de la tormenta (N/"J" de la hoja
grande) por el hietograma realmente registrado, en su orden
cronológico** (sin reordenar por bloque alterno), pero conservando el
resto de la lógica (Pe por NC, piso de infiltración, mismo hidrograma
unitario triangular ya calculado con el mismo tc) ⇒ Qmax evento=86.81
m³/s. Parte 2.2: se invierte CT(Tr) con el bloque más intenso del
hietograma (P=16.5 mm en d=5 min, CA=1 por ser dato puntual) ⇒ Tr≈19
años (mismo procedimiento que la sección de "Errores comunes" ítem 9,
aplicado sobre un dato de pluviógrafo en vez de sobre un caudal límite).

**Ejemplo con NC ponderado por Unidades Cartográficas de suelo (mismo uso,
distinto Grupo Hidrológico) + inversión de Tr por caudal límite tras un
cambio de tc + hietograma OBSERVADO con el tc nuevo**, Ejercicio 2 de
`resueltos/2020 Diciembre/RESOLUCION.md` (Rocha: Área=8.3 km², ΔH=130 m,
L=9850 m, suelo Río Branco 85% GH D + Andresito 15% GH B, pastizales
condición mala ⇒ NC=0.85×89+0.15×79=87.5, tc=2.09 hs). Parte 1: flujo
estándar (tc>1h ⇒ sólo NRCS, sin calcular Racional) ⇒ Qmax NRCS(Tr=10)=
43.43 m³/s, Vesc=391 874 m³. Parte 2: una obra de regularización del
cauce aumenta tc un 40% (tc_new=2.929 hs); se itera Tr (mismo método del
ítem 9, con el caudal objetivo=Qmax de la Parte 1 en vez de un caudal
límite dado) hasta encontrar el Tr para el cual, con el tc_new, se vuelve
a alcanzar ese mismo Qmax ⇒ Tr≈18.1 años (con precisión de 1 año: recién
en Tr=19 el caudal de diseño queda superado, ya que en Tr=18 todavía da
43.40<43.43). Parte 3: con el tc_new ya fijo, ocurre un evento REGISTRADO
(hietograma real de 12 bloques de 25 min, que coincide con el ancho de
bloque tc_new/7 de la Parte 2 — no es coincidencia, así se arma la
tormenta de diseño) ⇒ Qmax evento=53.82 m³/s, que supera el caudal de
diseño de la Parte 1 durante 1.88 hs.

---

## 6) Errores comunes y cosas a no olvidar

1. **El factor ×1.15 en `J4` de la hoja `Cálculos (grande)`** (ver 1.e) —
   el más importante, corregirlo o usar `C7` directamente. En `Cálculos
   (chica)` no hace falta (`J4=D6` ya es el Tc puro).
2. **Pendiente del cauce principal ≠ pendiente media de la cuenca.** La
   primera (`C5`/`D5`, = ΔH/L/10) alimenta Kirpich (Tc); la segunda (dato
   aparte del enunciado) solo se usa para elegir la fila del coeficiente
   `c` en la Tabla 3.1.4. No confundir ni mezclar los dos valores.
3. **Unidades de área:** la etiqueta de `J2`/`H2` dice "A (km)" pero es
   **km²**. `E21`/`Area en Ha` convierte multiplicando por 100 — revisar
   que el área cargada en `C3`/`D3` esté en km² y no en Ha o m².
4. **La planilla calcula ambos métodos (Racional y NRCS) siempre**, aunque
   el Tc diga que solo corresponde uno. El criterio de cuál adoptar según
   Tc (§3.1.5: <20min solo Racional, 20min–1h el mayor de los dos, >1h
   solo NRCS) hay que aplicarlo manualmente mirando `E22` vs `R74` (o
   `J20`/`I20` en la hoja chica) — no hay una celda que lo decida sola.
5. **`P3,10`, `C` y `NC` son lecturas gráficas externas**, no las calcula
   la planilla: `P3,10` sale de la Figura 3.1.10 (isoyetas), `C` de la
   Tabla 3.1.4, y `NC` de la Figura/Tabla 3.1.20 del Teórico. Hay que
   leerlos primero y después cargarlos en `J6`, `J3`, `J7` (o `M3`/`M4`
   para NC ponderado en la hoja chica).
6. **Piso de infiltración mínima (`I27`):** 2.4 mm/h solo si el grupo
   hidrológico es "A"; para B, C y D siempre 1.2 mm/h — no hay una celda
   separada para D pese a que en teoría D suele ser el suelo menos
   permeable (la fórmula de la planilla trata a B/C/D igual).
7. **Limpiar celdas entre corridas:** si reusás el mismo archivo para dos
   ejercicios/cuencas del mismo examen, revisar que no queden valores
   viejos en `J3, J4 (o C4/C5/E6), J5, J6, J7, J8` (hoja grande) o en
   `C3:C7, D3:D7, M2:M5` (hoja chica) — varias fórmulas dependen en
   cascada de estas celdas y un valor viejo se arrastra silenciosamente a
   todos los resultados aguas abajo (tormenta de diseño, hidrograma,
   Qmax).
8. **Duración vs Tc:** en el método Racional la duración de la tormenta se
   toma siempre igual al Tc (`E20=J4`). Si el enunciado pide el caudal
   para otra duración específica (p.ej. la duración de un bloque del
   hietograma observado), no uses `E19`/`E22` tal cual — armá el cálculo
   de intensidad con la duración correcta.
9. **Redondeo del Tr al invertir CT(Tr):** si el ejercicio pide "encontrar
   el Tr que produce tal caudal" (sección tipo `N17:N19` de la hoja
   chica), la fórmula de CT no se invierte en forma cerrada — hay que
   iterar/tantear valores de `J5` (o usar Buscar Objetivo de Excel) hasta
   que el caudal resultante (`R74` o `E22`) coincida con el objetivo; y
   como Tr suele pedirse como entero, conviene probar el entero de abajo y
   el de arriba y quedarse con el que efectivamente cumple la condición
   (ver ejemplo en `resueltos/2024 diciembre/RESOLUCION.md`, Ejercicio 2,
   Parte 2.1).
10. **La hoja `Horton` está vacía** — no perder tiempo buscando fórmulas
    ahí, ver sección 3.
11. **`Hoja 4` no aplica el piso de infiltración mínima** (a diferencia de
    las hojas grande/chica) — si el ejercicio lo requiere, agregarlo a
    mano.

---

## 7) Nota sobre la variante `Scripts examen AA/EVENTOS EXTREMOS 2025.xlsx`

En `Scripts/01_SCRIPTS/Scripts examen AA/` hay otro archivo,
`EVENTOS EXTREMOS 2025.xlsx`, con **la misma lógica matemática** (mismas
fórmulas de CD/CT/CA, mismo método NC con bloque alterno, mismo hidrograma
unitario SCS) pero con **una disposición de celdas completamente distinta**
y hojas separadas por tipo de ejercicio (`método racional`, `NRCS -
Gande`, `NRCS - Chica`, `5.2 Racional`, `5.2 NRCS`, `EJ 2`). Es una
planilla personal ya resuelta con datos de un examen específico (marcada
"COMPLETAR" en varias celdas), no una plantilla en blanco genérica. Los
scripts de Python en `resueltos/*/scripts/ej2_parte1.py` y `ej2_parte2.py`
replican las fórmulas de **esta** variante (por eso las mencionan en sus
comentarios), pero **para operar a mano en el examen real conviene usar
`Eventos extremos.xlsx`** (la de este instructivo), que es una plantilla
en blanco pensada para cargar los datos de cualquier cuenca. Si en el
examen te encontrás con la variante AA en vez de con `Eventos
extremos.xlsx`, la lógica de cálculo es la misma pero **las celdas exactas
no coinciden** con las de este documento — hay que releer los rótulos de
esa hoja en particular.
