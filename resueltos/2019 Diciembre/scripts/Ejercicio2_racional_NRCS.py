"""
Ejercicio 2 - Examen HHA 16/dic/2019.
Cuenca en Colonia (X=350km, Y=6250km): Area=4.15 km2, Lcp=2.05 km, dH=38 m,
S_cuenca=1.95%, uso de suelo pastizales condicion hidrologica BUENA, unidad
de suelos Ecilda Paullier-Las Brujas (Tabla 3.1.5 -> Grupo Hidrologico C),
flujo concentrado.

Replica las formulas de la hoja "Calculos (grande)" de
"Eventos extremos.xlsx" (ver RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md)
en Python, para poder iterar comodamente las partes 2) y 3) (area urbanizable
maxima, y Tr de un caudal dado) sin rehacer la planilla a mano en cada paso.

1) Caudal de diseno de la alcantarilla, Tr=5 anios.
2) Maxima superficie urbanizable (concreto/techo) si el caudal de diseno
   puede aumentar hasta 20% (mismo Tr, mismo tc).
3) Periodo de retorno de un evento que en el escenario de 2) da Q=32 m3/s.
"""
import numpy as np
from scipy.optimize import brentq

# ---------------- datos de la cuenca ----------------
A_km2 = 4.15      # area (km2)
Lcp = 2.05        # long. cauce principal (km)
dH = 38.0         # desnivel del cauce principal (m)
P310 = 84.0       # mm, P(3h,10anios) leida de isoyetas (Fig 3.1.10) en X=350,Y=6250
NC = 74           # pastizales, condicion hidrologica BUENA, grupo C (Fig 3.1.20:
                  # fila "Pradera o pastizal", columna "C", condicion "Buena")
piso_infilt = 1.2 # mm/h (grupo C: igual que B/D, solo A usa 2.4 mm/h)

# Tabla 3.1.4 (Chow 1994) -- pastizales "Plano 0-2%" (S_cuenca=1.95% -> esta fila)
# y "Concreto/techo" (para la urbanizacion de la parte 2)
Tr_tab     = np.array([2, 5, 10, 25, 50, 100, 500], dtype=float)
C_past_tab = np.array([0.25, 0.28, 0.30, 0.34, 0.37, 0.41, 0.53])
C_ct_tab   = np.array([0.75, 0.80, 0.83, 0.88, 0.92, 0.97, 1.00])

def C_past(Tr): return np.interp(Tr, Tr_tab, C_past_tab)
def C_ct(Tr):   return np.interp(Tr, Tr_tab, C_ct_tab)

# ---------------- tiempo de concentracion (Kirpich/Ramser) ----------------
S_cauce = dH/Lcp/10   # % (OJO: distinto de S_cuenca=1.95%, que solo se usa para
                      # elegir la fila de la Tabla 3.1.4, "Plano 0-2%")
tc = 0.4*Lcp**0.77/S_cauce**0.385   # horas

# ---------------- IDF de Uruguay (Rodriguez Fontal / Genta) ----------------
def CD(d):
    return 0.6208*d/(d+0.0137)**0.5639 if d < 3 else 1.0287*d/(d+1.0293)**0.8083

def CT(Tr):
    return 0.5786 - 0.4312*np.log10(np.log(Tr/(Tr-1)))

def CA(A, d):
    return 1.0 - (0.3549*d**(-0.4272))*(1.0 - np.exp(-0.005792*A))

def i_diseno(Tr, d, A):
    return P310*CT(Tr)*CD(d)*CA(A, d)/d   # mm/h

# ---------------- Metodo Racional ----------------
def Q_racional(Tr, C, d=None):
    if d is None:
        d = tc
    i = i_diseno(Tr, d, A_km2)
    return C*i*A_km2*100/360, i   # A_km2*100 = area en ha

