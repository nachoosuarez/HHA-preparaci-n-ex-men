# Examen HHA — 16 de diciembre de 2024

Resolución paso a paso. El PDF del examen (`EXAMENES/2024 diciembre.pdf`)
incluye, además de la letra (páginas 1-4), la solución oficial manuscrita
(páginas 5-9), que se usa para comparar cada resultado.

Herramientas: Octave (scripts de `Scripts/01_SCRIPTS/FGV_felo` y
`Scripts/01_SCRIPTS/bombas Pedro`, copiados y adaptados en `scripts/`) para
los Ejercicios 1 y 4; método Racional / NRCS (Teórico HHA §3.1) para los
Ejercicios 2 y 3.

Los scripts de Octave del Ejercicio 1 son independientes entre sí
(`ej1_parte1.m` resuelve la Parte 1 completa, `ej1_parte2.m` resuelve la
Parte 2 completa; ambos recalculan Q y las curvas de tramo 1 desde cero, ya
que Q no cambia entre partes). Ambos requieren en la misma carpeta:
`trap_geom.m`, `eq_yc.m`, `eq_yn.m`, `froude_trap.m`, `manning_trap.m`,
`critico.m`, `rect.m`, `tirantes_yn_yc.m`, `Mom_trap.m`.

---

## EJERCICIO 1 — Canal trapezoidal de dos tramos entre el Lago A y el Lago B

**Datos:** sección trapezoidal, ancho de fondo b=1.2 m (igual en ambos
tramos), n=0.012, S₀=0.01. Tramo 1 (x=0 a 300 m): talud m₁=1. Tramo 2 (x=300
a 600 m): talud m₂=0.5 (reducción de talud, cambio de sección "suave" sin
pérdidas de carga). Nivel del Lago A sobre el fondo del canal: h_LA=1.80 m.

**Teoría usada:** perfiles de flujo entre dos lagos y canales de pendiente
fuerte (Teórico HHA §2.5.4), clasificación M/S de canales según y_n vs. y_c
(§2.5.2), energía específica y tirante crítico (§2.2), ecuación diferencial
del flujo gradualmente variado dy/dx=(S₀−S_f)/(1−Fr²) (§2.3, implementada en
`rect.m`/`trap_geom.m`), cantidad de movimiento y tirantes conjugados para el
resalto hidráulico (§2.3.2–2.3.3, implementado en `Mom_trap.m`).

### Parte 1) h_LB = −0.50 m (nivel del Lago B por debajo del fondo del canal)

**Concepto.** Al ser h_LB negativo (por debajo del fondo del canal), el Lago
B no puede imponer ningún control hidráulico sobre el canal: la descarga es
en caída libre, cualquiera sea el tirante con que el canal llegue al final.
Por lo tanto el único control relevante es el de aguas arriba: el Lago A
alimenta el canal, y para un canal de pendiente fuerte (tipo S, hipótesis que
se verifica más abajo) el lago descarga estableciendo el **caudal máximo
compatible con su energía**, lo que ocurre con flujo **crítico en la sección
de entrada** (x=0): el tirante crítico es el que lleva el caudal máximo para
una energía específica dada (Teórico §2.2 y §2.5.4).

**Herramienta:** sistema de 2 ecuaciones no lineales con 2 incógnitas (Q,
y_c) resuelto con `fsolve` en Octave, usando `trap_geom.m` para la geometría
trapezoidal:

```
Fr² = Q²·B(y_c)/(g·A(y_c)³) = 1        (flujo crítico en x=0)
h_LA = y_c + Q²/(2g·A(y_c)²)            (conservación de energía Lago A → x=0)
```

Se eligió resolver este sistema directamente (en vez de usar
`caudal_M_ini.m`/`caudal_S_ini.m` del repositorio) porque esos scripts están
pensados para un único tramo con parámetros fijos; acá hace falta luego
empalmar dos tramos con taludes distintos, así que se arma el cálculo a
medida reutilizando las funciones geométricas base.

**Script:** `scripts/ej1_parte1.m`. Entradas: `b=1.2, n=0.012, S0=0.01,
m1=1, m2=0.5, L1=300, L2=300, hLA=1.80, hLB=-0.50`.

