# Examen HHA — 16 de diciembre de 2019

Fuente: `EXAMENES/2019 Diciembre.pdf` (9 páginas). Trae **solución oficial
manuscrita** completa (páginas 5 a 9), que se usa acá para comparar cada
resultado.

---

## Ejercicio 1 (25 puntos) — FGV en canal trapezoidal entre dos lagos

### Enunciado (resumen)

Canal trapezoidal de largo **L=370 m**, ancho de fondo **b=1.5 m**, talud
lateral **m=2** (1V:2H), pendiente de fondo **S₀=0.0003**, Manning
**n=0.011**. El Lago A, en la entrada del canal, tiene su superficie libre
a **hLA=1.24 m** sobre el fondo (dato fijo en las 3 partes).

a) Si el nivel del Lago B (salida) es **hLB=1.3 m**: caudal de descarga,
   clasificación M/S, perfil de superficie libre con tirantes y resaltos.
b) Si hLB puede variar: ¿existe un rango de hLB para el cual Q deja de
   depender de hLB? En caso afirmativo, hallar ese rango y el caudal.
c) En las condiciones de b), ubicar las zonas del canal con riesgo de
   erosión si la tensión rasante máxima admisible es **τ_max=4 Pa**.

### Teoría

- **A1 (clasificación M/S) y A2 (energía específica/tirante crítico)**
  (`RESUMEN_TEORICO.md` §A1-A2): yn (Manning) vs yc (Fr=1); yn>yc ⇒ M.
- **A4 (perfiles controlados por lagos), caso "transición lago-canal
  ASIMÉTRICA"**: la **entrada** (lago→canal) es una **contracción sin
  pérdidas**, conserva energía específica: `E(y en x=0) = hLA`. La
  **salida** (canal→lago) es una **expansión brusca**, que disipa toda
  la energía cinética: el nivel del lago iguala directamente el tirante,
  `y(x=L) = hLB` (sin sumar Q²/2gA²). Esta es la misma asimetría que en
  2022 dic Ej.1, aplicada acá a un canal **tipo M** (no S) y de longitud
  finita (no "muy largo", por lo que no alcanza con yn≈y(0): hay que
  integrar el perfil completo entre los dos extremos).
- **A2 (tirante crítico maximiza Q para E dada)**: si el nivel de salida
  baja lo suficiente, el control migra a la **propia salida** del canal
  (como una caída libre interna): `y(x=L) = yc(Q)`. Por debajo de ese
  umbral, cualquier hLB menor no cambia nada aguas arriba (la información
  no viaja contra una sección crítica), así que Q queda fijo en su
  máximo compatible con la energía del Lago A.
- **A6 (tensión rasante en FGV)**: τ₀(y)=γ·Rh(y)·Sf(y) es **decreciente**
  con y — a menor tirante, mayor Sf y mayor τ₀. Se evalúa sobre el
  perfil y(x) ya resuelto para hallar dónde τ₀ supera τ_max.

### Práctica

