"""
Ejercicio 3 - Examen HHA 22/jul/2019

Cuenca en Florida (X=480000 m, Y=6250000 m), Area=75 km2, Lcp=12500 m,
dH=70 m, S media cuenca=1.8%. Uso de suelo: 75% pastizales + 25% cultivo
en hileras rectas, ambos en condicion hidrologica BUENA. Suelo Cerro
Chato -> Grupo Hidrologico B. Flujo concentrado.

1) Caudal de diseno de una obra de drenaje (pequeno puente), Tr=100 anios.
2) Ocurre un evento registrado (hietograma de 12 bloques de 0.5h):
   a) Periodo de retorno de la intensidad maxima del evento.
   b) Caudal maximo generado por ese evento (P5d=62mm en junio, estacion
      inactiva -> corregir NC por AMC), y verificar si supera el caudal
      de diseno de la Parte 1.

Metodologia: replica la logica de la hoja "Calculos (chica)" de
Eventos extremos.xlsx (Numero de Curva PONDERADO por uso de suelo mixto,
RESUMEN_TEORICO.md B5) y el mismo patron de
resueltos/2024 diciembre/scripts/ej2_parte1.py (tormenta de diseno por
bloque alterno + Numero de Curva + hidrograma unitario triangular SCS),
mas la inversion de Tr de un evento observado (B3, con CA incluido por
ser un evento sobre TODA la cuenca, no un dato puntual de pluviografo) y
la correccion de NC por condicion de humedad antecedente AMC (B6).
"""
import numpy as np
import math

# ---------- DATOS DE LA CUENCA ----------
Area_km2 = 75.0
dH_m = 70.0
L_m = 12500.0
L_km = L_m/1000
Tr_diseno = 100          # anios
P310 = 82.0              # mm, isoyeta P(3h,10a) en Florida (X=480000,Y=6250000) - sol. oficial
floor_rate = 1.2         # mm/h, infiltracion minima grupos B,C,D (grupo A = 2.4 mm/h)

# ---------- NUMERO DE CURVA PONDERADO (uso de suelo mixto) ----------
# Tabla 3.1.20 del Teorico, Grupo Hidrologico B (suelo Cerro Chato):
NC_pastizal = 61   # "Pradera o pastizal", condicion hidrologica Buena, sin tratamiento (SR), grupo B
NC_cultivo  = 78   # "Cultivos en hileras", tratamiento SR (hileras rectas), condicion Buena, grupo B
frac_pastizal = 0.75
frac_cultivo  = 0.25
NC = frac_pastizal*NC_pastizal + frac_cultivo*NC_cultivo
print(f"NC ponderado = {frac_pastizal}*{NC_pastizal} + {frac_cultivo}*{NC_cultivo} = {NC:.2f}")

# ---------- TIEMPO DE CONCENTRACION (Kirpich / Ramser-Kirpich) ----------
S_channel_pct = dH_m / L_km / 10
tc_hs = 0.4 * (L_km**0.77) / (S_channel_pct**0.385)
tc_min = tc_hs*60
print(f"S cauce principal (Kirpich) = {S_channel_pct:.4f} %")
print(f"tc = {tc_hs:.4f} hs = {tc_min:.2f} min")
print(f"tc > 1 hora => corresponde SOLO el metodo NRCS (Teorico HHA 3.1.5); no se calcula Racional.")

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

def brentq(f, a, b, tol=1e-10):
    fa, fb = f(a), f(b)
    for _ in range(200):
        m = (a+b)/2
        fm = f(m)
        if abs(fm) < tol:
            return m
        if (fa < 0) == (fm < 0):
            a, fa = m, fm
        else:
            b, fb = m, fm
    return (a+b)/2


