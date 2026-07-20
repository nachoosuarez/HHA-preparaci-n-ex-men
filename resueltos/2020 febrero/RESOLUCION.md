# Examen HHA — 28 de febrero de 2020

Fuente: `EXAMENES/2020 febrero.pdf` (8 páginas: letra en pág. 1-2,
carta topográfica en pág. 3 y 5, solución oficial manuscrita en pág.
4, 6, 7 y 8). Trae solución oficial para los 4 ejercicios, aunque la
letra manuscrita del Ejercicio 1 (pág. 4) está parcialmente degradada
en la parte final (ubicación exacta del resalto móvil) — se indica más
abajo qué se pudo cotejar y qué se resolvió de forma independiente.

---

## Ejercicio 1 (30 puntos) — FGV: lago → canal trapezoidal → canal rectangular

### Enunciado (resumen)

Un lago descarga por un canal infinito de sección trapezoidal
(b_trap=1.5 m, talud m=1, S0=0.005, n_trap=0.009). El nivel del lago
está 1.2 m por encima del fondo a la entrada.

1. Determinar Q, clasificar el canal en M o S, dibujar la superficie
   libre indicando tirantes relevantes y resaltos si los hubiera.
2. A partir de x=700 m el canal pasa a ser **rectangular**
   (b_rect=1.5 m, n_rect=0.02, misma pendiente). Determinar Q,
   clasificar ambos tramos y dibujar la superficie libre completa.

### Teoría

- **Clasificación M/S y curvas de FGV** (RESUMEN_TEORICO.md §A1):
  yn>yc ⇒ canal M (mild, subcrítico en flujo normal); yn<yc ⇒ canal S
  (steep, supercrítico en flujo normal).
- **Control de un lago sobre un canal semi-infinito** (§A4): hay que
  probar **las dos hipótesis** de control en la entrada y quedarse con
  la autoconsistente:
  - Canal **M**: se asume que el tirante de entrada es yn (el canal
    "olvida" la entrada). Sistema 2×2 (energía + Manning) en (Q, yn).
    Se verifica *después* que yn>yc — si no, la hipótesis es
    inconsistente (no puede ser tipo M con ese Q).
  - Canal **S**: se asume flujo crítico en la entrada (control
    crítico, el lago descarga su caudal máximo). Como la sección es
    trapezoidal, yc(Q) no tiene forma cerrada: se itera un `fzero`
    externo en Q alrededor de un `fsolve` interno en yc, hasta que
    E(yc)=h_lago. Se verifica que yn<yc.
- **Información no viaja aguas arriba en flujo supercrítico** (§A4,
  párrafo "Control crítico en la entrada, sección trapezoidal"): si el
  tramo de entrada resulta tipo S, el caudal Q que descarga el lago
  queda fijado **únicamente** por esa entrada — nada de lo que se
  modifique aguas abajo (cambio de sección, de rugosidad, de
  pendiente) puede alterarlo, porque el flujo supercrítico no admite
  remanso hacia aguas arriba. Sólo hay que reclasificar el tramo
  modificado con el mismo Q y, si su clasificación cambia (de S a M),
  buscar dónde se ubica el resalto.
- **Resalto hidráulico de posición variable / cantidad de movimiento**
  (§A3): se ubica cruzando el **conjugado** (vía momento) de la rama
  supercrítica entrante con la rama subcrítica que llega desde aguas
  abajo (aquí, un canal M infinito ⇒ esa rama tiende a yn lejos aguas
  abajo, así que se integra hacia atrás desde ahí).

### Herramienta y por qué

Se usó **Octave** con el toolkit `RESUMEN EXAMEN/Codigos/FGV_trapezoidal/`
(`trap_geom`, `froude_trap`/`manning_trap` para yc/yn, `sistema_lago_M`
y `control_critico_lago_trap` para las dos hipótesis de control de
entrada, `rect.m`+`critico.m`+`ode23` para integrar la curva S2) y
`RESUMEN EXAMEN/Codigos/FGV_rectangular/` (`rect_geom`, `froude_rect`,
`manning_rect`, `Mom_rect` — ésta con fórmula **cerrada** para el
conjugado, a diferencia de la trapezoidal que necesita iterar) para el
tramo rectangular. Es exactamente el caso de uso de estas funciones:
control de un lago sobre un canal de dos tramos con distinta geometría,
con posible resalto móvil (mismo patrón que 2023 Julio Ej.1 y 2022
Julio Ej.1, documentado en RESUMEN_TEORICO.md §A4). Script:
`resueltos/2020 febrero/scripts/Ejercicio1_completo.m` (+ dependencias
copiadas al mismo directorio).

