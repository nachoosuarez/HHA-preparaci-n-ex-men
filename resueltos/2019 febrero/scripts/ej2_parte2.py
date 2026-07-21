"""
Ejercicio 2, Parte 2 - Examen HHA 7/feb/2019
Se implementa cultivo de maiz (curvas de nivel, condicion hidrologica
BUENA) sobre el 65% del area de la cuenca; el 35% restante sigue en
pastizales natural cond. MALA (igual que la Parte 1). El cambio de uso
de suelo reduce el tc total un 8%. Se pide el nuevo periodo de retorno
del caudal de diseno encontrado en la Parte 1 (el caudal de la
alcantarilla, YA CONSTRUIDA con esa capacidad fija, se mantiene; lo que
cambia es que Tr para alcanzarlo).

Reutiliza hidrograma_NRCS() de ej2_parte1.py.
"""
import numpy as np
import math
import runpy

p1 = runpy.run_path('ej2_parte1.py')
hidrograma_NRCS = p1['hidrograma_NRCS']
Area_km2 = p1['Area_km2']
tc_hs = p1['tc_hs']
P310 = p1['P310']
Qmax_diseno = p1['Qmax1']   # 29.72 m3/s, caudal de diseno de la Parte 1 (capacidad de la alcantarilla)

print("\n\n================ PARTE 2 ================")

# ---------- NC ponderado (65% maiz cond. buena + 35% pastizal cond. mala) ----------
NC_maiz = 82        # cultivo en hileras, sembrado por curvas de nivel, cond. hidrologica BUENA, GH C (Fig 3.1.20) - sol. oficial
NC_pastizal = 86    # igual que la Parte 1 (sin cambios en el 35% restante)
pct_maiz = 0.65
pct_pastizal = 0.35
NC_new = pct_maiz*NC_maiz + pct_pastizal*NC_pastizal
print(f"NC ponderado = {pct_maiz}*{NC_maiz} (maiz, curvas de nivel, buena) + {pct_pastizal}*{NC_pastizal} (pastizal, mala) = {NC_new:.2f}")

# ---------- tc reducido 8% ----------
tc_new = tc_hs*(1-0.08)
print(f"tc nuevo = 0.92 * tc = 0.92*{tc_hs:.4f} = {tc_new:.4f} hs = {tc_new*60:.2f} min")

def Qmax_de_Tr(Tr_):
    _, Qtot, *_ = hidrograma_NRCS(tc_new, Tr_, Area_km2, NC_new, P310)
    return Qtot.max()

print("\nTanteo de Tr (con tc y NC nuevos):")
for Tr_test in (3,5,6,7,7.5,8,10):
    print(f"  Tr={Tr_test:>4} anios -> Qmax NRCS(tc_new,NC_new) = {Qmax_de_Tr(Tr_test):.3f} m3/s")

def biseccion(f, lo, hi, iters=100):
    flo = f(lo)
    for _ in range(iters):
        mid = (lo+hi)/2
        fm = f(mid)
        if (fm > 0) == (flo > 0):
            lo, flo = mid, fm
        else:
            hi = mid
    return (lo+hi)/2

Tr_exact = biseccion(lambda Tr_: Qmax_de_Tr(Tr_)-Qmax_diseno, 1.01, 60)
print(f"\nTr exacto (interpolado, continuo) para Qmax=Qdiseno={Qmax_diseno:.2f} m3/s: {Tr_exact:.3f} anios")
Tr_floor, Tr_ceil = math.floor(Tr_exact), math.ceil(Tr_exact)
print(f"=> Con precision de 1 anio: Tr={Tr_floor} da Qmax={Qmax_de_Tr(Tr_floor):.2f} m3/s ; "
      f"Tr={Tr_ceil} da Qmax={Qmax_de_Tr(Tr_ceil):.2f} m3/s")
print(f"\nRESULTADO PARTE 2: nuevo periodo de retorno del caudal de diseno ~ Tr = {Tr_exact:.1f} anios")
print("(el NC baja mas de lo que sube el caudal por la reduccion de tc: el cultivo en curvas de")
print(" nivel en condicion BUENA infiltra mas que el pastizal en condicion MALA que reemplaza,")
print(" asi que para generar el MISMO caudal de diseno ahora hace falta un evento mas raro, Tr>5)")
