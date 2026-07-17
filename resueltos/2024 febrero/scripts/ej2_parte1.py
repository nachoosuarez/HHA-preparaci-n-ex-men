"""
Ejercicio 2, Parte 1 - Examen HHA 5/6-feb-2024 (2024 febrero)
Caudal de diseno de la alcantarilla, Tr=10 anios, cuenca al norte de
Artigas (pastizales, condicion hidrologica mala; suelos mixtos Rivera
25% (grupo B) / Itapebi-Tres Arboles 75% (grupo D)).

Replica las formulas de la planilla 'Eventos extremos.xlsx' (hoja
'Calculos (grande)', ver RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md)
resueltas a mano en Python porque en este entorno no hay Excel interactivo.
"""
import numpy as np
import math

# ---------- DATOS DE LA CUENCA (Tabla 1 del enunciado) ----------
Area_km2 = 6.3
dH_m = 180.0
L_m = 3750.0
L_km = L_m/1000
S_basin_pct = 3.1        # pendiente MEDIA de la cuenca (dato de la tabla) -> solo para elegir C (Tabla 3.1.4)
Tr = 10                  # anios
P310 = 98.0              # mm, isoyetas Fig 3.1.10 en X=400km, Y=6600km (Depto. Artigas)
C = 0.38                 # Tabla 3.1.4: pastizales, cond. hidrologica mala, pendiente promedio 2-7%
floor_rate = 1.2         # mm/h, infiltracion minima (grupos B, C y D -> 1.2; solo A usa 2.4)

# Numero de Curva ponderado por unidad cartografica de suelo
NC_Rivera = 79            # grupo hidrologico B (pastizales, cond. mala)
NC_ItapebiTresArboles = 89  # grupo hidrologico D (pastizales, cond. mala)
frac_Rivera = 0.25
frac_ItaTA  = 0.75
NC = frac_Rivera*NC_Rivera + frac_ItaTA*NC_ItapebiTresArboles
print(f"NC ponderado = {frac_Rivera}*{NC_Rivera} + {frac_ItaTA}*{NC_ItapebiTresArboles} = {NC:.2f}")

# ---------- TIEMPO DE CONCENTRACION (Kirpich / Ramser-Kirpich, flujo concentrado) ----------
# OJO: la pendiente que alimenta Kirpich es la del CAUCE PRINCIPAL
# (dH/L/10), DISTINTA de la pendiente media de la cuenca (3.1%, dato de
# la tabla, que solo se usa para elegir C en el metodo Racional).
S_channel_pct = dH_m / L_km / 10
tc_hs = 0.4 * (L_km**0.77) / (S_channel_pct**0.385)
tc_min = tc_hs*60
print(f"S canal principal (Kirpich) = dH/L/10 = {dH_m}/{L_km}/10 = {S_channel_pct:.4f} %")
print(f"tc = 0.4*L^0.77/S^0.385 = {tc_hs:.4f} hs = {tc_min:.2f} min")

# ---------- JUSTIFICACION DEL METODO (Teorico HHA Cap. 3.1.5) ----------
if tc_min < 20:
    metodo = "solo Racional"
elif tc_min <= 60:
    metodo = "AMBOS (Racional y NRCS), adoptar el MAYOR caudal"
else:
    metodo = "solo NRCS"
print(f"\ntc={tc_min:.1f} min -> criterio Teorico 3.1.5: {metodo}")

# ---------- Funciones IDF Uruguay ----------
def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