### Parte 1 — Canal trapezoidal (Q y clasificación)

Se prueban las dos hipótesis de control en la entrada:

| Hipótesis | Q (m³/s) | yc (m) | yn (m) | Consistente |
|---|---|---|---|---|
| M (y(0)=yn) | 3.5551 | 0.7048 | 0.4778 | **No** (yn<yc) |
| S (y(0)=yc) | 5.2452 | 0.8791 | 0.5952 | **Sí** (yn<yc) |

⇒ **Q = 5.245 m³/s**, canal **tipo S** (steep). Con control crítico en
x=0 (y=yc=0.879 m) y aguas abajo supercrítico en toda la longitud, la
superficie libre es una **curva S2** (decrece desde yc en la entrada y
tiende asintóticamente a yn=0.595 m aguas abajo — la integración
numérica da y≈0.595 m ya a los 700 m, a 0.01% de yn).

```
Superficie libre (Parte 1, sin modificar, tramo 0→∞):

 lago                                    yn=0.595 m ------------------
  \=====                                                 __ __ __ __
   \    \___                                    curva S2 (decreciente)
h_L=1.2m \yc=0.879m\____
           \______________\_______________________________________ ....
   canal trapezoidal, S0=0.005                (curva S en toda su extensión,
                                                 no hay resalto: todo supercrítico)
```

*Comparación con la solución oficial* (pág. 4, manuscrita, legible):
hipótesis M da Q=3.56 m³/s, yN=0.478 m, yc=0.7054 m, descartada por
yN<yc — **coincide exactamente**. Hipótesis S da Q=5.25 m³/s,
yc=0.878 m, yN≈0.59 m, aceptada, canal S — **coincide** (yn=0.5952 vs.
la lectura manuscrita ~0.585-0.6 m, dentro del margen de la letra a
mano). El croquis oficial marca la curva S2 llegando a ~1% de yn en
~280 m, consistente con la integración numérica.

### Parte 2 — Tramo rectangular desde x=700 m

**El caudal no cambia**: Q=5.245 m³/s (el tramo 0-700 m es
supercrítico en toda su longitud, así que el cambio de sección a los
700 m no puede "avisarle" al lago). El tirante que llega a x=700 m es
y=0.5953 m (prácticamente yn del tramo trapezoidal).

Con Q=5.245 m³/s y la nueva geometría (b=1.5 m, n=0.02, S0=0.005):

```
yc_rect = 1.0766 m       yn_rect = 1.5572 m
```

yn_rect > yc_rect ⇒ **tramo rectangular tipo M** (mild). Como el
tirante que llega (0.595 m) es menor que yc_rect (1.077 m), el flujo
**entra supercrítico** a un tramo mild ⇒ curva **M3** (creciente,
tendiendo asintóticamente a yc_rect) que necesariamente termina en un
**resalto hidráulico**, porque un canal M infinito sólo puede sostener
flujo subcrítico lejos aguas abajo (tiende a yn_rect).

Se ubica el resalto cruzando el conjugado de la curva M3 (fórmula
cerrada rectangular, `Mom_rect.m`) contra la curva subcrítica que llega
a yn_rect lejos aguas abajo (integrada hacia atrás; el resultado es
insensible al punto de arranque lejano — se verificó con 150, 300, 600
y 1000 m, siempre da el mismo cruce):

```
RESALTO a x' = 9.39 m después de la transición  (x = 709.4 m desde el lago)
  y1 (antes, supercrítico, sobre curva M3) = 0.708 m
  y2 (después, conjugado)                  = 1.557 m  (≈ yn_rect)
```

El resalto ocurre casi inmediatamente después del cambio de sección
(y1=0.708 m está muy cerca de yc_rect=1.077 m, es decir la curva M3 ya
casi había llegado al crítico). Aguas abajo del resalto el flujo es
prácticamente **uniforme a yn_rect=1.557 m** durante el resto del canal
(infinito).

