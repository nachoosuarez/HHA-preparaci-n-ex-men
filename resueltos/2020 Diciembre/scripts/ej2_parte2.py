"""
Ejercicio 2, Parte 2 - Examen HHA 22/dic/2020 (Variante A)
Tras una obra de regularizacion del cauce, tc aumenta un 40%. Se pide:
2.1) El periodo de retorno (precision de 1 anio) para el cual se supera
     el caudal de diseno de la Parte 1 (43.43 m3/s).
2.2) Comparar el hidrograma de 2.1 con el de la Parte 1.

Reutiliza hidrograma_NRCS() de ej2_parte1.py.
"""
import numpy as np
import math
import runpy

# Reejecuta parte 1 en su propio namespace para reusar funciones/datos sin duplicar
p1 = runpy.run_path('ej2_parte1.py')
hidrograma_NRCS = p1['hidrograma_NRCS']
Area_km2 = p1['Area_km2']
tc_hs = p1['tc_hs']
Qmax_diseno = p1['Qmax1']   # 43.43 m3/s, caudal de diseno de la Parte 1

tc_new = tc_hs*1.4
print(f"\n\n================ PARTE 2 ================")
print(f"tc nuevo = 1.4 * tc = 1.4*{tc_hs:.4f} = {tc_new:.4f} hs")

def Qmax_de_Tr(Tr):
    _,Qtot,_,_,_,_ = hidrograma_NRCS(tc_new, Tr, Area_km2)
    return Qtot.max()

print("\nTanteo de Tr:")
for Tr_test in (10,15,17,18,19,20,25):
    print(f"  Tr={Tr_test:>2} anios -> Qmax NRCS(tc_new) = {Qmax_de_Tr(Tr_test):.3f} m3/s")

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

Tr_exact = biseccion(lambda Tr: Qmax_de_Tr(Tr)-Qmax_diseno, 5, 40)
print(f"\nTr exacto (interpolado) para Qmax=Qdiseno={Qmax_diseno:.2f} m3/s: {Tr_exact:.3f} anios")
print(f"=> Con precision de 1 anio: para Tr={math.floor(Tr_exact)} NO se supera "
      f"({Qmax_de_Tr(math.floor(Tr_exact)):.2f}<{Qmax_diseno:.2f}); "
      f"para Tr={math.ceil(Tr_exact)} SI se supera ({Qmax_de_Tr(math.ceil(Tr_exact)):.2f}>{Qmax_diseno:.2f})")
print(f"   El caudal de diseno se supera A PARTIR DE Tr = {math.ceil(Tr_exact)} anios")

# ---------- Parte 2.2: comparacion de hidrogramas ----------
t1, Q1, N1, Pe1, Tp1, Tb1 = hidrograma_NRCS(tc_hs, 10, Area_km2)
t2, Q2, N2, Pe2, Tp2, Tb2 = hidrograma_NRCS(tc_new, Tr_exact, Area_km2)
print(f"\nComparacion:")
print(f"  Parte 1 (tc={tc_hs:.3f} hs, Tr=10):      Qmax={Q1.max():.2f} m3/s en t={t1[np.argmax(Q1)]:.2f} hs, Tb={Tb1:.2f} hs")
print(f"  Parte 2 (tc={tc_new:.3f} hs, Tr={Tr_exact:.1f}): Qmax={Q2.max():.2f} m3/s en t={t2[np.argmax(Q2)]:.2f} hs, Tb={Tb2:.2f} hs")
print("  => Al aumentar tc, el hidrograma se ENSANCHA (Tp y Tb mayores) y el pico se")
print("     ALCANZA MAS TARDE; para llegar al mismo caudal de diseno hace falta un Tr mayor.")
