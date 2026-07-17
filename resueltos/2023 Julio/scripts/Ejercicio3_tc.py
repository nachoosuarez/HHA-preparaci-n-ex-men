"""
Ejercicio 3, Parte 3 - Examen HHA 24/jul/2023
Desnivel maximo del cauce principal y tiempo de concentracion de la
cuenca de la canada de Arbelo (departamento de Canelones), delimitada
en la carta topografica SGM (punto de cierre X=520 km, Y=6160 km,
curvas de nivel cada 5 m).

La delimitacion de la cuenca (Parte 1) es un trabajo grafico sobre la
carta (ver ej3_carta_sin_delimitar.png y ej3_carta_solucion_oficial.png):
la divisoria de aguas se traza perpendicular a las curvas de nivel,
ganando altura por el lado convexo (lomas/cuchillas que separan la
canada de Arbelo de las canadas vecinas) y cerrando en el punto de
cierre marcado. El poligono resultante es alargado (forma de "hoja"),
siguiendo el valle del curso principal desde el punto de cierre (cerca
de la interseccion de caminos al norte del area, cota ~38 m) hasta sus
nacientes (loma al norte-noroeste del area, cota ~66 m).

Las cotas maxima y minima leidas sobre la delimitacion (interpolando
entre curvas de nivel cada 5 m) son las que se usan aqui; coinciden con
las de la solucion oficial manuscrita.
"""
import math

# ---------- Cotas leidas sobre la cuenca delimitada ----------
Hmax_m = 66.0    # cota mas alta del cauce principal (naciente, loma norte)
Hmin_m = 38.0    # cota del punto de cierre
dH_m = Hmax_m - Hmin_m

L_m = 7850.0     # longitud del cauce principal (dato del enunciado)
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
