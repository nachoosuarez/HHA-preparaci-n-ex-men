"""
Ejercicio 3, Parte 1.2 - Examen HHA 5/feb/2025 (2025_FEBRERO 2)
Desnivel maximo del cauce principal y tiempo de concentracion de la cuenca
delimitada en la carta topografica SGM (punto de cierre X=477.0km,
Y=6332.0km, departamento de Durazno).

La delimitacion de la cuenca (1.1) es un trabajo grafico sobre la carta
(ver ej3_carta_sin_delimitar.png y ej3_cuenca_delimitada.png): la divisoria
de aguas se traza perpendicular a las curvas de nivel, uniendo los puntos
altos (lineas de cumbre) que separan el agua que escurre hacia el punto de
cierre del resto de la cuenca vecina. Las cotas maxima y minima leidas
sobre la delimitacion (interpolando entre curvas de nivel cada 10 m) son
las que se usan aqui.
"""
import math

# ---------- Cotas leidas sobre la cuenca delimitada ----------
Hmax_m = 145.0   # cota mas alta dentro de la cuenca (loma sur, entre curvas 140-150)
Hmin_m = 105.0   # cota del punto de cierre (entre curvas 100-110)
dH_m = Hmax_m - Hmin_m

L_m = 4530.0     # longitud del cauce principal (dato del enunciado)
L_km = L_m/1000
S_pct = dH_m/L_km/10   # pendiente del cauce principal (%), formula Kirpich

tc_hs = 0.4*(L_km**0.77)/(S_pct**0.385)
tc_min = tc_hs*60

print(f"Cota maxima del cauce principal = {Hmax_m:.1f} m")
print(f"Cota minima (punto de cierre)   = {Hmin_m:.1f} m")
print(f"Desnivel maximo del cauce principal, dH = {dH_m:.1f} m")
print(f"\nL (cauce principal) = {L_m:.0f} m = {L_km:.3f} km")
print(f"S (cauce principal) = dH/L/10 = {S_pct:.4f} %")
print(f"\ntc (Ramser-Kirpich) = 0.4*L_km^0.77/S^0.385 = {tc_hs:.4f} hs = {tc_min:.2f} min")
