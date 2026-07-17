"""Ejercicio2_parte2_NRCS.py — Examen HHA 1 de marzo 2024, Ejercicio 2, parte 2.

Abstracciones totales (volumen infiltrado) de un evento observado por el
metodo del Numero de Curva del NRCS, con correccion por condicion de
humedad antecedente (AMC). Formulas de
RESUMEN EXAMEN/Teorico/RESUMEN_TEORICO.md B5/B6 (no requiere la planilla
"Eventos extremos.xlsx": esa resuelve la tormenta de DISENO por bloque
alterno, mientras que aca la lluvia ya viene dada -> aplicar directo la
formula de Pe, igual que "Hoja 4" pero con la correccion AMC agregada a mano
segun indica RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md 2.e/6.9).
"""
import math

# ---- Datos del enunciado ----
bloques_mm = [14, 26, 45, 22]  # t=0-30,30-60,60-90,90-120 min
P_total = sum(bloques_mm)
P5d = 58.0  # mm, precipitacion acumulada 5 dias previos
mes = "diciembre"  # estacion de crecimiento en Uruguay (primavera-verano)

# NC(II) de Fig. 3.1.20 del Teorico: "Hierba con baja densidad y arbustos",
# Grupo Hidrologico C -> NC=71
NC_II = 71

# ---- AMC: estacion de crecimiento, P5d=58mm ----
# Umbrales (estacion de crecimiento): AMC I <35.56mm, AMC II 35.56-53.34mm, AMC III >53.34mm
if P5d > 53.34:
    amc = "III"
elif P5d < 35.56:
    amc = "I"
else:
    amc = "II"
print(f"P total del evento = {P_total} mm ; P5d = {P5d} mm ({mes}, estacion de crecimiento)")
print(f"=> Condicion de humedad antecedente: AMC {amc}")

if amc == "III":
    NC = 23.0 * NC_II / (10 + 0.13 * NC_II)
elif amc == "I":
    NC = 4.2 * NC_II / (10 - 0.058 * NC_II)
else:
    NC = NC_II
print(f"NC(II)=71 (Fig. 3.1.20, Hierba con baja densidad y arbustos, Grupo C) -> NC({amc}) = {NC:.2f}")

S = 25.4 * (1000 / NC - 10)
Ia = 0.2 * S
print(f"S = 25.4*(1000/NC-10) = {S:.2f} mm  (retencion potencial maxima)")
print(f"Ia = 0.2*S = {Ia:.2f} mm")

if P_total <= Ia:
    Pef = 0.0
    print("P <= Ia => no hay precipitacion efectiva (Pef=0)")
else:
    Pef = (P_total - Ia) ** 2 / (P_total - Ia + S)  # = (P-0.2S)^2/(P+0.8S)
    print(f"P={P_total} mm > Ia={Ia:.2f} mm => hay Pef")

Vol_inf = P_total - Pef
print(f"\nPef (precipitacion efectiva) = (P-0.2S)^2/(P+0.8S) = {Pef:.2f} mm")
print(f"Volumen infiltrado total (abstracciones totales) = P - Pef = {P_total} - {Pef:.2f} = {Vol_inf:.2f} mm")
