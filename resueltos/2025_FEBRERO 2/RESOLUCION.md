# Examen HHA — 5 de febrero de 2025 (2025_FEBRERO 2)

Resolución paso a paso. El PDF del examen (`EXAMENES/2025_FEBRERO 2.pdf`)
incluye, además de la letra (páginas 1-3) y la carta topográfica del
Ejercicio 3 (página 4), la solución oficial manuscrita completa
(páginas 5-10), que se usa para comparar cada resultado.

Herramientas: Octave (scripts de `Scripts/01_SCRIPTS/FGV_felo`, copiados y
adaptados en `scripts/`) para el Ejercicio 1 (flujo gradualmente variado en
canal trapezoidal).

Los scripts de Octave del Ejercicio 1 deben ejecutarse en orden
(`ej1_parte1.m` genera `part1.mat`, usado por `ej1_parte2.m` y
`ej1_parte3.m`; `ej1_parte2.m` genera `part2.mat`, usado por
`ej1_parte3.m`). Los archivos `.mat` intermedios no se versionan.

---

## EJERCICIO 1 — Canal trapezoidal infinito con caída libre y transición de fondo (escalón)

**Datos:** sección trapezoidal, b=5 m, talud m=2 (1V:2H), n=0.017 (Manning),
S₀=0.001, Q=15 m³/s. El canal (considerado infinito aguas arriba) termina en
una caída libre.

Teoría usada: clasificación M/S de canales según y_c vs y_n (Teórico HHA
§2.5.1–2.5.2), condición de control en caída libre (y≈1.01·y_c, Teórico
§2.5.3), perfiles de flujo gradualmente variado (curvas M1/M2/M3, Teórico
§2.5.2), energía específica y transiciones de fondo suave —escalón—
(Teórico §2.2, caso de elevación local del fondo que puede ahogar/no ahogar
la sección), cantidad de movimiento y tirante conjugado para el resalto
hidráulico (Teórico §2.3.2–2.3.3).

### Parte 1) Clasificación M/S y perfil de la superficie libre

**Concepto.** El tipo de canal (M o S) se determina comparando el tirante
normal y_n (Manning, con S₀ y Q dados) con el tirante crítico y_c (Fr=1, con
Q dado), independientemente de la condición de borde. La caída libre al
final del canal impone un control aguas abajo: el tirante pasa por el
crítico muy cerca del borde (en la práctica y≈1.01·y_c, porque exactamente
en y_c la pendiente de la superficie libre es infinita para la ecuación de
FGV). A partir de ese control se integra la curva de FGV hacia aguas
arriba.

**Herramienta:** `eq_yc.m`/`eq_yn.m` con `fsolve` para y_c e y_n (geometría
trapezoidal en `trap_geom.m`), e integración de la ecuación de FGV
(`rect.m`, válida para trapezoidal porque usa `trap_geom.m`) con `ode23`
desde la caída libre hacia aguas arriba. Se usan estas funciones —en vez de
`caudal_M_ini.m`/`caudal_S_ini.m`— porque acá Q ya es dato (no hay que
inferirlo de un lago aguas arriba): sólo hace falta clasificar el canal e
integrar el perfil.

**Script:** `scripts/ej1_parte1.m`. Entradas: `Q=15, b=5, m=2, n=0.017,
S0=0.001`.

**Resultado:**
```
yc = 0.8610 m
yn = 1.2044 m
```
Como y_c (0.861 m) < y_n (1.204 m) ⇒ **el canal es de tipo M (pendiente
suave)**.

**Perfil de flujo:** con y(x=0)=1.01·y_c=0.870 m en la caída libre (x=0,
origen en la caída, x negativo hacia aguas arriba), se integró la ecuación
de FGV hacia aguas arriba. Resulta una curva **M2** (subcrítica, y_c<y<y_n,
creciendo hacia aguas arriba) que se aproxima asintóticamente a y_n a medida
que x se aleja de la caída (a x=−700 m, y=1.199 m, ya muy cerca de
y_n=1.204 m). Todo el tramo es subcrítico, por lo que **no hay resaltos
hidráulicos** en esta configuración.

**Perfil de la superficie libre (x medido desde la caída libre, negativo
hacia aguas arriba):**
- x→−∞ (aguas arriba, canal "infinito"): y→y_n=1.204 m.
- x=−300 m: y=1.1705 m.
- x=0 (caída libre): y=1.01·y_c=0.870 m.

