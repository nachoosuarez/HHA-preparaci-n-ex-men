# Examen HHA — 7 de febrero de 2019 ("2019 febrero")

Resolución paso a paso. El PDF (`EXAMENES/2019 febrero.pdf`, 7 páginas)
trae la letra completa (páginas 1-2: Ejercicios 1-4) y la solución
oficial manuscrita parcial (páginas 3, 5, 6, 7 — con la solución del
Ejercicio 1, 2, 3 y el inicio del 4), que se usa para comparar cada
resultado. La página 4 es la carta topográfica del Ejercicio 3 (no se
usa: el enunciado ya da la tabla progresiva/cota del perfil del cauce).

No confundir con "2019 febrero 2" (`EXAMENES/2019 febrero 2.pdf`), la
otra llamada de febrero de 2019 (22/feb), ya resuelta en este repo.

---

## EJERCICIO 1 — Alcantarilla de 3 tubos bajo canal trapezoidal infinito (25 puntos)

**Datos:** canal trapezoidal infinito, ancho de fondo b=4.5 m, talud
lateral 1V:2.5H (m=2.5), n=0.02, S₀=0.0007. Alcantarilla de 3 tuberías
circulares de hormigón, D=1 m, n_alc=0.013, L=15 m, apoyadas sobre el
lecho del canal (sin obra de aproximación), entrada con aristas
redondeadas r=0.02 m (r/D=0.02).

1) Caudal de diseño Qd=10 m³/s.
2) Durante una tormenta, Qt=6 m³/s.

Para cada caudal: identificar el tipo de funcionamiento de la
alcantarilla, calcular el tirante de agua inmediatamente antes de la
alcantarilla, y esquematizar el perfil de la superficie libre.

### Teoría (RESUMEN_TEORICO.md §D1, §A1)

- **D1** Clasificación de Bodhaine de alcantarillas (Tipo 1 a 6) según
  h1/D y h4/D. Como el canal es **infinito** (no hay un lago que fije
  el nivel aguas abajo), el tirante aguas abajo h4 es directamente el
  **tirante normal yn** del canal para ese caudal — no hace falta
  integrar un perfil de FGV para obtenerlo (caso particular anotado en
  §D1 punto 4).
- **A1** Clasificación M/S del canal: se compara yn (Manning) con yc
  (Froude=1, sección trapezoidal). yn>yc ⇒ canal tipo M (pendiente
  suave, régimen subcrítico normal).
- **D1** Balance de carga:
  - Tipo 1 (h4/D≥1, ambos extremos ahogados): h1 = h4 + pérdida
    localizada de entrada (CD1, Tabla 3.2.1) + pérdida distribuida
    (Manning) en la alcantarilla, todo referido al zampeado de salida.
  - Tipo 2 (h4/D<1 pero entrada ahogada, alcantarilla "hidráulicamente
    larga" — L/D=15 grande y S₀ chica, cae del lado Tipo 2 del ábaco
    Fig.3.2.5/3.2.6): igual balance pero con h3=D fijo (chorro a tubo
    lleno) en vez de h4.
- El caudal total se reparte **en partes iguales entre los 3 tubos**
  (misma geometría, mismo nivel de entrada): Q_alc = Q/3.

Cita: Teórico HHA §3.2 "Diseño de Alcantarillas" (§3.2.1, Tabla 3.2.1);
§2.5.1-2.5.2 (clasificación M/S, tirante normal y crítico);
Formulómetro "Alcantarillas" / "Flujo Uniforme (Manning)" / "Sección
Crítica".

### Herramienta y por qué

Se usó Octave, combinando el toolkit `FGV_trapezoidal` (`trap_geom`,
`eq_yn`, `eq_yc` para yn/yc del canal) con las fórmulas de balance de
carga de `RESUMEN EXAMEN/Codigos/Alcantarillas/` (`alcantarilla_tipo1.m`
y `alcantarilla_tipo2.m`), porque el ejercicio combina exactamente esos
dos bloques ya cubiertos en el resumen: clasificar el canal aguas abajo
y resolver el balance de carga de la alcantarilla según el tipo que
corresponda. No hizo falta ninguna función nueva. Script completo:
`resueltos/2019 febrero/scripts/Ejercicio1_alcantarilla.m` (con copias
locales de `trap_geom.m`, `eq_yn.m`, `eq_yc.m`).

