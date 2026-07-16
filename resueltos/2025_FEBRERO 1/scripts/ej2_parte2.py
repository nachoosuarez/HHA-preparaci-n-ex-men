import numpy as np
import math

d = np.load('part1.npz')
Area_km2=float(d['Area_km2']); tc_hs=float(d['tc_hs']); P310=float(d['P310'])
NC=float(d['NC']); S_mm=float(d['S_mm']); Ia=float(d['Ia']); floor_rate=float(d['floor_rate'])
dt=float(d['dt']); Tp=float(d['Tp']); Tb=float(d['Tb']); qp=float(d['qp']); tr_uh=float(d['tr_uh'])
Q_diseno = float(d['Qmax_NRCS'])

def CD(dur):
    if dur <= 3:
        return 0.6208*dur/((dur+0.0137)**0.5639)
    else:
        return 1.0287*dur/((dur+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

def CA(dur, Ac_km2):
    return 1 - (0.3549*(dur**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

# ---------- Hietograma observado (evento registrado) ----------
Pobs = np.array([1.6,3.2,4.1,5.8,8.7,12.2,21.7,10.5,6.2,4.6,3.6,2.0])
dt_obs = 7/60  # 7 min en horas (igual Delta t que el HU de la Parte 1: mismo tc)
n_blocks = len(Pobs)
print(f"Hietograma observado: {n_blocks} bloques de {dt_obs*60:.0f} min, total={Pobs.sum():.2f} mm")
print(f"Bloque de intensidad maxima: P={Pobs.max():.1f} mm (bloque {np.argmax(Pobs)+1}, "
      f"t={np.argmax(Pobs)*7}-{(np.argmax(Pobs)+1)*7} min)")

# ---------- 2.1) Periodo de retorno de la intensidad maxima ----------
Pmax = Pobs.max()
CD_obs = CD(dt_obs)
CA_obs = 1.0   # dato puntual (pluviometro), no lluvia de diseño de area
CT_obs = Pmax/(P310*CD_obs*CA_obs)
print(f"\n--- 2.1) Tr de la intensidad maxima ---")
print(f"d = {dt_obs*60:.0f} min = {dt_obs:.4f} hs ; CD(d) = {CD_obs:.4f} ; CA=1")
print(f"CT(Tr) = Pmax/(P310*CD*CA) = {CT_obs:.4f}")

def bisect(f, lo, hi, tol=1e-9, maxit=200):
    flo = f(lo)
    for _ in range(maxit):
        mid = (lo+hi)/2
        fm = f(mid)
        if abs(fm) < tol or (hi-lo) < tol:
            return mid
        if (fm>0) == (flo>0):
            lo, flo = mid, fm
        else:
            hi = mid
    return (lo+hi)/2

Tr_obs = bisect(lambda Tr: CT(Tr)-CT_obs, 1.01, 500)
print(f"Tr (invirtiendo CT(Tr)) = {Tr_obs:.2f} anios")

# ---------- 2.2) Qmax del evento (AMC segun humedad antecedente) ----------
P5d = 49.0  # mm, precipitacion acumulada 5 dias previos
# Verano = estacion de crecimiento; rango AMC II (Fig 3.1.21 Teorico) = 35.6-53.3 mm
AMC_II_lo, AMC_II_hi = 35.6, 53.3
if AMC_II_lo <= P5d <= AMC_II_hi:
    amc = 'II'
elif P5d < AMC_II_lo:
    amc = 'I'
else:
    amc = 'III'
print(f"\n--- 2.2) Qmax del evento ---")
print(f"P5d = {P5d} mm, estacion de crecimiento, rango AMC II=[{AMC_II_lo},{AMC_II_hi}] mm => AMC {amc}")
print("=> NC no se corrige (se usa el mismo NC=86, S y Ia de la Parte 1)")

O = np.cumsum(Pobs)
Pe_cum = np.where(O<=Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
deficit = np.maximum(Pobs-Qinc, floor_rate*dt_obs)
Pe_corr = Pobs - deficit
Pe_corr = np.maximum(Pe_corr, 0.0)
print(f"Precipitacion efectiva total (evento) = {Pe_corr.sum():.3f} mm")

def UH(x):
    a = (qp/10)/Tp
    c = -(qp/10)/(1.67*Tp)
    dd = qp/10 + (qp/10)/1.67
    return a*x if x<Tp else max(c*x+dd, 0.0)

step = tr_uh/8
Nsteps = int(math.ceil((11*tr_uh+Tb)/step)) + 60
t = np.arange(0, Nsteps)*step
Qtot = np.zeros_like(t)
for k in range(n_blocks):
    shift = k*tr_uh
    Qtot += Pe_corr[k]*np.array([UH(x-shift) if x>=shift else 0.0 for x in t])

Qmax_evento = Qtot.max()
tQmax = t[np.argmax(Qtot)]
print(f"Qmax evento = {Qmax_evento:.2f} m3/s en t = {tQmax:.3f} hs")

# ---------- 2.3) Tiempo durante el cual se supera Qdiseno ----------
print(f"\n--- 2.3) Comparacion con Qdiseno={Q_diseno:.2f} m3/s (Qmax NRCS, Parte 1) ---")
supera = Qtot > Q_diseno
if supera.any():
    idxs = np.where(supera)[0]
    t_ini = t[idxs[0]-1] + (Q_diseno-Qtot[idxs[0]-1])/(Qtot[idxs[0]]-Qtot[idxs[0]-1])*step if idxs[0]>0 else t[idxs[0]]
    # mejor: interpolar cruces exactos
    def cruce(i0,i1):
        return np.interp(Q_diseno, [Qtot[i0],Qtot[i1]], [t[i0],t[i1]])
    t_ini = cruce(idxs[0]-1, idxs[0])
    t_fin = cruce(idxs[-1], idxs[-1]+1)
    print(f"Q(t) > Qdiseno entre t={t_ini:.3f} hs y t={t_fin:.3f} hs")
    print(f"Duracion en que se supera Qdiseno = {(t_fin-t_ini)*60:.1f} min = {t_fin-t_ini:.3f} hs")
else:
    print("El evento no supera el caudal de diseno")