**Herramienta:** Octave, con un método de disparo ("shooting"): para
Q de prueba se calculan yn/yc (`tirantes_yn_yc.m`), se fija la condición
de borde de **salida** (y(L)=hLB en a, o y(L)=yc(Q) en b), se integra la
EDO de FGV (`rect.m`+`critico.m`, `ode45`) **hacia aguas arriba** hasta
x=0, y se itera Q (`fzero`) hasta que la energía específica resultante
en la entrada cierre con hLA=1.24 m. Se armó un script **canónico nuevo**
`dos_lagos_trap.m` (no existía en el repo un caso de "canal corto entre
dos lagos con ambos niveles conocidos, tipo M") en
`RESUMEN EXAMEN/Codigos/FGV_trapezoidal/`, con dos modos (`'hLB_dado'`
y `'critico_salida'`), reutilizado también para la parte c. Copia
adaptada al examen: `scripts/Ejercicio1_dos_lagos_trapezoidal.m`.

#### a) hLB = 1.30 m

Entradas: hLA=1.24, hLB=1.30, b=1.5, m=2, S0=0.0003, n=0.011, L=370.

Resultado del shooting (`dos_lagos_trap(hLA,1.30,...,'hLB_dado')`):

| Q (m³/s) | yn (m) | yc (m) | y(x=0), entrada (m) | y(x=L), salida (m) |
|---|---|---|---|---|
| 3.332 | 0.9327 | 0.6062 | 1.2152 | 1.3000 (=hLB) |

- yn=0.933 > yc=0.606 ⇒ **canal tipo M (mild)**.
- Fr(entrada)=0.257, Fr(salida)=0.224 ⇒ subcrítico en toda la longitud.
- Perfil: tirante crece monótonamente de 1.215 m (entrada) a 1.300 m
  (salida) ⇒ curva **M1** (remanso), **sin resalto** (todo subcrítico).

**Q = 3.33 m³/s, canal tipo M, curva M1 sin resaltos.**

Comparación con solución oficial (manuscrita, p.5): Q=3.3 m³/s (coincide),
yc≈0.60-0.66 (coincide con yc=0.606), y(entrada)≈1.21-1.24 m (coincide
con 1.215 m calculado). Diferencias de milésimas atribuibles a redondeo
manual en la iteración.

#### b) Rango de hLB con Q independiente de hLB

Se plantea el control crítico en la salida (`dos_lagos_trap(hLA,[],...,
'critico_salida')`, y(L)=yc(Q)):

| Qmax (m³/s) | yn (m) | yc (m) | y(x=0), entrada (m) | y(x=L)=yc, salida (m) |
|---|---|---|---|---|
| 6.204 | 1.2469 | 0.8403 | 1.1317 | 0.8408 |

- Para **hLB > 0.840 m**: la salida sigue controlada por el Lago B (igual
  mecanismo que en a), y Q depende de hLB (decrece al aumentar hLB: a
  mayor tirante en la salida, el perfil completo tiene tirantes más
  altos, la entrada necesita menos velocidad —menos Q— para llegar a
  hLA=1.24 m).
- Para **0 < hLB ≤ 0.840 m** (=yc del caudal máximo): la salida pasa a
  ser una sección **crítica** (como una caída libre "interna"); aguas
  abajo de ahí el flujo es supercrítico hasta el Lago B, que ya no
  puede influir en lo que pasa aguas arriba (la perturbación no viaja
  contra flujo supercrítico). El caudal queda fijo en su valor máximo.

**Rango: 0 < hLB ≤ 0.84 m ⇒ Q = 6.20 m³/s, constante (independiente de
hLB).** Canal sigue siendo tipo M (yn=1.247>yc=0.840); perfil subcrítico
en toda la longitud, tirante decreciendo de 1.132 m (entrada) a 0.840 m
(salida, =yc) ⇒ curva **M2** (aceleración hacia el control crítico de
salida), sin resalto.

Comparación con solución oficial (p.5): Qmax=6.2 m³/s (coincide), yc=0.84
(coincide exacto), y(entrada)=1.131 m (coincide con 1.132 m).

#### c) Zonas de erosión (τ_max = 4 Pa) sobre el perfil de b)

Se evalúa τ₀(y)=γ·Rh(y)·Sf(y) a lo largo del perfil M2 de la parte b)
(el más exigente, con los tirantes más bajos):

| Sección | y (m) | τ₀ (Pa) |
|---|---|---|
| Salida (Lago B), y=yc | 0.841 | 7.99 (**> 4 Pa, erosiona**) |
| Umbral τ₀=4 Pa | 1.032 | 4.00 |
| Entrada (Lago A) | 1.132 | 2.91 (< 4 Pa, seguro) |

τ₀ es decreciente con y (A6), así que el riesgo se concentra donde el
tirante es más bajo, es decir cerca de la salida. El cruce con τ_max=4 Pa
ocurre a x≈263 m (medido desde la entrada), es decir a **≈107 m de la
salida**.

**Riesgo de erosión en los últimos ≈107 m del canal, contados desde el
Lago B (salida), donde y < 1.03 m.** El resto del canal (los ≈263 m
desde el Lago A) tiene τ₀<4 Pa y no erosiona.