Gráfico: `scripts/ej1_perfil_parte1.png`.

**Resultado final Parte 1: canal tipo M (y_c=0.861 m < y_n=1.204 m), curva
M2 en todo el canal, sin resaltos, tirante tendiendo a y_n aguas arriba y
cayendo hasta ≈1.01·y_c justo antes de la caída libre.**

**Comparación con solución oficial:** el manuscrito da y_c=0,86 m,
y_n=1,20 m, canal M, condición aa caída libre M2 con y_ini=1,01·y_c —
**coincide exactamente**.

### Parte 2) Altura máxima de la tubería (escalón a 300 m de la caída) que no altera el tirante aguas arriba

**Concepto.** A L=300 m antes de la caída se instala una tubería que actúa
como un escalón de fondo (elevación local D del lecho, de longitud
despreciable, sin pérdidas). Para una transición de fondo suave, se conserva
la energía entre la sección aguas arriba (1) y la cresta del escalón (2):
E₁=E₂+D. Si D es pequeño, el tirante y₁ aguas arriba no cambia (el flujo
"pasa por arriba" del escalón sin verse forzado). El D máximo que **no**
altera y₁ es aquel para el cual, justo en la cresta, la energía específica
disponible sea la mínima compatible con el caudal (E₂=E_c, es decir, el
flujo se pone crítico exactamente en la cresta): para D mayor que ese
Dmax, la sección ya no puede pasar el caudal con E₂=E_c y el escalón se
"ahoga", obligando a subir y₁ aguas arriba (remanso).

**Herramienta:** cálculo directo de energía específica en la sección 1 (con
y₁ tomado del perfil M2 de la Parte 1 en x=−300 m, sin alterar) y de la
energía crítica E_c=y_c+U_c²/(2g) (mismas funciones `trap_geom.m`, sin
necesidad de `Eesp_trap.m` porque no hace falta el tirante alterno en esta
parte). Se eligió este camino —evaluar E1 y Ec directamente— porque es
exactamente el razonamiento de energía específica mínima del Teórico §2.2
aplicado a un escalón, y es el mismo enfoque de la solución oficial.

**Script:** `scripts/ej1_parte2.m`.

**Resultado:**
```
y1 (x=-300m, sin alterar) = 1.1705 m
E1 = 1.3260 m
Ec = 1.2037 m
Dmax = E1 - Ec = 0.1223 m
```

**Resultado final Parte 2: la altura máxima de la tubería para no alterar el
tirante aguas arriba es Dmax ≈ 0.12 m.**

**Comparación con solución oficial:** el manuscrito da y₁(x=−300m)=1,17 m,
E₁=1,325 m, E_c=1,204 m, Dmax=0,12 m — **coincide exactamente**.

### Parte 3) Tubería de altura A=0.35 m: perfil completo con remanso y resalto

**Concepto.** Como A=0.35 m > Dmax=0.12 m (Parte 2), el escalón "ahoga" la
sección: para poder pasar el caudal por la cresta se necesita más energía
específica aguas arriba, y aparece **remanso** (el tirante y₁ sube por
encima del valor sin alterar). En la cresta el flujo pasa por crítico
(E₂=E_c), luego E₁=E_c+A (conservación de energía en el escalón, subiendo).
Con esa nueva E₁ hay dos tirantes posibles con la misma energía específica
(alternos): el subcrítico (y₁, aguas arriba de la tubería, sobre una curva
**M1** de remanso) y el supercrítico (y₃, alterno de y₁, que es el tirante
inmediatamente aguas abajo de la tubería una vez que el fondo vuelve a su
nivel original —el escalón es de longitud despreciable, con subida y
bajada en el mismo punto—, ya que ahí también se conserva la energía
específica: E₃=E₂+A=E₁, misma cota de fondo que en la sección 1). Aguas
abajo de la tubería el flujo es supercrítico y sigue una curva **M3** que
crece hacia aguas abajo; como el resto del canal (aguas abajo) debe
empalmar con el perfil M2 sin alterar de la Parte 1 (que llega intacto
hasta la caída libre, ya que esta permanece fija como control aguas abajo),
en algún punto entre la tubería y la caída se produce un **resalto
hidráulico** que conecta la curva M3 con la curva M2 original.

