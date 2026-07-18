"""
Ejercicio 3 - Examen HHA 24/feb/2023
Cuenca en Cerro Largo (X=650 km, Y=6400 km), flujo concentrado, pastizales
naturales en condicion hidrologica MALA, unidad de suelos Risso (=> Grupo
Hidrologico D, Fig. 1.4.x / Tabla "Grupo hidrologico segun unidad de
suelo" del Teorico HHA, verificado con `pdftotext` sobre el Teorico:
"Risso ... D").

Replica las formulas de 'Scripts examen AA/EVENTOS EXTREMOS 2025.xlsx'
(hoja 'Calculos (grande)': tc Kirpich, IDF Uruguay, metodo Racional,
tormenta de diseno por bloque alterno, Numero de Curva NRCS, hidrograma
unitario triangular SCS), igual patron que
`resueltos/2024 diciembre/scripts/ej2_parte1.py`.

a) Qmax de diseno (Tr=5 anios), justificando el metodo segun tc.
b) Volumen de escorrentia del evento de diseno.
c) Maxima area transformable a urbana (lotes de 0.03 ha, < 0.05 ha =>
   categoria "Residencial <0.05Ha" del Numero de Curva, NC=92 para Grupo D)
   sin que el Qmax de diseno (Tr=5) crezca mas de un 15%, manteniendo el
   mismo tc.

Los valores base P(3,10) (isoyeta), C (Tabla 3.1.4) y NC (Fig. 3.1.20) se
toman de la solucion oficial manuscrita adjunta al examen.
"""
import numpy as np
import math

# ---------- DATOS DE LA CUENCA (Tabla del enunciado) ----------
Area_km2 = 5.10
dH_m = 120.0
L_m = 3600.0
L_km = L_m/1000
S_basin_pct = 3.8         # pendiente MEDIA de la cuenca (dato directo del enunciado, para C)
Tr = 5                     # anios
P310 = 80.0                # mm, isoyeta P(3h,Tr=10) en Cerro Largo (X=650,Y=6400) - sol. oficial
NC_pastizal = 89           # pastizales cond. mala, Risso -> Grupo Hidrologico D (Fig 3.1.20)
NC_urbano = 92             # residencial <0.05 Ha (lotes 0.03ha), Grupo Hidrologico D (Fig 3.1.20)
C_racional = 0.36          # pastizales cond. mala, S=3.8% (Tabla 3.1.4, metodo racional) - sol. oficial
floor_rate = 1.2           # mm/h, infiltracion minima grupos B,C,D (grupo A = 2.4 mm/h)

# ---------- TIEMPO DE CONCENTRACION (Kirpich / Ramser-Kirpich, cauce principal) ----------
S_channel_pct = dH_m / L_km / 10
tc_hs = 0.4 * (L_km**0.77) / (S_channel_pct**0.385)
tc_min = tc_hs*60
print(f"S cauce principal (Kirpich) = {S_channel_pct:.4f} %")
print(f"tc = {tc_hs:.4f} hs = {tc_min:.2f} min")
print(f"\ntc={tc_min:.1f} min: 20 min < tc < 1 hora => corresponde calcular")
print("AMBOS metodos (Racional y NRCS) y adoptar el MAYOR caudal (Teorico HHA 3.1.5)")

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

# =====================================================================
# METODO RACIONAL (duracion = tc)
# =====================================================================
d_rac = tc_hs
CD_rac = CD(d_rac)
CA_rac = CA(d_rac, Area_km2)
P_rac = CT5*CD_rac*CA_rac*P310
i_rac = P_rac/d_rac
Ac_ha = Area_km2*100
Q_racional = C_racional*i_rac*Ac_ha/360
print("\n--- METODO RACIONAL ---")
print(f"d=tc = {d_rac:.4f} hs, CD={CD_rac:.4f}, CA={CA_rac:.4f}")
print(f"P(d,5,A) = {P_rac:.3f} mm ; i = {i_rac:.3f} mm/h")
print(f"Qmax racional = {Q_racional:.3f} m3/s")

