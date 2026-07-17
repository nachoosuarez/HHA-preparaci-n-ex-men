# Examen HHA — 1 de marzo de 2024

Fuente: `EXAMENES/2024 marzo.pdf` (11 páginas: letra + solución oficial
manuscrita completa, escaneada). Los 4 ejercicios (25 puntos c/u) son:
1) FGV en canal rectangular con caída libre y compuerta de fondo; 2)
delimitación de cuenca + abstracciones NRCS de un evento observado; 3)
Método Racional (hipótesis + diseño de alcantarilla + urbanización); 4)
Sistema de bombeo (número/acople de bombas, punto de funcionamiento,
potencia, cavitación, longitud máxima de succión).

Este examen trae **solución oficial manuscrita completa** (páginas 4-5,
8-11 del PDF) que se usa para comparar cada resultado.

---

## Ejercicio 4 — Sistema de bombeo

### Enunciado (resumen)

Bombeo desde un reservorio (z1=-2.2 m, superficie libre abierta a la
atmósfera) hasta un tanque elevado presurizado (z2=+10 m, p2=170 kPa
manométrica). Succión: L1=20 m, D1=103 mm. Impulsión: L2=850 m, D2=103 mm.
Ambas tuberías de fundición, ε=0.12 mm. Pérdidas localizadas: k1=6
(succión), k2=5.5 (impulsión). Bombas iguales, ubicadas a cota zA=+0.3 m,
con curva característica H-Q, η-Q y NPSHr-Q dada por tabla (16 puntos, Q de
0 a 20 l/s). Se pide: 1) número mínimo de bombas y forma de acople; 2)
punto de funcionamiento, ecuaciones, Q y H por bomba, factores de fricción,
potencia; 3) evaluación de cavitación (NPSH disponible vs. requerido); 4)
manteniendo Ltot=870 m, cota zA y pérdidas localizadas, la longitud máxima
de succión para que no caviten.

### Teoría (RESUMEN_TEORICO.md, sección C — Sistemas de bombeo)

- **C1** Ecuación de la instalación (Darcy-Weisbach + Colebrook-White):
  Hm = (z2+p2/γ) − (z1+p1/γ) + pérdidas succión + pérdidas impulsión.
- **C2** Punto de funcionamiento: intersección H_bomba(Q) = H_instalación(Q).
- **C3** Potencia consumida: Pcons = γ·Q·H/η.
- **C4** Cavitación: NPSHdisp = HA − zA + 10.1 (m.c.a., incluye patm/γ−pvap/γ)
  vs. NPSHr de tabla; depende sólo del tramo de succión.
- **C5** Serie vs. paralelo: en **paralelo** el H entregado nunca supera el
  máximo de la curva H(Q) de UNA bomba (todas ven la misma H); si la carga
  estática a vencer ya supera ese máximo, ningún paralelo alcanza y hace
  falta **serie** (las cargas se suman a igual Q). Ver criterio agregado a
  C5 en esta corrida.
- Cita: Teórico HHA §3.3.6, §3.3.8, §3.3.10-§3.3.14; Formulómetro "Bombas".

### Herramienta y por qué

Se usó Octave (no la planilla de eventos extremos, que es sólo para
hidrología estadística) adaptando el script canónico
`RESUMEN EXAMEN/Codigos/Bombas/Bombas_serie.m`: resuelve exactamente este
tipo de problema (succión+impulsión con Colebrook-White, curva de bomba por
tabla, cavitación) y ya está pensado para 2 bombas en serie. Se guardó una
copia adaptada a los datos de este examen en
`resueltos/2024 marzo/scripts/Ejercicio4_bombas_serie.m` (+ `colebrook.m`).

### Paso a paso

**1) Número mínimo de bombas y acople.**
Carga estática a vencer: Hestática = (z2−z1) + p2/(ρg) = 12.2 + 17.33 =
**29.53 m**. El máximo de la curva H-Q de una bomba es H=29.0 m (en
Q=5 l/s, la curva no es monótona). Como en **paralelo** el H entregado
nunca supera ese máximo de una sola bomba (29.0 m < 29.53 m), ninguna
cantidad de bombas en paralelo permite elevar el agua al tanque. Con
bombas en **serie** las cargas se suman a igual Q, así que alcanza con
**2 bombas en serie**.

