"""
Ejercicio 2, Parte 1 - Examen HHA 5/feb/2025 (2025_FEBRERO 2)
Caudal maximo de diseño de la alcantarilla, Tr=10 años, uso de suelo actual
(pastizales, condicion hidrologica regular).
Replica exacta de las formulas de 'Scripts examen AA/EVENTOS EXTREMOS 2025.xlsx'
(hojas 'metodo racional' y 'NRCS - Gande'), adaptadas a los datos de la cuenca
de este examen (Tabla: Area=8.0 km2, dH=90m, L=5500m, Grupo B, S=3.2%).
"""
import numpy as np
import math

# ---------- DATOS DE LA CUENCA (Tabla del enunciado) ----------
Area_km2 = 8.0
dH_m = 90.0
L_m = 5500.0
L_km = L_m/1000
S_basin_pct = 3.2       # pendiente media de la cuenca (uso: tabla C del metodo racional, si aplicara)
Grupo_Hidrologico = 'B'
Tr = 10                  # anios
P310 = 90.0              # mm, leido de isoyetas (Fig 3.1.10) en X=382.5km,Y=6408.5km (Rio Negro)
NC = 69                  # pastizales, condicion hidrologica regular, grupo B (Fig 3.1.20)
floor_rate = 1.2         # mm/h, infiltracion minima grupos B,C,D (grupo A = 2.4 mm/h)

# ---------- TIEMPO DE CONCENTRACION (Kirpich / Ramser-Kirpich) ----------
# S del canal principal (para Kirpich) = dH(m)/L(km)/10  -- DISTINTO de la
# pendiente media de la cuenca (3.2%), que en este ejercicio no llega a usarse
# porque, como se ve abajo, el metodo racional queda descartado.
S_channel_pct = dH_m / L_km / 10
tc_hs = 0.4 * (L_km**0.77) / (S_channel_pct**0.385)
tc_min = tc_hs*60
print(f"S canal principal (Kirpich) = {S_channel_pct:.4f} %")
print(f"tc = {tc_hs:.4f} hs = {tc_min:.2f} min")

# ---------- JUSTIFICACION DEL METODO (Teorico HHA, Cap. 3.1.5) ----------
# El metodo Racional se desaconseja para tc > 1 hora (supone tormenta de
# intensidad constante, valido solo para cuencas pequenas de respuesta
# rapida). Aca tc=1.23 hs > 1 h => NO corresponde el metodo Racional:
# se debe usar el metodo NRCS (intensidad variable, tormenta de diseño +
# Numero de Curva + hidrograma unitario sintetico triangular SCS).
print(f"\ntc={tc_hs:.2f} hs > 1 hora => el metodo Racional NO es aplicable")
print("(Teorico HHA Cap 3.1.5: desaconsejado para tc>1h). Se usa el metodo NRCS.")

# ---------- Funciones IDF Uruguay (Rodriguez Fontal 1980 / Genta et al 1998) ----------
def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

def CA(d, Ac_km2):
    return 1 - (0.3549*(d**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

CT10 = CT(Tr)
print(f"CT(Tr=10) = {CT10:.4f}")

# =====================================================================
# METODO NRCS (bloque alterno + NC + hidrograma unitario triangular SCS)
# =====================================================================
dt = tc_hs/7  # ancho de cada bloque (12 bloques -> duracion total = 12*tc/7 = 1.71*tc)
n = np.arange(1,13)
d_n = dt*n
CD_n = np.array([CD(x) for x in d_n])
CA_n = np.array([CA(x, Area_km2) for x in d_n])
P_n = CD_n*CT10*CA_n*P310          # precipitacion acumulada para duracion d_n
M_n = np.diff(np.concatenate(([0.0], P_n)))   # incrementos M1..M12

# metodo del bloque alterno: pico al centro (slot 7), alternando L/R
order = [12,10,8,6,4,2,1,3,5,7,9,11]   # slot k -> indice n (1-based) de M
N = np.array([M_n[idx-1] for idx in order])   # tormenta de diseño ordenada en el tiempo (12 bloques)

print("\n--- TORMENTA DE DISEÑO (bloque alterno, Delta t = tc/7 = %.4f hs = %.2f min) ---" % (dt, dt*60))
for k in range(12):
    print(f"  bloque {k+1:2d}: {N[k]:6.3f} mm")
print(f"  TOTAL tormenta = {N.sum():.3f} mm  (duracion total = {12*dt:.3f} hs = {12*dt*60:.1f} min)")

# --- precipitacion efectiva (metodo NC del NRCS) ---
S_mm = 25.4*((1000/NC)-10)
Ia = 0.2*S_mm
print(f"\nS = {S_mm:.3f} mm ; Ia = 0.2S = {Ia:.3f} mm")

O = np.cumsum(N)  # tormenta acumulada
Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))   # Pe incremental (metodo NC puro)
deficit = np.maximum(N-Qinc, floor_rate*dt)        # piso de infiltracion (grupo B=1.2mm/h)
Pe_corr = N - deficit                              # "Pe corregido" (el que se convoluciona)
Pe_corr = np.maximum(Pe_corr, 0.0)

