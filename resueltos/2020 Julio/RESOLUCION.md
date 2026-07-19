# Examen HHA — 7 de julio de 2020

Resolución paso a paso. Herramientas usadas: Octave (funciones de la carpeta
`RESUMEN EXAMEN/Codigos/FGV_trapezoidal/`, copiadas y adaptadas en
`scripts/`) para el Ejercicio 1; Python/planilla de eventos extremos para el
Ejercicio 2; Octave (bombas) para el Ejercicio 3.

Hay solución oficial (manuscrita) **incluida en el mismo PDF del examen**
(`EXAMENES/2020 Julio.pdf`, páginas 4 a 9: son fotocopias reducidas y a
veces rotadas/con sangrado del reverso, pero legibles). Se cita y compara
en cada ejercicio.

---

## EJERCICIO 1 (30 puntos) — Dos lagos conectados por un canal trapezoidal, con una cañería atravesando el fondo

**Datos:** canal trapezoidal, ancho de fondo b=3 m, talud m=2 (2H:1V),
longitud L=6000 m, pendiente de fondo S₀=0.0008, Manning n=0.015. Nivel del
Lago A sobre el fondo del canal en x=0: h_LA=1.6 m. Nivel del Lago B sobre
el fondo del canal en x=L=6000 m: h_LB=1.8 m.

Teoría usada: ecuación de FGV y clasificación M/S (Teórico HHA §2.2.4),
energía específica y tirante crítico (§2.2.3), **perfiles de flujo entre
dos lagos** (§2.5.4) y **transición por escalón de fondo** (§2.2.5,
Ejemplo 1 del Teórico, prácticamente idéntico en estructura a la Parte 2/3
de este ejercicio). Ver también `RESUMEN EXAMEN/Teorico/RESUMEN_TEORICO.md`
§A4 y §A5 (sección "Escalón INTERIOR a un tramo largo entre dos lagos",
añadida a partir de este examen).

### Parte 1) Caudal de descarga, clasificación M/S y perfil de la superficie libre

**Concepto.** El bed desciende S₀·L=4.8 m entre A y B, mucho más que la
diferencia de niveles de los lagos (0.2 m), por lo que la superficie libre
del Lago A está muy por encima de la del Lago B ⇒ el flujo va de A hacia
B. Se trata del caso "dos lagos conectados por un canal" del Teórico
§2.5.4: en la entrada (ideal, sin pérdidas) la energía específica iguala el
nivel del lago, E(x=0)=h_LA; en la salida, si el nivel del Lago B es mayor
al tirante que trae el canal, el tirante en x=L iguala el nivel del lago,
y(x=L)=h_LB (hipótesis habitual de pérdida = término cinético en la
desembocadura).

**Procedimiento (iterativo en Q):** se prueba un Q, se calculan yn e yc
(Manning y crítico, trapezoidal — sin forma cerrada, `tirantes_yn_yc.m`
resuelve por `fsolve`), se integra la EDO de FGV (`rect.m` — pese al
nombre, es la versión trapezoidal, ver comentario en el propio archivo)
desde x=L (y=h_LB) hacia aguas arriba hasta x=0, y se compara la energía
resultante E(x=0) con h_LA. Se itera Q con `fzero` hasta que
E(x=0)=h_LA. Como estimación inicial se usa la hipótesis de canal muy
largo (`sistema_lago_M.m`: sistema energía+Manning asumiendo y(0)≈yn).

**Herramienta:** `caudal_M_ini.m`/`sistema_lago_M.m` (estimación inicial),
`tirantes_yn_yc.m`, `rect.m`+`critico.m` (integración FGV con `ode23`),
todo dentro de un `fzero` en Q. Se usan estas funciones porque son las que
provee el curso específicamente para este tipo de problema (canal M
alimentado y controlado por dos lagos) y automatizan la parte más tediosa
(resolver yn/yc trapezoidal sin forma cerrada, e iterar Q a mano).

**Script:** `scripts/ej1_parte1.m`. Entradas: `b=3, m=2, n=0.015,
S0=0.0008, L=6000, hLA=1.6, hLB=1.8`.

**Resultado:**
```
Q  = 14.9071 m3/s
yn = 1.4428 m
yc = 1.0677 m
```
Como y_n > y_c ⇒ **el canal es de tipo M (mild)**. Como h_LB (1.8 m) > yn
(1.44 m) ⇒ se forma una **curva M1** (remanso) que decrece hacia aguas
arriba, tendiendo asintóticamente a yn.

**Verificación:** integrando desde el Lago B, se obtiene y(x=0)=1.4428 m ≈
yn, con E(x=0)=1.6000 m = h_LA exactamente. Es decir, el canal es tan largo
frente al desarrollo típico de la curva M1 (que ya está dentro del 1% de yn
a partir de x≈1200 m aprox., mirando desde B) que el Lago A "ve" un canal
que descarga prácticamente con tirante normal — la hipótesis de canal muy
largo (`sistema_lago_M.m`) ya da, en este caso, el resultado casi exacto.