Comparación con solución oficial (p.5): "y=1.03 m en la zona n2 → L≈105 m
desde el final del canal, se deben proteger los últimos 105 m". Coincide
con el resultado calculado (≈107 m vs 105 m, diferencia atribuible a la
precisión de la lectura gráfica manuscrita).

---

## Ejercicio 2 (25 puntos) — Método Racional, NRCS y área urbanizable máxima

### Enunciado (resumen)

Cuenca en Colonia, punto de cierre X=350 km, Y=6250 km. Uso de suelo:
**pastizales, condición hidrológica buena**; unidad de suelos **Ecilda
Paullier - Las Brujas**; flujo **concentrado**. Datos: Área=4.15 km²,
Lcp=2.05 km, ΔH=38 m, S(cuenca)=1.95%.

1) Caudal de diseño de una alcantarilla en el punto de cierre, Tr=5 años.
   Justificar la metodología.
2) Con esa obra construida, se proyecta una urbanización (áreas
   concreto/techo). Máxima superficie urbanizable si el caudal de diseño
   puede aumentar hasta 20% (mismo Tr, mismo tc, no cambia por la
   urbanización).
3) En el escenario de 2), un evento extremo da Q=32 m³/s en el punto de
   cierre. Hallar su período de retorno.

### Teoría

- **B2 (tiempo de concentración, Kirpich)**: tc=0.4·L^0.77/S^0.385, con S
  del **cauce principal** (ΔH/L/10), no la pendiente media de la cuenca.
- **B3 (curvas IDF de Uruguay)**: P=P(3,10)·CT(Tr)·CD(d)·CA(A,d).
- **B4 (método Racional, criterio de selección según tc)**: con
  20 min<tc<1 h se calculan **ambos** métodos (Racional y NRCS) y se
  adopta el **mayor** caudal.
- **B4, "Coeficiente de escorrentía ponderado y área urbanizable
  máxima"**: si tc no cambia con la urbanización, Q∝C (i y A quedan
  fijos), así que el área urbanizable máxima sale en forma cerrada:
  `C*_objetivo=(1+x%)·C_original` y `A₂=A_T·(C*−C1)/(C2−C1)`.
- **B4, "hallar el Tr de un caudal límite dado"**: C sale de la Tabla
  3.1.4 (Chow), tabulada en columnas discretas de Tr (2,5,10,25,50,100).
  Acá, en vez de quedarse con el escalón tabulado más próximo, se
  **interpola linealmente** C entre las dos columnas adyacentes (10 y 25
  años) para estimar el Tr "exacto" que da Q=32 m³/s — variante más
  precisa del mismo procedimiento cuando se pide directamente el Tr de un
  evento (no solo verificar si supera un umbral).
- **B5 (NRCS)**: NC de Fig. 3.1.20 (pastizal, condición **buena**, grupo
  **C** ⇒ **NC=74**); grupo hidrológico de la unidad "Ecilda
  Paullier-Las Brujas" ⇒ **C** (Tabla 3.1.5, Durán 1997).
- **Tabla 3.1.4 (Chow, Teórico HHA pág. 9)**, filas usadas: "Pastizales,
  Plano 0-2%" (Tr=2,5,10,25,50,100,500 ⇒ C=0.25, 0.28, 0.30, 0.34, 0.37,
  0.41, 0.53) y "Concreto/techo" (C=0.75, 0.80, 0.83, 0.88, 0.92, 0.97,
  1.00). S(cuenca)=1.95% cae en la fila "Plano 0-2%".

### Práctica

**Herramienta:** Python, replicando exactamente las fórmulas de la hoja
`Cálculos (grande)` de `Eventos extremos.xlsx`
(`RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md`) — IDF de
Uruguay, método Racional, y método NRCS (bloque alterno + NC + hidrograma
unitario triangular SCS). Se eligió Python en vez de operar la planilla a
mano porque las partes 2) y 3) piden **iterar** el modelo (despejar un
área y, después, invertir un Tr), lo que conviene automatizar en vez de
recalcular la hoja celda a celda en cada tanteo. Script:
`scripts/Ejercicio2_racional_NRCS.py` (la función `Q_nrcs` se validó
contra el mini-ejemplo de referencia de `COMO_USAR_EVENTOS_EXTREMOS.md`
§5, cuenca del Río Negro, Tr=10: reproduce Qmax NRCS=25.6 m³/s).

