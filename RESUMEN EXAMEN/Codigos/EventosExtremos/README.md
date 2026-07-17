# Eventos Extremos — planilla elegida

Esta carpeta contiene **una sola** planilla de Excel para hidrología de eventos
extremos (método racional, hidrogramas NRCS, etc.). No es un script de Octave.

## Archivo elegido

**`EVENTOS EXTREMOS 2025.xlsx`**, copiado desde
`Scripts/01_SCRIPTS/Scripts examen AA/EVENTOS EXTREMOS 2025.xlsx`.

## Por qué esta versión y no las otras

Existían tres copias de la planilla en el repo:

| Archivo | Hojas | Tamaño |
|---|---|---|
| `Scripts/01_SCRIPTS/Eventos extremos.xlsx` | Cálculos (grande), Cálculos (chica), Horton, Hoja 4 | 114 KB |
| `Scripts/01_SCRIPTS/Scripts examen AA/Eventos extremos.xlsx` | (copia casi idéntica a la anterior) | 113 KB |
| `Scripts/01_SCRIPTS/Scripts examen AA/EVENTOS EXTREMOS 2025.xlsx` | método racional, NRCS - Grande, NRCS - Chica, 5.2 Racional, 5.2 NRCS, EJ 2 | 373 KB |

Se eligió **`EVENTOS EXTREMOS 2025.xlsx`** por dos motivos:

1. **Es la más completa**: tiene hojas separadas y ya armadas para el método
   racional y para el método NRCS (hidrograma unitario, cuenca grande y
   chica), más un ejemplo resuelto adicional (`EJ 2`), mientras que las otras
   dos copias sólo traen hojas genéricas de "Cálculos" y una hoja vacía
   (`Horton`).
2. **Es la que realmente se usó en los 4 exámenes ya resueltos** del
   repositorio (`resueltos/*/RESOLUCION.md`): en los cuatro casos
   (2024 diciembre, 2025 Febrero 1, 2025 Febrero 2, 2026 Febrero) el ejercicio
   de eventos extremos referencia explícitamente
   `Scripts examen AA/EVENTOS EXTREMOS 2025.xlsx` y sus hojas "método
   racional" / "NRCS - Gande" / "NRCS - Chica" / "5.2 Racional" / "5.2 NRCS"
   como la herramienta de cálculo, confirmando que es la versión validada y
   efectivamente utilizada en la cursada — no las otras dos.

Las otras dos copias (`Eventos extremos.xlsx`, ambas variantes) no se
copiaron a `RESUMEN EXAMEN/Codigos/` para evitar duplicados.