```
Superficie libre completa (Parte 2):

 lago                                     yn_trap=0.595m
  \=====                                  ____________|  y=0.708m  yn_rect=1.557m
   \    \___                        __.--''             |\_____________________
h_L=1.2  \yc=0.879\________.--''                         | (resalto, x=709.4m)
    \_____________________________________|______________|_______________________
    canal TRAPEZOIDAL S0=0.005 (curva S2)  x=700m   canal RECTANGULAR (M3→resalto→yn_rect)
```

*Comparación con la solución oficial*: yn_rect=1.557 m coincide con la
cifra manuscrita "yNII=1,550 m" (pág. 4). La cifra manuscrita
"ycII=1,277 m" **no cierra** con el cálculo cerrado
yc=(q²/g)^(1/3)=1.0766 m (q=Q/b=3.497 m²/s) — se interpreta como un
error de lectura del escaneo (el dígito "0" de "1,077" fácilmente se
lee "2" en la letra manuscrita degradada de esa página); con
yc_rect=1.077 m sigue valiendo yn>yc ⇒ canal M, igual clasificación que
la manuscrita ("CANAL M"). La aritmética final de ubicación del resalto
en la página 4 (search entre xrel=-20, -30 y -94 m) está parcialmente
ilegible/con notación no estándar en el escaneo disponible y no se
pudo reconstruir con confianza; se resolvió el resalto de forma
independiente con el método estándar del curso (conjugado de la curva
M3 vs. curva subcrítica de cola), verificado analíticamente con la
fórmula cerrada de Mom_rect y comprobado insensible al punto de arranque
de la integración hacia atrás.

---

## Ejercicio 2 (20 puntos) — Delimitación de cuenca + tiempo de concentración

### Enunciado (resumen)

Cañada Saca Calzones, departamento de Lavalleja, punto de cierre
X=528.6 km, Y=6194.9 km (carta SGM, curvas de nivel cada 5 m, adjunta).

1. Delimitar la cuenca correspondiente.
2. Definir tiempo de concentración y determinarlo, asumiendo flujo
   concentrado y longitud del cauce principal L=6470 m.

### Teoría

- **Definición de tc** (RESUMEN_TEORICO.md §B2): tc es el tiempo de
  viaje de la partícula de agua que recorre el trayecto hidráulicamente
  (no necesariamente el geométricamente) más largo hasta el punto de
  cierre — el instante en que toda la cuenca empieza a aportar
  simultáneamente al caudal de salida.
- **Delimitación de cuencas** (§B1): la divisoria se traza perpendicular
  a las curvas de nivel, por las lomas/crestas que separan la red de
  drenaje que converge al punto de cierre de las cuencas vecinas; nunca
  cruza un cauce salvo exactamente en el punto de cierre.
- **Flujo concentrado ⇒ fórmula de Ramser-Kirpich** (§B2):
  tc = 0.4·L^0.77/S^0.385, con L en km y **S en %** = ΔH(m)/L(km)/10.

### Herramienta y por qué

**Parte 1:** delimitación gráfica manual sobre la carta topográfica (no
hay fórmula cerrada). Se extrajo a imagen la carta de
`EXAMENES/2020 febrero.pdf` (pág. 3, con el punto de cierre marcado; pág.
5 trae una segunda copia en escala de grises, sin ningún polígono
dibujado): `scripts/ej2_carta_completa.jpg` (carta completa) y
`scripts/ej2_carta_zoom_X.jpg` (zoom sobre el entorno del punto X).

**Parte 2:** cálculo directo con la fórmula de Ramser-Kirpich (no hace
falta Octave ni la planilla de eventos extremos — L viene dado por el
enunciado, sólo falta ΔH, que sale de la carta).

### Paso a paso

**Parte 1) Delimitación de la cuenca.**