#### 1) Caudal de diseño (Tr=5 años)

- S(cauce)=ΔH/Lcp/10=38/2.05/10=1.854% ⇒ **tc (Kirpich) = 0.548 h ≈ 33
  min**. Como 20 min<tc<1 h, corresponde calcular **ambos** métodos.
- **Racional:** C(pastizal, Tr=5, Tabla 3.1.4)=0.28; i(Tr=5, d=tc)=61.4
  mm/h ⇒ **Q_racional = 19.8 m³/s**.
- **NRCS:** NC=74, con la tormenta de diseño por bloque alterno (12
  bloques, Δt=tc/7) ⇒ **Q_NRCS ≈ 9.7 m³/s**.

**Q_diseño = 19.8 m³/s (método Racional, por ser el mayor de los dos).**

Comparación con la solución oficial (p.6): Q_racional=19.7 m³/s (coincide,
diferencia de milésimas por redondeo de tc/P310), Q_NRCS≈10.2 m³/s (algo
más alto que el calculado, 9.7 m³/s — la diferencia no cambia el método
adoptado, ya que en ambos casos el Racional sigue siendo mayor).

#### 2) Área urbanizable máxima (+20% del caudal, mismo tc)

Con Tr=5 fijo y tc fijo, i no cambia: Q=C·i·A/360 ⇒ Q∝C. El objetivo es
C\*=Q\*·360/(i·A) con Q\*=1.2·19.8=23.8 m³/s:

- **C\* objetivo = 0.336** (Cpast=0.28, Cct=0.80 a Tr=5).
- `x = (C*−Cpast)/(Cct−Cpast) = 0.108` (10.8% del área).
- **Área urbanizable máxima = 0.108×4.15 km² ≈ 0.447 km² ≈ 44.7 ha.**

Comparación con la solución oficial (p.6): Área≈43.95 ha (coincide, dentro
del margen de redondeo de los pasos anteriores).

#### 3) Período de retorno del evento Q=32 m³/s

Con la fracción urbanizada x=0.108 fija (misma cuenca de la parte 2), se
itera Tr en el método Racional con el **coeficiente ponderado** C\*(Tr)
= Cpast(Tr)·(1−x) + Cct(Tr)·x, interpolando Cpast(Tr) y Cct(Tr)
linealmente entre las columnas tabuladas de la Tabla 3.1.4:

| Tr (años) | Cpast(Tr) | Cct(Tr) | C\*(Tr) | i (mm/h) | Q (m³/s) |
|---|---|---|---|---|---|
| 10 | 0.300 | 0.830 | 0.357 | 71.4 | 29.4 |
| 15 | 0.313 | 0.847 | 0.371 | 77.1 | 32.9 |
| **13.57** | **0.309** | **0.842** | **0.367** | **75.4** | **32.0** |

**Tr ≈ 13.6 años (≈14 años redondeando al entero).**

Comparación con la solución oficial (p.6): tabla con Tr=10 (Q=29.3) y
Tr=15 (Q=32.7) ⇒ Tr≈14 años (coincide con el resultado interpolado
≈13.6-14 años; ambos usan el mismo método de interpolar linealmente C
entre las columnas tabuladas de Tr en vez de solo verificar el escalón
discreto más próximo).

---

## Ejercicio 4 (25 puntos) — Punto de funcionamiento de una bomba, cota máxima sin cavitar

### Enunciado (resumen)

Bomba única que eleva agua desde un tanque inferior (zT1=0 m) a un tanque
elevado (zT2=25 m). Tuberías de succión e impulsión, ambas D=250 mm,
ε=0.02 mm; Ls=25 m (succión, k=2.5 localizado); Lt=550 m (impulsión
total, k=1.5 localizado, incluye la descarga al tanque elevado). Cota
del eje de la bomba zA=2 m. Curva de la bomba (tabla Q-H-NPSHr-η dada).