**Perfil de la superficie libre (x medido desde el Lago A):**
- x=0 a x≈4800 m: tirante prácticamente constante e igual a yn=1.44 m
  (flujo uniforme, subcrítico).
- x≈4800 m a x=6000 m: curva de remanso M1, el tirante crece suavemente
  desde yn hasta h_LB=1.8 m en el borde con el Lago B.
- **No hay resaltos** en este perfil (todo el escurrimiento es subcrítico).

**Resultado final Parte 1: Q = 14.91 m³/s, y_n = 1.443 m, y_c = 1.068 m,
canal tipo M, curva M1 entre yn y h_LB cerca del Lago B.**

**Comparación con solución oficial:** el manuscrito da Q≈15 m³/s,
yn≈1.447 m, yc≈1.071 m (canal M) — **coincide bien** (diferencias <0.5% en
Q y yn, consistentes con redondeo manual/gráfico; el valor de yc se leyó con
dificultad en el escaneo pero 1.071 encaja mucho mejor que una primera
lectura de "1.031").

### Parte 2) Altura máxima D de una cañería que atraviesa el canal en x=3000 m, sin afectar el flujo

**Concepto.** La cañería, colocada transversalmente en el fondo, actúa como
un **escalón de fondo** de altura D (Teórico §2.2.5, Ejemplo 1): sin
pérdidas de energía, E(antes) = E(cresta) + D. El D máximo que no altera el
tirante aguas arriba es aquel para el cual la energía sobre la cresta es
exactamente la mínima posible (crítica): Dmax = E_antes − Ec. Como el punto
x=3000 m está dentro del tramo donde y≈yn (ver Parte 1), E_antes ≈ En.

**Herramienta:** se evalúa el perfil de la Parte 1 en x=3000 m
(`interp1`), y se calculan Ec (con `trap_geom.m`) y Dmax por diferencia. No
hace falta ninguna herramienta adicional: es la aplicación directa de la
fórmula de escalón del Teórico §2.2.5, con los resultados ya obtenidos en
la Parte 1.

**Script:** `scripts/ej1_parte2.m`.

**Resultado:**
```
y(x=3000) sin caneria = 1.4428 m  (= yn, dentro de la Parte 1)
E(x=3000)             = 1.6000 m
Ec                    = 1.4448 m
Dmax = E(x=3000) - Ec = 0.1552 m
```

**Resultado final Parte 2: la altura máxima de la cañería para no afectar
el flujo es D_max ≈ 0.155 m (0.1552 m).**

**Comparación con solución oficial:** el manuscrito plantea exactamente
Dmax = En − Ec = 1.60 m − 1.45 m = **0.15 m** — **coincide** con el
resultado obtenido (0.1552 m redondea a 0.15 m).

### Parte 3) Se construye la cañería con D=0.6 m (> Dmax): caudal, perfil y resalto

**Concepto.** Como D=0.6 m > Dmax=0.155 m, la cañería **sí afecta** el
flujo: se establece un nuevo control de **flujo crítico sobre la cañería**
(análogo a un vertedero de cresta ancha). Aguas arriba se forma una curva
M1 de remanso (el tirante sube hasta el valor cuya energía específica,
menos D, es exactamente Ec); aguas abajo el flujo se acelera a
supercrítico (curva M3) y debe reconectar con la curva subcrítica que
llega desde el Lago B mediante un **resalto hidráulico** (Teórico §2.2.5 y
§2.3.2–2.3.3, y ver `RESUMEN_TEORICO.md` §A5).

A diferencia del caso "control crítico en la entrada de un canal" (donde
una perturbación aguas abajo no cambia Q, porque el flujo supercrítico no
transmite información hacia aguas arriba), acá el control crítico
**nuevo** está en medio de un tramo subcrítico, así que **si** el caudal
cambiara, cambiaría también yn, yc y toda la curva M1 entre la cañería y
el Lago A — hay que verificar autoconsistencia. Se itera un `fzero`
**externo** en Q: para cada Q se calcula Ec(Q), se fija
E1_nuevo=Ec(Q)+D, se resuelve la rama subcrítica y1 de esa energía, se
integra la M1 desde x=3000 (y=y1) hacia atrás hasta x=0, y se exige
E(x=0)=h_LA (mismo patrón que el caso "cambio de pendiente" de
`RESUMEN_TEORICO.md` §A4).

**Herramienta:** función auxiliar `Eesp_error` (energía específica menos
la energía objetivo, para hallar por `fsolve` las dos raíces —subcrítica y
supercrítica— de la ecuación cúbica trapezoidal), `rect.m`+`critico.m`
(integración FGV con eventos), y `Mom_trap.m` (conjugado, para ubicar el
resalto comparando el conjugado de la curva M3 con la curva que llega
desde el Lago B). Se usan porque son exactamente las piezas que provee el
curso para escalón + resalto en sección trapezoidal (ver
`encontrar_resalto.m` en la misma carpeta, que resuelve el mismo tipo de
cruce conjugado-vs-perfil).