**Herramienta:** tirantes alternos con `alternos_trap.m` (calcula y₁ y su
alterno y₃ para una energía específica dada, sección trapezoidal);
integración de la curva M3 con `rect.m`/`ode23` desde x=−300 m (y=y₃) hacia
aguas abajo; conjugado de cada punto de la curva M3 con `Mom_trap.m`
(cantidad de movimiento); ubicación del resalto por intersección entre el
conjugado de M3 y la curva M2 de la Parte 1 (mismo procedimiento que
`encontrar_resalto.m`, adaptado para comparar contra el perfil M2 ya
calculado en vez de una segunda curva analítica). Se eligieron estas
funciones porque son las provistas por el curso específicamente para
tirantes alternos y conjugados en sección trapezoidal, y el procedimiento
de ubicar el resalto por intersección de conjugados es el mismo usado en el
Ejercicio 1 del examen 2025_FEBRERO 1 ya resuelto en este repositorio.

**Script:** `scripts/ej1_parte3.m`.

**Resultado:**
```
E1_new = Ec + A = 1.5537 m
y1_new (subcritico, aguas arriba tuberia)            = 1.4693 m
y3_new (supercritico, alterno = aguas abajo tuberia) = 0.5549 m

Como A=0.35m > Dmax=0.1223m => y1_new > y1 sin alterar => HAY REMANSO

Curva M3: desde x=-300m (y=0.5549 m) hasta x=-257.03m (y=0.8610 m = yc,
   límite superior de la rama supercrítica)

RESALTO HIDRAULICO:
  x_resalto = -289.27 m (medido desde la caida libre)
  Distancia desde la tuberia (x=-300m) hasta el resalto = 10.73 m
  y antes del resalto (rama M3)                = 0.6067 m
  y despues del resalto (conjugado, sobre M2)  = 1.1682 m
```

**Perfil completo de la superficie libre (x medido desde la caída libre):**
- x→−∞: y→y_n=1.204 m (curva M1 aún no perturbada, muy lejos de la
  tubería).
- x=−300 m⁻ (justo aguas arriba de la tubería): y₁=1.469 m (remanso, curva
  M1).
- x=−300 m (cresta de la tubería): y=y_c=0.861 m (paso por crítico).
- x=−300 m⁺ (justo aguas abajo de la tubería): y₃=0.555 m (curva M3,
  supercrítica).
- x=−300 a −289.3 m: curva M3 creciendo de 0.555 m a 0.607 m.
- x≈−289.3 m: **resalto hidráulico**, de y=0.607 m a y=1.168 m.
- x=−289.3 a 0 m: curva M2 (idéntica a la de la Parte 1, sin alterar),
  decreciendo de 1.168 m hasta y=1.01·y_c=0.870 m en la caída libre.

Gráfico: `scripts/ej1_perfil_parte3.png`.

**Resultado final Parte 3: con la tubería de A=0.35 m se forma un remanso
aguas arriba (y₁≈1.47 m en x=−300 m), el flujo pasa por crítico en la
cresta y se acelera a supercrítico (y₃≈0.55 m) aguas abajo de la tubería;
tras recorrer sólo ≈10.7 m sobre la curva M3 se produce un resalto
hidráulico (de y≈0.61 m a y≈1.17 m), y de ahí en más el perfil vuelve a
coincidir con la curva M2 original de la Parte 1 hasta la caída libre.**

**Comparación con solución oficial:** el manuscrito da E₁=1,55 m,
y₁=1,47 m, y₃=y₁_alt=0,55 m, "M3 se agota en 43 m" (desde la cresta hasta
y_c, 300−257=43 m, coincide con el cálculo), x_resalto=11 m desde la
tubería (cálculo: 10.73 m) e y_resalto=1,17 m — **coincide muy
estrechamente** con el cálculo (diferencias <3% atribuibles a redondeo
gráfico manual).

### Resumen Ejercicio 1

| Ítem | Resultado |
|---|---|
| y_c | **0.861 m** |
| y_n | **1.204 m** |
| Clasificación | **Canal tipo M** |
| Perfil sin tubería | **M2, sin resaltos, y→y_n aguas arriba, y≈1.01·y_c en la caída** |
| Dmax (tubería sin alterar y₁) | **0.122 m** |
| Con A=0.35 m | **Remanso: y₁=1.47 m; y₃=0.55 m; resalto a 10.7 m de la tubería (y: 0.61→1.17 m); luego M2 original hasta la caída** |

ESTADO: EN CURSO (falta Ejercicio 2, Ejercicio 3 y Ejercicio 4)
