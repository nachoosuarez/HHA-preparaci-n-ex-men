# Examen HHA — 5/6 de febrero de 2024 (2024 febrero)

Resolución paso a paso. El PDF del examen (`EXAMENES/2024 febrero.pdf`)
incluye, además de la letra (páginas 1-2) y la carta topográfica del
Ejercicio 3 (páginas 3, 8), la solución oficial manuscrita completa
(páginas 5-7, 9), que se usa para comparar cada resultado.

Herramientas: Octave (funciones de
`RESUMEN EXAMEN/Codigos/FGV_trapezoidal/`, copiadas y adaptadas en
`scripts/`) para el Ejercicio 1 (flujo gradualmente variado en canal
trapezoidal entre dos lagos, con escalón de fondo).

Los scripts del Ejercicio 1 deben ejecutarse en orden (`ej1_parte1.m`
genera `part1.mat`, usado por `ej1_parte2.m`; `ej1_parte2.m` genera
`part2.mat`, usado por `ej1_parte3.m`). Los archivos `.mat` intermedios no
se versionan.

---

## EJERCICIO 1 — Canal trapezoidal entre dos lagos, con escalón de fondo (25 puntos)

**Datos:** sección trapezoidal, b=5 m, talud m=2 (1V:2H), n=0.018
(Manning), S₀=0.002, L=1500 m. El canal nace en el Lago A (tirante sobre
el fondo del canal h_LA=1.10 m en x=0) y termina en el Lago B (tirante
h_LB=1.49 m en x=L=1500 m).

Teoría usada: caudal de un canal tipo M alimentado por un lago largo
(Teórico HHA §2.5.4, Resumen Teórico §A4), clasificación M/S (§2.5.1–2.5.2,
§A1), control de un segundo lago aguas abajo con curva de remanso M1
(§2.5.4, §A4), transición de fondo tipo escalón con posible ahogamiento y
remanso (§2.2, §A5), tirante conjugado y ubicación del resalto por
cantidad de movimiento (§2.3.2–2.3.3, §A3), y fuerza sobre un obstáculo de
fondo F=γ·(M1−M2) (§2.3.1, §A3).

### Parte 1) Caudal, clasificación M/S y perfil sin escalón

**Concepto.** El canal es largo (1500 m) y de tipo M (a verificar), por lo
que cerca de la entrada (Lago A) el tirante tiende al normal yn: se plantea
un sistema de 2 ecuaciones (conservación de energía entre la superficie del
lago y la sección de entrada + ecuación de Manning) en las 2 incógnitas
(Q, yn). Una vez hallado Q se calcula yc y se clasifica el canal. El
control aguas abajo es el Lago B: como su tirante h_LB=1.49 m es mayor que
yn, el Lago B impone una curva de remanso **M1** que sube desde x=L hacia
aguas arriba y se acerca asintóticamente a yn lejos del lago (canal
"infinito" en la práctica).

**Herramienta:** `caudal_M_ini.m` (sistema Q–yn para canal M alimentado por
un lago) + `tirantes_yn_yc.m`/`eq_yc.m` (yc) para clasificar, y luego
`rect.m` (EDO de FGV trapezoidal) integrada con `ode23` desde x=L (control,
y=h_LB) hacia x=0. Se usa `caudal_M_ini.m` — en vez de asumir Q como dato —
porque acá el caudal no se conoce de antemano, sólo los niveles de los dos
lagos.

**Script:** `scripts/ej1_parte1.m`. Entradas: `b=5, m=2, n=0.018,
S0=0.002, L=1500, hLA=1.10, hLB=1.49`.

**Resultado:**
```
Q  = 11.9754 m3/s
yn = 0.9101 m
yc = 0.7524 m
```
Como yn (0.9101 m) > yc (0.7524 m) ⇒ **canal tipo M**. Como h_LB=1.49 m >
yn=0.9101 m ⇒ el Lago B controla e impone una **curva M1** en todo el
canal.

