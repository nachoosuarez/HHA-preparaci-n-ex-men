"""
Ejercicio 2, Parte 2 - Examen HHA 2024 febrero
Una vez construida la alcantarilla (capacidad fija = Q diseno de la
Parte 1), una modificacion del cauce principal aumenta el tiempo de
concentracion un 35%. Se pide el periodo de retorno Tr cuyo caudal NRCS,
con el NUEVO tc, iguala al caudal de diseno ya fijado por la Parte 1
(la alcantarilla ya esta construida con esa capacidad).

Se itera Tr (Buscar Objetivo, ver COMO_USAR_EVENTOS_EXTREMOS.md #6.9)
hasta que Qmax_NRCS(tc_nuevo, Tr) == Qdiseno.
"""
import numpy as np
import math

Area_km2 = 6.3
P310 = 98.0
NC = 86.5
floor_rate = 1.2
Qdiseno = 72.08   # m3/s, adoptado en la Parte 1 (metodo NRCS > Racional)

tc_hs_original = 0.6050
tc_hs_nuevo = 1.35*tc_hs_original
print(f"tc nuevo = 1.35 * {tc_hs_original:.4f} hs = {tc_hs_nuevo:.4f} hs = {tc_hs_nuevo*60:.2f} min")

def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

def CA(d, Ac_km2):
    return 1 - (0.3549*(d**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

def Qmax_NRCS(tc_hs, Tr):
    CT_ = CT(Tr)
    dt = tc_hs/7
    n = np.arange(1,13)
    d_n = dt*n
    CD_n = np.array([CD(x) for x in d_n])
    CA_n = np.array([CA(x, Area_km2) for x in d_n])
    P_n = CD_n*CT_*CA_n*P310
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
    Tb = Tp*2.667
    qp_cm = 2.08*Area_km2/Tp
    a = (qp_cm/10)/Tp
    c = -(qp_cm/10)/(1.67*Tp)
    dd = qp_cm/10 + (qp_cm/10)/1.67
    def UH(x):
        return a*x if x<Tp else max(c*x+dd, 0.0)
    step = tr_uh/8
    Nsteps = int(math.ceil((11*tr_uh+Tb)/step)) + 40
    t = np.arange(0, Nsteps)*step
    Qtot = np.zeros_like(t)
    for k in range(12):
        shift = k*tr_uh
        Qtot += Pe_corr[k]*np.array([UH(x-shift) if x>=shift else 0.0 for x in t])
    return Qtot.max()

# --- barrido de Tr para encontrar el que da Qmax_NRCS == Qdiseno ---
print(f"\nObjetivo: Qmax_NRCS(tc_nuevo, Tr) = Qdiseno = {Qdiseno:.2f} m3/s\n")
for Tr_try in [5,8,10,11,12,13,14,15,20]:
    q = Qmax_NRCS(tc_hs_nuevo, Tr_try)
    print(f"  Tr={Tr_try:3d} anios -> Qmax_NRCS = {q:.2f} m3/s")

# bisection fina
lo, hi = 2.0, 50.0
for _ in range(60):
    mid = (lo+hi)/2
    q = Qmax_NRCS(tc_hs_nuevo, mid)
    if q < Qdiseno:
        lo = mid
    else:
        hi = mid
Tr_sol = (lo+hi)/2
print(f"\nTr (interpolado) = {Tr_sol:.2f} anios -> Qmax_NRCS = {Qmax_NRCS(tc_hs_nuevo, Tr_sol):.3f} m3/s")
print(f"Tr entero mas cercano que verifica Qmax_NRCS >= Qdiseno: Tr = {math.ceil(Tr_sol)} anios "
      f"(Qmax_NRCS={Qmax_NRCS(tc_hs_nuevo, math.ceil(Tr_sol)):.2f} m3/s)")
