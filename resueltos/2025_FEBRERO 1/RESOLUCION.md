# Examen HHA — 27 de febrero de 2025

Resolución paso a paso. El PDF del examen (`EXAMENES/2025_FEBRERO 1.pdf`)
incluye, además de la letra (páginas 1-4), la solución oficial manuscrita
(páginas 5-10), que se usa para comparar cada resultado.

Herramientas: Octave (scripts de `Scripts/01_SCRIPTS/FGV_felo`, copiados y
adaptados en `scripts/`) para el Ejercicio 1.

Los scripts deben ejecutarse en orden (`ej1_parte1.m` genera `part1.mat`, que
usan `ej1_parte2.m` y `ej1_parte3.m`; `ej1_parte2.m` genera `part2.mat`, que
usa `ej1_parte3.m`). Los archivos `.mat` intermedios no se versionan.

---

## EJERCICIO 1 — Canal trapezoidal entre el Lago A y el Lago B, con restricción de tensión rasante

**Datos:** sección trapezoidal, b=2.2 m, m=1 (talud 1V:1H), n=0.013, S₀=0.01,
L=60 m. Nivel del Lago A sobre el fondo: h_LA=2.0 m. El canal termina en otro
lago (Lago B).

Teoría usada: perfiles de flujo entre dos lagos (Teórico HHA §2.5.4, en
particular el caso de canal tipo S), clasificación M/S de canales (§2.5.2),
energía específica y tirante crítico (§2.2), tensión rasante de fondo /
pendiente de energía (§2.1, §2.3), cantidad de movimiento y tirante conjugado
para el resalto hidráulico (§2.3.2–2.3.3).

### Parte 1) Caudal de descarga (h_LB=0.40 m), clasificación M/S y perfil

**Concepto.** El canal conecta dos lagos (Teórico §2.5.4). A priori no se sabe
si el flujo será tipo M o S: la guía del teórico indica que para n del orden
de 0.01 y S₀ del orden de 1 % (como en este caso, S₀=0.01) es razonable
suponer canal **tipo S**, hipótesis que se verifica después de calcular el
caudal. Para un canal S alimentado por un lago, el lago 1 (Lago A) descarga
con el **máximo caudal compatible con su energía**, estableciéndose flujo
**crítico en la sección inicial** del canal (x=0): esto ocurre porque el
tirante crítico es el que lleva el caudal máximo para una energía específica
dada. El sistema a resolver es:

```
Fr² = Q²·B(y₁)/(g·A(y₁)³) = 1        (flujo crítico en x=0, y₁=y_c)
h_LA = y₁ + Q²/(2g·A(y₁)²)            (conservación de energía Lago A → x=0)
```

**Herramienta:** sistema de 2 ecuaciones y 2 incógnitas (Q, y₁) resuelto con
`fsolve` en Octave (`trap_geom.m` para la geometría trapezoidal), más
`eq_yn.m`/`eq_yc.m` para verificar y_n e y_c una vez conocido Q. Se usa este
enfoque —en vez de `caudal_M_ini.m`— porque ese script asume canal tipo M con
tirante de entrada ≈ y_n (lago alimentando un canal largo tipo M); acá, al
verificarse canal tipo S, el control físico es muy distinto (crítico en la
entrada, no normal), por lo que se plantea el sistema específico del caso S
del Teórico §2.5.4.

**Script:** `scripts/ej1_parte1.m`. Entradas: `b=2.2, m=1, n=0.013, S0=0.01,
hLA=2.0, hLB=0.40, L=60`.

**Resultado:**
```
Q  = 17.3883 m3/s
yc = 1.4740 m
yn = 0.9748 m
```
Como y_n (0.975 m) < y_c (1.474 m) ⇒ **el canal es de tipo S (pendiente
fuerte)**, confirmando la hipótesis inicial.