# ---------------- Metodo NRCS (bloque alterno + NC + HU triangular SCS) ----------------
def Q_nrcs(Tr, NC_):
    dt = tc/7.0
    S = 25.4*(1000.0/NC_ - 10.0)
    d_n = dt*np.arange(1, 13)
    P_acum = np.array([P310*CT(Tr)*CD(d)*CA(A_km2, d) for d in d_n])
    incr = np.diff(np.concatenate(([0.0], P_acum)))

    # bloque alterno: mayor incremento al bloque central (slot 7 de 12), alternando
    order_rank = np.argsort(-incr)                       # indices de incr, de mayor a menor
    slot_por_rank = [7, 6, 8, 5, 9, 4, 10, 3, 11, 2, 12, 1]
    tormenta = np.zeros(12)
    for rank, idx in enumerate(order_rank):
        tormenta[slot_por_rank[rank]-1] = incr[idx]

    P_torm_acum = np.cumsum(tormenta)
    Pe_acum = np.where(P_torm_acum <= 0.2*S, 0.0, (P_torm_acum-0.2*S)**2/(P_torm_acum+0.8*S))
    Pe_incr = np.diff(np.concatenate(([0.0], Pe_acum)))
    deficit = tormenta - Pe_incr
    Pe_final = np.where(deficit/dt >= piso_infilt, Pe_incr, tormenta - piso_infilt*dt)
    Pe_final = np.maximum(Pe_final, 0.0)

    tp = dt/2.0 + 0.6*tc
    tb = 8.0/3.0*tp
    qp = 0.208*A_km2/tp

    def hu(t):
        if t < 0:
            return 0.0
        if t <= tp:
            return qp*t/tp
        if t <= tb:
            return qp*(tb-t)/(tb-tp)
        return 0.0

    ts = np.arange(0, tb + 11*dt + dt/8, dt/8)
    Qtot = np.zeros_like(ts)
    for k in range(12):
        Qtot += Pe_final[k]*np.array([hu(t - k*dt) for t in ts])
    return Qtot.max(), Pe_final, tp, tb, qp

if __name__ == "__main__":
    print(f"S_cauce (Kirpich) = {S_cauce:.4f} %   tc = {tc:.4f} h = {tc*60:.1f} min")

    print("\n===== PARTE 1: Q de diseno, Tr=5 anios =====")
    Tr1 = 5.0
    Cp1 = C_past(Tr1)
    Q1_rac, i1 = Q_racional(Tr1, Cp1)
    Q1_nrcs, *_ = Q_nrcs(Tr1, NC)
    print(f"C(pastizal, Tr=5) = {Cp1:.3f}   i = {i1:.2f} mm/h")
    print(f"Q racional = {Q1_rac:.2f} m3/s   Q NRCS = {Q1_nrcs:.2f} m3/s")
    Qdis = max(Q1_rac, Q1_nrcs)
    print(f"20 min < tc < 1 h => se calculan ambos y se adopta el MAYOR: "
          f"Q_diseno = {Qdis:.2f} m3/s ({'Racional' if Q1_rac >= Q1_nrcs else 'NRCS'})")

    print("\n===== PARTE 2: area urbanizable maxima (+20% del caudal) =====")
    Qstar = 1.2*Qdis
    Cct1 = C_ct(Tr1)
    Cstar = Qstar*360/(i1*A_km2*100)
    x = (Cstar - Cp1)/(Cct1 - Cp1)
    print(f"Q* = 1.2 x {Qdis:.2f} = {Qstar:.2f} m3/s")
    print(f"C* objetivo = {Cstar:.4f}  (Cpast={Cp1:.3f}, Cct={Cct1:.3f})  => x = {x:.4f}")
    print(f"Area urbanizable maxima = {x*A_km2:.4f} km2 = {x*A_km2*100:.2f} ha")

    print("\n===== PARTE 3: Tr para Q=32 m3/s (escenario urbanizado de la parte 2) =====")
    def residuo_Tr(Tr):
        Cw = C_past(Tr)*(1-x) + C_ct(Tr)*x
        Qr, _ = Q_racional(Tr, Cw)
        return Qr - 32.0

    Tr_sol = brentq(residuo_Tr, 5, 100)
    Cw_s = C_past(Tr_sol)*(1-x) + C_ct(Tr_sol)*x
    Qr_s, _ = Q_racional(Tr_sol, Cw_s)
    print(f"Tr = {Tr_sol:.2f} anios  (C*={Cw_s:.4f}, Q={Qr_s:.2f} m3/s)")
