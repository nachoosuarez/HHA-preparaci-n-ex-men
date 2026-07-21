"""
Ejercicio 3 - Examen HHA 22/feb/2019 ("2019 febrero 2")

Cuenca de la canada "Sin Nombre", departamento de Canelones, punto de
cierre X=470 km, Y=6212.5 km (delimitada sobre la carta topografica SGM,
curvas de nivel cada 5 m -- ver nota sobre la Parte 1 en el RESOLUCION.md).

Tabla del enunciado: Area=4.3 km2, DeltaH=45 m, L(cauce ppal)=2150 m,
Grupo Hidrologico C, S=1.9% (pendiente MEDIA de la cuenca -- para
Kirpich se usa la pendiente del CAUCE PRINCIPAL, DeltaH/L/10, no esta S).

Uso de suelo: 70% pastizales en condiciones hidrologicas OPTIMAS + 30%
cultivos en hileras rectas (condicion hidrologica BUENA). Tr=10 anios,
flujo concentrado.

Se piden ambos metodos (Racional y NRCS) porque 20 min < tc < 1 h
(RESUMEN_TEORICO.md S:B4) y se adopta el MAYOR caudal.

Ver RESUMEN_TEORICO.md S:B2 (tc Kirpich), B3 (IDF Uruguay), B4 (Racional,
C ponderado), B5 (NRCS, NC ponderado + bloque alterno + HU triangular).
"""
import numpy as np
import math

# ==== EDITAR ACA (datos del enunciado) ====
Area_km2 = 4.3
dH_m = 45.0
L_m = 2150.0
Tr = 10
P310 = 82.0        # mm, leido de la Fig. 3.1.10 (isoyetas) en X=470,Y=6212.5 (Canelones)
frac_pastizal = 0.70
frac_cultivo = 0.30
NC_pastizal = 74.0  # Tabla NRCS: pastizales, condicion hidrologica OPTIMA, grupo C
NC_cultivo = 85.0   # Tabla NRCS: cultivos en hileras rectas, condicion hidrologica BUENA, grupo C
C_pastizal = 0.30   # Tabla 3.1.4 (Chow): pastizales, S~promedio 2-7%, Tr=10
C_cultivo = 0.36    # Tabla 3.1.4: cultivos/hileras rectas, S~promedio 2-7%, Tr=10
floor_rate = 1.2    # mm/h, piso de infiltracion minima (grupo C)
# ===========================================


def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    return 1.0287*d/((d+1.0293)**0.8083)


def CT(Tr_):
    return 0.5786 - 0.4312*math.log10(math.log(Tr_/(Tr_-1)))


def CA(d, A):
    return 1 - (0.3549*d**(-0.4272))*(1-math.exp(-0.005792*A))


# ---------------- tc (Kirpich, flujo concentrado) ----------------
S_cauce_pct = dH_m/(L_m/1000.0)/10.0   # OJO: pendiente del CAUCE PRINCIPAL (no la "S" de la tabla, que es la media de la cuenca)
tc = 0.4*(L_m/1000.0)**0.77/(S_cauce_pct**0.385)
print(f"S cauce principal = DeltaH/L/10 = {dH_m}/{L_m/1000:.3f}/10 = {S_cauce_pct:.4f} %")
print(f"tc (Kirpich) = {tc:.4f} h ({tc*60:.1f} min)  => 20 min < tc < 1 h => calcular AMBOS metodos")

CT10 = CT(Tr)
print(f"CT(Tr={Tr}) = {CT10:.4f}")

# ---------------- coeficientes ponderados ----------------
NC = frac_pastizal*NC_pastizal + frac_cultivo*NC_cultivo
C_rac = frac_pastizal*C_pastizal + frac_cultivo*C_cultivo
print(f"\nNC ponderado = {frac_pastizal}*{NC_pastizal} + {frac_cultivo}*{NC_cultivo} = {NC:.2f}")
print(f"C ponderado (Racional) = {frac_pastizal}*{C_pastizal} + {frac_cultivo}*{C_cultivo} = {C_rac:.4f}")

