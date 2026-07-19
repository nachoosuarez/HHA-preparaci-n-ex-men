"""
Ejercicio 2, Parte 1 - Examen HHA 22/dic/2020 (Variante A)
Caudal maximo de diseno de la alcantarilla (Tr=10 anios), hietograma e
hidrograma de diseno, volumen de escorrentia.

Cuenca (Tabla 1): Area=8.3 km2, dH=130 m, L=9850 m, S_cuenca=1.9%.
Suelo: Rio Branco 85% (Grupo Hidrologico D) + Andresito 15% (Grupo B),
uso pastizales en condicion hidrologica mala (flujo concentrado).

Replica las mismas formulas IDF Uruguay / bloque alterno / hidrograma
unitario triangular SCS ya usadas en los examenes anteriores (ver p.ej.
resueltos/2026 Febrero/scripts/ej2_parte1.py), verificadas contra la
planilla 'Eventos extremos.xlsx' (ver RESUMEN EXAMEN/Teorico/
COMO_USAR_EVENTOS_EXTREMOS.md).
"""
import numpy as np
import math

# ---------- DATOS DE LA CUENCA (Tabla 1 del enunciado) ----------
Area_km2 = 8.3
dH_m = 130.0
L_m = 9850.0
L_km = L_m/1000
Tr = 10
P310 = 74.0            # mm, lectura de isoyetas (Fig 3.1.10) en X=650km,Y=6200km (Rocha)
floor_rate = 1.2        # mm/h (ningun grupo es A)

# NC ponderado por Unidades Cartograficas de suelo (distinto Grupo Hidrologico
# cada una), pastizales condicion hidrologica MALA (Fig 3.1.20 del Teorico):
NC_RioBranco_D = 89     # Grupo D
NC_Andresito_B = 79     # Grupo B
pct_RioBranco = 0.85
pct_Andresito = 0.15
NC = pct_RioBranco*NC_RioBranco_D + pct_Andresito*NC_Andresito_B
print(f"NC ponderado = {pct_RioBranco}*{NC_RioBranco_D} + {pct_Andresito}*{NC_Andresito_B} = {NC:.2f}")

# ---------- TIEMPO DE CONCENTRACION (Ramser-Kirpich, flujo concentrado) ----------
S_channel_pct = dH_m / L_km / 10
tc_hs = 0.4 * (L_km**0.77) / (S_channel_pct**0.385)
tc_min = tc_hs*60
print(f"S cauce principal = dH/L = {dH_m}/{L_km} km /10 = {S_channel_pct:.4f} %")
print(f"tc (Ramser-Kirpich) = {tc_hs:.4f} hs = {tc_min:.2f} min")
print("tc > 1 hora => corresponde metodo NRCS (Teorico 3.1.5)")

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

CT10 = CT(Tr)
print(f"CT(Tr=10) = {CT10:.4f}")

S_mm = 25.4*((1000/NC)-10)
Ia = 0.2*S_mm
print(f"S(NC) = {S_mm:.3f} mm ; Ia=0.2S = {Ia:.3f} mm")

def hidrograma_NRCS(tc_h, Tr_, Area, order=None):
    """Tormenta de diseno por bloque alterno + hidrograma unitario SCS."""
    if order is None:
        order = [12,10,8,6,4,2,1,3,5,7,9,11]
    CTv = CT(Tr_)
    dt = tc_h/7
    n = np.arange(1,13)
    d_n = dt*n
    CD_n = np.array([CD(x) for x in d_n])
    CA_n = np.array([CA(x, Area) for x in d_n])
    P_n = CD_n*CTv*CA_n*P310
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
    return t, Qtot, N, Pe_corr, Tp, Tb

t1, Q1, N1, Pe1, Tp1, Tb1 = hidrograma_NRCS(tc_hs, Tr, Area_km2)

print("\n--- TORMENTA DE DISENO (bloque alterno, dt={:.4f} hs = {:.1f} min) ---".format(tc_hs/7, tc_hs/7*60))
for k in range(12):
    print(f"  bloque {k+1:2d}: N={N1[k]:6.3f} mm   Pe_corr={Pe1[k]:6.3f} mm")
print(f"  TOTAL tormenta = {N1.sum():.3f} mm ; TOTAL Pe = {Pe1.sum():.3f} mm")

Qmax1 = Q1.max()
tQmax1 = t1[np.argmax(Q1)]
print(f"\nHidrograma unitario SCS: Tp={Tp1:.4f} hs, Tb={Tb1:.4f} hs")
print(f"Qmax NRCS (Tr=10) = {Qmax1:.3f} m3/s en t={tQmax1:.3f} hs")

# ---------- Volumen de escorrentia del evento de diseno ----------
Vesc1 = Pe1.sum()*1000*Area_km2
print(f"\nVolumen de escorrentia = Pe_total*Area = {Pe1.sum():.3f} mm * {Area_km2} km2 = {Vesc1:.0f} m3")

print("\n=====================================================")
print(f"RESULTADO PARTE 1: Qmax diseno (Tr=10) = {Qmax1:.2f} m3/s")
print(f"                    Vesc = {Vesc1:.3e} m3")
