"""
Ejercicio 3, Parte 2 - Examen HHA 11/dic/2023
Evento extremo observado en julio (estacion inactiva) en la cuenca de la
canada Sin Nombre (Florida): P total=185 mm, P acumulada en los 5 dias
previos=62 mm. Suelo: unidad cartografica "Cerro Chato" (Grupo
Hidrologico B), cobertura pasturas naturales en condicion hidrologica
REGULAR (NC(II)=69, Fig. 3.1.20 del Teorico).

Se pide: volumen de escorrentia total (mm) y coeficiente de escorrentia
del evento, corrigiendo el Numero de Curva por condicion de humedad
antecedente (AMC), ya que P5d=62 mm cae en estacion inactiva (invierno).
"""

NC_II = 69.0
P5d = 62.0
P = 185.0

# ---------- Condicion de humedad antecedente (AMC), Teorico HHA Fig 3.1.21 ----------
# Julio = invierno en Uruguay = estacion INACTIVA. Umbrales (estacion inactiva):
#   AMC I   : P5d < 12.7 mm
#   AMC II  : 12.7 mm <= P5d <= 27.94 mm
#   AMC III : P5d > 27.94 mm
umbral_amc3_inactiva = 27.94
print(f"P5d = {P5d} mm > {umbral_amc3_inactiva} mm (umbral AMC III, estacion inactiva)")
print("=> Condicion de humedad antecedente AMC III (suelo humedo)")

NC_III = 23.0*NC_II/(10+0.13*NC_II)
print(f"\nNC(II) tabla = {NC_II}")
print(f"NC(III) = 23*NC(II)/(10+0.13*NC(II)) = {NC_III:.2f}")

# ---------- Precipitacion efectiva (metodo NC del NRCS) ----------
S = 25.4*(1000/NC_III - 10)
Ia = 0.2*S
print(f"\nS = 25.4*(1000/NC(III)-10) = {S:.2f} mm")
print(f"Ia = 0.2*S = {Ia:.2f} mm")

if P <= Ia:
    Pe = 0.0
    print(f"P={P} mm <= Ia => Pe=0 (no hay escorrentia)")
else:
    Pe = (P-Ia)**2/(P+0.8*S)
    print(f"P={P} mm > Ia => hay escorrentia")
    print(f"Pe = (P-Ia)^2/(P+0.8S) = {Pe:.2f} mm")

C = Pe/P
print(f"\nCoeficiente de escorrentia del evento: C = Pe/P = {Pe:.2f}/{P} = {C:.4f}")

print("\n=====================================================")
print(f"RESUMEN: NC(III)={NC_III:.1f} | Pe={Pe:.1f} mm | C={C:.2f}")
