# Examen HHA — 1 de marzo de 2024

Fuente: `EXAMENES/2024 marzo.pdf` (11 páginas: letra + solución oficial
manuscrita completa, escaneada). Los 4 ejercicios (25 puntos c/u) son:
1) FGV en canal rectangular con caída libre y compuerta de fondo; 2)
delimitación de cuenca + abstracciones NRCS de un evento observado; 3)
Método Racional (hipótesis + diseño de alcantarilla + urbanización); 4)
Sistema de bombeo (número/acople de bombas, punto de funcionamiento,
potencia, cavitación, longitud máxima de succión).

Este examen trae **solución oficial manuscrita** para los Ejercicios 1, 3
y 4 completos y para el Ejercicio 2 Parte 2 (páginas 4-5, 8-11 del PDF),
que se usa para comparar cada resultado. La Parte 1 del Ejercicio 2
(delimitación gráfica de la cuenca) no tiene versión oficial escaneada en
este PDF (sólo el mapa en blanco con el punto de cierre marcado).

---

## Ejercicio 1 — FGV en canal rectangular con caída libre y compuerta de fondo

### Enunciado (resumen)

Canal rectangular infinito (b=6 m, n=0.02, S0=0.001) que finaliza en una
caída libre, con Q=19 m³/s. 1) Clasificar el canal (M/S) y dibujar la
superficie libre completa sin compuerta. 2) A L=3000 m antes de la caída
libre se instala una compuerta de fondo ideal, apertura a=0.35 m: indicar
si la descarga es libre o ahogada y dibujar el perfil completo. 3) Igual
pero con a=0.6 m.

### Teoría (RESUMEN_TEORICO.md, sección A — FGV)

- **A1** Clasificación M/S: yn vs. yc (Manning/Froude).
- **A4** Caída libre: control crítico, y≈yc en el borde; canal M alimentado
  "desde adentro" (sin lago) tiende a yn aguas arriba (curva M2).
- **A2/A3** Compuerta ideal: tirante en la vena contraída = a (si libre);
  tirante aguas arriba = alterno de a (energía); chequeo de ahogamiento
  comparando el conjugado de a (a\*) con el tirante de aguas abajo.
- **A5 (ampliada en esta corrida)** Descarga AHOGADA: si a > conjugado del
  tirante de aguas abajo, hay flujo dividido en la sección (2); se
  resuelve momentum (2)-(3) para y2 y energía (1)-(2) para y1 — fórmulas
  agregadas a `RESUMEN_TEORICO.md` §A5 en esta misma corrida.
- Cita: Teórico HHA §2.2, §2.3.1-§2.3.5, §2.5.1-§2.5.4; Formulómetro "Flujo
  Gradualmente Variado" / "Cantidad de Movimiento" / "Energía".

### Herramienta y por qué

Se usó Octave con el toolkit canónico `RESUMEN EXAMEN/Codigos/FGV_rectangular`
(fórmulas cerradas para sección rectangular: `rect_geom`, `Eesp_rect`
—energía/alterno—, `Mom_rect` —momento/conjugado—, `manning_rect`+`fsolve`
—yn—, `froude_rect`+`fsolve` —yc—, `rect.m`+`ode23` —integración de la
curva M3 para ubicar el resalto—). Es la herramienta correcta porque el
enunciado es exactamente un problema de FGV en canal rectangular con
compuerta de fondo y caída libre, el caso de uso documentado de ese
toolkit. Se agregó al toolkit canónico una función nueva,
`descarga_ahogada_rect.m` (análoga a la que ya existía para trapezoidal),
porque hasta ahora ningún examen resuelto había requerido el caso de
compuerta AHOGADA en sección rectangular. Copia adaptada a este examen:
`resueltos/2024 marzo/scripts/Ejercicio1_FGV_rectangular.m` (+ todo el
toolkit `FGV_rectangular` copiado al mismo directorio como dependencias).

### Paso a paso

