"""
Examen HHA - 13/feb/2020 - Ejercicio 2
Cuenca en Maldonado (X=590 km, Y=6200 km): 65% pastizales cond.
hidrologica mala + 35% cultivo agricola por curvas de nivel cond.
hidrologica buena, suelo San Carlos (grupo hidrologico C), flujo
concentrado.
Mismas formulas que resueltos/2024 Julio/scripts/ej3.py (IDF Uruguay +
NRCS con hidrograma unitario triangular SCS), reutilizadas y adaptadas
para: (1) Metodo Racional + NRCS con Tr=10 anios; (2) inversion de Tr
dado un caudal de disenio; (3) reemplazo de la tormenta de diseno por
un evento REAL (hietograma medido, sin reordenar por bloque alterno).
"""
import math
import numpy as np

# --- datos de la cuenca ---
Area_km2 = 8.35
Lcp_km = 5.15
dHcp_m = 158.0
P310 = 76.0   # mm, isoyeta en X=590,Y=6200 (dato de la solucion oficial)

def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT_from_Tr(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

def CA(d, Ac_km2):
    return 1 - (0.3549*(d**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

def tc_kirpich(L_km, dH_m):
    S_pct = dH_m/L_km/10.0
    return 0.4*L_km**0.77/S_pct**0.385, S_pct

tc_hs, Scp_pct = tc_kirpich(Lcp_km, dHcp_m)
print(f"tc (Kirpich) = {tc_hs:.4f} hs = {tc_hs*60:.1f} min ; Scp = {Scp_pct:.2f}%")
print("20 min < tc < 1 h => se calculan Racional y NRCS, se adopta el mayor\n")

# =====================================================================
# Parte 1a: Metodo Racional (Tr=10 anios)
# =====================================================================
def racional(Tr, C, A_km2, tc_hs):
    d = tc_hs
    P = P310*CT_from_Tr(Tr)*CD(d)*CA(d, A_km2)
    i = P/d
    Q = C*i*(A_km2*100)/360
    return Q, i, P

C_pastizal_mala_plano = 0.30   # Tabla 3.1.4, Pastizales, Plano 0-2%, Tr=10
C_cultivo_buena_plano = 0.36   # Tabla 3.1.4, Areas de cultivo, Plano 0-2%, Tr=10
C_pond = 0.65*C_pastizal_mala_plano + 0.35*C_cultivo_buena_plano
Q_racional, i10, P10 = racional(10, C_pond, Area_km2, tc_hs)
print(f"--- Parte 1: Metodo Racional (Tr=10) ---")
print(f"C ponderado = 0.65*{C_pastizal_mala_plano}+0.35*{C_cultivo_buena_plano} = {C_pond:.3f}")
print(f"P(d=tc,Tr=10)={P10:.2f} mm, i={i10:.2f} mm/h -> Qmax = {Q_racional:.2f} m3/s\n")

# =====================================================================
# Parte 1b: Metodo NRCS (Numero de Curva ponderado + HU triangular SCS)
# =====================================================================
NC_pastizal_mala = 86     # San Carlos = grupo hidrologico C, pastizal cond. mala
NC_cultivo_buena = 82     # grupo C, cultivo en curvas de nivel cond. buena
NC_pond = 0.65*NC_pastizal_mala + 0.35*NC_cultivo_buena
print(f"NC ponderado = 0.65*{NC_pastizal_mala}+0.35*{NC_cultivo_buena} = {NC_pond:.2f}\n")

def hidrograma_diseno_NRCS(Area_km2, tc_hs, NC, Tr, P310, floor_rate=1.2):
    """Tormenta de diseno por bloque alterno (12 bloques, dt=tc/7)."""
    CTr = CT_from_Tr(Tr)
    dt = tc_hs/7
    n = np.arange(1, 13)
    d_n = dt*n
    CD_n = np.array([CD(x) for x in d_n])
    CA_n = np.array([CA(x, Area_km2) for x in d_n])
    P_n = CD_n*CTr*CA_n*P310
    M_n = np.diff(np.concatenate(([0.0], P_n)))
    order = [12,10,8,6,4,2,1,3,5,7,9,11]
    N = np.array([M_n[idx-1] for idx in order])
    return hidrograma_convolucion(N, dt, Area_km2, tc_hs, NC, floor_rate)

def hidrograma_convolucion(N, dt, Area_km2, tc_hs, NC, floor_rate=1.2):
    """Convoluciona una serie de precipitacion N (mm, en intervalos dt,
    EN ORDEN CRONOLOGICO) con el HU triangular SCS, usando NC para la
    precipitacion efectiva incremental (retencion NRCS)."""
    S_mm = 25.4*(1000/NC - 10)
    Ia = 0.2*S_mm
    O = np.cumsum(N)
    Pe_cum = np.where(O <= Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
    Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
    deficit = np.maximum(N-Qinc, floor_rate*dt)
    Pe_corr = np.maximum(N-deficit, 0.0)

    Tp = dt/2 + 0.6*tc_hs
    Tb = Tp*2.667
    qp = 2.08*Area_km2/Tp   # m3/s por cm (SCS estandar)

    def UH(x):
        a = (qp/10)/Tp
        c = -(qp/10)/(1.67*Tp)
        dd = qp/10 + (qp/10)/1.67
        return a*x if x < Tp else max(c*x+dd, 0.0)

    nblocks = len(N)
    step = dt/8
    Nsteps = int(math.ceil(((nblocks-1)*dt+Tb)/step)) + 40
    t = np.arange(0, Nsteps)*step
    Qtot = np.zeros_like(t)
    for k in range(nblocks):
        shift = k*dt
        Qtot += Pe_corr[k]*np.array([UH(x-shift) if x >= shift else 0.0 for x in t])

    Qmax = Qtot.max()
    tQmax = t[np.argmax(Qtot)]
    return dict(t=t, Q=Qtot, Qmax=Qmax, tQmax=tQmax, Tp=Tp, Tb=Tb, Pe=Pe_corr.sum(), S=S_mm)

res_NRCS_10 = hidrograma_diseno_NRCS(Area_km2, tc_hs, NC_pond, 10, P310)
print(f"--- Parte 1: Metodo NRCS (Tr=10) ---")
print(f"S={res_NRCS_10['S']:.2f} mm, Tp={res_NRCS_10['Tp']:.3f} h, Tb={res_NRCS_10['Tb']:.3f} h")
print(f"Qmax = {res_NRCS_10['Qmax']:.2f} m3/s en t={res_NRCS_10['tQmax']:.3f} h\n")

Qadoptado = max(Q_racional, res_NRCS_10['Qmax'])
print(f"=> Se adopta el MAYOR: Qmax = {Qadoptado:.2f} m3/s ({'NRCS' if Qadoptado==res_NRCS_10['Qmax'] else 'Racional'})\n")

# =====================================================================
# Parte 2: hallar Tr tal que el hidrograma NRCS de Qmax=62 m3/s
# =====================================================================
print("--- Parte 2: periodo de retorno de una obra disenada para 62 m3/s ---")
for Tr in [15, 19.5, 20]:
    r = hidrograma_diseno_NRCS(Area_km2, tc_hs, NC_pond, Tr, P310)
    print(f"Tr={Tr:5.1f} anios -> Qmax = {r['Qmax']:.2f} m3/s")

def Qmax_of_Tr(Tr):
    return hidrograma_diseno_NRCS(Area_km2, tc_hs, NC_pond, Tr, P310)['Qmax'] - 62.0

# busqueda simple por biseccion (evita depender de scipy)
lo, hi = 5.0, 100.0
flo, fhi = Qmax_of_Tr(lo), Qmax_of_Tr(hi)
for _ in range(60):
    mid = (lo+hi)/2
    fm = Qmax_of_Tr(mid)
    if (fm>0) == (flo>0):
        lo, flo = mid, fm
    else:
        hi, fhi = mid, fm
Tr_62 = (lo+hi)/2
print(f"\nTr exacto para Qmax=62 m3/s -> Tr = {Tr_62:.2f} anios\n")

# =====================================================================
# Parte 3: evento REAL de febrero de 2019 (hietograma medido, orden
# cronologico, NO bloque alterno)
# =====================================================================
print("--- Parte 3: evento observado (feb/2019), verificacion de sobrepaso ---")
dt_obs = 0.13   # h, igual a los intervalos de la tabla del enunciado
P_obs = np.array([2.7, 3.0, 3.4, 4.1, 5.3, 8.9, 21.9, 6.5, 4.6, 3.7, 3.2, 2.8])
print(f"P total observada = {P_obs.sum():.1f} mm en {len(P_obs)*dt_obs:.2f} h")

res_obs = hidrograma_convolucion(P_obs, dt_obs, Area_km2, tc_hs, NC_pond)
print(f"Tp={res_obs['Tp']:.4f} h, Tb={res_obs['Tb']:.4f} h, Pe total={res_obs['Pe']:.2f} mm")
print(f"Qmax = {res_obs['Qmax']:.2f} m3/s en t = {res_obs['tQmax']:.3f} h")

Qdiseno_obra = 62.0
over = res_obs['Q'] > Qdiseno_obra
if over.any():
    t_over = res_obs['t'][over]
    t_ini, t_fin = t_over[0], t_over[-1]
    print(f"\nLa alcantarilla (Qdiseno={Qdiseno_obra} m3/s) es SOBREPASADA")
    print(f"desde t={t_ini:.3f} h hasta t={t_fin:.3f} h  "
          f"(duracion = {(t_fin-t_ini)*60:.1f} minutos)")
else:
    print(f"\nLa alcantarilla NO es sobrepasada (Qmax={res_obs['Qmax']:.2f} < {Qdiseno_obra} m3/s)")
