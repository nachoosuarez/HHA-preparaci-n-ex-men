"""
Ejercicio 2, Parte 1 - Examen HHA 7/feb/2019
Caudal maximo de diseno (Tr=5 anios) de una alcantarilla en el punto de
cierre de una cuenca de Cerro Largo (X=650 km, Y=6400 km), flujo
concentrado, pastizales naturales en condicion hidrologica MALA, unidad
de suelos San Manuel (Grupo Hidrologico C).

Replica la logica de 'Eventos extremos.xlsx' (hoja 'Calculos (grande)'),
ver RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md. Los valores
P(3,10) (isoyeta), C (Tabla 3.1.4) y NC (Fig. 3.1.20) se toman de la
solucion oficial manuscrita adjunta al examen.
"""
import numpy as np
import math

# ---------- DATOS DE LA CUENCA (tabla del enunciado) ----------
Area_km2 = 5.10
dH_m = 120.0
L_m = 3600.0
L_km = L_m/1000
Tr = 5                     # anios
P310 = 80.0                # mm, isoyeta P(3h,Tr) en Cerro Largo (X=650,Y=6400) - sol. oficial
NC = 86                    # pastizales natural cond. MALA, San Manuel = Grupo Hidrologico C - sol. oficial
C_racional = 0.28          # pastizales, Tabla 3.1.4 - sol. oficial
floor_rate = 1.2           # mm/h, infiltracion minima grupos B,C,D (grupo A = 2.4 mm/h)

# ---------- TIEMPO DE CONCENTRACION (Ramser-Kirpich, flujo concentrado) ----------
S_channel_pct = dH_m / L_km / 10
tc_hs = 0.4 * (L_km**0.77) / (S_channel_pct**0.385)
tc_min = tc_hs*60
print(f"S cauce principal (Kirpich) = dH/L/10 = {dH_m}/{L_km}km/10 = {S_channel_pct:.4f} %")
print(f"tc (Ramser-Kirpich) = {tc_hs:.4f} hs = {tc_min:.2f} min")
print("20 min < tc < 1 hora => corresponde calcular AMBOS metodos (Racional y NRCS)")
print("y adoptar el MAYOR de los dos caudales (Teorico HHA 3.1.5).")

# ---------- Funciones IDF Uruguay ----------
def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr_):
    return 0.5786 - 0.4312*math.log10(math.log(Tr_/(Tr_-1)))

def CA(d, Ac_km2):
    return 1 - (0.3549*(d**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

CT5 = CT(Tr)
print(f"\nCT(Tr=5) = {CT5:.4f}")

# ============================== METODO RACIONAL ==============================
d_rac = tc_hs
CD_rac = CD(d_rac)
CA_rac = CA(d_rac, Area_km2)
P_rac = CT5*CD_rac*CA_rac*P310
i_rac = P_rac/d_rac
Ac_ha = Area_km2*100
Q_racional = C_racional*i_rac*Ac_ha/360
print("\n--- METODO RACIONAL ---")
print(f"d=tc = {d_rac:.4f} hs, CD={CD_rac:.4f}, CA={CA_rac:.4f}")
print(f"P(d,Tr,A) = {P_rac:.3f} mm ; i = {i_rac:.3f} mm/h")
print(f"Qmax racional = {Q_racional:.3f} m3/s")

# ============================== METODO NRCS ==============================
def hidrograma_NRCS(tc_h, Tr_, Area, NC_, P310_, order=None):
    """Tormenta de diseno por bloque alterno + hidrograma unitario triangular SCS."""
    if order is None:
        order = [12,10,8,6,4,2,1,3,5,7,9,11]
    S_mm = 25.4*((1000/NC_)-10)
    Ia = 0.2*S_mm
    CTv = CT(Tr_)
    dt = tc_h/7
    n = np.arange(1,13)
    d_n = dt*n
    CD_n = np.array([CD(x) for x in d_n])
    CA_n = np.array([CA(x, Area) for x in d_n])
    P_n = CD_n*CTv*CA_n*P310_
    M_n = np.diff(np.concatenate(([0.0], P_n)))
    N = np.array([M_n[idx-1] for idx in order])
    O = np.cumsum(N)
    Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
    Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
    deficit = np.maximum(N-Qinc, floor_rate*dt)
    Pe_corr = np.maximum(N - deficit, 0.0)

    tr_uh = dt
    Tp = tr_uh/2 + 0.6*tc_h
    Tb = Tp*2.667
    qp = 0.208*Area/Tp
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
    return t, Qtot, N, Pe_corr, Tp, Tb, S_mm, Ia

t1, Q1, N1, Pe1, Tp1, Tb1, S_mm1, Ia1 = hidrograma_NRCS(tc_hs, Tr, Area_km2, NC, P310)

print(f"\n--- METODO NRCS (bloque alterno, dt={tc_hs/7:.4f} hs = {tc_hs/7*60:.2f} min) ---")
print(f"S(NC={NC}) = {S_mm1:.3f} mm ; Ia=0.2S = {Ia1:.3f} mm")
for k in range(12):
    print(f"  bloque {k+1:2d}: N={N1[k]:6.3f} mm   Pe_corr={Pe1[k]:6.3f} mm")
print(f"  TOTAL tormenta = {N1.sum():.3f} mm ; TOTAL Pe = {Pe1.sum():.3f} mm")

Qmax_NRCS = Q1.max()
tQmax1 = t1[np.argmax(Q1)]
print(f"\nHidrograma unitario SCS: Tp={Tp1:.4f} hs, Tb={Tb1:.4f} hs")
print(f"Qmax NRCS (Tr={Tr}) = {Qmax_NRCS:.3f} m3/s en t={tQmax1:.3f} hs")

Vesc1 = Pe1.sum()*1000*Area_km2
print(f"Volumen de escorrentia = {Pe1.sum():.3f} mm * {Area_km2} km2 * 1000 = {Vesc1:.0f} m3")

Qmax1 = max(Q_racional, Qmax_NRCS)
metodo = "NRCS" if Qmax_NRCS > Q_racional else "RACIONAL"
print("\n=====================================================")
print(f"Qmax METODO RACIONAL = {Q_racional:.2f} m3/s")
print(f"Qmax METODO NRCS     = {Qmax_NRCS:.2f} m3/s")
print(f"=> Se adopta el MAYOR: Qmax de diseno (Tr={Tr}) = {Qmax1:.2f} m3/s ({metodo})")