El punto de cierre (X, marcador rojo) está sobre la Cañada Saca Calzones,
justo aguas abajo de donde ésta recibe un par de afluentes menores
visibles convergiendo desde el noreste (entre las cotas 55-60 m). Desde
ahí la cañada sigue aguas abajo hacia el suroeste, uniéndose a la Cañada
Membrillos (fuera de la cuenca de cierre en X). La red de drenaje que
alimenta el punto de cierre se extiende hacia el noreste/este, ganando
altura de forma bastante sostenida — las curvas de nivel suben desde
~55-60 m cerca de X hasta las lomas de más de 100 m que bordean el
"Valle de Solís" y continúan subiendo hacia el Cerro Gordillo (136.8 m,
punto más alto legible en la zona), consistente con la diferencia de
nivel ΔH≈87 m usada en la Parte 2 para un cauce principal de L=6.47 km.
El camino pavimentado que corre por la cresta (línea roja en la carta,
de NO a SE bordeando el valle) sigue de cerca la divisoria de aguas en
buena parte de su trazado, como suele pasar con los caminos que evitan
cruzar cursos de agua. La cuenca resultante es alargada, en forma de
"herradura" abierta hacia el suroeste (hacia X), apoyada en las lomas
altas al norte y al este (hacia Cerro Gordillo) y cerrando en el punto
de cierre.

**Nota de precisión** (misma limitación que en `resueltos/2022
diciembre/RESOLUCION.md` Ej.3 y `resueltos/2023 diciembre/RESOLUCION.md`
Ej.3): ninguna de las dos copias de la carta disponibles en el PDF trae
el polígono de la cuenca ya dibujado — la descripción de arriba es una
lectura manual de la carta siguiendo el procedimiento de §B1, con la
misma precisión con la que se traza a mano en el examen real, sin
verificación numérica cruzada de área/perímetro contra un polígono
oficial (la solución manuscrita de la pág. 6 tampoco trae el dibujo, va
directo al cálculo de tc).

**Parte 2) Tiempo de concentración.**

```
ΔH = 138 − 51 = 87 m     (cota más alta de la cuenca − cota del cauce en el cierre)
L  = 6.47 km              (dato del enunciado)
S  = ΔH(m) / L(km) / 10 = 87 / 6.47 / 10 = 1.345 %

tc = 0.4 · L^0.77 / S^0.385 = 0.4 · 6.47^0.77 / 1.345^0.385
   = 0.4 · 4.212 / 1.121 = 1.503 h
```

**Resultado Parte 2: tc ≈ 1.50 horas.**

*Comparación con la solución oficial* (pág. 6, manuscrita, legible):
misma definición de tc en palabras, mismo ΔH=87 m, L=6.47 km, fórmula de
Ramser-Kirpich y resultado **tc=1.5 hs** — coincide exactamente.

### Resultado final

| Ítem | Resultado |
|---|---|
| Parte 1: cuenca delimitada | Cuenca alargada NE-SO apoyada en las lomas hacia Cerro Gordillo, cerrando en X=528.6/Y=6194.9 sobre la Cañada Saca Calzones (ver `scripts/ej2_carta_zoom_X.jpg`) |
| ΔH | 87 m |
| L (cauce principal) | 6.47 km |
| S (Kirpich) | 1.345 % |
| **tc** | **1.50 h** |

---

## Ejercicio 3 (25 puntos) — Hidrograma de crecida, Número de Curva y período de retorno de un evento observado

### Enunciado (resumen)

Cuenca al suroeste de Artigas (X=350 km, Y=6600 km), A=12.8 km²,
tc>1 hr. Se registró en junio un evento con el siguiente hietograma
(precipitación total y efectiva ya dadas, por bloques de 1 h):

| t (h) | 0-1 | 1-2 | 2-3 | 3-4 | 4-5 |
|---|---|---|---|---|---|
| P (mm) | 11 | 17 | 52 | 12 | 6 |
| Pefectiva (mm) | 0 | 0.4 | 23.5 | 0.3 | 0.1 |

1. Despreciando Pef<1 mm en el intervalo, determinar y graficar el
   hidrograma de crecida a partir de t=0. HU triangular simétrico
   (tb=2·tp), tb=1.5 h, qp=3.10 m³/s/mm.
2. Con P en los 5 días previos=16 mm, determinar el Número de Curva.
3. Estimar el período de retorno del evento de precipitación TOTAL
   (dato de pluviógrafo).

### Teoría

- **Convolución con Hidrograma Unitario** (RESUMEN_TEORICO.md §B5): el
  hidrograma de crecida es la suma de la respuesta de cada pulso de
  lluvia efectiva, cada uno escalando y desplazando en el tiempo la
  misma curva unitaria (aquí triangular, dato directo del enunciado —
  no hace falta calcularla con la fórmula SCS a partir de tc/A).