**Perfil de la superficie libre (x desde el Lago A):**
- x=0 (Lago A): y=0.9102 m ≈ yn (el canal es lo bastante largo como para
  que la entrada ya esté prácticamente en régimen normal).
- x=700 m (punto donde después se instala el escalón, Parte 2): y=0.9100 m
  ≈ yn.
- x=1500 m (Lago B): y=1.4900 m = h_LB.

No hay resaltos: todo el tramo es subcrítico (curva M1 monótona).
Gráfico: `scripts/ej1_perfil_parte1.png`.

**Resultado final Parte 1: Q ≈ 11.98 m³/s, canal tipo M (yn=0.91 m >
yc=0.75 m), curva M1 en todo el canal (remanso desde el Lago B), sin
resaltos.**

**Comparación con solución oficial:** el manuscrito da E₁=h_LA=1.10 m,
y₁=yn ⇒ Q=11.99 m³/s (yn≈0.91 m), yc=0.75 m ⇒ yn>yc canal M, h_LB>yn ⇒
curva M1 — **coincide** (diferencia de redondeo en Q: 11.9754 vs 11.99).

### Parte 2) Escalón de fondo Zesc=0.50 m en x=700 m

**Concepto.** La obra para instalar una tubería deja un escalón de fondo
de longitud despreciable en x=700 m (el fondo sube Zesc y vuelve a bajar
al nivel original en el mismo punto). Es la misma situación de §A5: se
compara la energía específica disponible sin escalón en ese punto (E₁, con
el y sin alterar de la Parte 1 ≈ yn) contra la energía mínima Ec
(crítica); si Zesc > Zmax=E₁−Ec el escalón "ahoga" la sección y aparece
remanso aguas arriba, el flujo pasa por crítico en la cresta, se acelera a
supercrítico aguas abajo (curva M3) y un resalto hidráulico reconecta esa
rama con la curva M1 original (que sigue vigente lejos del escalón, porque
el Lago B sigue siendo el control aguas abajo).

**Herramienta:** energía específica directa en la sección sin alterar
(con y≈yn de la Parte 1) y Ec=yc+U_c²/2g para Zmax; `alternos_trap.m` para
los tirantes alternos (subcrítico aguas arriba / supercrítico aguas abajo)
con la nueva energía E_A=Ec+Zesc; integración de la curva M3 con
`rect.m`/`ode23` desde x=700 m hacia aguas abajo; conjugado de cada punto
de M3 con `Mom_trap.m`; resalto por intersección entre ese conjugado y el
perfil M1 original de la Parte 1 (mismo procedimiento que
`encontrar_resalto.m`, adaptado). Es el mismo enfoque usado en el
Ejercicio 1 del examen 2025_FEBRERO 2 ya resuelto en este repositorio.

**Script:** `scripts/ej1_parte2.m` (carga `part1.mat`).

**Resultado:**
```
y(x=700, sin escalon) = 0.9101 m (~= yn)
E1_sin = 1.1000 m ; Ec = 1.0579 m
Zmax = E1_sin - Ec = 0.0421 m

Zesc = 0.50 m > Zmax = 0.0421 m  => el escalon AHOGA la seccion => HAY REMANSO

EA = Ec + Zesc = 1.5579 m
y1_new (subcritico, aguas arriba del escalon) = 1.5078 m
y3_new (supercritico, aguas abajo del escalon) = 0.4349 m

RESALTO HIDRAULICO:
  x_resalto = 732.20 m (desde el Lago A)
  distancia desde el escalon (x=700m) = 32.20 m
  y antes del resalto (curva M3, supercritico) = 0.6112 m
  y despues del resalto (conjugado, sobre M1)  = 0.9100 m
```

**Caudal de descarga:** en las condiciones con escalón el caudal sigue
siendo Q≈11.98 m³/s: lejos del escalón (cerca del Lago A) el flujo
recupera el tirante normal yn≈0.91 m —el mismo sistema Q–yn de la Parte
1—, y el escalón sólo modifica el perfil local (remanso + M3 + resalto)
sin cambiar el caudal aportado por el Lago A.

