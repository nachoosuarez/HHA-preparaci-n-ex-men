# Examen HHA — Julio 2024

Resolución paso a paso. El PDF del examen (`EXAMENES/2024 Julio.pdf`) incluye,
además de la letra (páginas 1-3), la solución oficial manuscrita (páginas
4-8, con las cartas topográficas en las páginas 5 y 9), que se usa para
comparar cada resultado.

Herramientas: Octave (scripts de `Scripts/01_SCRIPTS/Scripts examen AA/Sección
rectangular` y `TO2_Octave`, copiados y adaptados en `scripts/`) para el
Ejercicio 1 (canal rectangular); método Racional / NRCS y estadística de
eventos extremos para los Ejercicios 2 y 3; bombas (Colebrook-White, curva de
instalación) para el Ejercicio 4.

---

## EJERCICIO 1 — Canal rectangular infinito con compuerta de fondo y escalón

**Datos:** canal rectangular infinito, ancho b=10 m, S₀=0.001, n=0.015 (constante
en todo el canal). En una sección (x=0) hay una compuerta de fondo ideal con
apertura a=0.8 m y descarga libre. 200 m aguas abajo (x=200 m) el fondo se
eleva suavemente Δz=0.5 m (sin pérdidas de carga) y continúa indefinidamente
aguas abajo con la misma pendiente. Q=70 m³/s.

**Teoría usada:** tirante crítico y energía específica (Teórico HHA §2.2),
ecuación diferencial del flujo gradualmente variado dy/dx=(S₀−S_f)/(1−Fr²) y
clasificación de canales M (y_n>y_c) (§2.5.1–§2.5.2), clasificación de
perfiles M1/M2/M3 (§2.5.3), compuerta de fondo con descarga libre —tratada
como "compuerta ideal": sin pérdidas de energía y sin coeficiente de
contracción, por lo que el tirante en la vena contraída es igual a la
apertura de la compuerta (y=a)— y transición suave de fondo con energía
específica conservada (§2.5.4), cantidad de movimiento y tirantes conjugados
para el resalto hidráulico (§2.3.3 "Resalto hidráulico"), y **función de
cantidad de movimiento (momentum) M(y)=b·y²/2+Q²/(g·b·y)** para calcular la
fuerza que el agua ejerce sobre un obstáculo (compuerta, escalón, o cualquier
control) entre dos secciones (§2.3.1–§2.3.3): F=γ·[M(y_aguas arriba)−M(y_aguas
abajo)], con signo positivo en el sentido del escurrimiento.

**Herramienta:** scripts de Octave de `Sección rectangular`/`TO2_Octave`
(`rect_geom.m`, `Eesp_rect.m`, `Mom_rect.m`, `froude_rect.m`, `critico_rect.m`,
`manning_rect.m`, `rect.m`, `critico.m`), copiados a `scripts/` e integrados
con `ode23` para las curvas de FGV, igual esquema que el Ejercicio 1 de
`resueltos/2024 diciembre` pero para sección rectangular en vez de
trapezoidal. Se usó además Python (`scipy.integrate.solve_ivp` +
`scipy.optimize.brentq`) como verificación independiente antes de correr el
script de Octave definitivo; ambos coinciden.

**Script:** `scripts/ej1_completo.m`. Entradas: `b=10, n=0.015, S0=0.001,
Q=70, a=0.8, dz=0.5, Lgate_step=200`.

### 1) Clasificación del canal (M o S)

```
yc = (q^2/g)^(1/3) = 1.710 m     (q=Q/b=7 m2/s)
yn: Manning, 70 = (1/n)*A*R^(2/3)*S0^0.5  =>  yn = 2.404 m
```
Como y_n=2.404 m > y_c=1.710 m ⇒ **canal tipo M (pendiente suave)**.

**Comparación con la solución oficial:** el manuscrito da y_c=1.71 m,
y_n=2.4 m, "CANAL M" — **coincide exactamente**.

### 2) Perfil de la superficie libre completo

**a) Aguas arriba de la compuerta (remanso M1).** La compuerta de fondo
restringe el paso del agua, por lo que aguas arriba se forma un remanso
(curva M1, y>y_n) que decae muy lentamente porque S₀ es pequeña (a 150 m de
la compuerta el tirante todavía es ≈4.42 m; hacen falta más de 1500 m para
acercarse a y_n). Como la compuerta es ideal (sin pérdidas), la energía
específica se conserva entre la sección aguas arriba y la vena contraída:

```
E(y) = y + q^2/(2g y^2)
E(vena contraida, y=a=0.8) = 4.702 m
y1 (aguas arriba, raiz subcritica de E(y1)=4.702)  =>  y1 = 4.587 m
```

**b) Aguas abajo de la compuerta (curva M3).** En la vena contraída y=a=0.8 m
< y_c=1.710 m ⇒ régimen **supercrítico**, zona 3 ⇒ curva **M3** (creciente
hacia aguas abajo, tendiendo asintóticamente a y_c). Se integra la ecuación de
FGV (`rect.m`) con `ode23` desde x=0⁺ (y=0.8 m) hacia aguas abajo.

**c) Resalto hidráulico.** Como el canal es tipo M (flujo normal subcrítico),
la rama supercrítica M3 no puede llegar hasta y_c: en algún punto se produce
un **resalto hidráulico** que la conecta con una rama subcrítica. Esa rama
subcrítica queda fijada, aguas abajo, por la condición en el escalón (ver
punto d); se integra hacia aguas arriba desde x=200 m. La posición del
resalto es el punto x donde el **tirante conjugado** (`Mom_rect.m`, cantidad
de movimiento) de la rama M3 coincide con el tirante de la rama subcrítica:

