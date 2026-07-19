"""
Ejercicio 2 - Examen HHA 25/jul/2022
Cuenca en Rocha (X=650km, Y=6200km), Area=8.3 km2, dH=45m, L=4250m,
Grupo Hidrologico C, S media cuenca=1.9%. Uso de suelo: 60% pastizales
en condiciones hidrologicas OPTIMAS ("cubierta de pasto en el 75% o mas",
Fig. 3.1.21 nota 3 = fila "Buena" de la tabla) + 40% cultivos en hileras
rectas (SR) condicion hidrologica buena. Flujo concentrado.

Replica las formulas de la planilla 'Eventos extremos.xlsx' (ver
RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md) en Python, mismo
patron que los examenes ya resueltos (ej. 2024 febrero/scripts/ej2_parte1.py).

Parte 1: Qmax y Vesc para Tr=10 anios.
Parte 2: Tr de un evento observado Qmax=19 m3/s (P5d=25mm, febrero =>
         estacion de crecimiento => corregir NC por AMC).
Parte 3: maxima area adicional de cultivo en hileras que no cambie el
         Vesc(Tr=10) de la Parte 1 en mas de un 10%, con tc fijo.
"""
import numpy as np
import math

# ---------- DATOS DE LA CUENCA ----------
Area_km2 = 8.3
dH_m = 45.0
L_m = 4250.0
L_km = L_m/1000
P310 = 74.0          # mm, isoyetas Fig 3.1.10 en X=650km,Y=6200km (Rocha) -- lectura de la solucion oficial
floor_rate = 1.2     # mm/h, infiltracion minima Grupo C (solo Grupo A usa 2.4)

# Numero de Curva (Fig. 3.1.20 del Teorico, Grupo Hidrologico C):
#   Pradera o pastizal, condicion "Buena" (nota 3: >=75% cubierta de
#   pasto = "optimas condiciones", coincide con el enunciado) -> NC=74
#   Cultivos en hileras (SR = hileras rectas), condicion Buena -> NC=85
NC_pastizal = 74
NC_cultivo  = 85
frac_pastizal_0 = 0.60
frac_cultivo_0  = 0.40
NC0 = frac_pastizal_0*NC_pastizal + frac_cultivo_0*NC_cultivo
print(f"NC ponderado (situacion original) = {frac_pastizal_0}*{NC_pastizal} + {frac_cultivo_0}*{NC_cultivo} = {NC0:.2f}")

# ---------- TIEMPO DE CONCENTRACION (Ramser-Kirpich, flujo concentrado) ----------
S_channel_pct = dH_m / L_km / 10
tc_hs = 0.4 * (L_km**0.77) / (S_channel_pct**0.385)
tc_min = tc_hs*60
print(f"S cauce principal = dH/L/10 = {dH_m}/{L_km}/10 = {S_channel_pct:.4f} %")
print(f"tc = 0.4*L^0.77/S^0.385 = {tc_hs:.4f} hs = {tc_min:.2f} min")
if tc_min < 20:
    metodo = "solo Racional"
elif tc_min <= 60:
    metodo = "AMBOS (Racional y NRCS), adoptar el MAYOR caudal"
else:
    metodo = "solo NRCS (tc>1h)"
print(f"tc={tc_hs:.2f} hs -> criterio Teorico 3.1.5: {metodo}")

# ---------- Funciones IDF Uruguay ----------
def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