# =====================================================================
# METODO RACIONAL
# =====================================================================
d_rac = tc
cd_rac = CD(d_rac)
ca_rac = CA(d_rac, Area_km2)
P_rac = P310*CT10*cd_rac*ca_rac
i_rac = P_rac/d_rac
Ac_ha = Area_km2*100
Q_racional = C_rac*i_rac*Ac_ha/360
print("\n--- METODO RACIONAL ---")
print(f"d=tc={d_rac:.4f} h ; CD={cd_rac:.4f} ; CA={ca_rac:.4f}")
print(f"P(d,Tr,A) = {P310}*{CT10:.4f}*{cd_rac:.4f}*{ca_rac:.4f} = {P_rac:.3f} mm")
print(f"i = P/d = {i_rac:.3f} mm/h")
print(f"Qmax racional = C*i*A(ha)/360 = {C_rac:.4f}*{i_rac:.3f}*{Ac_ha:.1f}/360 = {Q_racional:.3f} m3/s")

# =====================================================================
# METODO NRCS (bloque alterno + NC ponderado + HU triangular SCS)
# =====================================================================
dt = tc/7
n = np.arange(1, 13)
d_n = dt*n
CD_n = np.array([CD(x) for x in d_n])
CA_n = np.array([CA(x, Area_km2) for x in d_n])
P_n = CD_n*CT10*CA_n*P310
M_n = np.diff(np.concatenate(([0.0], P_n)))

order = [12, 10, 8, 6, 4, 2, 1, 3, 5, 7, 9, 11]   # bloque alterno: mayor incremento al centro (slot 7)
N = np.array([M_n[idx-1] for idx in order])

print(f"\n--- TORMENTA DE DISENO (bloque alterno, dt=tc/7={dt*60:.2f} min) ---")
for k in range(12):
    print(f"  bloque {k+1:2d}: {N[k]:6.3f} mm")
print(f"  TOTAL = {N.sum():.3f} mm")

S_mm = 25.4*(1000.0/NC - 10.0)
Ia = 0.2*S_mm
print(f"\nS = 25.4*(1000/{NC:.2f}-10) = {S_mm:.3f} mm ; Ia = 0.2*S = {Ia:.3f} mm")

O = np.cumsum(N)
Pe_cum = np.where(O <= Ia, 0.0, (O-Ia)**2/(O+0.8*S_mm))
Qinc = np.diff(np.concatenate(([0.0], Pe_cum)))
deficit = np.maximum(N-Qinc, floor_rate*dt)
Pe_corr = np.maximum(N-deficit, 0.0)
print(f"suma Pe corregido (con piso de infiltracion {floor_rate} mm/h) = {Pe_corr.sum():.3f} mm")

tp = dt/2 + 0.6*tc
tb = (8/3)*tp
qp = 0.208*Area_km2/tp     # m3/s por mm de Pe
print(f"\n--- HIDROGRAMA UNITARIO TRIANGULAR SCS ---")
print(f"tp={tp:.4f} h, tb={tb:.4f} h, qp={qp:.4f} m3/s/mm")


def UH(x):
    if x < 0:
        return 0.0
    if x <= tp:
        return qp*x/tp
    if x <= tb:
        return qp*(tb-x)/(tb-tp)
    return 0.0


step = dt/8
Nsteps = int(math.ceil((11*dt+tb)/step)) + 40
t = np.arange(0, Nsteps)*step
Qtot = np.zeros_like(t)
for k in range(12):
    shift = k*dt
    Qtot += Pe_corr[k]*np.array([UH(x-shift) for x in t])

Qmax_NRCS = Qtot.max()
tQmax = t[np.argmax(Qtot)]
print(f"\nQmax NRCS (hidrograma) = {Qmax_NRCS:.3f} m3/s en t = {tQmax:.3f} h")

print("\n=====================================================")
print(f"Qmax METODO RACIONAL = {Q_racional:.2f} m3/s")
print(f"Qmax METODO NRCS     = {Qmax_NRCS:.2f} m3/s")
metodo = 'RACIONAL' if Q_racional > Qmax_NRCS else 'NRCS'
print(f"=> Se adopta el MAYOR: {metodo} ({max(Q_racional, Qmax_NRCS):.2f} m3/s)")