def hidrograma_NRCS(Pe_corr, dt, tc_hs, Area_km2):
    """Convoluciona la serie Pe_corr (mm, uno por bloque de ancho dt) con el
    hidrograma unitario triangular SCS y devuelve (Qmax, t_Qmax, t, Qtot)."""
    Tp = dt/2 + 0.6*tc_hs
    Tb = Tp*2.667
    qp = 2.08*Area_km2/Tp   # convencion "2.08" (cm) consistente con dividir /10 abajo
    a = (qp/10)/Tp
    c = -(qp/10)/(1.67*Tp)
    dd = qp/10 + (qp/10)/1.67

    def UH(x):
        return a*x if x < Tp else max(c*x+dd, 0.0)

    n = len(Pe_corr)
    step = dt/8
    Nsteps = int(math.ceil(((n-1)*dt+Tb)/step)) + 40
    t = np.arange(0, Nsteps)*step
    Qtot = np.zeros_like(t)
    for k in range(n):
        shift = k*dt
        Qtot += Pe_corr[k]*np.array([UH(x-shift) if x >= shift else 0.0 for x in t])
    imax = np.argmax(Qtot)
    return Qtot[imax], t[imax], Tp, Tb, qp


# =====================================================================
# PARTE 1: Caudal de diseno, Tr=100 anios (metodo NRCS unicamente)
# =====================================================================
print("\n" + "="*70)
print("PARTE 1: Caudal de diseno de la obra de drenaje (Tr=100 anios)")
print("="*70)

CT100 = CT(Tr_diseno)
print(f"CT(Tr=100) = {CT100:.4f}")

dt = tc_hs/7
n = np.arange(1, 13)
d_n = dt*n
CD_n = np.array([CD(x) for x in d_n])
CA_n = np.array([CA(x, Area_km2) for x in d_n])
P_n = CD_n*CT100*CA_n*P310
M_n = np.diff(np.concatenate(([0.0], P_n)))

order = [12, 10, 8, 6, 4, 2, 1, 3, 5, 7, 9, 11]   # bloque alterno, pico al centro
N = np.array([M_n[idx-1] for idx in order])
print(f"Tormenta de diseno (bloque alterno, dt={dt:.4f} hs = {dt*60:.2f} min): total={N.sum():.2f} mm")

S_mm = 25.4*((1000/NC)-10)
Ia = 0.2*S_mm
print(f"S = {S_mm:.3f} mm ; Ia = 0.2S = {Ia:.3f} mm (NC={NC:.2f})")

