# Examen HHA — 22 de julio de 2019

Fuente: `EXAMENES/2019 julio.pdf` (8 páginas: letra, páginas 1-3, +
solución oficial manuscrita completa, páginas 4-8, escaneadas — PDF sin
texto, se leyó renderizando cada página a PNG con `pdftoppm`). Los 4
ejercicios son:
1) FGV en canal TRAPEZOIDAL de dos tramos (distinta pendiente Y
   rugosidad) entre dos lagos (25 pts);
2) infiltración de Horton y tiempo de encharcamiento de un evento (20 pts);
3) caudal de diseño NRCS de una cuenca en Florida con uso de suelo mixto,
   período de retorno de un evento observado y verificación con AMC (30 pts);
4) sistema de bombeo de dos bombas iguales en paralelo, con regulación
   por válvula (25 pts).

Este examen trae **solución oficial manuscrita completa** para los 4
ejercicios (páginas 4-8 del PDF), que se usa para comparar cada resultado.

---

## Ejercicio 1 — FGV en canal trapezoidal de dos tramos entre dos lagos

### Enunciado (resumen)

Dos lagos se conectan por un canal TRAPEZOIDAL (ancho de fondo b=3.8 m,
talud m=1H:1V) con dos tramos de distinta rugosidad y pendiente:
- Tramo 1: L1=35 m, S01=0.018, n1=0.017 (corto y empinado).
- Tramo 2: L2=1000 m, S02=0.0006, n2=0.01 (largo y suave).

El Lago A tiene nivel hLA=2.0 m sobre el fondo del canal (x=0).

1) Con hLB=2.6 m (Lago B, x=L1+L2): calcular el caudal de descarga,
   clasificar cada tramo en M/S y dibujar la superficie libre, ubicando
   tirantes relevantes y resaltos si los hubiera.
2) Con hLB variable: hallar el rango de niveles del Lago B para el cual
   ocurre un resalto hidráulico en el **tramo 2**.

### Teoría (RESUMEN_TEORICO.md, sección A — FGV)

- **A1** Clasificación M/S: yn (Manning) vs. yc (Froude=1).
- **A4** "Canal de dos tramos con distinta pendiente" (2023 dic, Ej.1):
  se prueba primero la hipótesis más simple (tramo de entrada steep ⇒
  control crítico directo en x=0, Q en forma cerrada/semi-cerrada) y se
  verifica que sea autoconsistente (yn1<yc con ese Q). Acá, además de la
  pendiente, cambia también la rugosidad de Manning entre tramos — el
  razonamiento es idéntico, sólo cambia qué par (S,n) se usa en cada
  tramo para yn y para integrar la EDO de FGV.
- **A4** "Control crítico en la entrada, sección trapezoidal (sin forma
  cerrada)" (2023 jul, Ej.1): en trapezoidal, yc(Q) no tiene forma
  cerrada — se anida `fsolve` (yc dado Q) dentro de un `fzero` externo en
  Q hasta que la energía en yc iguale hLA.
- **A3** Ubicación de un resalto: comparar, en la misma sección x, el
  conjugado (`Mom_trap`) de la rama supercrítica con el valor real de la
  rama subcrítica que llega desde aguas abajo, extendida (si hace falta)
  con la pendiente/rugosidad del tramo donde se busca el resalto.

Cita: Teórico HHA §2.3.1-§2.3.3, §2.5.3-§2.5.6; Formulómetro "Flujo
Gradualmente Variado" / "Cantidad de Movimiento" / "Energía".

### Herramienta y por qué

Se usó Octave con el toolkit canónico `RESUMEN EXAMEN/Codigos/FGV_trapezoidal`
(`trap_geom`, `eq_yc`+`fsolve` —yc—, `eq_yn`+`fsolve` —yn—, `Mom_trap`
—conjugado/resalto—, `rect.m`+`ode45` —integración de las curvas M/S,
pese al nombre "rect" es la EDO trapezoidal—, `critico.m` como evento de
parada, `control_critico_lago_trap.m` —control crítico en la entrada,
Q sin forma cerrada— ) porque el enunciado es un problema de FGV en canal
trapezoidal con controles en ambos extremos (dos lagos) y dos tramos de
distinta pendiente/rugosidad — exactamente el caso de uso de ese
toolkit; no hizo falta ninguna función nueva, sólo encadenar las
funciones existentes con cada tramo. Script completo:
`resueltos/2019 julio/scripts/Ejercicio1_dos_lagos_dostramos_trap.m` (+
todo el toolkit `FGV_trapezoidal` copiado al mismo directorio como
dependencias).

### Paso a paso

**Parte 1) hLB = 2.6 m.**

Se prueba la hipótesis más simple: tramo 1 steep ⇒ control crítico en la
entrada (x=0), con energía E(yc)=hLA (sección trapezoidal, sin forma
cerrada ⇒ `fzero` en Q anidando `fsolve` en yc):

```
yc(Q) tal que  Q²·(b+2m·yc) / (g·(yc·(b+m·yc))³) = 1        (eq_yc.m)
E(yc) = yc + Q² / (2g·A(yc)²) = hLA = 2.0 m                  (fzero en Q)

=>  Q = 25.00 m³/s  ;  yc = 1.436 m
```

