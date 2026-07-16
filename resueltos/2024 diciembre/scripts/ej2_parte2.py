"""
Ejercicio 2, Partes 2 y 3 - Examen HHA 16/dic/2024
2) Periodo de retorno con que se inunda el camino (Qinund=50 m3/s) y tiempo
   que permanece inundado para un evento de Tr=25 anios.
3) Volumen minimo del embalse de retencion (= volumen de escorrentia total
   del evento de Tr=25 anios).

Reutiliza las mismas formulas y datos de ej2_parte1.py, generalizando el
calculo del hidrograma NRCS para un Tr cualquiera (aqui todo depende de Tr
solo a traves del coeficiente CT(Tr) del modelo de tormenta de diseno IDF).
"""
import numpy as np
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

Area_km2 = 7.5
dH_m = 90.0
L_m = 3800.0
L_km = L_m/1000
NC = 80
P310 = 90.0
floor_rate = 1.2
Qinund = 50.0   # m3/s, caudal a partir del cual el camino se inunda

S_channel_pct = dH_m / L_km / 10
tc_hs = 0.4 * (L_km**0.77) / (S_channel_pct**0.385)

def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

def CA(d, Ac_km2):
    return 1 - (0.3549*(d**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

S_mm = 25.4*((1000/NC)-10)
Ia = 0.2*S_mm

def hidrograma_NRCS(Tr):
    """Devuelve (t [hs], Qtot [m3/s], Pe_corr [mm por bloque]) para un Tr dado."""
    CTv = CT(Tr)
    dt = tc_hs/7
    n = np.arange(1,13)
    d_n = dt*n
    CD_n = np.array([CD(x) for x in d_n])
    CA_n = np.array([CA(x, Area_km2) for x in d_n])
    P_n = CD_n*CTv*CA_n*P310
    M_n = np.diff(np.concatenate(([0.0], P_n)))
    order = [12,10,8,6,4,2,1,3,5,7,9,11]
    N = np.array([M_n[idx-1] for idx in order])
    O = np.cumsum(N)
    Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
    Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
    deficit = np.maximum(N-Qinc, floor_rate*dt)
    Pe_corr = np.maximum(N - deficit, 0.0)

    tr_uh = dt
    Tp = tr_uh/2 + 0.6*tc_hs
    Tb = Tp*2.667
    qp = 2.08*Area_km2/Tp
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
    return t, Qtot, Pe_corr

# =====================================================================
# 2.1) Periodo de retorno con que se inunda el camino (Qmax_NRCS = Qinund)
# =====================================================================
def Qmax_de_Tr(Tr):
    _,Qtot,_ = hidrograma_NRCS(Tr)
    return Qtot.max()

for Tr_test in (10, 12, 25):
    print(f"Tr={Tr_test:>2} anios -> Qmax NRCS = {Qmax_de_Tr(Tr_test):.2f} m3/s")

def bisect(f, a, b, tol=1e-4, maxit=100):
    fa = f(a)
    for _ in range(maxit):
        m = (a+b)/2
        fm = f(m)
        if abs(fm) < tol or (b-a) < 1e-6:
            return m
        if (fa < 0) == (fm < 0):
            a, fa = m, fm
        else:
            b = m
    return (a+b)/2

Tr_inund = bisect(lambda Tr: Qmax_de_Tr(Tr)-Qinund, 5, 20)
print(f"\nTr exacto (interpolado) para Qmax=Qinund={Qinund} m3/s: {Tr_inund:.2f} anios")
Tr_diseno_camino = math.ceil(Tr_inund)
print(f"=> Como Tr=10 anios da Qmax<50 (no inunda) y Tr=12 da Qmax>50 (inunda),")
print(f"   el camino se inunda a partir de Tr = {Tr_diseno_camino} anios")

# =====================================================================
# 2.2) Tiempo que permanece inundado el camino para el evento de Tr=25
# =====================================================================
t25, Q25, Pe25 = hidrograma_NRCS(25)
above = Q25 > Qinund
idx = np.where(above)[0]
i1, i2 = idx[0], idx[-1]
t_sube = np.interp(Qinund, [Q25[i1-1], Q25[i1]], [t25[i1-1], t25[i1]])
t_baja = np.interp(Qinund, [Q25[i2+1], Q25[i2]], [t25[i2+1], t25[i2]])
dur_h = t_baja - t_sube
print(f"\nEvento Tr=25: Qmax = {Q25.max():.2f} m3/s en t={t25[np.argmax(Q25)]:.3f} hs")
print(f"Camino inundado (Q>{Qinund} m3/s) entre t={t_sube:.4f} hs y t={t_baja:.4f} hs")
print(f"Tiempo inundado = {dur_h:.4f} hs = {dur_h*60:.2f} min")

# Grafico del hidrograma de crecida Tr=25 con el umbral de inundacion
plt.figure(figsize=(9,5))
plt.plot(t25, Q25, 'b-', linewidth=2, label='Hidrograma de crecida (Tr=25 anios)')
plt.axhline(Qinund, color='r', linestyle='--', label=f'Q_inund = {Qinund:.0f} m3/s')
plt.fill_between(t25, Q25, Qinund, where=(Q25>Qinund), color='orange', alpha=0.3,
                  label=f'Camino inundado ({dur_h*60:.1f} min)')
plt.axvline(t_sube, color='k', linestyle=':', linewidth=1)
plt.axvline(t_baja, color='k', linestyle=':', linewidth=1)
plt.xlabel('t (hs)'); plt.ylabel('Q (m3/s)')
plt.title('Ej.2 Parte 2.2: Hidrograma de crecida Tr=25 anios y tiempo de inundacion del camino')
plt.legend(); plt.grid(True)
plt.tight_layout()
plt.savefig('ej2_hidrograma_Tr25.png', dpi=130)
print("\nGrafico guardado en ej2_hidrograma_Tr25.png")

# =====================================================================
# 3) Volumen minimo del embalse: volumen de escorrentia total del evento Tr=25
# =====================================================================
Vesc_m3 = Pe25.sum()*1000*Area_km2
print(f"\nVolumen de escorrentia total (Tr=25) = Pe_total * Area = "
      f"{Pe25.sum():.3f} mm * {Area_km2} km2 = {Vesc_m3:.1f} m3")
print(f"=> Volumen minimo del embalse de retencion = {Vesc_m3:.0f} m3")
