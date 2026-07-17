"""
Examen HHA - Julio 2024 - Ejercicio 2
Cuenca del arroyo Molles de Quinteros (Durazno).
Parte 2: cota superior/inferior del cauce principal, desnivel maximo,
tiempo de concentracion (Ramser-Kirpich, flujo concentrado).
Parte 3: periodo de retorno de la intensidad maxima de precipitacion
registrada en un evento observado (bloques horarios), usando las curvas
IDF de Uruguay (CD por duracion, CT por Tr) replicadas de
"Scripts/01_SCRIPTS/Eventos extremos.xlsx" (ver
RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md) - mismas formulas
que en resueltos/2024 diciembre/scripts/ej2_parte1.py.
"""
import math

# ---------------------------------------------------------------------
# Parte 2: tiempo de concentracion
# ---------------------------------------------------------------------
L_km = 6.875     # km, longitud del cauce principal (dato del enunciado)
Hsup = 120.0     # m, cota superior del cauce principal (lectura de la carta)
Hinf = 88.0      # m, cota inferior del cauce principal (lectura de la carta)
dH = Hsup - Hinf
S_pct = dH / L_km / 10.0   # % , pendiente del cauce principal = dH(m)/L(km)/10
tc = 0.4 * L_km**0.77 / S_pct**0.385   # Ramser-Kirpich, tc en horas

print("--- PARTE 2 ---")
print(f"Cota superior del cauce principal Hsup = {Hsup:.1f} m")
print(f"Cota inferior del cauce principal Hinf = {Hinf:.1f} m")
print(f"Desnivel maximo del cauce principal dH = {dH:.1f} m")
print(f"Pendiente del cauce principal S = dH/L/10 = {S_pct:.4f} %")
print(f"tc (Ramser-Kirpich) = 0.4*L^0.77/S^0.385 = {tc:.4f} hs = {tc*60:.1f} min")

# ---------------------------------------------------------------------
# Parte 3: periodo de retorno de la intensidad maxima registrada
# ---------------------------------------------------------------------
P310 = 86.0   # mm, P(3,10) leida en la isoyeta sobre la cuenca (dato oficial)

# hietograma observado, bloques horarios (mm caidos en cada hora)
P_bloques = {"0-1": 5, "1-2": 10, "2-3": 35, "3-4": 45, "4-5": 68,
             "5-6": 54, "6-7": 48, "7-8": 41, "8-9": 23, "9-10": 8}

Pmax = max(P_bloques.values())
d_h = 1.0   # duracion del bloque (h)
imax = Pmax / d_h

def CD(d):
    """Coeficiente de correccion por duracion (Uruguay), d en horas."""
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT_from_Tr(Tr):
    """Coeficiente de correccion por periodo de retorno."""
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

def Tr_from_CT(CT_target, lo=1.0001, hi=1000.0, it=200):
    """Invierte CT(Tr) por biseccion (CT es creciente con Tr)."""
    for _ in range(it):
        mid = (lo+hi)/2
        if CT_from_Tr(mid) < CT_target:
            lo = mid
        else:
            hi = mid
    return (lo+hi)/2

CDv = CD(d_h)
CT_necesario = Pmax / (P310*CDv)
Tr = Tr_from_CT(CT_necesario)

print("\n--- PARTE 3 ---")
print(f"Bloque de mayor precipitacion: 4-5 hs, Pmax = {Pmax} mm (d = {d_h} h)")
print(f"Intensidad maxima registrada: imax = Pmax/d = {imax:.1f} mm/h")
print(f"CD(d=1h) = {CDv:.4f}")
print(f"P(d=1h,Tr,puntual) = P310*CD*CT = Pmax  =>  CT necesario = {CT_necesario:.4f}")
print(f"Tr (invirtiendo CT(Tr)) = {Tr:.2f} anios  =>  se adopta Tr = {round(Tr)} anios")
