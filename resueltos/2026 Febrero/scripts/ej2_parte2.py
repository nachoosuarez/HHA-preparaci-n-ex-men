"""
Ejercicio 2, Parte 2 - Examen HHA 3/feb/2026
2.1) Periodo de retorno de la intensidad maxima del evento registrado.
2.2) Caudal maximo durante el evento (NRCS, AMC segun P acumulada 5 dias previos).
2.3) Verificacion de si se supera la capacidad de diseño (Qdis=66.28 m3/s, ej2_parte1.py)
     y por cuanto tiempo.
Reutiliza las funciones IDF (CT,CD,CA) y el hidrograma unitario triangular SCS
de ej2_parte1.py (mismo tc, misma cuenca).
"""
import numpy as np, math

def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)
def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))
def CA(d, Ac_km2):
    return 1 - (0.3549*(d**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

P310=98.0
Area_km2=8.9
tc_hs=0.8178153734880262   # from parte1 (recomputado abajo para no depender de import)
L_km=3.715; dH_m=80.0
S_channel_pct = dH_m/L_km/10
tc_hs = 0.4*(L_km**0.77)/(S_channel_pct**0.385)

# ---------------- 2.1: Periodo de retorno de la intensidad maxima ----------------
print("=== 2.1 ===")
d = 7/60  # hs
P_obs = 24.0  # mm, bloque max (35-42 min)
CD7 = CD(d)
CA7 = CA(d, Area_km2)  # ver si CA=1 (pluviometro puntual) o con reduccion por area
print(f"d={d:.4f} hs, CD={CD7:.4f}, CA(area)={CA7:.4f}  [se usa CA=1, dato puntual de pluviometro]")
CT_needed = P_obs/(P310*CD7*1.0)
print(f"CT necesario = {CT_needed:.4f}")
# invertir CT(Tr)=0.5786-0.4312*log10(ln(Tr/(Tr-1))) -> Tr por bisección
def f(Tr):
    return CT(Tr)-CT_needed
# bisección manual
lo,hi=1.001,1000
for _ in range(200):
    mid=(lo+hi)/2
    if (f(lo))*(f(mid))<=0:
        hi=mid
    else:
        lo=mid
Tr_sol=(lo+hi)/2
print(f"Tr = {Tr_sol:.3f} años")
for Trc in [14,15]:
    print(f"  check Tr={Trc}: P = {P310*CD7*CT(Trc):.2f} mm")

# ---------------- 2.2: Qmax durante el evento observado ----------------
print("\n=== 2.2 ===")
NC=80  # AMC II: 38mm cae en 35.56-53.34mm (rango 'estacion de crecimiento' AMC II) -> no se corrige
S_mm = 25.4*((1000/NC)-10)
Ia = 0.2*S_mm
print(f"S={S_mm:.3f} mm, Ia={Ia:.3f} mm  (verificacion AMC: P5d=38mm esta en [35.56,53.34]mm -> AMC II, NC=80 sin corregir)")

P_storm = np.array([1,3,7,10,12,24,10,8,5,3,1,1], dtype=float)
dt_obs = 7/60  # hs
O = np.cumsum(P_storm)
Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
floor_rate=1.2
deficit = np.maximum(P_storm-Qinc, floor_rate*dt_obs)
Pe_corr = np.maximum(P_storm-deficit, 0.0)
print("bloque  P    Pacum   Pe_acum  Pe_inc  deficit  Pe_corr")
for i in range(12):
    print(f"{i+1:5d} {P_storm[i]:5.1f} {O[i]:7.2f} {Pe_cum[i]:8.3f} {Qinc[i]:7.3f} {deficit[i]:7.3f} {Pe_corr[i]:7.3f}")
print("suma Pe_corr =", Pe_corr.sum())

tr_uh = tc_hs/7
Tp = tr_uh/2+0.6*tc_hs
Tb = Tp*2.667
qp = 2.08*Area_km2/Tp
a=(qp/10)/Tp; c=-(qp/10)/(1.67*Tp); dd=qp/10+(qp/10)/1.67
def UH(x):
    if x<0: return 0.0
    return a*x if x<Tp else max(c*x+dd,0.0)

step = tr_uh/8
Nsteps = int(math.ceil((11*dt_obs+Tb)/step))+80
t = np.arange(0,Nsteps)*step
Qtot = np.zeros_like(t)
for k in range(12):
    shift = k*dt_obs
    Qtot += Pe_corr[k]*np.array([UH(x-shift) for x in t])

Qmax = Qtot.max(); tQmax=t[np.argmax(Qtot)]
print(f"tr_uh={tr_uh:.4f} hs, Tp={Tp:.4f}, Tb={Tb:.4f}, qp={qp:.4f}")
print(f"Qmax evento = {Qmax:.3f} m3/s en t={tQmax:.3f} hs")

# ---------------- 2.3: tiempo en que se supera la capacidad de diseño ----------------
print("\n=== 2.3 ===")
Qdis = 66.28
over = Qtot>Qdis
idxs=np.where(over)[0]
if len(idxs):
    Tini=t[idxs[0]]
    Tfin=t[idxs[-1]]
    print(f"Se supera Qdis={Qdis} desde t={Tini:.3f} hs hasta t={Tfin:.3f} hs -> duracion={Tfin-Tini:.3f} hs = {(Tfin-Tini)*60:.1f} min")
else:
    print("no se supera")
