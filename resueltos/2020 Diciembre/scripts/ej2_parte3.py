"""
Ejercicio 2, Parte 3 - Examen HHA 22/dic/2020 (Variante A)
Con la cuenca ya regularizada (tc_new=2.929 hs, Parte 2), ocurre el evento
extremo REGISTRADO (hietograma real, en orden cronologico, bloques de 25
min dados por el enunciado). Se pide:
3.1) Esquematizar el hidrograma del evento.
3.2) Determinar cuanto tiempo se supera el caudal de diseno (43.43 m3/s,
     Parte 1).
"""
import numpy as np
import math
import runpy

p1 = runpy.run_path('ej2_parte1.py')
p2 = runpy.run_path('ej2_parte2.py')
hidrograma_NRCS = p1['hidrograma_NRCS']
Area_km2 = p1['Area_km2']
NC = p1['NC']
S_mm = p1['S_mm']
Ia = p1['Ia']
floor_rate = p1['floor_rate']
Qmax_diseno = p1['Qmax1']
tc_new = p2['tc_new']

print(f"\n\n================ PARTE 3 ================")
dt_new = tc_new/7
print(f"dt (=tc_new/7) = {dt_new:.4f} hs = {dt_new*60:.2f} min "
      f"(coincide con el ancho de bloque del evento registrado, 25 min)")

# Hietograma REGISTRADO (enunciado, bloques de 25 min, orden cronologico)
P_obs = np.array([3,4,5,7,9,15,39,11,8,6,5,4], dtype=float)
print(f"Hietograma observado (12 bloques x 25 min): total = {P_obs.sum():.1f} mm")

O = np.cumsum(P_obs)
Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
deficit = np.maximum(P_obs-Qinc, floor_rate*dt_new)
Pe_corr = np.maximum(P_obs - deficit, 0.0)
print(f"SUMA Pe (evento real) = {Pe_corr.sum():.3f} mm")

tr_uh = dt_new
Tp = tr_uh/2 + 0.6*tc_new
Tb = Tp*2.667
qp = 0.208*Area_km2/Tp
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

# Tiempo durante el cual se supera el caudal de diseno
above = Qtot > Qmax_diseno
idx = np.where(above)[0]
if len(idx)==0:
    print(f"El evento NO supera el caudal de diseno ({Qmax_diseno:.2f} m3/s)")
else:
    i1, i2 = idx[0], idx[-1]
    t_sube = np.interp(Qmax_diseno, [Qtot[i1-1], Qtot[i1]], [t[i1-1], t[i1]])
    t_baja = np.interp(Qmax_diseno, [Qtot[i2+1], Qtot[i2]], [t[i2+1], t[i2]])
    dur_h = t_baja - t_sube
    print(f"Q supera el caudal de diseno ({Qmax_diseno:.2f} m3/s) entre t={t_sube:.3f} hs y t={t_baja:.3f} hs")
    print(f"Tiempo de superacion = {dur_h:.3f} hs = {dur_h*60:.1f} min")