- **Número de Curva a partir de un evento observado** (§B5, relación
  NRCS): Pef=(P−0.2S)²/(P+0.8S) si P>0.2S, con S=25400/NC−254. Si se
  conocen P y Pef (totales) de un evento real, se **invierte** esa
  relación para hallar S y de ahí NC — el mismo camino inverso que se
  usa para hallar Tr a partir de un caudal (B4), aplicado acá sobre la
  lámina.
- **Condición de humedad antecedente (AMC)** (§B6): el NC así obtenido
  corresponde a la condición de humedad *real* del suelo durante ESE
  evento — hay que ubicarla (con P5d y la estación del año) para saber
  si ese NC ya es el NC(II) de tabla o si hace falta "des-corregirlo".
  Junio en Uruguay es estación **inactiva**; con P5d=16 mm, cae en el
  rango AMC II (12.7-27.94 mm) ⇒ el NC obtenido directamente del evento
  **ya es** el NC(II) de tabla, sin necesidad de conversión.
- **Período de retorno de una lámina puntual registrada** (§B3): dato de
  pluviógrafo (no hay corrección por área, CA=1) ⇒
  P=P(3,10)·CD(d)·CT(Tr); se despeja CT y se invierte numéricamente
  para Tr.

### Herramienta y por qué

Los tres numeritos (Qp de un único pulso, inversión de S↔NC, inversión
de CT↔Tr) son cálculos algebraicos directos/una bisección — no hace
falta la planilla `Eventos extremos.xlsx` completa (que arma la
tormenta de diseño por bloque alterno) porque acá el hietograma **ya
viene dado**, no hay que construirlo (caso "Hoja 4", ver
`COMO_USAR_EVENTOS_EXTREMOS.md`, aunque tampoco hace falta esa hoja
particular porque P/Pef totales ya están dados por bloque). Se usó
**Python** (biseccion simple, sin dependencias) para las dos
inversiones numéricas y para verificar la aritmética de la convolución:
`resueltos/2020 febrero/scripts/Ejercicio3.py`.

### Parte 1 — Hidrograma de crecida

Sólo el bloque [2,3] h tiene Pef≥1 mm (23.5 mm); los otros tres (0.4,
0.3, 0.1 mm) se desprecian según el enunciado. La convolución se reduce
entonces a un **único pulso**: el HU triangular (tp=0.75 h, tb=1.5 h,
qp=3.10 m³/s/mm) escalado por 23.5 mm y desplazado para arrancar al
inicio de ese bloque (t=2 h):

```
Qp = Pef · qp = 23.5 mm · 3.10 m³/s/mm = 72.85 m³/s

Hidrograma resultante:
  t=0 a t=2h:    Q=0 (sin aporte, los bloques previos son despreciables)
  t=2h:          Q=0, empieza a crecer
  t=2h+tp=2.75h: Q=Qp=72.85 m³/s (pico)
  t=2h+tb=3.5h:  Q=0 (fin del hidrograma)
  t>3.5h:        Q=0
```

**Resultado Parte 1: hidrograma triangular con pico Qmax = 72.85 m³/s
en t = 2.75 h**, subiendo desde t=2h y terminando en t=3.5h.

*Comparación con la solución oficial*: Qmax=23.5×3.10=72.85 m³/s con
pico marcado entre t=2.75h y fin en t=3.5h — **coincide exactamente**.

### Parte 2 — Número de Curva

```
P total  = Σ P   = 11+17+52+12+6 = 98 mm
Pef total = Σ Pef = 0+0.4+23.5+0.3+0.1 = 24.3 mm

Pef = (P-0.2S)² / (P+0.8S)  =>  (biseccion en S)  S = 135.74 mm
NC = 25400/(S+254) = 25400/(135.74+254) = 65.17
```

Chequeo de AMC: junio ⇒ estación inactiva; P5d=16 mm está dentro de
12.7-27.94 mm ⇒ **AMC II** ⇒ el NC recién hallado ya es el NC(II) de
tabla de la cuenca, sin corrección adicional.

**Resultado Parte 2: NC ≈ 65.2** (redondeando la tabla NRCS a NC=65).

