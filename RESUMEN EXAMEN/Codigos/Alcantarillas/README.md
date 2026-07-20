# Alcantarillas (Diseño de alcantarillas, Teórico HHA §3.2)

Clasificación de Bodhaine adaptada por el curso: 6 tipos de flujo en
alcantarillas según cómo se relacionan los niveles de agua arriba (h1) y
aguas abajo (h4) con la altura/diámetro D de la alcantarilla. Los dos
tipos que aparecieron en los exámenes resueltos hasta ahora son:

- **Tipo 1** (`alcantarilla_tipo1.m`): entrada Y salida ahogadas
  (h1/D≥1 y h4/D≥1). La alcantarilla funciona como una tubería a
  presión en toda su longitud. Balance entre las secciones (1) y (4).
- **Tipo 2** (`alcantarilla_tipo2.m`): entrada ahogada (h1/D≥1.5),
  salida NO ahogada pero la alcantarilla igual fluye LLENA en toda su
  longitud ("hidráulicamente larga": pendiente baja, rugosidad alta,
  alcantarilla larga, entrada suave). Balance entre las secciones (1) y
  (3), con h3=D (la salida es un chorro a tubo lleno).
- **Tipo 3**: como el Tipo 2 pero con flujo a superficie libre
  controlado por la entrada (orificio de gran tamaño) — la
  alcantarilla es "hidráulicamente corta" (pendiente alta, rugosidad
  baja, corta, entrada de aristas afiladas). Se resuelve como orificio,
  Q=CD·A·sqrt(2g(h1-D/2)). **No implementado todavía** (no apareció aún
  con un ejemplo numérico completo en los exámenes resueltos).
- Tipos 4/5/6 (superficie libre, control por Manning/crítico dentro de
  la alcantarilla, como un canal corto): no implementados todavía.

**Cuál usar (Tipo 1 vs Tipo 2/3):** primero se verifica Tipo 1
(h1/D≥1 y h4/D≥1, ambas ahogadas). Si el tirante de salida no está
ahogado (h4/D<1) pero la entrada sigue ahogada (h1/D≥1.5), hay que
decidir entre Tipo 2 y Tipo 3 con el ábaco Fig. 3.2.5/3.2.6 del
Teórico (parámetro L/D en el eje, curvas según pendiente S0 y
r/H o forma de la embocadura) — no hay fórmula cerrada para esa
decisión, es lectura gráfica. Alcantarillas largas y de pendiente baja
(L/D grande, S0 chica) caen del lado Tipo 2; cortas y de pendiente alta,
del lado Tipo 3.

**Coeficiente de descarga CD1 (=CD2), Tabla 3.2.1** según la
terminación de la embocadura (r/D, r/a, w/D o w/a, el redondeo o
achaflanado de la entrada):

| r/D, r/a, w/D o w/a | kE1/2 | CD1(=CD2) |
|---|---|---|
| 0.00 | 0.42 | 0.84 |
| 0.02 | 0.29 | 0.88 |
| 0.06 | 0.21 | 0.91 |
| 0.08 | 0.09 | 0.96 |
| 0.10 | 0.06 | 0.97 |
| 0.12 | 0.04 | 0.98 |

(CD1 = 1/sqrt(1+kE1); interpolar si el valor de r/H no cae justo en la
tabla.)

Origen de cotas: z=0 en el zampeado (fondo) de la SALIDA de la
alcantarilla; h1, h3, h4 son cargas piezométricas medidas desde ese
datum en las secciones (1) aguas arriba, (3) salida a tubo lleno/orificio,
(4) salida con nivel de aguas abajo. Si el enunciado da el tirante "y"
en una sección referido al fondo LOCAL de esa sección (no al datum de
salida), hay que sumar/restar el desnivel de zampeado entre esa sección
y la salida (z=S0·distancia) antes de usarlo como h.

Ejemplo numérico completo: `resueltos/2020 feb 2/scripts/ej1_alcantarilla_tipo1.m`
y `ej1_evento.m` (Tipo 1 en condición de diseño, Tipo 2 en un evento
extremo con caudal mayor).
