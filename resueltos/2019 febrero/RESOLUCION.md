# Examen HHA — 7 de febrero de 2019 ("2019 febrero")

Resolución paso a paso. El PDF (`EXAMENES/2019 febrero.pdf`, 7 páginas)
trae la letra completa (páginas 1-2: Ejercicios 1-4) y la solución
oficial manuscrita parcial (páginas 3, 5, 6, 7 — con la solución del
Ejercicio 1, 2, 3 y el inicio del 4), que se usa para comparar cada
resultado. La página 4 es la carta topográfica del Ejercicio 3 (no se
usa: el enunciado ya da la tabla progresiva/cota del perfil del cauce).

No confundir con "2019 febrero 2" (`EXAMENES/2019 febrero 2.pdf`), la
otra llamada de febrero de 2019 (22/feb), ya resuelta en este repo.

---

## EJERCICIO 1 — Alcantarilla de 3 tubos bajo canal trapezoidal infinito (25 puntos)

**Datos:** canal trapezoidal infinito, ancho de fondo b=4.5 m, talud
lateral 1V:2.5H (m=2.5), n=0.02, S₀=0.0007. Alcantarilla de 3 tuberías
circulares de hormigón, D=1 m, n_alc=0.013, L=15 m, apoyadas sobre el
lecho del canal (sin obra de aproximación), entrada con aristas
redondeadas r=0.02 m (r/D=0.02).

1) Caudal de diseño Qd=10 m³/s.
2) Durante una tormenta, Qt=6 m³/s.

Para cada caudal: identificar el tipo de funcionamiento de la
alcantarilla, calcular el tirante de agua inmediatamente antes de la
alcantarilla, y esquematizar el perfil de la superficie libre.

### Teoría (RESUMEN_TEORICO.md §D1, §A1)

- **D1** Clasificación de Bodhaine de alcantarillas (Tipo 1 a 6) según
  h1/D y h4/D. Como el canal es **infinito** (no hay un lago que fije
  el nivel aguas abajo), el tirante aguas abajo h4 es directamente el
  **tirante normal yn** del canal para ese caudal — no hace falta
  integrar un perfil de FGV para obtenerlo (caso particular anotado en
  §D1 punto 4).
- **A1** Clasificación M/S del canal: se compara yn (Manning) con yc
  (Froude=1, sección trapezoidal). yn>yc ⇒ canal tipo M (pendiente
  suave, régimen subcrítico normal).
- **D1** Balance de carga:
  - Tipo 1 (h4/D≥1, ambos extremos ahogados): h1 = h4 + pérdida
    localizada de entrada (CD1, Tabla 3.2.1) + pérdida distribuida
    (Manning) en la alcantarilla, todo referido al zampeado de salida.
  - Tipo 2 (h4/D<1 pero entrada ahogada, alcantarilla "hidráulicamente
    larga" — L/D=15 grande y S₀ chica, cae del lado Tipo 2 del ábaco
    Fig.3.2.5/3.2.6): igual balance pero con h3=D fijo (chorro a tubo
    lleno) en vez de h4.
- El caudal total se reparte **en partes iguales entre los 3 tubos**
  (misma geometría, mismo nivel de entrada): Q_alc = Q/3.

Cita: Teórico HHA §3.2 "Diseño de Alcantarillas" (§3.2.1, Tabla 3.2.1);
§2.5.1-2.5.2 (clasificación M/S, tirante normal y crítico);
Formulómetro "Alcantarillas" / "Flujo Uniforme (Manning)" / "Sección
Crítica".

### Herramienta y por qué

Se usó Octave, combinando el toolkit `FGV_trapezoidal` (`trap_geom`,
`eq_yn`, `eq_yc` para yn/yc del canal) con las fórmulas de balance de
carga de `RESUMEN EXAMEN/Codigos/Alcantarillas/` (`alcantarilla_tipo1.m`
y `alcantarilla_tipo2.m`), porque el ejercicio combina exactamente esos
dos bloques ya cubiertos en el resumen: clasificar el canal aguas abajo
y resolver el balance de carga de la alcantarilla según el tipo que
corresponda. No hizo falta ninguna función nueva. Script completo:
`resueltos/2019 febrero/scripts/Ejercicio1_alcantarilla.m` (con copias
locales de `trap_geom.m`, `eq_yn.m`, `eq_yc.m`).

