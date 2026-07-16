"""Ejercicio 3 - Partes 2 y 3: Agua Disponible media de la cuenca y balance
hidrico mensual (necesidad de riego) de un cultivo de soja.

Datos de Agua Disponible (AD) por unidad de suelo: Tabla 1.4.2 del Teorico
HHA ("Agua Disponible de los suelos del Uruguay", Molfino y Califra, 2001).
Kc de soja en etapa de crecimiento medio: Tabla 1.3.3 del Teorico HHA.
"""

# Parte 2: Agua Disponible media de la cuenca (promedio ponderado por area)
AD = {
    "Cuchilla de Haedo - Paso de los Toros": {"fraccion": 0.35, "AD_mm": 21.5},
    "Itapebi - Tres Arboles": {"fraccion": 0.65, "AD_mm": 124.2},
}

AD_media = sum(u["fraccion"] * u["AD_mm"] for u in AD.values())
print(f"AD media de la cuenca = {AD_media:.1f} mm")

# Parte 3: balance hidrico del mes para el cultivo de soja
Kc = 1.15          # soja, etapa de crecimiento medio (Tabla 1.3.3)
P = 43.0           # precipitacion del mes (mm)
ETP = 105.0        # evapotranspiracion potencial del mes (mm)
frac_humedad_antecedente = 0.5   # 50% del Agua Disponible

Hi_1 = frac_humedad_antecedente * AD_media   # reserva de agua en el suelo al inicio del mes
ETC = ETP * Kc                                # evapotranspiracion del cultivo
ETR = P + Hi_1                                # agua realmente disponible para evapotranspirar
                                               # (lluvia del mes + toda la reserva del suelo)
R = ETC - ETR                                 # necesidad de riego (ETC no cubierta)

print(f"Kc (soja, crecimiento medio) = {Kc}")
print(f"Hi-1 (reserva inicial = 50% AD) = {Hi_1:.2f} mm")
print(f"ETC = ETP * Kc = {ETC:.2f} mm")
print(f"ETR = P + Hi-1 = {ETR:.2f} mm")
print(f"Necesidad de riego R = ETC - ETR = {R:.2f} mm")
