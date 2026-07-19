# Examen HHA — 22 de diciembre de 2020

Fuente: `EXAMENES/2020 Diciembre.pdf` (22 páginas). Este PDF trae **tres
variantes** del mismo examen (distinto Q, distinta proporción de suelos y
distinto kv de válvula por alumno), cada una con su solución oficial
manuscrita:

- **Variante A** (páginas 1-4 letra, 5-9 solución): Ejercicio 1 con
  Q=22 m³/s y a=0.85 m; Ejercicio 2 con Río Branco 85%/Andresito 15%;
  Ejercicio 3 con kv=20.
- **Variante B** (páginas 10-13 letra, 14-15 solución parcial):
  Q=20 m³/s y a=0.85 m; Río Branco 5%/Andresito 95%; kv=30.
- **Variante C** (páginas 16-19 letra, 20-22 solución): Q=18 m³/s y
  a=0.76 m; Río Branco 50%/Andresito 50%; kv=40.

Se resuelve acá la **Variante A** (la que trae la solución oficial más
completa y legible), comparando cada resultado contra esa manuscrita.

---

## Ejercicio 1 (35 puntos) — FGV en canal trapezoidal con compuerta de fondo

### Enunciado (resumen, Variante A)

Canal trapezoidal semi-infinito (ancho de fondo b=2.4 m, talud m=2H:1V,
pendiente S₀=0.0005, Manning n=0.016), Q=22 m³/s, que finaliza en una
**caída libre**.

1. Clasificar el canal en tipo M o S; dibujar la superficie libre sin
   compuerta, indicando tirantes y resaltos si los hubiere.
2. Con una **compuerta de fondo ideal** (abertura a=0.85 m) ubicada
   **500 m aguas arriba** de la caída libre: dibujar la superficie libre
   completa, tirantes y resaltos.
3. Calcular la fuerza sobre la compuerta y la potencia disipada en los
   resaltos.
4. Indicar el máximo valor de la abertura a para el cual la compuerta
   descarga libre.

### Teoría

- **Clasificación M/S** (RESUMEN_TEORICO.md §A1): se compara yn
  (Manning) con yc (crítico, independiente de la pendiente) — yn>yc ⇒
  canal tipo M (pendiente suave).
- **Caída libre** (§A4): control crítico y≈yc justo en el borde; canal M
  muy largo aguas arriba tiende asintóticamente a yn (curva M2).
- **Compuerta de fondo ideal** (§A5): se conserva la energía específica
  entre la sección inmediatamente aguas arriba (yA) y la vena contraída
  aguas abajo (yB=a) — yA es el **alterno** de a. El chequeo de descarga
  libre/ahogada compara el **conjugado** de a (a\*, por momentum) con el
  tirante que trae la curva de aguas abajo en esa sección (a\* > y(aguas
  abajo) ⇒ libre, con resalto más adelante).
- **Resalto hidráulico y fuerza sobre un obstáculo** (§A3): se ubica
  cruzando el conjugado de la rama supercrítica (M3, avanzando desde la
  compuerta) con la rama subcrítica impuesta desde aguas abajo (M2,
  retrocediendo desde la caída libre). La fuerza sobre la compuerta es
  F=γ(M1−M2) entre las dos secciones que la limitan (aguas arriba y vena
  contraída), y la potencia disipada en el resalto es Pdis=γQ(H1−H2)
  entre los tirantes conjugados del resalto (no los de la compuerta).

### Herramienta y por qué

Se usó **Octave** con el toolkit canónico
`RESUMEN EXAMEN/Codigos/FGV_trapezoidal/` (`trap_geom`, `froude_trap`,
`manning_trap` para yc/yn; `Eesp_trap` para el alterno de a; `Mom_trap`
para conjugados/momento; `rect.m`+`ode23`+`critico.m` para integrar las
curvas M3 y M2) porque la sección es trapezoidal (yc, yn y los
conjugados no tienen forma cerrada) y hay que ubicar un resalto móvil
entre dos ramas de FGV — exactamente el caso de uso de esta librería
(ver también `resueltos/2022 Julio/RESOLUCION.md` Ej.1 y
`resueltos/2024 marzo/RESOLUCION.md` Ej.1 para el mismo patrón en
trapezoidal/rectangular). Script adaptado a este examen:
`resueltos/2020 Diciembre/scripts/Ejercicio1_FGV_trapezoidal_compuerta.m`
(+ todo el toolkit `FGV_trapezoidal` copiado como dependencia, + función
auxiliar `conjugado_de_a.m`).

### Parte 1 — Clasificación del canal (sin compuerta)

```
yc (froude_trap, fsolve)  = 1.4085 m
yn (manning_trap, fsolve) = 2.1188 m
```

yn > yc ⇒ **canal tipo M** (pendiente suave). Con la caída libre como
único control (control crítico, y=yc en el borde) y canal semi-infinito
aguas arriba, la superficie libre sigue una **curva M2**: crece
suavemente desde yc=1.41 m en la caída libre hasta acercarse
asintóticamente a yn=2.12 m muy aguas arriba.

*Comparación con la solución oficial*: yc=1.41 m, yn=2.12 m — coincide
exactamente.

### Parte 2 — Perfil completo con compuerta (a=0.85 m, a 500 m de la caída libre)

**Tirante aguas arriba de la compuerta** (energía conservada, compuerta
ideal): yA = alterno de a = **2.836 m** (usando `Eesp_trap(a,b,Q,m)`).