### Paso a paso — Parte 1: Qd=10 m³/s

1. **yn y yc del canal** (b=4.5, m=2.5, n=0.02, S₀=0.0007, Q=10):
   `yn = 1.174 m`, `yc = 0.695 m` → yn>yc ⇒ **canal M** (coincide con
   la solución oficial: yn=1.17, yc=0.69, "CANAL M").
2. **h4 = yn = 1.174 m** (canal infinito, sin lago). h4/D = 1.174 ≥ 1
   ⇒ **ALCANTARILLA TIPO 1** (entrada y salida ahogadas) — "Ahogada
   sólida → Tipo 1" en la solución oficial.
3. Q_alc = 10/3 = 3.333 m³/s por tubo. CD1(r/D=0.02) = 0.88 (Tabla
   3.2.1). Rh = AT/Pm = (πD²/4)/(πD) = D/4 = 0.25 m.
4. Balance de carga Tipo 1 (referido al zampeado de salida):
   `h1 = h4 + Q_alc²/(2g·CD1²·AT²) + n_alc²·Q_alc²·L/(AT²·Rh^(4/3))`
   → **h1 = 2.6504 m**.
5. Desnivel de zampeado entrada-salida: z = S₀·L = 0.0007×15 = 0.0105 m.
   Tirante aguas arriba referido al fondo local de la entrada:
   `y1 = h1 - z = 2.6399 m` (y1/D=2.64 ≥ 1, confirma Tipo 1
   autoconsistente).
6. Como y1 > yn > yc, aguas arriba de la alcantarilla se forma una
   **curva de remanso M1** que empalma con yn lejos aguas arriba
   (extensión típica ~3000-3500 m para S₀ tan chica, según el
   esquema oficial).

**Resultado Ejercicio 1, Parte 1: alcantarilla Tipo 1, y1 = 2.64 m**
(coincide exactamente con la solución oficial: "y1=2,64m → curva M1").

### Paso a paso — Parte 2: Qt=6 m³/s

1. **yn y yc del canal** (mismo canal, Q=6): `yn = 0.898 m`,
   `yc = 0.512 m` → yn>yc ⇒ canal M (oficial: yn=0.89, yc=0.51).
2. h4 = yn = 0.898 m. h4/D = 0.898 < 1 ⇒ salida **no ahogada**. Con
   L/D=15 (alcantarilla larga) y S₀=0.0007 (pendiente baja), el ábaco
   Fig.3.2.5/3.2.6 ubica el caso del lado **Tipo 2** (fluye llena por
   fricción, chorro a la salida) — coincide con "tipo 2" en la
   solución oficial.
3. Q_alc = 6/3 = 2 m³/s por tubo. Mismo CD1=0.88, Rh=0.25 m. h3=D=1 m
   (chorro a tubo lleno).
4. Balance de carga Tipo 2:
   `h1 = h3 + Q_alc²/(2g·CD1²·AT²) + n_alc²·Q_alc²·L/(AT²·Rh^(4/3))`
   → **h1 = 1.5316 m**.
5. `y1 = h1 - z = 1.5211 m` (y1/D=1.52 ≥ 1.5, confirma Tipo 2
   autoconsistente — oficial: "h1-z=1,52 > 1,5").
6. Aguas abajo de la alcantarilla el tubo descarga como chorro a tubo
   lleno; el canal es M (subcrítico), así que el chorro pasa por un
   **resalto hidráulico** corto y vuelve al tirante normal
   yn=0.898 m lejos aguas abajo (esquema oficial: caída y ondulación
   inmediatamente después de la alcantarilla, luego vuelve a yn en
   ~2000 m).

**Resultado Ejercicio 1, Parte 2: alcantarilla Tipo 2, y1 = 1.52 m**
(coincide con la solución oficial).