### Paso a paso — Parte 1: Qd=10 m³/s

1. **yn y yc del canal** (b=4.5, m=2.5, n=0.02, S₀=0.0007, Q=10):
   `yn = 1.174 m`, `yc = 0.695 m` → yn>yc ⇒ **canal M** (coincide con
   la solución oficial: yn=1.17, yc=0.69, "CANAL M").
2. **h4 = yn = 1.174 m** (canal infinito, sin lago). h4/D = 1.174 ≥ 1
   ⇒ **ALCANTARILLA TIPO 1** (entrada y salida ahogadas) — "Ahogada
   sólida → Tipo 1" en la solución oficial.
3. Q_alc = 10/3 = 3.333 m³/s por tubo. CD1(r/D=0.02) = 0.88 (Tabla
   3.2.1). Rh = AT/Pm = (πD²/4)/(πD) = D/4 = 0.25 m.
4. Balance de carga Tipo 1 (referido al zampeado de salida):
   `h1 = h4 + Q_alc²/(2g·CD1²·AT²) + n_alc²·Q_alc²·L/(AT²·Rh^(4/3))`
   → **h1 = 2.6504 m**.
5. Desnivel de zampeado entrada-salida: z = S₀·L = 0.0007×15 = 0.0105 m.
   Tirante aguas arriba referido al fondo local de la entrada:
   `y1 = h1 - z = 2.6399 m` (y1/D=2.64 ≥ 1, confirma Tipo 1
   autoconsistente).
6. Como y1 > yn > yc, aguas arriba de la alcantarilla se forma una
   **curva de remanso M1** que empalma con yn lejos aguas arriba
   (extensión típica ~3000-3500 m para S₀ tan chica, según el
   esquema oficial).

**Resultado Ejercicio 1, Parte 1: alcantarilla Tipo 1, y1 = 2.64 m**
(coincide exactamente con la solución oficial: "y1=2,64m → curva M1").

### Paso a paso — Parte 2: Qt=6 m³/s

1. **yn y yc del canal** (mismo canal, Q=6): `yn = 0.898 m`,
   `yc = 0.512 m` → yn>yc ⇒ canal M (oficial: yn=0.89, yc=0.51).
2. h4 = yn = 0.898 m. h4/D = 0.898 < 1 ⇒ salida **no ahogada**. Con
   L/D=15 (alcantarilla larga) y S₀=0.0007 (pendiente baja), el ábaco
   Fig.3.2.5/3.2.6 ubica el caso del lado **Tipo 2** (fluye llena por
   fricción, chorro a la salida) — coincide con "tipo 2" en la
   solución oficial.
3. Q_alc = 6/3 = 2 m³/s por tubo. Mismo CD1=0.88, Rh=0.25 m. h3=D=1 m
   (chorro a tubo lleno).
4. Balance de carga Tipo 2:
   `h1 = h3 + Q_alc²/(2g·CD1²·AT²) + n_alc²·Q_alc²·L/(AT²·Rh^(4/3))`
   → **h1 = 1.5316 m**.
5. `y1 = h1 - z = 1.5211 m` (y1/D=1.52 ≥ 1.5, confirma Tipo 2
   autoconsistente — oficial: "h1-z=1,52 > 1,5").
6. Aguas abajo de la alcantarilla el tubo descarga como chorro a tubo
   lleno; el canal es M (subcrítico), así que el chorro pasa por un
   **resalto hidráulico** corto y vuelve al tirante normal
   yn=0.898 m lejos aguas abajo (esquema oficial: caída y ondulación
   inmediatamente después de la alcantarilla, luego vuelve a yn en
   ~2000 m).

**Resultado Ejercicio 1, Parte 2: alcantarilla Tipo 2, y1 = 1.52 m**
(coincide con la solución oficial).

---

## EJERCICIO 2, 3, 4 — pendientes

## ESTADO: EN CURSO (Ejercicio 1 resuelto; faltan 2, 3 y 4)