1) Punto de funcionamiento: a) Q bombeado; b) verificar que no cavita;
   c) potencia consumida.
2) Máxima cota a la que se puede colocar la bomba (para alejarla del
   tanque inferior) sin que cavite, con las mismas longitudes/pérdidas.
3) En la cota límite de 2), el tanque elevado sube a 30 m: ¿cavita la
   bomba en esta nueva configuración?

**Nota sobre la solución oficial manuscrita (p.9):** el esquema
manuscrito trae datos de tubería **distintos** a los de la letra impresa
(L=29 m/k=2.6 en succión y L=850 m/k=2 en impulsión, en vez de Ls=25 m/
k=2.5 y Lt=550 m/k=1.5 de la letra). Esto es consistente con lo ya visto
en otros exámenes de este curso (p.ej. `resueltos/2020 Diciembre/`) donde
el ejercicio de bombas trae **datos individualizados por alumno/variante**
mientras el resto del examen es común — por eso Ejercicios 1 y 2
coinciden casi exactamente con la manuscrita pero este Ejercicio 4 no. Se
resuelve acá con los datos de la **letra impresa** (la fuente autoritativa
para este examen), y se compara solo la **metodología** contra la
manuscrita, no los valores numéricos exactos.

### Teoría

- **C1 (ecuación de la instalación)**: Hm(Q)=(z2−z1)+Δh(succión,Q)+
  Δh(impulsión,Q), con Δh=f·(L/D)·v²/2g (Colebrook-White) + k·v²/2g. Esta
  ecuación **no depende de zA** (la cota de la bomba no aparece en ningún
  término): mover la bomba a lo largo de la misma tubería no cambia el
  punto de funcionamiento (Q,H), sólo cambia el NPSH disponible.
- **C2 (punto de funcionamiento)**: intersección de la curva de la bomba
  H(Q) (catálogo) con Hm(Q) (instalación).
- **C3 (potencia)**: P=γ·Q·H/η, con η interpolado en el Q del punto de
  funcionamiento.
- **C4 (cavitación) y "Cota máxima de la bomba sin cavitar"**: NPSH_disp
  depende sólo del tramo de succión y de zA; como Q no cambia con zA
  (ver C1), el margen NPSH_disp−NPSH_req en el punto de funcionamiento
  actual se puede sumar directamente a la zA actual para hallar la cota
  límite: zA,max = zA + (NPSH_disp−NPSH_req).

### Práctica

**Herramienta:** Octave, adaptando `Bombas/Bomba_sola.m` (intersección
numérica curva de bomba vs. curva de instalación, con `colebrook.m` para
el factor de fricción) — es exactamente el caso que ese script resuelve
(una bomba única, succión+impulsión con Colebrook). Script:
`scripts/Ejercicio4_bomba.m`.

#### 1) Punto de funcionamiento

| Q (m³/s) | H (m) | η (%) | Potencia (kW) | NPSH_disp (m) | NPSH_req (m) |
|---|---|---|---|---|---|
| 0.0688 | 28.84 | 75.3 | 25.85 | 7.70 | 4.80 |

**Q = 0.069 m³/s (68.8 L/s), H = 28.8 m, P = 25.9 kW. NPSH_disp=7.70 m >
NPSH_req=4.80 m ⇒ NO cavita** (margen de 2.90 m).

#### 2) Cota máxima de la bomba sin cavitar

Como Hm(Q) no depende de zA, el Q y el margen NPSH_disp−NPSH_req=2.90 m
de la parte 1 no cambian al mover la bomba: la cota límite es
directamente zA + margen.

**zA,max = 2 + 2.90 = 4.90 m.**

#### 3) Con zA=4.90 m y el tanque elevado a 30 m: ¿cavita?

Al subir zT2 de 25 a 30 m cambia la curva de instalación (mayor desnivel
estático) ⇒ nuevo punto de funcionamiento, con **menor Q** (la curva de
la bomba es decreciente en H, y ahora se necesita más H):

