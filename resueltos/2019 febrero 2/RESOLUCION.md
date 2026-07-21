# Examen HHA — 22 de febrero de 2019 ("2019 febrero 2")

Resolución paso a paso. El PDF (`EXAMENES/2019 febrero 2.pdf`, 11
páginas) trae la letra completa (páginas 1-2: Ejercicios 1-4), la carta
topográfica del Ejercicio 3 (página 3, zona Tacuarembó/Cuchilla Mendoza)
y la solución oficial manuscrita completa (páginas 4-11), que se usa
para comparar cada resultado.

No confundir con "2019 febrero" (`EXAMENES/2019 febrero.pdf`), la otra
llamada de febrero de 2019, aún sin resolver en este repo.

Herramientas: Octave (toolkit canónico de
`RESUMEN EXAMEN/Codigos/FGV_trapezoidal/`, copiado sin modificar a
`scripts/` de este examen) para el Ejercicio 1.

---

## EJERCICIO 1 — Lago que descarga a canal trapezoidal con escalón de fondo (30 puntos)

**Datos:** canal trapezoidal, ancho de fondo b=3.5 m, talud lateral
1V:2H (m=2), n=0.01, S₀=0.015, longitud total L=450 m hasta una caída
libre. Lo alimenta un lago con nivel hLago=1.5 m sobre el fondo del
canal en la entrada. En la Parte 2, a x=40 m del inicio el fondo se
**eleva** (escalón) Δz=0.5 m y luego continúa con la pendiente original.

### Teoría (RESUMEN_TEORICO.md §A1, A2, A3, A4, A5)

- **A1** Clasificación M/S: se compara yn (Manning) con yc (Froude=1).
- **A4** "Control crítico en la entrada, sección TRAPEZOIDAL (sin forma
  cerrada)": en canal trapezoidal yc(Q) no tiene forma cerrada, así que
  se anida un `fzero` externo en Q alrededor del `fsolve` interno en yc
  hasta que yc(Q) + Q²/(2g·A(yc)²) = hLago.
- **A5** Escalón de fondo (transición suave, sin pérdidas): E1=E2+D.
  `Dmax = E1 − Ec` es la altura máxima que no altera el tirante aguas
  arriba; si D>Dmax el escalón "ahoga" la sección (remanso subcrítico
  aguas arriba, con E1_nuevo=Ec+D), pasa crítico en la cresta y se
  acelera a supercrítico aguas abajo, hasta reconectar por un
  **resalto hidráulico** con el perfil que viene de aguas arriba.
- **A3** Resalto: se ubica comparando, en la misma malla de x, el
  **conjugado** (`Mom_trap`) de la rama supercrítica que viene del lago
  contra la rama subcrítica que retrocede desde el escalón.

Cita: Teórico HHA §2.2 (energía/transiciones), §2.3.2-2.3.3
(conjugados/resalto), §2.5.3 (control crítico), §2.5.5-2.5.6
(transiciones de fondo); Formulómetro "Flujo Gradualmente Variado" /
"Energía" / "Cantidad de Movimiento".

### Herramienta y por qué

Se usó Octave con el toolkit `FGV_trapezoidal` (`trap_geom`, `eq_yc`,
`eq_yn`, `control_critico_lago_trap`, `rect.m`+`ode23`+`critico.m` para
integrar los perfiles, `Mom_trap` para el conjugado del resalto,
`alternos_trap` para los tirantes alternos de la energía post-escalón)
porque el problema es exactamente el caso de uso central de ese
toolkit: un lago con control crítico en la entrada de un canal tipo S,
y un escalón de fondo que puede ahogar la sección y generar un resalto.
No se necesitaron funciones nuevas — es una combinación directa de A4
("control crítico, sección trapezoidal") y A5 ("escalón de fondo") ya
cubiertas en el resumen teórico. Script completo:
`resueltos/2019 febrero 2/scripts/Ejercicio1_FGV_trapezoidal_lago_escalon.m`.

**Nota numérica importante:** la EDO de FGV es singular en y=yc
(1−Fr²=0). Integrando la curva S2 desde el arranque con las tolerancias
por defecto de `ode23`, el primer tramo (muy cerca de yc) se resuelve
con paso demasiado grueso y da un tirante visiblemente distinto más
adelante (y(40 m) salía ≈0.69 m en vez de ≈0.724 m, con un efecto en
cascada sobre Dmax y la conclusión de si el escalón ahoga o no la
sección). Usando `odeset('RelTol',1e-10,'AbsTol',1e-12)` el resultado
converge y coincide con la solución oficial. **Regla práctica: cualquier
integración de FGV que arranque en yc (control crítico) necesita
tolerancias de `ode23`/`ode45` bastante más finas que el default.**

### Paso a paso

**Parte 1) Caudal de descarga y clasificación**

Se prueba la hipótesis "canal tipo S (steep)": el lago descarga el
caudal máximo compatible con su energía, con flujo crítico en la
entrada (x=0). En sección trapezoidal yc(Q) no tiene forma cerrada, así
que se itera Q (`control_critico_lago_trap.m`) hasta que:

```
E(yc) = yc + Q²/(2g·A(yc)²) = hLago
```

```
Q  = 17.556 m³/s
yc = 1.1024 m  (Ec = 1.5000 m = hLago, por construcción)
yn = 0.5509 m  (Manning, S₀=0.015)
```

yn < yc ⇒ **canal tipo S (steep)** — hipótesis autoconsistente (coincide
con lo escrito en la solución oficial: "Supongo canal S... verifico
canal S").

**Resultado: Q = 17.56 m³/s** (oficial: 17.56 m³/s — coincide exacto).

Perfil: y=yc=1.102 m en x=0, curva **S2** (supercrítica, decreciente)
hasta y=0.553 m en x=450 m (≈yn=0.551 m, caída libre). Sin resaltos.

**Parte 2) Escalón de fondo Δz=0.5 m en x=40 m**

Se evalúa, sobre la curva S2 "natural" (sin escalón) de la Parte 1, el
tirante y la energía específica que trae el flujo al llegar a x=40 m:

```
y_natural(x=40 m) = 0.7239 m  ->  E_natural = 1.9496 m
Ec = 1.5000 m           (energía crítica, mismo Q — igual a hLago por A4)
Dmax = E_natural − Ec = 1.9496 − 1.5000 = 0.4496 m
```

Como Δz=0.5 m > Dmax=0.45 m, **el escalón ahoga la sección**: aparece un
remanso subcrítico aguas arriba con nueva energía (referida al fondo
original, antes del escalón) E2=Ec+Δz=2.000 m. Resolviendo con
`alternos_trap` los tirantes con esa energía:

```
y2 (aguas arriba del escalón, subcrítico) = 1.9209 m
y3 (cresta del escalón, fondo ya elevado) = yc = 1.1024 m   (control crítico local)
```

Aguas abajo de la cresta el canal es idéntico al de la Parte 1 (mismo
Q, b, m, n, S₀), sólo con el fondo desplazado +0.5 m: se integra una
nueva curva S2 local desde y=yc en la cresta hasta el final del canal,
llegando a y(450 m)=0.554 m (≈yn, caída libre) — **sin ningún resalto
adicional aguas abajo del escalón**.

Aguas arriba del escalón, la curva subcrítica (y2=1.9209 m en x=40 m)
se integró **hacia atrás** hasta encontrar el cruce de su **conjugado**
(`Mom_trap`) con la curva S2 natural que viene del lago:

```
x_resalto = 13.04 m
y (rama S2, supercrítica, antes del resalto)  = 0.8437 m
y (rama subcrítica, después del resalto)      = 1.3999 m
chequeo momentum: M(0.8437)=8.8248  ≈  M(1.3999)=8.8212   (coincide, <0.1%)
```

El remanso queda a sólo 13 m del lago (bastante antes de la entrada en
x=0), por lo que **no llega a afectar la entrada**: el caudal que
descarga el lago sigue siendo el de la Parte 1, **Q = 17.56 m³/s**.

**Perfil completo (Parte 2):** y=yc=1.102 m en x=0 → curva S2 hasta
y=0.844 m en x=13.04 m → **resalto** (0.844→1.400 m) → curva subcrítica
creciente hasta y2=1.921 m en x=40 m (base del escalón) → escalón:
y3=yc=1.102 m en la cresta (fondo +0.5 m) → nueva curva S2 local
decreciendo hasta y=0.554 m en x=450 m (caída libre).

Comparación con la solución oficial manuscrita:

| Magnitud | Oficial | Este cálculo |
|---|---|---|
| Q (Parte 1) | 17.56 m³/s | 17.556 m³/s |
| yc | 1.102 m | 1.1024 m |
| yn | 0.551 m | 0.5509 m |
| y_natural(x=40 m) | 0.724 m | 0.7239 m |
| E_natural(x=40 m) | 1.95 m | 1.9496 m |
| Dmax | 0.45 m | 0.4496 m |
| E2 = Ec+Δz | 2.0 m | 2.0000 m |
| y2 (aguas arriba del escalón) | 1.82 m* | 1.9209 m |
| x del resalto | ≈13.3 m | 13.04 m |
| y supercrítico en el resalto | ≈0.841 m | 0.8437 m |
| y subcrítico en el resalto | ≈1.405 m | 1.3999 m |

(*) La solución oficial anota y2=1.82 m, pero ese valor da E(1.82
m)=1.913 m con `trap_geom` — no coincide con la propia E2=2.0 m que la
misma solución calcula un renglón antes. El valor y2=1.9209 m obtenido
acá sí verifica exactamente E(y2)=2.000 m, y es plenamente consistente
con el resto de la cadena (Dmax, x del resalto y tirantes del resalto,
que coinciden con la solución oficial dentro de 2 cm/0.3 m). Se atribuye
la diferencia a un error de lectura/redondeo en el cálculo manual
(posible confusión de cifra en la letra manuscrita, "1.82" vs "1.92").

---

## ESTADO: EN CURSO (faltan Ejercicios 2, 3 y 4)