**Resultado del caudal y de los tirantes característicos:**
```
Q   = 10.224 m3/s
Tramo 1 (m=1.0):  y_c1 = 1.357 m ;  y_n1 = 0.911 m
Tramo 2 (m=0.5):  y_c2 = 1.560 m ;  y_n2 = 1.086 m
```
Como y_n < y_c en **ambos** tramos ⇒ **los dos tramos son canal tipo S
(pendiente fuerte)**, confirmando la hipótesis de control crítico en la
entrada.

**Perfil de flujo:**
- **Tramo 1 (x=0 a 300 m):** con y=y_c1=1.357 m en x=0 (control crítico), se
  integra la ecuación de FGV (`rect.m`) con `ode23` hacia aguas abajo.
  Resulta una **curva S2** (supercrítica, y_n<y<y_c, decreciente) que en
  x=300 m llega a y=0.915 m, muy cerca ya del tirante normal y_n1=0.911 m
  (flujo prácticamente uniforme al final del tramo).
- **Cambio de sección (x=300 m):** como el enunciado indica transición suave
  sin pérdidas de carga, se conserva la **energía específica** entre el
  tirante final del tramo 1 (con m₁) y el tirante inicial del tramo 2 (con
  m₂): y_end,1 + Q²/(2g·A₁²) = y₂,ini + Q²/(2g·A₂²). Resolviendo con
  `fsolve`: **y₂,ini = 1.203 m**.
- **Tramo 2 (x=300 a 600 m):** con y=1.203 m en el inicio del tramo (entre
  y_n2=1.086 y y_c2=1.560, o sea sigue siendo supercrítico), se integra
  nuevamente la ecuación de FGV con el talud m₂. Resulta otra **curva S2**
  que decrece asintóticamente hacia y_n2, llegando a y=1.088 m en x=600 m
  (prácticamente y_n2=1.086 m).
- **Descarga al Lago B:** como h_LB=−0.50 m está por debajo del fondo del
  canal, el nivel del lago no controla nada: el canal descarga **en caída
  libre** con y≈y_n2=1.086 m (una pequeña cascada de ≈1.59 m sobre el nivel
  del Lago B).

Todo el escurrimiento permanece **supercrítico** en ambos tramos (canal tipo
S alimentado por un lago con control crítico aguas arriba, sin control
subcrítico aguas abajo) ⇒ **no hay resaltos hidráulicos** en este perfil.

Gráfico: `scripts/ej1_perfil_parte1.png`.

**Resultado final Parte 1: Q = 10.22 m³/s. Tramo 1 y Tramo 2 ambos tipo S.
Perfil: y_c1=1.357 m en x=0 → curva S2 → y≈0.915 m en x=300 m → transición
(y=1.203 m) → curva S2 en tramo 2 → y≈1.086 m (≈y_n2) en x=600 m → caída
libre al Lago B. Sin resaltos.**

**Comparación con la solución oficial:** el manuscrito da Q=10.22 m³/s,
y_c1=1.36 m, el fin del tramo 1 en y=0.915 m (idéntico), la transición en
y=1.2 m (idéntico) e y_c2=1.56 m — **coincide exactamente**. El y_n1 oficial
(0.94 m) difiere levemente del calculado (0.911 m) y el y_n2 oficial (1.09 m)
prácticamente coincide con el calculado (1.086 m); la pequeña diferencia en
y_n1 es coherente con redondeo manual al resolver la ecuación de Manning.

### Parte 2) h_LB = 2.3 m (el Lago B sube por encima del tirante crítico del tramo 2)

**Concepto.** Ahora h_LB=2.3 m > y_c2=1.560 m: el Lago B impone un control
**subcrítico** en el extremo aguas abajo del tramo 2 (Teórico §2.5.4). Sin
embargo el Lago A sigue imponiendo control crítico en la entrada (x=0),
siempre que el remanso del Lago B no llegue a "ahogar" esa sección —lo cual
se verifica después viendo que el resalto se ubica muy cerca del Lago B, sin
afectar el tramo 1 ni el inicio del tramo 2—. Por lo tanto **Q no cambia**
respecto a la Parte 1, y aparece un **resalto hidráulico** en el tramo 2 que
conecta la rama supercrítica (que viene igual que en la Parte 1) con la rama
subcrítica que nace en el Lago B.

