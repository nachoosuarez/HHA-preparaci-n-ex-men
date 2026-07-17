"""Ejercicio3_racional.py — Examen HHA 1 de marzo 2024, Ejercicio 3.

Replica EXACTAMENTE las formulas de la hoja "Calculos (grande)" de
Scripts/01_SCRIPTS/Eventos extremos.xlsx (documentadas en
RESUMEN EXAMEN/Teorico/COMO_USAR_EVENTOS_EXTREMOS.md, seccion 1.b-1.c),
sin el bug del *1.15 en J4 (se usa Tc=C7 directo). Resuelve el metodo
Racional para el diseno de una alcantarilla (Tr=5 anios) y el recalculo
tras urbanizacion parcial + reduccion de tc (Tr=10 anios).

Datos: Area=4.5 km2, dH=80 m, L cauce=1600 m, S cuenca media=6.3%
(usada solo para elegir C en la Tabla 3.1.4, "pastizales, promedio 2-7%"),
Grupo Hidrologico B. P(3,10)=80 mm (dato tomado de la solucion oficial
manuscrita, lectura del mapa de isoyetas Fig. 3.1.10 para la ubicacion
de la cuenca, X=550 km Y=6275 km, NO de Lavalleja).
"""
import math


def tc_kirpich(L_km, S_pct):
    """Tc de Kirpich/Ramser (horas). L en km, S en % (pendiente del cauce)."""
    return 0.4 * L_km ** 0.77 / S_pct ** 0.385


def CT(Tr):
    return 0.5786 - 0.4312 * math.log10(math.log(Tr / (Tr - 1)))


def CD(d_h):
    if d_h < 3:
        return 0.6208 * d_h / (d_h + 0.0137) ** 0.5639
    return 1.0287 * d_h / (d_h + 1.0293) ** 0.8083


def CA(A_km2, d_h):
    return 1.0 - (0.3549 * d_h ** -0.4272) * (1.0 - math.exp(-0.005792 * A_km2))


def Q_racional(C, P310, Tr, d_h, A_km2):
    P = P310 * CT(Tr) * CD(d_h) * CA(A_km2, d_h)
    i = P / d_h  # mm/h
    A_ha = A_km2 * 100
    Q = C * i * A_ha / 360
    return Q, P, i


# ---- Datos del enunciado ----
A_km2 = 4.5
dH = 80.0       # m
L_m = 1600.0    # m
L_km = L_m / 1000
S_cuenca = 6.3  # % (pendiente media de la cuenca, solo para elegir C)
P310 = 80.0     # mm, P(3,10) del punto de cierre (lectura de isoyetas)

S_cauce = dH / L_km / 10  # % (pendiente DEL CAUCE PRINCIPAL, para Kirpich)
print(f"S_cauce = dH/L/10 = {dH}/{L_km}/10 = {S_cauce:.2f} %  (!= S_cuenca={S_cuenca}%)")

tc = tc_kirpich(L_km, S_cauce)
print(f"Tc (Kirpich) = 0.4*{L_km}^0.77/{S_cauce:.2f}^0.385 = {tc:.4f} h = {tc*60:.1f} min")
print("Tc < 20 min => usar SOLO el metodo Racional (Teorico 3.1.5)\n")

# ---- Parte 2: diseño de la alcantarilla, Tr=5 años ----
print("--- Parte 2: alcantarilla, Tr=5 años ---")
C_pastizal_5 = 0.36  # Tabla 3.1.4: Pastizales, Promedio 2-7%, Tr=5
Q2, P2, i2 = Q_racional(C_pastizal_5, P310, 5, tc, A_km2)
print(f"C (pastizales, promedio 2-7%, Tr=5) = {C_pastizal_5}")
print(f"P(Tr=5,tc) = {P2:.2f} mm ; i = {i2:.2f} mm/h")
print(f"Qmax racional (Tr=5) = {Q2:.2f} m3/s\n")

# ---- Parte 3: urbanización 25% + tc reducido 18%, Tr=10 años ----
print("--- Parte 3: urbanización 25% del área, tc -18%, Tr=10 años ---")
tc3 = tc * (1 - 0.18)
print(f"Tc nuevo = Tc*(1-0.18) = {tc3:.4f} h = {tc3*60:.1f} min")

C_pastizal_10 = 0.38   # Tabla 3.1.4: Pastizales, Promedio 2-7%, Tr=10 (75% del area)
C_concreto_10 = 0.83   # Tabla 3.1.4: Concreto/techo, Tr=10        (25% del area)
C_ponderado = 0.75 * C_pastizal_10 + 0.25 * C_concreto_10
print(f"C pastizal(Tr=10)={C_pastizal_10} (75% area) ; C concreto/techo(Tr=10)={C_concreto_10} (25% area)")
print(f"C ponderado = 0.75*{C_pastizal_10} + 0.25*{C_concreto_10} = {C_ponderado:.4f}")

Q3, P3, i3 = Q_racional(C_ponderado, P310, 10, tc3, A_km2)
print(f"P(Tr=10,tc_nuevo) = {P3:.2f} mm ; i = {i3:.2f} mm/h")
print(f"Qmax racional (Tr=10, urbanizado) = {Q3:.2f} m3/s")