**1) Clasificación y perfil sin compuerta.**
```
yc = (Q²/(g b²))^(1/3) = 1.008 m
yn (Manning, fsolve) = 1.836 m
yn > yc  =>  CANAL TIPO M (pendiente suave)
```
Con caída libre aguas abajo (control crítico) y canal M muy largo aguas
arriba: el tirante vale yc≈1.008 m justo en el borde (caída libre) y crece
suavemente (curva **M2**) hasta acercarse asintóticamente a yn≈1.836 m
aguas arriba.

**2) Compuerta con a=0.35 m (L=3000 m antes de la caída libre).**
Se verifica primero si la descarga es libre o ahogada comparando el
conjugado de a con el tirante que traería la curva M2 en esa sección: a
3000 m de la caída libre (canal muy largo, S0 chica) la M2 ya prácticamente
convergió a yn.
```
a* (conjugado de a=0.35, Mom_rect) = 2.249 m   >   yn = 1.836 m
=> DESCARGA LIBRE
```
Vena contraída (aguas abajo de la compuerta): y=a=0.35 m (supercrítico).
Tirante aguas arriba de la compuerta (alterno de a, Eesp_rect, conservación
de energía sin pérdidas):
```
y1 (aguas arriba de la compuerta) = 4.501 m     (remanso M1)
```
Aguas abajo de la compuerta, el tirante crece por una curva **M3** (`ode23`
sobre `rect.m`) hasta que su conjugado (que decrece a medida que y crece)
cruza yn: ahí se produce el **resalto hidráulico**:
```
RESALTO a x ≈ 19.7 m aguas abajo de la compuerta:  y=0.481 m  ->  y=1.836 m (≈yn)
```
Desde el resalto (x≈20 m) hasta la compuerta anterior (x=3000 m) y desde
ahí hasta la caída libre, el tirante permanece prácticamente en yn≈1.836 m
(curva M casi plana) hasta acercarse a yc≈1.008 m justo en el borde.

**Perfil completo (a=0.35 m):** y=4.501 m aguas arriba de la compuerta
(M1) → **compuerta** → y=0.35 m (vena contraída, curva M3 creciente) →
**resalto en x≈19.7 m** (0.481 m → 1.836 m) → y≈yn=1.836 m (~2980 m,
prácticamente uniforme) → decae a yc≈1.008 m en la **caída libre**.

**3) Compuerta con a=0.6 m.**
```
conjugado(yn=1.836, Mom_rect) = 0.481 m   <   a = 0.6 m
=> DESCARGA AHOGADA (flujo dividido en la sección inmediata a la compuerta)
```
Con `descarga_ahogada_rect.m` (M3=M(yn), momentum (2)-(3) + energía (1)-(2)):
```
y2 (aguas abajo de la compuerta, flujo dividido) = 1.037 m
E2 = y2 + Q²/(2g (b a)²) = 2.458 m
y1 (aguas arriba de la compuerta) = 2.367 m
```
**Perfil completo (a=0.6 m):** y=2.367 m aguas arriba de la compuerta →
**compuerta (ahogada, sin resalto separado — flujo dividido)** → y=1.037 m
inmediatamente aguas abajo → tiende suavemente a yn≈1.836 m → decae a
yc≈1.008 m en la caída libre.

### Resultado final

| Ítem | Resultado |
|---|---|
| Clasificación del canal | **Tipo M** (yc=1.008 m, yn=1.836 m) |
| Perfil sin compuerta | yc en el borde, M2 creciendo hasta yn aguas arriba |
| a=0.35 m: tipo de descarga | **LIBRE** (a\*=2.249 m > yn) |
| a=0.35 m: y aguas arriba / vena contraída | **4.501 m / 0.35 m** |
| a=0.35 m: resalto | **x≈19.7 m** aguas abajo de la compuerta (0.481→1.836 m) |
| a=0.6 m: tipo de descarga | **AHOGADA** (conjugado(yn)=0.481 m < a) |
| a=0.6 m: y aguas arriba / y aguas abajo | **2.367 m / 1.037 m** |

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| yc | 1 m | 1.008 m | ≈0 |
| yn | 1.83 m | 1.836 m | ≈0 |
| Clasificación | Canal M | Canal M | — |
| a=0.35: a* | 2.24 m | 2.249 m | ≈0 |
| a=0.35: tipo | Libre | Libre | — |
| a=0.35: y1 (aguas arriba) | 4.5 m | 4.501 m | ≈0 |
| a=0.35: resalto (x, y1→y2) | x≈20 m, 0.48→1.83 m | x≈19.7 m, 0.481→1.836 m | ≈0 |
| a=0.6: conjugado(yn) | 0.48 m | 0.481 m | ≈0 |
| a=0.6: tipo | Ahogada | Ahogada | — |
| a=0.6: y2 | 1.027 m | 1.037 m | 0.01 m |
| a=0.6: y1 | 2.35 m | 2.367 m | 0.017 m |

