import numpy as np
import math

# ---------- DATOS ----------
A_km2 = 3.21
tc_hs = 0.76
D_hs  = 5/60   # duracion del pulso de lluvia efectiva = ancho de bloque del hietograma (5 min)

Pef = np.array([0.0, 2.3, 0.0])  # mm, bloques T=0-5,5-10,10-15 min

# ---------- 2.2) Hidrograma unitario triangular SCS ----------
Tp = D_hs/2 + 0.6*tc_hs
Tb = Tp*8/3          # = 2.667*Tp (forma exacta 8/3 usada en la sol. oficial)
Qp = 0.208*A_km2/Tp  # m3/s por mm de lluvia efectiva (0.208 = 2.08/10, forma en mm en vez de cm)

print(f"Tp = {Tp:.4f} hs = {Tp*60:.2f} min")
print(f"Tb = {Tb:.4f} hs = {Tb*60:.2f} min")
print(f"Qp = {Qp:.4f} m3/s por mm de Pe")

def UH_mm(x):
    # hidrograma unitario (para 1 mm de lluvia efectiva) en funcion del tiempo x (hs) desde el inicio del pulso
    if x < 0:
        return 0.0
    if x < Tp:
        return Qp*x/Tp
    if x < Tb:
        return Qp*(Tb-x)/(Tb-Tp)
    return 0.0

# ---------- 2.3) Hidrograma del evento (convolucion con los 3 bloques) ----------
step = D_hs/20
Tmax = D_hs*len(Pef) + Tb + 0.2
t = np.arange(0, Tmax, step)
Q = np.zeros_like(t)
for k, pe in enumerate(Pef):
    if pe == 0:
        continue
    shift = k*D_hs
    Q += pe*np.array([UH_mm(x-shift) for x in t])

Qmax = Q.max()
tQmax = t[np.argmax(Q)]
print(f"\nQmax = {Qmax:.4f} m3/s en t = {tQmax:.4f} hs = {tQmax*60:.2f} min")

# Verificacion directa (un unico bloque no nulo): Qmax = Qp * Pef_max
print(f"Verificacion directa: Qp*Pef = {Qp*Pef.max():.4f} m3/s")

print("\n--- Hidrograma del evento (puntos cada 5 min) ---")
for tt in np.arange(0, min(Tmax, 90/60), 5/60):
    qq = np.interp(tt, t, Q)
    print(f"  t={tt*60:5.1f} min  Q={qq:.3f} m3/s")
print(f"  t={( D_hs + Tb)*60:5.1f} min  Q~=0 (fin de la base del hidrograma)")