| Q (m³/s) | H (m) | NPSH_disp (m) | NPSH_req (m) |
|---|---|---|---|
| 0.0514 | 32.22 | 4.97 | 3.20 |

**NPSH_disp=4.97 m > NPSH_req=3.20 m ⇒ NO cavita** (margen de 1.77 m,
más ajustado que en la parte 1, pero todavía seguro).

Comparación metodológica con la solución oficial (p.9, datos de tubería
distintos según la nota de arriba): mismo procedimiento en las 3 partes
(punto de funcionamiento por intersección de curvas, margen NPSH para la
cota máxima, recálculo completo del PF al cambiar el nivel del tanque
elevado) y misma conclusión cualitativa (no cavita en ningún caso).

---

## Ejercicio 3 (25 puntos) — Delimitación de cuenca, pendiente, índice de compacidad y Tr

### Enunciado (resumen)

1) En la carta topográfica adjunta (SGM, curvas de nivel cada 5 m),
   delimitar la cuenca de la cañada "Sin nombre", afluente del arroyo La
   Pedrera (Canelones), punto de cierre X=491.9 km, Y=6173.0 km.
2) Pendiente por extremos del cauce principal (Lcp=4150 m dato).
   Seleccionar el índice de compacidad más apropiado entre Ic=1.0, 1.1,
   1.4, justificando.
3) Período de retorno de una precipitación P=45 mm en d=1 hora,
   registrada en un pluviógrafo dentro de la cuenca delimitada.

### Teoría

- **B1 (delimitación de cuencas)**: la divisoria corta perpendicular a
  las curvas de nivel, por el lado convexo al ganar altura y cóncavo al
  perderla, y nunca cruza un curso de agua salvo en el punto de cierre.
  Índice de compacidad Ic=[√π/(2π)]·P/√A: cuencas muy alargadas (como una
  cañada angosta que sigue un único valle) dan Ic sensiblemente mayor a
  1 (cuenca circular ideal, Ic=1).
- **B2 (pendiente por extremos)**: S=ΔH/Lcp (Lcp en km, ΔH en m, S en %
  tras dividir entre 10 según la convención de Kirpich) — acá sólo se
  pide la pendiente, no Tc.
- **B3 (curvas IDF, "hallar el Tr de un evento observado")**: se invierte
  P=P(3,10)·CT(Tr)·CD(d) (CA=1, dato puntual de pluviógrafo) despejando
  CT(Tr)=P/(P310·CD(d)) e invirtiendo numéricamente CT(Tr) (sin forma
  cerrada).

### Práctica

**Herramienta y limitación importante:** la carta topográfica es un
escaneo de muy baja resolución (fotocopia de varias generaciones de un
plano SGM 1:50000 de curvas cada 5 m). Se renderizó la página 3 del PDF
del examen a 300 dpi y se inspeccionó visualmente (Python/Pillow) para
ubicar el **punto de cierre** (el círculo gris impreso en el plano, que
coincide exactamente con un cruce de la cuadrícula, consistente con
X=491.9/Y=6173.0) y el arroyo **La Pedrera** (rotulado en el plano), con
una cañada tributaria sin nombre que baja desde el N/NE y se une a la
Pedrera justo en el punto de cierre. **A la resolución disponible del
escaneo no se puede trazar la divisoria de aguas con precisión de
milímetro** (las curvas de nivel finas se distinguen apenas del ruido de
la fotocopia): se muestra en `scripts/ej3_cuenca_delimitada.png` el punto
de cierre confirmado y una divisoria **esquemática/aproximada**
(polígono alargado siguiendo el valle visible de la cañada tributaria,
según el criterio de B1), suficiente para razonar la forma general de la
cuenca (Parte 2) pero **no** para medir un área con precisión.

#### 1) Delimitación (ver `scripts/ej3_cuenca_delimitada.png`)

Punto de cierre localizado (círculo rojo en la imagen, sobre el marcador
impreso del examen). Divisoria aproximada trazada siguiendo el valle de
la cañada tributaria hacia aguas arriba (magenta en la imagen),
perpendicular a las curvas de nivel visibles, sin cruzar el cauce salvo
en el punto de cierre — **de forma esquemática dada la resolución del
escaneo** (ver limitación arriba).

