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

## Ejercicio 3 — pendiente
## Ejercicio 4 — pendiente