def NRCS_hidrograma(NC, Area, tc):
    """Devuelve (Qmax, Pe_corr(array 12 bloques), Tp, Tb) del metodo NRCS
    (tormenta de diseno por bloque alterno + Num. de Curva + hidrograma
    unitario triangular SCS), para una cuenca de area Area (km2), tc (hs)
    y Numero de Curva NC dados. CT5, P310 y floor_rate se toman del
    contexto global (misma tormenta de diseno / condicion de humedad)."""
    dt = tc/7
    n = np.arange(1,13)
    d_n = dt*n
    CD_n = np.array([CD(x) for x in d_n])
    CA_n = np.array([CA(x, Area) for x in d_n])
    P_n = CD_n*CT5*CA_n*P310
    M_n = np.diff(np.concatenate(([0.0], P_n)))

    order = [12,10,8,6,4,2,1,3,5,7,9,11]
    N = np.array([M_n[idx-1] for idx in order])

    S_mm = 25.4*((1000/NC)-10)
    Ia = 0.2*S_mm

    O = np.cumsum(N)
    Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
    Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
    deficit = np.maximum(N-Qinc, floor_rate*dt)
    Pe_corr = np.maximum(N - deficit, 0.0)

    tr_uh = dt
    Tp = tr_uh/2 + 0.6*tc
    Tb = Tp*2.667
    qp = 2.08*Area/Tp
    a = (qp/10)/Tp
    c = -(qp/10)/(1.67*Tp)
    dd = qp/10 + (qp/10)/1.67

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
    Tbase_total = tQmax + Tb  # tiempo base medido desde el inicio de la tormenta
    return Qmax, Pe_corr, Tp, tQmax, Tbase_total, S_mm

print("\n--- METODO NRCS (situacion original, NC=89) ---")
Qmax_NRCS_a, Pe_corr_a, Tp_a, tpico_a, tbase_a, S_mm_a = NRCS_hidrograma(NC_pastizal, Area_km2, tc_hs)
print(f"S = {S_mm_a:.3f} mm ; SUMA Pe corregido = {Pe_corr_a.sum():.3f} mm")
print(f"Qmax NRCS = {Qmax_NRCS_a:.3f} m3/s en t_pico={tpico_a:.3f} hs, t_base~{tbase_a:.3f} hs")

Qmax_diseno = max(Q_racional, Qmax_NRCS_a)
metodo = "NRCS" if Qmax_NRCS_a>Q_racional else "RACIONAL"
print("\n=====================================================")
print(f"Qmax METODO RACIONAL = {Q_racional:.2f} m3/s")
print(f"Qmax METODO NRCS     = {Qmax_NRCS_a:.2f} m3/s")
print(f"=> PARTE a) Se adopta el MAYOR: Qmax de diseno (Tr=5) = {Qmax_diseno:.2f} m3/s ({metodo})")

# =====================================================================
# PARTE b) Volumen de escorrentia
# =====================================================================
Vesc_m3 = Pe_corr_a.sum()*1000*Area_km2
print(f"\n--- PARTE b) ---")
print(f"Vesc = Area(km2)*1000*SUMA(Pe corregido, mm) = {Area_km2}*1000*{Pe_corr_a.sum():.3f} = {Vesc_m3:.0f} m3")

# =====================================================================
# PARTE c) Maxima area urbanizable sin superar +15% del Qmax de a)
# =====================================================================
print(f"\n--- PARTE c) ---")
Qmax_target = 1.15*Qmax_NRCS_a
print(f"Qmax objetivo = 1.15*{Qmax_NRCS_a:.2f} = {Qmax_target:.2f} m3/s")

def Qmax_de_NC(NC_pond):
    Qmax_, *_ = NRCS_hidrograma(NC_pond, Area_km2, tc_hs)
    return Qmax_

# Buscar por biseccion el NC ponderado que da Qmax_target (mismo tc: el
# enunciado dice que la urbanizacion NO cambia el tiempo de concentracion)
lo, hi = NC_pastizal, NC_urbano
for _ in range(60):
    mid = (lo+hi)/2
    if Qmax_de_NC(mid) < Qmax_target:
        lo = mid
    else:
        hi = mid
NC_star = (lo+hi)/2
print(f"NC ponderado necesario para Qmax=+15% = {NC_star:.3f}")

# NC* = x*NC_urbano + (1-x)*NC_pastizal  =>  x = (NC*-NC_pastizal)/(NC_urbano-NC_pastizal)
x_frac = (NC_star - NC_pastizal)/(NC_urbano - NC_pastizal)
Area_urb_max = x_frac*Area_km2
print(f"NC* = x*{NC_urbano}(urbano) + (1-x)*{NC_pastizal}(pastizal) => x = {x_frac:.4f}")
print(f"Area maxima transformable a urbana = x*Area = {x_frac:.4f}*{Area_km2} = {Area_urb_max:.3f} km2")
