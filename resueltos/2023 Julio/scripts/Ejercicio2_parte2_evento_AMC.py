"""
Ejercicio 2, Parte 2 - Examen HHA 24/jul/2023
Caudal maximo en el punto de cierre para el evento de precipitacion REGISTRADO
(hietograma observado, 12 bloques de 7 min), con correccion de NC por
condicion de humedad antecedente (AMC), dado que la precipitacion
acumulada en los 5 dias previos al evento fue P5d=64 mm.

Reutiliza tc, Area, y el hidrograma unitario triangular SCS calculados en
Ejercicio2_parte1_racional_NRCS.py (mismo tc: el enunciado da el
hietograma discretizado en bloques de 7 min, que coincide con
dt=tc/7=7.01 min de ese calculo).
"""
import numpy as np
import math

# ---------- Datos reutilizados de la Parte 1 ----------
d = np.load('ej2_part1.npz')
Area_km2 = float(d['Area_km2'])
tc_hs = float(d['tc_hs'])
NC_II = float(d['NC'])          # 86, condicion AMC II (tabla)
floor_rate = float(d['floor_rate'])
Tp = float(d['Tp']); Tb = float(d['Tb']); qp = float(d['qp']); tr_uh = float(d['tr_uh'])

# ---------- Hietograma OBSERVADO (dato del enunciado, orden cronologico real) ----------
# bloques de 7 min: 0-7,7-14,...,77-84
P_obs = np.array([1.9, 2.1, 2.4, 2.8, 3.7, 6.2, 15.3, 4.5, 3.2, 2.6, 2.2, 2.0])
dt = 7/60   # horas (coincide con tc/7 de la Parte 1)
P5d = 64.0  # mm, precipitacion acumulada en los 5 dias previos al evento

# ---------- Condicion de humedad antecedente (AMC) ----------
# Examen 24/jul: invierno en Uruguay => estacion INACTIVA
print("Fecha del evento: 24 de julio => estacion INACTIVA (invierno)")
print(f"P5d = {P5d} mm")
if P5d > 27.94:
    amc = "III (humedo)"
elif P5d < 12.7:
    amc = "I (seco)"
else:
    amc = "II (medio, sin correccion)"
print(f"P5d > 27.94 mm (umbral AMC III, estacion inactiva) => condicion AMC {amc}")

NC_III = 23.0*NC_II/(10+0.13*NC_II)
print(f"\nNC(II) de tabla = {NC_II}")
print(f"NC(III) = 23*NC(II)/(10+0.13*NC(II)) = {NC_III:.3f}")

# ---------- Precipitacion efectiva del evento observado (NRCS, sin bloque alterno) ----------
S_mm = 25.4*(1000/NC_III - 10)
Ia = 0.2*S_mm
print(f"\nS = 25.4*(1000/NC(III)-10) = {S_mm:.3f} mm ; Ia = 0.2*S = {Ia:.3f} mm")

O = np.cumsum(P_obs)
Pe_cum = np.where(O <= Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
deficit = np.maximum(P_obs - Qinc, floor_rate*dt)
Pe_corr = np.maximum(P_obs - deficit, 0.0)
print(f"P total del evento = {P_obs.sum():.2f} mm")
print(f"SUMA Pe (precipitacion efectiva, evento observado) = {Pe_corr.sum():.3f} mm")

Vesc_m3 = Pe_corr.sum()*1000*Area_km2
print(f"Volumen de escorrentia del evento = {Vesc_m3:.1f} m3")

# ---------- Hidrograma de crecida (convolucion con el HU triangular de la Parte 1) ----------
a = (qp/10)/Tp
c = -(qp/10)/(1.67*Tp)
dd = qp/10 + (qp/10)/1.67

def UH(x):
    return a*x if x < Tp else max(c*x+dd, 0.0)

step = tr_uh/8
Nsteps = int(math.ceil((11*tr_uh+Tb)/step)) + 40
t = np.arange(0, Nsteps)*step
Qtot = np.zeros_like(t)
for k in range(12):
    shift = k*tr_uh
    Qtot += Pe_corr[k]*np.array([UH(x-shift) if x >= shift else 0.0 for x in t])

Qmax = Qtot.max()
tQmax = t[np.argmax(Qtot)]
print(f"\nQmax del evento (hidrograma NRCS) = {Qmax:.3f} m3/s en t={tQmax:.3f} hs")
