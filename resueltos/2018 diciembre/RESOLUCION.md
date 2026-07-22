# Examen HHA — 17 de diciembre de 2018

Resolución paso a paso. Herramientas usadas: Octave (funciones de
`RESUMEN EXAMEN/Codigos/FGV_rectangular/`, copiadas y adaptadas en este
mismo directorio) para el Ejercicio 1.

Hay solución oficial (manuscrita) incluida en el mismo PDF del examen
(`EXAMENES/2018 diciembre.pdf`, páginas 4, 6, 9 y 10 para el Ej.1, Ej.2,
Ej.3 y Ej.4 respectivamente). Se cita y compara en cada ejercicio.

---

## EJERCICIO 1 (30 puntos) — Lago que descarga en un canal con caída libre, con una compuerta de fondo interior

**Enunciado (resumen):** un lago descarga en un canal rectangular
(b=2 m, n=0.01) de 1500 m de longitud que termina en una caída libre.
Cota superficie libre del lago z=3.8 m; cota de fondo del canal junto al
lago z=2.2 m; cota de fondo en la caída libre z=1 m.
1) Calcular Q, clasificar el canal, esquematizar el perfil.
1000 m aguas abajo del inicio se ubica una compuerta de fondo ideal de
abertura a=0.35 m.
2) Calcular el nuevo Q, clasificar, esquematizar el perfil (tirantes en
puntos relevantes, resalto si lo hay).
3) Calcular la fuerza sobre la compuerta y la potencia disipada en el
resalto.

Teoría usada: ecuación de FGV y clasificación M/S, energía específica y
tirante crítico, perfiles de flujo controlados por lago y por caída
libre (Teórico HHA §2.5.3–§2.5.4), transición por compuerta de fondo
ideal (§2.2, §2.3.4, §2.5.5). Ver `RESUMEN EXAMEN/Teorico/RESUMEN_TEORICO.md`
§A4 y §A5 (sección **"Compuerta INTERIOR entre un lago aguas arriba a
distancia finita y una caída libre aguas abajo"**, añadida a partir de
este examen).

### Parte 1) Caudal sin obstáculos, clasificación y perfil

**Concepto.** El lago descarga con conservación de energía en la entrada
(sin pérdidas): E(x=0) = h_Lago = 3.8−2.2 = 1.6 m. Como el canal es largo
(1500 m) y de pendiente suave (a verificar), el tirante de entrada tiende
al tirante normal yn — sistema de 2 ecuaciones (energía + Manning) en
(Q, yn), caso "canal tipo M alimentado por lago, muy largo" del §A4.

**Por qué esta herramienta.** Es exactamente el caso base de A4: un solo
lago aguas arriba, canal largo, caída libre aguas abajo (sin segundo
control). No hace falta integrar toda la EDO de FGV para obtener Q —
alcanza con Manning + energía en yn, y se verifica después integrando el
perfil completo.

**Script:** `Ejercicio1_lago_compuerta_caidalibre.m`, sección "PARTE 1".
Entradas: `b=2, n=0.01, S0=(2.2-1)/1500=0.0008, hL=1.6`.

**Resultado:**
```
Q  = 5.534 m3/s
yn = 1.401 m
yc = 0.921 m
```
Como yn > yc ⇒ **canal tipo M (pendiente suave/subcrítica)**.

**Verificación (integrando la EDO completa):** partiendo de yc+ε en la
caída libre (x=1500) e integrando hacia atrás hasta el lago, se obtiene
y(x=0)=1.393 m con E(x=0)=1.594 m ≈ 1.6 m (diferencia <0.4%): el canal es
lo bastante largo para que la aproximación y(0)≈yn sea excelente.

**Perfil (x medido desde el lago):** curva **M2** (subcrítica,
decreciente) desde y≈yn=1.40 m cerca del lago hasta y=yc=0.92 m justo en
el borde de la caída libre. **Sin resalto.**

**Comparación con la solución oficial:** coincide exactamente (Q=5.53
m³/s, yn=1.40 m, yc=0.92 m, canal "n" = mild, perfil hL→yn→yc sin
resalto).