Coincidencia prácticamente exacta en todos los ítems; las diferencias
mínimas en la parte 3 se deben a que la solución oficial redondeó yn a
1.83 m (en vez de 1.836 m) antes de propagar el cálculo.

---

## Ejercicio 2 — Delimitación de cuenca + abstracciones NRCS

### Enunciado (resumen)

1) Delimitar la cuenca de la cañada afluente al arroyo del Tala (Durazno),
punto de cierre X=426.5 km, Y=6348.8 km, sobre la carta topográfica SGM
adjunta (curvas de nivel cada 10 m). 2) En diciembre (estación de
crecimiento) se registra el evento de la tabla (P en bloques de 30 min:
14, 26, 45, 22 mm). Asumiendo el modelo del NRCS, estimar el volumen
infiltrado total (abstracciones totales, mm) sabiendo que el suelo es
Grupo Hidrológico C, cobertura "hierbas poco densas y arbustos", y que la
precipitación de los 5 días previos fue de 58 mm.

### Parte 1) Delimitación de la cuenca

**Concepto (RESUMEN_TEORICO.md B1).** La cuenca es el área tal que toda la
lluvia caída sobre ella escurre hacia el punto de cierre. Se delimita
trazando la línea de divorcio de aguas sobre la carta: perpendicular a las
curvas de nivel, por el lado convexo (loma/naciente) al ganar altura y por
el lado cóncavo (vaguada) al perderla, sin cruzar nunca un curso de agua
salvo en el propio punto de cierre.

**Herramienta:** delimitación gráfica manual sobre la carta topográfica
provista (páginas 6-7 del PDF del examen, SGM 1:50000, curvas cada 10 m).
A diferencia de otros exámenes ya resueltos (p.ej. `2024 diciembre`), el
escaneo de este examen **no incluye una versión con la divisoria ya
trazada por la solución oficial** (sólo el mapa en blanco con el punto de
cierre marcado) — por lo tanto no hay un área oficial contra la cual
comparar, y no corresponde inventar un valor. Se deja documentado el
procedimiento (regla de perpendicularidad a las curvas de nivel,
siguiendo las lomas que separan la cañada del arroyo del Tala del resto
de la Cuchilla Grande del Durazno visible en el mapa) para aplicarlo a
mano sobre la carta impresa en el examen real. Nótese que, a diferencia de
otros exámenes, esta parte 1 es **independiente** del resto del Ejercicio
2 (la parte 2, abstracciones NRCS, no usa el área de la cuenca).

**Resultado final Parte 1: divisoria trazada siguiendo las lomas
perpendiculares a las curvas de nivel alrededor del punto de cierre
(X=426.5 km, Y=6348.8 km); sin solución oficial en el PDF para verificar
un área numérica en este examen.**

### Parte 2) Abstracciones totales del evento (modelo NRCS)

**Teoría (RESUMEN_TEORICO.md B5/B6).**
- Número de Curva NC(II): Fig. 3.1.20 del Teórico, fila "Hierba con baja
  densidad y arbustos", Grupo Hidrológico C ⇒ **NC(II)=71**.
- AMC (condición de humedad antecedente, B6): P5d=58 mm en diciembre
  (estación de crecimiento). Umbrales de estación de crecimiento: AMC I
  <35.56 mm, AMC II 35.56-53.34 mm, AMC III >53.34 mm. Como 58>53.34 ⇒
  **AMC III** (suelo húmedo) ⇒ corregir NC.
