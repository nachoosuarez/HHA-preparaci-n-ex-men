"""
Ejercicio 2, Parte 2 - Examen HHA 7/jul/2020
Area maxima urbanizable (tipologia Concreto/Techo) para que el cambio de
caudal maximo (Tr=5) no supere el 15% respecto a la situacion original
(pastizales), despreciando el cambio en tc.
Formula: RESUMEN EXAMEN/Teorico/RESUMEN_TEORICO.md S B4
  "Coeficiente de escorrentia ponderado y area urbanizable maxima"
  A2 = AT*(C_target - C1)/(C2-C1) ,  C_target=(1+x)*C1
"""
Area_km2 = 7.3
C_past = 0.36   # pastizales, promedio 2-7%, Tr=5 (Tabla 3.1.4)
C_urban = 0.80  # concreto/techo, Tr=5 (Tabla 3.1.4)
x = 0.15        # incremento admisible de caudal

C_target = (1+x)*C_past
Aurb_max = Area_km2*(C_target-C_past)/(C_urban-C_past)

print(f"C_pastizal = {C_past}, C_concreto/techo = {C_urban}")
print(f"C_target = (1+{x})*{C_past} = {C_target:.4f}")
print(f"Aurb_max = AT*(C_target-C1)/(C2-C1) = {Aurb_max:.4f} km2")
print(f"          = {100*Aurb_max/Area_km2:.2f} % del area total ({Area_km2} km2)")

# Verificacion directa
Q_original_C = C_past
Q_urb_C = (C_urban*Aurb_max + C_past*(Area_km2-Aurb_max))/Area_km2
print(f"\nVerificacion: C ponderado con Aurb_max = {Q_urb_C:.4f} (debe ser {C_target:.4f})")
print(f"Aumento de Q resultante = {100*(Q_urb_C/Q_original_C-1):.2f} % (debe ser 15.00%)")
