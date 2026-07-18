"""
Ejercicio 2, Partes 2.1 y 2.2 - Examen HHA 15/dic/2022

2.1) Evento de precipitacion REGISTRADO (hietograma real, cronologico, NO
     bloque alterno) en la misma cuenca de la Parte 1. Se registraron
     P5d=25mm en los 5 dias previos (julio, estacion inactiva) -> se
     determina la condicion de humedad antecedente (AMC) para decidir si
     corregir el NC, y se calcula el caudal maximo generado (metodo NRCS,
     mismo tc/hidrograma unitario que la Parte 1, pero con el hietograma
     REAL en vez de la tormenta de diseno por bloque alterno).
2.2) Periodo de retorno asociado a la intensidad maxima registrada en el
     pluviografo (bloque de mayor P del hietograma).
"""
import numpy as np
import math

Area_km2 = 7.6
NC = 89          # Grupo D, pastizales cond. mala (igual que Parte 1)
floor_rate = 1.2
P310 = 76.0
tc_hs = 0.5844
dt = tc_hs/7     # =0.0835 hs = 5.01 min : coincide con el ancho de bloque del hietograma (5 min)

def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr_):
    return 0.5786 - 0.4312*math.log10(math.log(Tr_/(Tr_-1)))

# ---------------- Parte 2.1: AMC ----------------
P5d = 25.0   # mm, en los 5 dias previos
estacion = "inactiva (julio)"
# Umbrales AMC (estacion inactiva): AMC I <12.7 ; AMC II 12.7-27.94 ; AMC III >27.94
if P5d < 12.7:
    amc = "I (seco)"
elif P5d <= 27.94:
    amc = "II (medio, NC sin corregir)"
else:
    amc = "III (humedo)"
print(f"P5d={P5d} mm, estacion {estacion} => condicion AMC {amc}")
print(f"=> NC se mantiene en {NC} (sin correccion)")

# Hietograma REAL registrado (cronologico, 12 bloques de 5 min)
P_obs = np.array([2.1,2.3,2.7,3.2,4.2,7.0,16.5,5.1,3.6,2.9,2.5,2.2])
print(f"\nHietograma observado (12 bloques x 5 min): total = {P_obs.sum():.2f} mm")

S_mm = 25.4*((1000/NC)-10)
Ia = 0.2*S_mm
O = np.cumsum(P_obs)
Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
deficit = np.maximum(P_obs-Qinc, floor_rate*dt)
Pe_corr = np.maximum(P_obs - deficit, 0.0)
print(f"S={S_mm:.3f} mm, Ia={Ia:.3f} mm, SUMA Pe (evento real) = {Pe_corr.sum():.3f} mm")

tr_uh = dt
Tp = tr_uh/2 + 0.6*tc_hs
Tb = Tp*2.667
qp = 0.208*Area_km2/Tp

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

Qmax_evento = Qtot.max()
tQmax = t[np.argmax(Qtot)]
print(f"\nQmax generado por el evento REGISTRADO = {Qmax_evento:.3f} m3/s en t={tQmax:.3f} hs")

# ---------------- Parte 2.2: Tr de la intensidad maxima ----------------
Pmax_block = 16.5   # mm, bloque 30-35 min (el mas intenso del hietograma)
d_block_h = 5/60    # 5 min en horas
CD_block = CD(d_block_h)
# CA=1: es una intensidad puntual (pluviografo), no una precipitacion de diseno sobre el area
CT_target = Pmax_block/(P310*CD_block)
print(f"\nBloque mas intenso: P={Pmax_block} mm en d={d_block_h*60:.0f} min")
print(f"CD(d)={CD_block:.4f} ; CT objetivo = P/(P310*CD) = {CT_target:.4f}")

# Invertir CT(Tr) numericamente (biseccion manual, sin scipy)
def biseccion(f, lo, hi, iters=200):
    flo = f(lo)
    for _ in range(iters):
        mid = (lo+hi)/2
        fm = f(mid)
        if (fm > 0) == (flo > 0):
            lo, flo = mid, fm
        else:
            hi = mid
    return (lo+hi)/2

Tr_exact = biseccion(lambda Tr_: CT(Tr_)-CT_target, 1.001, 500)
print(f"Tr (inversion numerica) = {Tr_exact:.2f} anios")
for Tr_test in [10,15,20,25,50]:
    print(f"  CT({Tr_test})={CT(Tr_test):.4f}")