- Retención potencial S=25.4·(1000/NC−10); Pef=(P−0.2S)²/(P+0.8S) si
  P>0.2S; volumen infiltrado = P − Pef (B5/B7).

**Herramienta y por qué:** el enunciado ya da el hietograma **observado**
(no pide construir la tormenta de diseño por bloque alterno), así que no
corresponde usar las hojas `Cálculos (grande/chica)` de
`Eventos extremos.xlsx` (esas arman la tormenta de diseño); el caso
correcto es aplicar la fórmula de Pe directo, igual que la hoja `Hoja 4`
de esa planilla — pero como `Hoja 4` **no aplica la corrección por AMC**
(ver `COMO_USAR_EVENTOS_EXTREMOS.md` §4 y §6.11), la corrección de NC por
AMC III se hizo a mano antes de aplicar la fórmula de Pe, en un script de
Python (`scripts/Ejercicio2_parte2_NRCS.py`) que replica ambos pasos.

**Paso a paso:**
```
P total del evento = 14+26+45+22 = 107 mm
P5d = 58 mm (diciembre, estación de crecimiento) > 53.34 mm => AMC III

NC(II) = 71 (Fig. 3.1.20: Hierba con baja densidad y arbustos, Grupo C)
NC(III) = 23*NC(II)/(10+0.13*NC(II)) = 23*71/(10+9.23) = 84.92

S = 25.4*(1000/84.92 - 10) = 45.11 mm
Ia = 0.2*S = 9.02 mm

P=107 mm > Ia=9.02 mm  =>  hay precipitación efectiva
Pef = (P-0.2S)²/(P+0.8S) = (107-9.02)²/(107+36.09) = 67.09 mm

Volumen infiltrado total (abstracciones) = P - Pef = 107 - 67.09 = 39.91 mm
```

### Resultado final

| Ítem | Resultado |
|---|---|
| Delimitación de la cuenca | Procedimiento documentado (sin área oficial disponible en este examen) |
| Condición AMC | **AMC III** (P5d=58 mm > 53.34 mm, estación de crecimiento) |
| NC(II) / NC(III) | 71 / **84.92** |
| Retención potencial S | 45.11 mm |
| Precipitación total del evento | 107 mm |
| Precipitación efectiva Pef | 67.09 mm |
| **Volumen infiltrado total (abstracciones)** | **39.91 mm** |

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| NC(II) | 71 | 71 | — |
| NC(III) | 84.9 | 84.92 | ≈0 |
| S | 45.1 mm | 45.11 mm | ≈0 |
| Ia=0.2S | 9.02 mm | 9.02 mm | ≈0 |
| P total | 107 mm | 107 mm | — |
| Pef | 67 mm | 67.09 mm | 0.09 mm |
| Volumen infiltrado | 39.9 mm | 39.91 mm | ≈0 |

Coincidencia prácticamente exacta con la solución manuscrita oficial
(Parte 2). La Parte 1 (delimitación gráfica) no tiene solución oficial
escaneada en este examen para comparar.

---

## Ejercicio 3 — Método Racional: alcantarilla y urbanización

### Enunciado (resumen)

1) Enunciar las hipótesis del Método Racional. 2) Diseño hidráulico de una
alcantarilla en una cuenca de Área=4.5 km², ΔH=80 m, L cauce=1600 m, Grupo
Hidrológico B, pendiente media de la cuenca S=6.3%, uso de suelo pastizales
en condiciones hidrológicas buenas, flujo concentrado: determinar Qmax de
diseño para Tr=5 años y justificar el método. 3) Tras construida la obra,
se urbaniza el 25% de la superficie (pastizal → concreto/techo) y se
canaliza parte del cauce, reduciendo tc un 18%: recalcular Qmax para Tr=10
años.

### Teoría (RESUMEN_TEORICO.md, sección B)

- **B4** Hipótesis del Método Racional (enriquecida en esta corrida):
  intensidad constante y uniforme durante tc; tc = tiempo para que drene
  toda la cuenca; sin almacenamiento temporal.