**Perfil de flujo:** con y₁=y_c=1.474 m en x=0, se integró la ecuación de FGV
(`rect.m`, que usa `trap_geom.m` y por lo tanto sirve para sección
trapezoidal) con `ode23` hacia aguas abajo. Resulta una **curva S2**
(supercrítica, y_n<y<y_c, decreciente) que en x=60 m llega a y=1.088 m, sin
alcanzar aún el tirante normal (el canal es corto respecto al desarrollo
asintótico de la curva).

Como h_LB=0.40 m < y_n=0.975 m < y(x=60m)=1.088 m, el nivel del Lago B queda
por debajo de todo el rango de tirantes que trae la curva S2: el Lago B **no
afecta la descarga del Lago A** (Teórico §2.5.4, caso "y_c>y_n>y_L2"), y el
canal **descarga en caída libre** al Lago B (como una pequeña cascada de
≈0.69 m de altura, y(60)−h_LB). Todo el escurrimiento es **supercrítico**
(Fr>1 en todo el tramo, ya que 0.975<y<1.474<y_c en todo x) ⇒ **no hay
resaltos hidráulicos** en este perfil.

**Perfil de la superficie libre (x medido desde el Lago A):**
- x=0: y=y_c=1.474 m (control crítico a la salida del Lago A).
- x=0 a x=60 m: curva S2, tirante decreciendo suavemente de 1.474 m a 1.088 m
  (supercrítico en todo el tramo).
- x=60 m: caída libre al Lago B (nivel 0.40 m).

Gráfico: `scripts/ej1_perfil.png`.

**Resultado final Parte 1: Q = 17.39 m³/s, y_c = 1.474 m, y_n = 0.975 m, canal
tipo S, curva S2 en todo el canal, sin resaltos, descarga en caída libre al
Lago B.**

**Comparación con solución oficial:** el manuscrito da Q=17,39 m³/s,
y_c=1,474 m, y_n=0,975 m, canal S, curva S2, y(x=60m)=1,09 m — **coincide
exactamente**.

### Parte 2) Zonas donde la tensión rasante supera τ_max=42 Pa

**Concepto.** La tensión rasante de fondo en flujo gradualmente variado es
τ₀=γ·R·S_f, con S_f=(Q·n/(A·R^(2/3)))² la pendiente de energía (Teórico
§2.1/§2.3). Para un Q fijo, τ₀ es una función decreciente del tirante y: a
menor tirante, mayor velocidad y mayor pendiente de energía, y por lo tanto
mayor tensión de corte. Como la curva S2 de la Parte 1 tiene su tirante
mínimo (1.088 m) en el extremo aguas abajo (x=60 m, cerca del Lago B), es ahí
donde la tensión rasante será máxima.

**Herramienta:** se evaluó τ₀(y) analíticamente (misma fórmula que
`Scripts/01_SCRIPTS/Scripts examen AA/FGV_felo/rasante_max.m`, que además
está pre-cargada con los datos de este mismo ejercicio —Q=17.39, b=2.2, n=0.013,
m=1, τ_max=42— lo que confirma que es la herramienta pensada para este
problema) sobre el perfil y(x) obtenido en la Parte 1.

**Script:** `scripts/ej1_parte2.m`.

**Resultado:**
```
tau(x=0, y=yc)   = 18.02 Pa
tau(x=60, y=1.088m) = 44.55 Pa
y para el cual tau = 42 Pa: y = 1.1102 m
tau supera 42 Pa desde x = 48.34 m hasta x = 60 m
```

**Resultado final Parte 2: la tensión rasante supera 42 Pa en los últimos
≈11.7 m del canal (x≈48.3 a 60 m), es decir la zona inmediatamente anterior a
la descarga en el Lago B, donde el tirante es menor y la velocidad mayor.**

**Comparación con solución oficial:** el manuscrito da "a partir de los 49 m
→ últimos 11 m" — **coincide muy bien** con el cálculo (48.3 m, últimos
11.7 m); la pequeña diferencia (~0.7 m) es consistente con redondeo en la
lectura gráfica manual del perfil.

### Parte 3) Nivel del Lago B para que no se supere τ_max en la zona de la Parte 2