print("\n--- PRECIPITACION EFECTIVA POR BLOQUE ---")
for k in range(12):
    print(f"  bloque {k+1:2d}: tormenta={N[k]:6.3f}  Pe_NC_inc={Qinc[k]:6.3f}  deficit={deficit[k]:6.3f}  Pe_corregido={Pe_corr[k]:6.3f}")
print(f"  SUMA Pe corregido = {Pe_corr.sum():.3f} mm  (SUMA Pe NC puro = {Pe_cum[-1]:.3f} mm)")

# --- volumen de escorrentia (m3): 1mm sobre 1km2 = 1000 m3 ---
Vesc_m3 = Pe_corr.sum()*1000*Area_km2
print(f"\nVolumen de escorrentia = {Vesc_m3:.1f} m3")

# --- hidrograma unitario sintetico triangular SCS ---
tr_uh = dt
Tp = tr_uh/2 + 0.6*tc_hs
Tb = Tp*2.667
qp = 2.08*Area_km2/Tp   # m3/s por cm
a = (qp/10)/Tp
c = -(qp/10)/(1.67*Tp)
dd = qp/10 + (qp/10)/1.67
print(f"\n--- HIDROGRAMA UNITARIO TRIANGULAR SCS ---")
print(f"tr={tr_uh:.4f} hs, Tp={Tp:.4f} hs, Tb={Tb:.4f} hs, qp={qp:.4f} m3/s/cm")

def UH(x):
    return a*x if x<Tp else max(c*x+dd, 0.0)

# malla temporal fina: paso tr/8, suficientes puntos para cubrir la duracion total
step = tr_uh/8
Nsteps = int(math.ceil((11*tr_uh+Tb)/step)) + 40
t = np.arange(0, Nsteps)*step
Qtot = np.zeros_like(t)
for k in range(12):
    shift = k*tr_uh
    Qtot += Pe_corr[k]*np.array([UH(x-shift) if x>=shift else 0.0 for x in t])

Qmax_NRCS = Qtot.max()
tQmax = t[np.argmax(Qtot)]
print(f"\nQmax NRCS (hidrograma) = {Qmax_NRCS:.3f} m3/s  en t = {tQmax:.3f} hs (tiempo pico desde inicio de la tormenta)")

print("\n=====================================================")
print(f"Qmax de diseño (Tr=10, metodo NRCS, unico aplicable) = {Qmax_NRCS:.2f} m3/s")
print(f"Volumen de escorrentia del evento = {Vesc_m3:.0f} m3")

np.savez('part1.npz', t=t, Qtot=Qtot, Pe_corr=Pe_corr, N=N, tc_hs=tc_hs, dt=dt,
          Tp=Tp, Tb=Tb, qp=qp, Qmax_NRCS=Qmax_NRCS, tQmax=tQmax, Vesc_m3=Vesc_m3,
          Area_km2=Area_km2, P310=P310, NC=NC, S_mm=S_mm, Ia=Ia)