def CA(d, Ac_km2):
    return 1 - (0.3549*(d**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

def NRCS_Qmax_Vesc(tc_hs, Tr, NC, Area_km2):
    """Tormenta de diseno (bloque alterno) + Pe (NC) + hidrograma unitario
    triangular SCS. Devuelve (Qmax, Vesc_m3, Pe_total_mm)."""
    CT_ = CT(Tr)
    dt = tc_hs/7
    n = np.arange(1, 13)
    d_n = dt*n
    CD_n = np.array([CD(x) for x in d_n])
    CA_n = np.array([CA(x, Area_km2) for x in d_n])
    P_n = CD_n*CT_*CA_n*P310
    M_n = np.diff(np.concatenate(([0.0], P_n)))
    order = [12,10,8,6,4,2,1,3,5,7,9,11]
    N = np.array([M_n[idx-1] for idx in order])

    S_mm = 25.4*((1000/NC)-10)
    Ia = 0.2*S_mm
    O = np.cumsum(N)
    Pe_cum = np.where(O <= Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
    Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
    deficit = np.maximum(N-Qinc, floor_rate*dt)
    Pe_corr = np.maximum(N - deficit, 0.0)
    Pe_total = Pe_corr.sum()

    tr_uh = dt
    Tp = tr_uh/2 + 0.6*tc_hs
    Tb = Tp*2.667
    qp_cm = 2.08*Area_km2/Tp
    a = (qp_cm/10)/Tp
    c = -(qp_cm/10)/(1.67*Tp)
    dd = qp_cm/10 + (qp_cm/10)/1.67
    def UH(x):
        return a*x if x < Tp else max(c*x+dd, 0.0)
    step = tr_uh/8
    Nsteps = int(math.ceil((11*tr_uh+Tb)/step)) + 40
    t = np.arange(0, Nsteps)*step
    Qtot = np.zeros_like(t)
    for k in range(12):
        shift = k*tr_uh
        Qtot += Pe_corr[k]*np.array([UH(x-shift) if x >= shift else 0.0 for x in t])

    Vesc_m3 = Pe_total*1000*Area_km2
    return Qtot.max(), Vesc_m3, Pe_total

# =====================================================================
# PARTE 1: Tr=10 anios, situacion original (NC0)
# =====================================================================
print("\n===================== PARTE 1 (Tr=10 anios) =====================")
Qmax_1, Vesc_1, Pe_1 = NRCS_Qmax_Vesc(tc_hs, 10, NC0, Area_km2)
print(f"Pe total = {Pe_1:.3f} mm")
print(f"Qmax NRCS = {Qmax_1:.2f} m3/s")
print(f"Vesc = {Vesc_1:.0f} m3")

# =====================================================================
# PARTE 2: evento observado Qmax=19 m3/s, P5d=25mm (febrero=crecimiento)
#          -> hallar Tr
# =====================================================================
print("\n===================== PARTE 2 =====================")
P5d = 25.0
# Fig 3.1.21 (estacion de CRECIMIENTO): AMC I si P5d<35.56mm
if P5d < 35.56:
    amc = "I"
elif P5d <= 53.34:
    amc = "II"
else:
    amc = "III"
print(f"P5d={P5d}mm, estacion de crecimiento (febrero) -> AMC {amc}")

if amc == "I":
    NC_evento = 4.2*NC0/(10-0.058*NC0)
elif amc == "III":
    NC_evento = 23.0*NC0/(10+0.13*NC0)
else:
    NC_evento = NC0
print(f"NC corregido (AMC {amc}) = {NC_evento:.2f}")

Qobj = 19.0
lo, hi = 2.0, 200.0
for _ in range(60):
    mid = (lo+hi)/2
    q, _, _ = NRCS_Qmax_Vesc(tc_hs, mid, NC_evento, Area_km2)
    if q < Qobj:
        lo = mid
    else:
        hi = mid
Tr_evento = (lo+hi)/2
q_check, _, _ = NRCS_Qmax_Vesc(tc_hs, Tr_evento, NC_evento, Area_km2)
print(f"Tr tal que Qmax_NRCS(NC={NC_evento:.2f}) = {Qobj} m3/s  ->  Tr = {Tr_evento:.1f} anios "
      f"(verificacion: Qmax={q_check:.3f} m3/s)")

# =====================================================================
# PARTE 3: maxima area adicional de cultivo en hileras (tc fijo) para
#          que Vesc(Tr=10) no cambie mas de 10% respecto a la Parte 1
# =====================================================================
print("\n===================== PARTE 3 =====================")
Vesc_target = 1.10*Vesc_1
print(f"Vesc objetivo = 1.10 * {Vesc_1:.0f} = {Vesc_target:.0f} m3")

def Vesc_de_frac_cultivo(frac_cultivo):
    NC_try = (1-frac_cultivo)*NC_pastizal + frac_cultivo*NC_cultivo
    _, Vesc_try, _ = NRCS_Qmax_Vesc(tc_hs, 10, NC_try, Area_km2)
    return Vesc_try

lo, hi = frac_cultivo_0, 1.0
for _ in range(60):
    mid = (lo+hi)/2
    v = Vesc_de_frac_cultivo(mid)
    if v < Vesc_target:
        lo = mid
    else:
        hi = mid
frac_cultivo_max = (lo+hi)/2
NC_max = (1-frac_cultivo_max)*NC_pastizal + frac_cultivo_max*NC_cultivo
Vesc_max = Vesc_de_frac_cultivo(frac_cultivo_max)
area_cultivo_0   = frac_cultivo_0*Area_km2
area_cultivo_max = frac_cultivo_max*Area_km2
area_aumento_max = area_cultivo_max - area_cultivo_0
print(f"Fraccion de cultivo maxima = {frac_cultivo_max*100:.2f}% (NC_ponderado={NC_max:.2f}, "
      f"Vesc={Vesc_max:.0f} m3)")
print(f"Area de cultivo original = {area_cultivo_0:.3f} km2")
print(f"Area de cultivo maxima   = {area_cultivo_max:.3f} km2")
print(f"AUMENTO MAXIMO de area cultivada = {area_aumento_max:.3f} km2 "
      f"({area_aumento_max/Area_km2*100:.2f}% del area total de la cuenca)")