def CA(d, Ac_km2):
    return 1 - (0.3549*(d**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

CT10 = CT(Tr)
print(f"CT(Tr=10) = {CT10:.4f}")

# =====================================================================
# METODO RACIONAL (duracion de la tormenta = tc)
# =====================================================================
CD_tc = CD(tc_hs)
CA_tc = CA(tc_hs, Area_km2)
Ppunto = P310*CT10*CD_tc
Parea  = Ppunto*CA_tc
i_mmh  = Parea/tc_hs
Area_ha = Area_km2*100
Q_racional = C*i_mmh*Area_ha/360
print(f"\n--- METODO RACIONAL ---")
print(f"CD(tc={tc_hs:.4f}hs) = {CD_tc:.4f} ; CA(tc,A={Area_km2}km2) = {CA_tc:.4f}")
print(f"P(punto) = P310*CT*CD = {Ppunto:.3f} mm ; P(area) = P(punto)*CA = {Parea:.3f} mm")
print(f"i = P(area)/tc = {i_mmh:.3f} mm/h")
print(f"Q_racional = C*i*A(ha)/360 = {C}*{i_mmh:.3f}*{Area_ha}/360 = {Q_racional:.2f} m3/s")

# =====================================================================
# METODO NRCS (bloque alterno + NC + hidrograma unitario triangular SCS)
# =====================================================================
dt = tc_hs/7
n = np.arange(1,13)
d_n = dt*n
CD_n = np.array([CD(x) for x in d_n])
CA_n = np.array([CA(x, Area_km2) for x in d_n])
P_n = CD_n*CT10*CA_n*P310
M_n = np.diff(np.concatenate(([0.0], P_n)))

order = [12,10,8,6,4,2,1,3,5,7,9,11]
N = np.array([M_n[idx-1] for idx in order])

print(f"\n--- TORMENTA DE DISENO (bloque alterno, dt = tc/7 = {dt:.4f} hs = {dt*60:.2f} min) ---")
for k in range(12):
    print(f"  bloque {k+1:2d}: {N[k]:6.3f} mm")
print(f"  TOTAL tormenta = {N.sum():.3f} mm (duracion total = {12*dt:.3f} hs = {12*dt*60:.1f} min)")

S_mm = 25.4*((1000/NC)-10)
Ia = 0.2*S_mm
print(f"\nS = 25.4*(1000/NC-10) = {S_mm:.3f} mm ; Ia = 0.2*S = {Ia:.3f} mm")

O = np.cumsum(N)
Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
deficit = np.maximum(N-Qinc, floor_rate*dt)
Pe_corr = np.maximum(N - deficit, 0.0)

print("\n--- PRECIPITACION EFECTIVA POR BLOQUE ---")
for k in range(12):
    print(f"  bloque {k+1:2d}: tormenta={N[k]:6.3f}  Pe_NC_inc={Qinc[k]:6.3f}  deficit={deficit[k]:6.3f}  Pe_corregido={Pe_corr[k]:6.3f}")
Pe_total = Pe_corr.sum()
print(f"  SUMA Pe corregido = {Pe_total:.3f} mm")

Vesc_m3 = Pe_total*1000*Area_km2
Vesc_hm3 = Vesc_m3/1e6
print(f"\nVolumen de escorrentia = {Pe_total:.3f}mm * {Area_km2}km2 * 1000 = {Vesc_m3:.1f} m3 = {Vesc_hm3:.4f} hm3")

tr_uh = dt
Tp = tr_uh/2 + 0.6*tc_hs
Tb = Tp*2.667
qp_cm = 2.08*Area_km2/Tp  # m3/s por cm de Pe (equivalente a 0.208*A/Tp por mm)
a = (qp_cm/10)/Tp
c = -(qp_cm/10)/(1.67*Tp)
dd = qp_cm/10 + (qp_cm/10)/1.67
print(f"\n--- HIDROGRAMA UNITARIO TRIANGULAR SCS ---")
print(f"tr={tr_uh:.4f} hs, Tp={Tp:.4f} hs, Tb={Tb:.4f} hs, qp={qp_cm/10:.4f} m3/s/mm")

def UH(x):
    return a*x if x<Tp else max(c*x+dd, 0.0)

step = tr_uh/8
Nsteps = int(math.ceil((11*tr_uh+Tb)/step)) + 40
t = np.arange(0, Nsteps)*step
Qtot = np.zeros_like(t)
for k in range(12):
    shift = k*tr_uh
    Qtot += Pe_corr[k]*np.array([UH(x-shift) if x>=shift else 0.0 for x in t])

Qmax_NRCS = Qtot.max()
tQmax = t[np.argmax(Qtot)]
print(f"\nQmax NRCS (hidrograma) = {Qmax_NRCS:.3f} m3/s en t = {tQmax:.3f} hs desde inicio de la tormenta de diseno")

print("\n=====================================================")
print(f"Q racional = {Q_racional:.2f} m3/s")
print(f"Q NRCS     = {Qmax_NRCS:.2f} m3/s")
Qdiseno = max(Q_racional, Qmax_NRCS)
metodo_adoptado = "NRCS" if Qmax_NRCS >= Q_racional else "Racional"
print(f"20min<tc<1h => se adopta el MAYOR: Q diseno = {Qdiseno:.2f} m3/s (metodo {metodo_adoptado})")
print(f"Volumen de escorrentia = {Vesc_m3:.0f} m3 = {Vesc_hm3:.3f} hm3")
print(f"Tiempo de demora en alcanzar Qmax desde el inicio del evento = {tQmax:.2f} hs")

np.savez('part1_ej2.npz', t=t, Qtot=Qtot, Pe_corr=Pe_corr, N=N, tc_hs=tc_hs, dt=dt,
          Tp=Tp, Tb=Tb, Qmax_NRCS=Qmax_NRCS, tQmax=tQmax, Vesc_m3=Vesc_m3,
          Q_racional=Q_racional, Qdiseno=Qdiseno, Area_km2=Area_km2, P310=P310,
          NC=NC, S_mm=S_mm, Ia=Ia, CT10=CT10)

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, axs = plt.subplots(2,1, figsize=(8,7), sharex=False)
axs[0].bar(np.arange(1,13)*dt*60 - dt*60/2, N, width=dt*60*0.9, color='steelblue')
axs[0].set_xlabel('t (min)'); axs[0].set_ylabel('P (mm)')
axs[0].set_title('Hietograma de diseno (bloque alterno, Tr=10 anios)')
axs[1].plot(t, Qtot, 'b-', lw=2)
axs[1].axvline(tQmax, color='r', ls='--', label=f'Qmax en t={tQmax:.2f}h')
axs[1].set_xlabel('t (hs)'); axs[1].set_ylabel('Q (m3/s)')
axs[1].set_title('Hidrograma de crecida NRCS'); axs[1].legend()
plt.tight_layout()
plt.savefig('ej2_hietograma_hidrograma_parte1.png', dpi=110)
print("\nGrafico guardado: ej2_hietograma_hidrograma_parte1.png")
