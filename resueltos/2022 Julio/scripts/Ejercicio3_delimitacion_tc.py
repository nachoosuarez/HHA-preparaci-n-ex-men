"""
Ejercicio 3 - Examen HHA 25/jul/2022
Delimitacion de la cuenca de la canada Sin Nombre (Canelones), punto de
cierre X=470.7km, Y=6212.5km, carta SGM con curvas de nivel cada 5 m.

Parte 1 (delimitacion grafica) no tiene formula: se resuelve dibujando la
divisoria de aguas sobre la carta (perpendicular a las curvas de nivel,
por el lado convexo al ganar altura -lomas/nacientes-, por el lado
concavo al perder altura -vaguadas de la cuenca vecina-, sin cruzar
nunca un curso de agua salvo en el punto de cierre). Ver
RESUMEN_TEORICO.md B1. El propio examen trae la solucion oficial
graficada (PDF pagina 7) para verificar el trazado.

Parte 2: con L=4250m (dato del enunciado) y las cotas leidas en la
carta (equidistancia 5m) en el punto de cierre y en el punto mas alto
del cauce principal dentro de la cuenca delimitada, se calcula la
pendiente por extremos y el tiempo de concentracion (Ramser-Kirpich,
flujo concentrado).
"""
import math

L_m = 4250.0
L_km = L_m/1000

# Cotas leidas en la carta topografica (SGM, equidistancia 5m):
# - H_max: cota mas alta del cauce principal dentro de la cuenca
#   delimitada (nacimiento, cerca de una cota acotada "88.0" en la carta).
# - H_cierre: cota del punto de cierre (X=470.7km, Y=6212.5km),
#   interpolada entre las curvas de nivel de 40 y 45 m que lo rodean.
H_max = 88.0
H_cierre = 42.0
dH = H_max - H_cierre

S_extremos_pct = dH / L_km / 10
print(f"H_max = {H_max} m ; H_cierre = {H_cierre} m")
print(f"Desnivel maximo del cauce principal: dH = {H_max}-{H_cierre} = {dH} m")
print(f"Pendiente por extremos: S = dH/L/10 = {dH}/{L_km}/10 = {S_extremos_pct:.4f} %")

# Flujo concentrado -> Ramser-Kirpich (misma formula que Ejercicio 2)
tc_hs = 0.4 * (L_km**0.77) / (S_extremos_pct**0.385)
print(f"tc = 0.4*L^0.77/S^0.385 = {tc_hs:.4f} hs = {tc_hs*60:.2f} min")