**Concepto.** El caudal Q sigue estando fijado por el control crítico en la
entrada (x=0), independiente del nivel del Lago B, mientras el resalto
hidráulico no llegue a afectar la sección 1 (Teórico §2.5.4). Si h_LB se eleva
lo suficiente, se forma una curva **S1** (subcrítica, y>y_c) que remonta desde
el Lago B, y un **resalto hidráulico** conecta la curva S2 (que llega desde el
Lago A) con la curva S1. Aguas abajo del resalto el tirante es subcrítico
(y>y_c=1.474 m), y como ya en y=y_c la tensión es sólo 18 Pa (bien por debajo
de 42 Pa), **toda la zona cubierta por la curva S1 queda automáticamente a
salvo**. Por lo tanto, el h_LB mínimo buscado es el que ubica el resalto
exactamente en el borde de la zona peligrosa hallada en la Parte 2 (x=48.34 m):
para cualquier h_LB mayor, el resalto se da más aguas arriba y toda la zona
x∈[48.34, 60] m queda cubierta por la curva S1 seguirá (segura); para h_LB
menor, parte de esa zona seguiría en la curva S2 (insegura).

**Herramienta:** se calculó, para cada punto de la curva S2 (Parte 1), su
**tirante conjugado** (rama subcrítica) con `Mom_trap.m` (cantidad de
movimiento y conjugado para sección trapezoidal). Luego, para un h_LB de
prueba, se integró la curva S1 desde x=60 m (y=h_LB) hacia aguas arriba con la
misma ecuación de FGV, y se ubicó el resalto donde la curva S1 cruza al
conjugado de la curva S2 (igualdad de cantidad de movimiento a ambos lados del
resalto). Se usó `fzero` para encontrar el h_LB tal que el resalto caiga en
x=48.34 m. Se eligieron estas funciones porque son las que provee el curso
específicamente para el cálculo de conjugados y ubicación de resaltos en
sección trapezoidal (mismo procedimiento que en el Ejercicio 1 del examen de
2026 Febrero ya resuelto en este repositorio).

**Script:** `scripts/ej1_parte3.m`.

**Resultado:**
```
yL2sup (resalto justo en x=60m, límite descarga libre) = 1.9267 m
hLB minimo requerido = 2.0599 m
Verificación: con hLB=2.06 m el resalto se ubica en x=48.34 m (coincide con el
límite de la zona peligrosa de la Parte 2)
```

Con h_LB=2.06 m el perfil queda: curva S2 desde x=0 (y_c=1.474 m) hasta
x=48.34 m (y≈1.110 m, justo el límite τ=42 Pa), **resalto hidráulico** de
y≈1.110 m a y≈1.899 m (conjugado), y luego curva **S1** subcrítica desde
x=48.34 m hasta x=60 m, terminando en y=2.06 m (nivel del Lago B). Gráfico:
`scripts/ej1_perfil_parte3.png`.

**Resultado final Parte 3: el nivel mínimo del Lago B para que no se supere
τ_max=42 Pa en la zona identificada en la Parte 2 es h_LB ≈ 2.06 m** (para
cualquier valor mayor, el resalto se ubica más aguas arriba y toda la zona
peligrosa original queda cubierta por flujo subcrítico, seguro).

**Comparación con solución oficial:** el manuscrito da h_LB=2,06 m con resalto
en x=48,5 m — **coincide casi exactamente** con el cálculo (2.0599 m, resalto
en x=48.34 m).

### Resumen Ejercicio 1

| Ítem | Resultado |
|---|---|
| Q (h_LB=0.40 m) | **17.39 m³/s** |
| y_c | **1.474 m** |
| y_n | **0.975 m** |
| Tipo de canal | **S (pendiente fuerte)** |
| Resaltos (Parte 1) | **Ninguno; descarga en caída libre** |
| Zona con τ>42 Pa | **x≈48.3 a 60 m (últimos ≈11.7 m)** |
| h_LB mínimo para evitar τ>42 Pa en esa zona | **≈2.06 m** |

Los tres resultados numéricos coinciden con la solución oficial manuscrita
dentro del margen esperable de redondeo/lectura gráfica manual.

---
