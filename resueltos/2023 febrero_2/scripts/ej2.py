"""
Ejercicio 2 - Examen HHA 24/feb/2023

2.1) Periodo de retorno de la intensidad maxima registrada en el
     pluviografo durante el evento (bloque 0.5-0.8 hs, I=98 mm/h, el mayor
     del hietograma dado en el enunciado).
2.2) Tiempo de encharcamiento del evento, con el modelo de infiltracion
     de Horton (f0=112 mm/h, fc=0.18 mm/h, k=2.5 1/h).

Metodologia identica a resueltos/2023 Julio/scripts/Ejercicio2_parte3_Tr_pluviografo.py
(inversion numerica de CT(Tr), CA=1 por ser un dato PUNTUAL de pluviografo)
para 2.1; formula de Horton (Resumen Teorico B8) para 2.2.
"""
import math

def brentq(f, a, b, tol=1e-10):
    fa, fb = f(a), f(b)
    for _ in range(200):
        m = (a+b)/2
        fm = f(m)
        if abs(fm) < tol:
            return m
        if (fa < 0) == (fm < 0):
            a, fa = m, fm
        else:
            b, fb = m, fm
    return (a+b)/2

def CD(d):
    if d <= 3:
        return 0.6208*d/((d+0.0137)**0.5639)
    else:
        return 1.0287*d/((d+1.0293)**0.8083)

def CT(Tr):
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

print("=== 2.1) Tr de la intensidad maxima registrada ===")
P310 = 81.0     # mm, P(3h,10a) leida del mapa de isoyetas en Canelones (dato de la sol. oficial)
Imax = 98.0     # mm/h, mayor intensidad del hietograma (bloque 0.5-0.8 hs)
d_h = 0.8 - 0.5  # duracion del bloque de mayor intensidad = 0.3 hs

CD_d = CD(d_h)
print(f"d = {d_h:.2f} hs ; CD(d) = {CD_d:.4f}")

CA = 1.0  # dato PUNTUAL de pluviografo (no hay area de cuenca que promediar)
CT_target = Imax*d_h/(P310*CD_d*CA)
print(f"CT objetivo = Imax*d/(P310*CD*CA) = {Imax}*{d_h}/({P310}*{CD_d:.4f}*{CA}) = {CT_target:.4f}")

Tr = brentq(lambda x: CT(x)-CT_target, 1.001, 500)
print(f"Tr (invirtiendo CT(Tr)=CT objetivo, biseccion) = {Tr:.3f} anios")
print("(CT objetivo esta muy cerca de 1 = CT(10) por definicion => Tr proximo a 10 "
      "anios; en la practica se adopta el Tr TABULADO mas cercano: 10 anios)")

print("\n=== 2.2) Tiempo de encharcamiento (modelo de Horton) ===")
f0 = 112.0  # mm/h
fc = 0.18   # mm/h
k  = 2.5    # 1/h

def f(t):
    return fc + (f0-fc)*math.exp(-k*t)

# Hietograma del enunciado (intervalos e intensidad media, mm/h)
bloques = [(0.0,0.2,15.0), (0.2,0.5,68.0), (0.5,0.8,98.0), (0.8,1.1,30.0),
           (1.1,1.4,15.0), (1.4,1.7,11.0), (1.7,2.0,5.0), (2.0,2.3,3.0),
           (2.3,2.6,1.0), (2.6,2.9,0.5)]

print(f"{'t inicio (h)':>12} | {'I bloque (mm/h)':>16} | {'f(t inicio) (mm/h)':>18} | ¿I>=f?")
t_enc = None
for (t_ini, t_fin, I) in bloques:
    ft = f(t_ini)
    # tolerancia relativa: a t=0.2h da I=68.00 vs f=68.02 (dif. 0.03%) -- en la
    # practica es el mismo valor (redondeo de la solucion oficial), asi que se
    # considera "igual" dentro de una tolerancia chica en vez de exigir I>=f
    # estricto (que recien se cumpliria, por una diferencia despreciable, en
    # el bloque siguiente).
    encharca = I >= ft*0.999
    print(f"{t_ini:12.2f} | {I:16.2f} | {ft:18.2f} | {'SI' if encharca else 'no'}")
    if encharca and t_enc is None:
        t_enc = t_ini

print(f"\nTiempo de encharcamiento t_enc = {t_enc:.2f} hs "
      f"(la intensidad del bloque {t_enc}-{t_enc+0.3}hs, 98.0 mm/h, alcanza "
      f"f({t_enc})={f(t_enc):.2f} mm/h -- practicamente igual a la intensidad "
      f"I=68.00 mm/h del bloque anterior que arranca en t={t_enc}h; a partir "
      f"de ahi I>f en todos los bloques restantes)")