---

## EJERCICIO 2 — Caudal de diseño, cambio de uso de suelo y evento extremo (30 puntos)

**Datos:** cuenca en Cerro Largo (punto de cierre X=650 km, Y=6400 km),
Área=5.10 km², ΔH=120 m (desnivel del cauce ppal.), L=3600 m (largo del
cauce ppal.), S=1.95% (pendiente **media de la cuenca**, no la del
cauce). Uso de suelo: pastizales naturales condición hidrológica MALA,
unidad de suelos San Manuel, flujo concentrado.

1) Caudal de diseño de una alcantarilla en el punto de cierre, Tr=5 años.
2) Se cultiva el 65% del área con maíz sembrado por curvas de nivel,
   condición hidrológica BUENA; el tc total se reduce 8%. Estimar el
   nuevo Tr del caudal encontrado en 1).
3) En esas condiciones, evento extremo en febrero (hietograma de 12
   bloques de 5 min dado). Calcular el caudal del evento y determinar
   si supera el caudal de diseño, con P de los 5 días previos=38 mm.

### Teoría (RESUMEN_TEORICO.md §B2, §B3, §B4, §B5, §B6)

- **B2** tc por Ramser-Kirpich (flujo concentrado): usa la pendiente del
  **cauce principal** (ΔH/L/10), NO la pendiente media de la cuenca
  dada aparte (esa S=1.95% solo sirve para elegir el coeficiente C del
  método Racional, Tabla 3.1.4).
- **B4** Criterio de selección de método según tc: tc<20min→solo
  Racional; 20min<tc<1h→ambos, adoptar el mayor; tc>1h→solo NRCS.
- **B5** Método NRCS completo (tormenta de diseño por bloque alterno +
  Número de Curva + hidrograma unitario triangular SCS) para el caudal
  de diseño; **NC ponderado** por área cuando hay más de un uso de
  suelo (§B5 "NC ponderado"); caso de **efectos opuestos** cuando el
  nuevo uso de suelo baja el NC a la vez que baja el tc (§B5, nuevo
  párrafo agregado con este examen) — no se puede asumir el signo del
  resultado, hay que simular.
- **B6** AMC: estación de crecimiento (primavera-verano, incluye
  febrero) con umbrales AMC I<35.56mm, AMC II 35.56–53.34mm, AMC
  III>53.34mm (distintos de los umbrales de estación inactiva).

Cita: Teórico HHA §3.1.5 (tc, Racional, criterio de selección), §3.1.6
(NRCS), §3.1.5 b) (AMC); Formulómetro "Tiempo de Concentración" /
"Método Racional" / "Método NRCS" / "Condición de Humedad Antecedente".

### Herramienta y por qué

Se usó Python (replicando exactamente las fórmulas de
`Eventos extremos.xlsx`, hoja "Cálculos (grande)", documentadas en
`RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md`) en vez de la
planilla misma, porque la Parte 2 necesita **iterar Tr** (bisección)
hasta que el hidrograma NRCS con el NC y tc nuevos reproduzca el
caudal de diseño de la Parte 1 — la planilla no tiene una celda que
invierta Tr automáticamente (ver "Errores comunes" ítem 9 del
instructivo), así que conviene envolver el cálculo en una función y
tantear/biseccionar en código, siguiendo el mismo patrón ya usado en
`resueltos/2020 Diciembre/scripts/ej2_parte2.py`. P(3,10)=80mm, C=0.28
y NC=86/82 son lecturas gráficas (isoyetas Fig 3.1.10, Tabla 3.1.4,
Fig 3.1.20) tomadas de la solución oficial manuscrita. Scripts:
`resueltos/2019 febrero/scripts/ej2_parte1.py`, `ej2_parte2.py`,
`ej2_parte3.py`.

### Paso a paso — Parte 1: caudal de diseño (Tr=5)

