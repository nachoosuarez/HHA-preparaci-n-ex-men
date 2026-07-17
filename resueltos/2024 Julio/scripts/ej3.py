"""
Examen HHA - Julio 2024 - Ejercicio 3
Diseno hidraulico de una alcantarilla, cuenca en Rio Negro.
Metodo NRCS (Numero de Curva + hidrograma unitario triangular SCS),
mismas formulas que resueltos/2024 diciembre/scripts/ej2_parte1.py
(curvas IDF de "Scripts/01_SCRIPTS/Eventos extremos.xlsx", ver
RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md), generalizadas en
una funcion para poder recalcular con la cuenca urbanizada (Parte 3).
"""
import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# --- datos comunes ---
Area_km2 = 6.5
dH_m = 85.0
L_km = 5.4
Tr = 5
P310 = 90.0     # mm, lectura de isoyeta (dato oficial)
GH = "B"        # grupo hidrologico

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

def hidrograma_NRCS(Area_km2, tc_hs, NC, Tr, P310, floor_rate=1.2, label=""):
    CT5 = CT_from_Tr(Tr)
    dt = tc_hs/7
    n = np.arange(1, 13)
    d_n = dt*n
    CD_n = np.array([CD(x) for x in d_n])
    CA_n = np.array([CA(x, Area_km2) for x in d_n])
    P_n = CD_n*CT5*CA_n*P310
    M_n = np.diff(np.concatenate(([0.0], P_n)))
    order = [12,10,8,6,4,2,1,3,5,7,9,11]
    N = np.array([M_n[idx-1] for idx in order])

    S_mm = 25.4*(1000/NC - 10)
    Ia = 0.2*S_mm
    O = np.cumsum(N)
    Pe_cum = np.where(O <= Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
    Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
    deficit = np.maximum(N-Qinc, floor_rate*dt)
    Pe_corr = np.maximum(N-deficit, 0.0)
    Vesc_m3 = Pe_corr.sum()*1000*Area_km2

    Tp = dt/2 + 0.6*tc_hs
    Tb = Tp*2.667
    qp = 2.08*Area_km2/Tp   # m3/s por cm (SCS estandar)

    def UH(x):
        a = (qp/10)/Tp
        c = -(qp/10)/(1.67*Tp)
        dd = qp/10 + (qp/10)/1.67
        return a*x if x < Tp else max(c*x+dd, 0.0)

    step = dt/8
    Nsteps = int(math.ceil((11*dt+Tb)/step)) + 40
    t = np.arange(0, Nsteps)*step
    Qtot = np.zeros_like(t)
    for k in range(12):
        shift = k*dt
        Qtot += Pe_corr[k]*np.array([UH(x-shift) if x >= shift else 0.0 for x in t])

    Qmax = Qtot.max()
    tQmax = t[np.argmax(Qtot)]

    print(f"\n--- NRCS {label} ---")
    print(f"tc={tc_hs:.4f} hs, NC={NC:.2f}, dt={dt:.4f} hs, S={S_mm:.3f} mm, Ia={Ia:.3f} mm")
    print(f"Tp={Tp:.4f} hs, Tb={Tb:.4f} hs, qp={qp/10:.4f} m3/s/mm")
    print(f"Pe total = {Pe_corr.sum():.3f} mm ; Vesc = {Vesc_m3:.0f} m3")
    print(f"Qmax = {Qmax:.3f} m3/s en t = {tQmax:.3f} hs")

    return dict(t=t, Q=Qtot, Qmax=Qmax, tQmax=tQmax, Tb=Tb, Tp=Tp, Vesc=Vesc_m3, Pe=Pe_corr.sum())

# =====================================================================
# Parte 1 y 2: cuenca actual (pastizales, cond. hidrologica buena, grupo B)
# =====================================================================
tc_hs, S_cauce = tc_kirpich(L_km, dH_m)
print(f"tc (Kirpich) = {tc_hs:.4f} hs = {tc_hs*60:.1f} min (>1h => solo metodo NRCS, Teorico S3.1.5)")

NC_actual = 61   # pastizal, cond. hidrologica buena, grupo B (Fig 3.1.20)
res1 = hidrograma_NRCS(Area_km2, tc_hs, NC_actual, Tr, P310, label="(cuenca actual)")

# =====================================================================
# Parte 3: 15% del area se urbaniza (lote<0.05Ha, 65% impermeable) y el
# tc se reduce 15% por canalizacion de parte del cauce principal
# =====================================================================
NC_pastizal = 61
NC_urbano = 85   # residencial, lote<0.05Ha (1/8 acre), 65% impermeable, grupo B (Fig 3.1.20/Tabla NRCS)
frac_urb = 0.15
NC_pond = (1-frac_urb)*NC_pastizal + frac_urb*NC_urbano
tc_urb = tc_hs*(1-0.15)

print(f"\nNC ponderado (85% pastizal + 15% urbano) = {NC_pond:.2f}")
print(f"tc urbanizado = tc*(1-0.15) = {tc_urb:.4f} hs = {tc_urb*60:.1f} min")

res2 = hidrograma_NRCS(Area_km2, tc_urb, NC_pond, Tr, P310, label="(cuenca urbanizada 15%)")

print("\n=====================================================")
print(f"Qmax actual      = {res1['Qmax']:.2f} m3/s  (tpico={res1['tQmax']:.2f} h, Vesc={res1['Vesc']:.0f} m3)")
print(f"Qmax urbanizada  = {res2['Qmax']:.2f} m3/s  (tpico={res2['tQmax']:.2f} h, Vesc={res2['Vesc']:.0f} m3)")

# --- graficos ---
plt.figure(figsize=(9,5))
plt.plot(res1['t'], res1['Q'], '-b', linewidth=2, label=f"Cuenca actual (Qmax={res1['Qmax']:.2f} m3/s en t={res1['tQmax']:.2f} h)")
plt.xlabel('t (h)'); plt.ylabel('Q (m3/s)')
plt.title('Ejercicio 3 - Hidrograma de diseno, Tr=5 anios (cuenca actual)')
plt.grid(True); plt.legend()
plt.tight_layout()
plt.savefig('ej3_hidrograma_actual.png', dpi=120)

plt.figure(figsize=(9,5))
plt.plot(res1['t'], res1['Q'], '--b', linewidth=2, label=f"Actual (Qmax={res1['Qmax']:.2f} m3/s, tp={res1['tQmax']:.2f} h)")
plt.plot(res2['t'], res2['Q'], '-r', linewidth=2, label=f"Urbanizada 15% (Qmax={res2['Qmax']:.2f} m3/s, tp={res2['tQmax']:.2f} h)")
plt.xlabel('t (h)'); plt.ylabel('Q (m3/s)')
plt.title('Ejercicio 3 - Comparacion hidrograma actual vs. urbanizado (Tr=5 anios)')
plt.grid(True); plt.legend()
plt.tight_layout()
plt.savefig('ej3_hidrograma_comparacion.png', dpi=120)
print("\nGraficos guardados: ej3_hidrograma_actual.png, ej3_hidrograma_comparacion.png")
