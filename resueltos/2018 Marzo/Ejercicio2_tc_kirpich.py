"""
Ejercicio 2, partes 1-2 (examen HHA 22 marzo 2018).
Cuenca del arroyo Molles de Quinteros (Durazno). El punto de cierre
viene marcado explicitamente en la carta SGM adjunta (ver
ej2_cuenca_esquematica.png), a diferencia de 2018 diciembre donde no
habia forma de anclar las coordenadas. La longitud del cauce principal
Lcp=5300 m es un dato del enunciado (no hace falta medirla en la carta).

Desnivel maximo del cauce (DeltaH): lectura visual de las curvas de
nivel (cada 10 m) entre el punto de cierre (fondo de valle, cota
estimada ~85-90 m por las cotas de punto vecinas 100/111 m) y la
naciente del tributario mas largo del abanico que converge en el
cierre, que se prolonga hacia el area del camino/"Establecimiento Los
Ceibos" (cota estimada ~125-130 m por las cotas de punto vecinas
121/125/128 m). Estimacion propia (antes de mirar la solucion oficial):
cierre 85-90 m, naciente 120-130 m -- rango consistente con la
solucion oficial manuscrita, que da valores puntuales exactos (88 m y
125 m, ver RESOLUCION.md) y el mismo DeltaH=37 m usado aqui, con
tc=1.66 h.
"""

L_cp = 5.300  # km (dato del enunciado)
dH = 37.0     # m (125 m naciente - 88 m punto de cierre; ver RESOLUCION.md)

S = dH / L_cp / 10  # % (formula de Ramser-Kirpich, S=DeltaH(m)/L(km)/10)
tc = 0.4 * L_cp**0.77 / S**0.385  # horas

print(f"S (cauce principal) = {S:.4f} %")
print(f"tc (Ramser-Kirpich) = {tc:.3f} h = {tc*60:.1f} min")