Verificación de autoconsistencia (Manning en cada tramo, con ese Q):

```
yn1 (S01=0.018, n1=0.017) = 0.890 m   <  yc=1.436 m  =>  TRAMO 1 TIPO S  ✓ (consistente)
yn2 (S02=0.0006, n2=0.01) = 1.731 m   >  yc=1.436 m  =>  TRAMO 2 TIPO M
```

El lago A descarga entonces su caudal máximo **sin que importe** lo que
pase aguas abajo (salvo que el Lago B llegue a ahogar la entrada — se
verifica más abajo que no es el caso).

Se integra la curva supercrítica S2 en el tramo 1 (x: 0→35 m, desde yc):

```
y_S2(x=0) = yc = 1.436 m  ->  y_S2(x=35 m) = 1.021 m   (yn1=0.890 m, aún no lo alcanza en 35 m)
conjugado(y_S2 en x=35 m) = 1.935 m       (Mom_trap)
```

Se integra la curva subcrítica del tramo 2, hacia atrás desde el Lago B
(hLB=2.6 m > yc, controla la salida con y(x=1035)=hLB):

```
y_tramo2(x=1035 m) = 2.600 m (control)  ->  y_tramo2(x=35 m) = 2.112 m
```

Comparación en la unión de tramos (x=35 m): 2.112 m (subcrítico, tramo 2)
**>** 1.935 m (conjugado de S2) ⇒ el resalto está **dentro del tramo 1**
(la rama subcrítica "empuja" hacia atrás, más allá de la unión). Se
extiende la curva subcrítica hacia atrás dentro del tramo 1 (con S01,n1,
parando en yc por evento) y se cruza contra el conjugado de S2 en la
misma malla de x:

```
RESALTO en x = 26.0 m (medido desde el Lago A, dentro del tramo 1 de 35 m):
   y1 = 1.05 m  (supercrítico, antes)  ->  y2 = 1.89 m  (subcrítico, después)
```

**Resultado Parte 1: Q = 25.00 m³/s** · Tramo 1 tipo **S** (yn1=0.89 m) ·
Tramo 2 tipo **M** (yn2=1.73 m) · **resalto en el tramo 1**, en x≈26.0 m
desde el Lago A (y: 1.05 m → 1.89 m), seguido de una curva M1 casi
constante (≈1.9-2.1 m) hasta el Lago B. Gráfico:
`resueltos/2019 julio/scripts/perfil_parte1.png`.

**Comparación con la solución oficial:** coincide muy bien — Q=25 m³/s
(idéntico), yc≈1.43 m, yn1≈0.89 m, yn2≈1.73 m, y_S2(x=35m)≈1.02 m,
conjugado≈1.93 m, tirante en la unión con el tramo 2≈2.11 m, y_2 tras el
resalto≈1.89 m (todos coinciden a 2-3 cifras significativas); la posición
del resalto x≈26.0 m está muy cerca del x=26.15 m manuscrito (diferencia
<1%, atribuible a redondeo en la lectura gráfica de la solución oficial).

**Parte 2) Rango de hLB para el cual hay resalto en el tramo 2.**

Q, yc, yn1 y yn2 no cambian con hLB (el control de entrada sigue siendo
crítico en x=0 mientras el Lago B no ahogue esa sección). El resalto cae
en el tramo 2 si y sólo si el valor de la curva subcrítica del tramo 2 en
la unión (x=35 m) es **menor** que el conjugado de la curva S2 ahí mismo
(1.935 m, fijo); si fuera mayor, el resalto se corre al tramo 1 (caso de
la Parte 1). El caso límite es cuando ambos coinciden exactamente en
x=35 m: se integra la curva subcrítica del tramo 2 **hacia adelante**
desde ese valor límite (x=35 m) hasta el Lago B (x=1035 m) para hallar el
hLB umbral:

```
y(x=35 m) = conjugado(S2) = 1.935 m  ->  integrando hacia adelante (S02,n2) hasta x=1035 m:
hLB_umbral = 2.354 m
```

Chequeo adicional: si hLB baja hasta yc=1.436 m o menos, el Lago B deja de
controlar la salida (pasa a **caída libre**, y(x=1035)=yc); se verificó
que aún en ese caso el tirante que llega a la unión (1.723 m) sigue siendo
menor que el conjugado de S2 (1.935 m) — el resalto **permanece en el
tramo 2** para cualquier hLB por debajo del umbral, sin cota inferior.

**Resultado Parte 2: hay resalto hidráulico en el tramo 2 para
hLB < 2.35 m** (para 1.44 m < hLB < 2.35 m el Lago B controla la salida
directamente; para hLB ≤ 1.44 m la salida es caída libre, pero el resalto
sigue estando en el tramo 2 en ambos casos — recién por encima de
2.35 m el resalto se corre al tramo 1, como en la Parte 1).

**Comparación con la solución oficial:** coincide exactamente — el
manuscrito da como umbral hLB=2.35 m y concluye "RANGO → hLB < 2.35 m"
(sin cota inferior), igual que este cálculo.

---

ESTADO: EN CURSO (falta Ejercicio 2, 3 y 4)