O = np.cumsum(N)
Pe_cum = np.where(O <= Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
deficit = np.maximum(N-Qinc, floor_rate*dt)
Pe_corr = np.maximum(N - deficit, 0.0)
print(f"SUMA Pe corregido (con piso de infiltracion {floor_rate} mm/h) = {Pe_corr.sum():.3f} mm")

Qmax_diseno, tQmax, Tp, Tb, qp = hidrograma_NRCS(Pe_corr, dt, tc_hs, Area_km2)
print(f"Hidrograma unitario SCS: Tp={Tp:.4f} hs, Tb={Tb:.4f} hs, qp={qp:.4f} m3/s/cm")
print(f"\n>>> RESULTADO PARTE 1: Qmax diseno (NRCS, Tr=100) = {Qmax_diseno:.1f} m3/s "
      f"en t={tQmax:.2f} hs <<<")

# =====================================================================
# PARTE 2.a: Periodo de retorno de la intensidad (precipitacion) maxima
#            del evento registrado
# =====================================================================
print("\n" + "="*70)
print("PARTE 2.a: Periodo de retorno de la precipitacion maxima registrada")
print("="*70)

# Hietograma REGISTRADO (12 bloques de 0.5 hs, orden cronologico real)
P_obs = np.array([3, 5, 8, 10, 13, 21, 49, 16, 9, 7, 5, 3], dtype=float)
dt_obs = 0.5
print(f"Hietograma observado (dt={dt_obs} hs): {list(P_obs)} mm ; total={P_obs.sum():.0f} mm")

Pmax = P_obs.max()
d_Pmax = dt_obs   # duracion del bloque de mayor P (0.5 hs)
print(f"Bloque mas intenso: P={Pmax:.0f} mm en d={d_Pmax} hs")

CD_max = CD(d_Pmax)
CA_max = CA(d_Pmax, Area_km2)
# CA se incluye (a diferencia de un dato PUNTUAL de pluviografo) porque este
# es un evento registrado sobre TODA la cuenca (el mismo que se usa en la
# parte 2.b para generar el caudal en el punto de cierre), no una lectura
# puntual de pluviometro (RESUMEN_TEORICO.md B3).
CT_target = Pmax/(P310*CD_max*CA_max)
print(f"CD({d_Pmax}h)={CD_max:.4f} ; CA({d_Pmax}h,{Area_km2}km2)={CA_max:.4f}")
print(f"CT objetivo = Pmax/(P310*CD*CA) = {Pmax:.0f}/({P310}*{CD_max:.4f}*{CA_max:.4f}) = {CT_target:.4f}")

Tr_evento = brentq(lambda x: CT(x)-CT_target, 1.001, 2000)
print(f"\n>>> RESULTADO PARTE 2.a: Tr (invirtiendo CT(Tr), biseccion) = {Tr_evento:.1f} anios <<<")
print("(se adopta el Tr tabulado mas cercano: 200 o 250 anios)")

# =====================================================================
# PARTE 2.b: Caudal maximo generado por el evento registrado, con
#            correccion de NC por condicion de humedad antecedente (AMC)
# =====================================================================
print("\n" + "="*70)
print("PARTE 2.b: Caudal maximo del evento registrado (con AMC)")
print("="*70)

P5d = 62.0  # mm, precipitacion acumulada en los 5 dias previos (junio)
print(f"P5d = {P5d} mm, junio (estacion INACTIVA en Uruguay)")
# Umbrales AMC, estacion inactiva (RESUMEN_TEORICO.md B6):
#  AMC I  : P5d < 12.7 mm
#  AMC II : 12.7 <= P5d <= 27.94 mm
#  AMC III: P5d > 27.94 mm
if P5d > 27.94:
    amc = 'III'
elif P5d < 12.7:
    amc = 'I'
else:
    amc = 'II'
print(f"P5d={P5d} mm > 27.94 mm (estacion inactiva) => AMC {amc}")

NC_III = 23.0*NC/(10+0.13*NC)
print(f"NC(II)={NC:.2f} (tabla, ponderado) -> NC(III) = 23*NC(II)/(10+0.13*NC(II)) = {NC_III:.2f}")

S_mm3 = 25.4*((1000/NC_III)-10)
Ia3 = 0.2*S_mm3
print(f"S(NC=III) = {S_mm3:.3f} mm ; Ia = {Ia3:.3f} mm")

# Se aplica el hietograma REGISTRADO en su orden cronologico real (sin
# reordenar por bloque alterno), con el mismo hidrograma unitario ya
# calculado en la Parte 1 (mismo tc, mismo dt=0.5h -- coincide con el
# ancho de bloque del propio hietograma observado).
O2 = np.cumsum(P_obs)
Pe_cum2 = np.where(O2 <= Ia3, 0.0, (O2-Ia3)**2/(O2+0.8*S_mm3))
Qinc2 = np.diff(np.concatenate(([0.0], Pe_cum2)))
deficit2 = np.maximum(P_obs-Qinc2, floor_rate*dt_obs)
Pe_corr2 = np.maximum(P_obs - deficit2, 0.0)
print(f"SUMA Pe corregido (evento registrado, NC=III) = {Pe_corr2.sum():.3f} mm")

Qmax_evento, tQmax2, Tp2, Tb2, qp2 = hidrograma_NRCS(Pe_corr2, dt_obs, tc_hs, Area_km2)
print(f"\n>>> RESULTADO PARTE 2.b: Qmax evento registrado = {Qmax_evento:.1f} m3/s en t={tQmax2:.2f} hs <<<")

if Qmax_evento > Qmax_diseno:
    print(f"\nQmax evento ({Qmax_evento:.1f} m3/s) > Qmax diseno ({Qmax_diseno:.1f} m3/s, Tr=100)")
    print(">>> LA CONDICION DE DISENO DE LA OBRA FUE SOBREPASADA <<<")
else:
    print(f"\nQmax evento ({Qmax_evento:.1f} m3/s) <= Qmax diseno ({Qmax_diseno:.1f} m3/s)")
    print(">>> La obra NO fue sobrepasada <<<")