1. S cauce principal = ΔH/L(km)/10 = 120/3.6/10 = 3.333 %.
2. tc (Kirpich) = 0.4·L^0.77/S^0.385 = **0.6747 hs = 40.5 min**
   (oficial: 40.98 min, diferencia ~1% por redondeo intermedio).
3. 20 min < tc < 1 h ⇒ calcular ambos métodos y adoptar el mayor.
4. Método Racional: CT(5)=0.860, CD(tc)=0.517, CA(tc,A)=0.988 ⇒
   P(tc,5,A)=35.1 mm ⇒ i=52.0 mm/h ⇒ **Q_racional = 20.64 m³/s**
   (oficial: 20.6 m³/s).
5. Método NRCS: S(NC=86)=41.35 mm, Ia=8.27 mm; tormenta de diseño por
   bloque alterno (Δt=tc/7=5.78 min, 12 bloques, total 44.7 mm) ⇒
   ΣPe=17.09 mm ⇒ hidrograma unitario (Tp=0.453 h, Tb=1.208 h) ⇒
   **Q_NRCS = 29.72 m³/s** (oficial: 29.68-29.7 m³/s).
6. Q_racional < Q_NRCS ⇒ se adopta el mayor.

**Resultado Ejercicio 2, Parte 1: Qmax de diseño (Tr=5) = 29.7 m³/s
(NRCS)** (coincide con la solución oficial: 29,7 m³/s).

### Paso a paso — Parte 2: cambio de uso de suelo, nuevo Tr

1. NC ponderado = 0.65·NC_maíz(82, curvas de nivel, cond. buena) +
   0.35·NC_pastizal(86, sin cambios) = **83.4** (oficial: 83,4 —
   coincide).
2. tc_nuevo = 0.92·tc = 0.92×0.6747 = **0.6207 hs = 37.2 min**
   (reducción del 8%, oficial: 0.62 hs — coincide).
3. Se itera Tr (bisección) manteniendo NC=83.4 y tc=37.2 min hasta que
   Qmax NRCS(Tr) reproduzca el caudal de diseño fijo de la Parte 1
   (29.72 m³/s, la alcantarilla ya construida no cambia de capacidad):
   Tr=7→28.9 m³/s, Tr=7.5→29.75 m³/s, Tr=8→30.6 m³/s ⇒ **Tr ≈ 7.5 años**.
4. El efecto del NC (bajó, más infiltración) domina sobre el efecto
   del tc (bajó, más pico): para alcanzar el mismo caudal de diseño
   ahora hace falta un evento más raro que antes.

**Resultado Ejercicio 2, Parte 2: nuevo Tr ≈ 7.5 años** (coincide
exactamente con la solución oficial: "Tr=7,5 años").

### Paso a paso — Parte 3: evento extremo de febrero

1. P5d=38 mm, febrero = estación de **crecimiento** ⇒ 35.56<38<53.34
   ⇒ **AMC II** ⇒ NC se mantiene en 83.4 sin corregir (oficial:
   "P5DIAS T=38mm ⇒ NC II").
2. Se toma el hietograma **observado** (12 bloques de 5 min, tabla del
   enunciado, total 65 mm) directamente, sin reordenar por bloque
   alterno, con el NC=83.4 y tc=37.2 min de la Parte 2 (mismo piso de
   infiltración 1.2 mm/h): S=50.56 mm, Ia=10.11 mm ⇒ ΣPe=28.57 mm.
3. Hidrograma unitario triangular (tr=5 min, Tp=0.414 h, Tb=1.104 h,
   qp=2.562 m³/s por mm) convolucionado con los 12 pulsos de Pe ⇒
   **Qmax evento = 58.18 m³/s** (oficial: 58.2 m³/s).
4. 58.18 m³/s > 29.72 m³/s (caudal de diseño) ⇒ **el evento SUPERA el
   caudal de diseño de la alcantarilla**.

**Resultado Ejercicio 2, Parte 3: Qmax evento = 58.2 m³/s, SUPERA el
caudal de diseño** (coincide con la solución oficial).

---

## EJERCICIO 3 — Tiempo de concentración por dos alternativas (20 puntos)

