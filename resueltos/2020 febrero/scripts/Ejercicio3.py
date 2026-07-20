"""Ejercicio3.py -- Examen HHA 28/feb/2020, Ejercicio 3 (25 pts).

Cuenca en Artigas, A=12.8 km2, tc>1h. Evento extremo de junio con
hietograma (precipitacion efectiva ya dada por bloques de 1h):

  t (h)        0-1   1-2   2-3   3-4   4-5
  P (mm)        11    17    52    12     6
  Pef (mm)       0   0.4  23.5   0.3   0.1

Parte 1: hidrograma de crecida (HU triangular simetrico dado: tb=1.5h,
qp=3.10 m3/s/mm), despreciando Pef<1mm en el intervalo.
Parte 2: Numero de Curva de la cuenca a partir del evento (P5d previos=16mm).
Parte 3: periodo de retorno del evento de precipitacion TOTAL (dato de
pluviografo), D=5h, P(3,10)=96mm (lectura grafica, Fig. 3.1.10 Teorico).

Requiere solo la libreria estandar (bisection casera, sin scipy).
"""

# ------------------------------------------------------------------
# PARTE 1: hidrograma por convolucion (un unico pulso significativo)
# ------------------------------------------------------------------
P = [11, 17, 52, 12, 6]
Pef = [0, 0.4, 23.5, 0.3, 0.1]
tb_HU = 1.5      # h, tiempo base del HU triangular (dato)
tp_HU = tb_HU/2  # h, tiempo al pico (triangulo simetrico)
qp_HU = 3.10     # m3/s/mm, caudal pico del HU (dato)

print("=========== PARTE 1: hidrograma de crecida ===========")
pulsos = [(i, p) for i, p in enumerate(Pef) if p >= 1.0]
print(f"Bloques con Pef>=1mm (resto despreciable): {pulsos}")
for i, pef in pulsos:
    t0 = i          # inicio del bloque i (h), i=0 -> [0,1], i=2 -> [2,3], etc.
    Qp = pef * qp_HU
    print(f"  Bloque [{t0},{t0+1}]h: Pef={pef} mm -> Qp = {pef}*{qp_HU} = {Qp:.2f} m3/s")
    print(f"    Hidrograma: sube desde t={t0}h, pico Qp={Qp:.2f} m3/s en t={t0+tp_HU}h, "
          f"vuelve a 0 en t={t0+tb_HU}h")

# ------------------------------------------------------------------
# PARTE 2: Numero de Curva a partir del evento observado
# ------------------------------------------------------------------
print("\n=========== PARTE 2: Numero de Curva ===========")
Ptot = sum(P)
Peftot = sum(Pef)
print(f"P total = suma(P) = {Ptot} mm")
print(f"Pef total = suma(Pef) = {Peftot} mm")

def pef_nrcs(Ptot, S):
    if Ptot <= 0.2*S:
        return 0.0
    return (Ptot - 0.2*S)**2 / (Ptot + 0.8*S)

# resolver S tal que pef_nrcs(Ptot,S) = Peftot  (biseccion)
lo, hi = 0.001, 2000.0
for _ in range(200):
    mid = (lo+hi)/2
    if pef_nrcs(Ptot, mid) > Peftot:
        lo = mid
    else:
        hi = mid
S = (lo+hi)/2
NC = 25400/(S+254)
print(f"S (retencion potencial) tal que Pef({Ptot},S)={Peftot} mm -> S = {S:.2f} mm")
print(f"NC = 25400/(S+254) = {NC:.2f}")

P5d = 16  # mm, precipitacion en los 5 dias previos (junio = estacion inactiva)
print(f"P5d previos = {P5d} mm, evento en junio (estacion INACTIVA)")
print("Umbrales AMC (estacion inactiva): AMC I <12.7mm | AMC II 12.7-27.94mm | AMC III >27.94mm")
if 12.7 <= P5d <= 27.94:
    print(f"{P5d} mm cae en AMC II -> NC ya calculado (de este mismo evento) ES el NC(II) de tabla, sin corregir")
print(f"NC de la cuenca = {NC:.1f}")

# ------------------------------------------------------------------
# PARTE 3: periodo de retorno del evento (precipitacion TOTAL, pluviografo)
# ------------------------------------------------------------------
print("\n=========== PARTE 3: periodo de retorno (P total) ===========")
D = 5.0        # h, duracion total del evento registrado
P310 = 96.0    # mm, lectura grafica Fig. 3.1.10 (Artigas SO)

def CD(d):
    if d < 3:
        return 0.6208*d/(d+0.0137)**0.5639
    else:
        return 1.0287*d/(d+1.0293)**0.8083

def CT(Tr):
    import math
    return 0.5786 - 0.4312*math.log10(math.log(Tr/(Tr-1)))

CDd = CD(D)
CT_obj = Ptot/(P310*CDd)
print(f"CD({D}h) = {CDd:.4f}")
print(f"CT objetivo = Ptot/(P310*CD) = {Ptot}/({P310}*{CDd:.4f}) = {CT_obj:.4f}")

# invertir CT(Tr) por biseccion
lo, hi = 1.001, 500.0
for _ in range(200):
    mid = (lo+hi)/2
    if CT(mid) > CT_obj:
        hi = mid
    else:
        lo = mid
Tr = (lo+hi)/2
print(f"Tr tal que CT(Tr)={CT_obj:.4f} -> Tr = {Tr:.2f} anios")
