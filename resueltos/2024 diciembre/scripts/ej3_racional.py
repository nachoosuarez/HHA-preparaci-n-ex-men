"""
Ejercicio 3, Parte 3 - Examen HHA 16/dic/2024
Caudal maximo de un evento de Tr=5 anios para la cuenca de Artigas delimitada
en la Parte 1 (punto de cierre X=456.7 km, Y=6600.0 km).

Datos ya dados por el enunciado / obtenidos de la cuenca trazada en la Parte 1:
tc=17 min, Area=8.94 km2, pendiente media=3.6%, cubierta mayoritariamente por
pastizal. Como tc=17 min < 20 min, el Teorico HHA (3.1.5) indica usar
UNICAMENTE el metodo Racional (no corresponde NRCS).

El valor base P(3,10)=98 mm (isoyeta en las coordenadas del punto de cierre)
se toma de la solucion oficial manuscrita adjunta al examen.
"""
import math

Area_km2 = 8.94
tc_min = 17.0
tc_hs = tc_min/60
Tr = 5
P310 = 98.0            # mm, isoyeta P(3h,Tr=10) en el punto de cierre - sol. oficial
C_racional = 0.36      # pastizal, S=3.6% (Tabla 3.1.4, metodo racional) - sol. oficial

def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

def CA(d, Ac_km2):
    return 1 - (0.3549*(d**-0.4272))*(1-math.exp(-0.005792*Ac_km2))

print(f"tc = {tc_hs:.4f} hs = {tc_min:.0f} min  (< 20 min => SOLO metodo Racional, Teorico 3.1.5)")

CTv = CT(Tr)
CDv = CD(tc_hs)
CAv = CA(tc_hs, Area_km2)
print(f"CT(Tr=5)      = {CTv:.4f}")
print(f"CD(d=tc)      = {CDv:.4f}")
print(f"CA(d=tc, A)   = {CAv:.4f}")

P = CTv*CDv*CAv*P310
i = P/tc_hs
Ac_ha = Area_km2*100
Q = C_racional*i*Ac_ha/360

print(f"\nP(tc,5,p) = CT*CD*CA*P(3,10) = {P:.3f} mm")
print(f"i = P/tc = {i:.3f} mm/h")
print(f"Q = C*i*A/360 = {C_racional}*{i:.3f}*{Ac_ha:.0f}/360 = {Q:.3f} m3/s")

print("\n=====================================================")
print(f"Qmax de diseno (Tr=5, metodo Racional) = {Q:.2f} m3/s")