```
RESALTO en x = 24.4 m (aguas abajo de la compuerta):
  y1 (antes, supercritico) = 0.876 m
  y2 (despues, subcritico) = 2.969 m
```

**d) Escalón (x=200 m).** El enunciado indica que el cambio de fondo es
suave y sin pérdidas de carga, por lo que se conserva la energía específica
entre las secciones justo antes y justo después del escalón. Aguas abajo del
escalón el canal continúa indefinidamente con la misma pendiente, así que el
tirante ahí es (prácticamente) el normal, y_n=2.404 m:

```
E(despues del escalon, y=yn=2.404) = Em(yn) = 2.836 m
E(antes del escalon) = Dz + Em(yn) = 0.5 + 2.836 = 3.336 m
y (antes del escalon, raiz subcritica) = 3.071 m
```
Entre el resalto (x=24.4 m, y=2.969 m) y el escalón (x=200 m, y=3.071 m) el
tirante sube muy suavemente (curva M1 corta, casi uniforme, coherente con que
ambos valores están cerca de y_n).

**Resultado final: perfil completo (Q=70 m³/s, canal tipo M):**
y=4.587 m aguas arriba de la compuerta (remanso M1, decae muy lentamente) →
**compuerta** → y=0.8 m (vena contraída) → curva **M3** creciente → **resalto
hidráulico en x≈24.4 m** (0.876 m → 2.969 m) → curva M1 suave hasta y=3.071 m
justo antes del **escalón** (x=200 m) → **escalón** (Δz=0.5 m, sin pérdidas)
→ y=y_n=2.404 m (flujo prácticamente normal, continúa indefinidamente).

Gráfico: `scripts/ej1_perfil.png`.

**Comparación con la solución oficial:** el manuscrito da y=4.58 m aguas
arriba de la compuerta (vs. 4.587 m, coincide), el resalto hidráulico en
x≈25 m con tirantes ≈0.8 m→2.96 m (vs. x=24.4 m, 0.876 m→2.969 m — coincide
dentro de un margen de lectura manual de la gráfica), y y=3.07 m antes del
escalón con y_n=2.4 m después (coincide exactamente). Se usa el mismo
esquema conceptual (E₁=Δz+E₂, con y_2=y_n aguas abajo del escalón).

### 3) Fuerza ejercida por el agua sobre la compuerta y sobre el escalón

**Concepto.** En ambos casos se aplica cantidad de movimiento entre una
sección aguas arriba y una aguas abajo de la estructura, usando la función de
cantidad de movimiento (momentum) M(y)=b·y²/2+Q²/(g·b·y) (§2.3.1–§2.3.3,
`Mom_rect.m`): F=γ·[M(y_aguas arriba)−M(y_aguas abajo)] es la fuerza que la
estructura (compuerta o escalón) ejerce sobre el agua para producir el
cambio de cantidad de movimiento entre ambas secciones (con la hidrostática
más el flujo de cantidad de movimiento incluidos en M); por reacción, el agua
ejerce sobre la estructura una fuerza de igual magnitud en sentido del
escurrimiento.

**a) Compuerta:** entre y1=4.587 m (aguas arriba) y y2=a=0.8 m (vena
contraída, aguas abajo):
```
M(4.587) = 115.99 m3 ; M(0.8) = 65.64 m3
F_compuerta = gamma*(M1-M2) = 9800*(115.99-65.64) = 4.94e5 N
```

**b) Escalón:** entre y1=3.071 m (antes) y y2=y_n=2.404 m (después):
```
M(3.071) = 63.44 m3 ; M(2.404) = 49.62 m3
F_escalon = gamma*(M1-M2) = 9800*(63.44-49.62) = 1.35e5 N
```

**Resultado final: Fuerza sobre la compuerta ≈ 4.94×10⁵ N (494 kN). Fuerza
sobre el escalón ≈ 1.35×10⁵ N (135 kN). Ambas en el sentido del
escurrimiento.**

**Comparación con la solución oficial:** el manuscrito da F_compuerta=γ·(115.8−65.7)
≈4.9×10⁵ N — **coincide casi exactamente**. Para el escalón el manuscrito usa
el mismo método (M≈63.4 antes, M≈48.7–50.7 después, según la lectura de la
manuscrita, que es difícil de leer con precisión) y llega a un resultado del
mismo orden, ≈1.3-1.4×10⁵ N — **coincide** con los 1.35×10⁵ N calculados
dentro de ese margen.

### Resumen Ejercicio 1

| Ítem | Resultado |
|---|---|
| Clasificación del canal | **Tipo M** (y_c=1.710 m, y_n=2.404 m) |
| Tirante aguas arriba de la compuerta | **4.587 m** (remanso M1) |
| Tirante aguas abajo de la compuerta (vena contraída) | **0.800 m** (=a, curva M3) |
| Resalto hidráulico | **en x≈24.4 m** aguas abajo de la compuerta: 0.876 m → 2.969 m |
| Tirante antes / después del escalón (x=200 m) | **3.071 m → 2.404 m (=y_n)** |
| Fuerza sobre la compuerta | **≈4.94×10⁵ N (494 kN)** |
| Fuerza sobre el escalón | **≈1.35×10⁵ N (135 kN)** |

---