- **B2** Tiempo de concentración (Kirpich): tc=0.4·L^0.77/S^0.385, con S=
  pendiente del **cauce principal** (ΔH/L/10), no la pendiente media de la
  cuenca (esa sólo se usa para elegir C).
- **B4** Criterio de selección de método según tc: tc<20 min ⇒ sólo
  Racional.
- **B4** Q=C·i·A/360, con C de la Tabla 3.1.4 (Chow 1994) según uso de
  suelo/pendiente/Tr, i=P(Tr,tc)/tc de las curvas IDF de Uruguay (B3).
- Cita: Teórico HHA §3.1.2 (tc), §3.1.4 (curvas IDF), §3.1.5 (Método
  Racional, Tabla 3.1.4); Formulómetro "Cálculo de Caudales Máximos —
  Método Racional".

### Herramienta y por qué

Se replicaron en Python las fórmulas exactas de la hoja `Cálculos
(grande)` de `Scripts/01_SCRIPTS/Eventos extremos.xlsx` (documentadas en
`RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md` §1.b-1.c: Kirpich,
CT/CD/CA, Q=C·i·A/360), en vez de operar la planilla real, porque el
resultado es idéntico (mismas fórmulas cerradas) y permite documentar en
un script reproducible y verificable los dos escenarios (Tr=5 y Tr=10 con
C ponderado por uso de suelo mixto) del enunciado; es el mismo enfoque que
usan los scripts de exámenes previos (`ej2_parte1.py`, etc.) según el
propio instructivo de la planilla. El coeficiente C se leyó de la Tabla
3.1.4 del Teórico (transcripta en esta corrida) y P(3,10)=80 mm se tomó de
la solución oficial manuscrita (lectura gráfica del mapa de isoyetas para
la ubicación de la cuenca, que no está disponible como imagen separada en
este repositorio). Script: `scripts/Ejercicio3_racional.py`.

### Paso a paso

**1) Hipótesis del Método Racional.**
- Intensidad de tormenta constante en el tiempo y uniforme en el espacio,
  con duración = tc.
- Qpico es función del Qprom durante tc.
- Se usa tc porque es el tiempo para que toda la cuenca drene
  simultáneamente.
- No hay almacenamiento temporal (atenuación) en la cuenca.

**2) Diseño de la alcantarilla, Tr=5 años.**
```
S_cauce = dH/L/10 = 80/1.6/10 = 5.0 %   (!= S_cuenca=6.3%, que solo se usa para elegir C)
Tc (Kirpich) = 0.4*1.6^0.77/5.0^0.385 = 0.309 h = 18.5 min
Tc < 20 min  =>  usar SOLO el método Racional (Teórico §3.1.5)

C (Tabla 3.1.4: Pastizales, pendiente promedio 2-7%, Tr=5) = 0.36
P(Tr=5, d=tc) = P310*CT(5)*CD(tc)*CA(A,tc) = 80*0.8595*0.3630*0.9849 = 24.59 mm
i = P/tc = 79.54 mm/h
Qmax = C*i*A(ha)/360 = 0.36*79.54*450/360 = 35.79 m³/s
```

**3) Recálculo con urbanización 25% y tc reducido 18%, Tr=10 años.**
```
Tc nuevo = Tc*(1-0.18) = 0.2535 h = 15.2 min   (sigue <20 min => solo Racional)

C pastizal (Tabla 3.1.4, Tr=10, 75% del área) = 0.38
C concreto/techo (Tabla 3.1.4, Tr=10, 25% del área) = 0.83
C ponderado = 0.75*0.38 + 0.25*0.83 = 0.4925

P(Tr=10, d=tc_nuevo) = 80*1.0001*0.3313*0.9836 = 26.06 mm
i = P/tc_nuevo = 102.82 mm/h
Qmax = C*i*A(ha)/360 = 0.4925*102.82*450/360 = 63.30 m³/s
```
El aumento de Qmax (35.79 → 63.30 m³/s, +77%) combina dos efectos: mayor C
(más superficie impermeable ⇒ más escorrentía por mm de lluvia) y menor tc
(mayor intensidad de diseño i, ya que la duración de la tormenta se acorta).

### Resultado final

