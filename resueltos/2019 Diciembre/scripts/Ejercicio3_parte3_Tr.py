"""
Ejercicio 3, Parte 3 - Examen HHA 16/dic/2019.
Periodo de retorno de una precipitacion extrema observada (pluviografo
dentro de la cuenca delimitada en la parte 1): P=45 mm en d=1 hora.
P(3,10) en el punto de cierre (X=491.9km, Y=6173.0km), leido de la
Figura 3.1.10 (isoyetas) del Teorico HHA: P310=79 mm (confirmado
visualmente: el punto cae justo al lado de la isolinea gruesa de 80 mm,
levemente hacia el interior/sur de Uruguay respecto a ella).

Se invierte P=P310*CT(Tr)*CD(d) (CA=1, dato puntual de pluviografo, sin
correccion de area) despejando CT(Tr) y resolviendo Tr por fzero, ya que
CT(Tr) no es invertible en forma cerrada (RESUMEN_TEORICO.md, B3,
"Encontrar el Tr de un evento observado").
"""
import numpy as np
from scipy.optimize import brentq

P310 = 79.0   # mm, Fig 3.1.10 en X=491.9,Y=6173.0
d = 1.0       # h
P_obs = 45.0  # mm

def CD(d):
    return 0.6208*d/(d+0.0137)**0.5639 if d < 3 else 1.0287*d/(d+1.0293)**0.8083

def CT(Tr):
    return 0.5786 - 0.4312*np.log10(np.log(Tr/(Tr-1)))

if __name__ == "__main__":
    CDd = CD(d)
    CT_obj = P_obs/(P310*CDd)
    print(f"CD(d=1h) = {CDd:.4f}")
    print(f"CT objetivo = P_obs/(P310*CD) = {CT_obj:.4f}")

    print("\nTr (anios) |  P(Tr) = P310*CT(Tr)*CD (mm)")
    for Tr in [2, 5, 10, 25, 50]:
        print(f"  {Tr:5.0f}    |  {P310*CT(Tr)*CDd:6.2f}")

    Tr_sol = brentq(lambda Tr: CT(Tr) - CT_obj, 1.01, 500)
    print(f"\nTr = {Tr_sol:.2f} anios")
