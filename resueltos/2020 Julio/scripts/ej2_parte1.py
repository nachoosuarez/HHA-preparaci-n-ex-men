"""
Ejercicio 2, Parte 1 - Examen HHA 7/jul/2020
1.1) Caudal maximo de diseno para Tr=5 anios (alcantarilla, Ruta en Artigas).
1.2) Hietograma e hidrograma del evento de diseno.
Replica las formulas de 'Scripts examen AA/EVENTOS EXTREMOS 2025.xlsx'
(hojas 'metodo racional' y 'NRCS - Gande'), adaptadas a los datos de la
cuenca de este examen (Tabla 1: Area=7.3 km2, dH=180m, L=3750m; suelos
20% Rivera (GH B) + 80% Itapebi-Tres Arboles (GH D); pastizales, condicion
hidrologica buena).
"""
import numpy as np
import math

# ---------- DATOS DE LA CUENCA (Tabla 1 del enunciado) ----------
Area_km2 = 7.3
dH_m = 180.0
L_m = 3750.0
L_km = L_m/1000
S_basin_pct = 3.1        # pendiente media de la cuenca (uso: tabla C del metodo racional)
Tr = 5                    # anios
P310 = 100.0              # mm, leido de isoyetas (Fig 3.1.10) en X=400km,Y=6650km
# Grupo Hidrologico compuesto: Rivera 20% (GH B, Tabla "Grupo Hidrologico"
# del Teorico, pag.125) + Itapebi-Tres Arboles 80% (GH D)
NC = 0.20*61 + 0.80*80    # Pradera/pastizal, condicion hidrologica Buena (Fig 3.1.20): B=61, D=80
floor_rate = 1.2          # mm/h, infiltracion minima grupos B,C,D (grupo A = 2.4 mm/h)
C_racional = 0.36         # Pastizales, pendiente "Promedio 2-7%" (S=3.1%), Tr=5 (Tabla 3.1.4)

# ---------- TIEMPO DE CONCENTRACION (Ramser-Kirpich) ----------
# S del cauce principal (para Kirpich) = dH(m)/L(km)/10 -- DISTINTO de la
# pendiente media de la cuenca (3.1%), que solo se usa para la tabla de C.
S_channel_pct = dH_m / L_km / 10
tc_hs = 0.4 * (L_km**0.77) / (S_channel_pct**0.385)
tc_min = tc_hs*60
print(f"S cauce principal (Kirpich) = {S_channel_pct:.4f} %")
print(f"tc = {tc_hs:.4f} hs = {tc_min:.2f} min")
print(f"NC compuesto = 0.20*61 + 0.80*80 = {NC:.2f}")
print("Como 20 min < tc < 1 h => se calculan Racional y NRCS, se adopta el mayor")

# ---------- Funciones IDF Uruguay (Rodriguez Fontal 1980 / Genta et al 1998) ----------
def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