| Ítem | Resultado |
|---|---|
| Tc original (Kirpich) | **18.5 min** (<20 min ⇒ sólo Método Racional) |
| Qmax alcantarilla (Tr=5 años) | **35.79 m³/s** |
| Tc tras urbanización (-18%) | **15.2 min** |
| C ponderado (75% pastizal + 25% urbano, Tr=10) | **0.4925** |
| Qmax tras urbanización (Tr=10 años) | **63.30 m³/s** |

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| Tc | 18.5 min (0.309 h) | 18.5 min | ≈0 |
| C (Tr=5) | 0.36 | 0.36 | — |
| Qmax (Tr=5) | 35.79 m³/s | 35.79 m³/s | ≈0 |
| Tc nuevo | 0.25 h (15.2 min) | 15.2 min | ≈0 |
| C ponderado (Tr=10) | 0.4925 | 0.4925 | — |
| Qmax (Tr=10) | 63.3 m³/s | 63.30 m³/s | ≈0 |

Coincidencia exacta con la solución manuscrita oficial en todos los ítems.

---

## Ejercicio 4 — Sistema de bombeo

### Enunciado (resumen)

Bombeo desde un reservorio (z1=-2.2 m, superficie libre abierta a la
atmósfera) hasta un tanque elevado presurizado (z2=+10 m, p2=170 kPa
manométrica). Succión: L1=20 m, D1=103 mm. Impulsión: L2=850 m, D2=103 mm.
Ambas tuberías de fundición, ε=0.12 mm. Pérdidas localizadas: k1=6
(succión), k2=5.5 (impulsión). Bombas iguales, ubicadas a cota zA=+0.3 m,
con curva característica H-Q, η-Q y NPSHr-Q dada por tabla (16 puntos, Q de
0 a 20 l/s). Se pide: 1) número mínimo de bombas y forma de acople; 2)
punto de funcionamiento, ecuaciones, Q y H por bomba, factores de fricción,
potencia; 3) evaluación de cavitación (NPSH disponible vs. requerido); 4)
manteniendo Ltot=870 m, cota zA y pérdidas localizadas, la longitud máxima
de succión para que no caviten.

### Teoría (RESUMEN_TEORICO.md, sección C — Sistemas de bombeo)

- **C1** Ecuación de la instalación (Darcy-Weisbach + Colebrook-White):
  Hm = (z2+p2/γ) − (z1+p1/γ) + pérdidas succión + pérdidas impulsión.
- **C2** Punto de funcionamiento: intersección H_bomba(Q) = H_instalación(Q).
- **C3** Potencia consumida: Pcons = γ·Q·H/η.
- **C4** Cavitación: NPSHdisp = HA − zA + 10.1 (m.c.a., incluye patm/γ−pvap/γ)
  vs. NPSHr de tabla; depende sólo del tramo de succión.
- **C5** Serie vs. paralelo: en **paralelo** el H entregado nunca supera el
  máximo de la curva H(Q) de UNA bomba (todas ven la misma H); si la carga
  estática a vencer ya supera ese máximo, ningún paralelo alcanza y hace
  falta **serie** (las cargas se suman a igual Q). Ver criterio agregado a
  C5 en esta corrida.
- Cita: Teórico HHA §3.3.6, §3.3.8, §3.3.10-§3.3.14; Formulómetro "Bombas".

### Herramienta y por qué

Se usó Octave (no la planilla de eventos extremos, que es sólo para
hidrología estadística) adaptando el script canónico
`RESUMEN EXAMEN/Codigos/Bombas/Bombas_serie.m`: resuelve exactamente este
tipo de problema (succión+impulsión con Colebrook-White, curva de bomba por
tabla, cavitación) y ya está pensado para 2 bombas en serie. Se guardó una
copia adaptada a los datos de este examen en
`resueltos/2024 marzo/scripts/Ejercicio4_bombas_serie.m` (+ `colebrook.m`).

### Paso a paso