**Perfil completo de la superficie libre (x desde el Lago A):**
- x=0 a ≈690 m: curva M1 sin alterar, y≈0.91 m (≈yn, lejos del escalón).
- x=700 m⁻ (justo aguas arriba del escalón): y₁=1.5078 m (remanso).
- x=700 m (cresta del escalón): y=yc=0.7524 m (paso por crítico).
- x=700 m⁺ (justo aguas abajo, fondo ya en su nivel original): y₃=0.4349 m
  (curva M3, supercrítica).
- x=700 a 732.2 m: curva M3 acelerando de 0.435 m a 0.611 m.
- x≈732.2 m: **resalto hidráulico**, de y=0.611 m a y=0.910 m.
- x=732.2 a 1500 m: curva M1 original de la Parte 1 (idéntica, sin
  alterar), subiendo de 0.910 m hasta h_LB=1.49 m en el Lago B.

Gráfico: `scripts/ej1_perfil_parte2.png`.

**Resultado final Parte 2: Q≈11.98 m³/s (no cambia), canal sigue siendo
tipo M; el escalón de 0.50 m ahoga la sección (Zmax=0.042 m << Zesc), se
forma remanso aguas arriba (y≈1.51 m en x=700 m⁻), el flujo pasa por
crítico en la cresta, se acelera a supercrítico (y≈0.43 m) y, tras
recorrer ≈32 m sobre la curva M3, un resalto hidráulico (de y≈0.61 m a
y≈0.91 m) reconecta con la curva M1 original hasta el Lago B.**

**Comparación con solución oficial:** el manuscrito da (interpretando la
digitalización, borrosa en esta parte) Zmax≈0.04–0.09 m, E_A=Ec+Zesc≈1.55
m, y₁≈1.51 m, y₃≈0.43 m y un resalto a ≈34 m del escalón con y antes del
resalto ≈0.61 m — **coincide** con los valores obtenidos (Zmax=0.042 m,
E_A=1.558 m, y₁=1.508 m, y₃=0.435 m, resalto a 32.2 m con y=0.611 m antes
del resalto); las pequeñas diferencias (≤2 m en la posición del resalto)
son consistentes con redondeo manual en la resolución original.

### Parte 3) Fuerza sobre el escalón

**Concepto.** Entre la sección justo aguas arriba del escalón
(y₁=1.5078 m, fondo a nivel original) y la sección justo aguas abajo
(y₃=0.4349 m, fondo también a nivel original, tras la subida y bajada del
escalón) no hay cambio de cota de fondo entre las dos secciones de
control: toda la fuerza horizontal neta que el escalón ejerce sobre el
fluido es R=γ·(M₁−M₃) (cantidad de movimiento, §A3); por reacción, el
fluido ejerce sobre el escalón una fuerza igual y opuesta, en el sentido
del flujo.

**Herramienta:** `Mom_trap.m` para M(y₁) y M(y₃) (función cantidad de
movimiento de la sección trapezoidal), con los tirantes y1_new/y3_new
calculados en la Parte 2.

**Script:** `scripts/ej1_parte3.m` (carga `part2.mat`).

**Resultado:**
```
M1 = M(y=1.5078 m) = 9.1782 m3
M3 = M(y=0.4349 m) = 6.2547 m3

F = gamma*(M1 - M3) = 9800*(9.1782 - 6.2547) = 28649 N = 28.6 kN
```

**Resultado final Parte 3: F ≈ 28.6 kN, en el sentido del flujo.**

**Comparación con solución oficial:** el manuscrito da
Π_A=9.2068 m³, Π_A'=6.3369 m³ ⇒ F=9800·(9.2068−6.3369)=28126 N ≈ 28.1 kN
— **coincide** con el resultado obtenido (28.6 kN), diferencia ≈2% por
redondeo manual de los tirantes alternos en la resolución original.

---

## ESTADO: EN CURSO (Ejercicio 1 completo; faltan Ejercicios 2, 3 y 4)