**Chequeo libre/ahogada**: se integra la curva M2 hacia atrás desde la
caída libre (y=yc en x=500 m) hasta la compuerta (x=0), obteniendo el
tirante que traería esa rama en la compuerta **si no hubiera resalto
antes**: y_M2(x=0)=1.958 m. El conjugado de a (momentum, `Mom_trap`) es
a\*=2.136 m > 1.958 m ⇒ **descarga LIBRE** (el resalto se forma aguas
abajo de la compuerta, no queda ahogado contra ella).

**Ubicación del resalto**: se integra la curva M3 (supercrítica) hacia
adelante desde la compuerta (y=a=0.85 m en x=0) y se cruza su conjugado
punto a punto con la curva M2 (subcrítica) que retrocede desde la caída
libre:

```
RESALTO a x ≈ 30.1 m aguas abajo de la compuerta (≈470 m antes de la caída libre)
y1 (antes, supercrítico) = 0.966 m
y2 (después, subcrítico) = 1.949 m
Verificación: M(y1)=M(y2) por construcción (intersección de la curva conjugado(M3) con M2)
```

**Perfil completo**: y=2.836 m aguas arriba de la compuerta (remanso M1)
→ **compuerta** → y=0.85 m (vena contraída, curva M3 creciente) →
**resalto en x≈30 m** (0.966 m → 1.949 m) → curva M2 decreciendo
suavemente hasta **yc=1.409 m** en la caída libre (≈470 m después del
resalto).

*Comparación con la solución oficial*: el sketch manuscrito ubica el
resalto a "30.3 m" de la compuerta con tirantes ≈0.85/0.97 m antes y
≈1.95 m después, y el tirante aguas arriba de la compuerta lo anota como
"y=a\*=2.84 m" — coincide con x≈30.1 m, yA=2.836 m e y2≈1.949 m
calculados acá (la diferencia y1: 0.966 m vs. la lectura aproximada
"0.85 m" del sketch es coherente con el error de lectura de un dibujo a
mano; el valor numérico correcto, verificado por conservación de
momento, es 0.966 m).

### Parte 3 — Fuerza sobre la compuerta y potencia disipada

**Fuerza sobre la compuerta** (F=γ(M1−M2) entre la sección aguas arriba
y la vena contraída, con `Mom_trap`):

```
M(yA=2.836 m) = 27.02 m³
M(a=0.85 m)   = 15.43 m³
F = ρg(M1−M2) = 9810·(27.02−15.43) = 113.6 kN
```

**Potencia disipada en el resalto** (Pdis=γQ(H1−H2), entre los tirantes
conjugados DEL RESALTO — 0.966/1.949 m — no entre yA y a):

```
E(y1=0.966 m) = 2.377 m
E(y2=1.949 m) = 2.113 m
Pdis = ρgQ(E1−E2) = 9810·22·(2.377−2.113) = 57.05 kW
```

| Ítem | Resultado |
|---|---|
| Fuerza sobre la compuerta | **F ≈ 113.6 kN** |
| Potencia disipada en el resalto | **Pdis ≈ 57.05 kW** |

*Comparación con la solución oficial*: F=114.8 kN (con M1=27.1 m³,
M2=15.4 m³ — a menos de 1% del valor calculado acá) y Pdis=53.96 kW (con
H3=2.36 m, H4=2.11 m). La pequeña diferencia en Pdis (57.05 vs. 53.96
kW, ≈6%) es consistente con que la manuscrita redondeó los tirantes del
resalto (≈0.97/1.95 m) antes de calcular la energía, mientras que acá se
usan los valores sin redondear (0.966/1.949 m) hallados por
intersección numérica — igual orden de magnitud y mismo procedimiento.

### Parte 4 — Abertura máxima para descarga libre

El límite libre/ahogada ocurre cuando el conjugado de a iguala al
tirante que trae la curva M2 en la compuerta (y_M2(x=0)=1.958 m,
independiente de a porque esa curva la fija sólo la caída libre a
500 m). Se resuelve a\_max tal que conjugado(a\_max) = 1.958 m
(`fsolve` sobre `Mom_trap`):

```
a_max = 0.9595 m ≈ 0.96 m
```

Para a > 0.96 m la compuerta pasaría a descarga **ahogada** (resalto
sumergido contra la compuerta).

*Comparación con la solución oficial*: a\_max=0.906 m (anotado en la
solución oficial de la Variante B, con Q=20 m³/s en vez de 22 — no es
directamente comparable número a número; la Variante A no trae este
valor final en la manuscrita, aunque sí anota "0,96 m" en el dibujo del
punto 4). **Coincide** con a\_max≈0.96 m calculado acá.

### Resultado final (Variante A)

| Ítem | Resultado |
|---|---|
| yc / yn (sin compuerta) | **1.409 m / 2.119 m** — canal tipo **M** |
| Perfil sin compuerta | curva M2 desde yc en la caída libre hasta yn aguas arriba |
| yA (aguas arriba de la compuerta) | **2.836 m** |
| Tipo de descarga (a=0.85 m) | **LIBRE** |
| Resalto | **x≈30.1 m** de la compuerta (0.966 m → 1.949 m) |
| Fuerza sobre la compuerta | **≈113.6 kN** |
| Potencia disipada en el resalto | **≈57.05 kW** |
| a máxima para descarga libre | **≈0.96 m** |

---

## ESTADO: EN CURSO (faltan Ejercicio 2 — hidrología NRCS/alcantarilla — y Ejercicio 3 — bombeo)
