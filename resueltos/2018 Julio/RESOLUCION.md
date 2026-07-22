# Examen HHA — 23 de julio de 2018

Resolución paso a paso. Herramientas usadas: Octave (funciones de
`RESUMEN EXAMEN/Codigos/FGV_trapezoidal/`, copiadas a este directorio)
para el Ejercicio 1.

El PDF del examen (`EXAMENES/2018 Julio.pdf`) trae la letra completa en
las páginas 1-2 (texto legible, extraído con PyMuPDF) y una solución
oficial manuscrita en las páginas 3-7, mucho más degradada/con letra
difícil (fotos rotadas, texto cursivo). Se intenta comparar cuando se
puede reconocer algo con confianza; si no, se documenta la limitación.

---

## EJERCICIO 1 (25 puntos) — Canal trapezoidal de largo infinito, compuerta ideal, tensión rasante

**Enunciado (resumen):** canal trapezoidal (b=6 m, m=1H:1V) de largo
infinito, Q=10 m³/s, S0=0.0008, n=0.015.
1) Clasificar el canal.
2) Se coloca una compuerta de fondo ideal de abertura *a* en una sección
   cualquiera. Hallar la abertura mínima *a* tal que la tensión rasante
   (de corte de fondo) inmediatamente aguas abajo de la compuerta no
   supere 65 Pa.
3) Con la compuerta fija en esa abertura, dibujar el perfil de la
   superficie libre (tirantes de interés, resaltos si los hay).
4) Calcular la fuerza que ejerce el flujo sobre la compuerta.

Teoría usada: ecuación de Manning y tirante crítico para clasificar el
canal (§A1, §A2), tensión rasante de fondo en FGV τ0(y)=γ·Rh·Sf (§A6,
variante "abertura mínima de compuerta por tensión rasante admisible",
añadida a partir de este examen), compuerta de fondo ideal en canal
infinito con Q fijo (§A5, variante añadida a partir de este examen),
cantidad de movimiento y fuerza sobre una compuerta (§A3). Ver
`RESUMEN EXAMEN/Teorico/RESUMEN_TEORICO.md`.

### Parte 1) Clasificación del canal

**Concepto.** El canal es "de largo infinito" y transporta un caudal
Q=10 m³/s fijo (dato del problema, no depende de ningún control). Se
clasifica comparando el tirante normal yn (Manning, con la pendiente y
rugosidad reales del canal) contra el tirante crítico yc (geometría y Q,
independiente de la pendiente): yn>yc ⇒ pendiente suave (canal tipo M,
subcrítico en flujo uniforme); yn<yc ⇒ pendiente fuerte (tipo S).

**Por qué esta herramienta.** Es el caso base de §A1: sólo hace falta
resolver Manning (yn) y Froude=1 (yc) para un canal trapezoidal, sin
integrar ninguna EDO todavía.

**Script:** `Ejercicio1_canal_compuerta_rasante.m`, sección "PARTE 1"
(usa `tirantes_yn_yc.m`, que a su vez llama a `eq_yn.m`/`eq_yc.m` y
`trap_geom.m`). Entradas: Q=10, b=6, m=1, S0=0.0008, n=0.015.

**Resultado:**
```
yn = 0.9298 m
yc = 0.6333 m
```
Como yn > yc ⇒ **canal de pendiente suave (tipo M, flujo subcrítico en
régimen uniforme)**.

### Parte 2) Abertura mínima de la compuerta por tensión rasante ≤ 65 Pa

**Concepto.** Inmediatamente aguas abajo de una compuerta de fondo ideal
de abertura *a*, el tirante es yB=a (vena contraída, sin pérdida por
definición de "compuerta ideal"). En esa sección, aunque el flujo no sea
uniforme, la tensión de corte de fondo se calcula con la misma fórmula
de flujo gradualmente variado τ0(y)=γ·Rh(y)·Sf(y), con Sf(y) la pendiente
de energía de Manning evaluada con el Q real y la geometría de esa
sección (§A6). Como τ0 es **decreciente** en y (a menor tirante, mayor
velocidad, mayor Sf), existe una única abertura a_min para la cual
τ0(a_min)=65 Pa exactamente: cualquier abertura **menor** da más tensión
que la admisible (peligro de erosión del lecho/revestimiento aguas abajo
de la compuerta), así que la abertura mínima admisible es esa a_min.

**Por qué esta herramienta.** Es exactamente el caso de `rasante_max.m`
(ya usado en 2025 feb 1), aplicado aquí no sobre un perfil de FGV ya
calculado sino directamente sobre el tirante conocido yB=a de la vena
contraída — no hace falta integrar ninguna EDO para esta parte, porque
el canal es infinito y no hay ningún otro control que fije el punto
exacto donde τ0=65 Pa salvo la propia compuerta.

**Script:** `Ejercicio1_canal_compuerta_rasante.m`, sección "PARTE 2".