### Parte 2) Con compuerta de fondo (a=0.35 m) a 1000 m del lago

**Concepto.** La compuerta ideal (sin pérdida ni contracción, ver A5)
impone tirante yB=a inmediatamente aguas abajo, y aguas arriba yA es el
**alterno** de a con la misma energía específica. El caudal que efectivamente
pasa está determinado por el acoplamiento de TRES condiciones:
(i) energía en el lago, E(x=0)=h_Lago; (ii) el perfil de FGV entre el lago
y la compuerta (1000 m); (iii) la relación de la compuerta ideal en x=1000.

**Por qué NO alcanza con la aproximación "canal largo" de la Parte 1.**
Antes de resolver, conviene probar la hipótesis más simple: ¿el Q de la
Parte 1 (5.53 m³/s) sigue siendo válido con la compuerta abierta? Se
calcula yA=alterno(a=0.35, Q=5.53) y se integra la EDO **hacia atrás**
1000 m desde la compuerta hasta el lago: da y(x=0)=2.78 m, **mayor que
h_Lago=1.6 m** — energéticamente imposible. Es decir, la compuerta angosta
genera un remanso M1 tan pronunciado que llega hasta el propio lago y
"ahoga" la entrada: el caudal **debe** cambiar. A diferencia de un
escalón de fondo típico (ver caso "Escalón interior" en RESUMEN_TEORICO,
§A5), acá 1000 m **no** es "largo" frente al desarrollo de esta curva de
remanso, así que hay que resolver el sistema completo por *shooting*.

**Herramienta y por qué.** `fzero` en Q: para cada Q de prueba, (a) se
calcula yA=alterno(a,Q) con `Eesp_rect` (tirante alterno de la abertura
a, misma energía específica), (b) se integra la EDO de FGV (`rect.m` +
`ode23`) hacia atrás 1000 m desde la compuerta con esa condición de
borde, (c) se compara la energía específica resultante en x=0 contra
h_Lago. Se usa esta herramienta porque es la única forma sistemática de
resolver un remanso que no se relaja a yn dentro del tramo dado (mismo
patrón que "Canal tipo M corto entre dos lagos" de §A4, pero con una
compuerta en vez de un segundo lago como control aguas abajo del tramo).

**Script:** `Ejercicio1_lago_compuerta_caidalibre.m`, sección "PARTE 2".

**Resultado:**
```
Q  = 4.151 m3/s   (< 5.53 m3/s sin compuerta: la compuerta angosta reduce el caudal)
yA (aguas arriba de la compuerta) = 2.094 m
yn(canal, Q=4.15) = 1.122 m      yc(canal, Q=4.15) = 0.760 m
```

**Descarga libre vs. ahogada (tramo de salida, compuerta→caída libre):**
a*=conjugado(a=0.35)=1.42 m > yn=1.12 m (tirante de referencia aguas
abajo) ⇒ **descarga LIBRE** — se forma una curva M3 después de la
compuerta que se acelera hasta que un resalto hidráulico la reconecta con
la curva M2 que llega desde la caída libre (yc=0.76 m en x=1500).

**Ubicación del resalto:** se integra la curva M3 hacia adelante desde la
compuerta (y=a=0.35 m en x=1000) y la curva M2 hacia atrás desde la caída
libre (y=yc=0.76 en x=1500); se busca el x donde el **conjugado** de la
curva M3 cruza la curva M2 (mismo método que §A3).
```
Resalto en x=1067.9 m  (≈ 68 m aguas abajo de la compuerta)
y1 (antes, M3) = 0.514 m      y2 (después, conjugado) = 1.076 m
```

**Perfil completo (x desde el lago):**
- x=0 a x≈1000 m: curva M1 (remanso), desde y0=1.50 m (lago) creciendo
  hasta yA=2.09 m justo antes de la compuerta.
- x=1000 m (compuerta): salto de yA=2.09 m a y=a=0.35 m.
- x=1000 a x≈1068 m: curva M3 (supercrítica, creciente), de 0.35 m a
  0.51 m.