*Comparación con la solución oficial*: S=136.03 mm, NC=65.1, AMC II
(P5ant=16mm en junio) sin corregir — **coincide** (diferencia de
±0.1-0.3 en NC por redondeo intermedio de S).

### Parte 3 — Período de retorno del evento de precipitación total

Dato puntual de pluviógrafo ⇒ sin corrección de área (CA=1):

```
P total = 98 mm  (mismo total de la Parte 2; la solución oficial
                   escribe "99mm", se interpreta como error de lectura
                   del escaneo — la suma de la tabla da 98mm exacto)
D = 5 h            (duración total del evento registrado, 0 a 5h)
P(3,10) = 96 mm    (lectura gráfica, Fig. 3.1.10 del Teórico, para
                     el punto X=350km/Y=6600km al SO de Artigas)

CD(5h) = 1.0287·5/(5+1.0293)^0.8083 = 1.2038      (rama d>3h)
CT objetivo = P/(P(3,10)·CD) = 98/(96·1.2038) = 0.8480

CT(Tr) = 0.5786 - 0.4312·log10(ln(Tr/(Tr-1))) = 0.8480
  => (bisección numérica) Tr ≈ 4.73 años
```

**Resultado Parte 3: Tr ≈ 4.7 años.**

*Comparación con la solución oficial*: P3,10=96mm, D=5h,
CT(Tr)=0.8479, Tr=4.75 años — **coincide** (diferencia de centésimas de
año por redondeo, usando Ptotal=98 en vez del "99" ilegible del
escaneo).

### Resultado final

| Ítem | Resultado |
|---|---|
| Parte 1: Qmax hidrograma | **72.85 m³/s** en t=2.75 h (sube desde t=2h, termina en t=3.5h) |
| Parte 2: Número de Curva | **NC ≈ 65** (AMC II, sin corregir) |
| Parte 3: Período de retorno (P total) | **Tr ≈ 4.7-4.75 años** |

---

## Ejercicio 4 (25 puntos) — Bombeo con recirculación a tanque a presión negativa

### Enunciado (resumen)

Instalación que recircula agua desde y hacia el mismo tanque, con
presión inferior a la atmosférica: descarga libre a cota z2=5 m en la
parte superior del tanque; nivel de agua en el tanque z1=3 m; manómetro
en la parte superior del tanque pT=-10 kPa; bomba a cota zA=2 m (curva
característica dada en tabla Q-H-NPSHr-η). Succión e impulsión con
igual diámetro interno D=120 mm, rugosidad ε=0.05 mm; Ls=0.3 m, ks=2
(succión); Li=10 m, ki=3 (impulsión).

1. Determinar Q y H de la bomba; escribir la ecuación de la curva de
   la instalación.
2. Determinar la potencia consumida.
3. Determinar si la bomba cavita; escribir la ecuación de NPSH
   disponible.
4. Determinar la presión mínima admisible en el tanque para que la
   bomba no cavite.

### Teoría

- **Ecuación de la instalación** (RESUMEN_TEORICO.md §C1): balance de
  energía entre dos puntos con pérdidas distribuidas (Darcy-Weisbach +
  Colebrook-White, `colebrook.m`) y localizadas (coeficientes k).
- **Clave física de este ejercicio (no estaba en el resumen, se
  agregó): recirculación al mismo tanque cerrado** (§C4, nuevo párrafo):
  tanto el nivel libre z1 como la descarga z2 están dentro del **mismo**
  espacio de aire cerrado del tanque, a la **misma** presión pT (dato
  del manómetro) ⇒ p1=p2=pT se **cancelan exactamente** en la ecuación
  de la instalación, que queda sin depender de pT. Como z1 es una
  superficie libre grande, v1≈0.
- **Punto de funcionamiento** (§C2): intersección de la curva de la
  bomba (interpolada de la tabla) con la curva de la instalación.
- **Potencia consumida** (§C3): P=ρ·g·Q·H/η.
- **Cavitación / NPSH disponible** (§C4): NPSH_disp=z1+p1/(ρg)
  −Δh_succión−zA+10.1 (constante 10.1=(Patm−Pvap)/γ; el término cinético
  de z1 se cancela por ser superficie libre — misma "trampa común" ya
  documentada). Con p1=p2 cancelados en la instalación, el punto de
  funcionamiento **no depende de pT**, así que la presión mínima para
  no cavitar sale en forma **cerrada** (sin iterar), despejando pT de
  NPSH_disp=NPSH_req.

