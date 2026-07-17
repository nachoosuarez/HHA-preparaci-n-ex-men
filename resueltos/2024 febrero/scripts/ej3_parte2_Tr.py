"""
Ejercicio 3, Parte 2 - Examen HHA 2024 febrero
Periodo de retorno de la intensidad maxima registrada en un pluviografo
representativo de la cuenca (evento con hietograma en bloques de 10 min:
P(mm) = 3, 6, 12, 26, 9, 4).

Se identifica el bloque de mayor intensidad (26 mm en 10 min, entre
t=30-40min) y se invierte la relacion IDF de Uruguay -evaluada como
PRECIPITACION PUNTUAL (sin CA, porque es la lectura de un unico
pluviografo, no una lluvia de diseno areal)- para hallar el Tr que la
reproduce:  P_obs = P(3,10) * CT(Tr) * CD(d)  =>  CT(Tr) = P_obs/(P(3,10)*CD(d))
"""
import math

P310 = 79.0    # mm, isoyetas Fig 3.1.10 en X=494.4km, Y=6171.8km (Canelones)
P_obs = 26.0   # mm, mayor bloque del hietograma (t=30-40min)
d_hs = 10/60   # duracion de ese bloque, en horas

def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

CDd = CD(d_hs)
print(f"Intensidad maxima registrada: P={P_obs} mm en d={d_hs*60:.0f} min (bloque t=30-40min)")
print(f"CD(d={d_hs*60:.0f}min) = {CDd:.4f}")

CT_target = P_obs/(P310*CDd)
print(f"CT(Tr) objetivo = P_obs/(P310*CD) = {P_obs}/({P310}*{CDd:.4f}) = {CT_target:.4f}")

# inversion de CT(Tr) por biseccion (no tiene forma cerrada)
lo, hi = 1.001, 500.0
for _ in range(200):
    mid = (lo+hi)/2
    if CT(mid) < CT_target:
        lo = mid
    else:
        hi = mid
Tr = (lo+hi)/2
print(f"\nTr (interpolado) = {Tr:.2f} anios  (verificacion: CT({Tr:.2f})={CT(Tr):.4f})")
print(f"Tr redondeado = {round(Tr)} anios")