**Herramienta:** mismo sistema de la Parte 1 para (Q, y_c1); dos integraciones
de la ecuación de FGV en el tramo 2 (`ode23` con `rect.m`/`critico.m`): una
hacia aguas abajo desde la transición (rama supercrítica S2, igual a la
Parte 1) y otra hacia aguas arriba desde el Lago B con y(x=600m)=h_LB (rama
subcrítica S1, ya que y_c2<h_LB). La posición del resalto se determina
buscando la intersección entre el **tirante conjugado** (`Mom_trap.m`,
cantidad de movimiento) de la rama supercrítica y la rama subcrítica S1.

**Script:** `scripts/ej1_parte2.m`. Mismos datos que la Parte 1, cambiando
sólo `hLB=2.3`.

**Resultado:**
```
Q = 10.224 m3/s (igual que Parte 1)
Tramo 1: identico a la Parte 1 (S2, yc1=1.357 -> 0.915 m en x=300m)
Transicion a tramo 2: y = 1.203 m (identica a la Parte 1)
Rama S1 (remanso del Lago B) solo existe entre x=258.83 m y x=300 m
  (medido dentro del tramo 2) -> se agota (llega a yc2) a 41.17 m
  aguas arriba del Lago B
RESALTO en x=286.72 m (dentro del tramo2, x=586.72 m desde el Lago A):
  y1 (antes, supercritico) = 1.089 m
  y2 (despues, subcritico) = 2.130 m
```

**Perfil de flujo:** tramo 1 idéntico a la Parte 1 (curva S2, sin cambios).
En el tramo 2, la curva supercrítica S2 continúa descendiendo prácticamente
igual que en la Parte 1 (hacia y_n2≈1.086 m) durante casi todo el tramo; sólo
en los últimos ≈13 m antes del Lago B se produce el **resalto hidráulico**,
saltando de y≈1.089 m a y≈2.130 m, y a partir de ahí una breve curva S1
(remanso) que sube suavemente desde 2.130 m hasta el nivel del Lago B, 2.30
m, en x=600 m.

Gráfico: `scripts/ej1_perfil_parte2.png`.

**Resultado final Parte 2: Q = 10.22 m³/s (sin cambios respecto a la Parte
1). Tramo 1: idéntico a la Parte 1 (curva S2, sin resalto). Tramo 2: curva
S2 (igual que Parte 1) hasta x≈586.7 m (medido desde el Lago A), luego
**resalto hidráulico** de y=1.09 m a y=2.13 m, seguido de una curva S1
(remanso) hasta y=2.30 m en el Lago B.**

**Comparación con la solución oficial:** el manuscrito ubica la rama
subcrítica S1 "se agota a 41 m del Lago B" — **coincide exactamente** con los
41.17 m calculados—, y el resalto (por conjugación de la rama S2) en
x=286.75 m con y=2.13 m dentro del tramo 2 — **coincide casi exactamente**
con los x=286.72 m, y=2.13 m calculados. Todos los valores numéricos de esta
parte coinciden con la solución oficial dentro de un margen de precisión
numérica.

### Resumen Ejercicio 1

| Ítem | Parte 1 (h_LB=−0.50 m) | Parte 2 (h_LB=2.3 m) |
|---|---|---|
| Caudal Q | **10.22 m³/s** | **10.22 m³/s** (sin cambio) |
| Tramo 1 | tipo S, y_c1=1.357 m, y_n1=0.911 m, curva S2 | idéntico a Parte 1 |
| Tramo 2 | tipo S, y_c2=1.560 m, y_n2=1.086 m, curva S2 hasta el final | S2 hasta x≈586.7 m, luego **resalto** (1.09→2.13 m), luego S1 hasta 2.30 m |
| Resalto hidráulico | **no hay** (descarga libre) | **sí**, en x≈286.7 m del tramo 2 (≈13 m antes del Lago B) |