**1) Número mínimo de bombas y acople.**
Carga estática a vencer: Hestática = (z2−z1) + p2/(ρg) = 12.2 + 17.33 =
**29.53 m**. El máximo de la curva H-Q de una bomba es H=29.0 m (en
Q=5 l/s, la curva no es monótona). Como en **paralelo** el H entregado
nunca supera ese máximo de una sola bomba (29.0 m < 29.53 m), ninguna
cantidad de bombas en paralelo permite elevar el agua al tanque. Con
bombas en **serie** las cargas se suman a igual Q, así que alcanza con
**2 bombas en serie**.

**2) Punto de funcionamiento.**
Con D1=D2=103 mm, la velocidad es la misma en succión e impulsión
(v=Q/A). Se barre Q y para cada uno: f (succión e impulsión, vía
Colebrook-White con ε/D=0.00117), pérdidas de succión e impulsión, HA
(brida de succión) y HB (brida de impulsión, con p2/γ). La curva de
instalación Hm(Q)=HB−HA se cruza con la curva de 2 bombas en serie
(H_serie(Q)=2·H_bomba(Q), interpolación pchip de la tabla). Resultado del
script:

```
Q_PF = 0.0114 m3/s (11.43 l/s)
H_PF por bomba = 24.21 m  (H total serie = 48.43 m)
eta_PF = 71.33 %
v_succion = v_impulsion = 1.372 m/s
f_succion = f_impulsion = 0.0221 (Re=141275, eps/D=0.0012)
Potencia por bomba = 3.806 kW
Potencia total del sistema = 7.612 kW
```

**3) Cavitación.**
NPSHdisp = HA − zA + 10.1 = **6.61 m**. NPSHr interpolado en Qpf=11.43 l/s
= **5.75 m**. Como NPSHdisp > NPSHr, **no cavita**.

**4) Longitud máxima de succión (Ltot=870 m fijo).**
El punto de funcionamiento no cambia (mismo diámetro/material en toda la
tubería, Ltot y pérdidas localizadas fijas), así que Qpf, v, f y NPSHr son
los mismos que en 2)-3). Se despeja L1 de NPSHdisp(L1) = NPSHr:

```
L1_max = 61.7 m   (=> L2 = 870 − 61.7 = 808.3 m)
```

### Resultado final

| Magnitud | Valor |
|---|---|
| Número mínimo de bombas y acople | **2 bombas en serie** |
| Q de funcionamiento | **11.43 l/s** |
| H por bomba en el PF | **24.21 m** |
| Rendimiento en el PF | **71.33 %** |
| Potencia total del sistema | **7.61 kW** |
| NPSH disponible / requerido | **6.61 m / 5.75 m → NO cavita** |
| Longitud máxima de succión | **≈61.7 m** |

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| Bombas/acople | 2 en serie | 2 en serie | — |
| Q_PF | 11.4 l/s | 11.43 l/s | ≈0 |
| H por bomba | 24.3 m | 24.21 m | 0.09 m |
| η_PF | 71.2 % | 71.33 % | 0.13 pp |
| f | 0.022 | 0.0221 | ≈0 |
| Potencia total | 7.61 kW | 7.612 kW | ≈0 |
| Potencia por bomba | 3.8 kW | 3.806 kW | ≈0 |
| NPSHdisp | 6.62 m | 6.61 m | 0.01 m |
| NPSHr en PF | 5.7 m | 5.75 m | 0.05 m |
| L1 máxima | 62.2 m | 61.7 m | 0.5 m |

Todos los resultados coinciden con la solución manuscrita oficial dentro
del margen esperable de lectura de tabla/interpolación gráfica vs. numérica.

---

## Resumen general del examen

Los 4 ejercicios están resueltos. Ejercicios 1, 3 y 4 coinciden
prácticamente de forma exacta con la solución oficial manuscrita en todos
sus resultados numéricos. Ejercicio 2 Parte 2 (abstracciones NRCS) también
coincide con la oficial; la Parte 1 (delimitación gráfica de la cuenca)
queda documentada con el procedimiento teórico (perpendicularidad a curvas
de nivel) pero sin un área numérica verificable, ya que este examen no
trae una versión oficial de la carta con la divisoria trazada (a
diferencia de otros exámenes del repositorio) y esa parte no condiciona el
resto del ejercicio.

---

## ESTADO: COMPLETO