**Resultado:**
```
a_min = 0.3509 m
tau(a_min) = 65.000 Pa  (verificado)
a_min = 0.3509 m < yc = 0.6333 m  -> descarga supercrítica, consistente
```

**Verificación cruzada de la fórmula de τ0:** se comprobó que
τ0(yn)=5.854 Pa coincide exactamente con γ·Rh(yn)·S0=5.854 Pa (la
tensión de flujo uniforme, donde Sf=S0 por definición) — confirma que
`tau_fun` está bien planteada.

**Abertura mínima = 0.351 m.**

### Parte 3) Perfil de la superficie libre con la compuerta fija en a_min

**Concepto.** La compuerta ideal conserva la energía específica entre
la sección justo antes (yA) y justo después (yB=a_min): E(yA)=E(yB), con
yA la rama subcrítica (alterno de yB). Lejos de la compuerta, en ambos
sentidos, el canal (infinito) tiende al tirante normal yn (no hay lago
ni caída libre que impongan otro control, a diferencia de 2018 dic).

**Por qué esta herramienta.** Con el canal siendo infinito y sin ningún
otro control salvo la propia compuerta, no hace falta (ni es posible,
por falta de datos de distancia) ubicar la posición **exacta** x del
resalto: cualquier posición aguas abajo de la compuerta es compatible
con que el tramo subcrítico posterior se relaje asintóticamente a yn más
adelante. Alcanza con describir el perfil **cualitativamente** con los
tirantes de interés (§A5, variante "canal infinito con Q fijo").

**Script:** `Ejercicio1_canal_compuerta_rasante.m`, sección "PARTE 3"
(usa `Eesp_trap.m` para el alterno yA).

**Resultado:**
```
yB = a_min = 0.3509 m   (supercrítico, justo aguas abajo de la compuerta)
E(yB) = 1.3782 m
yA (alterno subcrítico, justo aguas arriba de la compuerta) = 1.3240 m
yn = 0.9298 m  (tirante lejos de la compuerta, aguas arriba y aguas abajo)
yc = 0.6333 m
```

**Descripción del perfil (x creciente en el sentido del flujo):**
- Lejos aguas arriba de la compuerta: y≈yn=0.930 m (flujo uniforme).
- Acercándose a la compuerta: curva **M1** (remanso, creciente) desde
  yn=0.930 m hasta yA=1.324 m justo antes de la compuerta.
- En la compuerta: salto de yA=1.324 m a yB=a_min=0.351 m.
- Justo después de la compuerta: curva **M3** (supercrítica, y<yc,
  creciente) que acelera el tirante desde 0.351 m.
- **Resalto hidráulico** en algún punto aguas abajo (posición exacta no
  determinada por falta de una longitud de referencia en el enunciado):
  conecta el tirante de la curva M3 con su conjugado (vía `Mom_trap`),
  ya en la rama subcrítica.
- Después del resalto: curva **M2** que se relaja asintóticamente hacia
  yn=0.930 m lejos aguas abajo.

### Parte 4) Fuerza sobre la compuerta

**Concepto.** Con la compuerta fija en a_min y descarga libre (no
ahogada, ya que a_min<yc), la fuerza que el flujo ejerce sobre la
compuerta es F=γ·(M1−M2) (cantidad de movimiento, §A3), con M1 el
momento en yA (justo aguas arriba, sección llena) y M2 el momento en
yB=a_min (justo aguas abajo, sección llena — no hace falta la fórmula
híbrida de descarga ahogada porque acá la descarga es libre).

**Herramienta:** `Mom_trap.m` (momento M(y) en forma cerrada, sección
trapezoidal).

**Script:** `Ejercicio1_canal_compuerta_rasante.m`, sección "PARTE 4".

**Resultado:**
```
M1 = 7.0835 m3   (y=yA=1.3240 m)
M2 = 4.9580 m3   (y=yB=a_min=0.3509 m)
F = gamma*(M1-M2) = 20 830 N = 20.83 kN   (empuja la compuerta hacia aguas abajo)
```

**Comparación con la solución oficial:** las páginas de solución oficial
(3-7 del PDF) son manuscritas, con letra cursiva difícil y fotografiadas
con rotación/perspectiva; no se pudo extraer con confianza suficiente
los valores numéricos finales de esta parte para comparar directamente.
El planteo (clasificación M, compuerta ideal con alterno, tensión
rasante, cantidad de movimiento) es coherente con el tipo de ejercicio y
con los demás exámenes ya resueltos del curso que usan exactamente las
mismas herramientas.

---

## Pendiente para próximas corridas

- Ejercicio 2 (hietograma, período de retorno de la intensidad máxima,
  infiltración NRCS, tiempo de encharcamiento).
- Ejercicio 3 (alcantarilla, Racional/NRCS según tc, % de urbanización
  máximo admitido).
- Ejercicio 4 (dos bombas en paralelo, coeficientes de pérdida de carga
  Kgs/Kgi, potencia y cavitación).

## ESTADO: EN CURSO (Ejercicio 1 de 4 completo)
