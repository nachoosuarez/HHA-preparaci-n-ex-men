# Examen HHA — 22 de marzo de 2018 (Mesa Especial)

Resolución paso a paso. Herramientas usadas: Octave (funciones de
`RESUMEN EXAMEN/Codigos/FGV_rectangular/`, copiadas a este directorio)
para el Ejercicio 1.

Hay solución oficial (manuscrita) incluida en el mismo PDF del examen
(`EXAMENES/2018 Marzo.pdf`, páginas 4, 6 y 7 para el Ej.1, Ej.2+Ej.3 y
Ej.4 respectivamente). Se cita y compara en cada ejercicio.

---

## EJERCICIO 1 (30 puntos) — Canal rectangular muy largo con caída libre y compuerta de fondo

**Enunciado (resumen):** canal rectangular "infinito" (b=6.5 m,
n=0.02, S0=0.001) que termina en una caída libre, con Q=25 m³/s.
1) Clasificar el canal (M o S) y esquematizar el perfil.
A L=3000 m aguas arriba de la caída libre se ubica una compuerta de
fondo ideal.
2) Con apertura a=0.35 m: nuevo perfil (tirantes en puntos relevantes,
   resaltos si los hay) y fuerza sobre la compuerta.
3) Se abre la compuerta a a=0.6 m: ídem perfil y fuerza.

Teoría usada: ecuación de FGV y clasificación M/S, energía específica
y tirante crítico, perfiles controlados por flujo uniforme aguas arriba
y caída libre aguas abajo (Teórico HHA §2.5.3–§2.5.4), transición por
compuerta de fondo ideal con descarga libre y ahogada (§2.2, §2.3.4,
§2.5.5) — ver `RESUMEN EXAMEN/Teorico/RESUMEN_TEORICO.md` §A4 y §A5
("Compuerta INTERIOR en canal muy largo, aguas arriba flujo uniforme
—no lago— y caída libre aguas abajo", variante sin acoplamiento de Q
porque aquí Q está dado y fijo, a diferencia del caso "lago" de 2018
diciembre donde Q debía resolverse).

### Parte 1) Caudal dado, clasificación y perfil

**Concepto.** Con el canal "infinito" (muy largo) el tirante se
establece en el normal yn en casi todo el desarrollo; sólo en el tramo
final, cerca de la caída libre, se desarrolla una curva de FGV que lleva
el tirante desde yn hasta yc (control de salida). No hace falta lago ni
compuerta para esta parte: Q=25 m³/s ya es un dato.

**Por qué esta herramienta.** Álgebra cerrada de Manning (yn) y de
tirante crítico rectangular (yc, `critico_rect.m`) — no hace falta
integrar la EDO de FGV para clasificar el canal, sólo comparar yn vs yc.

**Script:** `Ejercicio1_canal_compuerta_caidalibre.m`, sección "PARTE 1".
Entradas: `b=6.5, n=0.02, S0=0.001, Q=25`.

**Resultado:**
```
yc = 1.1471 m
yn = 2.0772 m
```
Como **yn > yc ⇒ canal tipo M** (pendiente suave/subcrítica).

**Perfil:** tirante ≈yn=2.077 m en casi todo el canal, curva **M2**
(decreciente) en el tramo final hasta yc=1.147 m justo en la caída
libre. Sin resalto.

**Comparación con la solución oficial:** coincide exactamente
(yn=2.077 m, yc=1.147 m, "CANAL M").

### Parte 2) Compuerta a=0.35 m a L=3000 m de la caída libre

**Concepto.** La compuerta ideal (sin pérdida) impone tirante
y(2)=a inmediatamente aguas abajo; aguas arriba, y(1) es el **alterno**
de a con la misma energía específica (a diferencia del caso "lago" de
2018 diciembre, aquí **no hace falta iterar en Q**: el canal es
"infinito", así que aguas arriba de la compuerta el tirante se relaja a
yn sin ninguna restricción de energía total — el único acoplamiento es
local, en la propia compuerta).

**Libre o ahogada.** Se compara el conjugado de a con el tirante de
referencia aguas abajo (yn, porque el tramo hasta la caída libre es
mucho más largo que el desarrollo de cualquier curva corta cerca de la
compuerta): conjugado(a=0.35)=2.767 m > yn=2.077 m ⇒ **descarga LIBRE**
(mismo criterio que 2018 diciembre, Ej.1 parte 2).

**Por qué esta herramienta.** Con descarga libre, aguas abajo de la
compuerta se desarrolla una curva **M3** corta (supercrítica, acelerando
desde a=0.35) hasta un tirante y3 tal que su **conjugado** (`Mom_rect.m`)
iguala yn — ahí ocurre el resalto que reconecta con el tirante normal,
que se mantiene el resto del tramo hasta la caída libre. Se ubica y3
resolviendo conjugado(y3)=yn con `fzero` (forma cerrada, sin iterar en
Q como en el caso lago) y se verifica la longitud de la curva M3
integrando la EDO (`rect.m`+`ode23`) como chequeo cruzado.

**Script:** `Ejercicio1_canal_compuerta_caidalibre.m`, sección
"PARTE 2".