**Datos:** cuenca de 2.7 km² próxima a José Pedro Varela (X=625,
Y=6300 km), cultivos en línea recta en la parte alta, pasturas en la
parte baja. Perfil del cauce principal (progresiva/cota, 8 puntos):

| Progresiva (m) | 0 | 175 | 295 | 575 | 726 | 1321 | 1850 | 2376 |
|---|---|---|---|---|---|---|---|---|
| Cota (m) | 237 | 230 | 220 | 210 | 200 | 190 | 180 | 176 |

1) tc suponiendo flujo NO concentrado (mantiforme) en la parte alta y
   flujo concentrado en la parte baja (desde la progresiva 575 hasta
   el cierre).
2) tc suponiendo flujo concentrado en todo el recorrido.

### Teoría (RESUMEN_TEORICO.md §B2)

- **B2** Fórmula NRCS por tramos para flujo **no concentrado**
  (mantiforme): `tc = 0.91134 · Σ(kᵢ·Lᵢ/√Sᵢ)`, suma por sub-tramos del
  perfil (Lᵢ en km, Sᵢ en % de CADA sub-tramo), k=coeficiente de
  cobertura del suelo (tabla del Teórico; k=1.111 para cultivos en
  línea recta — lectura de tabla, tomada de la solución oficial).
- **B2** Ramser-Kirpich para el tramo de flujo **concentrado**: mismo
  procedimiento de siempre, pero aplicado sólo al tramo correspondiente
  (L y ΔH de ESE tramo, no del perfil completo).
- El tc de un perfil mixto es la SUMA de ambos tramos; el flujo
  mantiforme es más lento que el concentrado equivalente, así que
  incluirlo da un tc mayor que asumir todo concentrado.

Cita: Teórico HHA §3.1.2 "Tiempo de concentración" (fórmula NRCS de
velocidad de flujo por tramos, tabla de coeficientes k); Formulómetro
"Eventos extremos — Tiempo de Concentración".

### Herramienta y por qué

Se usó Python (`resueltos/2019 febrero/scripts/Ejercicio3_tiempo_concentracion.py`)
en vez de la planilla de eventos extremos porque el ejercicio es
puramente el cálculo de tc por dos vías, sin caudal de diseño de por
medio — no hace falta el resto de la maquinaria de la planilla
(tormenta de diseño, hidrograma). Es una combinación directa de las dos
fórmulas de tc de §B2, aplicadas a distintos tramos del mismo perfil.

### Paso a paso

**Alternativa 1 — mixto (mantiforme + concentrado):**

1. Parte alta (0-575 m) dividida en 3 sub-tramos según los quiebres del
   perfil: 0-175m (L=0.175km, ΔH=7m, S=4.00%), 175-295m (L=0.12km,
   ΔH=10m, S=8.33%), 295-575m (L=0.28km, ΔH=10m, S=3.57%).
2. Con k=1.111: Σ(k·L/√S) = 0.0972+0.0462+0.1646 = 0.3080.
   **Tc1 = 0.91134×0.3080 = 0.2807 h** (oficial: 0.28h).
3. Parte baja (575-2376m, concentrado): L=1.801km, ΔH=34m, S=1.888%.
   Kirpich: **Tc2 = 0.4927 h** (oficial: 0.49h).
4. **Tca = Tc1+Tc2 = 0.7734 h** (oficial: 0.77h).

**Alternativa 2 — todo concentrado (0-2376 m):**

1. L=2.376km, ΔH=61m, S=2.567%. Kirpich: **Tcb = 0.5418 h** (oficial:
   0.54h).

**Resultado Ejercicio 3: Tca (mixto) = 0.77 h ; Tcb (todo concentrado)
= 0.54 h** — coincide exactamente con la solución oficial en ambos
valores. Suponer flujo no concentrado en el tramo alto da un tc mayor
(flujo mantiforme más lento que el concentrado equivalente).

---

## EJERCICIO 4 — pendiente

## ESTADO: EN CURSO (Ejercicios 1, 2 y 3 resueltos; falta 4)
