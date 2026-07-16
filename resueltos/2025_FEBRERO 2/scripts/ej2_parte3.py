"""
Ejercicio 2, Parte 3 - Examen HHA 5/feb/2025 (2025_FEBRERO 2)
Desarrollo Forestal sobre el 25% de la cuenca: reduce el tc de TODA la
cuenca en un 10%, y el NC pasa a ser un promedio ponderado por area entre
el uso actual (pastizales regular, NC=69, 75% del area) y el forestal
(NC=82, 25% del area). Recalcula Qmax (Tr=10), volumen de escorrentia y el
hidrograma, y compara con la Parte 1/2 (condicion actual).
"""
import numpy as np
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

d0 = np.load('part1.npz')   # resultados de la condicion actual (Partes 1 y 2)

Area_km2 = float(d0['Area_km2'])
P310 = float(d0['P310'])
tc_hs_old = float(d0['tc_hs'])
NC_old = float(d0['NC'])
floor_rate = 1.2

# ---------- Nuevo tc: reduccion del 10% por el desarrollo forestal ----------
tc_hs = 0.90*tc_hs_old
tc_min = tc_hs*60
print(f"tc actual = {tc_hs_old:.4f} hs")
print(f"tc nuevo  = 0.90 * tc actual = {tc_hs:.4f} hs = {tc_min:.2f} min")

# ---------- Nuevo NC: promedio ponderado por area ----------
frac_forestal = 0.25
NC_forestal = 82
NC = (1-frac_forestal)*NC_old + frac_forestal*NC_forestal
print(f"NC = {1-frac_forestal:.2f}*{NC_old:.0f} + {frac_forestal:.2f}*{NC_forestal} = {NC:.2f}")

# el tc sigue > 1h => sigue sin corresponder el metodo Racional, se usa NRCS
print(f"tc={tc_hs:.2f} hs > 1 hora => sigue sin corresponder el metodo Racional; se usa NRCS")

def CD(dur):
    if dur <= 3:
        return 0.6208*dur/((dur+0.0137)**0.5639)
    else:
        return 1.0287*dur/((dur+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

def CA(dur, Ac_km2):
    return 1 - (0.3549*(dur**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

Tr = 10
CT10 = CT(Tr)

dt = tc_hs/7
n = np.arange(1,13)
d_n = dt*n
CD_n = np.array([CD(x) for x in d_n])
CA_n = np.array([CA(x, Area_km2) for x in d_n])
P_n = CD_n*CT10*CA_n*P310
M_n = np.diff(np.concatenate(([0.0], P_n)))

order = [12,10,8,6,4,2,1,3,5,7,9,11]
N = np.array([M_n[idx-1] for idx in order])
print(f"\nTormenta de diseño total = {N.sum():.3f} mm (duracion {12*dt:.3f} hs = {12*dt*60:.1f} min)")

S_mm = 25.4*((1000/NC)-10)
Ia = 0.2*S_mm
print(f"S = {S_mm:.3f} mm ; Ia = {Ia:.3f} mm")

O = np.cumsum(N)
Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
deficit = np.maximum(N-Qinc, floor_rate*dt)
Pe_corr = np.maximum(N - deficit, 0.0)
print(f"SUMA Pe corregido = {Pe_corr.sum():.3f} mm")

Vesc_m3 = Pe_corr.sum()*1000*Area_km2
print(f"\nVolumen de escorrentia (desarrollo forestal) = {Vesc_m3:.0f} m3")

tr_uh = dt
Tp = tr_uh/2 + 0.6*tc_hs
Tb = Tp*2.667
qp = 2.08*Area_km2/Tp
a = (qp/10)/Tp
c = -(qp/10)/(1.67*Tp)
dd = qp/10 + (qp/10)/1.67
print(f"Tp(unitario)={Tp:.4f} hs, Tb(unitario)={Tb:.4f} hs, qp={qp:.4f} m3/s/cm")

def UH(x):
    return a*x if x<Tp else max(c*x+dd, 0.0)

step = tr_uh/8
Nsteps = int(math.ceil((11*tr_uh+Tb)/step)) + 40
t = np.arange(0, Nsteps)*step
Qtot = np.zeros_like(t)
for k in range(12):
    shift = k*tr_uh
    Qtot += Pe_corr[k]*np.array([UH(x-shift) if x>=shift else 0.0 for x in t])

Qmax = Qtot.max()
tQmax = t[np.argmax(Qtot)]
print(f"\nQmax (desarrollo forestal, Tr=10) = {Qmax:.3f} m3/s en t={tQmax:.3f} hs")

# ---------- Comparacion con la condicion actual (Parte 1/2) ----------
t0 = d0['t']; Q0 = d0['Qtot']
Qmax0 = float(d0['Qmax_NRCS']); tQmax0 = float(d0['tQmax']); Vesc0 = float(d0['Vesc_m3'])

print("\n===================== COMPARACION =====================")
print(f"{'':30s}{'Actual':>15s}{'Forestal 25%':>18s}")
print(f"{'Qmax (m3/s)':30s}{Qmax0:15.2f}{Qmax:18.2f}")
print(f"{'tiempo pico (hs)':30s}{tQmax0:15.2f}{tQmax:18.2f}")
print(f"{'Volumen escorrentia (m3)':30s}{Vesc0:15.0f}{Vesc_m3:18.0f}")
print("=========================================================")
if Qmax > Qmax0 and tQmax < tQmax0:
    print("=> El desarrollo forestal AUMENTA el caudal pico y lo ADELANTA en el "
          "tiempo (cuenca responde mas rapido: menor tc concentra el mismo/mayor "
          "volumen de escorrentia en menos tiempo).")

np.savez('part3.npz', t=t, Qtot=Qtot, Qmax=Qmax, tQmax=tQmax, Vesc_m3=Vesc_m3,
          tc_hs=tc_hs, NC=NC)

# ---------- Grafico comparativo ----------
plt.figure(figsize=(9,5))
plt.plot(t0, Q0, 'b-', linewidth=2, label=f'Actual (Qp={Qmax0:.1f} m3/s, tp={tQmax0:.2f} hs)')
plt.plot(t, Qtot, 'g-', linewidth=2, label=f'Forestal 25% (Qp={Qmax:.1f} m3/s, tp={tQmax:.2f} hs)')
plt.plot(tQmax0, Qmax0, 'bo', markersize=7)
plt.plot(tQmax, Qmax, 'go', markersize=7)
plt.xlabel('t (hs) desde el inicio de la tormenta de diseño')
plt.ylabel('Q (m3/s)')
plt.title('Ejercicio 2 Parte 3 - Comparacion hidrogramas: actual vs. desarrollo forestal (25%)')
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.savefig('ej2_hidrograma_parte3.png', dpi=120)
print("\nGrafico guardado en ej2_hidrograma_parte3.png")
