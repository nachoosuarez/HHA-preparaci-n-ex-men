"""
Ejercicio 2, Parte 3 - Examen HHA 7/feb/2019
Ya en las condiciones de la Parte 2 (uso de suelo mixto, NC=83.4;
tc reducido 8%), se registra un evento extremo en febrero (hietograma
observado de 12 bloques de 5 min). La precipitacion de los 5 dias
anteriores fue P5d=38 mm. Se pide el caudal generado por el evento y si
supera el caudal de diseno de la alcantarilla (29.72 m3/s, Parte 1).

Reutiliza NC_new, tc_new, Area_km2, floor_rate de ej2_parte2.py/ej2_parte1.py.
"""
import numpy as np
import math
import runpy

p2 = runpy.run_path('ej2_parte2.py')
NC_new = p2['NC_new']
tc_new = p2['tc_new']
Area_km2 = p2['Area_km2']
floor_rate = p2['p1']['floor_rate']
Qmax_diseno = p2['Qmax_diseno']

print("\n\n================ PARTE 3 ================")

# ---------- Condicion de humedad antecedente (AMC) ----------
P5d = 38.0   # mm, precipitacion de los 5 dias previos al evento
mes = "febrero"
# Umbrales AMC, estacion de CRECIMIENTO (primavera-verano en Uruguay; RESUMEN_TEORICO.md B6):
# AMC I < 35.56 mm ; AMC II 35.56-53.34 mm ; AMC III > 53.34 mm
if P5d < 35.56:
    amc = "I (seco) -> HABRIA que corregir NC"
elif P5d <= 53.34:
    amc = "II (medio) -> NC sin corregir"
else:
    amc = "III (humedo) -> HABRIA que corregir NC"
print(f"P5d={P5d} mm, {mes} (estacion de CRECIMIENTO) => condicion AMC {amc}")
print(f"=> NC se mantiene en {NC_new:.2f} (el de la Parte 2, uso de suelo mixto)")

# ---------- Hietograma observado (12 bloques de 5 min, dato del enunciado) ----------
P_obs = np.array([1.8,2.0,2.2,2.7,6.0,12.0,19.0,8.0,5.0,2.4,2.1,1.8])
dt_obs = 5/60  # hs, ancho de cada bloque observado
print(f"\nHietograma observado (12 bloques x 5 min): total = {P_obs.sum():.2f} mm")

S_mm = 25.4*((1000/NC_new)-10)
Ia = 0.2*S_mm
O = np.cumsum(P_obs)
Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
deficit = np.maximum(P_obs-Qinc, floor_rate*dt_obs)
Pe_corr = np.maximum(P_obs - deficit, 0.0)
print(f"S(NC={NC_new:.2f})={S_mm:.3f} mm, Ia={Ia:.3f} mm, SUMA Pe (evento real) = {Pe_corr.sum():.3f} mm")
for k in range(12):
    print(f"  bloque {k+1:2d} (t={5*k}-{5*(k+1)} min): P={P_obs[k]:5.2f} mm   Pe_corr={Pe_corr[k]:6.3f} mm")

# ---------- Hidrograma unitario triangular SCS ----------
# El pulso del HU se toma con el ancho del propio hietograma observado (5 min,
# el dato disponible), y Tp/Tb/qp con el tc de la Parte 2 (uso de suelo ya mixto).
tr_uh = dt_obs
Tp = tr_uh/2 + 0.6*tc_new
Tb = Tp*2.667
qp = 0.208*Area_km2/Tp
print(f"\nHidrograma unitario SCS (tc={tc_new:.4f} hs, tr={tr_uh*60:.1f} min): Tp={Tp:.4f} hs, Tb={Tb:.4f} hs, qp={qp:.4f} m3/s/mm")

def UH(x):
    if x < 0: return 0.0
    if x <= Tp: return qp*x/Tp
    if x <= Tb: return qp*(Tb-x)/(Tb-Tp)
    return 0.0

step = tr_uh/8
Nsteps = int(math.ceil((11*tr_uh+Tb)/step)) + 40
t = np.arange(0, Nsteps)*step
Qtot = np.zeros_like(t)
for k in range(12):
    shift = k*tr_uh
    Qtot += Pe_corr[k]*np.array([UH(x-shift) for x in t])

Qmax_evento = Qtot.max()
tQmax = t[np.argmax(Qtot)]
print(f"\nQmax generado por el evento REGISTRADO = {Qmax_evento:.3f} m3/s en t={tQmax:.3f} hs")

print("\n=====================================================")
print(f"Qmax evento extremo (NRCS, hietograma observado) = {Qmax_evento:.2f} m3/s")
print(f"Qmax de diseno de la alcantarilla (Parte 1)       = {Qmax_diseno:.2f} m3/s")
if Qmax_evento > Qmax_diseno:
    print(f"=> {Qmax_evento:.2f} > {Qmax_diseno:.2f} m3/s: el evento SUPERA el caudal de diseno de la alcantarilla")
else:
    print(f"=> {Qmax_evento:.2f} <= {Qmax_diseno:.2f} m3/s: el evento NO supera el caudal de diseno")