def CA(d, Ac_km2):
    return 1 - (0.3549*(d**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

CT5 = CT(Tr)
print(f"CT(Tr=5) = {CT5:.4f}")

# =====================================================================
# METODO RACIONAL
# =====================================================================
d_rac = tc_hs
CD_rac = CD(d_rac)
CA_rac = CA(d_rac, Area_km2)
P_rac = CT5*CD_rac*CA_rac*P310
i_rac = P_rac/d_rac  # mm/h
Ac_ha = Area_km2*100
Q_racional = C_racional*i_rac*Ac_ha/360
print("\n--- METODO RACIONAL ---")
print(f"d=tc = {d_rac:.4f} hs, CD={CD_rac:.4f}, CA={CA_rac:.4f}")
print(f"P(d,5,p) = {P_rac:.3f} mm ; i = {i_rac:.3f} mm/h")
print(f"Qmax racional = {Q_racional:.3f} m3/s")

# =====================================================================
# METODO NRCS (bloque alterno + NC + hidrograma unitario triangular SCS)
# =====================================================================
dt = tc_hs/7
n = np.arange(1,13)
d_n = dt*n
CD_n = np.array([CD(x) for x in d_n])
CA_n = np.array([CA(x, Area_km2) for x in d_n])
P_n = CD_n*CT5*CA_n*P310
M_n = np.diff(np.concatenate(([0.0], P_n)))

order = [12,10,8,6,4,2,1,3,5,7,9,11]
N = np.array([M_n[idx-1] for idx in order])

print(f"\n--- TORMENTA DE DISENO (bloque alterno, dt=tc/7={dt*60:.2f} min) ---")
for k in range(12):
    print(f"  bloque {k+1:2d}: {N[k]:6.3f} mm")
print(f"  TOTAL = {N.sum():.3f} mm  (duracion total = {12*dt:.3f} hs = {12*dt*60:.1f} min)")

S_mm = 25.4*((1000/NC)-10)
Ia = 0.2*S_mm
print(f"\nS = {S_mm:.3f} mm ; Ia = 0.2S = {Ia:.3f} mm")

O = np.cumsum(N)
Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
deficit = np.maximum(N-Qinc, floor_rate*dt)
Pe_corr = np.maximum(N-deficit, 0.0)
print(f"suma Pe corregido = {Pe_corr.sum():.3f} mm")

tr_uh = dt
Tp = tr_uh/2 + 0.6*tc_hs
Tb = Tp*2.667
qp = 2.08*Area_km2/Tp
a = (qp/10)/Tp
c = -(qp/10)/(1.67*Tp)
dd = qp/10 + (qp/10)/1.67
print(f"\n--- HIDROGRAMA UNITARIO TRIANGULAR SCS ---")
print(f"tr={tr_uh:.4f} hs, Tp={Tp:.4f} hs, Tb={Tb:.4f} hs, qp={qp:.4f} m3/s/cm")

def UH(x):
    if x < 0:
        return 0.0
    return a*x if x < Tp else max(c*x+dd, 0.0)

step = tr_uh/8
Nsteps = int(math.ceil((11*tr_uh+Tb)/step)) + 40
t = np.arange(0, Nsteps)*step
Qtot = np.zeros_like(t)
for k in range(12):
    shift = k*tr_uh
    Qtot += Pe_corr[k]*np.array([UH(x-shift) for x in t])

Qmax_NRCS = Qtot.max()
tQmax = t[np.argmax(Qtot)]
print(f"\nQmax NRCS (hidrograma) = {Qmax_NRCS:.3f} m3/s  en t = {tQmax:.3f} hs")

print("\n=====================================================")
print(f"Qmax METODO RACIONAL = {Q_racional:.2f} m3/s")
print(f"Qmax METODO NRCS     = {Qmax_NRCS:.2f} m3/s")
metodo = 'RACIONAL' if Q_racional > Qmax_NRCS else 'NRCS'
print(f"=> Se adopta el MAYOR: {metodo}  ({max(Q_racional,Qmax_NRCS):.2f} m3/s)")

# ---------------------------------------------------------------------
# 1.2) Hietograma e hidrograma del EVENTO DE DISENO (metodo adoptado:
# Racional). Hietograma: intensidad constante i_rac durante d=tc.
# Hidrograma: triangulo esquematico con tiempo al pico = tc (hipotesis del
# metodo racional: toda la cuenca aporta simultaneamente en t=tc) y pico
# = Q_racional; rama de descenso con la razon Tb/Tp=2.667 del hidrograma
# unitario triangular SCS (forma estandar del curso, Teorico S3.1.5c).
# ---------------------------------------------------------------------
if __name__ == "__main__":
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    Tp_design = tc_hs
    Tb_design = Tp_design*2.667
    t_hg = np.array([0, Tp_design, Tb_design])
    Q_hg = np.array([0, Q_racional, 0])

    fig, axs = plt.subplots(2, 1, figsize=(7,7), sharex=True)
    axs[0].plot([0, d_rac, d_rac, Tb_design], [i_rac, i_rac, 0, 0], '-b', lw=2)
    axs[0].set_ylabel("i (mm/h)")
    axs[0].set_title("Hietograma de diseno (Metodo Racional): i=%.2f mm/h, d=tc=%.3f h" % (i_rac, d_rac))
    axs[0].grid(True)

    axs[1].plot(t_hg, Q_hg, '-r', lw=2)
    axs[1].axvline(tc_hs, ls=':', color='k')
    axs[1].set_xlabel("t (hs)")
    axs[1].set_ylabel("Q (m3/s)")
    axs[1].set_title("Hidrograma de diseno (triangular, Tp=tc, Tb=2.667*tc, pico=%.2f m3/s)" % Q_racional)
    axs[1].grid(True)

    plt.tight_layout()
    plt.savefig("ej2_hietograma_hidrograma.png", dpi=120)
    print("\nGrafico guardado en ej2_hietograma_hidrograma.png")
    print(f"Tp_design={Tp_design:.4f} hs, Tb_design={Tb_design:.4f} hs")
