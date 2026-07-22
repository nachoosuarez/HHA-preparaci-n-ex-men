"""
Ejercicio 3 -- Examen HHA 23/jul/2018
Cuenca en Treinta y Tres (punto de cierre X=600 km, Y=6330 km), pastizales
naturales, Grupo Hidrologico B, condicion MALA, flujo concentrado.
Area=4.95 km2, dH=110 m, L=3100 m, S(media cuenca)=3.3%.

Replica las formulas de la planilla 'Eventos extremos.xlsx' (hoja
'Calculos (grande)', ver RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md)
para: tiempo de concentracion (Kirpich), metodo Racional y metodo NRCS
(tormenta de diseno por bloque alterno + Numero de Curva + hidrograma
unitario triangular SCS) -- mismo patron ya validado en
resueltos/2023 diciembre/scripts/Ejercicio2_racional_NRCS.py (mismo tipo
de cuenca, mismo departamento, valores muy parecidos).

Resuelve las 3 partes del ejercicio:
  a) Qdiseño de la alcantarilla, Tr=5 anios. Justificar metodologia.
  b) Tr del caudal limite de sobrepasamiento (Q=42 m3/s).
  c) Area maxima urbanizable (concreto/techo) sin superar en 15% el
     caudal de la parte (a), con tc invariante.
"""
import numpy as np
import math

# ---------- DATOS DE LA CUENCA (enunciado) ----------
Area_km2 = 4.95
dH_m = 110.0
L_m = 3100.0
L_km = L_m/1000
Grupo_Hidrologico = 'B'
floor_rate = 1.2   # mm/h, piso de infiltracion minima grupos B,C,D

# Lecturas graficas/tabulares externas (Teorico HHA):
P310 = 80.0        # mm, Figura 3.1.10 (isoyetas) en X=600km,Y=6330km (Treinta y Tres)
                    # -- el punto cae practicamente SOBRE la isoyeta gruesa "80"
                    # (ver ej3_isoyeta_P310.png), igual que en resueltos/2023 diciembre/
                    # (punto cercano X=625,Y=6350, tambien P310=80mm: buena consistencia).
NC = 79             # Tabla 3.1.20: "Pradera o pastizal", condicion MALA, grupo B
C_Tr2  = 0.33       # Tabla 3.1.4 (Chow 1994): Pastizales, pendiente "Promedio 2-7%"
C_Tr5  = 0.36
C_Tr10 = 0.38
C_Tr25 = 0.42
C_Tr50 = 0.45
C_concreto_Tr5 = 0.80   # Tabla 3.1.4: Concreto/techo, Tr=5

# ---------- TIEMPO DE CONCENTRACION (Kirpich / Ramser-Kirpich) ----------
S_channel_pct = dH_m / L_km / 10   # pendiente del CAUCE PRINCIPAL (!= pendiente media 3.3%)
tc_hs = 0.4 * (L_km**0.77) / (S_channel_pct**0.385)
tc_min = tc_hs*60
print(f"S canal principal (Kirpich) = {S_channel_pct:.4f} %")
print(f"tc = {tc_hs:.4f} hs = {tc_min:.2f} min")

# ---------- CRITERIO DE SELECCION DE METODO (Teorico HHA 3.1.5) ----------
print(f"\ntc={tc_min:.1f} min: 20 min < tc < 60 min => calcular Racional y NRCS, adoptar el MAYOR.")

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


def metodo_racional(Tr, C):
    """Qmax metodo Racional (m3/s), duracion = tc."""
    CTr = CT(Tr)
    CDd = CD(tc_hs)
    CAa = CA(tc_hs, Area_km2)
    Pmax_area = P310*CDd*CTr*CAa      # mm, precipitacion max en el area
    i = Pmax_area/tc_hs                 # mm/h
    Q = C*i*Area_km2*100/360            # m3/s  (c*i*Area_Ha/360)
    return Q, CTr, CDd, CAa, Pmax_area, i