- **Resalto** en x≈1068 m: de 0.51 m a 1.08 m.
- x≈1068 a x=1500 m: curva M2 (subcrítica, decreciente) de 1.08 m a
  yc=0.76 m en la caída libre.

**Comparación con la solución oficial:** coincide muy bien (oficial:
Q=4.15 m³/s, yn=1.12 m, yc=0.76 m, a*=1.41 m, resalto a ≈70 m de la
compuerta; acá 4.151 m³/s, 1.122 m, 0.760 m, 1.420 m, 67.9 m —
diferencias del orden del redondeo manual del examen).

### Parte 3) Fuerza sobre la compuerta y potencia disipada en el resalto

**Concepto.** La fuerza sobre cualquier obstáculo de fondo entre dos
secciones es F=γ·(M1−M2) (cantidad de movimiento, §A3/§A5), con M1 aguas
arriba y M2 aguas abajo del obstáculo. Como la descarga es **libre** (no
ahogada), M2 se calcula con la sección llena en y=a (no hace falta la
fórmula híbrida de flujo dividido). La potencia disipada en un resalto es
P=γ·Q·h_resalto, con h_resalto=(y2−y1)³/(4y1y2) la pérdida de carga entre
los tirantes conjugados exactos del resalto (no los de la malla de
búsqueda, para no perder precisión).

**Herramienta:** `Mom_rect.m` (momento M(y) en forma cerrada, sección
rectangular) para M1 y M2 de la compuerta y para el conjugado exacto del
resalto.

**Script:** `Ejercicio1_lago_compuerta_caidalibre.m`, sección "PARTE 3".

**Resultado:**
```
M1 = 4.806 m3   (y=yA=2.094 m)
M2 = 2.635 m3   (y=a=0.35 m)
F = gamma*(M1-M2) = 21 280 N = 21.28 kN   (sobre la compuerta)

h_resalto = (y2-y1)^3/(4 y1 y2) = 0.0805 m   (y1=0.514, y2=1.076, conjugados exactos)
P = gamma*Q*h_resalto = 3276 W = 3.28 kW
```

**Comparación con la solución oficial:** el examen no trae un valor
numérico final legible para esta parte en la copia disponible (última
página, muy oscurecida/degradada en el escaneo); los resultados de arriba
son consistentes con los datos (Q, yA, a, tirantes del resalto) que sí
están validados contra el resto de la solución oficial.

---

## EJERCICIO 2 (25 puntos) — Cuenca cañada San Fructuoso (Río Negro)

**Enunciado (resumen):**
1) Delimitar la cuenca de la cañada San Fructuoso (Río Negro), punto de
   cierre X=382.5 km, Y=6408.5 km, sobre carta topográfica SGM adjunta
   (curvas de nivel cada 10 m).
2) Determinar el desnivel máximo del cauce principal y el tiempo de
   concentración, con L=5875 m (flujo concentrado).
3) Con la precipitación extrema dada en bloques de 0.25 h (tabla/gráfico
   de intensidades I(mm/h): 5, 10, 15, 10, 5, 1, 0.5, 0.3, 0.1, 0.05),
   determinar el tiempo de encharcamiento con el modelo de Horton
   (f0=24 mm/h, fc=4.4 mm/h, k=2.5 1/h).

Teoría usada: delimitación de cuencas y divisoria de aguas (§B1),
tiempo de concentración de Ramser-Kirpich (§B2), infiltración de Horton
y tiempo de encharcamiento (§B8) — ver
`RESUMEN EXAMEN/Teorico/RESUMEN_TEORICO.md`.

### Partes 1) y 2) — Delimitación de la cuenca, desnivel y tc: NO resueltas en esta corrida