**Resultado:**
```
y0 = y4 = yn = 2.0772 m   (aguas arriba lejos de la compuerta, y aguas
                           abajo del resalto hasta la caida libre)
y1 (justo aguas arriba de la compuerta, alterno de a) = 6.4932 m
y2 = a = 0.3500 m         (vena contraida, aguas abajo de la compuerta)
y3 (fin de la curva M3, antes del resalto) = 0.5526 m
   conjugado(y3) = 2.0772 m = yn  (correcto, cierra el resalto)
Longitud curva M3 (compuerta -> resalto) = 31.4 m
y5 = yc = 1.1471 m        (en la caida libre)
```

**Perfil completo (x desde la compuerta, hacia aguas abajo):**
- Aguas arriba de la compuerta (curva **M1**, remanso): desde yn=2.077 m
  muy lejos, creciendo hasta y1=6.493 m justo antes de la compuerta.
- En la compuerta: salto de y1=6.493 m a y2=a=0.35 m.
- Curva **M3** (supercrítica, creciente) de 0.35 m a 0.553 m en ~31 m.
- **Resalto** en x≈31 m aguas abajo de la compuerta: de 0.553 m a
  2.077 m (=yn).
- Tirante ≈yn=2.077 m el resto del tramo (≈2970 m) hasta cerca de la
  caída libre.
- Curva **M2** final hasta yc=1.147 m en la caída libre.

**Fuerza sobre la compuerta:** F=γ(M1−M2) (momento aguas arriba menos
aguas abajo, sección llena en y=a porque la descarga es libre).
```
M1 = 138.538 m3   (y=y1=6.4932 m)
M2 = 28.431 m3    (y=a=0.35 m)
F = gamma*(M1-M2) = 1 079 046 N = 1.079 x10^6 N
```

**Comparación con la solución oficial:** coincide muy bien — oficial
y3=0.553 m (idéntico), F≈1.08×10⁶ N (aquí 1.079×10⁶ N). El y1 oficial se
lee con dificultad en el escaneo manuscrito (parece "6.911" pero el
trazo es ambiguo); el valor recalculado aquí de forma cerrada
(alterno de a=0.35 con la misma energía específica, verificado dos
veces con `Eesp_rect.m` y a mano) da 6.493 m, consistente con el resto
de la cadena de cálculo (M1, F) que sí cierra con el oficial. La
longitud de la curva M3 no es comparable con precisión (oficial parece
decir "21.5 m" a mano alzada en un dibujo esquemático, no un cálculo
exacto; aquí se integró la EDO completa con fricción y dio 31.4 m).

### Parte 3) Se abre la compuerta a a=0.6 m

**Concepto.** Al abrir más la compuerta, el conjugado de la apertura baja
por debajo de yn: conjugado(a=0.6)=1.963 m < yn=2.077 m ⇒ **descarga
AHOGADA** (el resalto queda empujado hacia la propia compuerta, la
sumerge). Se resuelve con el método de "flujo dividido": entre la
sección contraída (área de velocidad fija Am=b·a, pero tirante
hidrostático real y2) y el tirante normal aguas abajo se conserva el
momento; entre la sección contraída y aguas arriba de la compuerta se
conserva la energía específica.

**Por qué esta herramienta.** Exactamente el caso de
`descarga_ahogada_rect.m` (ya usado en 2018 diciembre, Ej.1): se
resuelve primero el momento (M(y2,Am) = M(yn)) y después la energía
(E(y2,Am) = E(y1)), ambas en forma cerrada (sin `fsolve` para la
geometría, sólo `fzero` 1D).

**Script:** `Ejercicio1_canal_compuerta_caidalibre.m`, sección
"PARTE 3".

**Resultado:**
```
M(yn) = 18.747 m3               (momento de referencia aguas abajo)
y2 (seccion contraida, hidrostatica) = 0.8582 m
E3 = 2.9547 m  =>  y1 (aguas arriba de la compuerta) = 2.8626 m
M1 = 30.060 m3
F = gamma*(M1 - M(yn)) = 110 874 N = 0.111 x10^6 N
```

**Comparación con la solución oficial:** coincide muy bien — oficial
y2(sección contraída)=0.86 m (aquí 0.858 m), y1=2.86 m (aquí 2.863 m),
M1=30.01 m³ (aquí 30.06 m³), F=0.110×10⁶ N (aquí 0.111×10⁶ N).
Diferencias del orden del redondeo manual del examen.

---

## EJERCICIO 2 (25 puntos) + EJERCICIO 3 (25 puntos): pendientes

No resueltos en esta corrida (queda para la próxima). El Ejercicio 2
requiere delimitar la cuenca del arroyo Molles de Quinteros (Durazno) —
**la carta topográfica de este examen es un escaneo de buena calidad
que SÍ muestra el "Punto de cierre" marcado explícitamente sobre el
mapa** (a diferencia del caso de 2018 diciembre), así que es
perfectamente resoluble; sólo falta tiempo en esta corrida. El
Ejercicio 3 (alcantarillado en Artigas, NRCS+Racional+isoyetas) también
tiene datos completos y legibles.

## EJERCICIO 4 (20 puntos): pendiente

Bombeo con recirculación, tanque abierto, dos manómetros (succión
-30 kPa, impulsión +260 kPa) — datos completos y legibles en la letra y
en la solución oficial (pág. 7). Pendiente para la próxima corrida.

---

## ESTADO: EN CURSO (Ejercicio 1 completo; Ejercicios 2, 3 y 4 pendientes)