**Script:** `scripts/ej1_parte3.m` (guarda `part3.mat`; requiere haber
corrido antes `ej1_parte1.m`, que genera `part1.mat`).

**Resultado:**
```
Nuevo caudal Q = 14.9061 m3/s   (vs. 14.9071 m3/s sin caneria: variacion < 0.01%)
yn = 1.4427 m , yc = 1.0677 m   (practicamente iguales a la Parte 1)
Ec (critica, sobre la caneria)               = 1.4448 m
E antes/despues de la caneria = Ec + D       = 2.0448 m
y1 (inmediatamente antes de la caneria, subcritico)  = 1.9856 m
y3 (inmediatamente despues de la caneria, supercrit) = 0.6622 m
```
El caudal prácticamente no cambia porque tanto el tramo Lago A→cañería
(3000 m) como el tramo cañería→Lago B (3000 m) son mucho más largos que el
desarrollo típico de las curvas M1/M2 de este canal (~1000-1200 m) — el
canal "olvida" la perturbación del escalón mucho antes de llegar a
cualquiera de los dos lagos. Esto confirma (a posteriori) la simplificación
que usa la solución oficial de asumir Q inalterado.

**Perfil aguas arriba de la cañería:** la curva M1 sube desde yn=1.443 m
(cerca del Lago A) hasta y1=1.986 m justo antes de la cañería (remanso
producido por la obstrucción). Verificación: integrando desde x=3000 hacia
atrás se llega a y(x=0)=1.4428 m con E(x=0)=1.6000 m = h_LA. ✓.

**Perfil aguas abajo:** inmediatamente después de la cañería el tirante
"cae" a y3=0.6622 m (supercrítico) y se desarrolla una curva M3 creciente.
Esta curva se acerca muy rápido a yc (en unos 80 m, con dy/dx→∞ al
acercarse al crítico, como es de esperar en una M3 — Teórico §2.2.4), por
lo que el resalto debe ocurrir antes de ese punto.

**Ubicación del resalto:** se calculó el conjugado de la curva M3 en cada
x (`Mom_trap.m`) y se comparó con la curva que llega desde el Lago B
(integrada con el mismo Q nuevo). El cruce da:
```
x_resalto = 3025.9 m  (25.9 m aguas abajo de la caneria)
y1 (antes del resalto, rama M3, supercritico)  = 0.7549 m
y2 (despues del resalto, rama M1/M2, ~yn)      = 1.4427 m
```
Aguas abajo del resalto el tirante permanece ≈yn=1.443 m hasta que, cerca
del Lago B, se desarrolla la misma curva M1 final de la Parte 1 hasta
h_LB=1.8 m.

Gráfico del perfil completo: `scripts/ej1_perfil.png` (vista general) y
`scripts/ej1_perfil_zoom.png` (detalle de la zona de la cañería y el
resalto).

**Resultado final Parte 3: el flujo SÍ se ve afectado (D=0.6 m > Dmax).
Caudal prácticamente sin cambios, Q ≈ 14.91 m³/s. Tirante justo antes de
la cañería: 1.99 m. Tirante justo después (supercrítico): 0.66 m. Resalto
hidráulico ubicado ≈26 m aguas abajo de la cañería, entre y=0.75 m y
y=1.44 m (≈yn).**

**Comparación con solución oficial:** el manuscrito plantea el mismo
mecanismo (E1=Ec+D=1.45+0.6=2.05 m, rama subcrítica y1≈1.99 m aguas
arriba; rama supercrítica y=0.665 m aguas abajo descartando la rama
subcrítica alterna de 1.99 m "porque no hay curva M para llegar al lago
B"), y ubica el resalto "a los 26 m" de la cañería con tirante conjugado
y*≈0.7587 m llegando a yn — **coincide muy bien** con los valores
calculados (25.9 m, 0.7549 m), con diferencias del orden del redondeo
gráfico manual.

### Resumen Ejercicio 1

| Ítem | Resultado |
|---|---|
| Q (sin cañería) | **14.91 m³/s** |
| y_n | **1.443 m** |
| y_c | **1.068 m** |
| Tipo de canal | **M (mild)** |
| Perfil sin cañería | Uniforme (y≈yn) casi todo el canal, curva M1 remontando a h_LB=1.8 m cerca del Lago B |
| D máximo que no afecta el flujo | **0.155 m** |
| Con D=0.6 m: ¿afecta el flujo? | **Sí** |
| Con D=0.6 m: nuevo caudal | **14.91 m³/s (prácticamente sin cambios)** |
| Tirante antes / después de la cañería | **1.99 m / 0.66 m** |
| Posición y tirantes del resalto | **26 m aguas abajo de la cañería, 0.75 m → 1.44 m** |

Todos los resultados numéricos coinciden con la solución oficial
manuscrita dentro del margen esperable de redondeo/lectura gráfica manual.

---