**Motivo.** La carta topográfica SGM incluida en el PDF del examen
(`EXAMENES/2018 diciembre.pdf`, página 3) está escaneada con muy baja
calidad/contraste (curvas de nivel y cotas apenas legibles incluso a
400 dpi con recortes por cuadrante) y la solución oficial manuscrita
(página 6) también está muy degradada — no se pudo leer con confianza
ni el trazado de la divisoria de aguas ni las cotas de nacimiento/cierre
del cauce principal necesarias para el desnivel ΔH. Delimitar a mano
"a ojo" sobre una imagen ilegible e inventar cotas para el desnivel
produciría un resultado no verificable y potencialmente engañoso, así
que se prefiere dejarlo pendiente antes que dar un número sin respaldo.

**Método a aplicar (para hacerlo a mano con la carta física, ver §B1
y §B2 del resumen teórico):**
- Trazar la divisoria de aguas perpendicular a las curvas de nivel,
  pasando por los puntos de mayor cota que separan la cuenca de las
  vecinas, cerrando en el punto de cierre dado (X=382.5, Y=6408.5 km).
- Leer en la carta la cota del punto más alto del cauce principal
  (nacimiento) y la cota en el punto de cierre; ΔH = diferencia entre
  ambas.
- Con L=5875 m (dato del enunciado, no hace falta medirlo en la carta)
  y S=ΔH/L, aplicar Ramser-Kirpich: tc = 0.0195·L^0.77·S^(-0.385) (L en
  m, tc en minutos) — fórmula de §B2, justificando "flujo concentrado"
  como pide el enunciado (cauce definido, no flujo laminar en manto).

**Pendiente para una próxima corrida:** si se consigue una copia de
mayor resolución de la carta topográfica (o se define manualmente sobre
un mapa georreferenciado), completar 1) y 2) con el mismo método.

### Parte 3) Tiempo de encharcamiento (modelo de Horton)

**Concepto.** El tiempo de encharcamiento es el instante en que la
intensidad de lluvia supera la capacidad de infiltración del suelo
f(t): antes, toda la lluvia infiltra; desde ese instante, el exceso
empieza a acumularse en superficie (§B8).

**Fórmula:** f(t) = fc + (f0−fc)·e^(−k·t). Criterio: comparar, al
inicio de cada bloque, la intensidad I del bloque (acá dada
directamente por el enunciado, no hace falta dividir P/Δt) contra
f(t_inicio); el primer bloque con I≥f(t_inicio) marca t_enc.

**Por qué esta herramienta.** Es álgebra cerrada de Horton (una
exponencial), sin geometría de canal ni de cuenca de por medio — no
hace falta Octave ni la planilla de eventos extremos. Se usó Python,
con la función canónica `RESUMEN EXAMEN/Codigos/Infiltracion/horton_encharcamiento.py`
(ver `Ejercicio2_Horton.py` en esta carpeta, versión adaptada a los
datos de este examen), mismo patrón validado en 2019 julio y 2023 feb 2.

**Script:** `Ejercicio2_Horton.py`. Entradas: f0=24, fc=4.4, k=2.5,
bloques de 0.25 h con I dada directamente (mm/h).

**Resultado:**
```
t(h)   I bloque (mm/h)   f(t_ini) (mm/h)   Estado
0.00        5.00              24.00        lluvia-limitado
0.25       10.00              14.89        lluvia-limitado
0.50       15.00              10.02        ENCHARCA (I>=f)
```

**t_enc = 0.50 h = 30 min.**

(Verificado también con la función canónica del toolkit — mismo
resultado; y cruzado contra el caso ya validado de 2019 julio, que
reproduce exactamente t_enc=0.5h y Vesc=37mm de la solución oficial de
ese examen, confirmando que la implementación del modelo de Horton es
correcta.)

**Comparación con la solución oficial:** la página de solución oficial
(pág. 6 del PDF) está manuscrita y muy degradada en el escaneo — no se
pudo leer un valor numérico final con confianza para comparar
directamente, pero el planteo (tabla f(t) vs. I por bloque) coincide
con el esquema visible en esa página.

---

## ESTADO: EN CURSO (Ejercicio 1 completo; Ejercicio 2 parcial —
parte 3 resuelta, partes 1 y 2 pendientes por calidad de escaneo de la
carta topográfica; faltan Ejercicios 3 y 4)