def metodo_nrcs(Tr, NC):
    """Qmax metodo NRCS (m3/s): tormenta de diseño (bloque alterno) + Pe (NC) + HU triangular SCS."""
    CTr = CT(Tr)
    dt = tc_hs/7
    n = np.arange(1,13)
    d_n = dt*n
    CD_n = np.array([CD(x) for x in d_n])
    CA_n = np.array([CA(x, Area_km2) for x in d_n])
    P_n = CD_n*CTr*CA_n*P310
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
    Tp = tr_uh/2 + 0.6*tc_hs
    qp = 0.208*Area_km2/Tp   # m3/s por mm
    a_ = qp/Tp
    Tb = 2.667*Tp
    c_ = -qp/(Tb-Tp)
    dd_ = -c_*Tb

    def UH(x):
        if x < 0: return 0.0
        if x < Tp: return a_*x
        if x < Tb: return c_*x + dd_
        return 0.0

    step = tr_uh/8
    Nsteps = int(math.ceil((11*tr_uh+Tb)/step)) + 40
    t = np.arange(0, Nsteps)*step
    Qtot = np.zeros_like(t)
    for k in range(12):
        shift = k*tr_uh
        Qtot += Pe_corr[k]*np.array([UH(x-shift) for x in t])
    Qmax = Qtot.max()
    return Qmax, N, Pe_corr, S_mm, Ia


print("\n=================== PARTE A: Qdiseño, Tr=5 años ===================")
QMR_5, CTr5, CDtc, CAtc, Pmax_area5, i5 = metodo_racional(5, C_Tr5)
print(f"Racional: CT(5)={CTr5:.4f} CD(tc)={CDtc:.4f} CA(tc)={CAtc:.4f}")
print(f"  P max en el area = {Pmax_area5:.2f} mm ; i = {i5:.2f} mm/h ; c={C_Tr5}")
print(f"  QMR(Tr=5) = {QMR_5:.2f} m3/s")

QNRCS_5, N5, Pe5, S_mm, Ia = metodo_nrcs(5, NC)
print(f"\nNRCS: S={S_mm:.2f} mm, Ia={Ia:.2f} mm, Pe total={Pe5.sum():.2f} mm")
print(f"  QNRCS(Tr=5) = {QNRCS_5:.2f} m3/s")

Qa = max(QMR_5, QNRCS_5)
metodo_adoptado = "Racional" if QMR_5>=QNRCS_5 else "NRCS"
print(f"\n=> Qdiseño = max(QMR,QNRCS) = {Qa:.2f} m3/s  (metodo {metodo_adoptado})")


print("\n=================== PARTE B: Tr del caudal limite (Q=42 m3/s) ===================")
for Tr_try, C_try in [(2,C_Tr2), (5,C_Tr5), (10,C_Tr10), (25,C_Tr25), (50,C_Tr50)]:
    qmr, *_ = metodo_racional(Tr_try, C_try)
    qnrcs, *_ = metodo_nrcs(Tr_try, NC)
    qmax = max(qmr,qnrcs)
    print(f"Tr={Tr_try:3d}: QMR={qmr:6.2f}  QNRCS={qnrcs:6.2f}  Qmax={qmax:6.2f} m3/s")


print("\n=================== PARTE C: area maxima urbanizable ===================")
Qc_target = 1.15*Qa
C_target = Qc_target/Qa*C_Tr5    # Q proporcional a C (i, A, tc fijos) => C_target = 1.15*C_Tr5
A2 = Area_km2*(C_target - C_Tr5)/(C_concreto_Tr5 - C_Tr5)
print(f"Qtarget = 1.15*Qa = {Qc_target:.2f} m3/s")
print(f"C_target = 1.15*C_Tr5 = {C_target:.4f}  (Q prop. a C, con i,A,tc fijos)")
print(f"C_concreto/techo (Tr=5) = {C_concreto_Tr5}")
print(f"A2 (area urbanizable maxima) = AT*(C_target-C_natural)/(C_concreto-C_natural) = {A2:.3f} km2")
print(f"  = {A2/Area_km2*100:.1f}% del area total")

print("\n=====================================================")
print(f"RESUMEN: Qdiseño(Tr=5)={Qa:.2f} m3/s (metodo {metodo_adoptado}) | A_urbana_max={A2:.3f} km2 ({A2/Area_km2*100:.1f}%)")
