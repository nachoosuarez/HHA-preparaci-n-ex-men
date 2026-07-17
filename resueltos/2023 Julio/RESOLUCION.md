# Examen HHA — 24 de julio de 2023

Fuente: `EXAMENES/2023 Julio.pdf` (10 páginas: letra + solución oficial
manuscrita completa, escaneada, con carta topográfica). Los 4 ejercicios
(25/30/20/25 puntos) son: 1) FGV en canal trapezoidal, entre dos lagos,
con obra de relleno que cambia la pendiente de fondo en un tramo; 2)
hidrología de una cuenca en Canelones — caudal de diseño de una
alcantarilla (Racional + NRCS), caudal de un evento observado (hietograma
en bloques + AMC) y período de retorno de una intensidad registrada; 3)
delimitación de la cuenca de la cañada de Arbelo (carta SGM), definición
de tiempo de concentración y cálculo de tc; 4) sistema de bombeo con
bifurcación en dos tuberías idénticas que descargan a la atmósfera —
cavitación y punto de funcionamiento.

Este examen trae **solución oficial manuscrita completa** para los 4
ejercicios (páginas 5-10 del PDF) y la carta topográfica sin delimitar
(página 3), que se usan para comparar cada resultado.

---

## Ejercicio 1 — FGV en canal trapezoidal con obra de relleno (cambio de pendiente)

### Enunciado (resumen)

Un Lago A (nivel hLA=1.7 m sobre el fondo) descarga a un canal
TRAPEZOIDAL (ancho de base b=1.8 m, talud lateral m=1, n=0.014,
S0=0.008), de longitud L=100 m, que termina en un Lago B (nivel
hLB=0.5 m sobre el fondo).

1) Calcular el caudal de descarga, clasificar el canal en tipo M o S y
   dibujar la superficie libre, indicando tirantes relevantes y
   resaltos si los hubiera.
2) Una obra de relleno cambia la pendiente de fondo a S02=0.0015 en el
   tramo x=[40,100] m (el tramo x=[0,40] m conserva S0=0.008). Repetir
   el análisis para estas nuevas condiciones.

### Teoría (RESUMEN_TEORICO.md, sección A — FGV)

- **A1** Clasificación M/S: yn (Manning) vs. yc (Froude=1); en sección
  trapezoidal ninguno de los dos tiene forma cerrada, se resuelven por
  `fsolve` (`eq_yn.m`, `eq_yc.m`).
- **A2** Energía específica: control crítico en la entrada de un canal
  alimentado por un lago, E(yc)=hLago. En trapezoidal esto tampoco es
  cerrado (a diferencia del rectangular E=1.5·yc): se itera un `fzero`
  externo en Q para que yc(Q) satisfaga la ecuación de energía.
- **A4** Control de un canal alimentado por un lago: si el tramo de
  salida es tipo S, el lago descarga con control crítico en la entrada,
  caudal máximo independiente de lo que pase aguas abajo (mientras siga
  siendo steep); un segundo lago aguas abajo con nivel menor al tirante
  que trae el canal no controla nada (caída libre).
- **A3** Ubicación de un resalto: comparar, en la misma sección x, el
  conjugado (`Mom_trap`) de la rama supercrítica con el valor real de la
  rama subcrítica.
- Caso análogo ya resuelto (canal RECTANGULAR de dos tramos entre dos
  lagos): `resueltos/2023 diciembre/RESOLUCION.md`, Ejercicio 1 — mismo
  método, adaptado acá a geometría trapezoidal.

Cita: Teórico HHA §2.2, §2.3.1–§2.3.3, §2.5.1–§2.5.6; Formulómetro "Flujo
Gradualmente Variado" / "Energía" / "Cantidad de Movimiento".

### Herramienta y por qué