**2) Punto de funcionamiento.**
Con D1=D2=103 mm, la velocidad es la misma en succión e impulsión
(v=Q/A). Se barre Q y para cada uno: f (succión e impulsión, vía
Colebrook-White con ε/D=0.00117), pérdidas de succión e impulsión, HA
(brida de succión) y HB (brida de impulsión, con p2/γ). La curva de
instalación Hm(Q)=HB−HA se cruza con la curva de 2 bombas en serie
(H_serie(Q)=2·H_bomba(Q), interpolación pchip de la tabla). Resultado del
script:

```
Q_PF = 0.0114 m3/s (11.43 l/s)
H_PF por bomba = 24.21 m  (H total serie = 48.43 m)
eta_PF = 71.33 %
v_succion = v_impulsion = 1.372 m/s
f_succion = f_impulsion = 0.0221 (Re=141275, eps/D=0.0012)
Potencia por bomba = 3.806 kW
Potencia total del sistema = 7.612 kW
```

**3) Cavitación.**
NPSHdisp = HA − zA + 10.1 = **6.61 m**. NPSHr interpolado en Qpf=11.43 l/s
= **5.75 m**. Como NPSHdisp > NPSHr, **no cavita**.

**4) Longitud máxima de succión (Ltot=870 m fijo).**
El punto de funcionamiento no cambia (mismo diámetro/material en toda la
tubería, Ltot y pérdidas localizadas fijas), así que Qpf, v, f y NPSHr son
los mismos que en 2)-3). Se despeja L1 de NPSHdisp(L1) = NPSHr:

```
L1_max = 61.7 m   (=> L2 = 870 − 61.7 = 808.3 m)
```

### Resultado final

| Magnitud | Valor |
|---|---|
| Número mínimo de bombas y acople | **2 bombas en serie** |
| Q de funcionamiento | **11.43 l/s** |
| H por bomba en el PF | **24.21 m** |
| Rendimiento en el PF | **71.33 %** |
| Potencia total del sistema | **7.61 kW** |
| NPSH disponible / requerido | **6.61 m / 5.75 m → NO cavita** |
| Longitud máxima de succión | **≈61.7 m** |

### Comparación con la solución oficial

| Magnitud | Oficial | Calculado | Diferencia |
|---|---|---|---|
| Bombas/acople | 2 en serie | 2 en serie | — |
| Q_PF | 11.4 l/s | 11.43 l/s | ≈0 |
| H por bomba | 24.3 m | 24.21 m | 0.09 m |
| η_PF | 71.2 % | 71.33 % | 0.13 pp |
| f | 0.022 | 0.0221 | ≈0 |
| Potencia total | 7.61 kW | 7.612 kW | ≈0 |
| Potencia por bomba | 3.8 kW | 3.806 kW | ≈0 |
| NPSHdisp | 6.62 m | 6.61 m | 0.01 m |
| NPSHr en PF | 5.7 m | 5.75 m | 0.05 m |
| L1 máxima | 62.2 m | 61.7 m | 0.5 m |

Todos los resultados coinciden con la solución manuscrita oficial dentro
del margen esperable de lectura de tabla/interpolación gráfica vs. numérica.

---

## Pendiente en este examen

- Ejercicio 1 (FGV rectangular: clasificación M/S, caída libre, compuerta
  de fondo con a=0.35 m y a=0.6 m, resalto).
- Ejercicio 2 (delimitación de cuenca cañada Arroyo del Tala + abstracciones
  NRCS del evento observado, AMC).
- Ejercicio 3 (hipótesis del Método Racional; diseño de alcantarilla Tr=5
  años; recálculo con urbanización 25% y reducción de tc del 18%, Tr=10
  años).

---

(en progreso — continúa en la próxima corrida)