#### 2) Pendiente por extremos e índice de compacidad

Elevaciones leídas de las cotas/curvas visibles en el plano: cota más
alta del cauce (naciente, zona norte de la cuenca) ≈**55 m**; cota en el
punto de cierre ≈**26 m** (coincide con la cota puntual "26.3" rotulada
junto a la confluencia con La Pedrera, visible en el escaneo). Con
Lcp=4150 m (dato):

```
ΔH = 55 - 26 = 29 m
S_cp = ΔH / Lcp / 10 = 29 / 4.15 / 10 = 0.699 % ≈ 0.70 %
```

**S_cp ≈ 0.70 %.**

**Índice de compacidad: Ic = 1.4** (el mayor de los tres valores dados).
Justificación: una cañada tributaria que recorre 4150 m de longitud
siguiendo un único valle angosto (visible en el plano: el corredor de la
cañada es apenas más ancho que 1 celda de la cuadrícula de 1 km, a lo
largo de más de 4 celdas) es una cuenca **muy alargada** — Ic se aleja
mucho de 1 (círculo) cuanto más elongada y angosta es la forma, por lo
que corresponde el valor más alto de la terna dada.

Comparación con la solución oficial (p.7): S_cp=(55-26)/4150m=0.007=0.7%
(coincide exactamente) e Ic≈1.4 (coincide, mismo razonamiento de "cuenca
muy alargada").

#### 3) Período de retorno de P=45 mm en d=1 h

P(3,10) en el punto de cierre: **79 mm**, leído de la Fig. 3.1.10
(isoyetas) — confirmado independientemente renderizando esa figura del
Teórico HHA: el punto (X=491.9, Y=6173.0) cae inmediatamente al lado de
la isolínea gruesa de 80 mm (levemente por debajo), consistente con
≈79 mm.

Con CA=1 (dato puntual de pluviógrafo, sin corrección de área) y
CD(d=1h)=0.6208·1/(1.0137)^0.5639=**0.616** (fórmula exacta de la IDF de
Uruguay — ver `scripts/Ejercicio3_parte3_Tr.py`, validado contra las dos
fuentes primarias, Teórico HHA y Formulómetro, que traen la misma
fórmula):

```
CT(Tr) objetivo = P/(P310·CD) = 45/(79×0.616) = 0.9246
```

Invirtiendo CT(Tr) numéricamente (`fzero`/bisección):

| Tr (años) | P(Tr)=P310·CT(Tr)·CD (mm) |
|---|---|
| 2 | 31.5 |
| 5 | 41.8 |
| 10 | 48.7 |
| **6.86** | **45.0** |
| 25 | 57.3 |

**Tr ≈ 6.9 años.**

**Diferencia con la solución oficial (p.7, Tr=5.25 años):** la
manuscrita arma una tabla con Tr=10→P=51.7mm y Tr=5→P=44.5mm, lo que
implica un CD(1h) usado de 51.7/79≈0.654 (con CT(10)=1 exacto) —
distinto del valor de fórmula cerrada (0.616) usado acá. La causa más
probable es que la planilla/manuscrito original leyó CD **gráficamente**
de la Fig. 3.1.10/3.1.11 (el propio Teórico aclara que estas relaciones
"se presentan en forma gráfica", y su Ejemplo 3 resuelto en el texto usa
CD=0.60 para d=1h como lectura redondeada de gráfico, ya distinto del
0.616 exacto de la fórmula) en vez de aplicar la fórmula cerrada con
todos los decimales; no se descarta tampoco que, igual que en el
Ejercicio 4 de este mismo examen, el manuscrito visible corresponda a
otra variante/otro alumno. Se adopta acá el resultado de la **fórmula
cerrada exacta** (Tr≈6.9 años) por ser reproducible y trazable a la
fuente primaria (Teórico HHA y Formulómetro, ambos verificados
visualmente en esta resolución), dejando asentado que el procedimiento
es idéntico al oficial (mismo despeje, misma inversión de CT).

---

**ESTADO: COMPLETO**
