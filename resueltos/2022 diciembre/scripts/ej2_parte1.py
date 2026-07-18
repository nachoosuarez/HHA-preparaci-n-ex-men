"""
Ejercicio 2, Parte 1 - Examen HHA 15/dic/2022
Caudal maximo de diseno (Tr=10 anios) y volumen de escorrentia del punto
de cierre de una cuenca en Maldonado (X=552 km, Y=6150 km), flujo
concentrado, pastizales en condicion hidrologica MALA, Grupo Hidrologico D.

Replica la logica de 'Eventos extremos.xlsx' (hoja 'Calculos (grande)'),
ver RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md. Los valores base
P(3,10) (isoyeta), C (Tabla 3.1.4) y NC (Fig. 3.1.20) se toman de la
solucion oficial manuscrita adjunta al examen.
"""
import numpy as np
import math

# ---------- DATOS DE LA CUENCA (tabla del enunciado) ----------
Area_km2 = 7.6
dH_m = 130.0
L_m = 3265.0
L_km = L_m/1000
S_basin_pct = 5.9        # pendiente media de la cuenca (Tabla 3.1.4, para C)
Tr = 10                   # anios
P310 = 76.0               # mm, isoyeta P(3h,Tr=10) en Maldonado (X=552,Y=6150) - sol. oficial
NC = 89                   # pastizales cond. MALA, Grupo Hidrologico D (Fig 3.1.20) - sol. oficial
C_racional = 0.38         # pastizales, S "promedio 2-7%" (Tabla 3.1.4)
floor_rate = 1.2          # mm/h, infiltracion minima grupos B,C,D (grupo A = 2.4 mm/h)

# ---------- TIEMPO DE CONCENTRACION (Ramser-Kirpich) ----------
S_channel_pct = dH_m / L_km / 10
tc_hs = 0.4 * (L_km**0.77) / (S_channel_pct**0.385)
tc_min = tc_hs*60
print(f"S cauce principal (Kirpich) = {S_channel_pct:.4f} %")
print(f"tc = {tc_hs:.4f} hs = {tc_min:.2f} min")
print(f"\ntc={tc_min:.1f} min: 20 min < tc < 1 hora => corresponde calcular")
print("AMBOS metodos (Racional y NRCS) y adoptar el MAYOR de los dos caudales (Teorico HHA 3.1.5).")

def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr_):
    return 0.5786 - 0.4312*math.log10(math.log(Tr_/(Tr_-1)))

def CA(d, Ac_km2):
    return 1 - (0.3549*(d**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

CT10 = CT(Tr)
print(f"\nCT(Tr=10) = {CT10:.4f} (=1 por definicion, caso base)")

# ============================== METODO RACIONAL ==============================
d_rac = tc_hs
CD_rac = CD(d_rac)
CA_rac = CA(d_rac, Area_km2)
P_rac = CT10*CD_rac*CA_rac*P310
i_rac = P_rac/d_rac
Ac_ha = Area_km2*100
Q_racional = C_racional*i_rac*Ac_ha/360
print("\n--- METODO RACIONAL ---")
print(f"d=tc = {d_rac:.4f} hs, CD={CD_rac:.4f}, CA={CA_rac:.4f}")
print(f"P(d,10,A) = {P_rac:.3f} mm ; i = {i_rac:.3f} mm/h")
print(f"Qmax racional = {Q_racional:.3f} m3/s")

# ============================== METODO NRCS ==============================
dt = tc_hs/7
n = np.arange(1,13)
d_n = dt*n
CD_n = np.array([CD(x) for x in d_n])
CA_n = np.array([CA(x, Area_km2) for x in d_n])
P_n = CD_n*CT10*CA_n*P310
M_n = np.diff(np.concatenate(([0.0], P_n)))

order = [12,10,8,6,4,2,1,3,5,7,9,11]   # bloque alterno, pico al centro
N = np.array([M_n[idx-1] for idx in order])
print(f"\n--- TORMENTA DE DISENO (bloque alterno, dt={dt:.4f} hs = {dt*60:.2f} min) ---")
print(f"TOTAL tormenta = {N.sum():.3f} mm  (duracion = {12*dt:.3f} hs)")

S_mm = 25.4*((1000/NC)-10)
Ia = 0.2*S_mm
print(f"S = {S_mm:.3f} mm ; Ia = 0.2S = {Ia:.3f} mm")

O = np.cumsum(N)
Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
deficit = np.maximum(N-Qinc, floor_rate*dt)
Pe_corr = np.maximum(N - deficit, 0.0)
print(f"SUMA Pe corregido = {Pe_corr.sum():.3f} mm")
Vesc_m3 = Pe_corr.sum()*1000*Area_km2
print(f"Volumen de escorrentia (Tr=10) = {Vesc_m3:.1f} m3")

tr_uh = dt
Tp = tr_uh/2 + 0.6*tc_hs
Tb = Tp*2.667
qp = 0.208*Area_km2/Tp
print(f"\n--- HIDROGRAMA UNITARIO TRIANGULAR SCS ---")
print(f"tr={tr_uh:.4f} hs, Tp={Tp:.4f} hs, Tb={Tb:.4f} hs, qp={qp:.4f} m3/s por mm de Pe")

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

Qmax_NRCS = Qtot.max()
tQmax = t[np.argmax(Qtot)]
print(f"\nQmax NRCS (hidrograma) = {Qmax_NRCS:.3f} m3/s en t={tQmax:.3f} hs")

Qmax_diseno = max(Q_racional, Qmax_NRCS)
metodo = "NRCS" if Qmax_NRCS>Q_racional else "RACIONAL"
print("\n=====================================================")
print(f"Qmax METODO RACIONAL = {Q_racional:.2f} m3/s")
print(f"Qmax METODO NRCS     = {Qmax_NRCS:.2f} m3/s")
print(f"=> Se adopta el MAYOR: Qmax de diseno (Tr=10) = {Qmax_diseno:.2f} m3/s ({metodo})")

np.savez('ej2_part1.npz', Area_km2=Area_km2, dH_m=dH_m, L_km=L_km, tc_hs=tc_hs,
         P310=P310, NC=NC, C_racional=C_racional, floor_rate=floor_rate,
         S_mm=S_mm, Ia=Ia, dt=dt, Tp=Tp, Tb=Tb, qp=qp, tr_uh=tr_uh,
         Q_racional=Q_racional, Qmax_NRCS=Qmax_NRCS, Pe_corr=Pe_corr, N=N)
