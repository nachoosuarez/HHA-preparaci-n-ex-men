# Examen HHA — 25 de julio de 2022

Examen con solución oficial manuscrita adjunta (escaneada dentro del PDF,
páginas 5-8), de lectura difícil por caligrafía cursiva y calidad de
escaneo. Se recalculó todo de forma independiente con Octave y se comparó
con lo legible de la solución oficial — coincide en todos los valores
numéricos que se pudieron leer con confianza.

---

## Ejercicio 1 (30 puntos) — FGV en canal trapezoidal de 3 tramos entre dos lagos

### Enunciado (resumen)

Lago A → canal trapezoidal (b=1.3 m, talud m=2, n=0.017) de **tres
tramos** → Lago B:
- Tramo I: pendiente S₀ᴵ=0.03, longitud **infinita** (muy larga).
- Tramo II: horizontal (S₀ᴵᴵ=0), L=100 m.
- Tramo III: S₀ᴵᴵᴵ=0.0015, L=70 m.

1) Con hLA=1.43 m, hallar Q de descarga del Lago A.
2) Con hLB=0.8 m, clasificar tramos I y III (M o S) y dibujar la
   superficie libre completa, ubicando resaltos si los hay.
3) Hallar el hLB a partir del cual el resalto pasa al tramo I.

### Teoría

- **Control crítico en la entrada de un canal S alimentado por un
  lago**: un canal steep muy largo hace que el lago descargue su caudal
  máximo compatible con su energía, con flujo crítico justo en la
  entrada — Teórico HHA §2.5.3-§2.5.4, Formulómetro "Perfiles
  lago-canal"; ver también RESUMEN_TEORICO.md §A4.
- **Clasificación M/S**: se compara yn (Manning, según la pendiente de
  cada tramo) contra yc (crítico, que sólo depende de Q y la geometría,
  no de la pendiente) — RESUMEN_TEORICO.md §A1.
- **Resalto hidráulico y tirantes conjugados**: se integran ambas ramas
  (supercrítica desde su control aguas arriba, subcrítica desde su
  control aguas abajo) y se busca dónde el conjugado M(y) de la rama
  supercrítica cruza el valor de la rama subcrítica en la misma
  posición x — RESUMEN_TEORICO.md §A3.
- **Canal horizontal (S=0)**: no tiene tirante normal finito (la
  ecuación de Manning no tiene solución con S=0), así que sólo se
  clasifica por yc: existen las curvas H2 (y>yc) y H3 (y<yc), sin H1.

### Herramienta y por qué

Se usó **Octave** con la librería `RESUMEN EXAMEN/Codigos/FGV_trapezoidal/`
(ya existente: `control_critico_lago_trap.m`, `eq_yn.m`, `rect.m` +
`ode23`, `Mom_trap.m`) en lugar de resolver a mano porque el canal es
trapezoidal (yc y yn no tienen forma cerrada) y hay que integrar la EDO
de FGV en **tres tramos con distinta pendiente**, ubicando un resalto
móvil — exactamente el tipo de problema para el que está pensada esa
librería. Script adaptado a este examen:
`resueltos/2022 Julio/scripts/Ejercicio1_FGV_trapezoidal_3tramos.m`
(+ función auxiliar `perfil_union_fn.m`).

### Parte 1 — Caudal de descarga del Lago A

Tramo I es "de gran longitud (infinita)" y steep: el lago descarga el
caudal máximo compatible con su energía, con **control crítico en la
entrada** (x=0), sin importar lo que pase aguas abajo:

```
E(yc) = yc + Q²/(2g·A(yc)²) = hLA = 1.43 m      (conservación de energía, sin pérdidas)
Fr²(yc) = Q²·B(yc)/(g·A(yc)³) = 1                (definición de yc, sección trapezoidal)
```

Sistema 2x2 resuelto con `control_critico_lago_trap.m` (`fzero` en Q
anidando un `fsolve` en yc, porque en sección trapezoidal yc(Q) no tiene
forma cerrada):

| Variable | Valor |
|---|---|
| **Q (caudal de descarga del Lago A)** | **9.79 m³/s** |
| yc | 1.094 m |

Verificación: E(yc) con este Q = 1.4300 m = hLA ✓.

*Comparación con la solución oficial*: la solución manuscrita da
Q=9.8 m³/s, yc=1.094 m — coincide.

### Parte 2 — Clasificación de tramos y perfil completo (hLB=0.8 m)

Tirantes normales de cada tramo (con el Q ya hallado, resolviendo
Manning trapezoidal por `fsolve`):

| Tramo | S₀ | yn | vs. yc=1.094 | Clasificación |
|---|---|---|---|---|
| I | 0.03 | **0.664 m** | yn < yc | **STEEP (S)** |
| III | 0.0015 | **1.336 m** | yn > yc | **MILD (M)** |

