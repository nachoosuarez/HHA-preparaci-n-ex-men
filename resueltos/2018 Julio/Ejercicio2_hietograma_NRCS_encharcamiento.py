"""Ejercicio2_hietograma_NRCS_encharcamiento.py -- HHA examen 23 julio 2018, Ejercicio 2

Hietograma observado en Canelones (X=480 km, Y=6200 km), 12 de diciembre,
bloques de 10 min: P = 3, 6, 12, 26, 9, 4 mm.

a) Periodo de retorno de la intensidad maxima de todo el evento (bloque
   de 26 mm en 10 min), invirtiendo las curvas IDF de Uruguay (P(3,10)
   leido de isoyetas, CD(d), CT(Tr), CA=1 por ser dato puntual).
b) Volumen infiltrado (mm) con el modelo NRCS: NC de tabla (hierba con
   baja densidad y arbustos, grupo hidrologico C), corregido por AMC
   segun P5d=58mm (evento en diciembre = estacion de crecimiento).
c) Tiempo de encharcamiento definido y estimado bajo el mismo modelo
   NRCS (no se dan parametros de Horton en este examen).
"""
import numpy as np
from scipy.optimize import brentq

# ---------------- Datos del hietograma ----------------
t_end = np.array([10, 20, 30, 40, 50, 60])   # min, fin de cada bloque
P_block = np.array([3, 6, 12, 26, 9, 4])      # mm por bloque
dt_block = 10.0  # min, todos los bloques duran 10 min
P_cum = np.cumsum(P_block)
print("Tabla hietograma:")
for te, pb, pc in zip(t_end, P_block, P_cum):
    print(f"  t={te:2d} min   P_bloque={pb:5.1f} mm   P_acum={pc:5.1f} mm")

P_total = P_cum[-1]
print(f"\nP_total del evento = {P_total} mm")

# ================= PARTE a) Tr de la intensidad maxima =================
print("\n--- PARTE a) ---")
i_max_idx = np.argmax(P_block)
P_obs = P_block[i_max_idx]           # 26 mm
d_h = dt_block/60.0                  # 10 min = 1/6 h
P310 = 90.0   # mm, isoyetas Fig 3.1.10 en X=480km, Y=6200km (Canelones) -- ver RESOLUCION.md
CA = 1.0      # dato puntual de pluviografo, sin area que promediar

def CD(d):
    if d < 3:
        return 0.6208*d/(d+0.0137)**0.5639
    else:
        return 1.0287*d/(d+1.0293)**0.8083

def CT(Tr):
    return 0.5786 - 0.4312*np.log10(np.log(Tr/(Tr-1)))

CD_d = CD(d_h)
CT_obj = P_obs/(P310*CD_d*CA)
print(f"Bloque mas intenso: P={P_obs} mm en d={dt_block} min = {d_h:.4f} h")
print(f"P(3,10) = {P310} mm (isoyetas) ; CD({d_h:.4f}h) = {CD_d:.4f} ; CA = {CA}")
print(f"CT objetivo = P_obs/(P310*CD*CA) = {CT_obj:.4f}")

Tr = brentq(lambda Tr: CT(Tr)-CT_obj, 1.001, 500)
print(f"Tr (invirtiendo CT(Tr)) = {Tr:.2f} anios")

# ================= PARTE b) Volumen infiltrado NRCS =================
print("\n--- PARTE b) ---")
NC_II = 71.0   # Tabla 3.1.20: "Hierba con baja densidad y arbustos", Grupo Hidrologico C
P5d = 58.0     # mm, precipitacion en los 5 dias previos
# evento el 12 de diciembre -> Uruguay, hemisferio sur -> estacion de crecimiento (primavera-verano)
umbral_I, umbral_III = 35.56, 53.34   # mm, estacion de crecimiento
if P5d < umbral_I:
    amc = "I"
elif P5d <= umbral_III:
    amc = "II"
else:
    amc = "III"
print(f"P5d = {P5d} mm, evento en diciembre (estacion de crecimiento) -> AMC {amc}")

if amc == "III":
    NC = 23.0*NC_II/(10+0.13*NC_II)
elif amc == "I":
    NC = 4.2*NC_II/(10-0.058*NC_II)
else:
    NC = NC_II
S = 25400.0/NC - 254.0
Ia = 0.2*S
print(f"NC(II)={NC_II} -> NC({amc})={NC:.2f}")
print(f"S = 25400/NC-254 = {S:.2f} mm ; Ia = 0.2*S = {Ia:.3f} mm")

if P_total > Ia:
    Pe = (P_total-Ia)**2/(P_total-Ia+S)
else:
    Pe = 0.0
Vinf = P_total - Pe
print(f"Pe (evento completo, P_total={P_total} mm) = {Pe:.2f} mm")
print(f"Volumen infiltrado = P_total - Pe = {Vinf:.2f} mm")

# ================= PARTE c) Tiempo de encharcamiento (NRCS) =================
print("\n--- PARTE c) ---")
print("t_enc = instante en que la precipitacion acumulada P(t) alcanza Ia")
print(f"Ia = {Ia:.3f} mm")
# localizar el bloque donde P_cum cruza Ia
idx = np.searchsorted(P_cum, Ia)
t_prev = 0 if idx==0 else t_end[idx-1]
P_prev = 0 if idx==0 else P_cum[idx-1]
t_next = t_end[idx]
rate = P_block[idx]/dt_block   # mm/min en ese bloque
t_enc = t_prev + (Ia-P_prev)/rate
print(f"Bloque donde P_acum cruza Ia: entre t={t_prev} min (P_acum={P_prev} mm) y t={t_next} min")
print(f"t_enc = {t_prev} + (Ia-P_acum_prev)/intensidad_bloque = {t_enc:.3f} min = {t_enc/60:.4f} h")
