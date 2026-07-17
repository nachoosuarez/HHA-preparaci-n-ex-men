"""
Ejercicio 2, Parte 3 - Examen HHA 2024 febrero
En las condiciones de la Parte 2 (cuenca modificada, tc_nuevo=49 min),
en julio (estacion inactiva) ocurre un evento extremo OBSERVADO (no la
tormenta de diseno por bloque alterno). Se pide verificar si supero el
caudal de diseno de la Parte 1 (72.08 m3/s).

AMC: P5d_previa=15mm, estacion inactiva -> 12.7<=15<=27.94 => AMC II
=> NC sin corregir (NC=86.5, el mismo de la Parte 1).

Se usa el hietograma YA OBSERVADO tal cual (orden cronologico real, sin
reordenar por bloque alterno), Hoja 4 de la planilla (precipitacion
efectiva por Numero de Curva, sin piso de infiltracion adicional -- ver
COMO_USAR_EVENTOS_EXTREMOS.md #4), convolucionado con el hidrograma
unitario triangular SCS de tc_nuevo=49 min (mismo Tp/Tb de la Parte 2,
porque el ancho de bloque del hietograma observado, 7 min, coincide con
dt=tc_nuevo/7=7min).
"""
import numpy as np
import math

Area_km2 = 6.3
NC = 86.5   # AMC II, sin corregir (P5d=15mm, estacion inactiva: 12.7-27.94mm)
tc_hs_nuevo = 0.8167
Qdiseno = 72.08

# Hietograma observado (Tabla del enunciado, Ej.2 parte 3), bloques de 7 min
P_obs = np.array([2.2,2.5,2.9,3.4,4.5,7.5,18.4,5.5,3.9,3.1,2.7,2.4])
dt = 7/60  # hs
print(f"Hietograma observado (12 bloques de {dt*60:.0f} min): {P_obs}")
print(f"Total precipitado = {P_obs.sum():.1f} mm")

# --- precipitacion efectiva, metodo NC puro (Hoja 4, sin piso de infiltracion) ---
S_mm = 25.4*(1000/NC - 10)
Ia = 0.2*S_mm
Pac = np.cumsum(P_obs)
Pe_ac = np.where(Pac<=Ia, 0.0, (Pac-Ia)**2/(Pac+0.8*S_mm))
Pe_inc = np.diff(np.concatenate(([0.0], Pe_ac)))
print(f"\nS = {S_mm:.3f} mm ; Ia = {Ia:.3f} mm")
print("bloque  P_obs   P_acum  Pe_acum  Pe_inc")
for k in range(12):
    print(f"  {k+1:2d}   {P_obs[k]:5.1f}  {Pac[k]:6.2f}  {Pe_ac[k]:6.3f}  {Pe_inc[k]:6.3f}")
Pe_total = Pe_inc.sum()
print(f"SUMA Pe = {Pe_total:.3f} mm")

# --- hidrograma unitario triangular SCS con tc_nuevo (Parte 2) ---
tr_uh = dt
Tp = tr_uh/2 + 0.6*tc_hs_nuevo
Tb = Tp*2.667
qp_cm = 2.08*Area_km2/Tp
a = (qp_cm/10)/Tp
c = -(qp_cm/10)/(1.67*Tp)
dd = qp_cm/10 + (qp_cm/10)/1.67
print(f"\nTp={Tp:.4f} hs, Tb={Tb:.4f} hs, qp={qp_cm/10:.4f} m3/s/mm")

def UH(x):
    return a*x if x<Tp else max(c*x+dd, 0.0)

step = tr_uh/8
Nsteps = int(math.ceil((11*tr_uh+Tb)/step)) + 40
t = np.arange(0, Nsteps)*step
Qtot = np.zeros_like(t)
for k in range(12):
    shift = k*tr_uh
    Qtot += Pe_inc[k]*np.array([UH(x-shift) if x>=shift else 0.0 for x in t])

Qmax_evento = Qtot.max()
tQmax = t[np.argmax(Qtot)]
print(f"\nQmax evento observado = {Qmax_evento:.2f} m3/s en t={tQmax:.2f} hs")

print("\n=====================================================")
print(f"Q diseno alcantarilla (Parte 1) = {Qdiseno:.2f} m3/s")
print(f"Q evento julio (observado)      = {Qmax_evento:.2f} m3/s")
if Qmax_evento > Qdiseno:
    print("=> El evento SUPERA la capacidad de diseno de la alcantarilla.")
else:
    print("=> El evento NO supera la capacidad de diseno de la alcantarilla.")

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
fig, ax = plt.subplots(figsize=(7,4))
ax.plot(t, Qtot, 'b-', lw=2, label='Q evento julio')
ax.axhline(Qdiseno, color='r', ls='--', label=f'Q diseno = {Qdiseno:.1f} m3/s')
ax.set_xlabel('t (hs)'); ax.set_ylabel('Q (m3/s)')
ax.set_title('Ejercicio 2, Parte 3: hidrograma del evento observado vs. capacidad de diseno')
ax.legend()
plt.tight_layout()
plt.savefig('ej2_hidrograma_parte3.png', dpi=110)
print("\nGrafico: ej2_hidrograma_parte3.png")