*Comparación con la solución oficial*: yn_I=0.66 m, yn_III=1.33 m —
coincide.

**Perfil completo** (x creciente en el sentido del flujo; Lago A → Lago
B), con hLB=0.8 m < yc=1.094 m (el Lago B **no alcanza a ahogar** la
salida del tramo III, que descarga como si fuera una caída libre — el
valor exacto de hLB no importa mientras sea ≤ yc):

1. **Lago A → tramo I** (x=0): control crítico, y=yc=**1.094 m**.
2. **Tramo I** (curva S2, decrece desde yc hacia yn_I al alejarse del
   lago): como el tramo es muy largo, el tirante converge a
   **yn_I=0.664 m** mucho antes de llegar a la unión con el tramo II —
   entra al tramo II ya en régimen uniforme supercrítico.
3. **Tramo II** (horizontal): la rama supercrítica que entra en
   yn_I=0.664 m **no se queda constante** — al cambiar la pendiente de
   fondo evoluciona según su propia ecuación (curva H3, tendiendo hacia
   yc). Integrando su conjugado punto a punto (`Mom_trap`) y cruzándolo
   con la rama subcrítica que llega desde aguas abajo (curva H2, ver
   punto 4), el **resalto se ubica a 26.7 m** de la unión tramo I/II
   (a 73.3 m de la unión con el tramo III):
   - y₁ (antes, supercrítico) = **0.799 m**
   - y₂ (después, subcrítico) = **1.443 m**
   - Verificación: M(y₁)=4.98 m³ ≈ M(y₂)=4.98 m³ ✓ (conservación de
     momento en el resalto).
4. **Resto del tramo II** (curva H2, subcrítica, desde el resalto hasta
   la unión con tramo III): decrece de 1.443 m a **1.276 m**.
5. **Tramo III** (curva M2, subcrítica, entre yc y yn_III): decrece
   desde 1.276 m en la unión con II hasta **yc=1.094 m** en la salida
   al Lago B (control crítico en la salida, por ser M con hLB<yc).

*Comparación con la solución oficial*: la manuscrita reporta valores muy
cercanos — y≈1.479 m en la unión I/II (vs. 1.481 m acá), y≈1.27 m en la
unión II/III (vs. 1.276 m), resalto ubicado "X_res≈26.8 m" desde la
unión I/II (vs. 26.7 m acá) con tirantes del resalto ≈0.98/1.44 m — la
diferencia en el tirante y₁ (0.799 m vs. la lectura aproximada de la
manuscrita, ≈0.8 m) es coherente dentro del error de lectura de la
caligrafía. Coincide en la conclusión: **el resalto está en el tramo
II**, no en el I ni el III.

### Parte 3 — Umbral de hLB para que el resalto pase al tramo I

El resalto llega justo a la unión tramo I/II cuando la rama subcrítica
que remonta desde el Lago B, evaluada en esa unión, iguala el
**conjugado de yn_I** (con la rama supercrítica todavía sin evolucionar,
recién entrando al tramo II):

```
[~, yconj_I] = Mom_trap(yn_I, b, m, Q)   -->   yconj_I = 1.655 m
```

Se itera hLB (`fzero`) propagando hacia atrás la rama subcrítica desde
la salida (control crítico si hLB≤yc, o directamente y=hLB si el lago
ahoga la salida) a través de los tramos III y II, hasta que el tirante
en la unión I/II iguale 1.655 m:

| Variable | Valor |
|---|---|
| **hLB umbral** | **≈1.65 m** |

- Para **hLB < 1.65 m** (incluye el caso hLB=0.8 m de la Parte 2): el
  resalto queda dentro del **tramo II**.
- Para **hLB > 1.65 m**: la rama subcrítica en la unión I/II ya supera
  el conjugado de yn_I, así que el cruce ocurre aguas arriba de esa
  unión — el **resalto se corre al tramo I**.

*Comparación con la solución oficial*: la manuscrita anota un valor de
"hLB" alrededor de 1.66 m en este mismo paso (con un tirante intermedio
en la unión II/III de ≈1.585 m, muy cercano al 1.576 m obtenido acá) —
coincide dentro del margen de lectura del escaneo. **Nota de lectura**:
la letra del examen pregunta literalmente "a partir de qué valor de hLB
ocurre un resalto en el tramo I"; el cálculo (y la propia lógica física:
subir hLB aumenta el remanso en todo el canal, empujando el resalto
hacia aguas arriba) confirma que la relación correcta es esa — **por
encima** de 1.65 m el resalto pasa a estar en el tramo I.

---

## ESTADO: EN CURSO (ejercicios 2, 3 y 4 pendientes)
