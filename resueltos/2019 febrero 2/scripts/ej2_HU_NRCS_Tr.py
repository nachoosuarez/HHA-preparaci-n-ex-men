"""
Ejercicio 2 - Examen HHA 22/feb/2019 ("2019 febrero 2")

Cuenca en Velazquez, Rocha (X=625, Y=6240 km). Area=5.2 km2, DeltaH=62 m,
L(cauce)=4600 m, Grupo Hidrologico C, uso "hierbas con baja densidad y
arbustos", S cuenca=5.5% (pendiente MEDIA de la cuenca -- no se usa aca,
no se pide metodo Racional; solo sirve para elegir C si hiciera falta).

Evento extremo: P=32 mm, duracion efectiva D=15 min=0.25 h, uniforme
sobre toda la cuenca. Flujo concentrado (dato del enunciado).

Parte 2: hidrograma unitario triangular SCS para esa duracion efectiva.
Parte 3: hidrograma resultante del evento, con condiciones antecedentes
         humedas (AMC III) -> corrige el NC antes de calcular Pe.
Parte 4: periodo de retorno del evento registrado (P=32mm, d=0.25h),
         invirtiendo CT(Tr) con la IDF de Uruguay.

Ver RESUMEN_TEORICO.md S:B2 (tc Kirpich), B5 (NC + HU triangular SCS),
B6 (AMC), B3 (IDF Uruguay, inversion de Tr).
"""
import math

# ==== EDITAR ACA (datos del enunciado) ====
Area_km2 = 5.2
dH_m = 62.0
L_m = 4600.0
NC_II = 71.0       # tabla NRCS: "hierbas con baja densidad y arbustos", grupo C
P_evento = 32.0    # mm
D_ef_h = 15/60     # duracion efectiva del evento, h
P310 = 76.0        # mm, leido de la Fig. 3.1.10 (isoyetas) en X=625,Y=6240 (Velazquez, Rocha)
# ===========================================


def CD(d):
    """Curva IDF Uruguay: correccion por duracion (d en horas)."""
    if d < 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)


def CT(Tr):
    """Curva IDF Uruguay: correccion por periodo de retorno."""
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))


def CA(A, d):
    """Curva IDF Uruguay: correccion por area (A en km2, d en horas)."""
    return 1.0 - (0.3549*d**(-0.4272))*(1.0 - math.exp(-0.005792*A))


# ---------------- tc (Ramser-Kirpich, flujo concentrado) ----------------
S_cauce_pct = dH_m/(L_m/1000.0)/10.0   # OJO: pendiente del CAUCE PRINCIPAL, no la "S cuenca" de la tabla
tc = 0.4*(L_m/1000.0)**0.77 / (S_cauce_pct**0.385)
print(f"S cauce principal = DeltaH/L/10 = {dH_m}/{L_m/1000:.2f}/10 = {S_cauce_pct:.4f} %")
print(f"tc (Kirpich, flujo concentrado) = {tc:.4f} h ({tc*60:.1f} min)")

# ---------------- Parte 2: HU triangular para D=15 min ----------------
tp = D_ef_h/2 + 0.6*tc
tb = (8/3)*tp
qp_unit = 0.208*Area_km2/tp   # m3/s por mm de Pe
print(f"\n--- Parte 2: HU triangular (D={D_ef_h*60:.0f} min) ---")
print(f"tp = D/2 + 0.6*tc = {D_ef_h/2:.4f} + {0.6*tc:.4f} = {tp:.4f} h")
print(f"tb = 8/3 * tp = {tb:.4f} h")
print(f"Qp (por mm de Pe) = 0.208*A/tp = 0.208*{Area_km2}/{tp:.4f} = {qp_unit:.4f} m3/s/mm")

# ---------------- Parte 3: Pe con AMC III + hidrograma resultante ----------------
NC_III = 23.0*NC_II/(10 + 0.13*NC_II)
S_mm = 25.4*(1000.0/NC_III - 10.0)
Ia = 0.2*S_mm
if P_evento <= Ia:
    Pe = 0.0
else:
    Pe = (P_evento-Ia)**2/(P_evento+0.8*S_mm)
Qp_evento = Pe*qp_unit
print(f"\n--- Parte 3: condiciones antecedentes humedas (AMC III) ---")
print(f"NC(II)={NC_II} -> NC(III) = 23*NC(II)/(10+0.13*NC(II)) = {NC_III:.2f}")
print(f"S = 25.4*(1000/NC(III)-10) = {S_mm:.3f} mm ; Ia = 0.2*S = {Ia:.3f} mm")
print(f"P={P_evento} mm > Ia => Pe = (P-Ia)^2/(P+0.8S) = {Pe:.3f} mm")
print(f"Qp del evento = Pe * Qp_unitario = {Pe:.3f} * {qp_unit:.4f} = {Qp_evento:.3f} m3/s")
print(f"(hidrograma triangular con el mismo tp={tp:.3f} h y tb={tb:.3f} h del HU, escalado por Pe)")

# ---------------- Parte 4: periodo de retorno del evento ----------------
cd = CD(D_ef_h)
ca = CA(Area_km2, D_ef_h)
ct_obj = P_evento/(P310*cd*ca)
print(f"\n--- Parte 4: Tr del evento registrado ---")
print(f"CD({D_ef_h:.2f}h) = {cd:.4f} ; CA(A={Area_km2}km2,d={D_ef_h:.2f}h) = {ca:.4f}")
print(f"CT objetivo = P/(P310*CD*CA) = {P_evento}/({P310}*{cd:.4f}*{ca:.4f}) = {ct_obj:.4f}")

# invertir CT(Tr) por biseccion (CT es creciente en Tr)
lo, hi = 1.0001, 500.0
for _ in range(200):
    mid = (lo+hi)/2
    if CT(mid) < ct_obj:
        lo = mid
    else:
        hi = mid
Tr = (lo+hi)/2
print(f"Invirtiendo CT(Tr)={ct_obj:.4f} (biseccion) => Tr = {Tr:.2f} anios")