Se usó Octave con el toolkit canónico `RESUMEN EXAMEN/Codigos/FGV_trapezoidal`
(`trap_geom` —geometría—, `eq_yc`+`fsolve` —yc—, `eq_yn`+`fsolve` —yn—,
`Mom_trap` —conjugado/resalto—, `rect.m` —ODE de FGV trapezoidal, pese al
nombre— +`ode23` —integración de las curvas S2/M2/M3—, `critico.m` —evento
de parada en yc—) porque el enunciado es un problema de FGV en canal
TRAPEZOIDAL con controles en ambos extremos (dos lagos) y un cambio de
pendiente intermedio en un solo tramo — el caso de uso central de ese
toolkit, con la particularidad de que ninguna magnitud (yc, Q de control
crítico) tiene forma cerrada en sección trapezoidal, a diferencia del caso
rectangular ya resuelto en 2023 diciembre. No hizo falta ninguna función
nueva en el toolkit: se resolvió encadenando las funciones existentes con
un `fzero` adicional (envuelto en la función local
`residuo_entrada_lago`, dentro del script de este ejercicio) para hallar
el Q de control crítico. Script adaptado a este examen (+ todo el
toolkit `FGV_trapezoidal` copiado al mismo directorio como dependencias):
`resueltos/2023 Julio/scripts/Ejercicio1_FGV_trapezoidal_relleno.m`.

### Paso a paso

**Parte 1) Canal uniforme, S0=0.008 en toda la longitud.**

Como el tramo de salida es candidato a tipo S (pendiente 0.008,
relativamente fuerte para b=1.8 m), se prueba la hipótesis de control
crítico en la entrada: el Lago A descarga el caudal máximo compatible
con su energía, es decir y(0)=yc con E(yc)=hLA. En sección trapezoidal
esto no tiene forma cerrada, así que se itera Q (`fzero`) hasta que el
yc(Q) resuelto con `eq_yc` cumpla la ecuación de energía:

```
yc(Q) + Q² / (2g·A(yc)²) = hLA        (fzero en Q)
Q = 11.323 m³/s  ;  yc = 1.2552 m  ;  A(yc) = 3.8347 m²
chequeo: E(yc) = 1.2552 + 11.323²/(2·9.8·3.8347²) = 1.7000 m = hLA  ✓
```

Tirante normal con S0=0.008 (`eq_yn`, `fsolve`):

```
yn = 0.9360 m   ;   yn < yc  =>  CANAL TIPO S (steep)
```

La hipótesis es autoconsistente (canal efectivamente steep), así que el
control crítico en la entrada es válido: el Lago A descarga su caudal
máximo **sin que importe lo que pase aguas abajo**, salvo verificar el
Lago B al final.

Se integra la curva **S2** (supercrítica, decreciente) desde y(0)=yc
hasta x=L=100 m:

```
y(x=0) = 1.2550 m (=yc)  ->  y(x=100) = 0.9585 m   (asintótico a yn=0.936 m)
```

Como hLB=0.5 m < y(100)=0.9585 m, el **Lago B queda por debajo** del
nivel que trae el canal: no controla nada (en flujo supercrítico la
información no viaja hacia aguas arriba), la descarga se comporta como
una caída libre y **no hay resalto** en todo el canal.

**Perfil completo (Parte 1):** y=1.255 m en la entrada (control crítico,
x=0) → curva **S2** decreciendo suavemente hasta y≈0.959 m en x=100 m
(cerca de yn=0.936 m) → descarga directa al Lago B, sin resalto.

**Parte 2) Relleno: S02=0.0015 en x=[40,100] m (x=[0,40] m sin cambios).**

Como el tramo x=[0,40] m conserva S0=0.008 (no cambia respecto a la
Parte 1), el control crítico en la entrada **sigue siendo el mismo**: la
perturbación aguas abajo no puede viajar hacia el Lago A porque el flujo
en ese tramo es supercrítico. Se reutilizan Q=11.323 m³/s y yc=1.2552 m
de la Parte 1.

Tirante normal del tramo 2 con S02=0.0015:

```
yn2 = 1.4567 m   ;   yn2 > yc  =>  TRAMO 2 TIPO M (mild)
```

La curva S2 del tramo 1, evaluada en x=40 m (mismo Q, misma S0=0.008):

```
y(x=40) = 1.0096 m   (< yc, sigue supercrítica)
```

Al entrar al tramo 2 (mild) con y<yc, la rama supercrítica se convierte
en una curva tipo **M3** (crece hacia yc): se integra la ODE de FGV con
S02 desde (x=40, y=1.0096) hacia adelante:

```
y(x=40) = 1.0096 m  ->  y(x≈81.5) = yc = 1.2552 m   (curva M3, creciendo)
```

En la salida (x=100 m), hLB=0.5 m < yc=1.2552 m: el Lago B tampoco
controla acá — la salida se comporta como caída libre, y(100)=yc,
alimentando una curva **M2** (subcrítica) que se integra **hacia atrás**
desde x=100 hasta x=40:

```
y(x=100) = 1.2553 m (=yc, caída libre)  ->  y(x=40) = 1.4028 m   (curva M2)
```

Como la rama que entra al tramo 2 es supercrítica (M3) y la rama de
salida es subcrítica (M2), debe haber un **resalto** dentro del tramo 2.
Se ubica comparando el conjugado (`Mom_trap`) de la rama M3 con el valor
real de la rama M2 en la misma malla de x:

```
RESALTO en x ≈ 69.3 m (≈29.3 m dentro del tramo 2):  y = 1.139 m  ->  y = 1.375 m
```

**Perfil completo (Parte 2):** y=1.255 m en la entrada (control crítico,
x=0) → curva **S2** decreciendo hasta y=1.010 m en x=40 m (cambio de
pendiente) → curva **M3** creciendo hasta y≈1.14 m en x≈69.3 m →
**resalto** (1.14 m → 1.375 m) → curva **M2** decreciendo suavemente
hasta y=yc=1.255 m en x=100 m (caída libre al Lago B).

### Resultado final

| Ítem | Resultado |
|---|---|
| Caudal de descarga (control crítico en la entrada) | **Q = 11.32 m³/s** |
| Tirante crítico yc | **1.255 m** |
| Parte 1: clasificación / yn | **Tipo S** (yn=0.936 m) |
| Parte 1: perfil | y=1.255 m (x=0) → curva S2 → y≈0.959 m (x=100 m), sin resalto |
| Parte 2: tramo 1 [0,40 m] | Tipo S (idéntico a Parte 1) |
| Parte 2: tramo 2 [40,100 m] | **Tipo M** (yn2=1.457 m) |
| Parte 2: resalto | **x≈69.3 m** (1.14 m → 1.375 m) |
| Parte 2: perfil | S2 (x=0→40) → M3 (40→69.3) → resalto → M2 (69.3→100, hasta yc) |

### Comparación con la solución oficial

La solución oficial manuscrita (páginas 5-6 del PDF) trae los mismos
resultados numéricos, calculados a mano con las fórmulas cerradas de
sección rectangular aplicadas a los términos trapezoidales (mismo
método, menor precisión numérica):

| Magnitud | Oficial (manuscrito) | Calculado | Diferencia |
|---|---|---|---|
| Q (control crítico) | 11.33 m³/s | 11.32 m³/s | ≈0 |
| yc | 1.25 m | 1.255 m | ≈0 |
| yn (Parte 1, S0=0.008) | 0.93 m | 0.936 m | ≈0.01 m |
| y(x=100 m), Parte 1 | 0.959 m | 0.959 m | 0 |
| yn2 (Parte 2, S02=0.0015) | 1.45 m | 1.457 m | ≈0.01 m |
| y(x=40 m), Parte 2 | 1.03 m | 1.010 m | ≈0.02 m |
| Posición del resalto | x≈70 m (30 m en tramo 2) | x≈69.3 m (29.3 m en tramo 2) | ≈0.7 m |
| Tirantes del resalto | 1.143 m → 1.37 m | 1.139 m → 1.375 m | ≈0.01 m |

Coincidencia prácticamente total (las diferencias de milésimas se deben
a redondeo manual en el examen original vs. precisión numérica de
`fsolve`/`ode23`). Nota: el escaneo original de la solución tiene, en el
encabezado del Ejercicio 1, una anotación manuscrita con otros valores
de b y L que no corresponden a la letra impresa del examen (probablemente
un residuo de un borrador o una serie distinta del mismo parcial); se
usaron los datos de la letra impresa (b=1.8 m, m=1, L=100 m) en todo el
cálculo, y la coincidencia numérica exacta de Q, yc y la posición del
resalto con el desarrollo manuscrito confirma que el resto de la
solución oficial sí corresponde a estos mismos datos.

---
