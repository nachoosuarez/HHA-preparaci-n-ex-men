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

## EJERCICIO 2 — Hidrograma unitario NRCS y período de retorno de un evento (25 puntos)

**Datos:** cuenca en Velázquez, departamento de Rocha (X=625, Y=6240
km). Área=5.2 km², ΔH=62 m, L(cauce)=4600 m, Grupo Hidrológico C, uso de
suelo "hierbas con baja densidad y arbustos", S cuenca=5.5% (pendiente
**media de la cuenca**, no se usa en este ejercicio porque no se pide
método Racional). Evento extremo: P=32 mm uniforme sobre la cuenca, en
duración efectiva D=15 min, flujo concentrado.

### Teoría (RESUMEN_TEORICO.md §B2, B3, B5, B6)

- **B2** Tiempo de concentración, Ramser-Kirpich (flujo concentrado):
  `tc = 0.4·L^0.77/S^0.385` (L en km, S en % **del cauce principal**
  =ΔH/L/10 — no confundir con la "S cuenca" de la tabla del enunciado,
  que no interviene acá).
- **B5** Método NRCS — caso de **un único pulso de lluvia con duración
  efectiva dada directamente** (no tormenta de diseño por bloque
  alterno): el HU triangular se calcula con esa D real
  (tp=D/2+0.6·tc, tb=8/3·tp, Qp=0.208·A/tp por mm de Pe) y el
  hidrograma resultante es ese único triángulo escalado por el Pe de
  todo el evento.
- **B6** Condición de humedad antecedente: "condiciones antecedentes
  húmedas" (dato explícito del enunciado) ⇒ AMC III ⇒
  `NC(III)=23·NC(II)/(10+0.13·NC(II))`.
- **B3** Curvas IDF de Uruguay: para invertir el Tr de un evento
  registrado que cae sobre **toda la cuenca** (no un dato puntual), se
  incluye CA(A,d) igual que en la tormenta de diseño:
  `CT_objetivo = P/(P310·CD(d)·CA(A,d))`, invirtiendo `CT(Tr)` por
  bisección.

Cita: Teórico HHA §3.1.2 (tc), §3.1.4 (IDF), §3.1.5 b) (NC/AMC/Pe),
§3.1.6 (HU triangular SCS); Formulómetro "Tiempo de Concentración" /
"Eventos extremos — IDF" / "Método NRCS" / "Hidrograma Unitario".

### Herramienta y por qué

Se resolvió con un script Python (`ej2_HU_NRCS_Tr.py`), replicando
directamente las fórmulas cerradas del Formulómetro (Kirpich, NC/Pe,
HU triangular SCS, IDF de Uruguay con inversión de CT por bisección),
en vez de la planilla `Eventos extremos.xlsx`: el ejercicio da un
**único** pulso de lluvia con su propia duración efectiva (no pide
armar una tormenta de diseño con el mecanismo de bloque alterno de 12
sub-intervalos que sí automatiza la hoja `Cálculos (grande)`), así que
alcanza con las fórmulas cerradas de tc, NC/Pe y HU triangular
aplicadas una sola vez, sin necesidad de la maquinaria de 12 filas de
la planilla. Script:
`resueltos/2019 febrero 2/scripts/ej2_HU_NRCS_Tr.py`.

### Paso a paso

**Parte 1) Hidrograma unitario: definición e hipótesis**

*Definición:* el hidrograma unitario de una cuenca es el hidrograma de
escorrentía directa resultante de una unidad (1 mm) de exceso de lluvia
(precipitación efectiva) generada uniformemente sobre el área de la
cuenca a una tasa constante a lo largo de una duración efectiva D.

*Hipótesis básicas:*
1. La precipitación efectiva tiene intensidad constante dentro de D.
2. Está uniformemente distribuida en toda el área de drenaje.
3. El tiempo base del hidrograma de escorrentía directa (HED) es
   constante para una duración D dada.
4. Las ordenadas de todos los HED de una base de tiempo común son
   directamente proporcionales al volumen total de escorrentía directa.
5. Para una cuenca dada, el HED de un exceso de lluvia dado refleja las
   características no cambiantes de la cuenca.

**Parte 2) Hidrograma unitario triangular (D=15 min)**

Tiempo de concentración (Ramser-Kirpich, S del cauce principal=ΔH/L/10):

```
S = 62/4.6/10 = 1.3478 %
tc = 0.4·4.6^0.77/1.3478^0.385 = 1.1547 h (≈69.3 min)
```

Parámetros del HU triangular (D=15 min=0.25 h):

```
tp = D/2 + 0.6·tc = 0.125 + 0.6928 = 0.8178 h
tb = 8/3·tp = 2.1809 h
Qp (por mm de Pe) = 0.208·5.2/0.8178 = 1.3225 m³/s/mm
```

**Resultado: tp = 0.82 h, tb = 2.18 h, Qp = 1.32 m³/s por mm de Pe**
(oficial: tp=0.82 h, tb=2.18 h, Qp=1.32 m³/s/mm — coincide exacto).

**Parte 3) Hidrograma resultante (condiciones antecedentes húmedas)**

Uso de suelo "hierbas con baja densidad y arbustos", Grupo C ⇒
NC(II)=71 (tabla NRCS). Condiciones antecedentes húmedas ⇒ **AMC III**:

```
NC(III) = 23·71/(10+0.13·71) = 84.92
S = 25.4·(1000/84.92-10) = 45.107 mm  ;  Ia = 0.2·S = 9.021 mm
P=32 mm > Ia  =>  Pe = (32-9.021)²/(32+0.8·45.107) = 7.755 mm
```

Como en el HED se mantienen los mismos tp/tb del HU (un único pulso):

```
Qp,evento = Pe · Qp,unitario = 7.755 · 1.3225 = 10.256 m³/s
```

**Resultado: Qp = 10.26 m³/s** (oficial: NC(III)=84.9, Pe=7.8 mm,
Qp=10.3 m³/s — coincide).

**Parte 4) Período de retorno del evento**

P(3,10)=76 mm (leído de la Fig. 3.1.10, isoyetas de Uruguay, en el
punto X=625, Y=6240 km). Con d=D=0.25 h y A=5.2 km² (el evento se trata
como lluvia caída sobre toda la cuenca, no un dato puntual, por lo que
CA debe incluirse — ver RESUMEN_TEORICO.md §B3, ítem "CA se incluye si
el evento es sobre TODA la cuenca"):

```
CD(0.25h) = 0.3291  ;  CA(5.2 km², 0.25h) = 0.9810
CT_objetivo = 32/(76·0.3291·0.9810) = 1.3042
```

Invirtiendo CT(Tr)=1.3042 por bisección:

**Resultado: Tr ≈ 48.7 años** (oficial: Tr=49 años — coincide, redondeando
al entero).

Todos los resultados numéricos de este ejercicio coinciden con la
solución oficial manuscrita.

---

## ESTADO: EN CURSO (faltan Ejercicios 3 y 4)