### Herramienta y por qué

Se usó **Octave**, adaptando el template canónico
`RESUMEN EXAMEN/Codigos/Bombas/Bomba_sola.m` (una sola bomba,
succión+impulsión con pérdidas por Colebrook-White) a este caso
particular (mismo D en succión e impulsión, p1=p2 cancelados, z1
superficie libre). Script:
`resueltos/2020 febrero/scripts/Ejercicio4_Bomba.m` (+ `colebrook.m`).

### Parte 1 — Punto de funcionamiento

Ecuación de la instalación (p1=p2=pT cancelados, v1≈0):

```
Hinst(Q) = (z2-z1) + [1 + ks + fs·Ls/D + ki + fi·Li/D] · U²/(2g) ,   U=Q/A
```

Intersección con la curva de la bomba (interpolación `pchip` de la
tabla):

```
Q_PF = 0.0304 m3/s (30.4 L/s)
H_PF = 4.765 m
Re_PF = 3.226e5 , f_PF (Colebrook) = 0.0176
eta_PF = 72.4 %
```

**Resultado Parte 1: Q ≈ 30.4 L/s, H ≈ 4.77 m.**

*Comparación con la solución oficial* (pág. 8, manuscrita): Q=0.0303
m³/s, H=4.75 m, Re=3.2×10⁵, f=0.0176, η=72.14% — **coincide**
(diferencias de centésimas por redondeo de la interpolación).

### Parte 2 — Potencia consumida

```
P = ρ·g·Q_PF·H_PF/eta_PF = 1000·9.81·0.0304·4.765/0.724 = 1962 W ≈ 1.96 kW
```

**Resultado Parte 2: P ≈ 1.96 kW.**

*Comparación con la solución oficial*: P=1.96 kW — **coincide
exactamente**.

### Parte 3 — Cavitación

```
Δh_succión(PF) = (ks + f_PF·Ls/D)·U_PF²/(2g) = 0.753 m

NPSH_disponible = z1 + pT/(ρg) - Δh_succión - zA + 10.1
                = 3 + (-10000)/(1000·9.81) - 0.753 - 2 + 10.1 = 9.328 m

NPSH_requerido(Q_PF) = 3.12 m  (interpolado de la tabla)
```

9.33 m > 3.12 m ⇒ **la bomba NO cavita** (margen amplio, ~6.2 m).

**Resultado Parte 3: NPSH_disp ≈ 9.33 m > NPSH_req ≈ 3.12 m — no
cavita.**

*Comparación con la solución oficial*: NPSH_disp=9.33 m, NPSH_req=3.15
m, "no cavita" — **coincide** (NPSH_req difiere en centésimas por
redondeo de interpolación).

### Parte 4 — Presión mínima admisible en el tanque

Como p1=p2 se cancelan en la curva de la instalación, el punto de
funcionamiento (y por lo tanto Δh_succión y NPSH_req) **no cambia** con
pT — se despeja directamente pT de NPSH_disp(pT)=NPSH_req(Q_PF):

```
p_min = ρ·[ NPSH_req,PF - z1 + Δh_succión,PF + zA - 10.1 ]
      = 1000·[ 3.12 - 3 + 0.753 + 2 - 10.1 ] = -70 911 Pa ≈ -70.9 kPa
```

**Resultado Parte 4: p_mín ≈ -70.9 kPa** (el tanque puede llegar hasta
esa presión, más negativa que eso la bomba empieza a cavitar).

*Comparación con la solución oficial*: p_mín=-70.5 kPa — **coincide**
(diferencia de ~0.4 kPa, arrastre del redondeo de NPSH_req en la Parte
3).

### Resultado final

| Ítem | Resultado |
|---|---|
| Parte 1: Q, H (punto de funcionamiento) | **Q≈30.4 L/s, H≈4.77 m** |
| Parte 2: Potencia consumida | **≈1.96 kW** |
| Parte 3: cavitación | **NPSH_disp≈9.33 m > NPSH_req≈3.12 m → no cavita** |
| Parte 4: presión mínima en el tanque | **≈-70.9 kPa** |

---

## ESTADO: COMPLETO
